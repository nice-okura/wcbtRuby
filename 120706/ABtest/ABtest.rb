class TASK
	 @@res1 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 exc(4 * @@share1)
	 end
	 def task3
		 exc(3 * @@share1)
		 GetShortResource(@@res1)
		 exc(2.5)
		 ReleaseShortResource(@@res1)
	 end
	 @@share2 = 1.0
	 def task2
		 exc(1.9 * @@share2)
		 GetShortResource(@@res1)
		 exc(4)
		 ReleaseShortResource(@@res1)
		 exc(3.1 * @@share2)
	 end
end
