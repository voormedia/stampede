module Stampede
  # A queue is a collection of processes, which are executed sequentially.
  class Queue < Process
    class_attribute :children, :enumerator

    class << self
      def initialize(name = nil)
        super
        self.children = []
        self.enumerator = children.each
      end

      # Append a new child to the queue.
      def push(child)
        children << child
      end
    end

    def start
      finish
    end

    def finish
      enumerator.next.run(self)
    rescue StopIteration
      super
    end
  end
end
