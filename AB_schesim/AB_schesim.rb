class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 exc(4.5 * @@share1)
		 GetLongResource(@@res1)
		 exc(1.5)
		 ReleaseLongResource(@@res1)
	 end
	 def task2
		 exc(0.5 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(0.5 * @@share1)
		 GetShortResource(@@res2)
		 exc(1)
		 ReleaseShortResource(@@res2)
		 exc(2.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task3
		 GetShortResource(@@res2)
		 exc(2.5)
		 ReleaseShortResource(@@res2)
		 exc(6.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(2.5)
		 ReleaseShortResource(@@res2)
		 exc(2.0 * @@share2)
	 end
	 @@share3 = 1.0
	 def task4
		 exc(6 * @@share3)
		 GetLongResource(@@res1)
		 exc(2.5)
		 ReleaseLongResource(@@res1)
		 exc(1.5 * @@share3)
	 end
end
