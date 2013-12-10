# Represent a pack of cards as a 1..52 array and deal cards from it.

module Cribbage

  class Pack

    def initialize
      @cards = Array.new( 52, 1 )
      @left  = 52   # Cards left
    end

    def deal( klass = Card )
      return nil if empty?    # Is this valid? should we punish emptyness with an exception

      card = rand 52

      card = rand( 52 ) while @cards[card] == 0

      @cards[card] = 0
      @left -= 1
      klass.new( (card / 4) + 1, (card % 4) + 1 )
    end

    def empty?
      @left == 0
    end

    # I can't think of another way to cut a card at the moment

    def cut( klass = Card )
      deal klass
    end

  protected

    attr_reader :left

  end
end
