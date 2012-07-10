class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 exc(2.1 * @@share1)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(5.9 * @@share1)
	 end
	 @@share2 = 1.0
	 def task2
		 exc(2 * @@share2)
		 GetLongResource(@@res1)
		 exc(4)
		 ReleaseLongResource(@@res1)
		 exc(4 * @@share2)
	 end
	 def task3
		 exc(3 * @@share2)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(8 * @@share2)
	 end
	 @@share3 = 1.0
	 def task4
		 exc(1.9 * @@share3)
		 GetLongResource(@@res1)
		 exc(4)
		 ReleaseLongResource(@@res1)
		 exc(3.1 * @@share3)
	 end
	 @@share4 = 1.0
end
