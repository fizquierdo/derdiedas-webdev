class HomeController < ApplicationController
  def index
    @word = Word.all.shuffle.first
  end
  def check
    @word = Word.find(params[:id])
    if given_answer == @word.article
      flash_data = { :success=> "Sehr gut!,  #{@word.to_s} war richtig"}
    else
      flash_data = { :error=> "mmmmmm Eigentlich war #{@word.to_error_s} richtig"}
    end
    save_guess if signed_in?
    redirect_to root_url, :flash => flash_data
  end
  private

    def given_answer
      answer = nil
      %w(der die das).each do |article|
        answer = article if params["chose_#{article}"]
      end
      answer
    end
    def save_guess
      guess = current_user.guesses.build(word_id: @word.id, answer: given_answer)
      guess.save
    end

end
