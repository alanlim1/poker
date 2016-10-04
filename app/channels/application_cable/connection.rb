module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_verified_player
    end

    protected
      def find_verified_player
        current_player = Player.find_by(id: cookies.signed['player.id'])
        if current_player && cookies.signed['player.expires_at'] > Time.now
          current_player
        else
          reject_unauthorized_connection
        end
      end
  end
end
