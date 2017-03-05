class SessionsController < ApplicationController
  def new
  end

  def create
    # instance variable for test
  	@user = User.find_by_email(params[:session][:email])
  	if @user && @user.authenticate(params[:session][:password])
  		login @user
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
  		redirect_back_or @user
  	else
  		flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
  		render "sessions/new"
  	end

  end

	def destroy
    log_out if logged_in?
    redirect_to root_url
	end

end
