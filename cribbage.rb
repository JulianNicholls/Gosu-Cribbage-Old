require 'gosu'

require './button'

require './hand'
require './scorer'

class CribbageGame < Gosu::Window

  DEAL        = 0
  DISCARDING  = 1
  CUT_CARD    = 2
  PLAY_31     = 3
  THE_SHOW    = 4
  CRIB_SHOW   = 5

  WIDTH   = 800
  HEIGHT  = 600

  MID_X   = WIDTH/2
  MID_Y   = HEIGHT/2

  BAIZE_COLOUR    = Gosu::Color.new( 0xff007000 )
  DISCARD_COLOUR  = Gosu::Color.new( 0xff104ec2 )

  CARD_HEIGHT = 150
  CARD_WIDTH  = 100

  CARD_GAP    = 15

  COMPUTER_TOP  = CARD_GAP
  COMPUTER_LEFT = CARD_GAP

  PLAYER_TOP  = HEIGHT - (CARD_HEIGHT + CARD_GAP)
  PLAYER_LEFT = CARD_GAP

  PACK_TOP  = MID_Y - (CARD_HEIGHT / 2)
  PACK_LEFT = WIDTH - (CARD_WIDTH + CARD_GAP)

  CRIB_TOP  = PACK_TOP
  CRIB_LEFT = PACK_LEFT - (CARD_WIDTH + CARD_GAP)

  BUTTON_HEIGHT = 40
  DISCARD_TOP   = PLAYER_TOP - BUTTON_HEIGHT*2
  DISCARD_LEFT  = CARD_GAP*3

  def initialize
    super( WIDTH, HEIGHT, false )

    self.caption = "Gosu Cribbage"

    load_images
    load_fonts
    setup_cards

    @discard_button = Button.new( self, 'Discard', @button_font, DISCARD_COLOUR, DISCARD_LEFT, DISCARD_TOP )
    @selected = []
    @show_discard_button = false
    @game_phase = DISCARDING
    @show_crib = FALSE
  end

  def needs_cursor?
    true
  end

  def update
    if @position
      @card_name = nil
      @score = nil

      if @game_phase == CUT_CARD &&
         @position[0].between?( PACK_LEFT, PACK_LEFT + CARD_WIDTH ) &&
         @position[1].between?( PACK_TOP, PACK_TOP + CARD_HEIGHT )      # && @card_cut.nil?
        cut_card
        @card_name = @card_cut.name
        @score = Cribbage::Scorer.new( @player_hand, @card_cut ).evaluate
        @position = nil
      elsif @show_discard_button && @discard_button.inside?( @position )
        discard_crib_cards
        @position = nil
      else
        @position = nil if @game_phase == DISCARDING && select_card
      end
    end
  end

  def draw
    self.draw_quad( 0, 0, BAIZE_COLOUR,
                    WIDTH-1, 0, BAIZE_COLOUR,
                    WIDTH-1, HEIGHT-1, BAIZE_COLOUR,
                    0, HEIGHT-1, BAIZE_COLOUR, 0 )

    draw_hand( @player_hand, :face_up )
    draw_hand( @computer_hand, :face_down )

    # Always draw the spare pack, and then the cut card on top if it's set

    @card_back_image.draw( PACK_LEFT, PACK_TOP, 1 )
    @card_cut.draw( :face_up ) if @card_cut

    @discard_button.draw if @show_discard_button
    draw_crib if @show_crib

    debug_display
  end

  def draw_hand( hand, orient )
    hand.cards.each { |c| c.draw( orient ) }
  end

  def draw_crib
    @card_back_image.draw( CRIB_LEFT, CRIB_TOP, 1 )
  end

  def button_down btn_id
    case btn_id
      when Gosu::KbEscape   then  close

      when Gosu::MsLeft     then  @position = [mouse_x, mouse_y]
    end
  end

  def load_images
    @card_back_image  = Gosu::Image.new( self, 'media/CardBack.png', true )
    @card_front_image = Gosu::Image.new( self, 'media/CardFront.png', true )
  end

  def load_fonts
    @font        = Gosu::Font.new( self, 'Arial', 50 )
    @card_font   = Gosu::Font.new( self, 'Arial', 28 )
    @button_font = Gosu::Font.new( self, 'Arial', 24 )
  end

  def setup_cards
    Cribbage::GosuCard.set_display( @card_front_image, @card_back_image, @card_font )

    @pack = Cribbage::Pack.new

    @player_hand   = Cribbage::GosuHand.new( @pack )
    @computer_hand = Cribbage::GosuHand.new( @pack )

    set_hand_positions

    @card_cut = nil
  end

  def set_hand_positions
    pcards = @player_hand.cards.length
    ccards = @computer_hand.cards.length

    left = PLAYER_LEFT

    [pcards, ccards].max.times do |idx|
      @player_hand.cards[idx].set_area( left, PLAYER_TOP, CARD_WIDTH, CARD_HEIGHT )     if idx < pcards
      @computer_hand.cards[idx].set_area( left, COMPUTER_TOP, CARD_WIDTH, CARD_HEIGHT ) if idx < ccards

      left += CARD_WIDTH + CARD_GAP
    end
  end

  def cut_card
     @card_cut = @pack.cut( Cribbage::GosuCard )
     @card_cut.set_area( PACK_LEFT + 2, PACK_TOP + 2, CARD_WIDTH, CARD_HEIGHT )
  end

  def select_card
    found = false
    @player_hand.cards.each_with_index do |c, idx|
      if c.inside?( @position )
        found = true
        @card_name = c.name
        sidx = @selected.index( idx )

        if sidx
          @selected.slice! sidx
          c.move_by( 0, CARD_GAP )  # Return to normal
        elsif @selected.length < 2
          @selected << idx
          c.move_by( 0, -CARD_GAP ) # Push up to indicate selection
        end
      end
    end

    @show_discard_button = (@selected.length == 2)
    found
  end

  def discard_crib_cards
    @player_hand.discard( *@selected )
    @computer_hand.discard( rand( 0..5 ), rand( 0..5 ) )

    @selected = []
    @show_discard_button = false
    @game_phase = CUT_CARD
    @show_crib = true
    set_hand_positions
  end


  def debug_display
    dbg_str = ''

    dbg_str += "Selected: #{@selected}" if !@selected.empty? || @game_phase == DISCARDING
    dbg_str += " - #{@position}"        if @position
    dbg_str += " - #{@card_name}"       if @card_name
    dbg_str += " - Score: #{@score}"    if @score

    @button_font.draw( dbg_str, CARD_GAP, MID_Y, 1 ) unless dbg_str == ''
  end
end

window = CribbageGame.new
window.show
