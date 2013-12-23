require './gosu_enhanced'
require './helpers'
require './button'

require './constants'

require './hand'
require './scorer'
require './player31'


module CribbageGame
  class Engine < Gosu::Window

    include Constants
    include Helpers


    attr_reader   :fonts
    attr_accessor :scores


    def initialize
      super( WIDTH, HEIGHT, false, 100 )  # Width x Height, not fullscreen, 100ms between 'update's

      self.caption = "Gosu Cribbage"

      @images = load_images self
      @fonts  = load_fonts self
      @discard_button = Button.new( self, 'Discard', @fonts[:button], DISCARD_COLOUR, DISCARD_LEFT, DISCARD_TOP )

      reset
    end


    def reset
      setup_cards

      @selected     = []
      @game_phase   = INITIAL_CUT
      @show_crib    = FALSE
      @crib         = []
      @scores       = { player: 0, cpu: 0 }
      @instruction  = nil
      @fan_cards    = {}
    end


    def needs_cursor?   # Enable the mouse cursor
      true
    end


    def update
      return if delaying

      case @game_phase
        when INITIAL_CUT
          @instruction = { text: 'Cut for Deal', top: 400 }

          if @position && player_cut_card
            set_delay 1
            set_phase CPU_CUT
            @instruction = nil
            @position = nil
          end

        when CPU_CUT
          cpu_cut_card
          decide_dealer
          set_delay 1.5

        when CUTS_MADE
          deal_hands
          set_phase DISCARDING

        when DISCARDING
          @instruction = { text: 'Click to Select for Discard' }

          if @position
            if @discard_button.inside?( @position )
              discard_crib_cards
              @position = nil
            else
              @position = nil if select_discard
            end
          end

        when CUT_CARD
          if @turn == :cpu
            @instruction = { text: "CPU is choosing Turn-up Card", left: 150 }
            set_turn_card
            set_delay 1
            set_phase PLAY_31
          else
            @instruction = { text: "Click Pack for Turn-up Card", left: 150 }

            if @position && @pack.inside?( @position )
              set_turn_card
              @position  = nil

              set_phase PLAY_31
            end
          end

          if @game_phase == PLAY_31
            @play31 = Player31.new( self, @player_hand, @cpu_hand, @turn )
            @scores[@turn] += 2 if @turn_card.rank == Cribbage::Card::JACK   # Two for his heels
          end

        when PLAY_31
          @instruction  = nil
          @position     = nil if @play31.update( @position )

        when PLAY_31_DONE
          set_phase THE_SHOW

        when THE_SHOW
          @turn = other_player @dealer
      end
    end


    def draw
#      puts "Drawing..."
      draw_background
      draw_scores
      draw_instruction if @instruction

      draw_pack_fan if @game_phase < DISCARDING

      if @game_phase >= DISCARDING
        draw_hands

        @pack.draw    # Always draw the spare pack, then the cut card on top if it's set
        @turn_card.draw( orient: :face_up ) if @turn_card

        @discard_button.draw

        draw_crib if @show_crib

        @play31.draw if [PLAY_31, PLAY_31_DONE].include? @game_phase
      end
    end


    def draw_background
      # Baize
      draw_rectangle( 0, 0, WIDTH, HEIGHT, 0, BAIZE_COLOUR );

      # Score Edge and Background
      draw_rectangle( SCORE_LEFT - MARGIN, 1, WIDTH - (SCORE_LEFT - MARGIN), 64, 0, SCORE_TEXT_COLOUR )
      draw_rectangle( (SCORE_LEFT - MARGIN) + 1, 2, WIDTH - (SCORE_LEFT - MARGIN) - 2, 62, 0, SCORE_BKGR_COLOUR )

      # 'Watermark' on the background
      @fonts[:watermark].draw( "The Julio", WATERMARK_LEFT, WATERMARK_TOP, 0, 1, 1, WATERMARK_COLOUR )

      # Grid

      0.step( WIDTH-50, 50 ).each do |l|
        draw_rectangle( l, 0, 2, HEIGHT, 0, WATERMARK_COLOUR )
      end

      0.step( HEIGHT-50, 50 ).each do |t|
        draw_rectangle( 0, t, WIDTH, 2, 0, WATERMARK_COLOUR )
      end
    end


    def draw_scores
      player  = 'Player '
      font    = @fonts[:score]
      width   = font.text_width( player, 1 )
      height  = font.height

      font.draw( "CPU", SCORE_LEFT, SCORE_TOP, 1, 1, 1, SCORE_TEXT_COLOUR )
      font.draw( @scores[:cpu], SCORE_LEFT + width, SCORE_TOP, 1, 1, 1, SCORE_NUM_COLOUR )
      font.draw( player, SCORE_LEFT, SCORE_TOP + height, 1, 1, 1, SCORE_TEXT_COLOUR )
      font.draw( @scores[:player], SCORE_LEFT + width, SCORE_TOP + height, 1, 1, 1, SCORE_NUM_COLOUR )
    end


    def draw_instruction
