# -*- coding: utf-8 -*-
require "manager"
require "test/unit"
require "task-CUI"
require "util"

include UTIL

class Test_taskCUI < Test::Unit::TestCase
  def setup

  end
  def test_check_highest_priority
    @manager = AllManager.new

    @manager.load_tasks("../120620/json/tasksets_for_priority/T8G4_LSSS_98")
    p check_highest_priority(@manager.tm.get_task_array)
  end
end
