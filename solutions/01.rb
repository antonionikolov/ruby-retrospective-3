class Integer
  def prime?
    return false if self < 1
    (2..self / 2).all? { |i| self.remainder(i).nonzero? }
  end

  def prime_factors
    count, primes, number = 2, [], self
    until number.abs == 1
      primes << count if number.remainder(count).zero?
      number.remainder(count).zero? ? number /= count : count += 1
    end
    primes
  end

  def harmonic
    return if self <= 0
    Rational((1..self).inject { |sum, n| sum + Rational(1, n) })
  end

  def digits
    number, digits = abs, []
    until number == 0
      digits << number.remainder(10)
      number /= 10
    end
    digits.reverse
  end
end

class Array
  def frequencies
    element_frequency = {}
    each { |i| element_frequency[i] = count(i) if element_frequency[i] == nil }
    element_frequency
  end

  def average
    sum = 0.0
    each { |i| sum += i }
    sum / size
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