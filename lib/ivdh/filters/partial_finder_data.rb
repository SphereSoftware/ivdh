module IVDH
  class Filters
    class PartialFinderData
     
      # === Parameters
      # * partial - partial like it's used in template
      # * parent_tpl - parent template, an instance of Template
      # * paths - array of all template paths
      def initialize(partial, parent_tpl, paths)
        @partial  = partial
        @parent_tpl = parent_tpl
        @paths    = paths
      end

      # Returns partial like it's used in template
      def partial
        @partial
      end

      # Returns path to parent template
      def parent
        @parent_tpl.path
      end

      # Returns array of all template paths
      def paths
        @paths  
      end

      # Returns array of template file extensions
      # === Example
      #   data.tpl_exts # => ['html.erb', 'rhtml', 'rjs']
      def tpl_exts
        Template::TPL_EXTS
      end

      # Returns partial path
      # === Example
      #   data.partial      # => "products/main/item"
      #   data.partial_path # => "products/main"
      def partial_path
        File.dirname(@partial)
      end

      # Returns partial name
      # === Example
      #   data.partial      # => "products/main/item"
      #   data.partial_path # => "item"
      def partial_name
        File.basename(@partial)
      end


    end
  end
end
