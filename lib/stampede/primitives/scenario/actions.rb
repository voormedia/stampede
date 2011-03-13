module Stampede
  # Define some basic actions that are available to scenarios by default.
  module Scenario::Actions
    # Creates an ad-hoc action. It should call +finish+ when completed.
    #
    #   action "awesome action" do
    #     # ...
    #     finish
    #   end
    def action(name = nil)
      push augment(Lambda.create(name, &Proc.new))
    end

    # Defines a session. A session executes its actions sequentially, and is
    # capable of maintaining a state that can be dynamically changed by the
    # actions that are executed in the context of the session.
    # See Session for details.
    #
    #   use HTTP
    #   session "browsing" do
    #     get "http://google.com/"
    #     # The next action will not be performed before the previous
    #     # one is completed.
    #     get "http://yahoo.com/"
    #   end
    def session(name = nil)
      push augment(Session.create(name), &Proc.new)
    end

    # Delays execution for the given number of seconds. This only makes sense
    # within a session (or another kind of queue). Stampede will not be
    # blocked during the waiting time. Other actions may be executed in
    # parallel, if there are any.
    #
    #   use HTTP
    #   session "browsing" do
    #     get "http://google.com/"
    #     wait 3  # Simulate user wait time of 3 seconds.
    #     get "http://yahoo.com/"
    #   end
    def wait(time)
      action("wait") { EventMachine.add_timer(time) { finish } }
    end
  end
end
