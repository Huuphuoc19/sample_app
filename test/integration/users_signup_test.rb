require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
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

  	follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
	end

end