#      puts "Drawing Instructions #{@instruction[:text]}..."

      font   = @fonts[:instructions]
      width  = font.text_width( @instruction[:text] )
      margin = font.text_width( 'X' )
      height = font.height

      left = @instruction[:left] || [MID_X - (width/2), 3].max
      top  = @instruction[:top]  || INSTRUCTION_TOP

      draw_rectangle( left - margin, top, width + margin * 2, height * 2, 6, WATERMARK_COLOUR )

      font.draw( @instruction[:text], left, top + height/2, 7, 1, 1, 0xffffffff )
    end


    def draw_pack_fan
      @pack.draw_fan( FAN_LEFT, PACK_TOP, CARD_GAP, orient: :face_down )
    end


    def draw_hands
      if [PLAY_31, PLAY_31_DONE].include? @game_phase
        @play31.draw_hands
      else
        @player_hand.draw( orient: :face_up )
        @cpu_hand.draw( orient: :peep )    # :face_down
      end
    end


    def draw_crib
      @images[:back].draw( CRIB_LEFT, CRIB_TOP, 1 )
    end


    def button_down( btn_id )
      case btn_id
        when Gosu::KbEscape   then  close
        when Gosu::KbR        then  reset

        when Gosu::MsLeft     then  @position = [mouse_x, mouse_y]
      end
    end


    def setup_cards
      Cribbage::GosuCard.set_display( @images[:front], @images[:back], @fonts[:card] )

      @pack = Cribbage::GosuPack.new
      @pack.set_position( PACK_LEFT, PACK_TOP )
      @pack.set_images( @images[:front], @images[:back] )

      @turn_card = nil
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
      @fan_cards[:player] = @pack.card_from_fan( @position, :player )

      return false unless @fan_cards[:player]

      true
    end


    def cpu_cut_card
      x, y = rand( FAN_LEFT..(FAN_LEFT + 51 * CARD_GAP) ), PACK_TOP + 10

      @fan_cards[:cpu] = @pack.card_from_fan( x, y, :cpu )
    end


    def decide_dealer
      if @fan_cards[:player].rank < @fan_cards[:cpu].rank
        @dealer = :player
      elsif @fan_cards[:cpu].rank < @fan_cards[:player].rank
        @dealer = :cpu
      else  # Both the same
        set_delay 1
        set_phase INITIAL_CUT   # Go again
        @pack.reset
        return
      end

      @turn = other_player @dealer
      set_phase CUTS_MADE
    end


    def set_turn_card
      @turn_card = @pack.cut
      @turn_card.set_position( PACK_LEFT + 2, PACK_TOP + 2 )
    end


    def select_discard
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
      add_cards_to_crib( @player_hand.cards[@selected[0]], @player_hand.cards[@selected[1]] )
      @player_hand.discard( *@selected )

      cpu_discard_to_crib

      @selected  = []
      @show_crib = true
      @discard_button.hide()

      set_hand_positions

      set_phase( CUT_CARD )
    end


    def cpu_discard_to_crib
      # THIS IS ALL TEMPORARY
      s1, s2 = rand( 0..5 ), rand( 0..5 )
      s2 = ((s1 + 1) % 6) if s1 == s2

      add_cards_to_crib( @cpu_hand.cards[s1], @cpu_hand.cards[s2] )

      @cpu_hand.discard( s1, s2 )
    end


    def add_cards_to_crib( c1, c2 )
      @crib.push( c1, c2 )
    end


    def set_phase( phase )
      @game_phase = phase
    end


private

    def swap_player
      @turn = other_player( @turn )
    end

  end
end



window = CribbageGame::Engine.new
window.show
