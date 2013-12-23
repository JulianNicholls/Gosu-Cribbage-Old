require 'gosu'

module CribbageGame
  module Helpers

    def other_player( turn )
      (turn == :player) ? :cpu : :player
    end

    def player_name( turn )
      (turn == :player) ? 'Player' : 'CPU'
    end


    def set_delay( length )
      @delay = Time.now + length
    end

    def delaying
      return true if @delay && Time.now < @delay

      @delay = nil
      false
    end


    def load_images( window )
      {
        back:  Gosu::Image.new( window, 'media/CardBack.png', true ),
        front: Gosu::Image.new( window, 'media/CardFront.png', true )
      }
    end


    def load_fonts( window )
      {
        watermark:      Gosu::Font.new( window, 'Century Schoolbook L', 180 ),
        score:          Gosu::Font.new( window, 'Serif', 20 ),
        card:           Gosu::Font.new( window, 'Arial', 28 ),
        button:         Gosu::Font.new( window, 'Arial', 24 ),
        instructions:   Gosu::Font.new( window, 'Serif', 30 )
      }
    end


  end
end
