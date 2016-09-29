class TableController < ApplicationController

  respond_to :js

  def index
  end

  def join
    TableBroadcastJob.perform_later({
        :type => "USER_JOINED",
        :data => { :user => {
          :user_id => current_player.id,
          :user_name => current_player.email
          }
        }
      })
  end

  def leave
    TableBroadcastJob.perform_now({
      :type => "USER_LEFT",
      :data => { :user => {
        :user_id => current_player.id
        }
      }
    })

    render :index
  end

end
