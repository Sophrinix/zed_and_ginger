require_relative "game_object"

# Paces up and down.
class Pacer < GameObject
  MOVE_SPEED = 5
  ANIMATION_DURATION = 0.5

  SPARK_COLOR = Color.new(150, 150, 255)

  def casts_shadow?; true; end
  def to_rect; Rect.new(*(@position - [4, 3]), 8, 6) end

  def initialize(map, tile, position)
    sprite = sprite image_path("pacer.png")
    sprite.sheet_size = [4, 1]
    sprite.origin = [sprite.sprite_width * 0.5, sprite.sprite_height + 1]
    sprite.scale *= 0.75

    super(map.scene, sprite, position)

    @shadow.image = image image_path("glow.png")
    @shadow.color = Color.new(200, 200, 255, 150)
    @shadow.blend_mode = :add

    @base_shadow_scale = @shadow.scale
    @animations << sprite_animation(from: [0, 0], to: [3, 0],
                                    duration: ANIMATION_DURATION).start(@sprite)
    @animations.last.loop!

    @min_y = map.to_rect.y + map.tile_size.width / 2.0 - 1
    @max_y = map.to_rect.y + map.to_rect.height - map.tile_size.height / 2.0

    recalculate_direction
  end

  def recalculate_direction
    if y <= @min_y or not defined? @velocity_y
      @velocity_y = + MOVE_SPEED
      self.y = @min_y + (@min_y - y)
    elsif y >= @max_y
      @velocity_y = - MOVE_SPEED
      self.y = @max_y - (y - @max_y)
    end
  end

  def collide?(other)
    other.z < 6 and super(other)
  end

  def update
    self.y += @velocity_y * frame_time

    recalculate_direction

    @shadow.scale = @base_shadow_scale * (0.75 + rand() * 0.5)

    scene.players.shuffle.each do |player|
      if player.can_be_hurt? and collide? player
        player.electrocute
        scene.remove_object self
        break
      end
    end

    if rand() < 0.15
      scene.create_particle([x, y, z + @sprite.sprite_height / 2.0], velocity: [0, 0, 12], gravity: 0.5,
          random_velocity: [8, 8, 8], glow: true, color: SPARK_COLOR, fade_duration: 1)
    end

    super
  end
end
