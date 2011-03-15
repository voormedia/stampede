require "active_support/concern"

module Stampede
  # Processes can be extended with modules. It is possible to extend a single
  # process by using Ruby's +extend+ method, but that will not make the module
  # available to inner processes, such as sessions within a scenario.
  #
  # By calling +use+ instead, the current process is extended, and in addition
  # all inner processes will be extended with all modules their context
  # processes have.
  module Process::Extending
    extend ActiveSupport::Concern

    module ClassMethods
      # Extends the current process with the given modules, and makes them
      # available to any process that was created with #derive.
      def use(*modules)
        modules << Module.new(&Proc.new) if block_given?
        (@extensions ||= []).concat modules
        extend *modules
      end

      # Extendes a process. The given process will be extended with all modules
      # that the current process was extended with. Any given block will be
      # called in the context of the new process.
      def augment(object)
        object.tap do |process|
          process.use *@extensions if @extensions
          process.instance_eval &Proc.new if block_given?
        end
      end
    end
  end
end
