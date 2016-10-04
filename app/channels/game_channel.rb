class GameChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "player_#{username}"
    # Seek.create(username)
  end

  def unsubscribed
    # Seek.remove(username)
  end
end
