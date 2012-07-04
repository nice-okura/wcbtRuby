class TASK
	 @@res1 = SHORT_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@res5 = SHORT_RESOURCE.new
	 @@res6 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task5
		 exc(50 * @@share1)
		 GetShortResource(@@res4)
		 exc(0.8)
		 ReleaseShortResource(@@res4)
		 exc(29.2 * @@share1)
	 end
	 def task1
		 exc(71 * @@share1)
		 GetLongResource(@@res3)
		 exc(0.8)
		 ReleaseLongResource(@@res3)
		 exc(8.2 * @@share1)
	 end
	 def task9
		 exc(58 * @@share1)
		 GetShortResource(@@res6)
		 exc(0.8)
		 ReleaseShortResource(@@res6)
		 exc(21.2 * @@share1)
	 end
	 @@share2 = 1.0
	 def task10
		 exc(20 * @@share2)
		 GetShortResource(@@res1)
		 exc(8.0)
		 ReleaseShortResource(@@res1)
		 exc(52.0 * @@share2)
	 end
	 def task2
		 exc(12 * @@share2)
		 GetLongResource(@@res3)
		 exc(0.8)
		 ReleaseLongResource(@@res3)
		 exc(67.2 * @@share2)
	 end
	 def task6
		 exc(52 * @@share2)
		 GetShortResource(@@res5)
		 exc(0.8)
		 ReleaseShortResource(@@res5)
		 exc(27.2 * @@share2)
	 end
	 @@share3 = 1.0
	 def task3
		 exc(53 * @@share3)
		 GetShortResource(@@res2)
		 exc(0.8)
		 ReleaseShortResource(@@res2)
		 exc(26.2 * @@share3)
	 end
	 def task7
		 exc(58 * @@share3)
		 GetShortResource(@@res6)
		 exc(0.8)
		 ReleaseShortResource(@@res6)
		 exc(21.2 * @@share3)
	 end
	 def task11
		 exc(53 * @@share3)
		 GetShortResource(@@res4)
		 exc(0.8)
		 ReleaseShortResource(@@res4)
		 exc(26.2 * @@share3)
	 end
	 @@share4 = 1.0
	 def task8
		 exc(8 * @@share4)
		 GetShortResource(@@res5)
		 exc(0.8)
		 ReleaseShortResource(@@res5)
		 exc(71.2 * @@share4)
	 end
	 def task4
		 exc(20 * @@share4)
		 GetShortResource(@@res1)
		 exc(8.0)
		 ReleaseShortResource(@@res1)
		 exc(52.0 * @@share4)
	 end
	 def task12
		 exc(43 * @@share4)
		 GetShortResource(@@res2)
		 exc(0.8)
		 ReleaseShortResource(@@res2)
		 exc(36.2 * @@share4)
	 end
end
