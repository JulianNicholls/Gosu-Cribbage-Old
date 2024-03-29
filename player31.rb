require './constants'

require './helpers'

require './scorer31'

module CribbageGame
  # Handle playing to 31 in the game of Cribbage

  class Player31
    include Constants
    include Helpers

    def initialize( engine, p_hand, c_hand, start_with )
      @engine = engine
      @scorer = Scorer31.new( engine )
      @player_hand, @cpu_hand = p_hand.clone, c_hand.clone
      @turn   = start_with

      @card_sets, @cur_set = [], -1

      start_set
    end

    def update( position )
      if @turn == :player && @player_hand.cards.size > 0
        player_select( position )
      elsif @cpu_hand.cards.size > 0
        cpu_select    # It will be possible because it's already been checked
        set_turn
      end
    end

    def draw
      left = PLAY31_POS.x + (CARD_SIZE.width + 3 * CARD_GAP) * @cur_set
      font = @engine.fonts[:score]

      font.draw( 'Count', left, PLAY31_POS.y - 20, 1,
                 1, 1, @engine.colours[:score_text] )

      font.draw( @total,  left + 55, PLAY31_POS.y - 20, 1,
                 1, 1, @engine.colours[:score_num] )

      @card_sets.each { |run| run.each { |c| c.draw( orient: :face_up ) } }
    end

    def draw_hands
      @player_hand.draw( orient: :face_up )
      @cpu_hand.draw( orient: :peep )     # :face_down
    end

    def start_set
      @total    = 0
      @cur_set += 1
      @card_sets[@cur_set] = []

      @position = PLAY31_POS.offset( (CARD_SIZE.width + 3 * CARD_GAP) * @cur_set, 0 )
    end

    def player_select( position )
      return if position.nil?

      @player_hand.cards.each_with_index do |c, idx|
        if c.inside?( position ) && @total + c.value <= 31
          @player_hand.cards.slice!( idx )
          add_card_to_set( c.dup )
          set_turn
        end
      end
    end

    # Select a 'good' card for the CPU.
    #   If it's possible to get to 15 or 31, do that, or
    #   If we can form a pair below 31, otherwise
    #   Choose the highest card that can be laid.
    # In the future, runs will also be considered.
    # The player's cards will NEVER be taken into consideration!

    def cpu_select
      highest, hidx = 0, 0

      @cpu_hand.cards.each_with_index do |c, idx|
        val = c.value

        if @total + val <= 31
          add_cpu_card_to_set( idx ) && return if excellent?( c )

          highest, hidx = val, idx if val > highest
        end
      end

      # No excellent card, so use the highest layable card

      add_cpu_card_to_set( hidx )
    end

    def excellent?( card )
      this_set  = @card_sets[@cur_set]

      @total + card.value == 15 || @total + card.value == 31 ||
      (this_set.length > 0 && card.rank == this_set.last.rank)
    end

    def add_cpu_card_to_set( idx )
      the_card = @cpu_hand.cards[idx].dup
      @cpu_hand.cards.slice!( idx )
      add_card_to_set( the_card )
    end

    def add_card_to_set( card )
      card.place( @position )

      @card_sets[@cur_set] << card
      @total += card.value

      @scorer.evaluate( @card_sets[@cur_set], @total, @turn )

      if @total == 31
        start_set
      else
        @position.move_by!( FANNED_GAP, FANNED_GAP )
      end
    end

    # Attempt to swap to the other player

    def set_turn
      if @turn == :player && @cpu_hand.cards.any? { |c| @total + c.value <= 31 }
        @engine.delay_update 0.5
        @turn = :cpu
      elsif @turn == :cpu && @player_hand.cards.any? { |c| @total + c.value <= 31 }
        @turn = :player
      else
        check_all_cards
      end
    end

    # At this point, we can't swap to the other player because they don't have a
    # card that they can lay.
    # Can we continue with this set, or at all?

    def check_all_cards
      all_cards = @cpu_hand.cards + @player_hand.cards

      if all_cards.length == 0
        complete
      elsif !all_cards.any? { |c| @total + c.value <= 31 }
        # There was no way to continue with the previous set, start a new one with
        # the other player.

        @scorer.peg_player( @turn, 1, 'a Go' )

        start_set

        @turn = other_player @turn
      end

      @engine.delay_update( 1 ) if @turn == :cpu
    end

    def complete
      @scorer.peg_player( @turn, 1, 'the last card' )

      @engine.phase = PLAY_31_DONE
      @engine.delay_update 1.5
    end
  end
end
