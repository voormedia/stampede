module Stampede
  module Process::Verbose
    def self.included(base)
      base.before_start do
        runner.logger.log "  " * depth << "\033[1;30m>> #{object_id.to_s(16)}: #{[self, defined_at].compact.join(', ')}\033[0;0m"
      end

      base.after_finish do
        runner.logger.log "  " * depth << "\033[1;30m<< #{object_id.to_s(16)}: #{self}\033[0;0m"
      end

      base.class_eval do
        class_attribute :defined_at
        def self.inherited(child)
          child.defined_at = caller.grep(/\.stampede/).first
        end
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
