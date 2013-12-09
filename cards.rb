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
    SUIT_CHARS = "\u2665\u2663\u2666\u2660"   # Not really usable

    attr_reader :rank, :suit

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
      [rank, 10].min   # Return 10 for 10, J, Q, K
    end

    def inspect
      short_name
    end
  end


  class GosuCard < Card

    attr_accessor :x, :y

    RED_COLOUR   = 0xffa00000
    BLACK_COLOUR = 0xff000000

    def self.set_display( front, back, font )
      @@back_image, @@front_image = back, front
      @@font = font
    end

    def draw( orient = :face_up, front = nil, back = nil, font = nil )
      if orient == :face_down
        image = back || @@back_image
        image.draw( @x, @y, 1 )
      else
        image = front || @@front_image
        cfont = font  || @@font
        image.draw( @x, @y, 1 )
        cfont.draw( "#{rank_name.slice(0)}#{suit_char}", x+10, y+10, 1, 1, 1, suit.odd? ? RED_COLOUR : BLACK_COLOUR )
      end
    end
  end


  # Represent a pack of cards as a 1..52 array and deal cards from it.

  class Pack

    def initialize
      @cards = Array.new( 52, 1 )
      @left  = 52		# Cards left
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

    def cut
      deal
    end

  protected

    attr_reader :left

  end

end


if $0 == __FILE__
  pack = Cribbage::Pack.new

  53.times do
    card = pack.deal
    print card ? "#{card.short_name}, " : 'nil'
  end
end
