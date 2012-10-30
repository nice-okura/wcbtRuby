class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 exc(21.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(6.7)
		 ReleaseLongResource(@@res1)
		 exc(8.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(6.7)
		 ReleaseShortResource(@@res2)
		 exc(24.6 * @@share1)
	 end
	 def task3
		 exc(40.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(6.7)
		 ReleaseLongResource(@@res1)
		 exc(6.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(6.7)
		 ReleaseLongResource(@@res1)
		 exc(7.59999999999999 * @@share1)
	 end
	 @@share2 = 1.0
	 def task2
		 exc(23.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(6.7)
		 ReleaseShortResource(@@res2)
		 exc(21.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(6.7)
		 ReleaseShortResource(@@res2)
		 exc(9.59999999999999 * @@share2)
	 end
	 def task4
		 exc(11.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(6.7)
		 ReleaseLongResource(@@res1)
		 exc(41.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(6.7)
		 ReleaseLongResource(@@res1)
		 exc(1.59999999999999 * @@share2)
	 end
end
