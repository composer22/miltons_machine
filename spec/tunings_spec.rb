require 'miltons_machine'

describe MiltonsMachine::Core::Tuning do

  context "when performing load operations" do

    it "should load a tuning file correctly" do
      solution_set = [104.955, 203.91, 297.513, 386.314, 1.313, 551.318, 701.955, 1.563, 840.528, 968.826, 1200.0]

      file_path = File.dirname(__FILE__) << '/test_files/tunings/tenney_tester.scl'
      subject.load(file_path)

      cents = subject.cents.collect{ |frequency| frequency = frequency.round(3) }
      description = subject.description
      result_file_path = subject.file_path

      cents.should eq solution_set
      description.should eq 'Modification of tenny_12.scl for rspec testing of the Tuning class'
      result_file_path.should eq file_path
    end

  end

end