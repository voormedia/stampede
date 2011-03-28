module Stampede
  # Represents an anonymous action.
  class Idle < Process
    class_attribute :time

    class << self
      def initialize(time, name = nil)
        super name
        self.time = time
      end
    end

    def start
      @start_time = Time.now
      EM.add_timer(time) { finish }
    end

    after_finish do
      @context.subtract_time Time.now - @start_time
    end
  end
end
