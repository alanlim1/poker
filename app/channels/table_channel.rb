class TableChannel < ApplicationCable::Channel
  def subscribed
    stream_from "table_channel"
  end

  def unsubscribed
    current_player.disappear
  end
end
