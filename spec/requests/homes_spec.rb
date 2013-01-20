require 'spec_helper'

describe "Home" do
  it "should have the content 'richtig'" do
    visit '/home/index'
    assert page.has_content?('richtig')
  end
end
