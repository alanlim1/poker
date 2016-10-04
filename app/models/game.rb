class Game < ApplicationRecord

  def self.start(username1..username3)
    # white, black, red, orange, yellow, green, blue, indigo, violet = [username1..username9].shuffle
    white, black, red = [username1..username3].shuffle

    ActionCable.server.broadcast "player_#{white}", {action: "game_start", msg: "white"}
    ActionCable.server.broadcast "player_#{black}", {action: "game_start", msg: "black"}
    ActionCable.server.broadcast "player_#{red}", {action: "game_start", msg: "red"}
    # ActionCable.server.broadcast "player_#{orange}", {action: "game_start", msg: "orange"}
    # ActionCable.server.broadcast "player_#{yellow}", {action: "game_start", msg: "yellow"}
    # ActionCable.server.broadcast "player_#{green}", {action: "game_start", msg: "green"}
    # ActionCable.server.broadcast "player_#{blue}", {action: "game_start", msg: "blue"}
    # ActionCable.server.broadcast "player_#{indigo}", {action: "game_start", msg: "indigo"}
    # ActionCable.server.broadcast "player_#{violet}", {action: "game_start", msg: "violet"}

    REDIS.set("opponent_for:#{white}", black, red)
    REDIS.set("opponent_for:#{black}", white, red)
    REDIS.set("opponent_for:#{red}", white, black)
  end

  def self.forfeit(uuid)
    if winner = opponent_for(uuid)
      ActionCable.server.broadcast "player_#{winner}", {action: "opponent_forfeits"}
    end
  end

  def self.opponent_for(username)
    REDIS.get("opponent_for:#{username}")
  end

  def self.make_move(uuid, data)
    opponent = opponent_for(uuid)
    move_string = "#{data["from"]}-#{data["to"]}"

    ActionCable.server.broadcast "player_#{opponent}", {action: "make_move", msg: move_string}
  end

end
