require 'miltons_machine'

describe MiltonsMachine::Core::ForteDictionary do

  context "when performing basic lookup operations" do

    it "should return a set by Forte set name" do
      result_set = MiltonsMachine::Core::ForteDictionary.instance.get_set('12-1')
      result_set.should eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
    end

    it "should return an interval vector by Forte set name" do
      interval_vector = MiltonsMachine::Core::ForteDictionary.instance.get_interval_vector('12-1')
      interval_vector.should eq([12, 12, 12, 12, 12, 6])
    end

    it "should return a set description by Forte set name" do
      description = MiltonsMachine::Core::ForteDictionary.instance.get_description('12-1')
      description.chomp.should eq('Chromatic Scale/Dodecamirror (111111111111)')
    end

  end

end