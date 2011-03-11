module Stampede
  class Queue < Process
    attr_reader :children

    def initialize(*args)
      @children = []
      @enumerator = @children.each
      super
    end

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
