require "json"
require "time"

class Time
  def to_json(*args) #:nodoc:
    iso8601(3).to_json(*args)
  end
end

module Stampede
  module Reporters
    class CouchDB
      def initialize(url)
        @url = url
        @docs = []
        @closing = false
      end

      def record(value)
        @docs << ::JSON.generate(value)
        EM.next_tick { flush }
      end

      def close
        @closing = true
        @close_callback = Proc.new
        flush
      end

      def flush
        return if @docs.empty?
        docs, @docs = %Q({"docs":[#{@docs.join(",")}]}), []
        request = EM::HttpRequest.new(@url + "/_bulk_docs").post :body => docs,
          :head => { "content-type" => "application/json" }

        request.callback do
          @close_callback.call if @closing
        end

        request.errback do
          @close_callback.call if @closing
        end
      end
    end
  end
end
