class WebNotificationsBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast 'web_notifications_channel', message
  end

end
