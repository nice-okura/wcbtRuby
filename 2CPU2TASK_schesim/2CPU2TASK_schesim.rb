class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = LONG_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 GetLongResource(@@res1)
		 exc(1)
		 ReleaseLongResource(@@res1)
	 end
	 def task2
		 exc(1 * @@share1)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
	 end
	 def task3
		 exc(1 * @@share1)
		 GetLongResource(@@res2)
		 exc(2)
		 ReleaseLongResource(@@res2)
	 end
	 @@share2 = 1.0
	 def task4
		 exc(2 * @@share2)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
	 end
end
