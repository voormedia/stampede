module Stampede
  # A scenario is the basic building block of executable processes.
  class Scenario < Group
    autoload :Actions, "stampede/primitives/scenario/actions"

    DEFAULT_EXTENSION = ".stampede"

    include Modules

    class << self
      # Create a new scenario based on the given file.
      def from_file(path)
        create(File.basename(path, DEFAULT_EXTENSION)).tap { |scenario| scenario.load path }
      end

      def initialize(name = nil)
        super
        use Actions
      end

      def load(path)
        class_eval File.read(path), path
      end
    end
  end
end
