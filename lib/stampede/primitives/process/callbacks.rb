require "active_support/core_ext/array/extract_options"
require "active_support/concern"
require "active_support/callbacks"

module Stampede
  # Defines before/after callbacks for start and finish.
  module Process::Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    included do
      define_callbacks :start, :finish
    end

    module ClassMethods
      def before_start(*args, &block);  before_callback(:start, *args, &block);  end
      def after_start(*args, &block);   after_callback(:start, *args, &block);   end
      def before_finish(*args, &block); before_callback(:finish, *args, &block); end
      def after_finish(*args, &block);  after_callback(:finish, *args, &block);  end

      private

      def before_callback(callback, *args, &block)
        set_callback(callback, :before, *args, &block)
      end

      def after_callback(callback, *args, &block)
        options = args.extract_options!
        options[:prepend] = true
        set_callback(callback, :after, *(args << options), &block)
      end
    end
  end
end
