require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not loggin" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?

    patch user_path(@other_user), params: {
                                    user: { password:              "aaaaaa",
                                            password_confirmation: "aaaaaa",
                                            admin: true } }
    assert_not  @other_user.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  test "deleted succefully with admin logged in" do
    log_in_as(@user)
    assert_difference "User.count",-1 do
      delete user_path(@other_user)
    end
    assert_redirected_to users_path
  end

  test "index users with non-admin logged in" do
    log_in_as(@user)
    get users_path
    assert_select "a", text: "delete", count: 0
  end

  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end

end
