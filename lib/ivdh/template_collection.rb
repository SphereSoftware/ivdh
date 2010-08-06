require 'logger'
require 'forwardable'

module IVDH
  class TemplateCollection
   
    include Enumerable
    extend Forwardable

    attr_reader :views_dir, :logger, :templates
    def_delegators :@templates, :each, :size

    # === Paramteres
    # * dir - Directory where templates are located
    # * opts - hash, available keys are:
    #   * :logger - instance of Logger. 
    #   * :write_log - true/false
    def initialize(dir, opts = {})
      opts[:logger] ||= ::Logger.new(STDOUT)
      @logger = LoggerWrapper.new(opts[:logger], opts[:write_log])

      @views_dir = File.expand_path(dir)

      pattern = "#{@views_dir}/**/*.{#{Template::TPL_EXTS.join(',')}}"
      @tpl_paths = Filters.filter(:template_files, Dir.glob(pattern))
      @templates = @tpl_paths.map do |path| 
        @logger.info("Initializing #{path}")
        Template.new(path, self)
      end

      @templates.each(&:define_subtemplates)
    end

    # Returns instance of Template or nil if subtemplate was not found
    # === Paramteres
    # * base_tpl - instance of Template, which uses partial template
    # * partial_name - string, partial name like it is used in template
    def get_subtemplate(base_tpl, partial_name)
      paths = @tpl_paths.map{|p| p.sub("#{@views_dir}/", '')}
      finder_data = Filters::PartialFinderData.new(partial_name, base_tpl, paths)
      partial_path = Filters.filter(:partial_to_path, finder_data)

      unless partial_path.nil?
        find_by_path(partial_path)
      else
        @logger.warn("Can't find partial '#{partial_name.underline}' " + 
                     "for '#{base_tpl.path.underline}'")
        nil
      end
    end

    # Finds template by path. Returns nil if was not found
    def find_by_path(path)
      @templates.find{|tpl| tpl.path == path}
    end

    # Finds parent template for passed template
    # === Parameters
    # * subtemplate - instance of Template
    def find_parents_for(subtemplate)
      @templates.find_all do |tpl|
        tpl.subtemplates.include?(subtemplate)
      end
    end


    # LoggerWrapper wraps the logger and writes to log only if write_log is true
    class LoggerWrapper < BlankSlate
      attr_accessor :write_log

      def initialize(logger, write_log)
        @logger, @write_log = logger, write_log
      end

      def method_missing(meth, *args)
        write_methods = [:fatal,  :error, :info, :warn, :debug, :add]
        if write_methods.include?(meth.to_sym) && !@write_log
          # do nothing
        else
          @logger.send(meth, *args)
        end
      end
    end # LoggerWrapper

  end
end
