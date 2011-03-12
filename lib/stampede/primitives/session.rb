module Stampede
  # A session is a list of actions that will be executed sequentially.
  # Additionally, a session is able to keep a state. The state may be
  # dynamically updated by actions.
  class Session < Queue
  end
end
