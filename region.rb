module Region

  def set_area( left, top, width, height )
    @left, @top     = left, top
    @width, @height = width, height
  end

  def move_to( new_left, new_top )
    @left, @top = new_left, new_top
  end

  def move_by( left_delta, top_delta )
    @left += left_delta
    @top  += top_delta
  end

  def inside?( x, y )
    x.between?( @left, @left + @width ) &&
    y.between?( @top, @top + @height )
  end

protected

  attr_reader :left, :top, :width, :height

end
