class TableController < ApplicationController
<<<<<<< HEAD
 before_action :authenticate_player!, only: [:join]
=======

  respond_to :js

>>>>>>> f70b50212ec7fe32dc4934f1254afec3f8db7c7d
  def index
  end

  def join
<<<<<<< HEAD
    if current_player
      player = current_player.email
      ActionCable.server.broadcast "table_channel", email: player, body:"testingowkr"
    else
      TableBroadcastJob.perform_later(current_player)
    end
=======
    TableBroadcastJob.perform_later({
        :type => "PLAYER_JOINED",
        :payload => { :player => {
          :id => current_player.id,
          :name => current_player.email
          }
        }
      })
>>>>>>> f70b50212ec7fe32dc4934f1254afec3f8db7c7d
  end
end
