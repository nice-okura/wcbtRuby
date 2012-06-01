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
    for i in 0..max
      msum += s[i]
    end
    return msum
  end

  #
  # jobがreq発行から完了までにspinする時間
  # @param [Task, Require] reqs:はjob以外のジョブが発行したグループgに対する最長リソース要求の長さの集合
  # @return [Fixnum]
  #
  def spin(job, reqs)
    m = PROC_NUM
    return msum(m-1, reqs)
  end

  
  
end
