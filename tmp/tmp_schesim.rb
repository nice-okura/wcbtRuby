class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task7
		 exc(28.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(5.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(21.0 * @@share1)
	 end
	 def task5
		 exc(19.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(15.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(26.0 * @@share1)
	 end
	 def task1
		 exc(21.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(8.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(18.0 * @@share1)
	 end
	 def task3
		 exc(18.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(34.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(27.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task8
		 exc(29.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(3)
		 ReleaseLongResource(@@res1)
		 exc(23.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(3)
		 ReleaseLongResource(@@res1)
		 exc(4.0 * @@share2)
	 end
	 def task6
		 exc(37.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(3.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(42.0 * @@share2)
	 end
	 def task4
		 exc(54.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(3)
		 ReleaseShortResource(@@res4)
		 exc(8.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(26.0 * @@share2)
	 end
	 def task2
		 exc(20.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(48.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(4)
		 ReleaseLongResource(@@res1)
		 exc(2.0 * @@share2)
	 end
end
