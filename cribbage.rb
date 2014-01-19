require './gosu_enhanced'
require './helpers'
require './button'

require './constants'

require './hand'
require './scorer'
require './player31'

module CribbageGame
  # Cribbage Game Engine

  class Engine < Gosu::Window
    include Constants
    include Helpers

    attr_reader   :fonts, :colours
    attr_accessor :phase

    PHASES = {
      INITIAL_CUT     =>  :update_initial_cut,
      INITIAL_RECUT   =>  :update_recut,
      CPU_CUT         =>  :update_cpu_cut,
      CUTS_MADE       =>  :update_cuts_made,
      DISCARDING      =>  :update_discarding,
      TURN_CARD       =>  :update_turncard,
      PLAY_31         =>  :update_play31,
      PLAY_31_DONE    =>  :update_play31_done,
      THE_SHOW        =>  :update_theshow
    }

    def initialize
      # Width x Height, not fullscreen, 100ms between 'update's
      super( WIDTH, HEIGHT, false, 100 )

      self.caption = 'Gosu Cribbage'

      load_visuals
      reset_game
    end

    def load_visuals
      @images   = load_images self
      @fonts    = load_fonts self
      @colours  = set_colours

      @discard_button = Button.new(
        self, 'Discard',
        font:   @fonts[:button],
        colour: @colours[:discard],
        point:  DISCARD_BUTTON
      )
    end

    def reset_game
      setup_cards

      @selected         = []
      @phase            = INITIAL_CUT
      @crib, @show_crib = [], FALSE
      @scores           = { player: 0, cpu: 0 }
      @fan_cards        = {}

      @score_reason = @score_reason_timeout = nil
      @instruction  = @position = nil
    end

    def needs_cursor?   # Enable the mouse cursor
      true
    end

    def update
      return if delaying

      if PHASES.key? phase
        send( PHASES[phase] )
      else
        fail "Strange Phase: #{phase}"
      end
    end

    def update_initial_cut
      @instruction = { text: 'Cut for Deal', top: 400 }

      if @position && player_cut_card
        delay_update 1
        self.phase = CPU_CUT
        @instruction = nil
        @position    = nil
      end
    end

    def update_recut
      @instruction = { text: 'Draw, Cut Again', top: 400 }
      @pack.reset
      self.phase = INITIAL_CUT
      delay_update 1
    end

    def update_cpu_cut
      cpu_cut_card
      decide_dealer
      delay_update 1.5
    end

    def update_cuts_made
      deal_hands
      self.phase = DISCARDING
    end

    def update_discarding
      @instruction = { text: 'Click to Select for Discard' }

      if @discard_button.inside?( @position )
        discard_crib_cards
        @position = nil
      else
        select_discard
      end
    end

    def update_turncard
      if @turn == :cpu
        update_cpu_turncard
      else
        update_player_turncard
      end

      if phase == PLAY_31
        @play31 = Player31.new( self, @player_hand, @cpu_hand, @turn )

        # Two for his heels
        @scores[@turn] += 2 if @turn_card.rank == Cribbage::Card::JACK
      end
    end

    def update_cpu_turncard
      @instruction = { text: 'CPU is choosing Turn-up Card', left: 150 }
      set_turn_card
      delay_update 1.5
      self.phase = PLAY_31
    end

    def update_player_turncard
      @instruction = { text: 'Click Pack for Turn-up Card', left: 150 }

      if @position && @pack.inside?( @position )
        set_turn_card
        @position  = nil

        self.phase = PLAY_31
      end
    end

    def update_play31
      @instruction  = nil
      @play31.update( @position )
      @position     = nil
    end

    def update_play31_done
      self.phase = THE_SHOW
    end

    def update_theshow
      @turn = other_player @dealer
    end

    def draw
#      puts "Drawing..."
      draw_background
      draw_scores
      draw_instruction if @instruction

      draw_pack_fan && return if @phase < DISCARDING

      draw_hands
      draw_pack_and_turnup
      draw_crib if @show_crib

      @discard_button.draw

      @play31.draw if [PLAY_31, PLAY_31_DONE].include? phase
    end

    def draw_background
      # Baize
      draw_rectangle( Point.new( 0, 0 ), Size.new( WIDTH, HEIGHT ),
                      0, @colours[:baize] )

      # 'Watermark' on the background
      @fonts[:watermark].draw(
        'The Julio', WATERMARK.x, WATERMARK.y, 0,
        1, 1, @colours[:watermark]
      )

      draw_score_box
      draw_grid
    end

    def draw_score_box
      box  = Point.new( SCORE.x - MARGIN, 1 )
      size = Size.new( WIDTH - (SCORE.x - MARGIN), SCORE_BOX_HEIGHT )

      draw_rectangle( box, size, 0, @colours[:score_text] )

      draw_rectangle( box.offset( 1, 1 ), size.inflate( -2, -2 ), 0,
                      @colours[:score_bkgr] )
    end

    def draw_grid
      vert  = Size.new( 1, HEIGHT )
      horiz = Size.new( WIDTH, 1 )

      0.step( WIDTH - 50, 50 ).each do |l|
        draw_rectangle( Point.new( l, 0 ), vert, 0, @colours[:watermark] )
      end

      0.step( HEIGHT - 50, 50 ).each do |t|
        draw_rectangle( Point.new( 0, t ), horiz, 0, @colours[:watermark] )
      end
    end

    def draw_pack_and_turnup
      # Always draw the spare pack, then the turnup card on top if it's set

      @pack.draw
      @turn_card.draw( orient: :face_up ) if @turn_card
    end

    def draw_scores
      player    = 'Player '
      font      = @fonts[:score]
      size      = font.measure( player )
      text, num = @colours[:score_text], @colours[:score_num]

      font.draw( 'CPU', SCORE.x, SCORE.y, 1, 1, 1, text )
      font.draw( @scores[:cpu], SCORE.x + size.width, SCORE.y, 1, 1, 1, num )

      font.draw( player, SCORE.x, SCORE.y + size.height, 1, 1, 1, text )
      font.draw( @scores[:player], SCORE.x + size.width,
                 SCORE.y + size.height, 1, 1, 1, num )

      if @score_reason && Time.now < @score_reason_timeout
        draw_score_reason
      else
        @score_reason = nil
      end
    end

    def draw_score_reason
      font  = @fonts[:score]
      size  = font.measure( 'x' )
      width = font.text_width( @score_reason ) + 2 * size.width

      draw_rectangle(
        Point.new( WIDTH - (width + 1), SCORE_BOX_HEIGHT + 4 ),
        Size.new( width, size.height ), 0, @colours[:watermark] )

      font.draw(
        @score_reason, WIDTH - (width - size.width), SCORE_BOX_HEIGHT + 6, 1,
        1, 1, Gosu::Color::WHITE )
    end

    def draw_instruction
