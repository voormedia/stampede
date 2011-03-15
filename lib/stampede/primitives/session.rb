module Stampede
  # A session is a list of actions that will be executed sequentially.
  # Additionally, a session is able to keep a state. The state may be
  # dynamically updated by actions.
  class Session < Queue
    include Process::Reporting
    include Process::Timing

    def record(data = {})
      report_sequence :actions, data
    end
  end
end
