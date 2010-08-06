require "forwardable"

require 'rubygems'
require "ruby_parser"

module IVDH
  class Template  
    # It is used to grab partials and instance variables from template
    class SexpHandler 
      extend Forwardable

      VALUE_INDEX       = 1
      METHOD_NAME_INDEX = 2

      attr_reader :template, :root_node

      def initialize(template)
        @template = template
        @root_node = RubyParser.new.parse(template.ruby_code)
        @valid = true
      rescue Exception
        @template.logger.warn("Can't parse #{template.path.underline}." +
                              " Probably it is invalid")
        @valid = false
      end

      # Returns all found partial template names as an array of strings
      #
      # === Example
      # There is some ruby code in your template:
      #   render :partial => 'controller/action'
      #   render(:partial => 'some_action'
      # And you use SexpHandler:
      #   handler = SexpHandler.new
      #   handler.grab_partial_templates
      #   # => ["controller/action", "some_action"]
      def grab_partial_template_names
        render_calls = find_render_call_nodes
        arglists = render_calls.map{|c| grab_arglist(c)}
        hashes = arglists.map{|al| grab_hash(al)}
        partials = hashes.map do |h|
          get_partial_name_from_hash_node(h)
        end.compact
        partials.map(&:to_s)
      end

      # Returns all found instance variables as an array of strings
      def grab_ivar_names
        ivar_node_types = [:ivar, :iasgn]
        ivar_node_types.map do |node_type|
          nodes = find_nodes_by_type_recursively(root_node, node_type)    
          nodes.map{|node| node[VALUE_INDEX].to_s}
        end.flatten.uniq
      end

      def valid?
        @valid
      end


      private

      def grab_arglist(source_node)
        source_node.find_nodes(:arglist).first  
      end

      def grab_hash(source_node)
        source_node.find_nodes(:hash).first  
      end

      def find_render_call_nodes
        call_nodes = find_nodes_by_type_recursively(root_node, :call)
        call_nodes.find_all do |node|
          method = node[2]
          method == :render
        end
      end

      def find_nodes_by_type_recursively(source_node, type)
        nodes = []
        if source_node.is_a?(Sexp)
          nodes << source_node if source_node.sexp_type == type
          source_node.each do |node|
           nodes += find_nodes_by_type_recursively(node, type)
          end
        end
        nodes
      end

      def get_partial_name_from_hash_node(hash_node)
        node = get_value_by_key_from_hash(hash_node, :partial)
        node_value = node[VALUE_INDEX]
        if (node.sexp_type != :str  && node.sexp_type != :lit)
          name = grab_var_or_method_name(node)
          @template.logger.warn("#{template.path.underline} defines " + 
            "partial name dynamically. See variable(method) " + 
            "#{name.to_s.underline}")
          return nil
        end
        node_value
      end

      def get_value_by_key_from_hash(hash_node, key)
        hash_node.sexp_body.each_slice(2) do |key_node, value_node|
          return value_node if key_node[VALUE_INDEX] == key
        end
      end

      def grab_var_or_method_name(node)
        case node.sexp_type
        when :ivar, :lvar
          node[VALUE_INDEX]
        when :call
          node[METHOD_NAME_INDEX]
        end
      end
      
    end # SexpHandler
  end # Template
end # IVDH
