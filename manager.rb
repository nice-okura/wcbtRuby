#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= タスク生成本体　TaskManager, RequireManager, GroupManager
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.5.0
#License::
#
#== Usage:
#
#=== 
$:.unshift(File.dirname(__FILE__))
# 標準ライブラリ
require "pp"
require "rubygems"  
require "json"      # JSON

# 独自ライブラリ
require "wcbt"      # 最大ブロック時間計算モジュール
require "task"      # タスク等のクラス
require "singleton" # singletonモジュール
require "config"    # コンフィグファイル
require "create-task"
require "create-require"
require "proc-manager"
#require "taskCUI"   # タスク表示ライブラリ


#==ランダム生成方針
# Task(taskId, proc, period, extime, priority, offset, reqList)
#  taskId: タスク生成順にインクリメント
#  proc: 完全ランダム
#  period: extime以下でランダム
#  extime: reqListの総時間以上で乱数
#  priority: 完全ランダム#  offset: period以下でランダム
#  reqList: createReqListで生成
# Group(group, kind)
#  group: 生成順にインクリメント
#  kind: 交互
# Require(req_id, group, time, reqs)
#  req_id: 生成順にインクリメント
#  group: ランダムに選択
#  time: (ある限度までで)ランダムに選択->20~50
#  reqs: groupとは異なるグループのリソースを選択

# グローバル変数の定義
$external_input = false # 外部入力ファイルの設定
#$output_task_file = TASK_FILE_NAME  # タスクの出力先ファイル名
#$output_group_file = GRP_FILE_NAME  # グループの出力先ファイル名
#$output_require_file = REQ_FILE_NAME  # リソース要求の出力先ファイル名

$all_task_list = []     # 全タスクリスト
$task_list = []         # 割り当て済みタスリスト 

