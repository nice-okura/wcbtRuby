class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 GetLongResource(@@res1)
		 exc(1)
		 ReleaseLongResource(@@res1)
		 exc(1 * @@share1)
	 end
	 def task2
		 exc(3 * @@share1)
	 end
	 @@share2 = 1.0
	 def task3
		 exc(5 * @@share2)
		 GetLongResource(@@res1)
		 exc(5)
		 ReleaseLongResource(@@res1)
		 exc(1 * @@share2)
	 end
end
