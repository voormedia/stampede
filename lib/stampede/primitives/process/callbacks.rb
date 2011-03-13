require "active_support/callbacks"

module Stampede
  # Defines before/after callbacks for start and finish.
  module Process::Callbacks
    def self.extended(base)
      base.class_eval do
        include ActiveSupport::Callbacks

        callbacks = [:start, :finish]
        define_callbacks *callbacks

        callbacks.product([:before, :after]).each do |method, callback|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{callback}_#{method}(*args, &block)
              set_callback :#{method}, :#{callback}, *args, &block
            end
          RUBY
        end
      end
    end
  end
end
