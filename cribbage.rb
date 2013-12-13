require 'gosu'

require './button'

require './hand'
require './scorer'

class CribbageGame < Gosu::Window

  DEAL        = 0
  DISCARDING  = 10
  CUT_CARD    = 20
  PLAY_31     = 30
  CPU_31      = 31
  THE_SHOW    = 40
  CRIB_SHOW   = 50

  WIDTH   = 800
  HEIGHT  = 600

  MID_X   = WIDTH / 2
  MID_Y   = HEIGHT / 2

  BAIZE_COLOUR      = Gosu::Color.new( 0xff007000 )
  SCORE_TEXT_COLOUR = Gosu::Color.new( 0xffffcc00 )
  SCORE_NUM_COLOUR  = Gosu::Color.new( 0xffffff00 )
  WATERMARK_COLOUR  = Gosu::Color.new( 0x20000000 )
  DISCARD_COLOUR    = Gosu::Color.new( 0xff104ec2 )

  CARD_HEIGHT = 150
  CARD_WIDTH  = 100

  CARD_GAP    = 12

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

  TOP_31  = COMPUTER_TOP + CARD_HEIGHT + CARD_GAP * 2
  LEFT_31 = CARD_GAP

  SCORE_TOP  = CARD_GAP
  SCORE_LEFT = WIDTH - CARD_WIDTH

  def initialize
    super( WIDTH, HEIGHT, false )

    self.caption = "Gosu Cribbage"

    load_images
    load_fonts
    setup_cards

    @discard_button = Button.new( self, 'Discard', @button_font, DISCARD_COLOUR, DISCARD_LEFT, DISCARD_TOP )
    @selected = []
    @game_phase = DISCARDING
    @show_crib = FALSE
    @player_hand_31 = @cpu_hand_31 = nil
    @player_score = @cpu_score = 0
  end

  def needs_cursor?   # Enable the mouse cursor
    true
  end

  def update
    return if !@position

    @card_name  = nil # DEBUG
    @score      = nil # DEBUG

    case @game_phase
    when CUT_CARD
      if @pack.inside?( @position )  # && @card_cut.nil?
        cut_card
        @card_name = @card_cut.name  # DEBUG
        @score = Cribbage::Scorer.new( @player_hand, @card_cut ).evaluate # DEBUG
        @position = nil

        setup_for_31
      end

    when DISCARDING
      if @discard_button.inside?( @position )
        discard_crib_cards
        @position = nil
      else
        @position = nil if select_card
      end

    when PLAY_31
      @position = nil if player_select_31
    end
  end

  def draw
    draw_background
    draw_hands
    draw_scores

    # Always draw the spare pack, and then the cut card on top if it's set

    @pack.draw
    @card_cut.draw( :face_up ) if @card_cut

    @discard_button.draw
    draw_crib if @show_crib

    draw_31 if @game_phase.between? PLAY_31, CPU_31
    debug_display
  end

  def draw_background
    self.draw_quad(
      0, 0, BAIZE_COLOUR, WIDTH-1, 0, BAIZE_COLOUR,
      WIDTH-1, HEIGHT-1, BAIZE_COLOUR, 0, HEIGHT-1, BAIZE_COLOUR, 0
    )

    @font.draw( "Cribbage", 80, 230, 0, 1, 1, WATERMARK_COLOUR )
  end

  def draw_hands
    if @game_phase.between? PLAY_31, CPU_31
      unless @player_hand_31.nil?
        @player_hand_31.draw :face_up
        @cpu_hand_31.draw :peep     # :face_down
      end
    else
      @player_hand.draw :face_up
      @cpu_hand.draw :peep     # :face_down
    end
  end

  def draw_scores
    player = 'Player '
    width  = @score_font.text_width( player, 1 );
    height = @score_font.height

    @score_font.draw( "CPU", SCORE_LEFT, SCORE_TOP, 1, 1, 1, SCORE_TEXT_COLOUR )
    @score_font.draw( @cpu_score.to_s, SCORE_LEFT + width, SCORE_TOP, 1, 1, 1, SCORE_NUM_COLOUR )
    @score_font.draw( player, SCORE_LEFT, SCORE_TOP + height, 1, 1, 1, SCORE_TEXT_COLOUR )
    @score_font.draw( @player_score, SCORE_LEFT + width, SCORE_TOP + height, 1, 1, 1, SCORE_NUM_COLOUR )
  end

  def draw_crib
    @card_back_image.draw( CRIB_LEFT, CRIB_TOP, 1 )
  end

  def draw_31
    @score_font.draw( 'Total', LEFT_31, TOP_31 - 20, 1, 1, 1, SCORE_TEXT_COLOUR )
    @score_font.draw( @total_31, LEFT_31 + 50, TOP_31 - 20, 1, 1, 1, SCORE_NUM_COLOUR )

    @run_cards.each do |run|
      run.each { |c| c.draw :face_up }
    end
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
    @font        = Gosu::Font.new( self, 'Century Schoolbook L', 180 )
    @score_font  = Gosu::Font.new( self, 'Serif', 20 )
    @card_font   = Gosu::Font.new( self, 'Arial', 28 )
    @button_font = Gosu::Font.new( self, 'Arial', 24 )
  end

  def setup_cards
    Cribbage::GosuCard.set_display( @card_front_image, @card_back_image, @card_font )

    @pack = Cribbage::GosuPack.new
    @pack.set_position( PACK_LEFT, PACK_TOP )
    @pack.set_images( @card_back_image, @card_front_image )

    @player_hand = Cribbage::GosuHand.new( @pack )
    @cpu_hand    = Cribbage::GosuHand.new( @pack )

    set_hand_positions

    @card_cut = nil
  end

  def set_hand_positions
    @player_hand.set_positions( PLAYER_LEFT, PLAYER_TOP, CARD_WIDTH + CARD_GAP )
    @cpu_hand.set_positions( COMPUTER_LEFT, COMPUTER_TOP, CARD_WIDTH + CARD_GAP )
  end

  def cut_card
     @card_cut = @pack.cut
     @card_cut.set_position( PACK_LEFT + 2, PACK_TOP + 2 )
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

    @discard_button.visible = (@selected.length == 2)
    found
  end

  def discard_crib_cards
    @player_hand.discard( *@selected )
    @cpu_hand.discard( rand( 0..5 ), rand( 0..5 ) )

    @selected = []
    @discard_button.hide()
    @game_phase = CUT_CARD
    @show_crib = true

    set_hand_positions
  end

  def setup_for_31
    @cpu_hand_31    = @cpu_hand.dup
    @player_hand_31 = @player_hand.dup
    @run_cards = []
    @run_num = -1

    start_31_run

    @game_phase = PLAY_31
  end

  def start_31_run
    @total_31 = 0
    @run_num += 1
    @run_cards[@run_num] = []
    @top_31   = TOP_31
    @left_31  = LEFT_31 + (CARD_WIDTH+CARD_GAP) * @run_num
  end

  def player_select_31
    idx = 0
    while idx < @player_hand_31.cards.length
      c = @player_hand_31.cards[idx]
      if c.inside?( @position ) && @total_31 + c.value <= 31
        @player_hand_31.cards.slice!( idx )
        add_card_to_run_31 c.dup, :player
        return true
      end

      idx += 1
    end

    false
  end

  def add_card_to_run_31 card, player
    c = card.dup
    c.set_position( @left_31, @top_31)

    @run_cards[@run_num] << c
    @total_31 += c.value

    if @total_31 == 15
      if player == :player
        @player_score += 2
      else
        @cpu_score += 2
      end
    end

    if @total_31 == 31
      if player == :player
        @player_score += 2
      else
        @cpu_score += 2
      end

      start_31_run
    else
      @top_31 += 25
      @left_31 += 25
    end
  end

  def debug_display
    dbg_str = @game_phase.to_s

    dbg_str += " - Selected: #{@selected}" if !@selected.empty? || @game_phase == DISCARDING
    dbg_str += " - #{@position}"        if @position
    dbg_str += " - #{@card_name}"       if @card_name
    dbg_str += " - Score: #{@score}"    if @score

    @button_font.draw( dbg_str, CARD_GAP, MID_Y, 10, 1, 1, 0x80000000 ) unless dbg_str == ''
  end
end

window = CribbageGame.new
window.show
