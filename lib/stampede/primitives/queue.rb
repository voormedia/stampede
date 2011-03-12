module Stampede
  # A queue is a collection of processes, which are executed sequentially.
  class Queue < Process
    attr_reader :children

    def initialize(name = nil)
      @children = []
      @enumerator = @children.each
      super
    end

    # Append a new child to the queue.
    def push(child)
      @children << child
    end

    def start
      finish
    end

    def finish
      @enumerator.next.run(self)
    rescue StopIteration
      super
    end
  end
end
