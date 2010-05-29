require File.dirname(__FILE__) + "/../lib/card_sets"

describe CardSets::Fixed do
  it "should have the basic cards" do
    CardSets::Fixed.cards.size.should == 10
  end
  
  it "should have the basic cards in family game" do
    CardSets::Fixed.cards(:family_game => true).size.should == 10
  end
end

describe CardSets::Starting do
  it "should not have cards for a 1 and 2 player game" do
    CardSets::Starting.cards(:players => 1).should == [nil, nil, nil, nil, nil, nil]
    CardSets::Starting.cards(:players => 2).should == [nil, nil, nil, nil, nil, nil]
  end

  it "should not have 4 cards for a 3 player game" do
    CardSets::Starting.cards(:players => 3)[0,4].each do |card|
      card.should be_instance_of(ActionCard)
    end
    CardSets::Starting.cards(:players => 3)[4,2].should == [nil,nil]
  end

  it "should not have 4 cards for a 3 player family game" do
    CardSets::Starting.cards(:players => 3, :family_game => true)[0,4].each do |card|
      card.should be_instance_of(ActionCard)
    end
    CardSets::Starting.cards(:players => 3, :family_game => true)[4,2].should == [nil,nil]
  end
  
  it "should have 6 cards for a 4 or 5 player game" do
    c = CardSets::Starting.cards(:players => 4).each do |card|
      card.should be_instance_of(ActionCard)
    end
    c.size.should == 6
    c = CardSets::Starting.cards(:players => 5).each do |card|
      card.should be_instance_of(ActionCard)
    end
    c.size.should == 6
  end

  it "should have 6 cards for a 4 or 5 player family game" do
    c = CardSets::Starting.cards(:players => 4, :family_game => true).each do |card|
      card.should be_instance_of(ActionCard)
    end
    c.size.should == 6
    c = CardSets::Starting.cards(:players => 5, :family_game => true).each do |card|
      card.should be_instance_of(ActionCard)
    end
    c.size.should == 6
  end
end

describe CardSets::Turn do
  it "should have 14 cards in total with" do
    c = CardSets::Turn.cards.flatten.each do |card|
      card.should be_instance_of(ActionCard)
    end
    c.size.should == 14
  end
  
  it "should shuffle cards" do 
    c = CardSets::Turn.cards
    d = CardSets::Turn.shuffled_cards
    c.should_not == d
    d.each do |card|
      card.revealed.should be_false
    end
  end
end