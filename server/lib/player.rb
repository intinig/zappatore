require 'common'
require 'farm'

class Player
  attr_accessor :starting_player, :color, :farm, :food
  
  def initialize(color)
    @color = color
    @farm = Farm.new
  end
end