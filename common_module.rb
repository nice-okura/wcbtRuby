# -*- coding: utf-8 -*-
class IllegalClass < StandardError; end

# 1.8.7でもround関数を使う
class Float
  def round(d)
    ret_float = eval "sprintf \"%.#{d}f\", #{self}"
    return ret_float.to_f
  end
end
