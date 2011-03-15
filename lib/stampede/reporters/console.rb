require "pp"

module Stampede
  module Reporters
    class Console
      def initialize(out)
        @out = out
      end

      def report(name, value)
        # @out.log "#{name}"
        @out.log "Report for '#{name}':\n\n" << value.collect { |key, value| "%18s: %s" % [key.to_s, value.inspect] }.join("\n") << "\n"
      end
    end
  end
end