#
# タスク，リソース要求，グループのマネージャー管理
# Singleton
#
include WCBT
class AllManager
  attr_reader :tm, :rm, :gm, :pm, :using_group_array

  ###################################################
  #
  # public
  public
  #
  ###################################################

  #
  # 初期化
  #
  def initialize
    #puts "AllManager_initialize"
    @tm = TaskManager.instance
    @rm = RequireManager.instance
    @gm = GroupManager.instance
    @pm = ProcessorManager.instance
  end

  #
  # タスクセットデータの読み込み
  #
  def load_tasks(name)
    if name == "" || name == nil
      puts "ファイル名を指定して下さいよ" 
      return false
    end
    return false if @gm.load_group_data("#{name}_group.json") == false
    return false if @rm.load_require_data("#{name}_require.json") == false
    return false if @tm.load_task_data("#{name}_task.json") == false
    return false if @pm.load_processor_data("#{name}_proc.json") == false
    @using_group_array = get_using_group_array
    $task_list = @tm.get_task_array
    init_computing($task_list)
    set_blocktime

    return true
  end
 
  #
  # タスクセットデータの書き込み
  #
  def save_tasks(name)
    if name == "" || name == nil
      puts "ファイル名を指定して下さいよ" 
      return false
    end
    return false unless @gm.save_group_data("#{name}_group.json")
    return false unless @rm.save_require_data("#{name}_require.json")
    return false unless @tm.save_task_data("#{name}_task.json")
    return false unless @pm.save_processor_data("#{name}_proc.json") == 0
    return true
  end

  #
  # タスクセット生成
  #
  def create_tasks(tcount=TASK_COUNT, rcount=REQ_COUNT, gcount=GRP_COUNT, info={ })
    # リソースグループの作成
    @gm.create_group_array(gcount, info)
    
    # リソース要求の作成
    @rm.create_require_array(rcount, info)
    
    # タスクの作成
    @tm.create_task_array(tcount, info)

    # プロセッサの作成
    @pm.create_processor_list(info)

    # タスクの割り当て
    @pm.assign_tasks(@tm.get_task_array, info)

    # システムで使用するリソースグループ
    @using_group_array = get_using_group_array

    # システムで使用するタスクセット
    $task_list = @tm.get_task_array
    
    # A Flexible.. のスケジューラビリティ解析の場合
    if info[:mode] == SCHE_CHECK
      assign_requires_for_sche_check
    end
    
    # 全タスクの設定しなおし
    $task_list.each{ |t|
      t.resetting
    }
    init_computing($task_list)
    set_blocktime
    
  end 


  # 指定したIDのtask_listのタスクをworst-fitでプロセッサに割り当て
  # @param idx 
  def assign_task_worstfit(id, opt={ })
    tsk = TaskManager.get_task(id)
    
    # longリソース要求をするタスクのあるプロセッサに割当てる場合
    if opt[:long_same_proc] == true
      # longリソース要求をしているタスクかチェック
      unless tsk.long_require_array.size == 0
        # longリソースがある場合，
        # longリソース要求をするタスクのあるプロセッサに割当てる
        @pm.proc_list.each{ |p|
          p.task_list.each{ |t|
            if t.long_require_array.size > 0
              #このプロセッサに割り当て
              p.assign_task(tsk)
            end
          }
        }
      else 
        proc_id = lowest_util_proc_id
        @pm.proc_list[proc_id - 1].assign_task(tsk)
      end
    else
      # 通常時
      proc_id = lowest_util_proc_id
      @pm.proc_list[proc_id - 1].assign_task(tsk)
    end
  end
  
  #
  # 全データ初期化
  #
  def all_data_clear
    $task_list = []
    @gm.data_clear
    @rm.data_clear
    @tm.data_clear
    @pm.data_clear
  end
  
  #
  # システムで使用中のリソースグループの配列を取得
  # rarrayはシステムで使用するリソース要求の配列
  # new_garrayは新しいグループ配列
  #
  def get_using_group_array
    new_garray = []
    
    @tm.get_task_array.each{|t|
      t.all_require.each{|r|
        new_garray << r.res unless new_garray.include?(r.res) 
      }
    }
    
    return new_garray
  end



  
    #
  # 最悪応答時間が最も良くなる時のグループの分類を求める
  # @return [Array<String>]
  #
  def compute_wcrt(loops)
    #pp using_group_array
    #
    # グループ数
    #
    group_count = using_group_array.size
    
    #
    # グループのパターン数
    #
    group_times = 2**group_count
    #p "#{group_times}times"
    
    #
    # グループパターン数を２進数で記録
    #
    group_binary = group_times.to_s(2)
    
    #
    # リソースを全てshortにする
    #
    GroupManager.get_group_array.each{|g|
      g.kind = SHORT
    }
    taskset = TaskSet.new
    
    #
    # システム全体の最悪応答時間
    #
    min_all_wcrt = 10000000 # 適当な最大値
    max_all_wcrt = -1       # 適当な最小値
    
    #
    # システム全体の最悪応答時間が最も良くなる場合を探す
    #
    
    i = 0
    change_count = 0
    long_count = 0
    
    #$DEBUG = true
    ret_hash = get_groups
    group_times.times{
      wcrt_max_system = -1 # 適当な最小値
      
      $task_list.each{|t|
        t.resetting
      }
      init_computing($task_list)
      set_blocktime
      
      $task_list.each{|t|
        wcrt = t.wcrt
        wcrt_max_system = wcrt if wcrt_max_system < wcrt
        #pbar.inc
      }
      
      
      if wcrt_max_system < min_all_wcrt
        min_all_wcrt = wcrt_max_system
        long_count = get_long_groups
        change_count += 1

        #$COLOR_CHAR = false
        if long_count > 0
          #puts "long_count:#{long_count}"
          #puts "最悪応答時間:#{min_all_wcrt}"
          #taskset = TaskSet.new($task_list)
          #taskset.show_taskset
          #taskset.show_blocktime
          #show_groups
          ret_hash = get_groups
          gsp = get_groups.values.collect{ |s| if s == LONG then "L" elsif s === SHORT then "S" end}.join 
          filename = "#{Dir::pwd}/json/same_cs_tasksets/T#{$task_list.size}G#{group_count}_#{gsp}_#{loops}"
          save_tasks(filename)
        end
        #$COLOR_CHAR = true
      end
      #taskset = TaskSet.new($task_list)
      #taskset.show_taskset
      #show_groups
      #puts wcrt_max_system
      i += 1
      istr = ("%010b" % [i])[10-group_count, group_count]
      #p "#{i}:#{istr}"
      change_groups(istr)
    }
    return ret_hash
  end

  ###################################################
  #
  # private
  private
  #
  ###################################################
  
  #
  # グループを変更
  #
  def change_groups(str)
    i = 0
    str.each_byte{|c|
      using_group_array[i].kind = c.chr=="0" ? SHORT : LONG
      i += 1
    }
  end

  #
  # 現在のリソースグループ表示
  #
  def show_groups
    using_group_array.each{|g|
      print "#{g.kind[0].chr} "
    }
  end

  #
  # 現在のリソースグループをハッシュにして返す
  #
  def get_groups
    ret_hash = { }
    using_group_array.each{ |g|
      ret_hash[g.group] = g.kind
    }
    return ret_hash
  end

  #
  # longグループ数を取得
  #
  def get_long_groups
    c = 0
    using_group_array.each{|g|
      #c += 1 if g.kind == LONG
      if g.kind == LONG
        c += 1
        #puts LONG
      end
    }
    return c
  end


    # スケジューラビリティ解析用のリソース要求割り当て
  def assign_requires_for_sche_check
    # ランダムに選ばれた2~4個のタスクにlongリソース要求を割当てる
      tmplist = $task_list.sort_by{ rand } # タスクをランダムに並び替える
      task_count = 2 + rand(3) # 2~4の乱数
      0.upto(task_count-1){ |i|
        @tm.set_long_require(tmplist[i])
        tmplist[i].resetting
      }

      #=begin
      f = info[:f] # nesting_factor
      # ネストした要求を生成して割り当て
      f_one = 2.0*f*(1.0-f) * 10000            # 1つネストする確率
      f_two = f*f * 10000                      # 2つネストする確率
      
      #puts "ネストつくりまーす.f_one#{f_one} f_two#{f_two}"
      id = 100                                 # ネストするリソース要求IDは100番以降とする
      # 全リソース要求に対して
      # 上記の確率でネストさせる
      $task_list.each{ |t|
        t.req_list.each{ |r|
          prob = rand(10001) + 1 # 1~10000の乱数
          #          print "#{prob} "
          reqs = []
          # fの確率でネスト作成
          if prob < f_two
            # 2つのネストしたリソース要求
            if r.res.kind == SHORT
              # shortの場合は |Rn| = R/3
              time = r.time/3
              # shortグループの中からランダムに選択する
              g_id1 = rand(SHORT_GRP_COUNT) + 1  # shortグループのIDは1-30
              g_id2 = rand(SHORT_GRP_COUNT) + 1 
            elsif r.res.kind == LONG
              # longの場合は |Rn| = 3 (from 論文．意味がわからない)
              time = 3.0
              # longグループの中からランダムに選択する
              g_id1 = rand(2) + 1 + 30 # longグループのIDは31-32
              g_id2 = rand(2) + 1 + 30 
            end
            g1 = GroupManager.get_group_from_group_id(g_id1)
            g2 = GroupManager.get_group_from_group_id(g_id2)
            req = []
            id += 1
            req1 = Req.new(id, g1, time, req)
            id += 1
            req2 = Req.new(id, g2, time, req)
            @rm.add_require(req1)
            @rm.add_require(req2)
            reqs << req1
            reqs << req2
          elsif prob < f_one
            # 1つのネストしたリソース要求
            if r.res.kind == SHORT
              # shortの場合は |Rn| = R/3
              time = r.time/3
              # shortグループの中からランダムに選択する
              g_id1 = rand(SHORT_GRP_COUNT) + 1  # shortグループのIDは1-30
            elsif r.res.kind == LONG
              # longの場合は |Rn| = 3 (from 論文．意味がわからない)
              time = 3.0
              # longグループの中からランダムに選択する
              g_id1 = rand(2) + 1 + 30 # longグループのIDは31-32
            end
            g1 = GroupManager.get_group_from_group_id(g_id1)
            req = []
            id += 1
            req1 = Req.new(id, g1, time, req)
            @rm.add_require(req1)
            reqs << req1
          end
          r.reqs = reqs
        }
      }
  end

