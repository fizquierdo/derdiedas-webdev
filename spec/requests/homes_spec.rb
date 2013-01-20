require 'spec_helper'

describe "Home" do
  let(:word) {FactoryGirl.create(:word)}
  subject {page}
  before{visit root_path}
  #it "should have the content 'richtig'" do
  #  # TODO pass this test
  #  should have_content('richtig')
  #end
end
