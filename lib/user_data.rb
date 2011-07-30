class BaseUserData
  include Log

  HEADER = <<END
# =======================================================================
# ------------------------- User settings file --------------------------
#
# WARNING: Editing this file manually may stop the game from starting up,
#          but, if deleted, the game will create a new data file.
# =======================================================================

END

  def initialize(user_file, default_file)
    @user_file = user_file
    @data = File.exists?(@user_file) ? YAML::load_file(@user_file) : {}
    @data = YAML::load_file(default_file).deep_merge @data

    log.info { "Read and merged user data:\n#{@data}" }

    save
  end

  def save
    File.open(@user_file, "w") do |f|
      f.puts HEADER
      f.puts @data.to_yaml
    end
  end
end

class UserData < BaseUserData
  DEFAULT_DATA_FILE = File.join(EXTRACT_PATH, 'config/default_user_settings.yml')
  DATA_FILE = File.join(ROOT_PATH, 'zed_and_ginger.dat')

  # High scores, high scorers and level unlocking.
  GROUP_LEVELS = 'levels'
  HIGH_SCORER = 'high-scorer'
  HIGH_SCORE = 'high-score'
  FINISHED = 'finished'

  DEV_LEVEL = 0 # Level just used for development.
  INITIAL_LEVEL = 1 # Tutorial level (always unlocked).

  # Graphics options.
  GROUP_GRAPHICS = 'graphics'
  SCALING = 'scaling'
  FULLSCREEN = 'fullscreen'

  MIN_SCALING = 2

  # Sound options.
  GROUP_SOUND = 'sound'
  # TODO: sound options.

  # Controls.
  GROUP_CONTROLS = 'key_controls'
  GROUP_CONTROLS_GENERAL = 'general'
  GROUP_CONTROLS_PLAYERS = 'players'

  VALID_PLAYER_CONTROLS = [:left, :right, :up, :down, :jump]
  VALID_CONTROLS = [:pause, :screenshot]

  GROUP_GAMEPLAY = 'gameplay'
  SELECTED_CAT = 'selected_cat'
  HARDCORE = 'hardcore'
  INVERSION = 'inversion'

  def initialize
    super DATA_FILE, DEFAULT_DATA_FILE

    @scaling = if fullscreen?
      [Ray.screen_size.width / GAME_RESOLUTION.width, Ray.screen_size.height / GAME_RESOLUTION.height].min
    else
      [@data[GROUP_GRAPHICS][SCALING].round, MIN_SCALING].max
    end
  end

  # High scores, high scorers and level unlocking.

  def high_scorer(level)
    @data[GROUP_LEVELS][level][mode.to_s][HIGH_SCORER]
  end

  def high_score(level)
    @data[GROUP_LEVELS][level][mode.to_s][HIGH_SCORE]
  end

  def set_high_score(level, player, score)
    @data[GROUP_LEVELS][level][mode.to_s][HIGH_SCORER] = player
    @data[GROUP_LEVELS][level][mode.to_s][HIGH_SCORE] = score
    save
  end

  def level_unlocked?(level, options = {})
    options = {
        mode: mode,
    }.merge! options

    case level
      when DEV_LEVEL     then DEVELOPMENT_MODE
      when INITIAL_LEVEL then true # First (tutorial) level is always unlocked.
      else
        # If the level we are asking for exists and we've completed the previous one.
        @data[GROUP_LEVELS].has_key?(level) and
            ((@data[GROUP_LEVELS].has_key?(level - 1) and
              @data[GROUP_LEVELS][level - 1][options[:mode].to_s][FINISHED]) or
                DEVELOPMENT_MODE)
    end
  end

  def finished_level?(level)
    @data[GROUP_LEVELS][level][mode.to_s][FINISHED]
  end

  # Possible to finish a level without having made a high score.
  def finish_level(level)
    @data[GROUP_LEVELS][level][mode.to_s][FINISHED] = true
    save
  end

  # Graphics options.

  def scaling
    @scaling
  end

  def scaling=(scaling)
    @scaling = scaling

    unless fullscreen?
      @data[GROUP_GRAPHICS][SCALING] = scaling
      save
    end
  end

  def fullscreen=(fullscreen)
    @data[GROUP_GRAPHICS][FULLSCREEN] = fullscreen
    save
  end

  def fullscreen?
    @data[GROUP_GRAPHICS][FULLSCREEN]
  end

  # Controls

  def player_control(player, action)
    raise "Bad player #{player.inspect}" unless Player::NAMES.include? player
    raise "Bad action #{action.inspect}" unless VALID_PLAYER_CONTROLS.include? action
    @data[GROUP_CONTROLS][GROUP_CONTROLS_PLAYERS][player.to_s][action.to_s]
  end

  def set_player_control(player, action, key)
    raise "Bad player #{player.inspect}" unless Player::NAMES.include? player or name == :both
    raise "Bad action #{action.inspect}" unless VALID_PLAYER_CONTROLS.include? action

    @data[GROUP_CONTROLS][GROUP_CONTROLS_PLAYERS][player.to_s][action.to_s] = key
    save
  end

  def control(action)
    raise "Bad action #{action.inspect}" unless VALID_CONTROLS.include? action
    @data[GROUP_CONTROLS][GROUP_CONTROLS_GENERAL][action.to_s]
  end

  def set_control(action, key)
    raise "Bad action #{action.inspect}" unless VALID_CONTROLS.include? action
    @data[GROUP_CONTROLS][GROUP_CONTROLS_GENERAL][action.to_s] = key
    save
  end

  # General gameplay
  def selected_cat
    @data[GROUP_GAMEPLAY][SELECTED_CAT]
  end

  def selected_cat=(name)
    raise "Bad cat name #{number.inspect}" unless Player::NAMES.include? name or name == :both
    @data[GROUP_GAMEPLAY][SELECTED_CAT] = name
    save
  end

  def hardcore=(fullscreen)
    @data[GROUP_GAMEPLAY][HARDCORE] = fullscreen
    save
  end

  def hardcore?
    @data[GROUP_GAMEPLAY][HARDCORE]
  end

  def inversion=(inversion)
    @data[GROUP_GAMEPLAY][INVERSION] = inversion
    save
  end

  def inversion?
    @data[GROUP_GAMEPLAY][INVERSION]
  end

  def mode
    if hardcore?
      if inversion?
        :hardcore_inversion
      else
        :hardcore
      end
    elsif inversion?
      :inversion
    else
      :normal
    end
  end
end
