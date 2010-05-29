begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'sinatra'
require 'json'
require 'redis'
require 'board'
require 'digest/md5'

redis_host = ENV["REDIS_HOST"] || "127.0.0.1"
redis_port = ENV["REDIS_PORT"] || 6379

REDIS = Redis.new(:host => redis_host, :port => redis_port)

before do
  content_type :json
end

get '/games/:id/board' do

  Board.new(:players => 4).to_json
end

post '/games' do
  uid = login_required(params[:id])
  halt 403, "Forbidden" if REDIS.get
end

get '/rooms' do
  {:rooms => [{:id => 1, :players => []}]}.to_json
end

put '/rooms/:id' do
  {:rooms => [{:id => 1, :players => []}]}.to_json
end

post '/login' do
  halt 400, "Missing login" unless params[:login] && params[:login].match(/^\w+$/)
  if uid = REDIS.get("login:#{params[:login]}:uid")
    # check for password
    auth = set_auth_data(uid)
    {:auth => auth}.to_json
  else
    halt 403, "Wrong credentials supplied."
  end
end

# forse è un errore farlo in get?
get '/logout/:id' do
  uid = login_required(params[:id])
  set_auth_data(uid)
  {}.to_json  
end

get '/sessions/:id' do
  uid = login_required(params[:id])
  login = REDIS.get("uid:#{uid}:login")
  {:login => login}.to_json
end

private

def set_auth_data(uid)
  auth = Digest::MD5.hexdigest("#{Time.now}--#{uid}--#{rand(65535)}")
  REDIS.set("uid:#{uid}:auth", auth)
  REDIS.set("auth:#{auth}", uid)
  REDIS.expire("auth:#{auth}", 60 * 24 * 14)
  auth
end

def login_required(auth)
  halt 404 unless uid = REDIS.get("auth:#{auth}")
  halt 404 unless auth == REDIS.get("uid:#{uid}:auth")
  uid
end