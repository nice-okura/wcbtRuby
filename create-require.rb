class RequireManager

  ################################################
  #
  # public
  public
  #
  ################################################

  ################################################
  #
  # リソース要求配列の作成
  # 作成したリソース要求の数を返す
  #
  ################################################
  def create_require_array(i, info={ })
    group_array = GroupManager.get_group_array
    case info[:mode]
    when SCHE_CHECK
      #
      # スケジューラビリティ解析用
      #
      
      f = info[:f] # nesting_factor

      # shortリソース要求作成
      i_max = SHORT_GRP_COUNT*3
      #d = 5.2/i_max.to_f
      0.upto(i_max-1){ |i|
        @@id += 1
        g = GroupManager.get_group_from_group_id(i%SHORT_GRP_COUNT+1)
        time = 1.3 + rand(6) + rand%0.2 # 1.3 + [0, 5] + [0.0, 0.2)
        #time = 1.3 + d*i # [1.3, 6.5]
        @@require_array << Req.new(@@id, g, time, [])
        #            return Req.new(@@id, group, time, req)
      }
      
      # longリソース要求作成
      # それぞれのlongリソース要求に対し，2〜4個のこのリソースアクセスしている異なったタスクを選択する．
      # なので，予め2(longリソース個数)*4(longリソース要求する最大タスク数)=8 のリソース要求を作成しておく

      0.upto(LONG_REQ_COUNT-1){ |i|
        @@id += 1
        g_id = 30 + i%2+1
        g = GroupManager.get_group_from_group_id(g_id)
        
        time = 20 + rand(11)
        
        @@require_array << Req.new(@@id, g, time, [])
      }
    when MY_SCHE_CHECK
      f = info[:f] # nesting_factor

      # shortリソース要求作成
      i_max = SHORT_GRP_COUNT*3
      0.upto(i_max-1) do |i|
        @@id += 1
        g = GroupManager.get_group_from_group_id(i%SHORT_GRP_COUNT+1)
        time = 1.3 + rand(6) + rand%0.2 # 1.3 + [0, 5] + [0.0, 0.2)
        #time = 1.3 + d*i # [1.3, 6.5]
        
        # RCSL比によってCS時間を変える
        time *= info[:rcsl]
        
        @@require_array << Req.new(@@id, g, time, [])
      end
      
      # longリソース要求作成
      # それぞれのlongリソース要求に対し，2〜4個のこのリソースアクセスしている異なったタスクを選択する．
      # なので，予め2(longリソース個数)*4(longリソース要求する最大タスク数)=8 のリソース要求を作成しておく

      0.upto(LONG_REQ_COUNT-1) do |i|
        @@id += 1
        g_id = 30 + i%2+1
        g = GroupManager.get_group_from_group_id(g_id)
        
        time = 20 + rand(11)
        
        # RCSL比によってCS時間を変える
        time *= info[:rcsl]
        time = time.round(2)
        @@require_array << Req.new(@@id, g, time, [])
      end
    when "120620_2", "120620"      
      get_use_group_array_order(i, group_array).each do |g|
          info[:group] = g
          @@require_array << create_require_120620(info)
      end
    when "120405_3"
      #
      # new_group(long or short)で要求時間timeの要求を作成
      #
      a_extime = info[:extime].to_i == 0 ? 50 : info[:extime].to_i
      get_use_group_array_random(i, group_array).each{ |new_group|
        c = create_require(new_group, a_extime/(time+1.0))
      }
    when"120411"
      # リソース要求時間は実行時間のrcsl比で決める
      a_extime = info[:extime].to_i == 0 ? 50 : info[:extime].to_i
      rcsl = rand%0.3
      #rcsl = info[2].to_f == 0.0 ? 0.3 : info[2].to_f
      get_use_group_array_random(i, group_array).each{ |new_group|
        @@require_array << create_require(new_group, a_extime*rcsl)
      }
    when "120613"
      get_use_group_array_random(i, group_array).each{ |new_group|
        info[:group] = new_group
        @@require_array << create_require_120613(info)
      }
    when CREATE_MANUALLY
      get_use_group_array_random(i, group_array).each{ |new_group|
        info[:group] = new_group
        @@require_array << create_require_manually(info)
      }
    else
      #
      #
      # リソース要求時間はランダム
      #
      get_use_group_array_random(i, group_array).each{ |new_group|
        @@require_array << create_require(new_group)
      }
    end
    
    return @@require_array.size
    
  end

  ################################################
  #
  # private
  private
  #
  ################################################

  #
  # 手動
  #
  def create_require_manually(info)
    @@id += 1
    
    # リソース要求時間
    if info[:rcsl] != nil
      time = -1  # タスクに割り当てる時にリソース要求時間は決めるので，いまは-1にしておく
    elsif info[:require_range] != nil
      time = info[:require_range].first + rand(info[:require_range].last - info[:require_range].first)
    elsif info[:require_time] != nil
      time = info[:require_time]
    else
      time = REQ_EXE_MIN + rand(REQ_EXE_MAX - REQ_EXE_MIN)
    end

    # グループ
    group = info[:group]
    group = GroupManager.get_random_group if group == nil

    # ネスト
    req = []
    r = RequireManager.get_random_req
    if r != nil && r.reqs.size == 0 && !(group.kind == SHORT && r.res.kind == LONG) && group.kind != r.res.kind
      # ※2段ネストまで対応
      if r.res != group && time > r.time && info[:nest] == true
        req << r.clone
      end
    end



    return Req.new(@@id, group, time, req)
  end

  #
  # ランダムにリソース要求を作成
  # 120620ミーティング用
  #
  def create_require_120620(info = { })
    @@id += 1
    group = info[:group]
    # Group1は長くする
    time = group.group == 1 ? info[:extime]*info[:rcsl_l] : info[:extime]*info[:rcsl_s]
    req = []

    return Req.new(@@id, group, time, req)
  end

  #
  # ランダムにリソース要求を作成
  # 120613ミーティング用
  #
  def create_require_120613(info = { })
    @@id += 1
    group = info[:group]
    time = info[:extime]*(rand%info[:rcsl])
    req = []

    return Req.new(@@id, group, time, req)
  end


  #
  # ランダムにリソース要求を作成
  #
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
    if r != nil && r.reqs.size == 0 && !(group.kind == SHORT && r.res.kind == LONG) && group.kind != r.res.kind
      # ※2段ネストまで対応
      if r.res != group && time > r.time && NEST_FLG
        req << r.clone
      end
    end
    
    #p time
    return Req.new(@@id, group, time, req)
  end



  
  ## 使用するリソースグループの配列を返す
  # 未使用のリソースの存在を許さず，全てのリソースを含めた後はランダム
  def get_use_group_array_semirandom(group_count, g_array)
    count = 0
    using_group_array = []
    
    g_array.each{ |g|
      using_group_array << g
      count += 1
      return using_group_array if count == group_count
    }
    
    # 残りはランダムで選択
    (group_count-count).times{ 
      RUBY_VERSION == "1.9.3" ? new_group = g_array.sample : new_group = g_array.choice  # 作るべきリソース要求のグループがあればそれを指定．なければ指定しない
      using_group_array << new_group
    }
    
    return using_group_array
  end

  # 未使用のリソースの存在を許さず，すべてランダム
  def get_use_group_array_random(group_count, g_array)
    return get_use_group_array_semirandom(group_count, g_array).sort_by{ rand }
  end


  # 未使用のリソースの存在を許さず，全てのリソースを含めた後もg_arrayの順番通り
  def get_use_group_array_order(group_count, g_array)
    count = 0
    using_group_array = []
    
    while(1)
      g_array.each{ |g|
        using_group_array << g
        count += 1
        return using_group_array if count == group_count
      }
    end
  end
end
