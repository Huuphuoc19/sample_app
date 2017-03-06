require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password reset" do
    get new_password_reset_path
    assert_template "password_resets/new"
    #invalid email
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_template "password_resets/new"
    assert_not flash.empty?
    # valid email
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    ###
    user = assigns(:user)
    #wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # inactive email
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: @user.email)
    assert_redirected_to root_url

    #right email, right token
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    ## Invalid password & confirmation

    patch password_reset_path, params: { email: user.email,
                                  user: { password:              "foobaz",
                                          password_confirmation: "barquux" } }
    assert_template "password_resets/edit"
    #empty password
    patch password_reset_path, params: { email: user.email,
                                  user: { password:              "foobaz",
                                          password_confirmation: "barquux" } }
    assert_template "password_resets/edit"
    assert_select "div#error_explanation"
    # valid password and confirmation
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert_not flash.empty?
    # delete digest
    assert_nil @user.reset_digest
    assert is_logged_in?
    assert_redirected_to user_path(@user)
  end

  test "password expire" do
    get new_password_reset_path
    post password_resets_path,
        params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    assert_response :redirect
    follow_redirect!
    assert_match /Password reset has expired./i, response.body
  end

end
