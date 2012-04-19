#!/usr/bin/ruby

GROUPS_COUNT = 4 # 1, 2, 4, 8 の4つ

def datas_sort!(datas)
  datas.sort!{|a, b|
    res = a[3].to_f <=> b[3].to_f
    if res == 0
    res = a[0].to_i <=> b[0].to_i
      if res == 0
        a[2].to_i <=> b[2].to_i
      else
        res
      end
    else
      res
    end
  }

  return true
end

#
# main
#
filename = ARGV[0]
datas = []
File.open(filename, "r"){|fp|
  while l = fp.gets
    data = l.scan(/TASKS:(.*)\sCPUs:(.*)\sGROUPS:(.*)\sRCSL:(.*)\s\]long_count:(.*)/)[0]
    datas << data unless data == nil
  end
}

datas_sort!(datas)

new_datas = []
0.step(datas.size-1, 4){ |i|
  data = datas[i] + [datas[i+1][4]] + [datas[i+2][4]] + [datas[i+3][4]]
  new_datas << data
}

new_datas.sort!{ |a, b|
  res = a[0].to_i <=> b[0].to_i
  if res == 0
    a[3].to_f <=> b[3].to_f
  else
    res
  end
}

for num in [8, 12, 16]
  File.open("pltdata_#{filename}_#{num}tasks.dat", "w"){|fp|
    10.times{ 
      data = new_datas[0]
      p data
      fp.puts "#{data[3].to_f} #{data[4].to_f} #{data[5].to_f} #{data[6].to_f} #{data[7].to_f}" unless data == nil
      new_datas.delete_at(0)
    }
  }
  puts "write pltdata_#{filename}_#{num}tasks.dat"
end
