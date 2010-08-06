class String

  class << self
    # Defines color methods
    #
    # === Parameters
    # * colors - hash where key is color and value is ANSI color code
    #
    # === Example
    #   # define blue and red methods
    #   color_methods :red => 31, :blue => 34
    def color_methods(colors)
      colors.each do |color, code|
        define_method(color) do
          "\e[#{code}m#{self}\e[0m"
        end
      end
    end
  end

  color_methods :red => 31, 
                :blue => 34,
                :green => 32,
                :yellow => 33,
                :white => 37,
                :bold => 1,
                :underline => 4
  
  # Titlizes a string
  #
  # === Example
  # 'some_string'.titlize   # => "SOME STRING"
  def titlize
    gsub('_', ' ').upcase
  end

  # Humanizes a string
  #
  # === Example
  # 'some_string'.humanize   # => "Some string"
  def humanize
    gsub('_', ' ').capitalize
  end

end