end

#
# タスクマネージャークラスの定義
#
class TaskManager
  include Singleton
  
  def initialize
    @@task_id = 0
    @@task_array = []
  end

  # shce_check用に，タスクに1~3個のshortリソース要求を割当てる
  def set_short_require(task)
    req_id_list = []
    count = rand(3) + 1 # 1~3の乱数
    count.times{ 
      req_id = rand(90) + 1 # req_id 1~90がshortリソース要求
      req_id_list << req_id
    }
    # リソース要求更新
    task.req_list = RequireManager.get_reqlist_from_req_id(req_id_list)
  end

  public
  # shce_check用に，タスクに1個のlongリソース要求を割当てる
  def set_long_require(task)
    req_id = rand(9) + 91 # req_id 91~98がlongリソース要求
   
    # リソース要求更新
    task.req_list = RequireManager.get_reqlist_from_req_id([req_id])
  end
  
  #
  # タスクの配列生成
  # 生成したタスクの数を返す
  #
  public
  def create_task_array(i, info={ })
    #tarray = []
    #p info
    case info[:mode]
    when "0"
      #
      # 外部ファイルからタスクが読み込まれていなかったらタスクランダム生成
      # そうでなければそのまま
      #
      i.times{
        #tarray << create_task
        @@task_array << create_task
      }
      #
      # rcslを考慮したタスク実行時間を作成．
      # 各CPUに均等にタスクは割り当てられる
      #
    when "120405" 
      # info[1] はrcls
      #puts "120405 MODE"
      if info[:rcsl] == nil
        $stderr.puts "create_task_array:[#{__LINE__}行目]rcslが設定されていません"
      else
        i.times{
          @@task_array << create_task_120405(i, info[:rcsl])
        }
      end
      
      #
      # rcslは不要
      # 指定した実行時間info[1](初期値50)のタスクを生成．
      # 各CPUに均等にタスクは割り当てられる．
      #
    when "120405_3", "120411"
      if info[:extime].to_i == 0
        i.times{
          @@task_array << create_task_120405_3(i)
        }
      else
        i.times{
          @@task_array << create_task_120405_3(i, info[:extime])
        }
      end
    when SCHE_CHECK
      #
      # スケジューラビリティ解析用
      #
      i.times{
        @@task_array << create_task_sche_check(info[:extime])
      }
    when "120620"
      i.times{ 
        @@task_array << create_task_120620(i, info[:extime])
      }
    when "120613"
      i.times{ 
        @@task_array << create_task_120613(i, info[:extime])
      }
    when "120620_2"
      i.times{ 
        @@task_array << create_task_120620_2(i, info[:extime])
      }
    else
      $stderr.puts "create_task_array:infoエラー"
      raise
      exit
    end
    
    #@@task_array = tarray
    return @@task_array.size
  end
  
  #
  # タスクの保存(JSON)
  # 保存したタスクの数を返す．失敗したらfalse
  #
  public
  def save_task_data(filename)
    print_debug("save_task:#{filename}")
    tasks_json = {
      "tasks" => []
    }
    @@task_array.each{|task|
      tasks_json["tasks"] << task.out_alldata
    }
    
    #pp tasks_json
    begin
      #puts "Saving #{tasks_json["tasks"].size} tasks..."
      File.open(filename, "w"){|fp|
        fp.write JSON.pretty_generate(tasks_json)
      }
      return tasks_json["tasks"].size
    rescue => e
      #puts e.class
      #puts e.message
      puts e.backtrace
      puts("resource file output error: #{filename} could not be created.\n")
      return false
    end
  end
  
  #
  # タスクの読み込み(JSON)
  # 読み取ったタスクの配列を返す．失敗したら空の配列を返す
  #
  private
  def load_json_task_data(filename=TASK_FILE_NAME)
    json = ""
    file_type = File::extname(filename)
    case file_type
    when ".json"
      begin
        File.open(File.expand_path(filename), "r") do |file|
          while line = file.gets
            json += line
          end
        end
      rescue
        puts "application file read error: #{filename} is not exist.\n"
        return []
      end

      data_clear
      tasks = (JSON.parser.new(json)).parse()
      puts "Loding #{tasks["tasks"].size} tasks..."
      return tasks
    else
      puts "application file read error: #{filename} is not JSON file.\n"
      return []
    end
  end
  
  #
  # JSONファイルから読み取って作成した(load_task_json_data)ハッシュから
  # タスククラスを作成
  # 読み取ったタスクの数を返す．失敗したらfalseを返す
  #
  public
  def load_task_data(filename=TASK_FILE_NAME)
    print_debug("load_task:#{filename}")
    tasks = load_json_task_data(filename)      # ハッシュの作成
    return false if tasks == []
    #
    # タスク毎の処理
    # @@task_arrayに読み込んだタスクを追加
    #
    tasks["tasks"].each{|tsk|
      #p "req_id_list:#{tsk["req_id_list"]}"
      reqarray = RequireManager.get_reqlist_from_req_id(tsk["req_id_list"])
      
      t = Task.new(
                   tsk["task_id"], 
                   tsk["proc"], 
                   tsk["period"], 
                   tsk["extime"], 
                   tsk["priority"], 
                   tsk["offset"], 
                   reqarray
                   )
      @@task_array << t
    }
    return @@task_array.size
  end
  
  #
  # 全タスクで使われているリソース要求の配列を返す
  #
  public
  def self.get_all_require
    req_array = []
    @@task_array.each{|tsk|
      req_array += tsk.all_require
    }
    return req_array
  end
  
  #
  # 内部データのクリア
  #
  public
  def data_clear
    @@task_id = 0
    @@task_array = []
  end
  
  #
  # task_arrayを返す
  #
  public
  def get_task_array
    return @@task_array
  end
  
  # 指定したタスクIDのタスクを返す
  def self.get_task(id)
    id = id.to_i
    @@task_array.each{ |t|
      return t if t.task_id == id
    }
    return nil
  end
  
  # 指定したタスクIDリストのタスクのリストを返す
  # @param task_id_list [Array<Fixnum>] タスクIDリスト
  # @return task_list [Array<Task>] タスクリスト
  def self.get_tasks(task_id_list)
    task_list = []
    task_id_list.each{ |id|
      task_list << self.get_task(id)
    }
    return task_list
  end


  # task_listの中から，最大周期を取得
  def get_max_period
    period = -1
    @@task_array.each{ |t|
      period = t.period if period < t.period
    }

    return period
  end
