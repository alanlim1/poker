class PlayerChannel < ApplicationCable::Channel
  def subscribed
    stream_from "player_channel_#{connection.current_player.id}"
  end

  def unsubscribed
  end

end
