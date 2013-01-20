require 'spec_helper'

describe "Home" do
  #before {@word = Word.new(noun: "Zimmer", article: "das", weight: 1)}
  it "should have the content 'richtig'" do
    visit root_path
    assert page.has_content?('richtig')
  end
end
