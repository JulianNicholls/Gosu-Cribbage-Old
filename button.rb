require './region'

# The button can be made visible/invisible and by inference active/inactive both
# via visible = true/false or via show() / hide()

class Button

  include Region

  attr_accessor :visible

  def initialize( window, text, font, colour, left, top, width = nil, height = nil, visible = false )
    @window, @text, @font, @colour = window, text, font, colour

    # If the width and/or height is not specified then measure the font and the button text

    width  ||= @font.text_width( text, 1 ) + 2 * @font.text_width( 'xx', 1 )
    height ||= @font.height * 2

    set_area( left, top, width, height )
    @visible = visible
  end

  def draw
    return if !visible

    # Centre the text on the button

    x_margin = (width - @font.text_width( @text, 1 )) / 2
    y_margin = (height - @font.height) / 2

    #  Colour for the bottom of the button

    lighter = Gosu::Color.new( 0xff, @colour.red * 2, @colour.green * 2, @colour.blue * 2 )

    @window.draw_quad( left, top, @colour,
                       left + width, top, @colour,
                       left + width, top + height, lighter,
                       left, top + height, lighter, 1 )

    @font.draw( @text, left + x_margin, top + y_margin, 1 )
  end

  def show
    @visible = true
  end

  def hide
    @visible = false
  end

  def inside?( x, y = nil )       # The position can't be inside an invisible button
    visible && super( x, y )
  end
end
