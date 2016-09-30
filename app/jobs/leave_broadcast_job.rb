class LeaveBroadcastJob < ApplicationJob
  queue_as :default

  def perform
    ActionCable.server.broadcast 'table_channel', message
  end
end
