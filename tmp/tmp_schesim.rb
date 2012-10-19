class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 exc(4.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(11.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(30.0 * @@share1)
	 end
	 def task3
		 exc(59.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(9.0 * @@share1)
	 end
	 def task5
		 exc(47.0 * @@share1)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(7.0 * @@share1)
		 GetShortResource(@@res4)
		 exc(4)
		 ReleaseShortResource(@@res4)
		 exc(28.0 * @@share1)
	 end
	 def task7
		 exc(45.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(19.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(14.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task2
		 exc(10.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(34.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(4)
		 ReleaseShortResource(@@res4)
		 exc(4.0 * @@share2)
	 end
	 def task4
		 exc(33.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(27.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(1.0 * @@share2)
	 end
	 def task6
		 exc(33.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(4)
		 ReleaseShortResource(@@res4)
		 exc(11.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(21.0 * @@share2)
	 end
	 def task8
		 exc(3.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(71.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(7.0 * @@share2)
	 end
end
