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

    def start_children
      @running = (@running || 0) + children.length + 1
      children.each do |child|
        child.run(self)
      end
      child_finished
    end
    alias_method :start, :start_children

    def child_finished
      @running -= 1
      finish if @running.zero?
    end
  end
end
