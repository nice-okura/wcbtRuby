class TaskManager
  private
  def create_task_120613(task_count, a_extime=50)
    #################
    # タスクステータス #
    #################
    #
    # 120613用
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
end
