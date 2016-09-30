class TableController < ApplicationController
 before_action :authenticate_player!, only: [:join]
  def index
  end

  def join
    if current_player
      player = current_player.email
      ActionCable.server.broadcast "table_channel", email: player, body:"testingowkr"
    else
      TableBroadcastJob.perform_later(current_player)
    end
  end

end
