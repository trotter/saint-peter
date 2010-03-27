require 'test_helper'
require 'json'

class SaintPeterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  test "create a user" do
    post '/users', :name => "john", :roles => "user, joker"
    assert last_response.ok?

    expected_user = {:name => "john", :roles => ["user", "joker"]}
    assert_equal expected_user, User.find_by_name("john")
  end

  test "create an authorization" do
    post '/authorizations', :resource => "/only-admins", :roles => "user, buster"
    assert last_response.ok?

    expected_authorization = { :resource => "/only-admins", :roles => ["user", "buster"] }
    assert_equal expected_authorization, Authorization.find_by_resource("/only-admins")
  end

  test "check user authorization" do
    resource = "/only-admins"
    user     = "john"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => false}, JSON.parse(last_response.body))

    post '/users', :name => "john", :roles => "user, joker"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => false}, JSON.parse(last_response.body))

    post '/authorizations', :resource => "/only-admins", :roles => "buster"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => false}, JSON.parse(last_response.body))

    post '/authorizations', :resource => "/only-admins", :roles => "user,buster"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => true}, JSON.parse(last_response.body))
  end
end
