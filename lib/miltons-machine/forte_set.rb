
# == Class: Forte Set
#
# An extention to the basic Array class of Ruby to allow for modulus 12 operations and transformations
# for musical set theoretics.
#
# @example  create and transpose a set
#
#   major_set = ForteSet.new([0, 4, 7])
#   major_set.transpose_set!(3)
#   puts major_set     <-- should print out [3, 7, 10]
#
#

class ForteSet < Array

  # Returns a copy of the set at a new transposition
  #
  # @param [Integer] number_to_transpose number of half steps between 0 - 11
  # @return [Array] a copy of the set transposed to the new Tn
  #

  def transpose_set( number_to_transpose = 0 )
    return_set = self.clone
    return_set.collect! { |pc| pc = transpose_pitch_class(pc, number_to_transpose) }
  end

  # Transposes the set in place and returns a reference to the set at the new transposition
  #
  # @param [Integer] number_to_transpose number of half steps between 0 - 11
  # @return [Array] a reference to the set (not a shallow copy)
  #

  def transpose_set!( number_to_transpose = 0 )
    self.collect! { |pc| pc = transpose_pitch_class(pc, number_to_transpose) }
  end

  # Return the inversion of this set
  #
  # @return [Array] a copy of the set inverted
  #

  def invert_set
    return_set = self.clone
    return_set.collect! { |pc| pc = invert_pitch_class(pc) }
  end

  # Invert the set in place and return a reference
  #
  # @return [Array] a reference to the inverted set
  #

  def invert_set!
    self.collect! { |pc| pc = invert_pitch_class(pc) }
  end

  # Return the complement of this set
  #
  # @return [Array] the complement set
  #

  def complement_set
    Array.new(12) { |i| i }  - self
  end

  # Return a copy of the set with all elements transposed so that the first element is set to zero.
  #
  # @return [Array] the zero transposed set
  #

  def zero_set
    number_to_transpose = 0
    self[0] == 0 ? number_to_transpose = 0 :  number_to_transpose = 12 - self[0]
    self.transpose_set(number_to_transpose)
  end

  # Zero the set in place, so that all element transposed so that the first element is set to zero. Return a reference
  # to the result.
  #
  # @return [Array] a copy of the zero transposed set
  #

  def zero_set!
    number_to_transpose = 0
    self[0] == 0 ? number_to_transpose = 0 :  number_to_transpose = 12 - self[0]
    self.transpose_set!(number_to_transpose)
  end

  # Returns the most compact order of a set
  #
  # @return [Array] a copy of the set normalized
  #

  def normalize_set
    winner = self.clone

    winner.sort!
    winner.reverse!
    working_set = winner.clone

    # Pick the best winner out of the lot of permutations
    0.upto(winner.length - 2 ) do
      winner = winner.compare_compact_sets( working_set.rotate!(1) )
     end

    winner.reverse!
  end

  # Normalizes the set in place and returns a reference to the set
  #
  # @return [Array] a reference to the normalized set
  #

  def normalize_set!
    self.sort!
    self.reverse!
    working_set = self.clone

    # Pick the best winner out of the lot of permutations
    0.upto(self.length - 2 ) do
      self = self.compare_compact_sets( working_set.rotate!(1) )
     end

    self.reverse!
  end

  # Normalize and zero down the set, returning a copy
  #
  # @return [Array] a copy of the set reduced
  #

  def reduce_set
    return_set = self.normalize_set
    return_set.zero_set!
  end

  # Normalize and zero down the set in place, returning a reference to the set
  #
  # @return [Array] a reference to the reduced set
  #

  def reduce_set!
    self.normalize_set!.zero_set!
  end

  # Return the prime version of the set
  #
  # @return [Array] the prime version of the set or its inversion
  #

  def prime_set
    prime_form = self.normalize_set.zero_set
    inverted_form =  self.invert_set.normalize_set.zero_set
    prime_form.reverse!
    prime_form.compare_compact_sets(inverted_form.reverse!).reverse!
  end

  # Set the prime version of the set in place and return a reference
  #
  # @return [Array] a reference to this set now changed to prime version
  #

  def prime_set!
    prime_form = self.normalize_set.zero_set
    inverted_form =  self.invert_set.normalize_set.zero_set
    prime_form.reverse!
    self = prime_form.compare_compact_sets(inverted_form.reverse!).reverse!
    self
  end

  # Compare two sets and return the most compact version
  #
  # @note going in its assumed the sets have been sorted and put in descending order as needed, since the
  # process here works in descending order
  #
  # @param [Array] compare_set the set to compare it to
  # @return [Array] the most compact form of the two
  #

  def compare_compact_sets( compare_set )

    winner = self.clone      # Assume the set is the winner going in.

    # Work backwards checking largest interval edge
    compare_set.each_index do |working_last_index|
      compare_interval1 = (winner[working_last_index] - winner.at(-1)) % 12
      compare_interval2 = (compare_set[working_last_index] - compare_set.at(-1)) % 12

      if compare_interval2 == compare_interval1
        next                                                  # equal, so loop back for next outer interval
      elsif compare_interval2 < compare_interval1             # new winner else assume #1 is good enough.
        winner = compare_set.clone
      end
      break
    end
    winner
  end

  # Converts the set from alpha representation to pc numbers and return a copy
  #
  # @return [Array] a copy of the set converted to pc representation as numbers
  #

  def convert_set_from_alpha
    return_set = self.clone
    return_set.collect! { |pc| pc = convert_from_alpha(pc) }
  end

  # Converts the set in place from alpha representation to pc numbers and return a reference
  #
  # @return [Array] a reference to the set converted to pc representation as numbers
  #

  def convert_set_from_alpha!
    self.collect! { |pc| pc = convert_from_alpha(pc) }
  end

  #  Converts the set from numeric representation to alphanumeric and return a copy
  #
  # @return [Array] a copy of the set converted to character representation
  #

  def convert_set_to_alpha
    return_set = self.clone
    return_set.collect! { |pc| pc = convert_to_alpha(pc) }
  end

  # Converts the set in place from numeric representation to alphanumeric and return a reference
  #
  # @return [Array] a reference to the set converted to character representation
  #

  def convert_set_to_alpha!
    self.collect! { |pc| pc = convert_to_alpha(pc) }
  end

  protected

  # Given a musical pitch, and how many 1/2 steps you want to transpose it, returns a new pitch at the new
  # transposition
  #
  # @param [Integer] pitch_class the pitch to transpose ()0-11)
  # @param [Integer] number_to_transpose the Tn we wish to transpose it to
  # @return [Integer] a copy of the pitch at the new Tn
  #

  def transpose_pitch_class( pitch_class, number_to_transpose = 0 )
    (pitch_class + number_to_transpose)  % 12
  end

  # Given a musical pitch, return the inversion of the pitch
  #
  # @param [Integer] pitch_class the pitch to invert ()0-11)
  # @return [Integer] a copy of the pitch at the new inversion
  #

  def invert_pitch_class( pitch_class )
    (12 - pitch_class)  % 12
  end

  # Convert String representation of a pitch to an Integer representation
  #
  # @param [String] pitch_class the pitch to convert
  # @return [Integer]  a copy of the pitch translated to Integer representation
  #

  def convert_pc_from_alpha( pitch_class )
    case pitch_class.to_s
      when 'A', 'a' then 10
      when 'B', 'b' then 11
      when 'C', 'c' then 12
      else pitch_class.to_i
    end
  end

  # Convert Integer representation of a pitch to a String representation
  #
  # @param [Integer] pitch_class the pitch to convert
  # @return [String] a copy of the pitch translated to a string representation
  #

  def convert_pc_to_alpha( pitch_class )
    case pitch_class.to_i
      when 10 then 'A'
      when 11 then 'B'
      when 12 then 'C'
      else pitch_class.to_s
    end
  end

end

