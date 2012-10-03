#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# A Comparison of the M-PCP, D-PCP, and FMLP on LITMUSRT のスケジューラビリティを真似てみました
#
#
# 3 Experiments
# A task system is *schedulable* if it can be verified via some test that no task will ever miss a deadline
# Schedulable: デッドラインミスするタスクのないことが保証されたタスクシステム
# 
# タスク使用率: [0.001, 0.1] の一様分布
# 周期:
#  (i): [3ms, 33ms]
# (ii): [10ms, 100ms]
#(iii): [33ms, 100ms]
# (iv): [100ms, 1000ms]
# 実行時間: 使用率，周期から計算
# 
proc_num = 4
