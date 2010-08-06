require "fileutils"

module IVDH
  class CLI
    # OutputWriter is used to write meta infromation about template into
    # appropriate files.
    # Before use it you should initialize output_dir.
    #
    # === Example
    #   OutputWriter.output_dir = "~/output_info"
    #   OutputWriter.write(template) # write info about template
    class OutputWriter
      class << self

        attr_accessor :output_dir

        # Writes info about template into yaml file
        # === Parameters
        # * template - an instance of Template
        #
        # === Example
        #   template.path           # => 'home/index.html.erb'
        #   OutputWriter.output_dir # => '~/output'
        #   # Write info about template into ~/output/home/index.html.erb.yml
        #   OutputWriter.write(template)
        def write(template)
          file_path = File.join(output_dir, "#{template.path}.yml")
          dir = File.dirname(file_path)
          FileUtils.mkdir_p(dir) unless File.exists?(dir)
          File.open(file_path, "w+") do |file|
            file.puts(template.to_yaml)
          end
        end

      end
    end
  end
end
