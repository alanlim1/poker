class TableBroadcastJob < ApplicationJob
  queue_as :default

  def perform(current_player)
    ActionCable.server.broadcast 'table_channel', current_player: current_player, message: "PLAYA HAS LEFT!"
  end
end
