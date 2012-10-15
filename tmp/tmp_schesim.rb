class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task7
		 exc(34.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(6)
		 ReleaseLongResource(@@res1)
		 exc(3.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(6)
		 ReleaseLongResource(@@res3)
		 exc(1.0 * @@share1)
	 end
	 def task1
		 exc(34.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(9)
		 ReleaseShortResource(@@res2)
		 GetLongResource(@@res1)
		 exc(7)
		 ReleaseLongResource(@@res1)
		 exc(2.0 * @@share1)
	 end
	 def task5
		 exc(34.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(6)
		 ReleaseLongResource(@@res3)
		 exc(30.0 * @@share1)
		 GetShortResource(@@res4)
		 exc(5)
		 ReleaseShortResource(@@res4)
		 exc(11.0 * @@share1)
	 end
	 def task3
		 exc(16.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(6)
		 ReleaseLongResource(@@res3)
		 exc(35.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(30.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task8
		 exc(32.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(6)
		 ReleaseLongResource(@@res1)
		 exc(5.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(6)
		 ReleaseLongResource(@@res3)
		 exc(13.0 * @@share2)
	 end
	 def task6
		 exc(56.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(7)
		 ReleaseLongResource(@@res1)
		 exc(2.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(7)
		 ReleaseLongResource(@@res1)
		 exc(2.0 * @@share2)
	 end
	 def task2
		 exc(20.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(6)
		 ReleaseLongResource(@@res3)
		 exc(34.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(6)
		 ReleaseLongResource(@@res1)
		 exc(8.0 * @@share2)
	 end
	 def task4
		 exc(69.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(9)
		 ReleaseShortResource(@@res4)
		 exc(2.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(5)
		 ReleaseLongResource(@@res3)
		 exc(13.0 * @@share2)
	 end
end
