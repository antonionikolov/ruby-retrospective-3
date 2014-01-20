class Integer
  def prime?
    return false if self < 2
    2.upto(self / 2).all? { |divisor| remainder(divisor).nonzero? }
  end

  def prime_factors
    return [] if self == 1
    new_divisor = 2.upto(abs).find { |x| remainder(x).zero? }
    [new_divisor] + (abs / new_divisor).prime_factors
  end

  def harmonic
    (1..self).reduce { |sum, n| sum + Rational(1, n) } if self > 0
  end

  def digits
    abs.to_s.split('').map(&:to_i)
  end
end

class Array
  def frequencies
    Hash[map { |element| [element, count(element)] }]
  end

  def average
    reduce(:+) / length.to_f unless empty?
  end

  def drop_every(n)
    each_slice(n).flat_map { |sliced| sliced.take(n - 1) }
  end

  def combine_with(other)
    short, long  = length <= other.length ? [self, other] : [other, self]

    both = []
    (0...short.length).each { |i| both << self[i] << other[i] }
    (short.length..long.length - 1).each { |i| both << long[i] }
    both
  end
end