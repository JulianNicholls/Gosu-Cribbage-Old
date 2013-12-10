require './pack'
require './card'

module Cribbage

  class Hand

    attr_reader :cards
    def initialize( pack )
      @cards = Array.new( 6 ) { pack.deal }
      @cards.sort_by! { |c| c.rank }
    end

    def discard( *discards )
      raise Exception.new( "There should be two discards" ) unless discards.size == 2

      discards.sort.reverse.each { |idx| @cards.slice!( idx ) }
    end

    def to_s
      @cards.map( &:short_name ).join ' '
    end

  end

  class GosuHand < Hand
    def initialize( pack )
      @cards = Array.new( 6 ) { pack.deal( GosuCard ) }
      @cards.sort_by! { |c| c.rank }
    end
  end
end
