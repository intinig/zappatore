require File.dirname(__FILE__) + '/spec_helper'

describe "Zappatore" do
  include Rack::Test::Methods
  
  def app
    @app ||= Sinatra::Application
  end
  
  describe "POST /games/rid/sid" do
    it "should require a valid session and a valid room" do
      auth = login_as("intinig", "cefalonia")
      post "/games/sarabanda/#{auth}"
      last_response.status.should == 404
    end
    
    it "should require the caller to be in the room" do
      auth = login_as("intinig", "cefalonia")
      post "/rooms/#{auth}"
      rid = JSON.parse(last_response.body)["id"]
      auth = login_as("enzo", "pardon")
      post "/games/#{rid}/#{auth}"
      last_response.status.should == 404
    end

    it "should require a room"
    it "should require a person in the room"
  end
    
  describe "POST /login" do
    it "should require a username" do
      post "/login"
      last_response.status.should == 400
    end
    
    it "should accept a username" do
      post "/login", :login => "intinig"
      last_response.status.should == 200
      JSON.parse(last_response.body)["auth"].should_not be_nil
    end
    
    it "should require a valid username" do
      post "/login", {:login => ";---$3inti\n"}
      last_response.status.should == 400
    end
    
    it "should set the username in the session" do
      post "/login", :login => "intinig"
      last_response.body.should =~ /auth/
    end
  end
  
  describe "GET /rooms/sid" do
    it "should require a session" do
      get "/rooms"
      last_response.status.should == 404
    end

    it "should require a valid session" do
      get "/rooms/falsesession"
      last_response.status.should == 403
    end
    
    it "should work with a valid session" do
      auth = login_as("intinig", "cefalonia")
      get "/rooms/#{auth}"
      last_response.status.should == 200
      JSON.parse(last_response.body)["rooms"].should == []
    end
  end

  describe "POST /rooms/sid" do
    it "should require a session" do
      post "/rooms"
      last_response.status.should == 404
    end

    it "should require a valid session" do
      post "/rooms/falsesession"
      last_response.status.should == 403
    end
    
    it "should work with a valid session" do
      auth = login_as("intinig", "cefalonia")
      post "/rooms/#{auth}"
      last_response.status.should == 200
      JSON.parse(last_response.body)["id"].to_i.should > 0
    end
    
    it "should return a valid room" do
      auth = login_as("intinig", "cefalonia")
      post "/rooms/#{auth}"
      room_id = JSON.parse(last_response.body)["id"]
      get "/rooms/#{room_id}/#{auth}"
      last_response.status.should == 200
      JSON.parse(last_response.body)["players"].include?("intinig").should be_true
    end
  end
  
  describe "DELETE /rooms/rid/auth" do
    it "should require a session" do
      delete "/rooms/1"
      last_response.status.should == 404
    end

    it "should require a valid session" do
      delete "/rooms/1/falsesession"
      last_response.status.should == 403
    end
    
    it "should require a valid session and a valid room" do
      auth = login_as("intinig", "cefalonia")
      delete "/rooms/sarabanda/#{auth}"
      last_response.status.should == 404
    end
    
    it "should work with a valid session and a valid room" do
      auth = login_as("intinig", "cefalonia")
      post "/rooms/#{auth}"
      rid = JSON.parse(last_response.body)["id"]
      
      delete "/rooms/#{rid}/#{auth}"
      last_response.status.should == 200
    end
    
    it "should remove player from room" do
      auth = login_as("intinig", "cefalonia")
      post "/rooms/#{auth}"
      rid = JSON.parse(last_response.body)["id"]
      uid = REDIS.get("login:intinig:uid")
      
      delete "/rooms/#{rid}/#{auth}"
      REDIS.get("uid:#{uid}:rid").should be_nil
      REDIS.sismember("rid:#{rid}:players", "intinig").should be_false
    end
  end
end