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
require 'curb'

before do
  @url = params.delete("url")
  @extra_params = params.map {|k, v| Curl::PostField.content(k, v)}
end

get "/" do
  erb :index
end

post "/p" do
  @c = Curl::Easy.http_post(@url, @extra_params)
  
  handle_headers
  handle_response
end

get "/p" do
  @c = Curl::Easy.http_get(@url)
  
  handle_headers
  handle_response
end

put "/p" do
  @c = Curl::Easy.http_put(@url, @extra_params)
  
  handle_headers
  handle_response
end

delete "/p" do
  @extra_params << Curl::PostField.content("_method", "DELETE")
  @c = Curl::Easy.http_post(@url, @extra_params)
  
  handle_headers
  handle_response
end

private

def handle_response
  if @c.response_code >= 400
    halt @c.response_code, @c.body_str
  elsif @c.response_code >= 200
    @c.body_str
  else
    halt 501, @c.body_str
  end
end

def handle_headers
  if @c.header_str =~ /Content-Type: (.*)(\r)?\n/
    content_type $1
  end
end