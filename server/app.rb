#!/usr/bin/env/ruby

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'rubygems'
require 'sinatra'
require 'json'
require 'board'


get '/games/:id/board' do
  content_type 'application/json'

  Board.new(:players => 4).to_json
end