class RequireManager
  #
  # ランダムにリソース要求を作成
  #
  private
  def create_require_120613(info = { })
    @@id += 1
    group = info[:group]
#    p group 
    time = info[:extime]*(rand%info[:rcsl])
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
end
