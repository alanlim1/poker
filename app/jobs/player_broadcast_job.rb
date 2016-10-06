class PlayerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(player_id, message)
    ActionCable.server.broadcast "player_channel_#{player_id}", message
  end

end
