class PlayerActionsController < ApplicationController
  before_action :authenticate_user!

  def call
    player_order = $redis.smembers("player_order")
  end

  def check
  end

  def raise
    binding.pry
    if isAllowedToBet
      player_order = $redis.smembers("player_order")
      previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet").to_i : nil
      blind = $redis.get("blind").to_i
      bet = params[:bet].to_i
      if(previous_bet)
        if(bet < previous_bet)
          #Reject bet
          flash[:danger] = "BET MORE"
        end
      else
        if(bet < blind)
          #Reject bet
          flash[:danger] = "BET MORE"
        end
      end

      $redis.set("previous_bet", bet)
      current_player.account -= bet
      current_player.save
      pot = $redis.get("pot").to_i
      $redis.set("pot", pot + bet)
      next_bet
    end
  end

  def fold
  end

  def isAllowedToBet
    player_order = $redis.smembers("player_order")
    current_player.id == player_order[0].to_i
  end

  def next_bet
    player_order = $redis.smembers("player_order")
    new_player_order = player_order.rotate!
    $redis.del("player_order")
    $redis.sadd("player_order", new_player_order)
    # binding.pry
    next_player_id = new_player_order[0]
    # $redis.set("pot", @pot + params[:bet].to_i)
    # players = eval(@player_order)
    # next_player = players[players.index(current_player.id) + 1] # if you're the last player don't add one
    # round_2 = [] << current_player.id
    # $redis.set("round_2", round_2)
    # RevealActionBroadcast.perform_later(next_player)

    current_bet = $redis.get("previous_bet").to_i
    PlayerBroadcastJob.perform_later(next_player_id, {
      :type => "BET_EVENT",
      :payload => {:current_bet => current_bet}
      })
    # TableBroadcastJob.perform_later({
    #     :type => "BET_EVENT",
    #     :payload => {:current_player => next_player_id }
    #     })
  end
end