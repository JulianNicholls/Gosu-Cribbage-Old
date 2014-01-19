require './pack'
require './card'

module Cribbage
  # Holder for a Card

  class Hand
    attr_reader :cards

    def initialize( pack )
      @cards = Array.new( 6 ) { pack.deal }
      @cards.sort_by!( &:rank )
    end

    def discard( *discards )
      fail 'There should be two discards' unless discards.size == 2

      discards.sort.reverse_each { |idx| @cards.slice!( idx ) }
    end

    def to_s
      @cards.map( &:short_name ).join ' '
    end
  end

  # Card that can be displayed in a Gosu window

  class GosuHand < Hand
    def initialize( pack, copy = nil )
      @cards = copy ? copy : Array.new( 6 ) { pack.deal }
      @cards.sort_by!( &:rank )
    end

    def clone
      GosuHand.new( nil, cards.clone )
    end

    def set_positions( point, gap )
      pos = point.dup
      @cards.each do |c|
        c.set_position( pos )
        pos.move_by!( gap, 0 )
      end
    end

    def draw( options )
      @cards.each { |c| c.draw( options ) }
    end
  end
end
