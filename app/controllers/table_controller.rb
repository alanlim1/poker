class TableController < ApplicationController
  before_action :authenticate_player!, only: [:join]
  respond_to :js

  def index
  end

  def join
    TableBroadcastJob.perform_later({
        :type => "PLAYER_JOINED",
        :payload => { :player => {
          :id => current_player.id,
          :name => current_player.email
          }
        }
      })
  end
end
