require 'set'
require 'stringio'

require 'miltons_machine'

describe MiltonsMachine::Tools::MatrixAnalyzer do

  # This is a helper class derived from the parent, so we can peek at the protected variables
  # and validate some of the test scenarios.

  class TestingHelper <  MiltonsMachine::Tools::MatrixAnalyzer
    def add_row_test(subject)
      set_1 = [0, 1, 2, 3]
      set_2 = [4, 5, 6, 7]
      set_3 = [8, 9, 10, 11]
      subject.add_row(1, set_1)
      subject.add_row(2, set_2)
      subject.add_row(3, set_3)
      groups = subject.groups
      return false unless subject.groups[0][0] == set_1
      return false unless subject.groups[1][0] == set_2
      return false unless subject.groups[2][0] == set_3
      true
    end

    def add_search_set_test(subject)
      set_1 = [0, 1, 2, 3]
      set_2 = [4, 5, 6, 7]
      set_3 = [8, 9, 10, 11]
      subject.add_search_set(set_1)
      subject.add_search_set(set_2)
      subject.add_search_set(set_3)
      compare_set = Set.new(set_1)
      return false unless subject.search_sets[0] == compare_set
      return false unless subject.search_sets[1] == compare_set.replace(set_2)
      return false unless subject.search_sets[2] == compare_set.replace(set_3)
      true
    end

    def add_forte_set_test(subject)
      subject.add_forte_set('5-3i')
      subject.add_forte_set('7-10')
      subject.add_forte_set('8-18')
      compare_set = Set.new([0, 1, 3, 4, 5])
      return false unless subject.search_sets[0] == compare_set
      return false unless subject.search_sets[1] == compare_set.replace([0, 1, 2, 3, 4, 6, 9])
      return false unless subject.search_sets[2] == compare_set.replace([0, 1, 2, 3, 5, 6, 8, 9])
      true
    end

  end

  include MiltonsMachine::Testing::Helpers

  context "when performing basic operations" do

    before(:each) do
      @testing_helper  = TestingHelper.new
    end

    it "should add a row" do
      @testing_helper.add_row_test(subject).should eq(true)
    end

    it "should add a search set as an array" do
      @testing_helper.add_search_set_test(subject).should eq(true)
    end

    it "should add a search set by Forte set name" do
      @testing_helper.add_forte_set_test(subject).should eq(true)
    end

    it "should run the analysis correctly" do
      melody = [0, 0, 0, 4, 4, 4, 7, 7, 0, 7, 2, 0, 7, 3, 0, 0]
      subject.report_details=(true)
      subject.add_row(1, melody)
      subject.add_row(2, melody)
      subject.add_row(3, melody)

      0.upto(11) do |i|
          subject.add_forte_set("3-11", i)
          subject.add_forte_set("3-11i", i)
      end

      compare_string = "1:182:483:724:245:426:6**EndofReport"
      @output = capture(:stdout) { subject.run_rotation_analysis }
      @output = @output[-125..-1]
      @output.delete!("\n ")
      @output.should include(compare_string)
    end

  end

end