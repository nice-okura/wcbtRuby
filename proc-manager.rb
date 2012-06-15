require "pp"

# プロセッサマネージャーの定義
class ProcessorManager
  include Singleton
  
  ###############################################################
  #
  # 以下 prublic
  #
  ###############################################################
  public 
  def initialize
    @@proc_id = 0
    @@proc_list = []
  end

  # プロセッサ情報の保存(JSON)
  # 書き込んだプロセッサ数を返す．失敗したら0
  def save_processor_data(filename)
    proc_json = {
      :procs => []
    }
    @@proc_list.each{ |p|
      proc_json[:procs] << p.out_alldata
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
    return proc_json[:procs].size
  end

  # プロセッサの読み込み(JSON)
  # 読み込んだプロセッサ数を返す．失敗したら0
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
        return 0
      end
      
      data_clear  # 元のデータを削除し，新しいデータを格納
      procs = (JSON.parser.new(json)).parse()
      
      #
      # プロセッサ事の処理
      # @@proc_listに読み込んだタスクを追加
      #
      grps[:procs].each{|proc|
        p = Processor.new(proc)
        @@proc_list << p        
      }
    else
      # 
      # JSONファイルでない場合
      #
      puts "processor file read error: #{filename} is not JSON file.\n"
      return false
    end
    
    return @@group_array.size
  end
  
  # プロセッサの作成
  # 個数はPROC_NUM
  def create_processor_list(info={ })
    1.upto(PROC_NUM){ |id|
      @@proc_list << Processor.new({ :id => id })
    }
    return @@proc_list.size
  end
  
  # CPU使用率が一番低いプロセッサIDを返す
  def lowest_util_proc_id
    u = 10.0
    id = 0
    @proc_list.each{ |p|
      if p.util < u
        u = p.util 
        id = p.proc_id
      end
    }
    return id 
  end


  # 各プロセッサの使用率と割当てられているタスク数を表示
  def show_proc_info
    @@proc_list.each{ |p|
      puts "PE#{p.proc_id}(#{p.util}):#{p.task_list.size}tasks"
    }
  end

  # データの削除
  def data_clear
    @proc_list = []
  end

  ###############################################################
  #
  # 以下 private
  #
  ###############################################################
  private
end
