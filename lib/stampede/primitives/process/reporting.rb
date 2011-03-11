module Stampede
  # Report data to the current context.
  module Process::Reporting
    def report(var, value = nil)
      context.report "#{name}.#{var}", value
    end
  end
end
