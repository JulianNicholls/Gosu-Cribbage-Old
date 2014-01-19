require './region'

require './constants'

module Cribbage
  # class to hold a card. both rank and suit are 1-based.

  class Card
    attr_reader :suit, :rank

    HEARTS    = 1
    CLUBS     = 2
    DIAMONDS  = 3
    SPADES    = 4

    ACE       = 1
    TEN       = 10
    JACK      = 11
    QUEEN     = 12
    KING      = 12 + 1  # Superstitious much?

    SUITS = %w{Hearts Clubs Diamonds Spades}
    RANKS = %w{Ace 2 3 4 5 6 7 8 9 Ten Jack Queen King}
    SUIT_CHARS = "\u2665\u2663\u2666\u2660"   # Not all fonts have these

    def initialize( rank, suit )
      @rank, @suit = rank, suit
    end

    def to_s
      name
    end

    def name
      "#{rank_name} of #{suit_name}"
    end

    def short_name
      "#{rank_name.slice(0)}#{suit_name.slice(0)}"
    end

    def display_name
      "#{rank == 10 ? '10' : rank_name.slice(0)}#{suit_char}"
    end

    def rank_name
      RANKS[@rank - 1]
    end

    def suit_name
      SUITS[@suit - 1]
    end

    def suit_char
      SUIT_CHARS[@suit - 1]
    end

    def value
      [rank, 10].min
    end     # Return 10 for 10, J, Q, K

    def inspect
      short_name
    end
  end

  # Card that can display itself
  class GosuCard < Card
    include Region
    include CribbageGame::Constants

    RED_COLOUR   = 0xffa00000

    def self.set_display( front, back, font )
      @images = {
        front:  front,
        back:   back
      }

      @font = font
    end

    def set_position( point )
      set_area( point, CARD_SIZE )
    end

    class << self
      attr_reader :images, :font
    end

    def draw( options )
      orient = options[:orient] || :face_down

      draw_image( options )

      draw_text( options ) if orient == :face_up || orient == :peep
    end

    def draw_image( options )
      if options[:orient] == :face_up
        image = options[:front] || self.class.images[:front]
      else
        image = options[:back] || self.class.images[:back]
      end

      image.draw( left, top, 1 )
    end

    def draw_text( options )
      cfont = options[:font] || self.class.font
      cfont.draw( display_name,
                  left + 5, top + 5, 1,
                  1, 1,
                  suit.odd? ? RED_COLOUR : Gosu::Color::BLACK
      )
    end
  end
end

if $PROGRAM_NAME == __FILE__
  pack = Cribbage::Pack.new

  53.times do
    card = pack.deal
    print card ? "#{card.short_name}, " : 'nil'
  end
end
