class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task5
		 exc(48.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(5)
		 ReleaseLongResource(@@res1)
		 exc(4.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(7)
		 ReleaseLongResource(@@res1)
		 exc(5.0 * @@share1)
	 end
	 def task3
		 exc(34.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(56.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(46.0 * @@share1)
	 end
	 def task1
		 exc(95.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(6)
		 ReleaseShortResource(@@res2)
		 exc(31.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(8)
		 ReleaseLongResource(@@res3)
		 exc(6.0 * @@share1)
	 end
	 def task7
		 exc(41.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(18.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(8)
		 ReleaseLongResource(@@res3)
		 exc(85.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task2
		 exc(7.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(6)
		 ReleaseLongResource(@@res1)
		 exc(27.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(57.0 * @@share2)
	 end
	 def task8
		 exc(112.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(6)
		 ReleaseShortResource(@@res4)
		 exc(10.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(6)
		 ReleaseLongResource(@@res1)
		 exc(1.0 * @@share2)
	 end
	 def task4
		 GetShortResource(@@res2)
		 exc(8)
		 ReleaseShortResource(@@res2)
		 exc(33.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(5)
		 ReleaseShortResource(@@res2)
		 exc(97.0 * @@share2)
	 end
	 def task6
		 exc(76.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(37.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(8)
		 ReleaseShortResource(@@res2)
		 exc(19.0 * @@share2)
	 end
end
