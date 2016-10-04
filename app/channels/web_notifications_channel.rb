class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "web_notifications_channel"
    hole
  end

  def unsubscribed
    # $redis.srem("players", connection.current_player.id)
    $redis.flushdb
  end

  private 

  def deck
  end

  def hole

    faces = %w[A K Q J T 9 8 7 6 5 4 3 2]
    suits = %w[c d h s]

    deck = []

    faces.each do |f|
      suits.each do |s|
        deck.push(f + s)
      end
    end

    3.times do
      deck.shuffle!
    end

    player_ids = $redis.smembers("players")
    hole = Array.new(player_ids.count) { Array.new(2) { deck.shift } }

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

    player_ids.each_with_index do |element, index|
      # $redis.sadd("allholes", {player_ids[index] => hole[index]})
      player_ids[index] << hole[index].to_s
    end

    $redis.sadd("allholes", player_ids)
    allholes = $redis.smembers("allholes")

    flop = Array.new(3) { deck.shift }
    burn = deck.shift
    turn = Array.new(1) { deck.shift }
    burn
    river = Array.new(1) { deck.shift }
    
    $redis.sadd("commoncards", flop+turn+river)
    commoncards = $redis.smembers("commoncards")

    $redis.sadd("god", flop+turn+river + player_ids)
    god = $redis.smembers("god")

    WebNotificationsBroadcastJob.perform_later({
        :type => "GAME_START_EVENT",
        :payload => { :playerHand => allholes, :commoncards => flop + turn + river }
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
