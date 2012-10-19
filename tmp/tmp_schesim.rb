class TASK
	 @@res1 = LONG_RESOURCE.new
	 @@res2 = SHORT_RESOURCE.new
	 @@res3 = LONG_RESOURCE.new
	 @@res4 = SHORT_RESOURCE.new
	 @@res5 = LONG_RESOURCE.new
	 @@res6 = SHORT_RESOURCE.new
	 @@res7 = LONG_RESOURCE.new
	 @@res8 = SHORT_RESOURCE.new
	 @@share1 = 1.0
	 def task1
		 exc(31.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(4.0 * @@share1)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(38.0 * @@share1)
	 end
	 def task3
		 exc(70.0 * @@share1)
		 GetLongResource(@@res7)
		 exc(4)
		 ReleaseLongResource(@@res7)
		 exc(4.0 * @@share1)
		 GetLongResource(@@res5)
		 exc(4)
		 ReleaseLongResource(@@res5)
		 exc(17.0 * @@share1)
	 end
	 def task5
		 exc(36.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(35.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(6.0 * @@share1)
	 end
	 def task7
		 exc(25.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(52.0 * @@share1)
	 end
	 def task9
		 exc(13.0 * @@share1)
		 GetShortResource(@@res8)
		 exc(4)
		 ReleaseShortResource(@@res8)
		 exc(29.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(41.0 * @@share1)
	 end
	 def task11
		 exc(59.0 * @@share1)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(22.0 * @@share1)
		 GetShortResource(@@res8)
		 exc(4)
		 ReleaseShortResource(@@res8)
		 exc(10.0 * @@share1)
	 end
	 def task13
		 exc(28.0 * @@share1)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res4)
		 exc(6.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(50.0 * @@share1)
	 end
	 def task15
		 exc(44.0 * @@share1)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(7.0 * @@share1)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(33.0 * @@share1)
	 end
	 @@share2 = 1.0
	 def task2
		 exc(16.0 * @@share2)
		 GetShortResource(@@res6)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(37.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(4.0 * @@share2)
	 end
	 def task4
		 exc(38.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(10.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(7.0 * @@share2)
	 end
	 def task6
		 exc(26.0 * @@share2)
		 GetShortResource(@@res8)
		 exc(4)
		 ReleaseShortResource(@@res8)
		 exc(15.0 * @@share2)
		 GetLongResource(@@res7)
		 exc(3)
		 ReleaseLongResource(@@res7)
		 exc(16.0 * @@share2)
	 end
	 def task8
		 exc(68.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(1.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(4.0 * @@share2)
	 end
	 def task10
		 exc(48.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(13.0 * @@share2)
		 GetShortResource(@@res8)
		 exc(3)
		 ReleaseShortResource(@@res8)
		 exc(23.0 * @@share2)
	 end
	 def task12
		 exc(76.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(3)
		 ReleaseShortResource(@@res4)
		 exc(7.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(5.0 * @@share2)
	 end
	 def task14
		 exc(23.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(6.0 * @@share2)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(48.0 * @@share2)
	 end
	 def task16
		 exc(16.0 * @@share2)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(15.0 * @@share2)
		 GetShortResource(@@res8)
		 exc(3)
		 ReleaseShortResource(@@res8)
		 exc(20.0 * @@share2)
	 end
end
