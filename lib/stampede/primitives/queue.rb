module Stampede
  # A queue is a collection of processes, which are executed sequentially.
  class Queue < Process
    class_attribute :children

    class << self
      def initialize(name = nil)
        super
        self.children = []
      end

      # Append a new child to the queue.
      def push(child)
        self.children << child
      end
    end

    def start
      @enumerator = children.each
      finish
    end

    def finish
      @enumerator.next.run(self)
    rescue StopIteration
      super
    end
  end
end
