# -*- coding: utf-8 -*-
#
# プロセッサクラス
#
class Processor
  # プロセッサに割り当てられているタスクのリスト
  attr_reader :task_list
  attr_reader :util, :proc_id
  
  # コンストラクタ
  def initialize(attr)
    @task_list = []

    @util = 0.0
    id = attr[PROC_ID_SYN] # IDは1から始まる
    if id == nil || id == 0
      raise "プロセッサIDが不正です．"
    end
    @proc_id = id

    unless attr[TASK_LIST_SYN] == nil
      tlist = TaskManager.get_tasks(attr[TASK_LIST_SYN])
      tlist.each do |t|
        #pp t.wcrt
        assign_task(t)
      end
    end
  end
  
  ###############################################################
  #
  # 以下 public
  #
  ###############################################################
  public 
  # プロセッサにタスク割り当て
  # @param [Task] 割当てるタスク
  # @return 成功したらtrue
  def assign_task(task)
    if @proc_id == nil || @proc_id == 0
      raise "プロセッサIDが不正です．"
    elsif task == nil
      raise "taskがnilです.(Processor::assign_task)" if task == nil
    end
    @task_list << task

    # プロセッサ番号設定
#    p @proc_id
    task.set_proc(self)
    # 優先度設定
    task.set_priority(@task_list.size)

    # プロセッサ使用率計算
    @util = calc_util
    return true
  end

  # プロセッサ内のタスクのソート
  def sort_tasks(mode)
    case mode
    when SORT_PRIORITY
      sort_by_task_pri
    when SORT_ID
      sort_by_task_id
    when SORT_UTIL
      sort_by_task_util
    when SORT_PERIOD
      sort_by_task_period
    else 
      # 標準は優先度順
      sort_by_task_pri
    end
  end

  # プロセッサのデータを返す
  # JSON外部出力用
  def out_alldata
    tsk_list = []
    @task_list.each do |t|
      tsk_list << t.task_id
    end
    return {
      PROC_ID_SYN => @proc_id, 
      TASK_LIST_SYN => tsk_list
    }
    #return [@task_id, @proc, @period, @extime, @priority, @offset, req_list]
  end

  # プロセッサに割り当てられているタスクを削除
  def remove_task
    @task_list = []
  end
  
  # Processorクラスを整形して表示
  def print
    puts "Processor#{@proc_id}"
    puts "\tタスク: #{@task_list.each{ |t| print t.task_id }}"
  end
  
  # 比較演算子
  def ==(proc)
    raise unless proc.class == Processor
    return true if @proc_id == proc.proc_id
    return false
  end
  
  # プロセッサ内の最高優先度のタスクを返す
  def get_highest_priority_task
    priority = 100
    task = nil
    @task_list.each do |t|
      if priority > t.priority
        priority = t.priority
        task = t
      end
    end
    
    return task
  end
  #def !=(proc)
  #  return false if self == proc
  #  return true
  #end
  
  ###############################################################
  #
  # 以下 private
  #
  ###############################################################
  # プロセッサ使用率を計算
  # @return [Float] プロセッサ使用率
  private
  def calc_util
    util = 0.0
    @task_list.each do |t|
      util += t.get_extime/t.period
    end

    return util
  end

  # タスクをIDの降順で並べる
  def sort_by_task_id
    @task_list.sort! do |a, b|
      a.task_id <=> b.task_id
    end
  end
  
  # タスク使用率の降順で並べる
  def sort_by_task_util
    @task_list.sort! do |a, b|
      a.util <=> b.util
    end
  end

  # タスク優先度の降順で並べる
  def sort_by_task_pri
    @task_list.sort! do |a, b|
      a.priority <=> b.priority
    end
  end

  # タスク周期の降順で並べる
  def sort_by_task_period
    @task_list.sort! do |a, b|
      a.period <=> b.period
    end
  end
end
