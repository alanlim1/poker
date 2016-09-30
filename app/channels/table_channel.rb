class TableChannel < ApplicationCable::Channel
  def subscribed
    stream_from "table_channel"
    #TODO: broadcast message that contains all existing subscribers
    stream_from "web_notifications_channel"
  end

  def unsubscribed
    TableBroadcastJob.perform_now({
      :type => "PLAYER_LEFT",
      :payload => { :player => {
        :id => connection.current_player.id
        }
      }
    })
  end
end
