require 'miltons_machine'

describe MiltonsMachine::Core::Tuning do

  context "when performing load operations" do

    it "should load a tuning file correctly" do
      solution_set = [104.95540939865029, 203.9100015330788, 297.51301584385595, 386.31371349029365, 1.3125,
                      551.3179418302396, 701.9550001848238, 1.5625, 840.5276609543971, 968.825905529823,
                      1199.9999988365687]

      file_path = File.dirname(__FILE__) << '/test_files/tunings/tenney_tester.scl'
      subject.load(file_path)

      cents = subject.cents
      description = subject.description
      result_file_path = subject.file_path

      cents.should eq solution_set
      description.should eq 'Modification of tenny_12.scl for rspec testing of the Tuning class'
      result_file_path.should eq file_path
    end

  end

end