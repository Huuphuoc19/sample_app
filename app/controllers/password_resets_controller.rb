class PasswordResetsController < ApplicationController
  #before
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  #check password not expiration time
  before_action :check_expiration, only: [:edit, :update]    # Case (1)
  ###
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email])
    # have user
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty? # handle empty password
      @user.errors.add(:password, "can't be empty")
      render :edit
    elsif @user.update_attributes(user_params) ## login ok
      login @user
      #remove digest 
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else # fail confirm
       render :edit
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user && @user.activated? &&
          @user.authenticated?(:reset, params[:id]))
          redirect_to root_path
      end
    end

    def check_expiration
      ## check of remain time
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end


end
