module Stampede
  module Reporters
    class Console
      def initialize
        @out = $stdout
      end
      
      def report(name, value)
        @out.puts "#{name}: #{value}"
      end
    end
  end
end
