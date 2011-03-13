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
        new(name).tap { |scenario| scenario.instance_eval File.read(path), path }
      end
    end

    def initialize(name = nil)
      use Actions
      super
    end
  end
end
