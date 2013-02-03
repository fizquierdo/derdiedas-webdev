
require 'spec_helper'

describe Word do
  before do
    @word = FactoryGirl.create(:word)
  end
  subject{@word}
  it {should respond_to(:article)}
  it {should respond_to(:noun)}
  it {should respond_to(:to_s)}

  describe "factory example" do
    its(:article) {should == "das"}
    its(:noun) {should == "Zimmer"}
    its(:weight) {should == 1}
    it " to_s should be article and noun" do 
      @word.to_s.should == "Das Zimmer"
    end
  end
  

end
