require "active_support/core_ext/class/attribute"
require "active_support/core_ext/module/anonymous"

module Stampede
  # Processes are the basic abstract unit of a Stampede script. When a process
  # is run, it is first duplicated, and then its +start+ method is called.
  # When the task is complete, the +finish+ method should be called. Subclasses
  # are responsible for performing actions asynchronously, and guaranteeing
  # that +finish+ is called.
  #
  # Because a process is always duplicated before being run, its internal
  # state may be modified during execution.
  class Process
    class FinishedError < StandardError; end

    autoload :Callbacks, "stampede/primitives/process/callbacks"
    autoload :Extending, "stampede/primitives/process/extending"
    autoload :Reporting, "stampede/primitives/process/reporting"
    autoload :Timing, "stampede/primitives/process/timing"
    autoload :Verbose, "stampede/primitives/process/verbose"

    include Callbacks, Extending

    class_attribute :process_name

    class << self
      def create(*args, &block)
        Class.new(self).tap do |process|
          process.send :initialize, *args, &block
        end
      end

      def initialize(name = nil)
        self.process_name = name || superclass.process_name || superclass.name.split("::").last.downcase
      end

      def run(context)
        new(context).run
      end

      def to_s
        if anonymous?
          "subclass of #{superclass.to_s}"
        else
          super
        end
      end
      alias_method :inspect, :to_s

      private :new
    end

    attr_reader :context, :runner, :logger

    def initialize(context)
      @context = context
      @runner = @context.runner
      @logger = @runner.logger
      @finished = false
    end

    def run
      _run_start_callbacks { start }
      self
    end

    # Returns whether or not the current process has finished its task.
    def finished?
      @finished
    end

    def record(data)
      @context.record(data)
    end

    def to_s
      "#{process_name} (#{self.class})"
    end
    alias_method :inspect, :to_s

    protected

    # Kicks off whatever task this process should perform. Subclasses should
    # override this method.
    def start
      raise NotImplementedError, "Override #start to define a process."
    end

    # Signals that this process is finished. It will alert its context process
    # that it is finished.
    def finish
      raise FinishedError, "Process is already finished" if finished?
      _run_finish_callbacks { @finished = true }
      @context.child_finished if @context
    end
  end
end
