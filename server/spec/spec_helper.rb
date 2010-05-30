# database - needed before requiring app
#ENV["REDIS_PORT"] = "8484"

require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def login_as(username, password)
  uid = REDIS.incr("global:nextUserId")
  REDIS.set("uid:#{uid}:login", username)
  REDIS.set("login:#{username}:uid", uid)
  post '/login', :login => username, :password => password
  JSON.parse(last_response.body)["auth"]
end