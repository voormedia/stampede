module Stampede
  # Represents an anonymous action.
  class Lambda < Action
    class_attribute :lambda

    class << self
      def initialize(lambda, name = nil)
        super name
        self.lambda = lambda
      end
    end

    def start
      instance_eval &lambda
    end
  end
end
