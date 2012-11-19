#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
# タスクをschesim用に変換するためのクラス
#
#$:.unshift(File.dirname(__FILE__))

class EXPORT_SCHESIM

  def initialize(name)
    # hoge/piyo/以下に
    #   piyo_task.json
    #   ...
    #を作成する場合
    # name = hoge/piyo/
    # dirname = hoge/piyo
    # filename = piyo とする

    # name はfrozenなのでdir_nameとして複製
    @dirname = name.dup

    # 末尾が"/"なら"/"を取る
    @dirname.sub!(/\/$/, "")
    
    # ファイル名のプレフィックス
    @filename = File::basename(@dirname)

    # ディレクトリ作成
    Dir::mkdir(@dirname) unless File::exists?(@dirname)
    @info = { }
    @info["cpu"] = []
    set_cpu_info(1)
  end

  def clear
    @filename = nil
    @dirname = nil
    @info = { }
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
      "period" => 50000,
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
    proc_list.each do |proc|
      @info["cpu"][0]["core"] << get_core_info(manager, proc)
    end
  
    File.open("#{@dirname}/#{@filename}.json", "w") do |fp|
      fp.write JSON.pretty_generate(@info)
    end
  end

  #
  #  タスク処理記述ファイルの出力
  #
  def output_app_desc_file(manager)
    File.open("#{@dirname}/#{@filename}.rb", 'w') { |f|
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
    g_array.each do |g|
      if g.kind == LONG
        str << "\t @@res#{g.group} = LONG_RESOURCE.new\n"
      else
        str << "\t @@res#{g.group} = SHORT_RESOURCE.new\n"
      end
    end
    
    return str
  end


  def get_task_str(t)
    str = ""

    proc_s = t.proc.proc_id.to_s
    curTime = t.offset
    t.req_list.each do |req|
      calc_time = 0.0
      calc_time = req.begintime - curTime # 現在時刻から次のリソース要求の時間までが計算時間
      
      str << "\t\t exc(" << calc_time.to_s << " * @@share" << proc_s << ")\n" if calc_time > 0.0

      curTime += calc_time                # 現在時刻を進める

      str << get_req_str(req)   # リソース要求の分だけLONG or SHORTCHAR を表示

      curTime += req.time
    end

    # 最後に計算時間が余っていれば表示
    time = t.get_noninflate_time + t.offset - curTime
    str << "\t\t exc(" << time.to_s << " * @@share" << proc_s << ")\n" if time > 0.0
  

    return str
  end
  
  def get_req_str(req)
    str = ""
    grp = req.res.group.to_s
    time = req.time.to_s
    if req.res.kind == LONG
      str << "\t\t GetLongResource(@@res" << grp << ")\n"
      str << "\t\t exc(" << time << ")\n"
      str << "\t\t ReleaseLongResource(@@res"<< grp << ")\n"
    else
      str << "\t\t GetShortResource(@@res" << grp << ")\n"
      str << "\t\t exc(" << time << ")\n"
      str << "\t\t ReleaseShortResource(@@res" << grp << ")\n"
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
