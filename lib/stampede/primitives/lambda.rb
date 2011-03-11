module Stampede
  class Lambda < Action
    def initialize(&lambda)
      @lambda = lambda
      super()
    end

    def start
      instance_eval &@lambda
    end
  end
end
