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
#$:.unshift(File.dirname(__FILE__))
# 標準ライブラリ
require "pp"
require "rubygems"  

# 独自ライブラリ
#require "./120601_sche_ana/wcbt-edf"      # 最大ブロック時間計算モジュール
require "./wcbt"      # 最大ブロック時間計算モジュール
#require "./120601_sche_ana/task"      # タスク等のクラス
require "./task"      # タスク等のクラス
require "singleton" # singletonモジュール
require "./create-task"
require "./create-require"
require "./proc-manager"
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


  # 初期化
  # @param [String] taskset_name 読み込みたいタスクセット名
  def initialize(taskset_name="")
    #puts "AllManager_initialize"
    @tm = TaskManager.instance
    @rm = RequireManager.instance
    @gm = GroupManager.instance
    @pm = ProcessorManager.instance
    load_tasks(taskset_name) unless taskset_name == ""
  end


  # タスクセットデータの読み込み
  # @param [String] name タスクセット名(ディレクトリ名)
  # @param [Hash] info タスクセット条件
  def load_tasks(name, info={})
    if name == "" || name == nil
      puts "ディレクトリ名を指定して下さいよ" 
      return false
    end
    
    # hoge/piyo/以下に
    #   piyo_task.json
    #   ...
    #を作成する場合
    # name = hoge/piyo/
    # dir_name = hoge/piyo
    # taskset_name = piyo とする

    # name はfrozenなのでdir_nameとして複製
    dir_name = name.dup

    # 末尾が"/"なら"/"を取る
    dir_name.sub!(/\/$/, "")
    
    # タスクセット名
    taskset_name = File::basename(dir_name)

    return false if @gm.load_group_data("#{dir_name}/#{taskset_name}_group.json") == false
    return false if @rm.load_require_data("#{dir_name}/#{taskset_name}_require.json") == false
    return false if @tm.load_task_data("#{dir_name}/#{taskset_name}_task.json") == false
    return false if @pm.load_processor_data("#{dir_name}/#{taskset_name}_proc.json") == false
    @using_group_array = get_using_groups
    $task_list = []
    ProcessorManager.proc_list.each do |proc|
      proc.task_list.each do |task|
        $task_list << task
      end
    end

    # 最大ブロック時間を計算させない
    unless info[:not_compute] == true
      init_computing($task_list)
      set_blocktime
    end

    return true
  end
 

  # タスクセットデータの書き込み
  # @param [String] name タスクセット名(ディレクトリ名)
  def save_tasks(name)
    if name == "" || name == nil
      puts "ディレクトリを指定して下さいよ" 
      return false
    end

    # hoge/piyo/以下に
    #   piyo_task.json
    #   ...
    #を作成する場合
    # name = hoge/piyo/
    # dir_name = hoge/piyo
    # taskset_name = piyo とする

    # name はfrozenなのでdir_nameとして複製
    dir_name = name.dup

    # 末尾が"/"なら"/"を取る
    dir_name.sub!(/\/$/, "")
    
    # タスクセット名
    taskset_name = File::basename(dir_name)

    # ディレクトリ作成
    Dir::mkdir(dir_name) unless File::exists?(dir_name)

    # 各ファイルの保存
    return false unless @gm.save_group_data("#{dir_name}/#{taskset_name}_group.json")
    return false unless @rm.save_require_data("#{dir_name}/#{taskset_name}_require.json")
    return false unless @tm.save_task_data("#{dir_name}/#{taskset_name}_task.json")
    return false unless @pm.save_processor_data("#{dir_name}/#{taskset_name}_proc.json") == 0
    return true
  end
  
  # スケジューラビリティ用タスクセット生成
  # プロセッサに割り当てはしない
  public
  def create_taskset(task_count, info={})
    # リソースグループの作成
    @gm.create_group_array(gcount, info)
    
    # リソース要求の作成
    @rm.create_require_array(rcount, info)
    
    # タスクの作成
    @tm.create_task_array(tcount, info)
    
    # プロセッサの作成
    @pm.create_processor_list(info)
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

    unless info[:mode] == SCHE_CHECK || info[:mode] == MY_SCHE_CHECK
      # タスクの割り当て
      @pm.assign_tasks(@tm.get_task_array, info) 
    end

    # システムで使用するリソースグループ
    @using_group_array = get_using_groups

    # システムで使用するタスクセット
    $task_list = []
    ProcessorManager.proc_list.each do |proc|
      proc.task_list.each do |task|
        $task_list << task
      end
    end
    
    # A Flexible.. のスケジューラビリティ解析の場合
    if info[:mode] == SCHE_CHECK
      #@pm.init_all_proc # プロセッサ初期化
      assign_requires_for_sche_check(info)
    end
    
    # 全タスクの設定しなおし
    $task_list.each do |t|
      t.resetting
    end
    
    # 最大ブロック時間を計算させない
    unless info[:mode] == SCHE_CHECK || info[:mode] == MY_SCHE_CHECK || info[:not_compute] == true
      init_computing($task_list)
      set_blocktime
    end
  end 


  # 指定したIDのtask_listのタスクをworst-fitでプロセッサに割り当て
  # @param idx 
  def assign_task_worstfit(idx, opt={ })
    tsk = TaskManager.get_task_by_index(idx)
    
    # longリソース要求をするタスクのあるプロセッサに割当てる場合
    if opt[:long_same_proc] == true
      # longリソース要求をしているタスクかチェック
      unless tsk.long_require_array.size == 0
        # longリソースがある場合，
        # longリソース要求をするタスクのあるプロセッサに割当てる
        ProcessorManager.proc_list.each do |p|
          p.task_list.each do |t|
            if t.long_require_array.size > 0
              #このプロセッサに割り当て
              p.assign_task(tsk)
            end
          end
        end
      else 
        proc_id = lowest_util_proc_id
        ProcessorManager.proc_list[proc_id - 1].assign_task(tsk)
      end
    else
      # 通常時
      proc_id = lowest_util_proc_id
      ProcessorManager.proc_list[proc_id - 1].assign_task(tsk)
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
  

  # システムで使用中のリソースグループの配列を取得
  # @return [Array<Group>] システムで使用中のリソースグループの配列
  def get_using_groups(kind=nil)
    new_garray = []
    
    case kind
    when nil
      # 使用中の全リソースを返す
      @tm.get_task_array.each do |t|
        t.all_require.each do |r|
          new_garray << r.res unless new_garray.include?(r.res) 
        end
      end
    when LONG
      # 使用中のlongリソースを返す
      @tm.get_task_array.each do |t|
        t.all_require.each do |r|
          if r.res.kind == LONG
            new_garray << r.res unless new_garray.include?(r.res)
          end
        end
      end
    when SHORT
      @tm.get_task_array.each do |t|
        t.all_require.each do |r|
          if r.res.kind == SHORT
            new_garray << r.res unless new_garray.include?(r.res)
          end
        end
      end
      # 使用中のshortリソースを返す
    end
    
    return new_garray
  end
  
  # 最悪応答時間が最も良くなる時のグループの分類を求める
  # @return [Array<String>]
  def compute_wcrt(loops)
    #pp using_group_array
    
    # グループ数
    group_count = using_group_array.size
    
    # グループのパターン数
    group_times = 2**group_count
    #p "#{group_times}times"
    
    # グループパターン数を２進数で記録
    group_binary = group_times.to_s(2)
    
    # リソースを全てshortにする
    GroupManager.get_group_array.each do |g|
      g.kind = SHORT
    end
    taskset = TaskSet.new
    
    # システム全体の最悪応答時間
    min_all_wcrt = 10000000 # 適当な最大値
    max_all_wcrt = -1       # 適当な最小値
    
    # システム全体の最悪応答時間が最も良くなる場合を探す
    i = 0
    change_count = 0
    long_count = 0
    
    #$DEBUG = true
    ret_hash = get_groups
    group_times.times do
      wcrt_max_system = -1 # 適当な最小値
      
      $task_list.each do |t|
        t.resetting
      end
      init_computing($task_list)
      set_blocktime
      
      $task_list.each do |t|
        wcrt = t.wcrt
        wcrt_max_system = wcrt if wcrt_max_system < wcrt
        #pbar.inc
      end      
      
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
          gsp = get_groups.values.collect{ |s| if s == LONG then "L" elsif s == SHORT then "S" end}.join 
          filename = "./120927/json_analysis_for_long/T#{$task_list.size}G#{group_count}_#{gsp}_#{loops}"
          save_tasks(filename)
        end
        #$COLOR_CHAR = true
      end
      #taskset = TaskSet.new
      #taskset.show_taskset
      #show_groups
      #puts wcrt_max_system
      i += 1
      istr = ("%010b" % [i])[10-group_count, group_count]
      #p "#{i}:#{istr}"
      change_groups(istr)
    end
    return ret_hash
  end

  # スケジューラビリティが最も良くなる場合のグループの分類を求める
  # @return [Array<String>]
  def compute_wcrt(loops)
    # グループ数
    group_count = using_group_array.size
    
    # グループのパターン数
    group_times = 2**group_count
    #p "#{group_times}times"
    
    # グループパターン数を２進数で記録
    group_binary = group_times.to_s(2)
    
    # リソースを全てshortにする
    GroupManager.get_group_array.each do |g|
      g.kind = SHORT
    end
    taskset = TaskSet.new
    
    # システム全体の最悪応答時間
    min_all_wcrt = 10000000 # 適当な最大値
    max_all_wcrt = -1       # 適当な最小値
    
    # システム全体の最悪応答時間が最も良くなる場合を探す
    i = 0
    change_count = 0
    long_count = 0
    
    #$DEBUG = true
    ret_hash = get_groups
    group_times.times do
      wcrt_max_system = -1 # 適当な最小値
      
      $task_list.each do |t|
        t.resetting
      end
      init_computing($task_list)
      set_blocktime
      
      $task_list.each do |t|
        wcrt = t.wcrt
        wcrt_max_system = wcrt if wcrt_max_system < wcrt
        #pbar.inc
      end      
      
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
          gsp = get_groups.values.collect{ |s| if s == LONG then "L" elsif s == SHORT then "S" end}.join 
          filename = "./120927/json_analysis_for_long/T#{$task_list.size}G#{group_count}_#{gsp}_#{loops}"
          save_tasks(filename)
        end
        #$COLOR_CHAR = true
      end
      #taskset = TaskSet.new
      #taskset.show_taskset
      #show_groups
      #puts wcrt_max_system
      i += 1
      istr = ("%010b" % [i])[10-group_count, group_count]
      #p "#{i}:#{istr}"
      change_groups(istr)
    end
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
  def assign_requires_for_sche_check(info)
    # ランダムに選ばれた2~4個のタスクにlongリソース要求を割当てる
    tmplist = $task_list.sort_by{ rand } # タスクをランダムに並び替える
    task_count = 2 + rand(3) # 2~4の乱数
    0.upto(task_count-1){ |i|
      break if tmplist.size <= i
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
            group_a = (1..SHORT_GRP_COUNT).to_a
            group_a.delete(r.res.group)
            g_id1 = group_a.sample  # shortグループのIDは1-30
            g_id2 = group_a.sample
          elsif r.res.kind == LONG
            # longの場合は |Rn| = 3 (from 論文．意味がわからない)
            time = 3.0
            # longグループの中からランダムに選択する
            g_id1 = r.res.group==31 ? 32 : 31 # longグループのIDは31-32
            g_id2 = r.res.group==31 ? 32 : 31
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
            group_a = (1..SHORT_GRP_COUNT).to_a
            group_a.delete(r.res.group)
            g_id1 = group_a.sample  # shortグループのIDは1-30
          elsif r.res.kind == LONG
            # longの場合は |Rn| = 3 (from 論文．意味がわからない)
            time = 3.0
            # longグループの中からランダムに選択する
            g_id1 = r.res.group==31 ? 32 : 31 # longグループのIDは31-32
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


  # 既存のタスクからマネージャーを作成
  def set_tasks(tasks)
    TaskManager.task_array = tasks
    tasks.each{ |task|
      @rm.req
      task.req_list.each{ |req|
      
      }
    }
  end

end

#
# タスクマネージャークラスの定義
#
class TaskManager
  include Singleton
  
  attr_reader :task_array
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
  
  
  # 周期の短い順に優先度を割り当てる
  # @param: <Array> タスクセット
  private 
  def assign_priority_by_period(tasks)
    tasks.sort!{ |a, b| a.period <=> b.period }
    tasks.each_with_index do |task, i| 
      task.set_priority(i)
    end
    
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
    ProcessorManager.proc_list.each do |proc|
      proc.task_list.each do |task|
        tasks_json["tasks"] << task.out_alldata
      end
    end
    
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
      print_debug "Loding #{tasks["tasks"].size} tasks..."
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

  #
  # @@task_arrayのソートを行う
  #
  # タスク使用率の降順にソート
  def sort_tasklist_by_util
    @@task_array.sort do |a, b|
      -1 * (a.get_extime/a.period <=> b.get_extime/b.period)
    end
  end

  # 総タスク使用率を求める
  def get_alltask_util
    util = 0.0
    @@task_array.each do |t|
      util += t.get_extime/t.period
    end
    
    return util
  end
  
  # 指定したタスクIDのタスクを返す
  def self.get_task(id)
    id = id.to_i
    @@task_array.each do |t|
      return t if t.task_id == id
    end
    return nil
  end
  
  # 指定したインデックスのタスクを返す
  # (@@task_array配列のインデックス)
  def self.get_task_by_index(idx)
    return @@task_array[idx]
  end
  
  # 指定したタスクIDリストのタスクのリストを返す
  # @param task_id_list [Array<Fixnum>] タスクIDリスト
  # @return task_list タスクリスト
  def self.get_tasks(task_id_list)
    task_list = []
    task_id_list.each do |id|
      task_list << get_task(id)
    end
    return task_list
  end


  # task_listの中から，最大周期を取得
  def get_max_period
    period = -1
    @@task_array.each do |t|
      period = t.period if period < t.period
    end

    return period
  end

  # デッドラインミスaしているかチェックする
  # @return [bool] true:デッドラインミスしている false:デッドラインミスしていない
  def deadline_miss?
    @@task_array.each do |tsk|
      return true if tsk.wcrt > tsk.period
    end

    return false
  end

  # デッドラインミスしているタスクの配列を返す
  # @return [Array<Task>] デッドラインミスしているタスクの配列
  def get_deadline_miss_tasks
    tasks = []
    @@task_array.each do |tsk|
      tasks << tsk if tsk.wcrt > tsk.period
    end

    return tasks
  end


end

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
 
  # @return ランダムにリソース要求を返す
  #         作成されている要求がなければ，nilを返す
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
      ra.reqs.each do |r|
        @@id += 1
        r.req_id = @@id
      end
    end
    return ra
  end
  

  # リソース要求IDからリソースのオブジェクト参照の配列を返す
  # @param [Array<Fixnum>] req_list リソースIDの配列
  # @return [Array<Req>] リソース要求の配列
  def self.get_reqlist_from_req_id(req_list)
    reqs = []
    req_list.each do |req_id|
      @@require_array.each do |r|
        if r.req_id == req_id
          reqs << r
          break
        end
      end
    end
    
    return reqs
  end

    # グループIDからリソース要求の配列を返す
  # @param [Array<Fixnum>] group_ids グループIDの配列
  # @return [Array<Req>] リソース要求の配列
  def self.get_reqs_from_group_id(group_ids)
    reqs = []
    group_ids.each do |g_id|
      @@require_array.each do |r|
        if r.res.group == g_id
          reqs << r
          break
        end
      end
    end
    
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
  
  def self.set_require_array(reqs)
    @@require_array = reqs
  end


  # reuqireIDからリソース要求を得る
  # @param [Fixnum] id リソース要求ID
  # @return [Req] リソース要求
  def self.get_require_from_id(id)
    req = @@require_array.select{ |r| r.req_id == id}
    return req[0] unless req == []
    return nil
  end
  

  # 内部データのクリア
  public
  def data_clear
    @@id = 0
    @@require_array = []
    return true
  end
end

#########################################################################
#
# グループマネージャークラスの定義
#

# GroupManager
class GroupManager
  include Singleton
  
  def initialize
    @@group_id = 0
    @@kind = LONG
    @@group_array = []
  end
  
  # グループを生成する
  # @param [Hash] info グループ作成条件
  private
  def create_group(info)
    @@group_id += 1

    if info[:short_only]
      @@kind = SHORT
    else
      @@kind = @@kind == LONG ? SHORT : LONG
    end
    group = Group.new(@@group_id, @@kind)
    
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

  

  # count個のグループを生成し，group_arrayとする
  # @param [Fixnum] count グループ生成個数
  # @param [Hash] info グループ生成条件
  # @return [Fixnum] 作成したグループの個数
  public
  def create_group_array(count, info={ })
    data_clear
    garray = []

    case info[:mode]
    when SCHE_CHECK, MY_SCHE_CHECK
      #
      # スケジューラビリティ解析用
      #
      count = SHORT_GRP_COUNT
      @@kind = SHORT
      # Shortリソースを6*TASK_NUM/PROC_NUM個作る
      count.times{ 
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
      count.times{ 
        @@group_array << create_group_120620_2
      }
    else
      count.times{
        garray << create_group(info)
      }
      @@group_array = garray
    end
    return @@group_array.size
  end
  
  private
  def get_count
    return @@group_id
  end
    

  # グループの保存(JSON)
  # @param [String] filename グループファイル名
  public
  def save_group_data(filename)
    print_debug("save_group:#{filename}")
    grps_json = {
      "grps" => []
    }
    @@group_array.each { |grp| grps_json["grps"] << grp.out_alldata }
    begin
      File.open(filename, "w") { |fp| fp.write JSON.pretty_generate(grps_json) }
    rescue => e
      puts e.backtrace
      STDERR.puts "group file output error: #{filename} could not be created.\n"
      return false
    end
    return true
  end
  

  # グループの読み込み(JSON)
  # @param [String] filename ファイル名
  # @return [Fixnum] 読み込んだグループ数
  # 読み込んだグループ数を返す．失敗したらfalse
  public
  def load_group_data(filename)
    print_debug("load_group:#{filename}")
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
        STDERR.puts "group file read error: #{filename} is not exist.\n"
        return false
      end
      
      data_clear  # 元のデータを削除し，新しいデータを格納
      grps = (JSON.parser.new(json)).parse()
      

      # グループ毎の処理
      # @@grpArrayに読み込んだタスクを追加
      grps["grps"].each do |grp|
        if grp["group"] > 0 && (grp["kind"]==LONG||grp["kind"]==SHORT)
          g = Group.new(
                        grp["group"], 
                        grp["kind"]
                        )
          @@group_array << g
        end
      end
    else
      # JSONファイルでない場合
      puts "application file read error: #{filename} is not JSON file.\n"
      return false
    end
    
    return @@group_array.size
  end
  
  # group_idからグループのオブジェクトの参照を返す
  # @param [Fixnum] group_id グループID
  public
  def self.get_group_from_group_id(group_id)
    @@group_array.each do |g|
      return g if g.group == group_id
    end
  end
  
  # group_arrayを返す
  # @return [Array<Group>] グループの配列(group_array)
  public
  def self.get_group_array
    return @@group_array
  end
  
  # グループをランダムに返す
  # @return [Group] ランダムなリソースグループ
  def self.get_random_group
    if @@group_array.size == 0
      puts "グループが生成されていません．"
      return nil
    end
    return RUBY_VERSION == "1.9.3" ? @@group_array.sample : @@group_array.choice
  end

  # shortリソースグループをランダムに返す
  # @return [Group] ランダムなshortリソースグループ
  def self.get_random_short_group
    short_array = []
    @@group_array.each do |grp|
      short_array << grp if grp.kind == SHORT
    end
    
    if short_array.size == 0
      puts "shortグループが生成されていません．"
      return nil
    end
        
    return RUBY_VERSION == "1.9.3" ? short_array.sample : short_array.choice
  end

  # longリソースグループをランダムに返す
  # @return [Group] ランダムなlongリソースグループ
  def self.get_random_long_group
    long_array = []
    @@group_array.each do |grp|
      long_array << grp if grp.kind == LONG
    end
    
    if long_array.size == 0
      puts "longグループが生成されていません．"
      return nil
    end
        
    return RUBY_VERSION == "1.9.3" ? long_array.sample : long_array.choice
  end
  
  # 作成したグループのIDの配列を返す
  # 使用しているグループIDの配列とは限らない
  # @return [Array<Fixnum>] グループのIDの配列
  def self.get_group_id_list
    return @@group_array.inject([]){ |groups, g| groups << g.group }
  end
  
  # 内部データのクリア
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
