module CleanPuts
  class CleanPuts

    attr_accessor :files_to_clean
    attr_accessor :diff_command

    def initialize
      @diff_command = "git diff --unified=0 -G'puts'"
      @files_to_clean = {}
    end

    def perform
      diff = execute_diff
      get_files_to_clean(diff)
      cleanup
    end

    def execute_diff
      `#{diff_command}`
    end

    def get_files_to_clean(diff)
      filename = nil

      diff.each_line do |d|
        if d.include? "diff --git"
          filename_line = d
          filename = get_filename(filename_line)
          @files_to_clean[filename] = []
        end
        if d.match(/^@@.*@@.*$/)
          linenumber_line = d
          if @files_to_clean.has_key? filename
            @files_to_clean[filename] << get_linenumber(linenumber_line)
          end
        end
      end
    end

    def cleanup
      @files_to_clean.each do |f, v|
        v.each_with_index do |n, i|
          `sed -i '#{n-i}d' #{f}`
        end
      end
    end

    ## Example:
    # diff --git a/file.rb b/file.rb
    def get_filename(line)
      parts = line.split(" ")
      filename_b = parts[3]
      filename_b[2..-1]
    end

    ## Example
    # @@ -12,0 +13 @@
    #TODO: Handle when puts was added to existing blank line
    def get_linenumber(line)
      parts = line.split(' ')
      parts[2].to_i
    end

  end
end
