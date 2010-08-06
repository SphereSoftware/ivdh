require "yaml"
require "forwardable"

require 'ivdh/template/sexp_handler'

module IVDH
  # An instance of template represents a template file.
  class Template

    extend Forwardable

    TPL_EXTS = ["html.erb", "rhtml", "rjs"]

    class << self
      # Defines has_* and has_no_* methods.
      # === Example
      # Assume you have instance methods _ivars_ wich returns an array
      # of instance vars.
      #   has_methods :ivars # creates has_ivars? and has_no_ivars?
      def has_methods(*methods)
        methods.each do |method|
          define_method("has_#{method}?"){ !send(method).empty?}
          define_method("has_no_#{method}?"){ send(method).empty?}
        end
      end
    end

    attr_reader :collection, :own_ivars, :partials,
                :full_path, :path, :ruby_code, :subtemplates
    def_delegators :@collection, :logger, :write_log?
    has_methods :ivars, :subtemplates, :parent_templates

    # == Paramteres
    # * full_path - path of template file
    # * collection - instance of TemplateCollection
    def initialize(full_path, collection)
      validate(full_path)

      @collection = collection
      @full_path  = File.expand_path(full_path)
      @path       = @full_path.sub("#{collection.views_dir}/", '')
      @ruby_code  = grab_ruby_code

      sexp_handler = SexpHandler.new(self)
      @own_ivars   = sexp_handler.grab_ivar_names
      @partials    = sexp_handler.grab_partial_template_names
      @valid       = sexp_handler.valid?
    end

    # Returns true if template is partial
    def partial?
      !!(File.basename(@full_path) =~ /^_/)
    end

    # Returns true if template does not have ruby syntax errors
    def valid?
      @valid
    end

    # Returns array of ivars including
    # ivars in subtemplates
    def ivars
      (own_ivars + subtemplate_ivars).uniq
    end

    # Returns ivars of subtemplates
    def subtemplate_ivars
      subtemplates.map{|tpl| tpl.ivars}.flatten
    end

    # Initializes subtemplates for current template
    def define_subtemplates
      @subtemplates = @partials.map do |partial|
        @collection.get_subtemplate(self, partial)
      end.compact
    end

    # Returns all template where current template is used as a partial
    def parent_templates
      @collection.find_parents_for(self)
    end
    
    # Returns tree as a hash where key is template path
    # and value is a similar hash with subtemplates.
    # If template does not have subtmeplates value is nil
    # === Paramters
    # * show_ivars - if true own_ivars will be displayed with template path
    def subtemplates_tree(show_ivars = true)
      value = @subtemplates.map{|tpl| tpl.subtemplates_tree(show_ivars)}
      value = nil if value.empty?
      key = show_ivars ? @path + "(#{@own_ivars.join(', ')})" : @path
      return ({key => value})
    end

    def to_yaml
      hash = {}
      hash[:path]               = @path
      hash[:subtemplates_tree]  = subtemplates_tree
      hash[:parent_templates]   = parent_templates.map{|tpl| tpl.path}
      hash[:instance_variables] = ivars
      YAML.dump(hash)
    end


    private 
    
    # Grabs ruby code from template
    def grab_ruby_code
      tpl_content = File.read(@full_path)
      regexp = %r{<%=?(.*?)-?%>}m
      tpl_content.scan(regexp).flatten.join("\n")
    end

    def validate(full_path)
      raise "#{full_path} is not a file" unless File.file?(full_path)
    end

  end # Template
end # IVDH
