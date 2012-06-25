# よく使う関数群

module UTIL
  # group1リソースを要求するタスクの優先度が1(最高優先度かどうか)
  # @param [Array<Task>]
  # @return group1が最高優先度タスクに割り当てられていればtrue そうでなければfalse
  def check_highest_priority(task_list)
    task_list.each{ |t|
      t.req_list.each{ |r|
        if r.res.group == 1
          # group1を要求しているが，
          if t.priority != 1
            # 最高優先度でない場合，falseを返す
            return false
          end
        end
      }
    }
    # group1を要求しているタスクが全て高優先度ならtrueを返す
    return true
  end
end
