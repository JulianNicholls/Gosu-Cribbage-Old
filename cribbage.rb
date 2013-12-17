require './gosu_enhanced'

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
      @game_phase   = INITIAL_CUT
      @show_crib    = FALSE
      @crib         = []
      @scores       = { player: 0, cpu: 0 }
      @delay        = nil
      @instruction  = nil
    end


    def needs_cursor?   # Enable the mouse cursor
      true
    end


    def update
      return if delaying

      @dbg_score  = nil  # DEBUG

      case @game_phase
        when INITIAL_CUT
          @instruction = 'Cut for Deal'

          if @position && player_cut_card
            set_delay 0.5
            @game_phase = CPU_CUT
            @instruction = nil
          end

        when CPU_CUT
          cpu_cut_card
          set_delay 1
          @game_phase = CUTS_MADE

        when CUTS_MADE
          deal_hands
          @game_phase = DISCARDING

        when DISCARDING
          if @position && @discard_button.inside?( @position )
            discard_crib_cards
            @position = nil
          else
            @position = nil if @position && select_card
          end

        when CUT_CARD
          if @position && @pack.inside?( @position )
            set_turn_card
            @dbg_score = Cribbage::Scorer.new( @player_hand, @card_cut ).evaluate # DEBUG
            @position  = nil

            @play31 = Player31.new( self, @player_hand, @cpu_hand )
            set_phase PLAY_31
            set_arrow( 1, Player31::TOP + CARD_GAP )
          end

        when PLAY_31
          @position = nil if @play31.update( @position )

        when THE_SHOW
          set_arrow( nil )
      end
    end


    def draw
