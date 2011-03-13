module Stampede
  # A group is a collection of processes, which are executed in parallel.
  class Group < Process
    class_attribute :children

    class << self
      def initialize(name = nil)
        super
        self.children = []
      end

      def push(child)
        self.children << child
      end
    end

    def start
      @running = children.length + 1
      children.each do |child|
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
