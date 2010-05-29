require File.dirname(__FILE__) + '/spec_helper'

describe "Zappatore" do
  include Rack::Test::Methods
  
  def app
    @app ||= Sinatra::Application
  end
  
  describe "POST /games" do
    it "should send me away" do
      post "/games"
      last_response.status.should == 403
    end
  end
  
  describe "GET /rooms" do
    it "should give me one available room" do
      get "/rooms"
      last_response.content_type.should == "application/json"
      JSON.parse(last_response.body)["rooms"].size.should == 1
    end
  end
  
  describe "PUT /rooms/:id" do
    it "should make me enter that room" do
      pending
      # put "/rooms/1"
      # last_response.content_type.should == "application/json"
      # JSON.parse(last_response.body)["rooms"].size.should == 1
    end
  end
  
  describe "POST /login" do
    it "should require a username" do
      post "/login"
      last_response.status.should == 400
    end
    
    it "should accept a username" do
      post "/login", :login => "intinig"
      last_response.status.should == 200
      JSON.parse(last_response.body)["login"].should == "intinig"
    end
    
    it "should require a valid username" do
      post "/login", {:login => ";---$3inti\n"}
      last_response.status.should == 400
    end
    
    it "should set the username in the session" do
      post "/login", :login => "intinig"
      session["login"].should == "intinig"
    end
  end
end