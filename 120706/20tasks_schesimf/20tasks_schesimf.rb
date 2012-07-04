class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@res5 = LONG_RESOURCE.new
	 @@res6 = SHORT_RESOURCE.new
	 @@res7 = LONG_RESOURCE.new
	 @@res8 = SHORT_RESOURCE.new
	 @@res9 = LONG_RESOURCE.new
	 @@res10 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task4
		 exc(6 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(8 * @@share1)
	 end
	 def task6
		 exc(6 * @@share1)
	 end
	 def task7
		 exc(11 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share1)
	 end
	 def task8
		 exc(0 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share1)
	 end
	 def task12
		 exc(6 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(0 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(2 * @@share1)
	 end
	 def task16
		 exc(1 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share1)
	 end
	 def task20
		 exc(2 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(0 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(1 * @@share1)
	 end
	 @@share2 = 1.0
	 def task1
		 exc(0 * @@share2)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(5 * @@share2)
	 end
	 def task3
		 exc(1 * @@share2)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(1 * @@share2)
	 end
	 def task10
		 exc(2 * @@share2)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(1 * @@share2)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(3 * @@share2)
	 end
	 def task11
		 exc(1 * @@share2)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share2)
	 end
	 def task13
		 exc(1 * @@share2)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(0 * @@share2)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(1 * @@share2)
	 end
	 @@share3 = 1.0
	 def task2
		 exc(1 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(2 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(4 * @@share3)
	 end
	 def task9
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share3)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(2 * @@share3)
	 end
	 def task14
		 exc(1 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(2 * @@share3)
	 end
	 def task15
		 exc(14 * @@share3)
	 end
	 def task19
		 exc(2 * @@share3)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(5 * @@share3)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share3)
	 end
	 @@share4 = 1.0
	 def task5
		 exc(0 * @@share4)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(14 * @@share4)
	 end
	 def task17
		 exc(4 * @@share4)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(3 * @@share4)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share4)
	 end
	 def task18
		 exc(5 * @@share4)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(4 * @@share4)
	 end
end
