module IVDH
  class Filters
    class DefaultFilters
    
      # Converts instance methods to procs
      def self.filters
        @@instance ||= self.new
        self.instance_methods(false).inject({}) do |hash, meth_name|
          hash[meth_name] = @@instance.method(meth_name).to_proc
          hash
        end
      end


      def template_files(*files)
        files.flatten
      end

      # Return full path of partial
      # === Paramteres
      # * data - an instance of PartialFinderData
      def partial_to_path(data)
        result = nil

        extra_path = data.parent
        until extra_path == '.'
          extra_path= File.dirname(extra_path) 
          data.tpl_exts.each do |ext|
            path = File.join(extra_path, data.partial_path, "_#{data.partial_name}.#{ext}")

            # normalize path
            path = File.expand_path('/' + path)[1..-1]

            result = path if data.paths.include?(path)
          end
        end
        result
      end

    end
  end
end #IVDH
