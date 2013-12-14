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
    KING      = 12+1  # Superstitious much?

    SUITS = %w{Hearts Clubs Diamonds Spades}
    RANKS = %w{Ace 2 3 4 5 6 7 8 9 Ten Jack Queen King}
    SUIT_CHARS = "\u2665\u2663\u2666\u2660"   # Use with care, not all fonts have these characters

    attr_reader :rank, :suit

    def initialize( rank, suit )
      @rank, @suit = rank, suit
    end

    def to_s; name; end

    def name;         "#{rank_name} of #{suit_name}";               end

    def short_name;   "#{rank_name.slice(0)}#{suit_name.slice(0)}"; end

    def display_name
      "#{rank == 10 ? '10' : rank_name.slice(0)}#{suit_char}"
    end

    def rank_name;    RANKS[@rank - 1];       end
    def suit_name;    SUITS[@suit - 1];       end
    def suit_char;    SUIT_CHARS[@suit - 1];  end

    def value;    [rank, 10].min;   end     # Return 10 for 10, J, Q, K

    def inspect;  short_name; end
  end


  class GosuCard < Card

    include Region
    include CribbageGame::Constants

    RED_COLOUR   = 0xffa00000
    BLACK_COLOUR = 0xff000000

    def self.set_display( front, back, font )
      @@back_image, @@front_image = back, front
      @@font = font
    end

    def set_position( pos_left, pos_top )
      set_area( pos_left, pos_top, CARD_WIDTH, CARD_HEIGHT )
    end

    def draw( orient = :face_up, front = nil, back = nil, font = nil )
      if orient == :face_down || orient == :peep
        image = back || @@back_image
        image.draw( left, top, 1 )
      else
        image = front || @@front_image
        image.draw( left, top, 1 )
      end

      if orient == :face_up || orient == :peep
        cfont = font  || @@font
        cfont.draw( display_name, left + 5, top + 5, 1, 1, 1, suit.odd? ? RED_COLOUR : BLACK_COLOUR )
      end
    end
  end

end


if $0 == __FILE__
  pack = Cribbage::Pack.new

  53.times do
    card = pack.deal
    print card ? "#{card.short_name}, " : 'nil'
  end
end
