require './hand'

module Cribbage
  # A cribbage hand scorer

  class Scorer
    attr_accessor :crib
    attr_reader   :scores

    def initialize( hand, turncard, crib = false )
      @crib = crib
      set_cards( hand, turncard )
    end

    def set_cards( hand, turncard )
      @hand, @turncard = hand, turncard

      collect_five
      build_combos
    end

    def evaluate
      @scores = {
        fifteen:  fifteens_score,
        pair:     pairs_score,
        run:      runs_score,
        flush:    flush_score,
        nob:      one_for_his_nob
      }

      @scores.values.reduce( :+ )
    end

    private

    def fifteens_score
      return 2 if @thefive.map( &:value ).reduce( :+ ) == 15  # Add all 5

      score = 0

      @fours.each  { |four|  score += 2 if four.map( &:value ).reduce( :+ ) == 15 }
      @threes.each { |three| score += 2 if three.map( &:value ).reduce( :+ ) == 15 }
      @pairs.each  { |pair|  score += 2 if pair.map( &:value ).reduce( :+ ) == 15 }

      score
    end

    # Count pairs, pairs royal, and double pairs royal

    def pairs_score
      @pairs.reduce( 0 ) { |a, e| e.first.rank == e.last.rank ? (a + 2) : a }
    end

    def runs_score
      return 5 if run?( @thefive )

      score = @fours.reduce( 0 ) { |a, e| run?( e ) ? a + 4 : a }
      return score if score > 0

      @threes.reduce( 0 ) { |a, e| run?( e ) ? a + 3 : a }
    end

    def run?( cards )
      (1..cards.size - 1).all? { |idx| cards[idx].rank == cards[idx - 1].rank + 1 }
    end

    # 4 points if all the cards in the hand are the same suit, except in a crib
    # 5 points if the turn card is also the same suit, even in a crib

    def flush_score
      cards     = @hand.cards
      suit      = cards.first.suit
      all_same  = cards.all? { |c| c.suit == suit }
      score     = !@crib && all_same ? 4 : 0
      score     = 5 if all_same && @turncard.suit == suit
      score
    end

    # Jack in hand matches turn card suit

    def one_for_his_nob
      nob = @hand.cards.any? do |c|
        c.rank == Cribbage::Card::JACK && c.suit == @turncard.suit
      end

      nob ? 1 : 0
    end

    # Collect the five cards together in rank/value order

    def collect_five
      @thefive = @hand.cards.dup
      @thefive << @turncard
      @thefive.sort_by!( &:rank )
    end

    # The combos are the combinations of cards in 2s, 3s, and 4s

    def build_combos
      @pairs  = @thefive.combination( 2 ).to_a
      @threes = @thefive.combination( 3 ).to_a
      @fours  = @thefive.combination( 4 ).to_a
    end
  end
end
