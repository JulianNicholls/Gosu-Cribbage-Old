# The 1.5 in the height alculation in initialize() and the 2 in the y_margin
# calculation in draw() are pragmatic rather than obviously correct.

require './region'

require './gosu_enhanced'

# A Gosu Button

class Button
  include Region

  # The button can be made visible/invisible and by inference active/inactive
  # both via visible = true/false or via show() / hide()

  attr_accessor :visible

  def initialize( window, text, options )
    @window, @text  = window, text
    @font           = options[:font]
    @visible        = options[:visible] || false
    @colour         = options[:colour]

    # If the width and/or height is not specified then measure the font and
    # the button text

    options[:width]  ||= @font.text_width( text + 'xx', 1 )
    options[:height] ||= @font.height * 1.5

    set_area( options[:left], options[:top], options[:width], options[:height] )
    @visible = visible
  end

  def draw
    return unless visible

    draw_outline

    # Centre the text on the button

    f_width, f_height = @font.measure( @text )
    x_margin = (width  - f_width) / 2
    y_margin = (height - f_height) / 2

    @font.draw( @text, left + x_margin, top + y_margin, 1 )
  end

  def draw_outline
    #  Colours for the bottom of the button and the shadow

    r, g, b = @colour.red, @colour.green, @colour.blue
    lighter = Gosu::Color.new( 0xff, r * 2, g * 2, b * 2 )
    darker  = Gosu::Color.new( 0xc0, r, g, b )

    @window.draw_quad( left, top, @colour,
                       left + width, top, @colour,
                       left + width, top + height, lighter,
                       left, top + height, lighter, 1 )

    # Right and Bottom Shadow

    @window.draw_rectangle( left + width, top + 3, 4, height, 1, darker )
    @window.draw_rectangle( left + 3, top + height, width, 4, 1, darker )
  end

  def show
    @visible = true
  end

  def hide
    @visible = false
  end

  def inside?( x, y = nil )
    visible && super( x, y )    # The position can't be inside an invisible button
  end
end
