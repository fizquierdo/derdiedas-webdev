require 'spec_helper'

describe "Home" do
  subject {page}
  before { visit root_path}
  describe "home page shows an initial word" do
    it { should have_link('Sign up!') }
    it { should have_selector('h1',    text: 'Baum') }
    it { should have_button('Der') }
    it { should have_button('Die') }
    it { should have_button('Das') }
  end
  describe "user clicks correctly article der" do
    before { click_button 'Der' }
    it { should have_selector('div.alert.alert-success', text: 'richtig') }
  end

  let(:wrong_word){"Eigentlich war der Baum richtig"}
  describe "user clicks wrong article" do
    before { click_button 'Das' }
    it { should have_error_message(wrong_word)}
  end
  describe "user clicks another wrong article" do
    before { click_button 'Die' }
    it { should have_error_message(wrong_word)}
  end

  describe " no guess is created unless the user is logged in" do
    it " should not increase guesses" do
      expect{click_button 'Der'}.to change(Guess, :count).by(0)
      expect{click_button 'Die'}.to change(Guess, :count).by(0)
      expect{click_button 'Das'}.to change(Guess, :count).by(0)
    end
  end

  describe " a guess is created if the user is logged in" do
    let(:user) { FactoryGirl.create(:user)}
    before do 
      sign_in user
      visit root_path
    end
    describe "user clicks wrong word" do
      let(:clicked){"Das"}
      it " should increase guesses" do
        expect{click_button clicked}.to change(Guess, :count).by(1)
        expect{click_button clicked}.to change(user.guesses, :count).by(1)
      end
    end
    describe "user clicks right word" do
      let(:clicked){"Der"}
      it " should increase guesses" do
        expect{click_button clicked}.to change(Guess, :count).by(1)
        expect{click_button clicked}.to change(user.guesses, :count).by(1)
      end
    end
  end

end
