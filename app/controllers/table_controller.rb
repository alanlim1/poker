class TableController < ApplicationController

  def index
    if current_player
      player = current_player.email
    end
    ActionCable.server.broadcast "table_channel", email: player
  end

end
