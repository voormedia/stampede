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
    autoload :Callbacks, "stampede/primitives/process/callbacks"
    autoload :Extending, "stampede/primitives/process/extending"
    autoload :Reporting, "stampede/primitives/process/reporting"
    autoload :Timing, "stampede/primitives/process/timing"

    include Callbacks, Extending, Reporting

    class << self
      # Returns the default process name, which will be used if no specific
      # name is assigned to a process. Defaults to the class name in lower
      # case.
      def process_name
        @process_name ||= (name.to_s != "") && name.split("::").last.downcase
      end
    end

    # The context in which this process is running. A process that is not
    # running does not have a context.
    attr_accessor :context

    # The name of this process. Defaults to the class name. Subclasses may
    # choose to automatically set the name to something sensible on
    # initialization.
    attr_accessor :name

    # Create a new process with the given name (defaulting to the class name).
    def initialize(name = nil)
      @name = name || self.class.process_name
      @copy = @finished = false
    end

    # When duplicating a proces, we mark it as a copy.
    def initialize_copy(source)
      @copy = true
      super
    end

    # Creates a duplicate of this process, and runs it in the given context.
    def run(context = nil)
      dup.send(:dispatch, context)
    end

    # Returns whether or not the current process is a copy, as opposed to a
    # prototype.
    def copy?
      @copy
    end

    # Returns whether or not the current process has finished its task.
    def finished?
      @finished
    end

    def to_s
      "#<#{self.class}:0x%.14x @copy=#{@copy.inspect} @finished=#{@finished.inspect}>" % (object_id << 1)
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
      run_callbacks(:finish) do
        @finished = true
      end
      @context.finish if @context
    end

    private

    # Transform the current process into a running process. This should not be
    # performed unless the current process is a copy.
    def dispatch(context = nil)
      @context = context
      run_callbacks(:start) { start }
      self
    end
  end
end
