require 'logger'

module IVDH
  class CLI
    # DoubleLogger is a proxy logger.
    # It delegates all calls to STDOUT logger and file logger,
    # so you can used it as a usual instance of Logger
    class DoubleLogger < BlankSlate

      attr_accessor :stdout_logger, :file_logger
     
      # Creates an instance
      # === Parameters 
      # * log_file - path of log file
      # * mode - :quiet, :verbose
      def initialize(log_file, mode=nil)
        @stdout_logger = ::Logger.new(STDOUT)
        @stdout_logger.formatter = StdoutLoggerFormatter.new
        @stdout_logger.level = define_stdout_logger_level(mode)

        @file_logger = ::Logger.new(log_file)
        @file_logger.level  = ::Logger::WARN
      end

      def method_missing(meth, *args)
        @stdout_logger.send(meth, *args)
        @file_logger.send(meth, *args)
      end

      def define_stdout_logger_level(mode)
        case mode
        when :quiet
          ::Logger::FATAL
        when :verbose
          ::Logger::INFO
        else
          ::Logger::WARN
        end
      end


      class StdoutLoggerFormatter < ::Logger::Formatter
        def call(severity, time, program_name, message)
          "#{message}\n"
        end
      end 

    end  # DoubleLogger
  end  # CLI
end  # IVDH
