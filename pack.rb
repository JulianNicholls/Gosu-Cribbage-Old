require './region'

require './constants'

module Cribbage
  # Represent a pack of cards as a 1..52 array and deal cards from it.

  class Pack
    def initialize
      reset
    end

    def reset
      @cards      = Array.new( 52, 1 )
      @cards_left = 52
    end

    def deal( klass = Card )
      return nil if empty?    # Should we punish emptyness with an exception

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

  # A pack that can display itself on a Gosu window

  class GosuPack < Pack
    include Region
    include CribbageGame::Constants

    def initialize
      super

      @fan, @fan_cards = nil, {}
    end

    def reset
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

    def set_position( point )
      set_area( point, CARD_SIZE )
    end

    def draw
      @back.draw( left, top, 1 )
    end

    def draw_fan( point, gap, options )
      generate_fan( point, gap ) unless @fan

      @fan.each { |c| c.draw( options ) }
      @fan_cards.keys.each { |k| @fan_cards[k].draw( orient: :face_up ) }
    end

    def generate_fan( point, gap )
      @fan = []
      pos = point.dup

      until empty?
        card = deal
        card.set_position( pos )
        @fan.push card

        pos.move_by!( gap, 0 )
      end
    end

    def card_from_fan( point, turn = :player )
      # Must traverse from the right, because cards overlap each other

      @fan.reverse_each do |c|
        if c.inside?( point )
          @fan_cards[turn] = c
          delta = CARD_SIZE.height + CARD_GAP
          @fan_cards[turn].move_by!( 0, turn == :player ? delta : -delta )

          return c
        end
      end

      nil   # Nothing chosen
    end
  end
end
