require "pp"

PROCS = "procs"
# プロセッサマネージャーの定義
class ProcessorManager
  include Singleton
  ###############################################################
  #
  # 以下 public
  #
  ###############################################################
  public 
  def initialize
    @@proc_id = 0
    @@proc_list = []
  end

  # プロセッサにタスクを割当てる
  # 呼び出される度にプロセッサを初期化する
  # @param task_list [Array<Task>] 割当てるタスクのリスト
  def assign_tasks(task_list, info={ })
    init_all_proc # 全てのプロセッサのタスクを取り除く

    case info[:assign_mode]
    when WORST_FIT
      # WORST_FITで割当てる
    when LIST_ORDER
      # task_listの順に割り当てる
      assign_list_order(task_list)
    when ID_ORDER
      # タスクIDの順で割り当てる
      assign_id_order(task_list)
    when RANDOM_ORDER
      # ランダムに割り当てる
      assign_random(task_list)
    else
      # ランダムに割当てる
      assign_random(task_list)
    end
  end

  # プロセッサ情報の保存(JSON)
  # @param filename [String] ファイル名
  # @reutrn [Fixnum] 書き込んだプロセッサ数を返す．失敗したら0
  def save_processor_data(filename)
    proc_json = {
      PROCS => []
    }
    @@proc_list.each{ |p|
      proc_json[PROCS] << p.out_alldata
    }
    
    begin
      File.open(filename, "w"){|fp|
        fp.write JSON.pretty_generate(proc_json)
      }
      #pp JSON.pretty_generate(proc_json)
    rescue => e
      puts e.backtrace
      puts("proc file output error: #{filename} could not be created.\n")
      return 0
    end
    return proc_json[PROCS].size
  end

  # プロセッサの読み込み(JSON)
  # @param filename [String] ファイル名
  # @return [Fixnum] 読み込んだプロセッサ数を返す．失敗したらfalse
  def load_processor_data(filename)
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
        puts "processor file read error: #{filename} is not exist.\n"
        return false
      end
      
      data_clear  # 元のデータを削除し，新しいデータを格納
      procs = (JSON.parser.new(json)).parse()
      
      # プロセッサ毎の処理
      # @@proc_listに読み込んだタスクを追加
      procs[PROCS].each{|prc|
        #p prc
        proc = Processor.new(prc)
        @@proc_list << proc
      }
    else
      # JSONファイルでない場合
      puts "processor file read error: #{filename} is not JSON file.\n"
      return false
    end
    
    return @@proc_list.size
  end
  
  # プロセッサの作成
  # @param info [Hash] オプション
  # 個数はPROC_NUM
  def create_processor_list(info={ })
    1.upto(PROC_NUM){ |id|
      @@proc_list << Processor.new({ PROC_ID_SYN => id })
    }
    return @@proc_list.size
  end
  
  # 各プロセッサの使用率と割当てられているタスク数を表示
  def show_proc_info
    @@proc_list.each{ |p|
      puts "PE#{p.proc_id}(#{p.util}):#{p.task_list.size}tasks"
    }
  end

  # データの削除
  def data_clear
    @@proc_list = []
  end

  # ProcessorManagerにTaskManagerをもたせる
  # @param tm [TaskManager] タスクマネージャー
  def set_task_managet(tm)
    @@tm = tm
  end

  # プロセッサ内のタスクのソート
  def sort_tasks(mode)
    @@proc_list.each{ |proc|
      proc.sort_tasks(mode)
    }
  end

  # proc_listアクセサ
  def self.proc_list
    return @@proc_list
  end

  # 指定したIDのプロセッサを返す
  def self.get_proc(id)
    @@proc_list.each{ |proc|
      return proc if proc.proc_id == id
    }
  end

  # 全タスクで１番最悪応答時間が悪いタスクを返す
  def get_worst_wcrt
    wcrt = -1
    worst_t = nil
    @@proc_list.each{ |proc|
      proc.task_list.each{ |t|
        wcrt = t.wcrt if wcrt < t.wcrt
        worst_t = t
      }
    }
    return worst_t
  end
  ###############################################################
  #
  # 以下 private
  #
  ###############################################################
  private
  # タスクをランダムにプロセッサに割当てる
  # @param task_list [Array<Task>] 割当てるタスクのリスト
  def assign_random(task_list)
    task_list.each{ |t|
      proc_id = rand(@@proc_list.size)+1
      assign_task(proc_id, t)
    }
  end
  
  # タスクをtask_listの順番にプロセッサに割り当てる
  # task_listに入っている順番にプロセッサに配置(タスクIDは関係ない)
  def assign_list_order(task_list)
    proc_id = 0
    task_list.each{ |t|
      assign_task((proc_id%@@proc_list.size)+1, t)
      proc_id += 1
    }
  end

  # タスクをタスクIDの順にプロセッサに割り当てる
  def assign_id_order(task_list)
    proc_id = 0
    task_list.each{ |t|
      proc_id = ((t.task_id-1)%@@proc_list.size) + 1
      assign_task(proc_id, t)
    }
  end

  # CPU使用率が一番低いプロセッサIDを返す
  # @return id [Fixnum] プロセッサID
  def lowest_util_proc_id
    u = 10.0
    id = 0
    @@proc_list.each{ |p|
      if p.util < u
        u = p.util 
        id = p.proc_id
      end
    }
    return id 
  end

  # 指定したIDのプロセッサにタスクを割当てる
  # @param proc_id [Fixnum] プロセッサID
  # @param task [Task] タスク
  # @return assign_taskがtrueならtrue
  def assign_task(proc_id, task)
    return true if get_proc(proc_id).assign_task(task)
  end

  # 指定したプロセッサIDのプロセッサを得る
  # @param proc_id [Fixnum] プロセッサID
  # @return [Processor] プロセッサ．エラー時はnilを返す
  def get_proc(proc_id)
    @@proc_list.each{ |p|
      return p if p.proc_id == proc_id
    }
    return nil
  end
  
  # 全てのプロセッサの割り当てタスクを取り除く
  def init_all_proc
    @@proc_list.each{ |proc|
      proc.remove_task
    }
  end
  
  # プロセッサに割り当てられているタスクを取り除く
  # @param [Fixnum] プロセッサID
  def init_proc(proc_id)
    @@proc_list.select{ |p| p.proc_id == proc_id }[0].remove_task
  end
end
