class HomeController < ApplicationController
  def index
    @word = Word.all.shuffle.first
  end
  def check
    @word = Word.find(params[:id])
    if params["chose_#{@word.article}"]
      redirect_to root_url, :flash => { :success=> "OK,  #{@word.to_s} war richtig"}
    else
      redirect_to root_url, :flash => { :error=> "Neeein,  #{@word.to_s} war richtig"}
    end
  end
end
