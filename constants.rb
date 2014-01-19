require 'gosu'

module CribbageGame
  # Constants for the Cribbage Game

  module Constants
    # Phases

    INITIAL_CUT       = 0
    INITIAL_RECUT     = 2
    CPU_CUT           = 4
    CUTS_MADE         = 6
    DEAL              = 8
    DISCARDING        = 10
    TURN_CARD         = 20
    PLAY_31           = 30
    PLAY_31_DONE      = 35
    THE_SHOW          = 40
    CRIB_SHOW         = 50

    # Window Sizes

    WIDTH             = 800
    HEIGHT            = 600

    MID_X             = WIDTH / 2
    MID_Y             = HEIGHT / 2

    MARGIN            = 12

    # Card Sizes

    CARD_SIZE         = Size.new( 100, 150 )

    CARD_GAP          = 12
    FANNED_GAP        = 25

    # Positions

    WATERMARK         = Point.new( WIDTH / 12, MID_Y - HEIGHT / 6 )

    INSTRUCTION_TOP   = MID_Y + HEIGHT / 12

    # Hand positions

    COMPUTER_HAND     = Point.new( MARGIN, MARGIN )
    PLAYER_HAND       = Point.new( MARGIN, HEIGHT - (CARD_SIZE.height + MARGIN) )

    PACK_POS          = Point.new(    # Spare Pack
                          WIDTH - (CARD_SIZE.width + MARGIN),
                          MID_Y - (CARD_SIZE.height / 2) )

    FAN_POS           = Point.new( 50, PACK_POS.y )

    CRIB_POS          = PACK_POS.offset( -(CARD_SIZE.width + MARGIN), 0 )   # Crib

    PLAY31_POS        = COMPUTER_HAND.offset( 0, CARD_SIZE.height + CARD_GAP * 2 )

    BUTTON_HEIGHT     = 40
    DISCARD_BUTTON    = Point.new(    # Discard Button
                          MARGIN * 3,
                          PLAYER_HAND.y - BUTTON_HEIGHT * 2 )

    SCORE             = Point.new( WIDTH - CARD_SIZE.width, MARGIN )
    SCORE_BOX_HEIGHT  = 64
  end
end
