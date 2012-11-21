# -*- coding: utf-8 -*-
class TaskManager

  private
  #
  # 手動
  #
  def create_task_manually(task_count, info)
    @@task_id += 1

    # プロセッサ未割り当て
    proc = UNASSIGNED

    # タスク使用率
    if info[:util] == nil
      # 周期
      if info[:period_range] != nil
        period = info[:period_range].get_random
      else
        period = (extime/(1.0/task_count))
      end
      
      # タスク実行時間
      if info[:extime_range] != nil
        extime = info[:extime_range].get_random
      elsif info[:extime] != nil
        extime = info[:extime]
      else
        STDERR.puts "実行時間を指定してー"
        raise
      end
    else
      # タスク使用率が指定されている場合
      util = info[:util]

      # 周期を元にタスク実行時間を決める
      if info[:period_range] != nil
        period = info[:period_range].get_random
        extime = period * util
      elsif info[:extime_range] != nil
        extime = info[:extime_range].get_random
        period = extime / util
      elsif info[:extime] != nil
        extime = info[:extime]
        period = extime / util
      else
        puts "タスク使用率を用いてタスクを生成する場合は，タスク周期かタスク実行時間を指定して．"
      end
    end
    

    # リソース要求
    req_list = []
    req_time = 0
    if info[:require_count] == nil
      REQ_NUM.times do
        if rand(2) == 1
          r = RequireManager.get_random_req
          unless r == nil
            # RCSLが指定されていた場合はタスク実行時間からCS長を求める
            r.set_time(extime*info[:rcsl]) if r.time == -1 # RCSLが指定されている時，time == -1 となる(create_require.rb)
            
            req_list << r 
            req_time += r.time
          end
        end
      end
    else
      info[:require_count].times do
        r = RequireManager.get_random_req
        unless r == nil
          # RCSLが指定されていた場合はタスク実行時間からCS長を求める
          r.set_time(extime*info[:rcsl]) if r.time == -1 # RCSLが指定されている時，time == -1 となる(create_require.rb)
          
          req_list << r 
          req_time += r.time
        end
      end
    end

    # 優先度
    priority = @@task_id

    # offset
    if info[:offset_range] != nil
      offset = info[:offset_range].get_random
    else
      offset = 0
    end

    return Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
  end

  def create_task_121121(task_count, info)
    @@task_id += 1

    # プロセッサ未割り当て
    proc = UNASSIGNED

    # タスク使用率
    if info[:util] == nil
      # 周期
      if info[:period_range] != nil
        period = info[:period_range].get_random
      else
        period = (extime/(1.0/task_count))
      end
      
      # タスク実行時間
      if info[:extime_range] != nil
        extime = info[:extime_range].get_random
      elsif info[:extime] != nil
        extime = info[:extime]
      else
        STDERR.puts "実行時間を指定してー"
        raise
      end
    else
      # タスク使用率が指定されている場合
      util = info[:util]

      # 周期を元にタスク実行時間を決める
      if info[:period_range] != nil
        period = info[:period_range].get_random
        extime = period * util
      elsif info[:extime_range] != nil
        extime = info[:extime_range].get_random
        period = extime / util
      elsif info[:extime] != nil
        extime = info[:extime]
        period = extime / util
      else
        puts "タスク使用率を用いてタスクを生成する場合は，タスク周期かタスク実行時間を指定して．"
      end
    end
    

    # リソース要求
    # 121121 の時は後でタスクに割当てる
    req_list = []

    # 優先度
    priority = @@task_id

    # offset
    if info[:offset_range] != nil
      offset = info[:offset_range].get_random
    else
      offset = 0
    end

    return Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
  end
  
  #
  # 120620_2用
  #
  def create_task_120620_2(task_count, a_extime=50)
    @@task_id += 1
    proc = UNASSIGNED  # 未割り当て
    extime = a_extime
    period = (extime/(1.0/task_count))
    priority = @@task_id
    offset = 0
    req_list = RequireManager.get_reqlist_from_req_id([@@task_id])
    task = Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end

  #
  # 120620用
  #
  def create_task_120620(task_count, info)
    @@task_id += 1  # ここではタスクのidとしては用いない．task_id_arrayからnew_task_idを用いる
    task_id_array = Array.new(task_count){|index| "#{index+1}".to_i}
    @@task_array.each{|t|
      task_id_array.delete(t.task_id)
    }
    # リソース要求
    # 最大REQ_NUM回リソースを取得
    req_list = []
    
    gcount = GroupManager.get_group_array.size
    gnum = (@@task_id-1)%gcount + 1  # 使用するグループのID
    new_garray = []
    RequireManager.get_require_array.each{|r|
      if r.res.group == gnum
        new_garray << r
      end
    }
    REQ_NUM.times{ 
      loop do
        RUBY_VERSION == "1.9.3" ? r = new_garray.sample : r = new_garray.choice
        if r.res.group == gnum
          req_list << r
          break
        end
      end
    }
    
    req_time = 0
    req_list.each{|req|
      req_time += req.time
    }
    RUBY_VERSION == "1.9.3" ? new_task_id = task_id_array.sample : new_task_id = task_id_array.choice 
    proc = UNASSIGNED
    priority = new_task_id
    if info[:extime] != nil
      extime = info[:extime]
    elsif info[:extime_range] != nil
      extime = info[:extime_range].get_random
    end 
    period = (extime/(1.0/task_count))
    offset = 0 #rand(10)
    
    #################
    
    task = Task.new(new_task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end


  # 120927用
  def create_task_120927(task_count, info)
     @@task_id += 1  # ここではタスクのidとしては用いない．task_id_arrayからnew_task_idを用いる
    task_id_array = Array.new(task_count){|index| "#{index+1}".to_i}
    @@task_array.each{|t|
      task_id_array.delete(t.task_id)
    }
    # リソース要求
    # 最大REQ_NUM回リソースを取得
    req_list = []
    
    gcount = GroupManager.get_group_array.size
    gnum = (@@task_id-1)%gcount + 1  # 使用するグループのID
    new_garray = []
    RequireManager.get_require_array.each{|r|
      if r.res.group == gnum
        new_garray << r
      end
    }
    REQ_NUM.times{ 
      loop do
        RUBY_VERSION == "1.9.3" ? r = new_garray.sample : r = new_garray.choice
        if r.res.group == gnum
          req_list << r
          break
        end
      end
    }
    
    req_time = 0
    req_list.each{|req|
      req_time += req.time
    }
    RUBY_VERSION == "1.9.3" ? new_task_id = task_id_array.sample : new_task_id = task_id_array.choice 
    proc = UNASSIGNED
    priority = new_task_id
    if info[:extime] != nil
      extime = info[:extime]
    elsif info[:extime_range] != nil
      extime = info[:extime_range].get_random
    end 
    period = extime/[0.1..0.3].get_random
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
    
    gcount = GroupManager.get_group_array.size
    gnum = @@task_id%gcount + 1  # 使用するグループのID
    new_garray = []
    #p "task_id:#{@@task_id} gcount:#{gcount} gnum:#{gnum}"
    RequireManager.get_require_array.each{|r|
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
      gcount = GroupManager.get_group_array.size
      gnum = @@task_id%gcount + 1  # 使用するグループのID
      new_garray = []
      #p "task_id:#{@@task_id} gcount:#{gcount} gnum:#{gnum}"
      RequireManager.get_require_array.each do|r|
        if r.res.group == gnum
          new_garray << r
        end
      end
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
  
  private
  def create_task_sche_check(umax)
    #################
    # タスクステータス #
    #################
    #
    # FMLP_P-EDFスケジューラビリティ解析用
    #
    
    # タスクセット当たりの最大タスク数
    task_count = 20

    # タスクの最大使用率
    #d = umax/task_count.to_f
    #util = d*i
    util = umax - (rand%umax) # タスクの使用率は(0, umax] 
    
    @@task_id += 1
    proc = UNASSIGNED                 # 未割り当ては-1
    #p task_id_array
    #priority = new_task_id # EDFなのでpriorityは後から決めるしかない
    #extime = 50.0 + (450.0/task_count.to_f)*i
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
    
    gcount = GroupManager.get_group_array.size
    gnum = @@task_id%gcount + 1  # 使用するグループのID
    new_garray = []
    #p "task_id:#{@@task_id} gcount:#{gcount} gnum:#{gnum}"
    RequireManager.get_require_array.each{|r|
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
  private
  def create_task_121003(task_count, info)
    ####################
    # タスクステータス #
    ####################
    #
    # 121003用
    #
    @@task_id += 1
    priority = @@task_id
    extime = info[:extime]
    period = (extime/(1.0/task_count))
    offset = 0 #rand(10)
    
    req_list = []
    info[:require_count].times do
      r = RequireManager.get_random_req
      req_list << r
    end
    #################
    
    task = Task.new(@@task_id, -1, period, extime, priority, offset, req_list)
    
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
    offset = rand(10)
    #################
    
    task = Task.new(@@task_id, proc, period, extime, priority, offset, req_list)
    
    return task
  end


  # タスクの配列生成
  # 生成したタスクの数を返す
  public
  def create_task_array(i, info={ })
    case info[:mode]
    when "0"
      #
      # 外部ファイルからタスクが読み込まれていなかったらタスクランダム生成
      # そうでなければそのまま
      #
      i.times{
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
      max_util = 0.0
      i.times do |num|
        t = create_task_sche_check(info[:umax])
        max_util += t.get_extime/t.period
        break if max_util > 4*0.8
        @@task_array << t
      end
    when MY_SCHE_CHECK
      # 自分で考えたP-SP FMLPスケジューラビリティ解析
      # Real-time synchronization on multiprocessors: To block or not to block, to suspend or spin?
      # を参考にした．
      max_util = 0.0
      i.times do |num|
        t = create_task_sche_check(info[:umax])
        max_util += t.get_extime/t.period
        
        u = info[:proc_num]*info[:cpu_util_max].to_f
        break if max_util > u
        @@task_array << t
      end 
    when "120620"
      i.times{ 
        @@task_array << create_task_120620(i, info)
      }
    when "120613"
      i.times{ 
        @@task_array << create_task_120613(i, info[:extime])
      }
    when "120620_2"
      i.times{ 
        @@task_array << create_task_120620_2(i, info[:extime])
      }
    when "120927"
      i.times do
        @@task_array << create_task_120620(i, info)
      end
    when "121003"
      i.times do 
        @@task_array << create_task_121003(i, info)
      end
    when "121121"
      i.times do
        @@task_array << create_task_121121(i, info)
      end
      reqs = get_use_reqs_random(i*info[:require_count])
      @@task_array.each do |t|
        # タスクごとのリソース要求数ずつ，リソース要求を割当てる
        info[:require_count].times{ t.req_list << reqs.shift }
      end
      STDERR.puts "リソース要求が余っている．おかしい．" unless reqs == []
      
      
    # リソースやタスクのの割り当てを手動で設定
    when CREATE_MANUALLY
      i.times{ 
        @@task_array << create_task_manually(i, info)
      }
    else
      $stderr.puts "create_task_array:infoエラー"
      raise
      exit
    end

    # 優先度割当て
    case info[:priority_mode]
    when PRIORITY_BY_UTIL      
      # タスク使用率順に優先度とID付け直す
      @@task_array.sort! do |a, b|
        -1 * (a.util <=> b.util)
      end
      @@task_array.each_with_index do |t, i|
        t.set_taskid(i+1)
        t.set_priority(i+1)
      end
    when PRIORITY_BY_PERIOD
      # タスク周期順に優先度とID付け直す
      @@task_array.sort! do |a, b|
        a.period <=> b.period
      end
      @@task_array.each_with_index do |t, i|
        t.set_taskid(i+1)
        t.set_priority(i+1)
      end
    when PRIORITY_BY_ID
      # タスクID順に優先度とID付け直す
      # 既にID順になっているので何もしない
    else
      # 標準
      # タスクID順に優先度とID付け直す
      # 既にID順になっているので何もしない
    end
    
    return @@task_array.size
  end


  # タスクに割当てるリソース要求の作成
  # 未使用のリソース要求の存在を許さず，全てのリソースを含めた後はランダム
  # @param [Fixnum] req_count 必要なリソース要求数
  def get_use_reqs_semirandom(req_count)
    count = 0
    using_reqs = []
    reqs = RequireManager.get_require_array
   
    # 作成したグループのリソース要求をまず取得
    using_reqs += RequireManager.get_reqs_from_group_id(GroupManager.get_group_id_list)

    # 残りはランダムで選択
    (req_count - using_reqs.size).times do
      req = RUBY_VERSION == "1.9.3" ? reqs.sample : reqs.choice
      using_reqs << req
    end
    
    return using_reqs
  end

    # タスクに割当てるリソース要求の作成
  # 未使用のリソース要求の存在を許さず，完全ランダム
  # @param [Fixnum] req_count 必要なリソース要求数
  def get_use_reqs_random(req_count)
    return get_use_reqs_semirandom(req_count).sort{ rand }
  end
end
