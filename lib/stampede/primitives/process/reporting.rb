module Stampede
  # Report data to the current context.
  module Process::Reporting
    def report(var, value = nil)
      context.report "#{process_name}.#{var}", value
    end
  end
end
