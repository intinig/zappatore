require File.dirname(__FILE__) + "/../lib/shufflable.rb"

Array.class_eval do
  include Shufflable
end

module Kernel
  def rand(n)
    0
  end
end

describe "Shufflable" do
  it "should shuffle 1 element arrays" do
    a = [1]
    a.shuffle!
    a.should == [1]
  end
  
  it "should shuffle n elements arrays" do
    a = [1,2,3,4,5]
    a.shuffle!
    a.should == [2,3,4,5,1]
  end
end