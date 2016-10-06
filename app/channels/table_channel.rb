class TableChannel < ApplicationCable::Channel
  def subscribed
    #TODO: make sure player has enough in his account
    stream_from "table_channel"
    $redis.sadd("players", connection.current_player.id)
    notify_players
  end

  def unsubscribed
    $redis.srem("players", connection.current_player.id)
    notify_players
  end

  def notify_players
    player_ids = $redis.smembers("players")
    players = []

    player_ids.each do |player_id|

      player = Player.find_by(id: player_id)
      if !player
        next
      end
      players.push({:id => player.id, :name => player.email})
    end

    TableBroadcastJob.perform_later({
        :type => "JOIN_LEAVE_EVENT",
        :payload => { :players => players }
      })
  end
end
