module Stampede
  # Represents an anonymous action.
  class Lambda < Action
    def initialize(name = nil, &lambda)
      @lambda = lambda
      super name
    end

    def start
      instance_eval &@lambda
    end
  end
end
