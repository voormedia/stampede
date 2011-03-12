module Stampede
  # A group is a collection of processes, which are executed in parallel.
  class Group < Process
    attr_reader :children

    def initialize(name = nil)
      @children = []
      super
    end

    # Append a new child to the group.
    def push(child)
      @children << child
    end

    def start
      @running = @children.length + 1
      @children.each do |child|
        child.run(self)
      end
      finish
    end

    def finish
      @running -= 1
      super if @running.zero?
    end
  end
end
