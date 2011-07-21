# encoding: UTF-8

class EnterName < Scene
  BLANK_CHAR = '_'
  MAX_CHARS = 3

  def setup(previous_scene, set_name_proc)
    @previous_scene, @set_name_proc = previous_scene, set_name_proc
    @heading = ShadowText.new("Enter Name", at: [150, 10], font: FONT_NAME, size: 64, shadow_offset: [4, 4])

    @entry = text BLANK_CHAR * MAX_CHARS, at: [250, 60], font: FONT_NAME, size: 90
    @entry_background = Polygon.rectangle([215, 100, 275, 75], Color.new(0, 0, 0, 200))
  end

  def register
    # Enter the name.
    on :text_entered do |char|
      char = Ray::TextHelper.convert(char).upcase

      case char
        when 'A'..'Z', '0'..'9'
          first_blank_index = @entry.string.index(BLANK_CHAR)
          if first_blank_index
            name = @entry.string
            name[first_blank_index] = char
            @entry.string = name
          end
      end
    end

    # Accept the name.
    [:return].each do |key_code|
      on(:key_press, key(key_code)) { accept_name }
    end

    # Delete last character.
    [:delete, :backspace].each do |key_code|
      on(:key_press, key(key_code)) { delete_last_char }
    end

    render do |win|
      @previous_scene.render(win)

      @heading.draw_on win

      win.draw @entry_background
      win.draw @entry
    end
  end

  def accept_name
    unless @entry.string.include? BLANK_CHAR
      @set_name_proc.call @entry.string
      pop_scene
    end
  end

  def delete_last_char
    @entry.string.chars.reverse_each.with_index do |char, i|
      if char !=  BLANK_CHAR
        name = @entry.string
        name[MAX_CHARS - 1 - i] = BLANK_CHAR
        @entry.string = name

        break
      end
    end
  end
end