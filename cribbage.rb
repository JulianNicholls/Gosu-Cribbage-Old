require 'gosu'

require './button'

require './hand'
require './scorer'
require './player31'

require './constants'


module CribbageGame
  class Engine < Gosu::Window

    include Constants

    attr_reader :score_font
    attr_accessor :scores

    def initialize
      super( WIDTH, HEIGHT, false, 100 )  # Width x Height, not fullscreen, 100ms between 'update's

      self.caption = "Gosu Cribbage"

      load_images
      load_fonts
      @discard_button = Button.new( self, 'Discard', @button_font, DISCARD_COLOUR, DISCARD_LEFT, DISCARD_TOP )

      reset
    end


    def reset
      setup_cards

      @selected     = []
      @game_phase   = DISCARDING
      @show_crib    = FALSE
      @crib         = []
      @scores       = { player: 0, cpu: 0 }
      @delay        = nil
    end


    def needs_cursor?   # Enable the mouse cursor
      true
    end


    def update
      return unless @position || @game_phase == PLAY_31
      return if delaying

      @card_name, @dbg_score  = nil, nil  # DEBUG

      case @game_phase
        when CUT_CARD
          if @pack.inside?( @position )
            cut_card
            @card_name = @card_cut.name  # DEBUG
            @dbg_score = Cribbage::Scorer.new( @player_hand, @card_cut ).evaluate # DEBUG
            @position = nil

            @play31 = Player31.new( self, @player_hand, @cpu_hand )
            set_phase PLAY_31
            set_arrow( 1, Player31::TOP + CARD_GAP )
          end

        when DISCARDING
          if @discard_button.inside?( @position )
            discard_crib_cards
            @position = nil
          else
            @position = nil if select_card
          end

        when PLAY_31
          @position = nil if @play31.update( @position )

        when THE_SHOW
          set_arrow( nil )
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

      @play31.draw if @game_phase == PLAY_31

      draw_arrow

      debug_display
    end


    def draw_background
      self.draw_quad(                 # Baize
        0, 0, BAIZE_COLOUR,
        WIDTH-1, 0, BAIZE_COLOUR,
        WIDTH-1, HEIGHT-1, BAIZE_COLOUR,
        0, HEIGHT-1, BAIZE_COLOUR,
        0
      )

      self.draw_quad(                 # Score Edge
        SCORE_LEFT - CARD_GAP, 1, SCORE_TEXT_COLOUR,
        WIDTH - 2, 1, SCORE_TEXT_COLOUR,
        WIDTH - 2, 65, SCORE_TEXT_COLOUR,
        SCORE_LEFT - CARD_GAP, 65, SCORE_TEXT_COLOUR,
        0
      )

      self.draw_quad(                 # Score Background
        SCORE_LEFT - CARD_GAP + 1, 2, SCORE_BKGR_COLOUR,
        WIDTH - 3, 2, SCORE_BKGR_COLOUR,
        WIDTH - 3, 64, SCORE_BKGR_COLOUR,
        SCORE_LEFT - CARD_GAP + 1, 64, SCORE_BKGR_COLOUR,
        0
      )

      @font.draw( "The Julio", 60, 220, 0, 1, 1, WATERMARK_COLOUR )
    end


    def draw_hands
      if @game_phase == PLAY_31
        @play31.draw_hands
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
      @score_font.draw( @scores[:cpu], SCORE_LEFT + width, SCORE_TOP, 1, 1, 1, SCORE_NUM_COLOUR )
      @score_font.draw( player, SCORE_LEFT, SCORE_TOP + height, 1, 1, 1, SCORE_TEXT_COLOUR )
      @score_font.draw( @scores[:player], SCORE_LEFT + width, SCORE_TOP + height, 1, 1, 1, SCORE_NUM_COLOUR )
    end


    def draw_crib
      @card_back_image.draw( CRIB_LEFT, CRIB_TOP, 1 )
    end


    def button_down btn_id
      case btn_id
        when Gosu::KbEscape   then  close
        when Gosu::KbR        then  reset

        when Gosu::MsLeft     then  @position = [mouse_x, mouse_y]
      end
    end


    def load_images
      @card_back_image  = Gosu::Image.new( self, 'media/CardBack.png', true )
      @card_front_image = Gosu::Image.new( self, 'media/CardFront.png', true )
    end


    def draw_arrow
      return if !@arrow_x

      self.draw_triangle(
        @arrow_x, @arrow_y - CARD_GAP, ARROW_COLOUR,
        @arrow_x + CARD_GAP * 2, @arrow_y, ARROW_COLOUR,
        @arrow_x, @arrow_y + CARD_GAP, ARROW_COLOUR,
        2
      )
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
      @crib << @player_hand.cards[@selected[0]]
      @crib << @player_hand.cards[@selected[1]]
      @player_hand.discard( *@selected )

      # THIS IS ALL TEMPORARY
      s1, s2 = rand( 0..5 ), rand( 0..5 )
      s2 = ((s1 + 1) % 6) if s1 == s2

      @crib << @cpu_hand.cards[s1]
      @crib << @cpu_hand.cards[s2]

      @cpu_hand.discard( s1, s2 )
      # TO HERE

      @selected = []
      @discard_button.hide()
      @show_crib = true

      set_hand_positions

      set_phase( CUT_CARD )
      set_arrow( PACK_LEFT - (CARD_GAP * 2), PACK_TOP + CARD_GAP )
    end


    def set_delay length
      @delay = Time.now + length
    end


    def delaying
      return true if @delay && Time.now < @delay

      @delay = nil
      false
    end


    def set_arrow( x, y = nil )
      @arrow_x, @arrow_y = x, y
    end


    def set_phase phase
      @game_phase = phase
    end


private

    def debug_display
      dbg_str = @game_phase.to_s

      dbg_str += " - Selected: #{@selected}"  if !@selected.empty? || @game_phase == DISCARDING
      dbg_str += " - #{@position}"            if @position
      dbg_str += " - #{@card_name}"           if @card_name
      dbg_str += " - Score: #{@dbg_score}"    if @dbg_score

      @button_font.draw( dbg_str, CARD_GAP, MID_Y, 10, 1, 1, 0x80000000 ) unless dbg_str == ''
    end
  end
end



window = CribbageGame::Engine.new
window.show
