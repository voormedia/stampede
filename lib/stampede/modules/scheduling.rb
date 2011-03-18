require "active_support/core_ext/numeric/time"

class Numeric
  def ms
    (self.to_f / 1000).seconds
  end
end

module Stampede
  module Modules::Scheduling
    def every(interval)
      create Interval, interval, &Proc.new
    end

    class Interval < Group
      class_attribute :interval

      class << self
        def initialize(interval, options = {})
          super "every #{interval.inspect}"
          self.interval = interval.to_f
        end
      end

      def start
        EM.next_tick do
          EM.add_periodic_timer(interval) { start_children }
          start_children
        end
      end

      def finish
      end
    end
  end
end
