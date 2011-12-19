require 'singleton'

# ============================================================================
# Class: Forte Sets     (Singleton)
#
# A dictionary of Forte sets indexed by name
#
# Use this class to lookup forte representation of musical sets.
#
# Structure of the dictionary is as follows:
#
#    @dictionary[forte_set_name] = [[<set pitches>], [<interval vector>], <description> ]
#
# == Examples:
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
#   TODO allow name lookup by an array representing the set.  Should normalize, make prime etc.
#
# =============================================================================


class ForteSets
  include Singleton

  #   File layour: <set_name>\t<prime_set>\t<interval_vector>\t<description>\n
  FORTE_SETS_CSV = "forte_sets.csv"

  attr_accessor :dictionary

  private       :dictionary

  # Constructor
  #
  # * *Parameters*    :
  #   - none
  # * *Returns* :
  #   - [Object] -> a new ForteSets Object
  # * *Raises* :
  #   - none
  #

  def initialize()
    @dictionary = Hash.new()
    self.load_dictionary()
  end

  public

  # Given the name of a set, will return an array of pitches representing the prime set
  #
  # * *Parameters* :
  #   - +name+ [String] -> the Forte name of the set to retrieve
  # * *Returns* :
  #   - [Array] or nil -> a copy of the prime set from the dictionary
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #

  def get_set(name)
    raise ArgumentError, "name is mandatory" if(name.nil?)
    raise ArgumentError, "name must be a string" unless(name.instance_of?(String))

    forte_array = @dictionary[name]
    forte_array.nil? ? forte_set = nil : forte_set = Array.new(forte_array[0])        # Set ex [0,2,4,5]
    forte_set
  end

  # Given the name of a set, will return an array representing the interval vector of the set
  #
  # * *Parameters* :
  #   - +name+ [String] -> the Forte name of the set to retrieve
  # * *Returns* :
  #   - [Array] or nil -> a copy of the interval vector from the dictionary
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #

  def get_vector(name)
    raise ArgumentError, "name is mandatory" if(name.nil?)
    raise ArgumentError, "name must be a string" unless(name.instance_of?(String))

    forte_array = @dictionary[name]
    forte_array.nil? ? forte_vector = nil : forte_vector = Array.new(forte_array[1])         # interval vector
    forte_vector
  end

  # Given the name of a set, will return a long text description of the set
  #
  # * *Parameters* :
  #   - +name+ [String] -> the Forte name of the set to retrieve
  # * *Returns* :
  #   - [String] or nil -> a copy of the set description from the dictionary
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil or wrong type
  #

  def get_description(name)
    raise ArgumentError, "name is mandatory" if(name.nil?)
    raise ArgumentError, "name must be a string" unless(name.instance_of?(String))

    forte_array = @dictionary[name]
    forte_array.nil? ? forte_description = nil : forte_description = String.new(forte_array[2])      # Description
    forte_description
  end

  # Given a set of pitches, and how many 1/2 steps you want to transpose it, returns a new set at the new
  # transposition
  #
  # * *Parameters* :
  #   - +set+ [Array] -> The set to transpose 0 = c; 1 = c#...11 = b
  #   - +n+ [Integer] -> Tn or how many steps to increment (optional)
  # * *Returns* :
  #   - [Array] -> The new transposed Array
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def transpose_set(set, n = 0)
    raise ArgumentError, "set is mandatory" if (set.nil?)
    raise ArgumentError, "set must be an Array" unless (set.instance_of?(Array))
    set.each {|pc| raise ArgumentError, "set values must be between 0 and 11" unless ((0..11).include?(pc))}
    raise ArgumentError, "n must be an integer" unless (n.instance_of?(Fixnum))
    raise ArgumentError, "n must be between 0-11" unless ((0..11).include?(n))
    return_set = Array.new(set)
    return_set.collect!{ |pc| pc = self.transpose_pc(pc, n) }
    return_set
  end

  # Given a set of pitches, return the sets inversion
  #
  # * *Parameters* :
  #   - +set+ [Array] -> The set to invert 0 = c; 1 = c#...11 = b
  # * *Returns* :
  #   - [Array] -> The new inverted Array
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def invert_set(set)
    raise ArgumentError, "set is mandatory" if (set.nil?)
    raise ArgumentError, "set must be an Array" unless (set.instance_of?(Array))
    set.each {|pc| raise ArgumentError, "set values must be between 0 and 11" unless ((0..11).include?(pc))}
    return_set = Array.new(set)
    return_set.collect!{ |pc| pc = self.invert_pc(pc) }
    return_set
  end

  # Given a musical pitch, and how many 1/2 steps you want to transpose it, returns a new pitch at the new
  # transposition
  #
  # * *Parameters* :
  #   - +pc+ [Integer] -> A pitch to increment 0 = c; 1 = c#...11 = b
  #   - +n+ [Integer] -> Tn or how many steps to increment (optional)
  # * *Returns* :
  #   - [Integer] -> The new transposed pitch
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def transpose_pc(pc, n = 0)
      raise ArgumentError, "pc is mandatory" if (pc.nil?)
      raise ArgumentError, "pc must be an integer" unless (pc.instance_of?(Fixnum))
      raise ArgumentError, "pc must be between 0-11" unless ((0..11).include?(pc))
      raise ArgumentError, "n must be an integer" unless (n.instance_of?(Fixnum))
      raise ArgumentError, "n must be between 0-11" unless ((0..11).include?(n))
      (pc + n)  % 12
  end

  # Given a musical pitch, return the inversion of the pitch
  #
  # * *Parameters* :
  #   - +pc+ [Integer] -> A pitch to increment 0 = c; 1 = c#...11 = b
  # * *Returns* :
  #   - [Integer] -> The new inverted pitch
  # * *Raises* :
  #   - +ArgumentError+ -> if any mandatory value is nil
  #

  def invert_pc(pc)
      raise ArgumentError, "pc is mandatory" if (pc.nil?)
      raise ArgumentError, "pc must be an integer" unless (pc.instance_of?(Fixnum))
      raise ArgumentError, "pc must be between 0-11" unless ((0..11).include?(pc))
      (12 - pc)  % 12
  end

  protected

  # Loads the dictionary from a CSV file into a hash dictionary
  #
  # Note:  it's a simple table so we don't use any special libraries like csv, faster_csv, ccsv, CSVScan  etc.
  #
  # * *Parameters* :
  #   - +name+ [String] -> the Forte name of the set to retrieve
  # * *Returns* :
  #   - none
  # * *Raises* :
  #   - none
  #

  def load_dictionary()
     file = File.new(FORTE_SETS_CSV, 'r')
     file.each_line("\n") do |row|
       columns = row.split("\t")
       key = columns[0]                                      # Set name
       prime_set =  columns[1].split('')
       prime_set.collect!() do |pc|                          # Store integer representations only
         case pc.to_s
           when 'A' then pc = 10
           when 'B' then pc = 11
           else pc = pc.to_i
         end
       end
       interval_vector =  columns[2].split('')
       @dictionary[key] = Array.new([prime_set, interval_vector, columns[3]])
     end
  end

end
