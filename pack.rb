# Represent a pack of cards as a 1..52 array and deal cards from it.

require './region'

require './constants'

module Cribbage

  class Pack

    def initialize
      @cards      = Array.new( 52, 1 )
      @cards_left = 52
    end

    def deal( klass = Card )
      return nil if empty?    # Is this valid? should we punish emptyness with an exception

      card = rand 52

      card = rand( 52 ) while @cards[card] == 0

      @cards[card] = 0
      @cards_left -= 1
      klass.new( (card / 4) + 1, (card % 4) + 1 )
    end

    def empty?
      @cards_left == 0
    end

    # I can't think of another way to cut a card at the moment

    def cut( klass = Card )
      deal klass
    end

  protected

    attr_reader :cards_left

  end

  class GosuPack < Pack

    include Region
    include CribbageGame::Constants

    def initialize
      super

      @fan = []
    end

    def deal
      super( GosuCard )
    end

    alias_method :cut, :deal

    def set_images( back, front )
      @back, @front = back, front
    end

    def set_position( left, top )
      set_area( left, top, CARD_WIDTH, CARD_HEIGHT )
    end

    def draw
      @back.draw( left, top, 1 )
    end

    def draw_fan( pos_left, pos_top, gap, orient )
      while left > 0
        card = deal( GosuCard )
        card.set_position( pos_left, pos_top )
        card.draw( orient )
        @fan.push card

        pos_left += gap
      end
    end
  end
end
