require './constants'

class Player31

  include CribbageGame::Constants

  TOP  = COMPUTER_TOP + CARD_HEIGHT + CARD_GAP * 2
  LEFT = CARD_GAP


  def initialize( engine, p_hand, c_hand, start_with = :player )
    @engine = engine
    @player_hand, @cpu_hand = p_hand.clone, c_hand.clone
    @turn = start_with

    @run_cards = []
    @run_num   = -1

    start_run
  end

  def update( position )
    if @turn == :player
      if position
        selected = player_select position

        set_turn if selected
        return selected
      end
    else
      cpu_select    # It will be possible because it's already been checked
      set_turn
    end

    false   # User didn't select
  end

  def draw
    @engine.score_font.draw( 'Total', LEFT + (CARD_WIDTH + CARD_GAP) * @run_num, TOP - 20, 1, 1, 1, SCORE_TEXT_COLOUR )
    @engine.score_font.draw( @total,  LEFT + (CARD_WIDTH + CARD_GAP) * @run_num + 50, TOP - 20, 1, 1, 1, SCORE_NUM_COLOUR )

    @run_cards.each do |run|
      run.each { |c| c.draw :face_up }
    end
  end


  def draw_hands
    @player_hand.draw :face_up
    @cpu_hand.draw :peep     # :face_down
  end


  def start_run
    @total   = 0
    @run_num += 1
    @run_cards[@run_num] = []

    @top, @left  = TOP, LEFT + (CARD_WIDTH + CARD_GAP) * @run_num
  end


  def player_select position
    idx = 0

    while idx < @player_hand.cards.length
      c = @player_hand.cards[idx]

      if c.inside?( position ) && @total + c.value <= 31
        @player_hand.cards.slice!( idx )
        add_card_to_run c.dup
        return true
      end

      idx += 1
    end

    false
  end


  # Select a 'good' card for the CPU. if it's possible to get to 15 or 31, do that, otherwise
  # choose the highest card that can be laid.
  # In the future, possible pairs / pairs royal and runs will also be considered.
  # The player's cards will NEVER be taken into consideration!

  def cpu_select
    idx = 0
    highest, hidx = 0, 0

    while idx < @cpu_hand.cards.length
      c = @cpu_hand.cards[idx]

      if @total + c.value == 15 || @total + c.value == 31
        @cpu_hand.cards.slice!( idx )
        add_card_to_run c.dup
        return
      end

      highest, hidx = c.value, idx if c.value > highest && @total + c.value < 31
      idx += 1
    end

    the_card = @cpu_hand.cards[hidx].dup
    @cpu_hand.cards.slice!( hidx )
    add_card_to_run the_card
  end


  def add_card_to_run( card )
    card.set_position( @left, @top )

    @run_cards[@run_num] << card
    @total += card.value

    @engine.update_player_score( 2 ) if @turn == :player && (@total == 15 || @total == 31)
    @engine.update_cpu_score( 2 )    if @turn == :cpu    && (@total == 15 || @total == 31)

    if @total == 31
      start_run
    else
      @top += 25
      @left += 25
    end
  end

  def set_turn
    if @turn == :player && @cpu_hand.cards.any? { |c| @total + c.value <= 31 }
      @engine.set_delay 0.5
      @turn = :cpu
    elsif @turn == :cpu && @player_hand.cards.any? { |c| @total + c.value <= 31 }
      @turn = :player
    else  # At this point, we can't swap to the other player because they don't have a
          # card that they can lay.
          # Can we continue with this run, or at all?

      all_cards = @cpu_hand.cards + @player_hand.cards

      if all_cards.length > 0
        if all_cards.any? { |c| @total + c.value <= 31 }
          @engine.set_delay( 0.5 ) if @turn == :cpu
          return  # Continue with same player
        elsif @turn == :player
          @engine.update_player_score 1
        else
          @engine.updatecpu_score 1
        end

        # There was no way to continue with the previous run, start a new one with
        # the other player

        start_run
        if @turn == :player
          @turn = :cpu
          @engine.set_delay( 0.5 )
        else
          @turn = :player
        end
      else  # No cards left
        if @turn == :player
          @engine.update_player_score 1
        else
          @engine.update_cpu_score 1
        end

        @engine.set_phase THE_SHOW
        @engine.set_delay 0.5
      end
    end
  end

end