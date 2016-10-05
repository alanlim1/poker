class PlayerActionsController < ApplicationController
  before_action :authenticate_user!

  def call
    @player_order = $redis.get("player_order")
    @pot


  end

  def check

  end

  def raise
    @pot = $redis.get("pot")
    $redis.set("pot", eval(@pot) + params[:bet])
    players = eval(@player_order)
    next_player = players[players.index(current_player.id) + 1] # if you're the last player don't add one
    round_2 = [] << current_player.id
    $redis.set("round_2", round_2)
    RevealActionBroadcast.perform_later(next_player)
  end

  def fold
  end
end
