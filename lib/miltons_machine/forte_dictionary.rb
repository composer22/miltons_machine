require 'singleton'

module MiltonsMachine

  #
  # == Class: Forte Dictionary (Singleton)
  #
  # A dictionary of Forte sets indexed by name for use by the system
  #
  # Use this class to lookup forte representation of musical sets.
  #
  # Structure of the dictionary is as follows:
  #
  #    @dictionary[forte_set_name] = [ [<set pitches>], [<interval vector>], <description> ]
  #
  # @example Retrieving Sets
  #
  #    major_scale = MiltonsMachine::ForteDictionary.instance.get_set("7-35")
  #    puts major_scale
  #
  #    # would print out [0, 1, 3, 5, 6, 8, 11]
  #
  #    interval_vector = MiltonsMachine::ForteDictionary.instance.get_vector("7-35")
  #    puts interval_vector
  #
  #    # would print out [7, 2, 5, 4, 3, 6, 1]
  #
  #    description = MiltonsMachine::ForteDictionary.instance.get_description("7-35")
  #    puts description
  #
  #    # would print out "Major Diatonic Heptachord/Dominant-13th, Locrian (1221222), Phrygian (1222122), Major inverse"
  #
  # TODO allow name lookup by an array representing the set
  #

  class ForteDictionary
    include Singleton

    #   File layout: <set_name>\t<prime_set>\t<interval_vector>\t<description>\n

    FORTE_DICTIONARY_CSV = "../data/forte_dictionary.csv"

    attr_accessor :dictionary

    private       :dictionary

    # Constructor
    #
    # @return [Object] a new ForteDictionary Object
    #

    def initialize
      @dictionary = Hash.new
      load_dictionary
    end

    public

    # Given the name of a forte set, will return an array of pitches representing the prime set
    #
    # @param [String] forte_set_name the Forte name of the set to retrieve
    # @return [ForteSet] a copy of the forte set from the dictionary if found
    #

    def get_set( forte_set_name )
      dictionary_entry = @dictionary[forte_set_name]
      dictionary_entry.nil? ? nil : dictionary_entry[0].clone
    end

    # Given the name of a set, will return an array representing the interval vector of the set
    #
    # @param [String] forte_set_name the Forte name of the set who's interval vector we want
    # @return [ForteSet] a copy of the forte set's interval vector from the dictionary if found
    #

    def get_interval_vector( forte_set_name )
      dictionary_entry = @dictionary[forte_set_name]
      dictionary_entry.nil? ? nil : dictionary_entry[1].clone
    end

    # Given the name of a set, will return a long text description of the set
    #
    # @param [String] forte_set_name the Forte name of the set who's description we want
    # @return [String] a copy of the prime set's description from the dictionary if found
    #

    def get_description( forte_set_name )
      dictionary_entry = @dictionary[forte_set_name]
      dictionary_entry.nil? ? nil : dictionary_entry[2].clone
    end

    protected

    # Loads the dictionary from a CSV file into a hash dictionary
    #
    # @note  it's a simple table so we don't use any special libraries like csv, faster_csv, ccsv, CSVScan  etc.
    #

    def load_dictionary
      file = File.new(FORTE_DICTIONARY_CSV, 'r')
      file.each_line("\n") do |row|
        columns = row.split("\t")

        set_name        = columns[0]
        forte_set       = MiltonsMachine::ForteSet.new( columns[1].split('') ).convert_set_from_alpha!
        interval_vector = MiltonsMachine::ForteSet.new( columns[2].split('') ).convert_set_from_alpha!   # we just need the conversion
        description     = columns[3]

        @dictionary[set_name] = Array.new( [forte_set, interval_vector, description] )
      end
    end

  end

end
