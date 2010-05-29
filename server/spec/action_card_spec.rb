require File.dirname(__FILE__) + "/../lib/action_card"

describe ActionCard do
  it "should have an id" do
    a = ActionCard.new(:description => "2 Wood", :id => "4pl-2-wood")
    a.id.should == "4pl-2-wood"
  end
  
  it "should have a default id" do
    a = ActionCard.new(:description => "2 Wood")
    a.id.should == "2-wood"
  end
  
  it "should be covered or uncovered" do
    a = ActionCard.new(:description => "2 Wood", :covered => true)
    a.revealed.should be_true
  end
  
  it "should accept description" do
    a = ActionCard.new(:description => "2 Wood")
    a.description.should == "2 Wood"
  end
  
  it "should require description" do
    lambda {ActionCard.new()}.should raise_error
  end
  
  it "should store resources on it" do
    a = ActionCard.new(:description => "2 Wood")
    a.wood.should == 0
    a.add_resources(:wood => 6)
    a.wood.should == 6
  end
  
  it "should handle construction resources" do
    a = ActionCard.new(:description => "2 Wood", :wood => 1, :reed => 2, :clay => 3, :stone => 4)
    a.wood.should == 1
    a.reed.should == 2
    a.clay.should == 3
    a.stone.should == 4
  end
  
  it "should handle food" do
    a = ActionCard.new(:description => "2 Wood", :food => 1)
    a.food.should == 1
  end
  
  it "should handle animals" do
    a = ActionCard.new(:description => "2 Wood", :sheep => 1, :boar => 2, :cattle => 3)
    a.sheep.should == 1
    a.boar.should == 2
    a.cattle.should == 3
  end
  
  it "should handle grain and vegetables" do
    a = ActionCard.new(:description => "2 Wood", :vegetable => 1, :grain => 1)
    a.grain.should == 1
    a.vegetable.should == 1
  end
  
  it "should allow playing an occupation" do
    a = ActionCard.new(:description => "1 Occupation", :actions => {:occupation => [{:food => 0}, {:food => 1}]})
    a.allows_occupation?.should be_true
    a.occupation_price(0).should == {:food => 0}
    a.occupation_price(1).should == {:food => 1}
    a.occupation_price(2).should == {:food => 1}
    a.occupation_price(5).should == {:food => 1}
  end
  
  it "should allow building a room" do
    a = ActionCard.new(:description => "Build 1 Room", :actions => {:rooms => room_cost})
    
    a.allows_building_rooms?(:wood).should be_true
    a.allows_building_rooms?(:clay).should be_true
    a.allows_building_rooms?(:stone).should be_true
    
    a.room_price(:wood).should == {:wood => 5, :reed => 2}
    a.room_price(:clay).should == {:clay => 5, :reed => 2}
    a.room_price(:stone).should == {:stone => 5, :reed => 2}
    a.allows_building_multiple_rooms?(:wood).should be_true
    a.allows_building_multiple_rooms?(:clay).should be_true
    a.allows_building_multiple_rooms?(:stone).should_not be_true
  end
  
  it "should allow fixed amounts of resources" do
    a = ActionCard.new(:description => "2 Wood", :fixed => {:wood => 2})
    a.act!.should == {:resources => {:wood => 2}, :required_actions => {}}
    a.next_turn!
    a.act!.should == {:resources => {:wood => 2}, :required_actions => {}}
  end
  
  it "should allow per_turn amounts of resources" do
    a = ActionCard.new(:description => "2 Wood", :per_turn => {:wood => 2})
    a.act!.should == {:resources => {}, :required_actions => {}}
    a.next_turn!
    a.act!.should == {:resources => {:wood => 2}, :required_actions => {}}
    a.next_turn!
    a.next_turn!
    a.next_turn!
    a.act!.should == {:resources => {:wood => 6}, :required_actions => {}}
  end
  
  it "should allow mixed resources" do
    a = ActionCard.new(:description => "1 Reed + 1 Stone and 1 Wood", :per_turn => {:reed => 1}, :fixed => {:wood => 1, :stone => 1})
    a.next_turn!
    a.next_turn!
    a.act!.should == {:resources => {:reed => 2, :wood => 1, :stone => 1}, :required_actions => {}}
    a.act!.should == {:resources => {:wood => 1, :stone => 1}, :required_actions => {}}
  end
  
  it "should allow A or B effects" do
    food = ActionCard.new(:description => "1 Food", :per_turn => {:food => 1})
    a = ActionCard.new(:description => "2 Wood or 1 Food", :per_turn => {:wood => 2}, :or => food)
    a.next_turn!
    a.act!(:or => true).should == {:resources => {:food => 1}, :required_actions => {}}
    a.next_turn!
    a.wood.should == 4
    a.or_card.food.should == 1
  end
  
  it "should allow A and/or B effects" do
    food = ActionCard.new(:description => "1 Food", :per_turn => {:food => 1})
    a = ActionCard.new(:description => "2 Wood or 1 Food", :per_turn => {:wood => 2}, :and_or => food)
    a.next_turn!
    a.act!(:and_or => :or).should == {:resources => {:food => 1}, :required_actions => {}}
    a.next_turn!
    a.act!(:and_or => true).should == {:resources => {:wood => 4, :food => 1}, :allowed_actions => {}}
    a.next_turn!
    a.wood.should == 2
    a.and_or_card.food.should == 1
  end
  
  it "should allow B after A effects" do
    food = ActionCard.new(:description => "1 Food", :per_turn => {:food => 1})
    a = ActionCard.new(:description => "2 Wood or 1 Food", :per_turn => {:wood => 2}, :after => food)
    a.next_turn!
    a.act!(:after => true).should == {:resources => {:wood => 2, :food => 1}, :required_actions => {}, :allowed_actions => {}}
    a.next_turn!
    a.act!.should == {:resources => {:wood => 2}, :required_actions => {}, :allowed_actions => {}}
    a.next_turn!
    a.wood.should == 2
    a.after_card.food.should == 2
  end
  
  it "should return required actions" do
    a = ActionCard.new(:description => "Build Room", :actions => {:rooms => room_cost})
    a.act!.should == {:required_actions => {:rooms => room_cost}, :resources => {}}
  end
  
  it "should allow A and B effects" do
    food = ActionCard.new(:description => "Shop", :fixed => {:food => 1})
    a = ActionCard.new(:description => "Primo Giocatore", :actions => {:starting_player => true}, :and => food)
    a.act!.should == {:resources => {:food => 1}, :required_actions => {:starting_player => true}}
  end
  
  it "should allow A and/or B split actions" do
    improvement = ActionCard.new(:description => "Piccolo Miglioramento", :actions => {:minor_improvent => :single})
    a = ActionCard.new(:description => "Primo Giocatore", :actions => {:starting_player => true}, :and_or => improvement)
    a.act!.should == {:resources => {}, :allowed_actions => {:starting_player => true, :minor_improvent => :single}}
  end

  it "should allow building stables" do
    a = ActionCard.new(:description => "Build Stable(s)", 
      :actions => {
        :stables => stable_cost
      }
    )
    
    a.act!.should == {:required_actions => {:stables => stable_cost}, :resources => {}}
  end
  
  it "should allow starting player" do
    a = ActionCard.new(:description => "Starting Player", :actions => {:starting_player => true})
    a.act!.should == {:required_actions => {:starting_player => true}, :resources => {}}
  end
  
  it "should allow improvements" do
    a = ActionCard.new(:description => "Minor Improvement", :actions => {:improvement => {:type => :minor, :multiple => false}})
    a.act!.should == {:required_actions => {:improvement => {:type => :minor, :multiple => false}}, :resources => {}}
  end
  
  it "should allow plowing" do
    a = ActionCard.new(:description => "Plow 1 Field", :actions => {:plow => 1})
    a.act!.should == {:required_actions => {:plow => 1}, :resources => {}}
  end
  
  it "should allow sowing" do
    a = ActionCard.new(:description => "Sow", :actions => {:sow => true})
    a.act!.should == {:required_actions => {:sow => true}, :resources => {}}
  end
  
  it "should allow baking bread" do
    a = ActionCard.new(:description => "Bake", :actions => {:bake => true})
    a.act!.should == {:required_actions => {:bake => true}, :resources => {}}
  end
  
  it "should allow family growth" do
    a = ActionCard.new(:description => "Family Growth", :actions => {
      :family_growth => {
        :rooms => 1,
      }
    })
    a.act!.should == {:required_actions => {
      :family_growth => {
        :rooms => 1,
        :haste => false,
        :multiple => false
      }
    }, :resources => {}}
  end
  
  it "should allow fences" do
    a = ActionCard.new(:description => "Build Fences", :actions => {
      :fences => {:wood => 1}
    })
    a.act!.should == {:required_actions => {:fences => {:wood => 1}}, :resources => {}}
  end
  
  it "should allow renovation" do
    a = ActionCard.new(:description => "Renovate", :actions => {
      :renovate => renovation_cost
    })
    a.act!.should == {:required_actions => {:renovate => renovation_cost}, :resources => {}}
  end
    
  it "should allow a or b or c effects" do
    sheep = ActionCard.new(:description => "1 Sheep", :per_turn => {:sheep => 1})
    boar = ActionCard.new(:description => "1 Boar", :per_turn => {:boar => 1})
    a = ActionCard.new(:description => "1 Cattle", :per_turn => {:cattle => 1}, :or => [sheep, boar])
    a.next_turn!
    a.act!.should == {:resources => {:cattle => 1}, :required_actions => {}}
    a.next_turn!
    a.act!(:or => 0).should == {:resources => {:sheep => 2}, :required_actions => {}}
    a.next_turn!
    a.act!(:or => 1).should == {:resources => {:boar => 3}, :required_actions => {}}
  end
  
  it "should allow trade effects" do
    a = ActionCard.new(:description => "1 Food x 1 Cattle", :actions => {:trade => {:cost => {:food => 1}, :result => {:cattle => 1}, :multiple => false}})
    a.act!.should == {:required_actions => {:trade => {:cost => {:food => 1}, :result => {:cattle => 1}, :multiple => false}}, :resources => {}}
  end
  
  it "should allow multiple trade effects" do
    a = ActionCard.new(:description => "focolare", :actions => {:trade => [{:cost => {:sheep => 1}, :result => {:food => 2}}, {:cost => {:boar => 1}, :result => {:food => 2}}, {:cost => {:vegetable => 1}, :result => {:food => 3}}]})
    a.act!.should == {
      :resources => {},
      :required_actions => {
        :trade => [
          {:cost => {:sheep => 1}, :result => {:food => 2}, :multiple => true},
          {:cost => {:boar => 1}, :result => {:food => 2}, :multiple => true},
          {:cost => {:vegetable => 1}, :result => {:food => 3}, :multiple => true},
        ]
      }
    }
  end
  
  it "should allow trade effects with baking requirements" do
    a = ActionCard.new(:description => "Forno", :actions => {:trade => {:cost => {:grain => 1}, :result => {:food => 5}, :bake => 1}})
    a.act!.should == {
      :resources => {},
      :required_actions => {
        :trade => {:cost => {:grain => 1}, :result => {:food => 5}, :bake => 1}
      }
    }
  end
  
  private
  def room_cost
    {
        :wood => {:cost => {:wood => 5, :reed => 2}, :multiple => true},
        :clay => {:cost => {:clay => 5, :reed => 2}, :multiple => true},
        :stone => {:cost => {:stone => 5, :reed => 2}}
    }
  end
  
  def renovation_cost
    {
      :clay => {
        :per_room => {:clay => 1},
        :fixed => {:reed => 1}
      },
      :stone => {
        :per_room => {:clay => 1},
        :fixed => {:reed => 1}
      }
    }
  end
  
  def stable_cost
    {
      :cost => {:wood => 2}, 
      :multiple => true
    }
  end
end

describe ActionCard, "relationships" do
  it "should be able to combine cards in a relationship" do
    wood = ActionCard.new(:description => "3 Wood", :per_turn => {:wood => 3})
    clay = ActionCard.new(:description => "1 Clay", :per_turn => {:clay => 1})
    
    ActionCard.chain(wood, clay, :and_or).should == ActionCard.new(
      :description => "3 Wood", :per_turn => {:wood => 3}, :and_or => clay
    )
  end
end