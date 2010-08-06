require 'optparse'

require "ivdh/cli/summary"
require "ivdh/cli/output_writer"
require "ivdh/cli/double_logger"


module IVDH
  class CLI
    class << self
      
      # Runs the application
      def run
        begin
          opts = process_opts 
          raise unless opts[:target_dir]
        rescue 
          puts "Run with --help to see help."
          exit
        end
        
        OutputWriter.output_dir = opts[:output_dir]

        logger = DoubleLogger.new(opts[:log_file], opts[:mode])

        collection = TemplateCollection.new(opts[:target_dir],
                                            :write_log => true,
                                            :logger => logger)

        collection.each do |tpl|
          OutputWriter.write(tpl)
        end

        summary = Summary.new(collection)
        logger.file_logger   << "\n#{summary.to_s}\n"
        logger.stdout_logger << "\n#{summary.short.to_s}\n" unless opts[:quiet]
      end

      def process_opts
        # default options
        options = {
          :output_dir => Dir.pwd + '/ivdh_output',
          :log_file   => Dir.pwd + '/ivdh.log'
        }

        OptionParser.new do |opts|

          opts.on('-t DIRECTORY', '--target-dir DIRECTORY', 'Directory where views files are located(required)') do |target|
            options[:target_dir] = target
          end

          opts.on('-o', '--output-dir DIRECTORY', 'Path to dir where you want to save output metafiles. Default: ./ivdh_output') do |output|
            options[:output_dir] = output
          end

          opts.on('-l', '--log-file', 'Log file where all errors message will be logged. Default: ./ivdh.log') do |log|
            options[:log_file] = log
          end

          opts.on('-q', '--quiet', 'Quiet mode. Do not print any console output') do
            options[:mode] = :quiet
          end

          opts.on('-v', '--verbose', 'Verbose mode') do
            options[:mode] = :verbose
          end

          opts.on('-f', '--filters FILE', 'Specify file with user filters') do |file_path|
            load file_path
          end

          opts.on('-h', '--help', 'Show help') do
            puts opts
            exit
          end
        end.parse!
        options
      end

    end # CLI self
  end # CLI
end # IVDH
