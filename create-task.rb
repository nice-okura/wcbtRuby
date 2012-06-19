class TaskManager

  private
  #
  # 120620_2用
  #
  def create_task_120620_2(task_count, a_extime=50)
    #################
    # タスクステータス #
    #################
    #
    # 120620_2用
    #
    @@task_id += 1
    proc = UNASSIGNED  # 未割り当て
    extime = a_extime
    period = (extime/(1.0/task_count))
    priority = @@task_id
    offset = 0
    req_list = RequireManager.get_reqlist_from_req_id([@@task_id])
    p proc
    task = Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end
  #
  # 120620用
  #
  def create_task_120620(task_count, a_extime=50)
    #################
    # タスクステータス #
    #################
    #
    # 120620用
    #
    @@task_id += 1  # ここではタスクのidとしては用いない．task_id_arrayからnew_task_idを用いる
    
    task_id_array = Array.new(task_count){|index| "#{index+1}".to_i}
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
  # 120613用
  #
  def create_task_120613(task_count, a_extime=50)
    #################
    # タスクステータス #
    #################
    #
    # 120613用
    #
    @@task_id += 1  # ここではタスクのidとしては用いない．task_id_arrayからnew_task_idを用いる
    
    task_id_array = Array.new(task_count){|index| "#{index+1}".to_i}
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
  # rcsl:実行時間に対するリソース要求時間の比
  #
  def create_task_120405(task_count, rcsl)
    ####################
    # タスクステータス #
    ####################
    
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
  private
  def create_task_sche_check(umax)
    #################
    # タスクステータス #
    #################
    #
    # FMLP_P-EDFスケジューラビリティ解析用
    #
    
    # タスクの最大使用率
    util = umax - (rand%umax) # タスクの使用率は[0, umax] 

    @@task_id += 1
    proc = -1                 # 未割り当ては-1
    #p task_id_array
    #priority = new_task_id # EDFなのでpriorityは後から決めるしかない
    extime = 50.0 + rand(450.0) # 実行時間は[50, 500]
    period = extime/util
    offset = 0 #rand(10)
    req_list = []
    priority = 1
    #################
    
    task = Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
    
    set_short_require(task)
    task.resetting
    return task
  end

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
        r = RequireManager.get_random_req
        req_list << r unless r == nil
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
end

