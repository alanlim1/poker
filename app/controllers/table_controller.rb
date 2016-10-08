class TableController < ApplicationController
  before_action :authenticate_player!, only: [:join] & [:start]
  respond_to :js

  def index
    @player_ids = $redis.smembers("players")
  end

  def join
  end

  def start
    if(!$redis.get("state"))
      deck
      hole
      commoncards
      $redis.set("state", "STARTED")
      $redis.set("dealer_index", "0")
      $redis.set("pot", "0")
      $redis.set("blind", "10")

      TableBroadcastJob.perform_later({
          :type => "GAME_START_EVENT"
        })
    end

    if $redis.get("state") == "STARTED"
      player_turn
      set_pot
      bet #commoncards given but not revealed
      $redis.set("state", "FLOP")
    end
    fin
  end

  def fin
    if $redis.get("state") == "FLOP" && $redis.smembers("player_order") == []
      TableBroadcastJob.perform_later({
          :type => "FLOP_REVEAL_EVENT",
          :payload => { :flop => @flop }
        })

      TableBroadcastJob.perform_later({
          :type => "TURN_REVEAL_EVENT",
          :payload => { :flop => @turn }
        })

      TableBroadcastJob.perform_later({
          :type => "RIVER_REVEAL_EVENT",
          :payload => { :flop => @river }
        })
      $redis.set("state", "COMPARE")
    end
    #
    # if $redis.get("state") == "TURN"
    #   TableBroadcastJob.perform_later({
    #       :type => "TURN_REVEAL_EVENT",
    #       :payload => { :turn => @turn }
    #     })
    #   bet
    #   $redis.set("state", "RIVER")
    # end
    #
    # if $redis.get("state") == "RIVER"
    #   TableBroadcastJob.perform_later({
    #       :type => "RIVER_REVEAL_EVENT",
    #       :payload => { :river => @river }
    #     })
    #   bet
    #   $redis.set("state", "COMPARE_HANDS")
    # end
    #
    # if $redis.get("state") == "COMPARE_HANDS"
    #   # game_ended #gem to compare HANDS
    #   #declare winner, % probability, etc
    #   #give out pot to winner / split
    #   $redis.set("state", "ENDED")
    # end
    #
    # if $redis.get("state") == "ENDED"
    #   # $redis.del("state")
    #   # $redis.flushall
    # end
      #reveal flop, update pot
  end

  def player_turn
    players = $redis.smembers("players")
    dealer = $redis.get("dealer_index").to_i
    small_blind = dealer + 1 >= players.length ? 0 : dealer + 1 #if true 0, else false (dealer+1)
    big_blind = small_blind + 1 >= players.length ? 0 : small_blind + 1
    key_players = [players[dealer], players[small_blind], players[big_blind]]
    player_order = (players - key_players) + key_players

    # $redis.del("player_order") <------#WHY WTF IS THIS FOR?
    $redis.sadd("player_order", player_order)
  end

  def set_pot
    blind = $redis.get("blind").to_i
    player_order = $redis.smembers("player_order")
    small_blind = Player.find(player_order[-2])
    big_blind = Player.find(player_order[-1])

    small_blind.account -= blind/2
    big_blind.account -= blind

    small_blind.save
    big_blind.save

    $redis.set("pot", blind/2 + blind)
  end

  def bet
    player_order = $redis.smembers("player_order")
    next_player_id = player_order[0]

    TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {
          :current_player => next_player_id,
          :message => "Betting has started. You are next in line. "
        }
      })

    PlayerBroadcastJob.perform_later(next_player_id, {
        :type => "BET_EVENT",
        :payload => {
          :message => "It's your turn. "
        }
      })

    # if player_order == nil || []
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

    $redis.sadd("deck", @deck)
    @redisdeck = $redis.smembers("deck").shuffle!

    3.times do
      @redisdeck.shuffle!
    end
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

  def commoncards
    @flop = Array.new(3) { @redisdeck.shift }
    burn = @redisdeck.shift
    @turn = Array.new(1) { @redisdeck.shift }
    burn = @redisdeck.shift
    @river = Array.new(1) { @redisdeck.shift }

    $redis.sadd("commoncards", @flop+@turn+@river)
    $redis.sadd("flop", @flop)
    $redis.sadd("turn", @turn)
    $redis.sadd("river", @river)
  end


end
