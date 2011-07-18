require_relative "game_object"

class DynamicObject < GameObject
  def initialize(scene, sprite, position) 
    @velocity_z = 0
    @animations = []
    
    super(scene, sprite, position)
  end
  
  def update
      if @velocity_z != 0 or z > 0
      @velocity_z -= 0.15
      self.z += @velocity_z
      
      if z <= 0
        self.z = 0
        @velocity_z = 0
      end
    end
    
    @animations.each(&:update)
  end
  
  def animated?
    @animations.any?(&:running?)
  end
end