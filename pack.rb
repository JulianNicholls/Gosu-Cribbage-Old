# Represent a pack of cards as a 1..52 array and deal cards from it.

require './region'

require './constants'

module Cribbage

  class Pack

    def initialize
      reset
    end

    def reset
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

      @fan, @fan_cards = nil, {}
    end

    def deal
      super( GosuCard )
    end

    alias_method :cut, :deal

    def set_images( front, back )
      @front, @back = front, back
    end

    def set_position( left, top )
      set_area( left, top, CARD_WIDTH, CARD_HEIGHT )
    end

    def draw
      @back.draw( left, top, 1 )
    end

    def draw_fan( pos_left, pos_top, gap, orient = :face_down )
      if @fan
        @fan.each { |c| c.draw( orient ) }
        @fan_cards.keys.each { |k| @fan_cards[k].draw( :face_up ) }
      else
        @fan = []

        while !empty?
          card = deal
          card.set_position( pos_left, pos_top )
          card.draw( orient )
          @fan.push card

          pos_left += gap
        end
      end
    end

    def card_from_fan( x, y = nil, turn = :player )
      @fan.reverse.each do |c|  # Must traverse from the right, because cards overlap each other
        if c.inside?( x, y )
          @fan_cards[turn] = c
          @fan_cards[turn].move_by( 0, (turn == :player) ? CARD_HEIGHT + CARD_GAP : -(CARD_HEIGHT + CARD_GAP) )

          return c
        end
      end

      nil   # Nothing chosen
    end

  end
end
