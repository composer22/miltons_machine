require 'miltons_machine/forte_set'

describe ForteSet do

  context "when performing base set operations" do

    before(:each) do
      subject.replace([0, 3, 5, 6, 9])
    end

    it "should transpose itself and return a copy" do
      return_set = subject.transpose_mod12(4)
      subject.should eq([0, 3, 5, 6, 9])
      return_set.should eq([4, 7, 9, 10, 1])
    end

    it "should transpose itself in place and return a reference" do
      return_set = subject.transpose_mod12!(4)
      subject.should eq([4, 7, 9, 10, 1])
      return_set.should eq(subject)
      subject[3] = 11
      subject.should eq([4, 7, 9, 11, 1])
      return_set.should eq(subject)
    end

    it "should invert itself and return a copy" do
      subject.transpose_mod12!(4)
      return_set = subject.invert_mod12
      subject.should eq([4, 7, 9, 10, 1])
      return_set.should eq([8, 5, 3, 2, 11])
    end

    it "should invert itself in place and return a reference" do
      subject.transpose_mod12!(4)
      return_set = subject.invert_mod12!
      subject.should eq([8, 5, 3, 2, 11])
      return_set.should eq(subject)
      subject[3] = 7
      subject.should eq([8, 5, 3, 7, 11])
      return_set.should eq(subject)
    end

    it "should return it's complement set" do
      return_set = subject.complement_mod12
      subject.should eq([0, 3, 5, 6, 9])
      return_set.should eq([1, 2, 4, 7, 8, 10, 11])
    end

    it "should replace itself with it's complement set" do
      return_set = subject.complement_mod12!
      subject.should eq([1, 2, 4, 7, 8, 10, 11])
      return_set.should eq(subject)
      subject[3] = 5
      subject.should eq([1, 2, 4, 5, 8, 10, 11])
      return_set.should eq(subject)
    end

    it "should return the zero placement of the set" do
      subject.transpose_mod12!(7)
      return_set = subject.zero_mod12
      subject.should eq([7, 10, 0, 1, 4])
      return_set.should eq([0, 3, 5, 6, 9])
    end

    it "should zero itself in place and return a reference" do
      subject.transpose_mod12!(7)
      return_set = subject.zero_mod12!
      subject.should eq([0, 3, 5, 6, 9])
      return_set.should eq(subject)
      subject[3] = 7
      subject.should eq([0, 3, 5, 7, 9])
      return_set.should eq(subject)
    end

    it "should return its normalized form" do
      true
    end

    it "should replace itself with it's normalized form and return a copy" do
      true
    end

    it "should return it's reduced form'" do
      true
    end

    it "should replace itself with it's reduced form and return a copy" do
      true
    end

    it "should return it's prime form" do
      true
    end

    it "should replace itself with it's prime form and return a reference" do
      true
    end

    it "should compare itself with another set and return the more compact form" do
      true
    end

    it "should convert itself from alphanumeric form and return a copy" do
      true
    end

    it "should convert itself in place from alphanumeric form and return a reference" do
      true
    end

    it "should convert itself from numeric form and return a copy" do
      true
    end

    it "should convert itself in place from numeric form and return a reference" do
      true
    end

  end

end