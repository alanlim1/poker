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

      TableBroadcastJob.perform_later({
          :type => "GAME_START_EVENT"
        })
    end
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
  end

  def commoncards
    flop = Array.new(3) { @deck.shift }
    burn = @deck.shift
    turn = Array.new(1) { @deck.shift }
    burn
    river = Array.new(1) { @deck.shift }

    $redis.sadd "commoncards", flop+turn+river
    update_deck_in_redis @deck
  end

  def hole
    player_ids = $redis.smembers("players")
    hole = Array.new(player_ids.count) { Array.new(2) { @deck.shift } }
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
    update_deck_in_redis @deck

  end

  def update_deck_in_redis(deck)
    $redis.del "deck"
    $redis.sadd "deck", deck
  end
end
