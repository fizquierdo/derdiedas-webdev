class HomeController < ApplicationController
  def index
    @word = Word.all.shuffle.first
  end
  def check
    @word = Word.find(params[:id])
    if params["chose_#{@word.article}"]
      redirect_to root_url, :flash => { :success=> "Sehr gut!,  #{@word.to_s} war richtig"}
    else
      redirect_to root_url, :flash => { :error=> "mmmmmm Eigentlich war #{@word.to_s} richtig"}
    end
  end
end
