module Stampede
  # Run one or more scenarios.
  class Runner
    class << self
      def start(scenario, reporter)
        new(scenario, reporter).start
      end
    end

    attr_reader :reporter

    def initialize(scenario, reporter)
      @scenario, @reporter = scenario, reporter
    end

    def start
      EventMachine.run do
        EventMachine.set_quantum 50
        @scenario.run(self)
      end
    end

    def finish
      EventMachine.stop
    end

    def report(*args)
      @reporter.report(*args)
    end
  end
end
