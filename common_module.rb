# -*- coding: utf-8 -*-
require "json"

class IllegalClass < StandardError; end

# 1.8.7でもround関数を使う
class Float
  def round(d)
    ret_float = eval "sprintf \"%.#{d}f\", #{self}"
    return ret_float.to_f
  end
end


class Hash
  # ハッシュの保存
  # @param [String] filename ファイル名
  def self.save(hash, filename)
    open(filename, "w") do |fp|
      JSON.dump(hash, fp)
    end
  end

  # ハッシュの読み込み
  # @param [String] filename ファイル名
  # @return [Hash] 読み込んだハッシュデータ
  def self.load(filename)
    hash = { }
    open(filename, "r") do |fp|
      hash = JSON.load(fp.gets)
    end

    return hash
  end

  # ハッシュのkeyがstringの場合，symbolに変換する
  # @return [Hash] symbolに変換したハッシュ
  def to_sym
    new_hash = { }
    self.each do |k, v|
      new_hash[k.to_sym] = v if k.class = String
    end

    return new_hash
  end
  
  # ハッシュのkeyがstringの場合，symbolに変換する(破壊的メソッド)
  # @return [Hash] symbolに変換したハッシュ
  def to_sym!
    new_hash = { }
    self.each do |k, v|
      new_hash[k.to_sym] = v if k.class == String
    end

    return self.replace(new_hash)
  end


  class String 
    # StringをRangeに変換する
    # @return [Range] 変換したRangeオブジェクト 
    def to_rng
      return self.split('..').inject { |s,e| s.to_i..e.to_i }
    end

    # StringをRangeに変換する(破壊的メソッド)
    def to_rng!
      return self.replace(self.split('..').inject { |s,e| s.to_i..e.to_i })
    end
  end
end
