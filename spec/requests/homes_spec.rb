require 'spec_helper'

describe "Home" do
  subject {page}
  describe "home page shows an initial word" do
    before { visit root_path }
    # Fixture loads das Zimmer, TODO learn how to do this with factories
    it { should have_link('Sign up!') }
    it { should have_selector('h1',    text: 'Zimmer') }
    it { should have_button('Der') }
    it { should have_button('Die') }
    it { should have_button('Das') }
    describe "user clicks correct article" do
      before { click_button 'Das' }
      it { should have_selector('div.alert.alert-success', text: 'richtig') }
    end
    let(:wrong_word){"Eigentlich war das Zimmer richtig"}
    describe "user clicks wrong article" do
      before { click_button 'Der' }
      it { should have_error_message(wrong_word)}
    end
    describe "user clicks another wrong article" do
      before { click_button 'Die' }
      it { should have_error_message(wrong_word)}
    end
  end

end
