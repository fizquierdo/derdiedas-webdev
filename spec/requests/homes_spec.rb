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


end
