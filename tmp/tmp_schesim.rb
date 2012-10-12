class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task5
		 exc(70.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(7)
		 ReleaseLongResource(@@res3)
		 GetLongResource(@@res1)
		 exc(8)
		 ReleaseLongResource(@@res1)
		 exc(1.0 * @@share1)
	 end
	 def task3
		 exc(6.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(6)
		 ReleaseLongResource(@@res3)
		 exc(58.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(9)
		 ReleaseLongResource(@@res1)
		 exc(31.0 * @@share1)
	 end
	 def task1
		 exc(33.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(78.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(7)
		 ReleaseLongResource(@@res3)
		 exc(22.0 * @@share1)
	 end
	 def task7
		 exc(16.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(5)
		 ReleaseShortResource(@@res2)
		 exc(82.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(9)
		 ReleaseShortResource(@@res2)
		 exc(60.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task4
		 exc(52.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(7)
		 ReleaseLongResource(@@res3)
		 exc(8.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(5)
		 ReleaseShortResource(@@res2)
		 exc(9.0 * @@share2)
	 end
	 def task8
		 exc(24.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(9)
		 ReleaseLongResource(@@res1)
		 exc(9.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(8)
		 ReleaseLongResource(@@res1)
		 exc(40.0 * @@share2)
	 end
	 def task6
		 exc(174.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(5)
		 ReleaseShortResource(@@res2)
		 exc(1.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(9)
		 ReleaseLongResource(@@res1)
		 exc(1.0 * @@share2)
	 end
	 def task2
		 exc(160.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(7)
		 ReleaseLongResource(@@res3)
		 exc(8.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(5)
		 ReleaseShortResource(@@res2)
		 exc(16.0 * @@share2)
	 end
end
