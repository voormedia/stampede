require "active_support/concern"

module Stampede
  module Process::Stateful
    extend ActiveSupport::Concern

    included do
      after_start { @state = {} }
    end

    def [](key)
      @state[key]
    end

    def []=(key, value)
      @state[key] = value
    end
  end
end
