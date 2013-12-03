require 'gosu'

require './hand'


class CribbageGame < Gosu::Window

  WIDTH   = 800
  HEIGHT  = 600

  BAIZE_COLOUR = 0xff007000

  CARD_HEIGHT = 150
  CARD_WIDTH  = 100

  CARD_GAP    = 15

  COMPUTER_TOP  = CARD_GAP
  COMPUTER_LEFT = CARD_GAP

  PLAYER_TOP  = HEIGHT - (CARD_HEIGHT + CARD_GAP)
  PLAYER_LEFT = CARD_GAP

  PACK_TOP  = (HEIGHT / 2) - (CARD_HEIGHT / 2)
  PACK_LEFT = WIDTH - (CARD_WIDTH + CARD_GAP)

  def initialize
    super( WIDTH, HEIGHT, false )

    self.caption = "Gosu Cribbage"

    @card_back_image  = Gosu::Image.new( self, 'media/CardBack.png', true )
    @card_front_image = Gosu::Image.new( self, 'media/CardFront.png', true )

    @pack = Cribbage::Pack.new

    @font = Gosu::Font.new( self, 'Arial', 50 )
    @card_font = Gosu::Font.new( self, 'Courier New', 24 )

    @player_hand   = Cribbage::GosuHand.new( @pack, self, @card_front_image, @card_back_image, @card_font )
    @computer_hand = Cribbage::GosuHand.new( @pack, self, @card_front_image, @card_back_image, @card_font )

    @card_cut = nil
  end

  def update

  end

  def draw
    self.draw_quad( 0, 0, BAIZE_COLOUR,
                    WIDTH-1, 0, BAIZE_COLOUR,
                    WIDTH-1, HEIGHT-1, BAIZE_COLOUR,
                    0, HEIGHT-1, BAIZE_COLOUR, 0 )

    draw_hand( @player_hand, PLAYER_LEFT, PLAYER_TOP, :face_up )
    draw_hand( @computer_hand, COMPUTER_LEFT, COMPUTER_TOP, :face_down )

    if @card_cut
      @card_cut.draw( PACK_LEFT, PACK_TOP, :face_up )
    else
      @card_back_image.draw( PACK_LEFT, PACK_TOP, 1 )
    end
  end

  def draw_hand( hand, x, y, orient )
    hand.cards.each do |c|
      c.draw( x, y, orient )
      x += CARD_WIDTH + CARD_GAP
    end
  end

  def button_down btn_id
    close if btn_id == Gosu::KbEscape
  end

end

window = CribbageGame.new
window.show
