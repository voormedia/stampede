module Stampede
  module Process::Verbose
    def self.included(base)
      base.before_start do
        $stderr.puts "  " * depth + "\033[1;30m>> #{self}\033[0;0m"
      end

      base.after_finish do
        $stderr.puts "  " * depth + "\033[1;30m<< #{self}\033[0;0m"
      end
    end

    private

    def depth
      @depth ||= begin
        ctx = self
        level = -1
        level += 1 while ctx.respond_to? :context and ctx = ctx.context
        level
      end
    end
  end
end
