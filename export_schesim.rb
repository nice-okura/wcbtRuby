#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
# タスクをschesim用に変換するためのクラス
#
$:.unshift(File.dirname(__FILE__))
require "manager"

class EXPORT_SCHESIM

  def initialize(filename)
    @filename = filename
    @info = { }
    @info["cpu"] = []
    set_cpu_info(1)
  end

  ######################################################
  # 
  # private
  #
  private
  ######################################################

  def set_cpu_info(id)
    core_info = { 
      "id" => id,
      "core" => []
    }
    @info["cpu"] << core_info
  end

  def get_core_info(manager, proc)
    core_info = { 
      "id" => proc.proc_id,
      "application" => [],
      "scheduling" => "fp" # 今のところ固定
    }
    
    period = manager.tm.get_max_period
    core_info["application"] << get_app_info(proc, period)
    
    return core_info
  end

  def get_app_info(proc, period)
    app_info = { 
      "id" => proc.proc_id,
      "share" => 1.0,
      "scheduling" => "fp",
      "pri" => 1,
      "period" => period*PROC_NUM,
      "task" => []
    }

    proc.task_list.each{ |t|
      app_info["task"] << get_task_info(t)
    }

    return app_info
  end

  # タスククラスからschesim用のタスクデータ(Hash)を返す
  def get_task_info(task)
    tsk = { 
      "id" => task.task_id,
      "priority" => task.priority,
      "period" => task.period,
      "wcet" => task.wcrt,
      "attr" => "cyclic",
      "offset" => task.offset
    }

    return tsk
  end
   
  # AllManagerクラスからschesim用のjsonファイルを出力する
  def output_schesim_json(manager)
    proc_list = ProcessorManager.proc_list
    proc_list.each{ |proc|
      @info["cpu"][0]["core"] << get_core_info(manager, proc)
    }
  
    File.open("#{@filename}.json", "w"){ |fp|
      fp.write JSON.pretty_generate(@info)
    }
  end

  #
  #  タスク処理記述ファイルの出力
  #
  def output_app_desc_file(manager)
    File.open("#{@filename}.rb", 'w') { |f|
      f.print "class TASK\n"
      f.print get_groups_str(GroupManager.get_group_array)
      @info["cpu"].each do |cpu|
        cpu["core"].each do |core|
          core["application"].each do |app|
            f.print "\t @@share" + app["id"].to_s + " = " + app["share"].to_s + "\n"
            app["task"].each do |tsk|
              f.print "\t def task" + tsk["id"].to_s + "\n"
              f.print get_task_str(TaskManager.get_task(tsk["id"]))
              #f.print "\t\t exc(" + tsk["wcet"].to_s + " * @@share" + app["id"].to_s + ")\n"
              f.print "\t end\n"
            end
          end
        end
      end
      f.print "end\n"
    }
  end
  
  def get_groups_str(g_array)
    str = ""
    g_array.each{ |g|
      if g.kind == LONG
        str += "\t @@res#{g.group} = LONG_RESOURCE.new\n"
      else
        str += "\t @@res#{g.group} = SHORT_RESOURCE.new\n"
      end
    }
    
    return str
  end


  def get_task_str(t)
    str = ""

    curTime = t.offset
    t.req_list.each{ |req|
      calc_time = 0.0
      calc_time = req.begintime - curTime # 現在時刻から次のリソース要求の時間までが計算時間
      
      str += "\t\t exc(#{calc_time} * @@share#{t.proc.proc_id})\n" if calc_time > 0.0

      curTime += calc_time                # 現在時刻を進める

      str += get_req_str(req)   # リソース要求の分だけLONG or SHORTCHAR を表示

      curTime += req.time
    }

    # 最後に計算時間が余っていれば表示
    time = t.get_extime + t.offset - curTime
    str += "\t\t exc(#{time} * @@share#{t.proc.proc_id})\n" if time > 0.0
  

    return str
  end
  
  def get_req_str(req)
    str = ""
    
    if req.res.kind == LONG
      str += "\t\t GetLongResource(@@res#{req.res.group})\n"
      str += "\t\t exc(#{req.time})\n"
      str += "\t\t ReleaseLongResource(@@res#{req.res.group})\n"
    else
      str += "\t\t GetShortResource(@@res#{req.res.group})\n"
      str += "\t\t exc(#{req.time})\n"
      str += "\t\t ReleaseShortResource(@@res#{req.res.group})\n"
    end

    return str
  end
  
  ######################################################
  # 
  # public
  #
  public
  ######################################################
  
  def output(manager)
    output_schesim_json(manager)
    output_app_desc_file(manager)
  end
end
