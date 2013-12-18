require './constants'

class Player31

  include CribbageGame::Constants

  TOP  = COMPUTER_TOP + CARD_HEIGHT + CARD_GAP * 2
  LEFT = CARD_GAP


  def initialize( engine, p_hand, c_hand, start_with = :player )
    @engine = engine
    @player_hand, @cpu_hand = p_hand.clone, c_hand.clone
    @turn   = start_with

    @card_sets = []
    @cur_set   = -1

    start_set
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
    left = LEFT + (CARD_WIDTH + CARD_GAP) * @cur_set
    @engine.score_font.draw( 'Total', left, TOP - 20, 1, 1, 1, SCORE_TEXT_COLOUR )
    @engine.score_font.draw( @total,  left + 50, TOP - 20, 1, 1, 1, SCORE_NUM_COLOUR )

    @card_sets.each do |run|
      run.each { |c| c.draw :face_up }
    end
  end


  def draw_hands
    @player_hand.draw :face_up
    @cpu_hand.draw :peep     # :face_down
  end


  def start_set
    @total    = 0
    @cur_set += 1
    @card_sets[@cur_set] = []

    @top, @left  = TOP, LEFT + (CARD_WIDTH + CARD_GAP) * @cur_set
  end


  def player_select position
    @player_hand.cards.each_with_index do |c, idx|
      if c.inside?( position ) && @total + c.value <= 31
        @player_hand.cards.slice!( idx )
        add_card_to_set c.dup
        return true
      end
    end

    false
  end


  # Select a 'good' card for the CPU.
  #   If it's possible to get to 15 or 31, do that, or
  #   If we can form a pair below 31, otherwise
  #   Choose the highest card that can be laid.
  # In the future, runs will also be considered.
  # The player's cards will NEVER be taken into consideration!

  def cpu_select
    highest, hidx = 0, 0

    this_set = @card_sets[@cur_set]

    @cpu_hand.cards.each_with_index do |c, idx|
      val = c.value

      if @total + val <= 31
        if @total + val == 15 || @total + val == 31 ||
         (this_set.length > 0 && c.rank == this_set[-1].rank)
          @cpu_hand.cards.slice!( idx )
          add_card_to_set c.dup
          return
        end

        highest, hidx = val, idx if val > highest
      end
    end

    # No excellent card, so use the highest layable card

    the_card = @cpu_hand.cards[hidx].dup
    @cpu_hand.cards.slice!( hidx )
    add_card_to_set the_card
  end


  def add_card_to_set( card )
    card.set_position( @left, @top )

    @card_sets[@cur_set] << card
    @total += card.value

    score_last_cards

    if @total == 31
      start_set
    else
      @top  += 25
      @left += 25
    end
  end


  def score_last_cards
    this_set  = @card_sets[@cur_set]
    top       = this_set[-1]    # Last card played

    score_current_player( 2 ) if @total == 15 || @total == 31

    score_current_player( 6 ) if this_set.length >= 4 && this_set[-4..-2].all? { |c| c.rank == top.rank }

    if this_set.length >= 3
      score_current_player( 4 ) if this_set[-3..-2].all? { |c| c.rank == top.rank }
      score_runs
    end

    score_current_player( 2 ) if this_set.length >= 2 && this_set[-2].rank == top.rank
  end

  def score_runs
    this_set = @card_sets[@cur_set]

    this_set.length.downto(3) do |n|
      if run?( this_set[-n..-1].sort_by { |c| c.rank } )
        score_current_player n
        return
      end
    end
  end

  def run?( cards )
    (1..cards.size-1).all? { |idx| cards[idx].rank == cards[idx-1].rank + 1 }
  end


  # Attempt to swap to the other player

  def set_turn
    if @turn == :player && @cpu_hand.cards.any? { |c| @total + c.value <= 31 }
      @engine.set_delay 0.5
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

    if all_cards.length > 0
      if all_cards.any? { |c| @total + c.value <= 31 }
        @engine.set_delay( 0.5 ) if @turn == :cpu
        return  # Continue with same player
      else
        score_current_player 1
      end

      # There was no way to continue with the previous set, start a new one with
      # the other player.

      start_set

      if @turn == :player
        @turn = :cpu
        @engine.set_delay 1
      else
        @turn = :player
      end
    else      # No cards left, we're outta here!
      score_current_player 1

      @engine.set_phase THE_SHOW
      @engine.set_delay 1
    end
  end


  def score_current_player( by )
    @engine.scores[@turn] += by
  end

end