#      puts "Drawing Instructions #{@instruction[:text]}..."

      font    = @fonts[:instructions]
      size    = font.measure( @instruction[:text] )
      margin  = font.text_width( 'X' )

      left = @instruction[:left] || [MID_X - (size.width / 2), 3].max
      top  = @instruction[:top]  || INSTRUCTION_TOP

      draw_rectangle( Point.new( left - margin, top ),
                      Size.new( size.width + margin * 2, size.height * 2 ), 6,
                      @colours[:watermark] )

      font.draw( @instruction[:text], left, top + size.height / 2, 7,
                 1, 1, Gosu::Color::WHITE )
    end

    def draw_pack_fan
      @pack.draw_fan( FAN_POS, CARD_GAP, orient: :face_down )
    end

    def draw_hands
      if [PLAY_31, PLAY_31_DONE].include? phase
        @play31.draw_hands
      else
        @player_hand.draw( orient: :face_up )
        @cpu_hand.draw( orient: :peep )    # :face_down
      end
    end

    def draw_crib
      @images[:back].draw( CRIB_POS.x, CRIB_POS.y, 1 )
    end

    def button_down( btn_id )
      case btn_id
      when Gosu::KbEscape   then  close
      when Gosu::KbR        then  reset_game

      when Gosu::MsLeft     then  @position = Point.new( mouse_x, mouse_y )
      end
    end

    def setup_cards
      Cribbage::GosuCard.set_display(
        @images[:front], @images[:back], @fonts[:card]
      )

      @pack = Cribbage::GosuPack.new
      @pack.place( PACK_POS )
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
      @player_hand.set_positions( PLAYER_HAND, CARD_SIZE.width + CARD_GAP )
      @cpu_hand.set_positions( COMPUTER_HAND, CARD_SIZE.width + CARD_GAP )
    end

    def player_cut_card
      @fan_cards[:player] = @pack.card_from_fan( @position, :player )

      return false unless @fan_cards[:player]

      true
    end

    def cpu_cut_card
      point = Point.new(
        rand( FAN_POS.x..(FAN_POS.x + 51 * CARD_GAP) ),
        PACK_POS.y + 10 )

      @fan_cards[:cpu] = @pack.card_from_fan( point, :cpu )
    end

    def decide_dealer
      @dealer = nil

      @dealer = :player if @fan_cards[:player].rank < @fan_cards[:cpu].rank
      @dealer = :cpu    if @fan_cards[:cpu].rank < @fan_cards[:player].rank

      if @dealer.nil?   # Draw
        self.phase = INITIAL_RECUT   # Go again
        return
      end

      @turn = other_player @dealer
      self.phase = CUTS_MADE
    end

    def set_turn_card
      @turn_card = @pack.cut
      @turn_card.place( PACK_POS.offset( 2, 2 ) )
    end

    def select_discard
      @player_hand.cards.each_with_index do |c, idx|
        if c.inside?( @position )
          @position = nil
          select_card( c, idx )
        end
      end

      @discard_button.visible = (@selected.length == 2)
    end

    def select_card( card, idx )
      sidx = @selected.index( idx )

      if sidx
        @selected.slice! sidx
        card.move_by!( 0, CARD_GAP )  # Return to normal
      elsif @selected.length < 2
        @selected << idx
        card.move_by!( 0, -CARD_GAP ) # Push up to indicate selection
      end
    end

    def discard_crib_cards
      player_discard_to_crib
      cpu_discard_to_crib

      @show_crib = true
      @discard_button.hide

      set_hand_positions

      self.phase = TURN_CARD
    end

    def player_discard_to_crib
      add_cards_to_crib(
        @player_hand.cards[@selected[0]], @player_hand.cards[@selected[1]]
      )

      @player_hand.discard( *@selected )
      @selected = []
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

    def set_score( player, value, reason = nil )
      @scores[player] += value

      if reason
        @score_reason = player_name( player ) + " scored #{value} for " + reason
        @score_reason_timeout = Time.now + 2
      end
    end

    private

    def swap_player
      @turn = other_player( @turn )
    end
  end
end

window = CribbageGame::Engine.new
window.show
