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
# タスクマネージャークラスの定義
#
class TaskManager
  include Singleton
  
  def initialize
    @@task_id = 0
    @@task_array = []
    
    #
    # 外部ファイルから読み込む場合
    #
    if $external_input == true
      load_task_data
    end
  end

  #
  # タスクの配列を返す
  #
  public
  def get_task_array
    return @@task_array
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
      if rand(2) == 1 then
        req_list += [RequireManager.get_random_req]
      end
    }
    #reqList.uniq!
    
    req_time = 0
    #pp reqList
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
    period = extime/(rand % (1/TASK_NUM.to_f)) # 1つのCPUに全てのタスクが割り当てられても，CPU使用率が1を超えないタスク使用率にする
    offset = rand(10)

    #################
    
    task = Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
    task.set_begin_time
    return task
  end
  
  #
  # タスクの配列生成
  #
  public
  def create_task_array(i)
    #
    # 外部ファイルからタスクが読み込まれていなかったらタスクランダム生成
    # そうでなければそのまま
    #
    if @@task_array == []
      puts "non_external_file"
      tarray = []
      i.times{
        tarray << create_task
      }
      @@task_array = tarray
    end
  end
  
  #
  # タスクの保存(JSON)
  #
  public
  def save_task_data
    #puts "write"
    
    tasks_json = {
      "tasks" => []
    }
    @@task_array.each{|task|
      tasks_json["tasks"] << task.out_alldata
    }
    #pp tasks_json
    begin
      File.open(TASK_FILE_NAME, "w"){|fp|
        fp.write JSON.pretty_generate(tasks_json)
      }
    rescue => e
      #puts e.class
      #puts e.message
      puts e.backtrace
      puts("resource file output error: #{filename} could not be created.\n")
    end
  end
  
  #
  # タスクの読み込み(JSON)
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
      end

      tasks = (JSON.parser.new(json)).parse()
      return tasks
    end
  end
  
  #
  # JSONファイルから読み取って作成した(load_task_json_data)ハッシュから
  # タスククラスを作成
  #
  private
  def load_task_data(filename=TASK_FILE_NAME)
    tasks = load_json_task_data(filename)      # ハッシュの作成
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
  end
  
  #
  # 全タスクで使われているリソース要求の配列を返す
  #
  public
  def TaskManager.get_all_require
    req_array = []
    @@task_array.each{|tsk|
      req_array += tsk.req_list
    }
    return req_array
  end
end

#
# グループマネージャークラスの定義
#
class GroupManager
  include Singleton

  def initialize
    @@group_id = 0
    @@kind = "long"
    @@group_array = []
    
    #
    # 外部ファイルから読み込む場合
    #
    if $external_input == true
      load_group_data
    end
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
    #
    # 外部ファイルからタスクが読み込まれていなかったらタスクランダム生成
    # そうでなければそのまま
    #
    garray = []
    if @@group_array == []
      garrau = []
      i.times{
        garray << create_group
      }
      @@group_array = garray
    end
  end
  
  private
  def get_count
    return @@group_id
  end
  
  public
  def get_group_array
    return @@group_array
  end
  
  #
  # グループの保存(JSON)
  #
  public
  def save_group_data(filename=GRP_FILE_NAME)
    grps_json = {
      "grps" => []
    }
    @@group_array.each{|grp|
      grps_json["grps"] << grp.out_alldata
    }
    begin
      File.open(GRP_FILE_NAME, "w"){|fp|
        fp.write JSON.pretty_generate(grps_json)
      }
      rescue => e
      puts e.backtrace
      puts("resource file output error: #{filename} could not be created.\n")
    end
  end

  #
  # グループの読み込み(JSON)
  #
  private
  def load_group_data(filename=GRP_FILE_NAME)
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
      end
      
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
    end
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
  # グループをランダムに返す
  #
  def GroupManager.get_random_group
    if @@group_array.size == 0
      puts "グループが生成されていません．"
      exit()
    end
    return @@group_array[rand(@@group_array.size)]
  end
end

#
# リソース要求マネージャーの定義
#
class RequireManager
  include Singleton

  def initialize
    @@id = 0
    @@require_array = []
    
    #
    # 外部ファイルから読み込む場合
    #
    if $external_input == true
      load_require_data
    end
  end
  
  private
  def create_require
    @@id += 1
    group = GroupManager.get_random_group
    #pp group
    time = REQ_EXE_MIN + rand(REQ_EXE_MAX - REQ_EXE_MIN)
    req = []
    r = RequireManager.get_random_req
    if r != [] && r.reqs.size == 0 && !(group.kind == "short" && r.res.kind == "long")then
      # ※2段ネストまで対応
      if r.res != group && time > r.time
        # p r.object_id
        req << r.clone
      end
    end
    Req.new(@@id, group, time, req)
  end
  
  #
  # クラス変数：require_arrayを返す
  #
  public
  def get_require_array
    return @@require_array
  end
  
  #
  #
  #
  def RequireManager.get_random_req
    if @@require_array.size <= 1 then
      # puts "要求が生成されていません．"
      []
    else
      req = @@require_array[rand(@@require_array.size)]
      return req.clone
    end
  end
  
  #
  # リソース要求IDからリソースのオブジェクト参照の配列を返す
  #
  def RequireManager.get_reqlist_from_req_id(req_list)
    #p "REQUIRE_ARRAY:" + @@require_array.to_s
    reqs = []
    req_list.each{|req_id|
      @@require_array.each{|r|
        #p r.req_id
        if r.req_id == req_id
          reqs << r
          break
        end
      }
    }
    #pp reqs
    return reqs
  end

  #
  # リソース要求配列の作成
  #
  public
  def create_require_array(i)
    #
    # 外部ファイルから読み込まれていなかったら要求ランダム生成
    # そうでなければそのまま
    #
    if @@require_array.size == 0
      reqArray = []
      i.times{
        @@require_array << create_require
      }
    end
  end
  
  #
  # リソース要求の保存(JSON)
  #
  public
  def save_require_data    
    reqs_json = {
      "reqs" => []
    }
    TaskManager.get_all_require.each{|req|
      reqs_json["reqs"] << req.out_alldata
    }
    begin
      File.open(REQ_FILE_NAME, "w"){|fp|
        fp.write JSON.pretty_generate(reqs_json)
      }
      rescue => e
      puts e.backtrace
      puts("resource file output error: #{filename} could not be created.\n")
    end
  end
  
  #
  # リソース要求の読み込み(JSON)
  #
  private
  def load_require_data
    json = ""
    file_type = File::extname(REQ_FILE_NAME)
    case file_type
      when ".json"
      begin
        File.open(File.expand_path(REQ_FILE_NAME), "r") { |file|
          while line = file.gets
            json += line
          end
        }
        rescue
        puts "application file read error: #{filename} is not exist.\n"
      end
      
      reqs = (JSON.parser.new(json)).parse()
      
      #
      # リソース要求毎の処理
      # @@req_arrayに読み込んだタスクを追加
      #
      reqs["reqs"].each{|req|
        #
        # req作成時に「自分より前に作成されていたリソースをネストとする」ため，
        # reqsのidがreqより先のidであることはない
        # 
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
        unless b == r.begintime
          puts "ERROR:begintime"
        end
        @@require_array << r
      }
    end
  end
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