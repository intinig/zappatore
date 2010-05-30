#require File.dirname(__FILE__) + '/../game'

# describe Game, "initialization" do
#   it "should take a list of players" do
#     lambda {Game.new}.should raise_error
#     game = Game.new(4)
#     game.should be_instance_of(Game)
#     game.players.size.should == 4
#   end
#   
#   it "should initialize the players" do
#     p = Player.new(0)
#     Player.should_receive(:new).exactly(4).times.and_return(p)
#     game = Game.new(4)
#   end
#   
#   it "should randomly set the starting player" do
#     game = Game.new(1)
#     game.starting_player.should == game.players.first
#   end
#   
#   it "should give 3 food to all players but the starting player" do
#     game = Game.new(3)
#     game.players.each do |player|
#       player.food.should == 3 unless player.starting_player
#       player.food.should == 2 if player.starting_player
#     end
#   end
#   
#   it "should take a parameter to decide whether it is a family game or not" do
#     game = Game.new(4)
#     game.family.should be_false
#     game = Game.new(3, true)
#     game.family.should be_true
#   end
#   
#   it "should not accept more than 5 players" do
#     lambda {Game.new(6)}.should raise_error
#   end
# 
#   it "should not accept less than 1 player" do
#     lambda {Game.new(0)}.should raise_error
#   end
#   
#   it "should instantiate a board" do
#     game = Game.new(3)
#     game.board.should be_instance_of(Board)
#   end
#   
#   it "should setup the board for the correct number of players" do
#     b = Board.new(3)
#     Board.should_receive(:new).with(3, false).and_return(b)
#     game = Game.new(3)
#   end
#   
#   it "should setup the board for the correct type of game" do
#     b = Board.new(3, true)
#     Board.should_receive(:new).with(3, true).and_return(b)
#     game = Game.new(3, true)
#   end
#   
#   it "should go to first turn" do
#     pending
#   end
#   
#   it "should deal cards unless it's a family game" do
#     pending
#   end
#end