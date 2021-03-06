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
require 'pusher'

redis_host = ENV["REDIS_HOST"] || "127.0.0.1"
redis_port = ENV["REDIS_PORT"] || 6379

REDIS = Redis.new(:host => redis_host, :port => redis_port)

Pusher.app_id = '1231'
Pusher.key = '0788cbceb5387c7f2eb8'
Pusher.secret = '7b1319e09f5a0c36d8d5'

before do
  content_type :json
end

get '/games/:id/board' do
  j Board.new(:players => 4).to_json
end

post '/games/:rid/:auth' do
  login_required
  halt 404 unless REDIS.sismember("rid:#{params[:rid]}:players", REDIS.get("uid:#{@uid}:login")) && 
                  REDIS.get("uid:#{@uid}:rid") == params[:rid]
  gid = REDIS.incr("global:nextGameId")
  # new game here
end

get '/rooms' do
  rooms = []
  room_keys = REDIS.keys("rid:*:players")
  room_keys.each do |k|
    rooms << {:rid => k.split(":")[1], :players => REDIS.smembers(k)}
  end
  j({:rooms => rooms}.to_json)
end

post '/rooms/:auth' do
  login_required(403)
  rid = REDIS.incr("global:nextRoomId")
  login = REDIS.get("uid:#{@uid}:login")
  REDIS.sadd("rid:#{rid}:players", login)
  REDIS.set("uid:#{@uid}:rid", rid)
  Pusher['zappatore-main'].trigger('room-create', {:players => [login], :rid => rid})
  j({:id => rid}.to_json)
end

get '/rooms/:rid/:auth' do
  login_required(403)
  room = REDIS.smembers("rid:#{params[:rid]}:players")
  halt 404 if room.nil?
  j({:players => room}.to_json)
end

put '/rooms/:rid/:auth' do
  login_required(403)
  login = REDIS.get("uid:#{@uid}:login")
  room = REDIS.smembers("rid:#{params[:rid]}:players")
  halt 404 if room.nil?
  REDIS.sadd("rid:#{params[:rid]}:players", login)
  room = REDIS.smembers("rid:#{params[:rid]}:players")
  j({:players => room}.to_json)
end

delete '/rooms/:rid/:auth' do
  login_required(403)
  halt 404 unless (rid = REDIS.get("uid:#{@uid}:rid")) == params[:rid]
  login = REDIS.get("uid:#{@uid}:login")
  REDIS.del("uid:#{@uid}:rid")
  REDIS.srem("rid:#{rid}:players", REDIS.get("uid:#{@uid}:login"))
  Pusher['zappatore-main'].trigger('room-destroy', {:players => [login], :rid => rid})
end

post '/signup' do
  halt 400, "Missing login" unless params[:login] && params[:login].match(/^\w+$/)
  halt 400, "Missing password" unless params[:password]
  halt 409, "Passwords do not match" unless params[:password] == params[:confirm]
  halt 409, "Login already taken" if REDIS.get("login:#{params[:login]}:uid")
  uid = REDIS.incr('global:nextUserId')
  REDIS.set("login:#{params[:login]}:uid", uid)
  REDIS.set("uid:#{uid}:login", params[:login])
  REDIS.set("uid:#{uid}:password", params[:password])
  auth = set_auth_data(uid)
  j({:auth => auth}.to_json)
end

post '/login' do
  halt 400, "Missing login" unless params[:login] && params[:login].match(/^\w+$/)
  if (uid = REDIS.get("login:#{params[:login]}:uid")) && params[:password] == REDIS.get("uid:#{uid}:password")
    auth = set_auth_data(uid)
    j({:auth => auth}.to_json)
  else
    halt 403, "Wrong credentials supplied."
  end
end

# forse è un errore farlo in get?
get '/logout/:auth' do
  login_required
  set_auth_data(@uid)
  j({}.to_json)
end

get '/sessions/:auth' do
  login_required
  login = REDIS.get("uid:#{@uid}:login")
  room = REDIS.get("uid:#{@uid}:rid")
  j({:login => login, :room => room}.to_json)
end

private

def set_auth_data(uid)
  auth = Digest::MD5.hexdigest("#{Time.now}--#{uid}--#{rand(65535)}")
  REDIS.set("uid:#{uid}:auth", auth)
  REDIS.set("auth:#{auth}", uid)
  REDIS.expire("auth:#{auth}", 60 * 24 * 14)
  auth
end

def login_required(error = 404)
  halt error unless @uid = REDIS.get("auth:#{params[:auth]}")  
  halt error unless params[:auth] == REDIS.get("uid:#{@uid}:auth")    
end

def j(retval)
  if callback = params["callback"]
    "#{callback}(#{retval})"
  else
    retval
  end
end