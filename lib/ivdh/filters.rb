require 'ivdh/filters/partial_finder_data'

module IVDH
  # Filters is used to provide functionallity wich allows adding 
  # some user's filters and algorithms.
  class Filters

    autoload :DefaultFilters, 'ivdh/filters/default_filters'

    class << self
      AVAILABLE_FILTERS = :template_files, :partial_to_path

      @@filters = {}
      
      # Sets a filter with passed name
      def set_filter(name, &block)
        name = name.to_sym
        unless AVAILABLE_FILTERS.include?(name)
          raise "Can't set unavailable filter '#{name}'" 
        end
        raise "Block wasn't given" unless block_given?
        @@filters[name] = block
      end

      # Executes filter specified by name. Raises if filter is not defined.
      def filter(name, *args)
        raise "Undefined filter #{name}" unless has_filter?(name)
        @@filters[name].call(*args)
      end

      # Returns true if filter with passed name exists
      def has_filter?(name)
        !!@@filters[name.to_sym]
      end


      private

      def set_default_filters
        DefaultFilters.filters.each do |name, f|
          set_filter(name, &f)
        end
      end
    end 

    set_default_filters

  end # Filters
end # IVDH
