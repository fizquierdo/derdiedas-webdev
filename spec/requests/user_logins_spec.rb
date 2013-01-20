require 'spec_helper'

describe "UserLogins" do
  describe "sign up page" do
    before {visit signup_path}
    it { assert page.has_selector?('h1',    text: 'Sign up') }
  end
end
