require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  # reset mailer
  def setup
    ActionMailer::Base.deliveries.clear
  end


  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid.com",
                                         password:              "aaaaaa",
                                         password_confirmation: "aaaaaa" } }
    end
    assert_template 'users/new'
    assert_select "#error_explanation>ul>li",1
    assert_select "#error_explanation>ul>li:first-child","Name can't be blank"
  end

  test "should signup successfully" do
  	get signup_path
  	assert_difference 'User.count' do
  		post users_path, params: { user: { name:  "Temp",
                                         email: "user@invalid.com",
                                         password:              "aaaaaa",
                                         password_confirmation: "aaaaaa" } }
  	end
    #delivery 1 mail
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    #login
    log_in_as(user)
    assert_not is_logged_in?

    #invalid token
    get edit_account_activation_path("invalid token",email: user.email)
    assert_not is_logged_in?
    #valid token
    get edit_account_activation_path(user.activation_token,email: user.email)
    assert user.reload.activated?
    assert_redirected_to user
    follow_redirect!
    
    assert_template 'users/show'
    assert is_logged_in?
	end

end
