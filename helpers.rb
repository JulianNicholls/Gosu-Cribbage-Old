module CribbageGame
  module Helpers

    def other_player( turn )
        (turn == :player) ? :cpu : :player
    end

    @@delay = nil

    def set_delay( length )
      @@delay = Time.now + length
    end


    def delaying
      return true if @@delay && Time.now < @@delay

      @@delay = nil
      false
    end


  end
end
