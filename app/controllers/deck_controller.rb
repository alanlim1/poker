class DeckController < ApplicationController
  before_action :authenticate_user!

  def deck
    FACES="AKQJT98765432"
    SUITS="cdhs"

    deck = []

    FACES.each_byte do |f|
      SUITS.each_byte do |s|
        deck.push(f.chr + s.chr)
      end
    end

    3.times do
      deck.shuffle!
    end
  end

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


def player_order
  @player_order = Table.player.shuffle! [1,2,3]
end

def button
  @button = @player_order.first
end

def blinds
  @big_blind = @player_order[1]
  @small_blind = @player_order[2]
end

def chips
  @player = Player.find_by(id: data[:id])
  @chips = @player.chips <- add column to players (braintree transaction)
end

def game_start
  deck
  hole
  common
  call
end

def call
  @player.each do 
    if @button || @big_blind || @small_blind
      @pass
    else
      @first_bet
    end
    @betting
  end
end

def pass
  @pass = nil
end

def betting
  @first_bet = @player_order.third(params: chips)
  @betting = @player.chips
end




  def deal_common_cards_with_BURN
    burn = deck.shift
    flop = Array.new(3) { deck.shift }
    burn
    turn = Array.new(1) { deck.shift }
    burn
    river = Array.new(1) { deck.shift }

    $redis.sadd("CommonCards", flop+turn+river) 
  end

  def hole_2
    first_deal = Array.new(@player_order) { Array.new(1) { deck.shift } }
    second_deal = Array.new(@player_order) { Array.new(1) { deck.shift } }
    @player_order.each_with_index do |activeplayer, index|
      $redis.sadd("Game", {@player_order[index] => first_deal[index]+second_deal[index]}) 
    end
  end