end

#########################################################################
#########################################################################


#
# リソース要求マネージャーの定義
#
class RequireManager
  include Singleton
    
  def initialize
    @@id = 0
    @@require_array = []
  end 
 
  #
  # ランダムにリソース要求を返す
  # 作成されている要求がなければ，nilを返す
  #
  def self.get_random_req
    @@id += 1
    ra = []
    if @@require_array.size < 1
      ra = nil
    else
      #p @@require_array.size
      RUBY_VERSION == "1.9.3" ? ra = @@require_array.sample.clone : ra = @@require_array.choice.clone
      
      #pp ra
      ra.req_id = @@id
      ra.reqs.each{|r|
        @@id += 1
        r.req_id = @@id
      }
    end
    return ra
  end
  
  #
  # リソース要求IDからリソースのオブジェクト参照の配列を返す
  #
  def self.get_reqlist_from_req_id(req_list)
    reqs = []
    req_list.each{|req_id|
      @@require_array.each{|r|
        if r.req_id == req_id
          reqs << r
          break
        end
      }
    }
    return reqs
  end


  public
  def add_require(req)
    return @@require_array << req
  end
  
  #
  # リソース要求の保存(JSON)
  #
  public
  def save_require_data(filename)
    print_debug("save_require:#{filename}")
    reqs_json = {
      "reqs" => []
    }
    TaskManager.get_all_require.each{|req|
      reqs_json["reqs"] << req.out_alldata
    }
    begin
      File.open(filename, "w"){|fp|
        fp.write JSON.pretty_generate(reqs_json)
      }
      rescue => e
      puts e.backtrace
      puts("resource file output error: #{filename} could not be created.\n")
    end
  end
  
  #
  # リソース要求の読み込み(JSON)
  # 読み込んだリソース要求の数を返す．失敗したらfalseを返す．
  #
  public
  def load_require_data(filename=REQ_FILE_NAME)
    print_debug("load_require:#{filename}")
    json = ""
    file_type = File::extname(filename)
    case file_type
    when ".json"
      begin
        File.open(File.expand_path(filename), "r") { |file|
          while line = file.gets
            json += line
          end
        }
      rescue
        puts "application file read error: #{filename} is not exist.\n"
        return false
      end
      
      data_clear
      reqs = (JSON.parser.new(json)).parse()
      
      #
      # リソース要求毎の処理
      # @@require_arrayに読み込んだタスクを追加
      # 1回目
      #
      temp_array = []
      reqs["reqs"].each{|req|
        b = req["begintime"]
        g = GroupManager.get_group_from_group_id(req["group"])
        #rs = RequireManager.get_reqlist_from_req_id(req["req_id_list"])
        r = Req.new(
                    req["req_id"], 
                    g, 
                    req["time"], 
                    [], # まずは[]でよい，2回目のループで設定
                    req["begintime"],
                    req["outermost"]
                    )
        @@require_array << r
      }
      #
      # 2回目
      # ネストしたリソース要求の読み込み
      #
      reqs["reqs"].each{|req|
        b = req["begintime"]
        g = GroupManager.get_group_from_group_id(req["group"])
        rs = RequireManager.get_reqlist_from_req_id(req["req_id_list"])
        r = Req.new(
                    req["req_id"], 
                    g, 
                    req["time"], 
                    rs,
                    req["begintime"],
                    req["outermost"]
                    )
        temp_array << r
      }
      @@require_array = temp_array
    else
      puts "application file read error: #{filename} is not JSON file.\n"
      return false
    end
    
    return @@require_array.size
  end
  
  #
  # require_arrayを返す
  # 
  public 
  def self.get_require_array
    return @@require_array
  end
  
  #
  # reuqireIDからリソース要求を得る
  #
  def self.get_require_from_id(id)
    req = @@require_array.select{ |r| r.req_id == id}
    return req[0] unless req == []
    return nil
  end
  #
  # 内部データのクリア
  #
  public
  def data_clear
    @@id = 0
    @@require_array = []
    return true
  end
