require 'common'
require 'player'
require 'board'

class Game
  attr_accessor :players, :family, :board
  
  def initialize(players_number, family = false)
    raise "Can't have more than 5 players" if players_number > 5
    raise "Can't have less than 1 player" if players_number < 1
    
    @board = Board.new(players_number, family)
    @family = family
    @players = []
    players_number.times do |i|
      player = Player.new(i)
      player.food = 3
      @players << player
    end
    splayer = @players[rand(players_number)]
    splayer.starting_player = true
    splayer.food = 2
  end
  
  def starting_player
    @players.each do |player|
      return player if player.starting_player
    end
  end
end
