# Mixin that defines a region of interest which can:
#   Store and return the position and size of a screen item.
#   Return whether a given position is inside it.

module Region
  def set_area( point, size )
    @point, @size = point.dup, size.dup
  end

  def move_to!( new_point )
    @point.move_to!( new_point )
  end

  def move_by!( left_delta, top_delta )
    @point.move_by!( left_delta, top_delta )
  end

  # Return whether a pair of co-ordinates or a point is inside this region.

  def inside?( x, y = nil )
    return false if x.nil?

    if x.is_a? Point
      x.x.between?( left, left + width ) &&
      x.y.between?( top,  top  + height )
    else
      x.between?( left, left + width ) &&
      y.between?( top,  top  + height )
    end
  end

  protected

  def left
    @point.x
  end

  def top
    @point.y
  end

  def width
    @size.width
  end

  def height
    @size.height
  end
end
