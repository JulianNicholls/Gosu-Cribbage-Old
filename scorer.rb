require './hand'

module Cribbage

  class Scorer

    attr_accessor :crib

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
      fifteens_score + pairs_score + runs_score+ flush_score + one_for_his_nob
    end


  private

    def fifteens_score
      return 2 if @thefive.map( &:value ).reduce( :+ ) == 15  # Add all 5

      score = 0

      # There's a complication for threes because combos like 6 3 6 are scored twice
      # like this: (6S + 3S) + 6D and 6S + (3S + 6D)
      # but 5 5 5 is just worth 2

      @threes.each do |three|
        if three.map( &:value ).reduce( :+ ) == 15
          score += 2
          score += 2 if three[0].rank != 5 && (three[0].rank == three[1].rank || three[0].rank == three[2].rank || three[2].rank == three[1].rank)
        end
      end

      @fours.each { |four| score += 2 if four.map( &:value ).reduce( :+ ) == 15 }
      @pairs.each { |pair| score += 2 if pair.map( &:value ).reduce( :+ ) == 15 }

      score
    end

    def pairs_score
      @pairs.reduce( 0 ) { |score, pair| (pair[0].rank == pair[1].rank) ? (score + 2) : score }
    end

    def runs_score
      return 5 if run?( @thefive )

      score = @fours.reduce( 0 ) { |score, cards| run?( cards ) ? score + 4 : score }
      return score if score > 0

      @threes.reduce( 0 ) { |score, cards| run?( cards ) ? score + 3 : score }
    end

    def run?( cards )
      (1..cards.size-1).all? { |idx| cards[idx].rank == cards[idx-1].rank + 1 }
    end

    # 4 points if all the cards in the hand are the same suit, except in a crib
    # 5 points if the turn card is also the same suit, even in a crib

    def flush_score
      cards     = @hand.cards
      suit      = cards.first.suit
      all_same  = cards.all? { |c| c.suit == suit }
      score     = (!@crib && all_same) ? 4 : 0
      score     = 5 if all_same && @turncard.suit == suit
      score
    end

    def one_for_his_nob
      @hand.cards.reduce( 0 ) { |score, c| (c.rank == Cribbage::Card::JACK && c.suit == @turncard.suit) ? (score + 1) : score }
    end

    # Collect the five cards together in rank/value order

    def collect_five
      @thefive = @hand.cards.dup
      @thefive << @turncard
      @thefive.sort_by! { |c| c.rank }
    end

    # The combos are built in decreasing size order,
    # i.e. the first one is all 5 cards, followed by the combinations of
    # 4 cards, and so on

    def build_combos
      @pairs  = @thefive.combination( 2 ).to_a
      @threes = @thefive.combination( 3 ).to_a
      @fours  = @thefive.combination( 4 ).to_a
    end

  end

end