#      puts "Drawing..."
      draw_background
      draw_scores
      draw_instruction if @instruction

      draw_pack_fan if @game_phase <  DISCARDING

      if @game_phase >= DISCARDING
        draw_hands

        @pack.draw    # Always draw the spare pack, then the cut card on top if it's set
        @card_cut.draw( :face_up ) if @card_cut

        @discard_button.draw

        draw_crib if @show_crib

        @play31.draw if @game_phase == PLAY_31

        draw_arrow

        debug_display
      end
    end


    def draw_background
      # Baize
      draw_rectangle( 0, 0, WIDTH, HEIGHT, 0, BAIZE_COLOUR );

      # Score Edge
      draw_rectangle( SCORE_LEFT - CARD_GAP, 1, WIDTH - (SCORE_LEFT - CARD_GAP), 64, 0, SCORE_TEXT_COLOUR )

      # Score Background
      draw_rectangle( (SCORE_LEFT - CARD_GAP) + 1, 2, WIDTH - (SCORE_LEFT - CARD_GAP) - 2, 62, 0, SCORE_BKGR_COLOUR )

      @font.draw( "The Julio", 60, 220, 0, 1, 1, WATERMARK_COLOUR )
    end


    def draw_scores
      player = 'Player '
      width  = @score_font.text_width( player, 1 )
      height = @score_font.height

      @score_font.draw( "CPU", SCORE_LEFT, SCORE_TOP, 1, 1, 1, SCORE_TEXT_COLOUR )
      @score_font.draw( @scores[:cpu], SCORE_LEFT + width, SCORE_TOP, 1, 1, 1, SCORE_NUM_COLOUR )
      @score_font.draw( player, SCORE_LEFT, SCORE_TOP + height, 1, 1, 1, SCORE_TEXT_COLOUR )
      @score_font.draw( @scores[:player], SCORE_LEFT + width, SCORE_TOP + height, 1, 1, 1, SCORE_NUM_COLOUR )
    end


    def draw_instruction
      puts "Drawing Instructions #{@instruction}..."

      width  = @instruction_font.text_width( @instruction )
      margin = @instruction_font.text_width( 'XX' )
      height = @instruction_font.height

      draw_rectangle( MID_X - width/2 - margin, MID_Y - height, width + margin * 2, height * 2, 6, WATERMARK_COLOUR )

      @instruction_font.draw( @instruction, MID_X - width/2, MID_Y - height/2, 7, 1, 1, 0xffffffff )
    end

    def draw_pack_fan
      @pack.draw_fan( CARD_GAP, PACK_TOP, CARD_GAP, :face_down )
    end


    def draw_hands
      if @game_phase == PLAY_31
        @play31.draw_hands
      else
        @player_hand.draw :face_up
        @cpu_hand.draw :peep     # :face_down
      end
    end


    def draw_crib
      @card_back_image.draw( CRIB_LEFT, CRIB_TOP, 1 )
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


    def button_down( btn_id )
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


    def load_fonts
      @font             = Gosu::Font.new( self, 'Century Schoolbook L', 180 )
      @score_font       = Gosu::Font.new( self, 'Serif', 20 )
      @card_font        = Gosu::Font.new( self, 'Arial', 28 )
      @button_font      = Gosu::Font.new( self, 'Arial', 24 )
      @instruction_font = Gosu::Font.new( self, 'Serif', 36 )
    end


    def setup_cards
      Cribbage::GosuCard.set_display( @card_front_image, @card_back_image, @card_font )

      @pack = Cribbage::GosuPack.new
      @pack.set_position( PACK_LEFT, PACK_TOP )
      @pack.set_images( @card_back_image, @card_front_image )

      @card_cut = nil
    end


    def deal_hands
      @pack.reset

      @player_hand = Cribbage::GosuHand.new( @pack )
      @cpu_hand    = Cribbage::GosuHand.new( @pack )

      set_hand_positions
    end

    def set_hand_positions
      @player_hand.set_positions( PLAYER_LEFT, PLAYER_TOP, CARD_WIDTH + CARD_GAP )
      @cpu_hand.set_positions( COMPUTER_LEFT, COMPUTER_TOP, CARD_WIDTH + CARD_GAP )
    end


    def player_cut_card
      card = @pack.card_from_fan( @position, :player )

      return false unless card

      true
    end


    def cpu_cut_card
      x, y = rand( CARD_GAP..(52 * CARD_GAP) ), PACK_TOP + 10

      card = @pack.card_from_fan( x, y, :cpu )
    end


    def set_turn_card
      @card_cut = @pack.cut
      @card_cut.set_position( PACK_LEFT + 2, PACK_TOP + 2 )
    end


    def select_card
      found = false
      @player_hand.cards.each_with_index do |c, idx|
        if c.inside?( @position )
          found = true
          sidx  = @selected.index( idx )

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
      @crib.push( @player_hand.cards[@selected[0]], @player_hand.cards[@selected[1]] )
      @player_hand.discard( *@selected )

      # THIS IS ALL TEMPORARY
      s1, s2 = rand( 0..5 ), rand( 0..5 )
      s2 = ((s1 + 1) % 6) if s1 == s2

      @crib.push( @cpu_hand.cards[s1], @cpu_hand.cards[s2] )

      @cpu_hand.discard( s1, s2 )
      # TO HERE

      @selected  = []
      @show_crib = true
      @discard_button.hide()

      set_hand_positions

      set_phase( CUT_CARD )
      set_arrow( PACK_LEFT - (CARD_GAP * 2), PACK_TOP + CARD_GAP )
    end


    def set_delay( length )
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


    def set_phase( phase )
      @game_phase = phase
    end


private

    def debug_display
      dbg_str = @game_phase.to_s

      dbg_str += " - Selected: #{@selected}"  if !@selected.empty? || @game_phase == DISCARDING
      dbg_str += " - #{@position}"            if @position
      dbg_str += " - Score: #{@dbg_score}"    if @dbg_score

      @button_font.draw( dbg_str, CARD_GAP, MID_Y, 10, 1, 1, 0x80000000 ) unless dbg_str == ''
    end
  end
end



window = CribbageGame::Engine.new
window.show
