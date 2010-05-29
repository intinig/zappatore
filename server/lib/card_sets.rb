require File.dirname(__FILE__) + '/action_card'

module CardSets
  class Base
    def self.wood(n = 3)
      ActionCard.new(:description => "#{n} Wood", :per_turn => {:wood => n})
    end
        
    def self.clay(n = 1)
      ActionCard.new(:description => "#{n} Clay", :per_turn => {:clay => n})
    end
    
    def self.reed(n = 1)
      ActionCard.new(:description => "#{n} Reed", :per_turn => {:reed => n})
    end
    
    def self.fishing
      ActionCard.new(:description => "Fishing", :per_turn => {:food => 1})
    end
    
    def self.build_stables(wood = 2, multiple = true)
      description = "Build Stable"
      description += "(s)" if multiple
      ActionCard.new(:description => description, :actions => {:stable => {:wood => wood, :multiple => multiple}})
    end
    
    def self.build_family_stable
      self.build_stables(1, false)
    end
    
    def self.build_rooms
      ActionCard.new(:description => "Build Room(s)", 
        :rooms => {
          :wood => {:cost => {:wood => 5, :reed => 2}, :multiple => true},
          :clay => {:cost => {:clay => 5, :reed => 2}, :multiple => true},
          :stone => {:cost => {:stone => 5, :reed => 2}, :multiple => true}
        }
      )
    end
    
    def self.build_rooms_and_or_stables
      ActionCard.chain(self.build_rooms, self.build_stables, :and_or)
    end
    
    def self.starting_player
      ActionCard.new(:description => "Starting Player", :actions => {:starting_player => true})
    end
    
    def self.minor_improvement
      ActionCard.new(:description => "Minor Improvement", :actions => {:improvement => {:type => :minor, :multiple => false}})
    end
    
    def self.starting_player_and_or_minor_improvement
      ActionCard.chain(self.starting_player, self.minor_improvement, :and_or)
    end
    
    def self.one_grain
      ActionCard.new(:description => "1 Grain", :fixed => {:grain => 1})
    end
          
    def self.plow_one_field
      ActionCard.new(:description => "Plow 1 Field", :actions => {:plow => 1})
    end
    
    def self.occupation(prices)
      ActionCard.new(:description => "1 Occupation", :actions => {:occupation => prices})
    end
    
    def self.day_labourer
      ActionCard.new(:description => "Day Labourer", :fixed => {:food => 2})
    end
  
    def self.shop
      ActionCard.new(:description => "Shop", :fixed => {:food => 1})
    end
    
    def self.starting_player_and_shop
      ActionCard.chain(self.day_labourer, self.shop, :and)
    end
    
    def self.bake_bread
      ActionCard.new(:description => "Bake Bread", :actions => {:bake => true})
    end
    
    def self.build_stable_and_bake_bread
      ActionCard.chain(self.build_family_stable, self.bake_bread, :and_or)
    end
    
    def self.construction_resource(n = 1)
      description = "#{n} Construction Resource"
      description += "s" if n > 1
      ActionCard.new(:description => "#{n} Construction Resource", :fixed => {:construction => n})
    end
    
    def self.family_day_labourer
      ActionCard.new(:description => "Day Labourer", :fixed => {:food => 1, :construction => 1})
    end
    
    def self.reed_stone_food
      ActionCard.new(:description => "1 Reed, 1 Stone and 1 Food", :fixed => {:stone => 1, :food => 1, :reed => 1})
    end
    
    def self.traveling_players
      ActionCard.new(:description => "Traveling Players", :per_turn => {:food => 1})
    end
    
    def self.family_growth(space_needed = 1, turn = 5)
      ActionCard.new(:description => "Family Growth", :actions => {:family_growth => {:rooms => space_needed, :turn => turn}})
    end
    
    def self.reed_stone_wood
      ActionCard.new(:description => "1 Reed, 1 Stone and 1 Wood", :fixed => {:stone => 1, :wood => 1}, :per_turn => {:reed => 1})
    end
    
    def self.construction_resources_or_family_growth
      ActionCard.chain(self.construction_resource(2), self.family_growth, :or)
    end
    
    def self.occupation_or_family_growth
      ActionCard.chain(self.occupation([{:food => 1}, {:food => 1}, {:food => 2}]), self.family_growth, :or)
    end
    
    def self.build_rooms_or_traveling_players
      ActionCard.chain(self.build_rooms, self.traveling_players, :or)
    end
    
    def self.sheep_boar_cattle
      cattle = ActionCard.new(:description => "1 Food x 1 Cattle", :actions => {:trade => {:cost => {:food => 1}, :result => {:cattle => 1}, :multiple => false}})
      boar = ActionCard.new(:description => "1 Boar", :fixed => {:boar => 1})
      ActionCard.new(:description => "1 Sheep, 1 Food", :fixed => {:food => 1, :sheep => 1}, :or => [boar, cattle])
    end
    
    def self.minor_or_major_improvement
      ActionCard.new(:description => "1 Minor or 1 Major Improvement", :actions => {:improvement => {:type => :any, :multiple => false}})
    end
    
    def self.sow
      ActionCard.new(:description => "Sow", :actions => {:sow => true})
    end
    
    def self.sow_and_or_bake_bread
      ActionCard.chain(self.bake_bread, self.sow, :and_or)
    end
    
    def self.build_fences
      ActionCard.new(:description => "Build Fences", :actions => {
        :fences => {:wood => 1}
      })
    end
    
    def self.sheep
      ActionCard.new(:description => "1 Sheep", :fixed => {:sheep => 1})
    end

    def self.boar
      ActionCard.new(:description => "1 Boar", :fixed => {:boar => 1})
    end
    
    def self.cattle
      ActionCard.new(:description => "1 Cattle", :fixed => {:cattle => 1})
    end
    
    def self.after_family_growth_minor_improvement
      ActionCard.chain(self.family_growth, self.minor_improvement, :after)
    end
    
    def self.vegetable
      ActionCard.new(:description => "1 Vegetable", :per_turn => {:vegetable => 1})
    end
    
    def self.plow_and_sow
      ActionCard.chain(self.plow_one_field, self.sow, :and_or)
    end
    
    def self.after_renovate_build_fences
      ActionCard.chain(self.renovate, self.build_fences, :after)
    end
    
    def self.renovate
      ActionCard.new(:description => "Renovate", :actions => {
        :renovate => {
          :clay => {
            :per_room => {:clay => 1},
            :fixed => {:reed => 1}
          },
          :stone => {
            :per_room => {:clay => 1},
            :fixed => {:reed => 1}
          }
        }
      })
    end
    
    def self.renovate_and_minor_or_major_improvement
      ActionCard.chain(self.renovate, self.minor_or_major_improvement, :after)
    end
    
    def self.stone(n)
      ActionCard.new(:description => "#{n} Stone", :per_turn => {:stone => 1})
    end
  end
  
  class Fixed
    def self.cards(options = {})
      if options[:family_game]
        [Base.build_rooms_and_or_stables, Base.starting_player_and_shop, Base.one_grain, Base.plow_one_field, Base.build_stable_and_bake_bread, Base.family_day_labourer, Base.wood(3), Base.clay(1), Base.reed(1), Base.fishing]
      else
        [Base.build_rooms_and_or_stables, Base.starting_player_and_or_minor_improvement, Base.one_grain, Base.plow_one_field, Base.occupation([{:food => 0}, {:food => 1}]), Base.day_labourer, Base.wood(3), Base.clay(1), Base.reed(1), Base.fishing]
      end
    end
  end
  
  class Starting
    def self.cards(options = {})
      if options[:players] == 1 || options[:players] == 2
        [nil, nil, nil, nil, nil, nil]
      elsif options[:players] == 3
        if options[:family_game]
          [Base.construction_resource(2), Base.wood(2), Base.construction_resource(1), Base.clay(1), nil, nil]
        else
          [Base.occupation([{:food => 2}]), Base.wood(2), Base.construction_resource(1), Base.clay(1), nil, nil]
        end
      elsif options[:players] == 4
        if options[:family_game]
          [Base.wood(1), Base.wood(2), Base.reed_stone_food, Base.clay(2), Base.traveling_players, Base.construction_resource(2)]
        else
          [Base.wood(1), Base.wood(2), Base.reed_stone_food, Base.clay(2), Base.traveling_players, Base.occupation([{:food => 1}, {:food => 1}, {:food => 2}])]          
        end        
      elsif options[:players] == 5
        if options[:family_game]
          [Base.wood(4), Base.construction_resources_or_family_growth, Base.clay(3), Base.reed_stone_wood, Base.build_rooms_or_traveling_players, Base.sheep_boar_cattle]
        else
          [Base.wood(4), Base.occupation_or_family_growth, Base.clay(3), Base.reed_stone_wood, Base.build_rooms_or_traveling_players, Base.sheep_boar_cattle]
        end        
      end
    end
  end
  
  class Turn
    def self.cards(options = {})
      [
        [Base.minor_or_major_improvement, Base.sow_and_or_bake_bread, Base.build_fences, Base.sheep], 
        [Base.after_family_growth_minor_improvement, Base.renovate_and_minor_or_major_improvement, Base.stone(1)], 
        [Base.vegetable, Base.boar], 
        [Base.cattle, Base.stone(1)], 
        [Base.plow_and_sow, Base.family_growth(0)],
        [Base.after_renovate_build_fences]
      ]
    end
    
    def self.shuffled_cards(options = {})
      cardset = self.cards.dup
      cardset.each do |set|
        set.shuffle!
      end
      cardset.flatten.each do |card|
        card.revealed = false
      end
      cardset
    end
  end
end