class Map
  include Helper
  
  attr_reader :grid_width, :grid_height, :tile_size, :scene, :position, :default_tile
  
  def to_rect; Rect.new(*@position, @grid_width * @tile_size.x, @grid_height * @tile_size.y); end

  def initialize(tile_size, scene, tile_data, default_tile)
    @tile_size = tile_size.to_vector2
    @scene, @default_tile = scene, default_tile
    @position = Vector2[0,0]
    @grid_width, @grid_height = tile_data.first.length, tile_data.size

    @tiles = Array.new(@grid_height) { Array.new(@grid_width) }
    tile_data.each_with_index do |row, y|
      row.each_char.with_index do |char, x|
        @tiles[y][x] = create_tile(char, Vector2[x, y])
      end
    end
  end
  
  def tile_at_coordinate(coordinate)
    coordinate = coordinate.to_vector2.dup
    coordinate -= @position
    tile_at_grid(Vector2[(coordinate.x / tile_size.width).to_i, (coordinate.y / tile_size.height).to_i])
  end
  
  def tile_at_grid(grid_position)
    grid_position = grid_position.to_vector2
    if grid_position.x.between?(0, @grid_width - 1) and grid_position.y.between?(0, @grid_height - 1)
      @tiles[grid_position.y][grid_position.x]
    else
      nil
    end
  end
  
  # Yields every tile visible to the view (also more to the left edge, to allow for skewing).
  def each_visible(view, &block)
    rect = view.rect
    if rect.height < 0
      rect.height *= -1
      rect.y -= rect.height
    end

    top_left = rect.center - rect.size / 2
    y_range = ((top_left.y - tile_size.height) / tile_size.height).floor..((top_left.y + rect.size.height) / tile_size.height).ceil
    x_range = ((top_left.x - tile_size.width * 2) / tile_size.width).floor..((top_left.x + rect.size.width) / tile_size.width).ceil
    y_range.each do |y|
      x_range.each do |x|       
        tile = tile_at_grid([x, y])
        yield tile if tile
      end
    end
  end
  
  # Draws all tiles (only) visible in the window.
  def draw_on(window)
    each_visible(window.view) {|tile| tile.draw_on window }
  end
end