require File.dirname(__FILE__) + "/../lib/board"

describe Board do
  before do
    @board = Board.new(:players => 4)
  end
  
  it "should require number of players" do
    lambda {Board.new(:family_game => true)}.should raise_error
  end
  
  it "should default to full game" do
    b = Board.new(:players => 3)
    b.family_game?.should be_false
  end
  
  it "should set family_game" do
    b = Board.new(:players => 3, :family_game => true)
    b.family_game?.should be_true
  end
    
  it "should load the correct cards for 2 players normal game" do
    CardSets::Starting.should_receive(:cards).with(:players => 2, :family_game => nil)
    CardSets::Fixed.should_receive(:cards).with(:family_game => nil)
    Board.new(:players => 2)
  end

  it "should load the correct cards for 4 players family game" do
    CardSets::Starting.should_receive(:cards).with(:players => 4, :family_game => true)
    CardSets::Fixed.should_receive(:cards).with(:family_game => true)
    Board.new(:players => 4, :family_game => true)
  end
  
  # it "should handle a next turn" do
  #   @board.next_turn!.should be_true
  # end
  
  it "should know the latest uncovered card" do
    @board.last_uncovered_card.should be_nil
  end
  
  it "should uncover a card during next turn" do
    @board.next_turn!
    @board.last_uncovered_card.should be_instance_of(ActionCard)
  end
  
  it "should have a phases array" do
    b = Board.new(:players => 3, :family_game => false)
    b.should respond_to(:phases)
  end

  it "should have a phases array" do
    b = Board.new(:players => 3, :family_game => false)
    b.phases.size.should == 6
  end
  
  it "should have 4 actions on phase 1" do
    b = Board.new(:players => 3, :family_game => false)
    b.phases.first.size.should == 4
  end

  it "should have 3 actions on phase 2" do
    b = Board.new(:players => 3, :family_game => false)
    b.phases[1].size.should == 3
  end
  
  it "should have 2 actions on phase 3, 4 and 5" do
    b = Board.new(:players => 3, :family_game => false)
    b.phases[2].size.should == 2
    b.phases[3].size.should == 2
    b.phases[4].size.should == 2
  end

  it "should have 1 action on phase 6" do
    b = Board.new(:players => 3, :family_game => false)
    b.phases[5].size.should == 1
  end

  # it "should uncover a card during next turn" do
  #   latest_card = @board.latest_card
  # end
end