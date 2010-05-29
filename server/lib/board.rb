$LOAD_PATH.unshift(File.dirname(__FILE__) + '/')

require 'rubygems'
require 'common'
require 'card_sets'
require 'json'

class Board
  attr_reader :starting, :default, :phases, :turn_actions
  
  def initialize(options = {})
    @players = options.delete(:players) || raise("Must specify number of players")
    @family_game = options.delete(:family_game)
    @starting = CardSets::Starting.cards(:players => @players, :family_game => @family_game)
    @default = CardSets::Fixed.cards(:family_game => @family_game)
    @phases = CardSets::Turn.shuffled_cards
    @turn_actions = @phases.flatten
  end
  
  def family_game?
    @family_game == true
  end
    
  def last_uncovered_card
    @turn_actions.find_all{|a| a.revealed == true}.first
  end  
  
  def first_covered_card
    @turn_actions.find_all{|a| a.revealed == false}.first
  end
  
  def next_turn!
    @starting.each do |action|
      action.next_turn!
    end
        
    @default.each do |action|
      action.next_turn!
    end
    
    @turn_actions.each do |action|
      first_covered_card.revealed = true
      action.next_turn!
    end
  end
  
  def to_json(*a)        
    {
      :family_game => family_game?,
      :default => @default,
      :starting => @starting,
      :phases => @phases
    }.to_json(*a)
  end
end
