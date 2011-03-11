module Stampede
  # Allows extension and derivation of a process.
  module Process::Extending
    # Extends the current process with the given modules, and makes them
    # available to any process that was created with #derive.
    def use(*modules)
      (@extensions ||= []).concat modules
      extend(*@extensions)
    end

    # Derives a new process of the given klass. The derived process will be
    # extended with all modules that the current process was extended with.
    # Any given block will be called in the context of the new process.
    def derive(klass)
      klass.new.tap do |process|
        process.use *@extensions if @extensions
        process.instance_eval &Proc.new if block_given?
      end
    end
  end
end
