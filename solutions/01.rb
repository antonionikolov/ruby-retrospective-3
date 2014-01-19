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
    remaining_elements = []
    each_with_index do |item, i|
      remaining_elements << item if (i + 1).remainder(n).nonzero?
    end
    remaining_elements
  end

  def combine_with(other)
    short = if size <= other.size then size else other.size end
    both = []
    (0..short - 1).each { |i| both << self[i] & both << other[i] }
    (short..other.size - 1).each { |i| both << other[i] } if short < other.size
    (short..size - 1).each { |i| both << self[i] } if short < size
    both
  end
end