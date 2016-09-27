class CardsController < ApplicationController
  before_action :authenticate_user!

  def show
    card_ids = $redis.smembers current_user_card
    @hole = Card.find(card_ids)

  end

  def add
    $redis.sadd current_user_card, params[:card_id]
    render json: current_user.card_count, status: 200
  end

  def newGame
    $redis.sadd("newGame", card_ids)
    # $redis.smembers("newGame")
  end

  private

  def current_user_card
    "cards#{current_user.id}"
  end

end
