require 'test_helper'
require 'json'

class SaintPeterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def clean_db
    User.delete_all
    Resource.delete_all
  end

  setup do
    clean_db
  end

  teardown do
    clean_db
  end

  test "create a user" do
    post '/users', :name => "john", :roles => "user, joker"
    assert last_response.ok?
    assert_equal ["user", "joker"], User.find_by_name("john").roles
  end

  test "create an authorization" do
    post '/resources', :name => "/only-admins", :roles => "user, buster"
    assert last_response.ok?
    assert_equal ["user", "buster"], Resource.find_by_name("/only-admins").roles
  end

  test "check user authorization" do
    resource = "/only-admins"
    user     = "john"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => false}, JSON.parse(last_response.body))

    post '/users', :name => "john", :roles => "user, joker"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => false}, JSON.parse(last_response.body))

    post '/resources', :name => "/only-admins", :roles => "buster"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => false}, JSON.parse(last_response.body))

    post '/resources', :name => "/only-admins", :roles => "user,buster"
    get "/users/#{user}/authorizations", :resource => "/only-admins"
    assert_equal({"authorized" => true}, JSON.parse(last_response.body))
  end
end
