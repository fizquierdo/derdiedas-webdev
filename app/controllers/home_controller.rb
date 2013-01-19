class HomeController < ApplicationController
  def index
   @word = Word.all.shuffle.first
  end
end
