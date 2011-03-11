module Stampede
  class Group < Process
    attr_reader :children

    def initialize(*args)
      @children = []
      super
    end

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
