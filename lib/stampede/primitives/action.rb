module Stampede
  # An action is a process that performs a specific task. Its start and end
  # times are recorded automatically.
  #
  # Specific actions should typically be a subclass of this class.
  class Action < Process
    include Process::Reporting
    include Process::Timing
  end
end
