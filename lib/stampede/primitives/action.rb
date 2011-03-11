module Stampede
  class Action < Process
    include Process::Timing
  end
end
