class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  def prio_list
    words = Word.all
    if signed_in?
      words.sort{|w1, w2| current_user.word_prob(w2) <=> current_user.word_prob(w1)}
    else
      words.sort_by{|word| word.weight}
    end
  end
end
