class SessionsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by_email(params[:session][:email])
  	if user && user.authenticate(params[:session][:password])
  		login user
  		redirect_to user
  	else
  		flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
  		render "sessions/new"
  	end

  end

	def destroy
    log_out
    redirect_to root_url
	end  

end
