require 'gosu'

module CribbageGame
  module Constants

    # Phases

    INITIAL_CUT       = 0
    CPU_CUT           = 2
    CUTS_MADE         = 4
    DEAL              = 8
    DISCARDING        = 10
    CUT_CARD          = 20
    PLAY_31           = 30
    PLAY_31_DONE      = 35
    THE_SHOW          = 40
    CRIB_SHOW         = 50

    # Window Sizes

    WIDTH             = 800
    HEIGHT            = 600

    MID_X             = WIDTH / 2
    MID_Y             = HEIGHT / 2

    MARGIN            = 12        # This replaces misuses of CARD_GAP


    # Colours

    BAIZE_COLOUR      = Gosu::Color.new( 0xff007000 )
    WATERMARK_COLOUR  = Gosu::Color.new( 0x20000000 )

    SCORE_BKGR_COLOUR = Gosu::Color.new( 0xff005000 )
    SCORE_TEXT_COLOUR = Gosu::Color.new( 0xffffcc00 )
    SCORE_NUM_COLOUR  = Gosu::Color.new( 0xffffff00 )

    ARROW_COLOUR      = Gosu::Color.new( 0xf0ffcc00 )
    DISCARD_COLOUR    = Gosu::Color.new( 0xff104ec2 )


    # Card Sizes

    CARD_HEIGHT       = 150
    CARD_WIDTH        = 100

    CARD_GAP          = 12
    FANNED_GAP        = 25


    # Positions

    WATERMARK_LEFT    = WIDTH / 12
    WATERMARK_TOP     = MID_Y - HEIGHT / 6

    INSTRUCTION_TOP   = MID_Y + HEIGHT / 12

    FAN_LEFT          = 50

    COMPUTER_TOP      = MARGIN    # Computer Hand
    COMPUTER_LEFT     = MARGIN

    PLAYER_TOP        = HEIGHT - (CARD_HEIGHT + MARGIN)     # Player Hand
    PLAYER_LEFT       = MARGIN

    PACK_TOP          = MID_Y - (CARD_HEIGHT / 2)           # Spare Pack
    PACK_LEFT         = WIDTH - (CARD_WIDTH + MARGIN)

    CRIB_TOP          = PACK_TOP                            # Crib
    CRIB_LEFT         = PACK_LEFT - (CARD_WIDTH + MARGIN)

    BUTTON_HEIGHT     = 40
    DISCARD_TOP       = PLAYER_TOP - BUTTON_HEIGHT*2        # Discard Button
    DISCARD_LEFT      = MARGIN * 3

    SCORE_TOP         = MARGIN                              # Score Position
    SCORE_LEFT        = WIDTH - CARD_WIDTH
    SCORE_BOX_HEIGHT  = 64
  end
end
