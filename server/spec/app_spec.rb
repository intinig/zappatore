require File.dirname(__FILE__) + '/spec_helper'

describe "Zappatore" do
  include Rack::Test::Methods
  
  before :each do
    REDIS.flushall
  end
  
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
      login_as("intinig", "cefalonia")
      post "/login", :login => "intinig", :password => "cefalonia"
      last_response.status.should == 200
      JSON.parse(last_response.body)["auth"].should_not be_nil
    end
    
    it "should require a valid username" do
      post "/login", {:login => ";---$3inti\n"}
      last_response.status.should == 400
    end
    
    it "should set the username in the session" do
      login_as("intinig", "cefalonia")
      post "/login", :login => "intinig", :password => "cefalonia"
      last_response.body.should =~ /auth/
    end
  end
  
  describe "GET /rooms/sid" do
    it "should return all rooms" do
      auth = login_as("intinig", "cefalonia")
      post "/rooms/#{auth}"
      auth = login_as("pilu", "foo")
      post "/rooms/#{auth}"
      get "/rooms"
      last_response.status.should == 200
      rooms = JSON.parse(last_response.body)["rooms"]
      rooms.size.should == 2
      rooms.first["players"].include?("intinig").should be_true
      rooms.last["players"].include?("pilu").should be_true
    end
  end

  describe "PUT /rooms/rid/sid" do
    before :each do
      @auth = login_as("intinig", "cefalonia")
    end
    it "should require a valid room" do
      put "/rooms/xxx/#{@auth}"
      last_response.status.should == 404
    end
    
    it "should require a valid auth" do
      post "/rooms/#{@auth}"
      rid = JSON.parse(last_response.body)["id"].to_i
      put "/rooms/#{rid}/garzone"
      last_response.status.should == 403
    end
    
    it "should add a user to the room" do
      post "/rooms/#{@auth}"
      rid = JSON.parse(last_response.body)["id"].to_i
      auth = login_as("pilu", "ciao")
      put "/rooms/#{rid}/#{auth}"
      last_response.status.should == 200
      players = JSON.parse(last_response.body)["players"]
      players.size.should == 2
      players.include?("intinig").should be_true
      players.include?("pilu").should be_true
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
  
  describe "POST /signup" do
    it "should require a username" do
      post "/signup"
      last_response.status.should == 400
    end
        
    it "should require a valid username" do
      post "/signup", {:login => ";---$3inti\n"}
      last_response.status.should == 400
    end

    it "should require password and password confirmation" do
      post "/signup", {:login => 'intinig', :password => 'ciao'} 
      last_response.status.should == 409

      post "/signup", {:login => 'intinig', :confirm => 'ciao'} 
      last_response.status.should == 400
    end
    
    it "should check that password and password confirmation are the same" do
      post "/signup", {:login => 'intinig', :password => 'ciao', :confirm => 'oaic'} 
      last_response.status.should == 409
    end

    it "should signup if data is ok" do
      post "/signup", {:login => 'intinig', :password => 'ciao', :confirm => 'ciao'} 
      last_response.status.should == 200
    end
    
    it "should check for uniqueness of username" do
      post "/signup", {:login => 'intinig', :password => 'ciao', :confirm => 'ciao'} 
      post "/signup", {:login => 'intinig', :password => 'ciao', :confirm => 'ciao'} 
      last_response.status.should == 409
    end
  end
end