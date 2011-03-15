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

    def start_children
      @enumerator = children.each
      start_next
    end
    alias_method :start, :start_children

    def start_next
      @enumerator.next.run(self)
    rescue StopIteration
      finish
    end
    alias_method :child_finished, :start_next
  end
end
