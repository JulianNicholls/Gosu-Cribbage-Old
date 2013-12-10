require './region'

class Button

  include Region

  def initialize( window, text, font, colour, left, top, width = nil, height = nil )
    @window, @text, @font, @colour = window, text, font, colour

    width  ||= @font.text_width( text, 1 ) + 2 * @font.text_width( 'xx', 1 )
    height ||= @font.height * 2

    set_area( left, top, width, height )
  end

  def draw
    x_margin = (width - @font.text_width( @text, 1 )) / 2
    y_margin = (height - @font.height) / 2

    lighter = Gosu::Color.new( 0xff, @colour.red * 2, @colour.green * 2, @colour.blue )

    @window.draw_quad( left, top, @colour,
                       left + width, top, @colour,
                       left + width, top + height, lighter,
                       left, top + height, lighter, 1 )

    @font.draw( @text, left + x_margin, top + y_margin, 1 )
  end

end
