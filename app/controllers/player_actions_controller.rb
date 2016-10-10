class PlayerActionsController < ApplicationController
  before_action :authenticate_player!

  def call_bet
    player_order = $redis.smembers("players")
    if isAllowedToBet && current_player.id != player_order[-2].to_i && current_player.id != player_order[-1].to_i
      blind = $redis.get("blind")
      previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet"): blind
      bet = previous_bet.to_i
      $redis.set("previous_bet", bet)
      current_player.account -= bet
      current_player.save

      pot = $redis.get("pot").to_i
      $redis.set("pot", pot + bet)
      updated_pot = $redis.get("pot").to_i

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.email} has called the bet of $#{bet}. POT: $#{updated_pot}. "}
        })

    blind = $redis.get("blind")
    previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet"): blind
    bet = previous_bet.to_i

    elsif isAllowedToBet && current_player.id == player_order[-2].to_i && bet.to_i < 10
      blind = $redis.get("blind")
      halfbet = blind.to_i/2

      current_player.account -= halfbet
      current_player.save

      pot = $redis.get("pot").to_i
      $redis.set("pot", pot + halfbet)
      updated_pot = $redis.get("pot").to_i

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "The small blind #{current_player.email} has called the bet of $#{halfbet}. POT: $#{updated_pot}. "}
        })

      previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet"): blind
      bet = previous_bet.to_i

      if bet > 10
        blind = $redis.get("blind")
        halfbet = blind.to_i/2
        bet = bet - blind.to_i
        $redis.set("previous_bet", bet)

        current_player.account -= bet
        current_player.save

        pot = $redis.get("pot").to_i
        $redis.set("pot", pot + bet)
        updated_pot = $redis.get("pot").to_i

        TableBroadcastJob.perform_later({
          :type => "BET_EVENT",
          :payload => {:message => "The small blind #{current_player.email} has called the bet of $#{bet}. POT: $#{updated_pot}. "}
          })
      end

    previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet"): blind
    bet = previous_bet.to_i

    elsif isAllowedToBet && current_player.id == player_order[-1].to_i
      if previous_bet.to_i == 10
        check
      else
        blind = $redis.get("blind")
        previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet"): blind
        bet = previous_bet.to_i
        bet = bet - blind.to_i
        $redis.set("previous_bet", bet)

        current_player.account -= bet
        current_player.save

        pot = $redis.get("pot").to_i
        $redis.set("pot", pot + bet)
        updated_pot = $redis.get("pot").to_i

        TableBroadcastJob.perform_later({
          :type => "BET_EVENT",
          :payload => {:message => "The big blind #{current_player.email} has called the bet of $#{bet}. POT: $#{updated_pot}. "}
          })
      end
    end
    next_bet
  end

  def check #TODO WHAT HAPPENS IS RAISE RERAISE?!
    if isAllowedToBet
      pot = $redis.get("pot")
      player_order = $redis.smembers("player_order")
      blind_player = player_order[-1]
      previous_bet = $redis.get("previous_bet")

      if current_player.id == blind_player.to_i && previous_bet == "10"
        $redis.set("previous_bet", 0)
        TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.email} has checked. POT: $#{pot}. "}
        })
        next_bet
      elsif pot.to_i >= 15 && (previous_bet == "0")
        $redis.set("previous_bet", 0)
        TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.email} has checked. POT: $#{pot}. "}
        })
        next_bet
      elsif previous_bet != 0
        TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.email}, check not available. Bet is called. "}
        })
        call_bet ## check & call all always with a checkbox button a la ZYNGA
      end
    end
  end

  def raise_bet
    if isAllowedToBet
      player_order = $redis.smembers("player_order")
      previous_bet = $redis.get("previous_bet")? $redis.get("previous_bet").to_i : nil
      blind = $redis.get("blind").to_i
      bet = params[:bet].to_i
      if(previous_bet)
        if(bet < previous_bet)
          TableBroadcastJob.perform_later({
            :type => "BET_EVENT",
            :payload => {:message => "#{current_player.email} needs to bet more. Learn your math. Bet is called! "}
            })
        #TODO: REJECT BET and ALLOW SECOND HIGHER RAISE. how?
          return call_bet
        end
      elsif(bet < blind)
        TableBroadcastJob.perform_later({
          :type => "BET_EVENT",
          :payload => {:message => "#{current_player.email}, raise needs to be more than blind! Math please, bet is called! "}
          })
        return call_bet
      end

      # !?!?!?!?!?!?!?!?!??!?!WTAFSJDALSKDJASLKDFJASDLKSAJDSAKL
      # >>>>>>>>>>>>>
        #TODO same as above: allow second raise to be more than previous bet
      #   elsif bet > previous_bet && (current_player.id != player_order[0].to_i)
      #     pot = $redis.get("pot").to_i
      #     TableBroadcastJob.perform_later({
      #       :type => "RERAISE_EVENT",
      #       :payload => {:message => "#{current_player.email} has re-raised $#{bet}! POT: $#{pot}. "}
      #       })
      #   end
      # end

      $redis.set("previous_bet", bet)
      current_player.account -= bet
      current_player.save
      pot = $redis.get("pot").to_i
      $redis.set("pot", pot + bet)
      updated_pot = $redis.get("pot").to_i

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.email} has raised $#{bet}! POT: $#{updated_pot}. "}
        })
    end
    next_bet
  end

  def fold
    if isAllowedToBet
      pot = $redis.get("pot").to_i
      @nu_player_order.delete("#{current_player.id}".to_s)
      $redis.set("nu_player_order", @nu_player_order)

      $redis.srem("player_order", current_player.id)
      # player_order = $redis.smembers("player_order")
      # player_order.delete("#{current_player.id}")

      TableBroadcastJob.perform_later({
        :type => "BET_EVENT",
        :payload => {:message => "#{current_player.email} has folded. POT: $#{pot}. "}
        })
    end
    next_bet_if_fold
  end

  def next_bet
    turnOver
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

    fin
  end

  def game_best_hands

    allholes = $redis.smembers "allholes"
    player_hole = JSON.parse(allholes[0])

    all_player_best_hands = Hash.new
    player_hole.each do |player_id, holes|
      all_player_best_hands[player_id] = player_best_hands(player_id)
    end

    choose_best_hands = []
    all_player_best_hands.each do |key, value|
      choose_best_hands.push(value)
    end

    winner_hands = PokerHand.new([])
    choose_best_hands.each do |x|
      best_hands = PokerHand.new(x)
      if best_hands.rank > winner_hands.rank
        winner_hands = best_hands
      end
      winner_hands.cards
    end

    winner_id = all_player_best_hands.key(winner_hands.cards)
    winner_player = Player.find_by(winner_id)

    pot = $redis.get "pot"
    winner_player.account += pot
    winner_player.save

    TableBroadcastJob.perform_later({
      :type => "WINNER_EVENT"
      :payload => "#{winner_player.email} has won the round and #{pot} richer!!"
      })
  end

  def player_best_hands(player)
    allholes = $redis.smembers "allholes"
    player_hole = JSON.parse(allholes[0])["1"]
    commoncards = $redis.smembers "commoncards"
    combined_cards = commoncards.push(player_hole).flatten
    all_combination = combined_cards.combination(5).to_a
    highest_hands = ""
    all_combination.each_with_index do |x, index|
        if all_combination[index].contains_all? player_hole
          hands = PokerHand.new(all_combination[index])
          if hands.rank > PokerHand.new(highest_hands).rank
            highest_hands = hands.cards
          end
        end
    end
    highest_hands
  end

  def contains_all? other
    other = other.dup
    each{|e| if i = other.index(e) then other.delete_at(i) end}
    other.empty?
  end

  # all_combination.each_with_index do |x, index|
  #    puts "#{index} : #{PokerHand.new(all_combination[index]).rank}"
  # end


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

    fin
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

  def turnOver
    $redis.srem("player_order", current_player.id)
    # binding.pry
    # player_order = $redis.smembers("player_order")
    # if @nu_player_order[0].to_i == current_player.id
    #   player_order.delete("#{current_player.id}")
    # end
  end

  def fin
    flop = $redis.smembers("commoncards")
    if $redis.get("state") == "FLOP" && $redis.smembers("player_order") == []
      TableBroadcastJob.perform_later({
          :type => "FLOP_REVEAL_EVENT",
          :payload => { :flop => flop}
        })
      $redis.set("state", "COMPARE")
    end
  end

  def game_best_hands
    allholes = $redis.smembers "allholes"
    player_hole = JSON.parse(allholes)
    player_hole.each do |player_id, holes|
      all_player_best_hands.push(:player_id => player_best_hands(player_id))
    end

    all_player_best_hands.each do |player_id, player_best_hands|
      choose_best_hands.push(PokerHand.new(player_best_hands))
        choose_best_hands.each do |best_hands|
          winner_hands = PokerHand.new([])
          if best_hands.rank > winner_hands.rank
            winner_hands = best_hands
          end
        end
    end
  end

  def player_best_hands(player)
    allholes = $redis.smembers "allholes"
    player_hole = JSON.parse(allholes[0])[player]
    commoncards = $redis.smembers "commoncards"
    combined_cards = commoncards.push(player_hole).flatten
    all_combination = combined_cards.combination(5).to_a
    all_combination.each_with_index do |x, index|
      hands = PokerHand.new(all_combination[index])
      highest_hands = PokerHand.new([])
        if hands.rank > highest_hands.rank
          highest_hands = hands
        end
    end
    highest_hands
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
