require 'singleton'

# ============================================================================
# == Class: Forte Sets (Singleton)
#
# A dictionary of Forte sets indexed by name, as well as some common operations
#
# Use this class to lookup forte representation of musical sets.
#
# Structure of the dictionary is as follows:
#
#    @dictionary[forte_set_name] = [ [<set pitches>], [<interval vector>], <description> ]
#
# === Code Example:
#
#    major_scale = ForteSets.instance.get_set("7-35")
#    puts major_scale
#
#    # would print out [0, 1, 3, 5, 6, 8, 11]
#
#    interval_vector = ForteSets.instance.get_vector("7-35")
#    puts interval_vector
#
#    # would print out [7, 2, 5, 4, 3, 6, 1]
#
#    description = ForteSets.instance.get_description("7-35")
#    puts description
#
#    # would print out "Major Diatonic Heptachord/Dominant-13th, Locrian (1221222), Phrygian (1222122), Major inverse"
#
# TODO allow name lookup by an array representing the set.  Should normalize, make prime etc.
#
# =============================================================================

class ForteSets
  include Singleton

  #   File layout: <set_name>\t<prime_set>\t<interval_vector>\t<description>\n

  FORTE_SETS_CSV = "forte_sets.csv"

  attr_accessor :dictionary

  private       :dictionary

  # Constructor
  #
  # @return [Object] -> a new ForteSets Object
  #

  def initialize
    @dictionary = Hash.new
    load_dictionary
  end

  public

  # Given the name of a forte set, will return an array of pitches representing the prime set
  #
  # @param name [String] -> the Forte name of the set to retrieve
  # @return [Array] or [nil]  -> a copy of the forte set from the dictionary if found
  #

  def get_set( name )
    forte_array = @dictionary[name]
    forte_array.nil? ? nil : Array.new( forte_array[0] )        # Set ex [0,2,4,5]
  end

  # Given the name of a set, will return an array representing the interval vector of the set
  #
  # @param name [String] -> the Forte name of the set who's interval vector we want
  # @return [Array] or [nil] -> a copy of the forte set's interval vector from the dictionary if found
  #

  def get_vector( name )
    forte_array = @dictionary[name]
    forte_array.nil? ? nil : Array.new( forte_array[1] )         # interval vector
  end

  # Given the name of a set, will return a long text description of the set
  #
  # @param name [String] -> the Forte name of the set who's description we want
  # @return [String] or [nil] -> a copy of the prime set's description from the dictionary if found
  #

  def get_description( name )
    forte_array = @dictionary[name]
    forte_array.nil? ? nil : String.new( forte_array[2] )        # Description
  end

  # Given a set of pitches, and how many 1/2 steps you want to transpose it, returns a new set at the new
  # transposition
  #
  # @param set_to_transpose [Array] -> the set which we want to transpose
  # @param number_to_transpose [Integer] -> number of half steps between 0 - 11
  # @return [Array] -> a copy of the set transposed to the new Tn
  #

  def transpose_set( set_to_transpose, number_to_transpose = 0 )
    return_set = Array.new( set_to_transpose )
    return_set.collect! { |pc| pc = transpose_pitch_class(pc, number_to_transpose) }
    return_set
  end

  # Given a set of pitches, return the sets inversion
  #
  # @param set_to_invert [Array] -> the set which we want to invert
  # @return [Array] -> a copy of the set inverted
  #

  def invert_set( set_to_invert )
    return_set = Array.new( set_to_invert )
    return_set.collect! { |pc| pc = invert_pitch_class(pc) }
    return_set
  end

  # Given a set of pitches, return the complement set
  #
  # @param set_to_complement [Array] -> the set who's complement we desire
  # @return [Array] -> the complement set
  #

  def complement_set( set_to_complement )
    Array.new(12) { |i| i }  - set_to_complement
  end

  # Given a set of pitches, return a copy of the set with all element transposed so that the first element
  # is set to zero.
  #
  # @param set_to_zero_out [Array] -> the set to set to zero.
  # @return [Array] -> the zero transposed set
  #

  def zero_set( set_to_zero_out )
    set_to_zero_out[0] == 0 ? n = 0 :  n = 12 - set_to_zero_out[0]
    transpose_set(set_to_zero_out, n)
  end


  # Returns the most compact order of a set
  #
  # @param set_to_normalize [Array] -> the set we wish to normalize the order
  # @return [Array] -> a copy of the set normalized
  #

  def normalize_set( set_to_normalize )
    winner = Array(set_to_normalize)
    last_index = winner.length - 1
    return winner if last_index < 1

    winner.sort!()

    # Create all the permutations to compare for winners by rotating it.
    permutations = Array.new
    working_set = Array.new(winner)
    0.upto(last_index - 1 ) { permutations <<  Array.new( working_set.rotate!(1) ) }

    # Pick the best winner out of the lot
    permutations.each do |compare_set|

      working_last_index = last_index
      while (working_last_index > 0 ) do
        winner_interval =  winner[working_last_index] -  winner[0]
        compare_interval = compare_set[working_last_index] - compare_set[0]
        winner_interval += 12 if winner_interval < 0
        compare_interval += 12 if compare_interval < 0

        #  Compare outer intervals...winner is smaller of either previous winner or this permutation.

        if compare_interval < winner_interval             # new winner
          winner = compare_set.clone
          break
        elsif compare_interval > winner_interval          # old winner is still ruling
          break
        end

        working_last_index -= 1                           # a tie, so go back and look at second to last interval.
      end
    end

    winner
  end

  # Given a musical pitch, and how many 1/2 steps you want to transpose it, returns a new pitch at the new
  # transposition
  #
  # @param pitch_class [Integer] -> the pitch to transpose ()0-11)
  # @param number_to_transpose [Integer] -> the Tn we wish to transpose it to
  # @return [Integer] -> a copy of the pitch at the new Tn
  #

  def transpose_pitch_class( pitch_class, number_to_transpose = 0 )
    (pitch_class + number_to_transpose)  % 12
  end

  # Given a musical pitch, return the inversion of the pitch
  #
  # @param pitch_class [Integer] -> the pitch to invert ()0-11)
  # @return [Integer] -> a copy of the pitch at the new inversion
  #

  def invert_pitch_class( pitch_class )
    (12 - pitch_class)  % 12
  end

  # Convert String representation of a pitch to an Integer representation
  #
  # @param pitch_class [Integer] or [String]-> the pitch to convert
  # @return [Integer] -> a copy of the pitch translated to Integer representation
  #

  def convert_from_alpha( pitch_class )
    case pitch_class.to_s
      when 'A', 'a' then 10
      when 'B', 'b' then 11
      else pitch_class.to_i
    end
  end

  # Convert Integer representation of a pitch to a String representation
  #
  # @param pitch_class [Integer] -> the pitch to convert
  # @return [String] -> a copy of the pitch translated to a string representation
  #

  def convert_to_alpha( pitch_class )
    case pitch_class.to_i
      when 10 then 'A'
      when 11 then 'B'
      else pitch_class.to_s
    end
  end

  protected

  # Loads the dictionary from a CSV file into a hash dictionary
  #
  # Note:  it's a simple table so we don't use any special libraries like csv, faster_csv, ccsv, CSVScan  etc.
  #

  def load_dictionary
    file = File.new(FORTE_SETS_CSV, 'r')
    file.each_line("\n") do |row|
      columns = row.split("\t")
      set_name  =  columns[0]
      prime_set =  columns[1].split('')
      prime_set.collect! { |pc| pc = convert_from_alpha(pc) }

      interval_vector =  columns[2].split('')
      interval_vector.collect! { |pc| pc = convert_from_alpha(pc) }

      description = columns[3]

      @dictionary[set_name] = Array.new( [prime_set, interval_vector, description] )
    end
  end

end
