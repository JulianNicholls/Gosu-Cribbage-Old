require 'gosu'

module CribbageGame
  # Helper functions

  module Helpers
    @delay = nil

    def other_player( turn )
      turn == :player ? :cpu : :player
    end

    def player_name( turn )
      turn == :player ? 'Player' : 'CPU'
    end

    def delay_update( length )
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

    def set_colours
      {
        baize:      Gosu::Color.new( 0xff007000 ),
        watermark:  Gosu::Color.new( 0x20000000 ),

        score_bkgr: Gosu::Color.new( 0xff005000 ),
        score_text: Gosu::Color.new( 0xffffcc00 ),
        score_num:  Gosu::Color.new( 0xffffff00 ),

        arrow:      Gosu::Color.new( 0xf0ffcc00 ),
        discard:    Gosu::Color.new( 0xff104ec2 )
      }
    end
  end
end
