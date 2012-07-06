class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@res5 = LONG_RESOURCE.new
	 @@share1 = 1.0
	 def task4
		 exc(1 * @@share1)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(3 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(5 * @@share1)
	 end
	 def task7
		 exc(2 * @@share1)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share1)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(0 * @@share1)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(1 * @@share1)
	 end
	 @@share2 = 1.0
	 def task8
		 exc(4 * @@share2)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(12 * @@share2)
	 end
	 @@share3 = 1.0
	 def task2
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share3)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
	 end
	 def task5
		 exc(1 * @@share3)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(0 * @@share3)
		 GetLongResource(@@res5)
		 exc(2)
		 ReleaseLongResource(@@res5)
		 exc(0 * @@share3)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(1 * @@share3)
	 end
	 @@share4 = 1.0
	 def task1
		 exc(3 * @@share4)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(1 * @@share4)
	 end
	 def task3
		 exc(5 * @@share4)
		 GetShortResource(@@res2)
		 exc(4)
		 ReleaseShortResource(@@res2)
		 exc(10 * @@share4)
	 end
	 def task6
		 exc(0 * @@share4)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(0 * @@share4)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(0 * @@share4)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(3 * @@share4)
	 end
end
