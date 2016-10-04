class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_channel"
    deck
    hole
    commoncards
  end

  def unsubscribed
    # $redis.srem("players", connection.current_player.id)
    $redis.flushdb
  end

  private 

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
  end

  def commoncards
    flop = Array.new(3) { @deck.shift }
    burn = @deck.shift
    turn = Array.new(1) { @deck.shift }
    burn
    river = Array.new(1) { @deck.shift }
    
    $redis.sadd("commoncards", flop+turn+river)
    commoncards = $redis.smembers("commoncards")

    PlayerBroadcastJob.perform_later({
        :type => "DEAL_COMMON_CARDS_EVENT",
        :payload => { :commoncards => flop }
      })
  end

  def hole
    player_ids = $redis.smembers("players")
    hole = Array.new(player_ids.count) { Array.new(2) { @deck.shift } }

    # player_ids.each_with_index do |element, index|
    #   $redis.sadd("holey", {player_ids[index] => hole[index]}) 
    # end
    # holecards = $redis.smembers("holey")

    # hole.each_with_index do |onehole, index|

      # player_ids.each do |player_id|
      #   player = Player.find_by(id: player_id)
      #   if player.hole == nil
      #     player.hole = ""
      #   end

    allholes = {}
    player_ids.each_with_index do |id, index|
      # $redis.sadd("allholes", {player_ids[index] => hole[index]})
      allholes[id] = hole[index]
    end
    $redis.sadd("allholes", JSON.generate(allholes))

    PlayerBroadcastJob.perform_later({
      :type => "GAME_START_EVENT",
      :payload => { :allholes => allholes }
    })
  end

  # def deal_hole
  #   player_ids = $redis.smembers("players")
  #   hole = []

  #   player_ids.each do |player_id|

  #     player = Player.find_by(id: player_id)
  #     hole.push({:id => player.id, :name => player.email})
  #   end

  #   PlayersBroadcastJob.perform_later({
  #       :type => "GAME_START_EVENT",
  #       :payload => { :players => players }
  #     })
  # end
end
