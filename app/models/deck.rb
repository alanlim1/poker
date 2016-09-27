class Deck < ApplicationRecord

  FACES="AKQJT98765432"
  SUITS="cdhs"

  deck = []
  FACES.each_byte do |f|
    SUITS.each_byte do |s|
      deck.push(f.chr + s.chr)
    end
  end

  3.times do
    deck.shuffle!
  end
  
end
