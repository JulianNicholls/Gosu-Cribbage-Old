# Additions to Gosu, to mop up some of the wordier functions

require 'gosu'

class Gosu::Window

  # Draw a simple rectangle in one colour.

  def draw_rectangle( left, top, width, height, z_index, colour )
    draw_quad(                 # Baize
      left, top, colour,
      left + width - 1, top, colour,
      left + width - 1, top + height - 1, colour,
      left, top + height - 1, colour,
      z_index
    )
  end
end
