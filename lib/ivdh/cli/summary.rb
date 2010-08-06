require 'yaml'

module IVDH
  class CLI
    # Summary class is used to collect and contain summary information about templates in collection
    #
    # === Example
    #   summary = Summary.new(collection)
    #   puts summary       # print summary
    #   puts summary.short # print short summary
    class Summary
      
      # Creates a summary
      # === Parameters
      # * collection - an instance of TemplateCollection
      def initialize(collection)
        @sections = {}

        @sections[:not_used_partial_templates] = collection.find_all do |tpl|
          tpl.partial? && tpl.has_no_parent_templates?
        end
        @sections[:partials_with_instance_variables] = collection.find_all do |tpl|
          tpl.partial? && tpl.has_ivars?
        end
        @sections[:invalid_templates] = collection.find_all{|tpl| !tpl.valid?}
        @sections[:all_processed_templates] = collection.templates
      end

      # Returns short summary as a string
      def short
        title = "SHORT SUMMARY".underline
        body = @sections.map do |name, tpls|
          name.to_s.humanize + ': ' + tpls.size.to_s
        end.join("\n")
        "#{title}\n#{body}"
      end

      def to_s
        title = "SUMMARY".underline
        "#{title}\n#{to_yaml}"
      end

      def to_yaml
        hash = @sections.map do |name, tpls|
          {"#{name.to_s.titlize}(#{tpls.size})" => tpls.map(&:path)}
        end.inject{|a,b| a.merge(b)}
        YAML.dump(hash)
      end

    end # Summary
  end # CLI
end # IVDH
