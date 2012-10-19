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
		 exc(1.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(10.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseShortResource(@@res2)
		 exc(37.0 * @@share1)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(38.0 * @@share1)
	 end
	 def task3
		 exc(38.0 * @@share1)
		 GetLongResource(@@res7)
		 exc(4)
		 ReleaseLongResource(@@res7)
		 exc(4.0 * @@share1)
		 GetLongResource(@@res5)
		 exc(4)
		 ReleaseLongResource(@@res5)
	 end
	 def task5
		 exc(36.0 * @@share1)
		 GetLongResource(@@res1)
		 exc(2)
		 ReleaseLongResource(@@res1)
		 exc(35.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(4.0 * @@share1)
	 end
	 def task7
		 exc(8.0 * @@share1)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(27.0 * @@share1)
		 exc(2)
		 exc(3)
		 exc(52.0 * @@share1)
		 exc(32.0 * @@share1)
	 end
	 def task9
		 exc(39.0 * @@share1)
		 GetShortResource(@@res8)
		 exc(4)
		 ReleaseShortResource(@@res8)
		 exc(29.0 * @@share1)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(23.0 * @@share1)
		 GetShortResource(@@res4)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(22.0 * @@share1)
		 GetShortResource(@@res8)
		 ReleaseShortResource(@@res8)
		 exc(10.0 * @@share1)
	 end
	 def task13
		 exc(28.0 * @@share1)
		 GetShortResource(@@res4)
		 exc(2)
		 exc(17.0 * @@share1)
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
		 exc(42.0 * @@share2)
		 GetShortResource(@@res4)
		 exc(3)
		 ReleaseShortResource(@@res4)
		 exc(4.0 * @@share2)
		 exc(4)
		 ReleaseShortResource(@@res6)
		 exc(6.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
		 exc(4.0 * @@share2)
	 end
	 def task4
		 exc(12.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(2)
		 ReleaseShortResource(@@res2)
		 exc(13.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(3)
		 ReleaseLongResource(@@res3)
		 exc(61.0 * @@share2)
	 end
	 def task6
		 exc(34.0 * @@share2)
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
		 exc(45.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(4)
		 ReleaseLongResource(@@res3)
	 end
	 def task14
		 exc(23.0 * @@share2)
		 GetShortResource(@@res2)
		 exc(3)
		 exc(10.0 * @@share2)
		 GetShortResource(@@res6)
		 exc(2)
		 ReleaseShortResource(@@res6)
		 exc(48.0 * @@share2)
	 end
	 def task16
		 exc(52.0 * @@share2)
		 exc(18.0 * @@share2)
		 GetShortResource(@@res8)
		 exc(3)
		 ReleaseShortResource(@@res8)
		 exc(11.0 * @@share2)
		 GetLongResource(@@res3)
		 exc(2)
		 ReleaseLongResource(@@res3)
		 exc(7.0 * @@share2)
	 end
end
