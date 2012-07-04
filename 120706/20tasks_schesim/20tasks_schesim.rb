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
	 def task6
		 exc(10 * @@share1)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(0 * @@share1)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(1 * @@share1)
	 end
	 def task11
		 exc(6 * @@share1)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(3 * @@share1)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(0 * @@share1)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(2 * @@share1)
	 end
	 def task13
		 exc(2 * @@share1)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(0 * @@share1)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(1 * @@share1)
	 end
	 def task15
		 exc(1 * @@share1)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(3 * @@share1)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(1 * @@share1)
	 end
	 @@share2 = 1.0
	 def task8
		 exc(0 * @@share2)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(0 * @@share2)
	 end
	 def task10
		 exc(2 * @@share2)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(2 * @@share2)
	 end
	 def task14
		 exc(11 * @@share2)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(0 * @@share2)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(1 * @@share2)
	 end
	 def task18
		 exc(10 * @@share2)
	 end
	 def task20
		 exc(1 * @@share2)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(4 * @@share2)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(4 * @@share2)
	 end
	 @@share3 = 1.0
	 def task2
		 exc(2 * @@share3)
	 end
	 def task3
		 exc(1 * @@share3)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(4 * @@share3)
	 end
	 def task9
		 exc(5 * @@share3)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(0 * @@share3)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(1 * @@share3)
	 end
	 def task17
		 exc(0 * @@share3)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(4 * @@share3)
	 end
	 @@share4 = 1.0
	 def task1
		 exc(2 * @@share4)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(4 * @@share4)
	 end
	 def task19
		 exc(0 * @@share4)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(1 * @@share4)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(2 * @@share4)
	 end
	 @@share5 = 1.0
	 def task4
		 exc(3 * @@share5)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(0 * @@share5)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(3 * @@share5)
	 end
	 def task7
		 exc(3 * @@share5)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(0 * @@share5)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(3 * @@share5)
	 end
	 @@share6 = 1.0
	 def task5
		 exc(0 * @@share6)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(0 * @@share6)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(0 * @@share6)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(1 * @@share6)
	 end
	 def task12
		 exc(11 * @@share6)
	 end
	 def task16
		 exc(5 * @@share6)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(1 * @@share6)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(3 * @@share6)
	 end
end
