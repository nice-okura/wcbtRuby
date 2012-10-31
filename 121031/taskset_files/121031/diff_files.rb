file1 = ARGV[0]
file2 = ARGV[1]

file1_array = { }
file2_array = { }

File.open(file1, "r") do |f|
  while l = f.gets
    l = l.split(' ')
    file1_array[l[0].to_i] = l[1].to_f
  end
end

File.open(file2, "r") do |f|
  while l = f.gets
    l = l.split(' ')
    file2_array[l[0].to_i] = l[1].to_f
  end
end

result = { }
0.upto(99) do |i|
  result[i] = file1_array[i] - file2_array[i]
end
File.open("rt_ave_diff.txt", "w") do |f|
  0.upto(99) do |i|
    f.puts "#{i} #{result[i]}"
  end
end
