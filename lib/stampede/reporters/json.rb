require "json"
require "time"

class Time
  def to_json(*args) #:nodoc:
    iso8601(3).to_json(*args)
  end
end

module Stampede
  module Reporters
    class JSON
      def initialize(out)
        @out = out
      end

      def record(value)
        @out.log "[" << ::JSON.generate(value) << "]"
      end
    end
  end
end
