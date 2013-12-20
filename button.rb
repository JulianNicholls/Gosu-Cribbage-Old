# The 1.5 in the height alculation in initialize() and the 2 in the y_margin
# calculation in draw() are pragmatic rather than obvious.

require './region'

require './gosu_enhanced'

class Button

  include Region

  # The button can be made visible/invisible and by inference active/inactive
  # both via visible = true/false or via show() / hide()

  attr_accessor :visible

  def initialize( window, text, font, colour, left, top, width = nil, height = nil, visible = false )
    @window, @text, @font, @colour = window, text, font, colour

    # If the width and/or height is not specified then measure the font and the button text

    width  ||= @font.text_width( text, 1 ) + 2 * @font.text_width( 'X' )
    height ||= @font.height * 1.5

    set_area( left, top, width, height )
    @visible = visible
  end

  def draw
    return if !visible

    # Centre the text on the button

    x_margin = (width  - @font.text_width( @text )) / 2
    y_margin = (height - @font.height) / 2

    #  Colour for the bottom of the button

    lighter = Gosu::Color.new( 0xff, @colour.red * 2, @colour.green * 2, @colour.blue * 2 )
    darker  = Gosu::Color.new( 0xc0, @colour.red, @colour.green, @colour.blue )

    @window.draw_quad( left, top, @colour,
                       left + width, top, @colour,
                       left + width, top + height, lighter,
                       left, top + height, lighter, 1 )

    @window.draw_rectangle( left + width, top + 3, 4, height, 1, darker ) # Right Shadow
    @window.draw_rectangle( left + 3, top + height, width, 4, 1, darker ) # Bottom Shadow

    @font.draw( @text, left + x_margin, top + y_margin, 1 )
  end


  def show; @visible = true;  end
  def hide; @visible = false; end


  def inside?( x, y = nil )
    visible && super( x, y )    # The position can't be inside an invisible button
  end
end
