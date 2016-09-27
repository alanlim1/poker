class DeckController < ApplicationController
  before_action :authenticate_user!

  def deal_common_cards
    common = Array.new(5) { deck.shift }
  end

  def hole
    hole = Array.new(number_of_players) { Array.new(2) { deck.shift } }

    # activeplayer.define_singleton_method(:hole)
    # end
    @activeplayers.each_with_index do |activeplayer, index|
      $redis.sadd("Game", {activeplayer[index] => hole[index]}) 
    end

    

  end

  private

  def number_of_players
    Table.player_id.count
  end

  # def player
  #   @player = Player.find_by(params: player_id)
  #   @activeplayers = $
  #   @activeplayers.order(:timestamp_entered_table)
  # end

  if current_user == true || user_signed_in?
    $redis.set("Game", current_user.id)
  end  
end
