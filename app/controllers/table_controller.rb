class TableController < ApplicationController
  before_action :authenticate_player!, only: [:join] & [:start]
  respond_to :js

  def index
    @player_ids = $redis.smembers("players")
  end

  def join
  end

  def start
    if(!$redis.get("state")) || $redis.get("state") == "FIN"
      deck
      hole
      commoncards
      $redis.set("state", "STARTED")
      $redis.set("dealer_index", "0")

      TableBroadcastJob.perform_later({
          :type => "GAME_START_EVENT"
        })
    end

    if $redis.get("state") == "STARTED"
      player_turn
      pre_bet #commoncards given but not revealed
      $redis.set("state", "BET")
    end

    if $redis.get("state") == "BET"
      bet
      $redis.set("state", "FLOP")
    end

    if $redis.get("state") == "FLOP"
      bet
      $redis.set("state", "TURN")
    end

    if $redis.get("state") == "TURN"
      bet
      $redis.set("state", "RIVER")
    end

    if $redis.get("state") == "RIVER"
      bet
      $redis.set("state", "ENDED")
    end

    if $redis.get("state") == "ENDED"
      # game_ended
      $redis.set("state", "FIN")
    end


  end

  def player_turn
    players = $redis.smembers "players"

    dealer = $redis.get("dealer_index").to_i
    small_blind = dealer + 1 >= players.length ? 0 : dealer + 1 #if true 0, else false (dealer+1)
    big_blind = small_blind + 1 >= players.length ? 0 : small_blind + 1
    player_order = [players[dealer], players[small_blind], players[big_blind]]
    player_order = (players - player_order) + player_order

    $redis.sadd("player_order", player_order)
  end

  def pre_bet
    player_order = $redis.smembers "player_order"
    player_order.each do 
      if player_action == "call", "raise", "fold"
        
    # dealer_index = $redis.get "dealer_index"
    # small_blind = dealer_index + 1 , if small_blind is bigger than array length, reset to 0
    # big_blind = small_blind + 1
    # starting_player = big_blind + 1
    # [starting_player, ]
    players.each do

    end

      
    end
  end

  def bet
  end

  def fold
    # if $redis.get("state") == "STARTED" || "BET" || "FLOP" || "TURN" || "RIVER" 
    #   && $redis.get("player_turn") == true
    # end
  end

  def game_ended
    $redis.del("commoncards")
    $redis.del("deck")
    $redis.del("allholes")
  end

  def deck
    faces = %w[A K Q J T 9 8 7 6 5 4 3 2]
    suits = %w[c d h s]

    @deck = []

    faces.each do |f|
      suits.each do |s|
        @deck.push(f + s)
      end
    end

    3.times do
      @deck.shuffle!
    end

    $redis.sadd "deck", @deck
    @redisdeck = $redis.smembers("deck").shuffle!

    3.times do
      @redisdeck.shuffle!
    end
  end

  def commoncards
    @flop = Array.new(3) { @redisdeck.shift }
    burn = @redisdeck.shift
    @turn = Array.new(1) { @redisdeck.shift }
    burn = @redisdeck.shift
    @river = Array.new(1) { @redisdeck.shift }

    $redis.sadd "commoncards", @flop+@turn+@river
  end

  def hole
    player_ids = $redis.smembers("players")
    hole = Array.new(player_ids.count) { Array.new(2) { @redisdeck.shift } }
    allholes = {}
    player_ids.each_with_index do |player_id, index|
      allholes[player_id] = hole[index]
    end

    $redis.sadd("allholes", JSON.generate(allholes))

    player_ids.each do |player_id|
      PlayerBroadcastJob.perform_later(player_id, {
          :type => "HOLE_EVENT",
          :payload => { :hole => allholes[player_id] }
        })
    end
  end

end
