class PlayerActionsController < ApplicationController
  before_action :authenticate_player!

  def call_bet
    if isAllowedToBet
      blind = $redis.get("blind")
      previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet"): blind
      bet = previous_bet.to_i
      $redis.set("previous_bet", bet)
      current_player.account -= bet
      current_player.save

      pot = $redis.get("pot").to_i
      $redis.set("pot", pot + bet)

      next_bet

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.id} has called the bet of $#{bet}. "}
        })
    end
  end

  def check #TODO WHAT HAPPENS IS RAISE RERAISE?!
    if isAllowedToBet
      pot = $redis.get("pot")
      player_order = $redis.smembers("player_order")
      blind_player = player_order[-1]
      previous_bet = $redis.get("previous_bet")

      if current_player.id == blind_player.to_i && previous_bet == "10"
        $redis.set("previous_bet", 0)
      elsif pot != 15 && (previous_bet == "0")
        $redis.set("previous_bet", 0)
      end
    end
    next_bet
  end

  def raise_bet
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

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.id} has raised $#{bet}! "}
        })

      player_order = $redis.smembers("player_order")
      if bet > previous_bet && (current_player.id != player_order[0] || player_order[0].to_i)
        TableBroadcastJob.perform_later({
          :type => "RERAISE_EVENT",
          :payload => {:message => "#{current_player.id} has re-raised $#{bet}! "}
          })
      end
    end
  end

  def fold
    if isAllowedToBet
      @nu_player_order.delete("#{current_player.id}".to_s)
      $redis.set("nu_player_order", @nu_player_order)

      $redis.srem("player_order", current_player.id)
      # player_order = $redis.smembers("player_order")
      # player_order.delete("#{current_player.id}")

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.id} has folded. "}
        })

    end
    next_bet_if_fold
  end

  def next_bet
    @nu_player_order.rotate!
    $redis.set("nu_player_order", @nu_player_order)

    next_player_id = @nu_player_order[0].to_i
    current_bet = $redis.get("previous_bet").to_i

    PlayerBroadcastJob.perform_later(next_player_id, {
      :type => "BET_EVENT",
      :payload => {:current_bet => current_bet}
      })

    TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:current_player => next_player_id }
        })
  end

  def next_bet_if_fold
    next_player_id = @nu_player_order[0].to_i

    current_bet = $redis.get("previous_bet").to_i

    PlayerBroadcastJob.perform_later(next_player_id, {
      :type => "BET_EVENT",
      :payload => {:current_bet => current_bet}
      })

    TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:current_player => next_player_id }
        })
  end

  def isAllowedToBet
    player_order = $redis.smembers("player_order")

    if $redis.get("nu_player_order").nil?
      $redis.set("nu_player_order", player_order)
    # else
    #   @nu_player_order = eval($redis.get("nu_player_order"))
    end
    @nu_player_order = eval($redis.get("nu_player_order"))
    current_player.id == @nu_player_order[0].to_i
  end

  # def OLD_next_bet ## LEGACY CODES
  #   @nu_player_order.rotate!
  #   # player_order.each do |x|
  #   #   @new_order = [] << x.to_i
  #   # end
  #   # $redis.del("player_order")
  #   # $redis.set("player_order", @new_order)
  #   $redis.set("nu_player_order", @nu_player_order)

  #   next_player_id = @nu_player_order[0].to_i

  #   # $redis.set("pot", @pot + params[:bet].to_i)
  #   # players = eval(@player_order)
  #   # next_player = players[players.index(current_player.id) + 1] # if you're the last player don't add one
  #   # round_2 = [] << current_player.id
  #   # $redis.set("round_2", round_2)
  #   # RevealActionBroadcast.perform_later(next_player)

  #   current_bet = $redis.get("previous_bet").to_i
  #   PlayerBroadcastJob.perform_later(next_player_id, {
  #     :type => "BET_EVENT",
  #     :payload => {:current_bet => current_bet}
  #     })
  #   # TableBroadcastJob.perform_later({
  #   #     :type => "BET_EVENT",
  #   #     :payload => {:current_player => next_player_id }
  #   #     })
  # end
end
