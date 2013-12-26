# Additions to Gosu, to mop up some of the wordier functions

require 'gosu'

# Add a draw_rectangle() to Gosu which simplifies drawing a simple rectangle
# in one colour

class Gosu::Window
  def draw_rectangle( left, top, width, height, z_index, colour )
    draw_quad(
      left, top, colour,
      left + width - 1, top, colour,
      left + width - 1, top + height - 1, colour,
      left, top + height - 1, colour,
      z_index
    )
  end
end

# Add a measure to return both width and height for a text

class Gosu::Font
  def measure( text )
    [text_width( text, 1 ), height]
  end
end
