module ApplicationHelper

  def resource_name
    :player
  end

  def resource
    @resource ||= Player.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:player]
  end

  # def poker_cards(card)
  #   return "two-c" if card_is == "2c"
  #   return "two-d" if card_is == "2d"
  #   return "two-h" if card_is == "2h"
  #   return "two-s" if card_is == "2s"

  # end
end
