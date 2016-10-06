class PlayerActionsController < ApplicationController
  before_action :authenticate_user!

  def call
    if isAllowedToBet
      blind = $redis.get("blind")
      previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet").to_i : blind
      bet = previous_bet
      $redis.set("previous_bet", bet)
      current_player.account -= bet
      current_player.save

      pot = $redis.get("pot").to_i
      $redis.set("pot", pot + bet)

      next_bet
    end

  end

  def check
    binding.pry
    if isAllowedToBet
      pot = $redis.get("pot")
      blind_player = @nu_player_order[-1]
      previous_bet = $redis.get("previous_bet")

      if current_player == blind_player && previous_bet = "0"
        $redis.set("previous_bet", "0")
      elsif pot != 15 && (previous_bet == "0")
        $redis.set("previous_bet", "0")
      end
    end
    next_bet
  end

  def raise
    if isAllowedToBet
      # player_order = $redis.smembers("player_order")
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
    if isAllowedToBet
      x = eval(@nu_player_order)

      x.delete("#{current_player.id}")

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.id} has fold for this round"}
        })

    end
    next_bet
  end

  def isAllowedToBet
    player_order = $redis.smembers("player_order")

    if !$redis.get("nu_player_order")
      $redis.set("nu_player_order", player_order)
    end

    @nu_player_order = eval($redis.get("nu_player_order"))

    current_player.id == player_order[0].to_i || @nu_player_order[0].to_i
  end

  def next_bet
    @nu_player_order.rotate!
    # player_order.each do |x|
    #   @new_order = [] << x.to_i
    # end
    # $redis.del("player_order")
    # $redis.set("player_order", @new_order)
    $redis.set("nu_player_order", @nu_player_order)

    next_player_id = @nu_player_order[0].to_i
    
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