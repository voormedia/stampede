module Stampede
  class Process
    autoload :Callbacks, "stampede/primitives/process/callbacks"
    autoload :Extending, "stampede/primitives/process/extending"
    autoload :Reporting, "stampede/primitives/process/reporting"
    autoload :Timing, "stampede/primitives/process/timing"

    include Callbacks, Extending, Reporting

    # The context in which this process is running. A process that is not
    # running does not have a context.
    attr_accessor :context

    # The name of this process. Defaults to the class name. Subclasses may
    # choose to automatically set the name to something sensible on
    # initialization.
    attr_accessor :name

    # Create a new process with the given name (defaulting to the class name).
    def initialize(name = self.class.name)
      @name = name
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

    protected

    # Kicks off whatever task this process should perform. Subclasses should
    # override this method.
    def start
      raise NotImplementedError, "Override #start to primitives a process."
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
