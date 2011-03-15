require "eventmachine"

module Stampede
  # Run one or more scenarios.
  class Runner
    autoload :Daemonization, "stampede/runner/daemonization"
    autoload :Configuration, "stampede/runner/configuration"

    include Daemonization

    attr_reader :reporter, :logger, :config

    class << self
      def start(scenario, config)
        new(scenario, config).start
      end
    end

    def initialize(scenario, config)
      @scenario = scenario
      @config = Runner::Configuration.new(config)
      @reporter = Reporters::Console.new(@logger = @config.logger)
    end

    def start
      trap_signals
      set_max_connections
      verbose! if config.verbose?
      daemonize! if config.daemonize?

      logger.log "Starting #{Stampede.banner}..."
      logger.log "Running scenario '#{@scenario.process_name}'."

      execute
    end

    def finish(exit_message = "Exiting.")
      logger.log exit_message
      EM.stop
    end
    alias_method :child_finished, :finish

    def abort(exit_message = "Aborted.")
      $stderr.puts exit_message
      exit! 1
    end

    def runner
      self
    end

    private

    def trap_signals
      Signal.trap(:KILL) { abort "Killed!" }
      Signal.trap(:TERM) { finish "Terminated!" }
      Signal.trap(:INT)  { abort "\nInterrupted!" }
    end

    def set_max_connections
      EM.set_descriptor_table_size config.max_connections
    end

    def verbose!
      Process.send :include, Process::Verbose
    end

    def execute
      EM.run do
        EM.set_quantum 50
        @scenario.run(self)
      end
    end
  end
end
