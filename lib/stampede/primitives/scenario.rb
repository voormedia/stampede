module Stampede
  class Scenario < Group
    class << self
      def load(path)
        new.tap { |scenario| scenario.instance_eval File.read(path), path }
      end
    end
  end
end