end

#########################################################################
#########################################################################

#
# グループマネージャークラスの定義
#
class GroupManager
  include Singleton
  
  def initialize
    @@group_id = 0
    @@kind = LONG
    @@group_array = []
  end
  
  #
  # グループを生成する
  #
  private
  def create_group
    @@group_id += 1
    group = Group.new(@@group_id, @@kind)
    #@@kind = SHORT
    @@kind = @@kind == LONG ? SHORT : LONG
    
    return group
  end
  
  # 120620_2用
  # はじめに生成されるグループのみLONG
  def create_group_120620_2
    @@group_id += 1
    group = Group.new(@@group_id, @@kind)
    @@kind = SHORT
    return group
  end

  
  #
  # i個のグループを生成し，group_arrayとする
  #
  public
  def create_group_array(i, info={ })
    data_clear
    garray = []

    case info[:mode]
    when SCHE_CHECK
      #
      # スケジューラビリティ解析用
      #
      i = SHORT_GRP_COUNT
      @@kind = SHORT
      # Shortリソースを6*TASK_NUM/PROC_NUM個作る
      i.times{ 
        @@group_id += 1
        garray << Group.new(@@group_id, @@kind)
      }
      # Longリソースを2個作る
      @@group_id += 1
      @@kind = LONG
      garray << Group.new(@@group_id, @@kind)
      @@group_id += 1
      garray << Group.new(@@group_id, @@kind)
      

      @@group_array = garray
      #pp @@group_array
    when "120620_2"
      i.times{ 
        @@group_array << create_group_120620_2
      }
    else
      i.times{
        garray << create_group
      }
      @@group_array = garray
    end
    return @@group_array.size
  end
  
  private
  def get_count
    return @@group_id
  end
    
  #
  # グループの保存(JSON)
  #
  public
  def save_group_data(filename)
    print_debug("save_group:#{filename}")
    grps_json = {
      "grps" => []
    }
    @@group_array.each{|grp|
      grps_json["grps"] << grp.out_alldata
    }
    begin
      File.open(filename, "w"){|fp|
        fp.write JSON.pretty_generate(grps_json)
      }
      rescue => e
      puts e.backtrace
      puts("resource file output error: #{filename} could not be created.\n")
      return false
    end
    return true
  end
  
  #
  # グループの読み込み(JSON)
  # 読み込んだグループ数を返す．失敗したらfalse
  public
  def load_group_data(filename=GRP_FILE_NAME)
    print_debug("load_group:#{filename}")
    json = ""
    file_type = File::extname(filename)
    case file_type
    when ".json"
      begin
        File.open(File.expand_path(filename), "r") { |file|
          while line = file.gets
            json += line
          end
        }
      rescue
        puts "application file read error: #{filename} is not exist.\n"
        return false
      end
      
      data_clear  # 元のデータを削除し，新しいデータを格納
      grps = (JSON.parser.new(json)).parse()
      
      #
      # グループ毎の処理
      # @@grpArrayに読み込んだタスクを追加
      #
      grps["grps"].each{|grp|
        if grp["group"] > 0 && (grp["kind"]==LONG||grp["kind"]==SHORT)
          g = Group.new(
                        grp["group"], 
                        grp["kind"]
                        )
          @@group_array << g
        end
      }
    else
      # 
      # JSONファイルでない場合
      #
      puts "application file read error: #{filename} is not JSON file.\n"
      return false
    end
    
    return @@group_array.size
  end
  
  #
  # group_idからグループのオブジェクトの参照を返す
  #
  public
  def self.get_group_from_group_id(group_id)
    @@group_array.each{|g|
      if g.group == group_id
        return g
      end
    }
  end
  
  #
  # group_arrayを返す
  #
  public
  def self.get_group_array
    return @@group_array
  end
  
  #
  # グループをランダムに返す
  #
  def self.get_random_group
    if @@group_array.size == 0
      puts "グループが生成されていません．"
      return nil
    end
    return RUBY_VERSION == "1.9.3" ? @@group_array.sample : @@group_array.choice
  end
  
  #
  # 内部データのクリア
  #
  public
  def data_clear
    @@group_id = 0
    @@group_array = []
    return true
  end
end

#########################################################################
#########################################################################




###############################################################

def print_debug(str)
  puts str if $DEBUGFlgFlg
end
