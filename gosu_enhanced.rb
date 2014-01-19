# Additions to Gosu, to mop up some of the wordier functions

require 'gosu'

# Hold a (x, y) pixel position, and allows for offsetting

class Point < Struct.new( :x, :y )
  def offset( by_x, by_y )
    Point.new( x + by_x, y + by_y )
  end

  def move_by!( by_x, by_y)
    self.x += by_x
    self.y += by_y
  end

  def move_to!( new_x, new_y = nil )
    if new_x.is_a? Point
      self.x, self.y = new_x.x, new_x.y
    else
      self.x, self.y = new_x, new_y
    end
  end
end

# Hold a 2-diemnsional size and allow for inflation / deflation

class Size < Struct.new( :width, :height )
  def inflate( by_width, by_height )
    Size.new( width + by_width, height + by_height )
  end

  def inflate!( by_width, by_height )
    self.width  += by_width
    self.height += by_height
  end
end

# Add a draw_rectangle() to Gosu which simplifies drawing a simple rectangle
# in one colour

class Gosu::Window
  def draw_rectangle( point, size, z_index, colour )
    left, top     = point.x, point.y
    width, height = size.width, size.height

    draw_quad(
      left, top, colour,
      left + width, top, colour,
      left + width, top + height, colour,
      left, top + height, colour,
      z_index
    )
  end
end

# Add a measure to return both width and height for a text

class Gosu::Font
  def measure( text )
    Size.new( text_width( text, 1 ), height )
  end
end
