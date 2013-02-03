require 'spec_helper'

describe Guess do
  let(:user){FactoryGirl.create(:user)}
  let(:word){FactoryGirl.create(:word)}
  before do
    @guess = user.guesses.build(word_id: word.id)
  end

  subject{@guess}
  
  it {should respond_to(:user_id)}
  it {should respond_to(:word_id)}
  it {should respond_to(:answer)}
  it {should respond_to(:user)}
  it {should respond_to(:word)}
  it {should respond_to(:correct?)}
  its(:user) {should == user}
  its(:word) {should == word}

  describe "when user_id is not present" do
    before {@guess.user_id = nil}
    it {should_not be_valid}
  end
  describe "when word_id is not present" do
    before {@guess.word_id = nil}
    it {should_not be_valid}
  end
  describe "when answer is not present" do
    before {@guess.answer = nil}
    it {should_not be_valid}
  end
  describe "when answer is not an article" do
    before {@guess.answer = "derr"}
    it {should_not be_valid}
  end

  describe "has article as an answer" do
    describe "which is correct" do
      before{ @guess = user.guesses.build(word_id: word.id, answer: "das")}
      its(:answer) { should == word.article}
      it {should be_correct}
    end
    describe "which is wrong" do
      before{ @guess = user.guesses.build(word_id: word.id, answer: "die")}
      its(:answer) { should_not == word.article}
      it {should_not be_correct}
    end
  end

end
