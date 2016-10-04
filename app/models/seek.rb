class Seek < ApplicationRecord
  def self.create(username)
  if opponent = REDIS.spop("seeks")
    Game.start(username, opponent)
  else
    REDIS.sadd("seeks", username)
  end
end

def self.remove(username)
  REDIS.srem("seeks", username)
end

def self.clear_all
  REDIS.del("seeks")
end
end
