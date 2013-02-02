class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user and user.authenticate(params[:session][:password])
      # Sign the user in
      sign_in user
      redirect_to user
    else
      flash[:error] = "Invalid email/password combination"
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
