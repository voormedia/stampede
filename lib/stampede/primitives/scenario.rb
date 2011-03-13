module Stampede
  # A scenario is the basic building block of executable processes.
  class Scenario < Group
    autoload :Actions, "stampede/primitives/scenario/actions"

    DEFAULT_EXTENSION = ".stampede"

    include Modules

    class << self
      # Create a new scenario based on the given file.
      def load(path)
        name = File.basename(path, DEFAULT_EXTENSION)
        create(name).tap { |scenario| scenario.class_eval File.read(path), path }
      end
      
      def initialize(name = nil)
        super
        use Actions
      end
    end
  end
end
