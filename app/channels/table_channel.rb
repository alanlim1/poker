class TableChannel < ApplicationCable::Channel
  def subscribed
    stream_from "table_channel"
    $redis.sadd("players", connection.current_player.id)
    notify_players
    stream_from "player_channel"
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
      players.push({:id => player.id, :name => player.email})
    end

    TableBroadcastJob.perform_later({
        :type => "JOIN_LEAVE_EVENT", 
        # :type => "pre_betEvent", 
        # :type => "betEvent", 
        # :type => "foldEvent", 
        # :type => "flopEvent", 
        # :type => "turnEvent", 
        # :type => "riverEvent",
        :payload => { :players => players }
      })
  end
end
