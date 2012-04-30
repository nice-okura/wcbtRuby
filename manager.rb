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

# 標準ライブラリ
require "pp"
require "rubygems"  
require "json"      # JSON

# 独自ライブラリ
require "wcbt"      # 最大ブロック時間計算モジュール
require "task"      # タスク等のクラス
require "singleton" # singletonモジュール
require "config"    # コンフィグファイル
#require "taskCUI"   # タスク表示ライブラリ


#==ランダム生成方針
# Task(taskId, proc, period, extime, priority, offset, reqList)
#  taskId: タスク生成順にインクリメント
#  proc: 完全ランダム
#  period: extime以下でランダム
#  extime: reqListの総時間以上で乱数
#  priority: 完全ランダム
#  offset: period以下でランダム
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

$task_list = [] # タスクの配列

#
# タスク，リソース要求，グループのマネージャー管理
# Singleton
#
include WCBT
class AllManager
  attr_reader :tm, :rm, :gm, :using_group_array
  
  #
  # 初期化
  #
  def initialize
    #puts "AllManager_initialize"
    @tm = TaskManager.instance
    @rm = RequireManager.instance
    @gm = GroupManager.instance
    
  end

  
  #
  # 各要素の読み込み
  # load_tasks(tname=TASK_FILE_NAME, rname=REQ_FILE_NAME, gname=GRP_FILE_NAME)
  #
  def load_tasks(name)
    if name == "" || name == nil
      puts "ファイル名を指定して下さいよ" 
      return false
    end
    return false unless @gm.load_group_data("#{name}_group.json")
    return false unless @rm.load_require_data("#{name}_require.json")
    return false unless @tm.load_task_data("#{name}_task.json")
    @using_group_array = get_using_group_array
    $taskList = @tm.get_task_array
    init_computing
    set_blocktime
    
    return true
  end
 
  #
  # 各要素の書き込み
  # ファイル名は必須
  #
  def save_tasks(name)
    if name == "" || name == nil
      puts "ファイル名を指定して下さいよ" 
      return false
    end
    return false unless @gm.save_group_data("#{name}_group.json")
    return false unless @rm.save_require_data("#{name}_require.json")
    return false unless @tm.save_task_data("#{name}_task.json")
    return true
  end
  
  #
  # タスク生成
  #
  def create_tasks(tcount=TASK_COUNT, rcount=REQ_COUNT, gcount=GRP_COUNT, info=["0"])
    @gm.create_group_array(gcount)
    
    @rm.set_garray(@gm.get_group_array)
    @rm.create_require_array(rcount, info)
    
    @tm.set_array(@rm.get_require_array, @gm.get_group_array)
    @tm.create_task_array(tcount, info)
    
    @using_group_array = get_using_group_array
    
    $taskList = @tm.get_task_array
    init_computing
    set_blocktime
    
  end
    
  #
  # 全データ初期化
  #
  def all_data_clear
    $taskList = []
    @gm.data_clear
    @rm.data_clear
    @tm.data_clear
  end
  
  #
  # システムで使用中のリソースグループの配列を取得
  # rarrayはシステムで使用するリソース要求の配列
  # new_garrayは新しいグループ配列
  #
  def get_using_group_array
    new_garray = []
    
    @rm.get_require_array.each{|r|
      unless new_garray.include?(r.res) 
        new_garray << r.res
      end
    }
    
    return new_garray
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

  #
  # require_arrayとgroup_arrayをセットする
  #
  def set_array(rarray, garray)
    @@rarray = rarray
    @@garray = garray
    return true
  end
  
  #
  # ランダムタスク生成
  # rcsl:実行時間に対するリソース要求時間の比
  #
  private
  def create_task_120405(task_count, rcsl)
    #################
    # タスクステータス #
    #################
    
    #
    # 120405用
    #
    @@task_id += 1  # ここではタスクのidとしては用いない．task_id_arrayからnew_task_idを用いる

    task_id_array = Array.new(task_count){|index| "#{index+1}"}
    #p @@task_array
    @@task_array.each{|t|
      task_id_array.delete(t.task_id)
    }
    #puts "@@task_id:#{@@task_id}:#{task_id_array}"
    # リソース要求
    # 最大REQ_NUM回リソースを取得
    req_list = []

    unless rcsl == 0.0
      gcount = @@garray.size
      gnum = @@task_id%gcount + 1  # 使用するグループのID
      new_garray = []
      #p "task_id:#{@@task_id} gcount:#{gcount} gnum:#{gnum}"
      @@rarray.each{|r|
        if r.res.group == gnum
          new_garray << r
        end
      }
      REQ_NUM.times{ 
        loop do
          RUBY_VERSION == "1.9.3" ? r = new_garray.sample : r = new_garray.choice
          #p "gnum:#{gnum}"
          #p r.res.group
          if r.res.group == gnum
            req_list << r
            break
          end
        end
      }
      
      #reqList.uniq!
      
      
      req_time = 0
      #pp req_list
      req_list.each{|req|
        req_time += req.time
      }
    end
    RUBY_VERSION == "1.9.3" ? new_task_id = task_id_array.sample : new_task_id = task_id_array.choice 
    
    proc = (new_task_id.to_i%PROC_NUM)+1
    #p task_id_array
    priority = new_task_id
    extime = rcsl == 0.0 ? 10 : req_time/rcsl
    period = extime/((1.0/(task_count/PROC_NUM).to_f)/4.0)
    offset = 0 #rand(10)
    
    #################
    
    task = Task.new(new_task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end
  
  #
  # ランダムタスク生成
  # 
  #
  private
  def create_task_120405_3(task_count, a_extime=50)
    #################
    # タスクステータス #
    #################
    #
    # 120405_3用
    #
    @@task_id += 1  # ここではタスクのidとしては用いない．task_id_arrayからnew_task_idを用いる
    
    task_id_array = Array.new(task_count){|index| "#{index+1}"}
    #p @@task_array
    @@task_array.each{|t|
      task_id_array.delete(t.task_id)
    }
    #puts "@@task_id:#{@@task_id}:#{task_id_array}"
    # リソース要求
    # 最大REQ_NUM回リソースを取得
    req_list = []
    
    gcount = @@garray.size
    gnum = @@task_id%gcount + 1  # 使用するグループのID
    new_garray = []
    #p "task_id:#{@@task_id} gcount:#{gcount} gnum:#{gnum}"
    @@rarray.each{|r|
      if r.res.group == gnum
        new_garray << r
      end
    }
    REQ_NUM.times{ 
      loop do
        RUBY_VERSION == "1.9.3" ? r = new_garray.sample : r = new_garray.choice
        #r = new_garray.choice
        #p "gnum:#{gnum}"
        #p r.res.group
        if r.res.group == gnum
          req_list << r
          break
        end
      end
    }
    
    #reqList.uniq!
    
    
    req_time = 0
    #pp req_list
    req_list.each{|req|
      req_time += req.time
    }
    RUBY_VERSION == "1.9.3" ? new_task_id = task_id_array.sample : new_task_id = task_id_array.choice 
    proc = (new_task_id.to_i%PROC_NUM)+1
    #p task_id_array
    priority = new_task_id
    extime = a_extime
    period = (extime/(1.0/task_count))
    offset = 0 #rand(10)
    
    #################
    
    task = Task.new(new_task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end
  
  #
  # ランダムタスク生成
  #
  private
  def create_task
    # リソース要求
    # 最大REQ_NUM回リソースを取得
    req_list = []
    REQ_NUM.times{
      if rand(2) == 1
        req_list << RequireManager.get_random_req unless RequireManager.get_random_req == nil
      end
    }
    #reqList.uniq!
    
    
    req_time = 0
    #pp req_list
    req_list.each{|req|
      req_time += req.time
    }
    
    #################
    # タスクステータス #
    #################
    @@task_id += 1
    proc = rand(PROC_NUM) + 1
    priority = rand(PRIORITY_MAX) + 1
    extime = req_time + rand(TASK_EXE_MAX - req_time)
    period = (extime/(rand % (1/TASK_NUM.to_f))).to_i + 1 # 1つのCPUに全てのタスクが割り当てられても，CPU使用率が1を超えないタスク使用率にする
    offset = 0 #rand(10)
    #################
    
    task = Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end
  
  #
  # タスクの配列生成
  # 生成したタスクの数を返す
  #
  public
  def create_task_array(i, info=["0"])
    #tarray = []
    #p info
    if info[0] == "0"
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
    elsif info[0] == "120405" 
      # info[1] はrcls
      #puts "120405 MODE"
      if info[1] == nil
        $stderr.puts "create_task_array:[#{__LINE__}行目]rcslが設定されていません"
      else
        i.times{
          @@task_array << create_task_120405(i, info[1])
        }
      end
      
      #
      # rcslは不要
      # 指定した実行時間info[1](初期値50)のタスクを生成．
      # 各CPUに均等にタスクは割り当てられる．
      #
    elsif info[0] == "120405_3" || info[0] == "120411"
      if info[1].to_i == 0
        i.times{
          @@task_array << create_task_120405_3(i)
        }
      else
        i.times{
          @@task_array << create_task_120405_3(i, info[1].to_i)
        }
      end
    else
      $stderr.puts "create_task_array:infoエラー"
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
      puts "Saving #{tasks_json["tasks"].size} tasks..."
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
  def TaskManager.get_all_require
    req_array = []
    @@task_array.each{|tsk|
      req_array += tsk.get_all_require
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
  # group_arrayをセット
  #
  def set_garray(garray)
    @@garray = garray
  end
  
  #
  # ランダムにリソース要求を作成
  #
  private
  def create_require(a_group=nil, a_time=nil)
    @@id += 1
    if a_group == nil 
      group = GroupManager.get_random_group
    else
      group = a_group
    end
    if a_time == nil
      time = REQ_EXE_MIN + rand(REQ_EXE_MAX - REQ_EXE_MIN)
    else
      time = a_time
    end
    
    req = []
    #p @@id
    r = RequireManager.get_random_req
    if r != nil && r.reqs.size == 0 && !(group.kind == "short" && r.res.kind == "long") && group.kind != r.res.kind
      # ※2段ネストまで対応
      if r.res != group && time > r.time && NEST_FLG
        req << r.clone
      end
    end
    #p time
    return Req.new(@@id, group, time, req)
  end
  
  #
  # ランダムにリソース要求を返す
  # 作成されている要求がなければ，nilを返す
  #
  def RequireManager.get_random_req
    ra = []
    if @@require_array.size < 1 then
      ra = nil
    else
      #p @@require_array.size
      RUBY_VERSION == "1.9.3" ? ra = @@require_array.sample.clone : ra = @@require_array.choice.clone
    end
    return ra
  end
  
  #
  # リソース要求IDからリソースのオブジェクト参照の配列を返す
  #
  def RequireManager.get_reqlist_from_req_id(req_list)
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

  #
  # リソース要求配列の作成
  # 作成したリソース要求の数を返す
  #
  public
  def create_require_array(i, info=["0"])
    flg = false
    g_array = []  # 作るべきリソース要求のグループ
    @@garray.each{|g|
      g_array << g
    }
    new_group = nil
    #p g_id_array
    until flg
      data_clear
      garray = []
      #puts "i:#{i}"
      
      i.times{|time|
        RUBY_VERSION == "1.9.3" ? new_group = g_array.sample : new_group = g_array.choice  # 作るべきリソース要求のグループがあればそれを指定．なければ指定しない
        new_group = GroupManager.get_random_group if new_group == nil
        g_array.delete(new_group)
        

        if info[0] == "120405_3"
          #
          # new_group(long or short)で要求時間timeの要求を作成
          #
          a_extime = info[1].to_i == 0 ? 50 : info[1].to_i
          c = create_require(new_group, a_extime/(time+1.0))
        elsif info[0] == "120411"
          #
          # リソース要求時間は実行時間のrcsl比で決める
          #
          a_extime = info[1].to_i == 0 ? 50 : info[1].to_i
          rcsl = info[2].to_f == 0.0 ? 0.3 : info[2].to_f
          c = create_require(new_group, a_extime*rcsl)
        else
          #
          #
          # リソース要求時間はランダム
          #
          c = create_require(new_group)
        end
        #p c
        garray << c.res.group
        @@require_array << c
      }
      #p garray

      garray.uniq!
      
      #p "@@garray:#{@@garray}"
      # 全てのグループのリソース要求が作成されたか確認
      #
      flg = true if garray.size == @@garray.size || i < @@garray.size
    end
    return @@require_array.size
      
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
    pp TaskManager.get_all_require
    TaskManager.get_all_require.each{|req|
      reqs_json["reqs"] << req.out_alldata
    }
    pp reqs_json["reqs"]
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
  def get_require_array
    return @@require_array
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
    @@kind = "long"
    @@group_array = []
  end
  
  #
  # グループを生成する
  #
  private
  def create_group
    @@group_id += 1
    group = Group.new(@@group_id, @@kind)
    #@@kind = "short"
    @@kind = @@kind == "long" ? "short" : "long"
    
    return group
  end
  
  #
  # i個のグループを生成し，group_arrayとする
  #
  public
  def create_group_array(i)
    data_clear
    garray = []
    i.times{
      garray << create_group
    }
    @@group_array = garray
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
        if grp["group"] > 0 && (grp["kind"]=="long"||grp["kind"]=="short")
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
  def GroupManager.get_group_from_group_id(group_id)
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
  def get_group_array
    return @@group_array
  end
  
  #
  # グループをランダムに返す
  #
  def GroupManager.get_random_group
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



def print_debug(str)
  puts str if $DEBUG
end
#
# main関数
#
# 使用方法 
# グループ，要求，タスクのマネージャーインスタンスを作成
# gm = GroupManager.instance
# rm = RequireManager.instance
# tm = TaskManager.instance
puts "ランダムタスク"
# 
# グループをランダムに5個作成
# gm.createGroupArray(5)
#
# それらのグループから要求から5つの要求を作成
# rm.create_requireArray(5)
#
# それらの要求から5つのタスクを作成
# pp tm.create_task_array(5)

=begin
gm = GroupManager.instance
rm = RequireManager.instance
tm = TaskManager.instance

gm.create_group_array(3)
rm.create_require_array(15)
tm.create_task_array(TASK_NUM)

tm.get_task_array
taskset = TaskSet.new(tm.get_task_array)
taskset.show_taskset

tm.save_task_data
gm.save_group_data
rm.save_require_data
=end
