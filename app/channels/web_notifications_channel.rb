class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "web_notifications_channel"
    hole
  end

  def unsubscribed
  end

  private 

  def deck
  end

  def hole
    faces="AKQJT98765432"
    suits="cdhs"

    deck = []

    faces.each_byte do |f|
      suits.each_byte do |s|
        deck.push(f.chr + s.chr)
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

    holecards = $redis.smembers("holey")

    WebNotificationsBroadcastJob.perform_later({
        :type => "GAME_START_EVENT",
        :payload => { :hole => holecards }
      })
    # binding.pry
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
