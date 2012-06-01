#! /usr/bin/ruby
# -*- coding: utf-8 -*-
#
#= EDF用FMLP最大ブロック時間計算用モジュール
#== A flexible real-time locking protocol for multiprocessors
#
#Author:: Takahiro FUJITANI (ERTL, Nagoya Univ.)
#Version:: 0.1.0
#License:: 
#
# 
$:.unshift(File.dirname(__FILE__))
require "rubygems"
require "term/ansicolor"
require "config"
#require "ruby-prof"

class String
  include Term::ANSIColor
end

module WCBT
  #
  # ブロック時間を計算し，格納
  #
  def set_blocktime
    $taskList.each{ |t|
      t.bw = BW(t)
      t.npb = NPB(t)
      t.db = DB(t)
      t.b = t.bw + t.npb + t.db
    }
  end
  
  #
  # 集合sのmin(n, |s|)番目までの要素の和を返す関数
  # @param [Fixnum, Array]
  # @return [Fixnum]
  #
  def msum(n, s)
    msum = 0
    max = [n, s.size].min - 1
    0.upto(max){|i|
      msum += s[i].time
    }
    return msum
  end

  #
  # jobがreq発行から完了までにspinする時間
  # @param [Task, Require] reqs:はjob以外のジョブが発行したグループgに対する最長リソース要求の長さの集合
  # @return [Fixnum]
  #
  def spin(job, req)
    m = PROC_NUM
    s = get_Rset_for_spin(job, req.res.group)
    return msum(m-1, s) unless s == []
    return 0
  end

  #
  # job以外のジョブが発行するグループgへの要求の最大長のものの集合を求める
  # @param [Task, Group]
  # @return [Fixnum]
  #
  def get_Rset_for_spin(job, g)
    reqlist = []
    $taskList.each{ |t|
      next if t.proc == job.proc
      tmp_reqlist = []
      t.req_list.each{ |req|
        tmp_reqlist << req if req.res.group == g
      }
      if tmp_reqlist.size > 1
        # タスクtのグループgへの要求の中で一番長いものを抽出する
        reqlist << tmp_reqlist.sort{ |a, b|
          -1 * (a.time <=> b.time)
        }[0]        
      else
        reqlist += tmp_reqlist
      end
    }
    return reqlist
  end
  #
  #
  #
  def BW(t)
    bw = 0
    t.get_short_require_array.each{ |req|
      bw += spin(t, req)
    }
    
    return bw
  end
  
  #
  #
  #
  def NPB(t)
    npb = 0
    return npb
  end
  
  #
  #
  #
  def DB(t)
    db = 0
    return db
  end
end
