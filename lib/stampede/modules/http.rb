require "em-http-request"

module Stampede
  module Modules::HTTP
    METHODS = [:get, :post, :put, :delete, :head]
    HEADERS = { "user-agent" => Stampede.user_agent }

    METHODS.each do |method|
      class_eval <<-RUBY
        def #{method}(url, options = {})
          push Request.create(:#{method}, url, options)
        end
      RUBY
    end

    class Request < Action
      class_attribute :http_method, :url, :options

      class << self
        def initialize(http_method, url, options = {})
          super url
          self.http_method, self.url, self.options = http_method, url, options
        end
      end

      def start
        request = connection.send(http_method, collect_options)
        report :method => http_method

        request.headers do
          # p request.last_effective_url.normalize.to_s
          # p request.redirect?
          report :url => request.last_effective_url.normalize.to_s,
            :status => request.response_header.status,
            :length => request.response_header.content_length # FIXME: streaming
        end

        request.stream do |data|
          # p data
        end

        request.callback do
          report :success => true,
            :redirects => request.redirects
          finish
        end

        request.errback do
          report :success => false,
            :error => request.error
          finish
        end
      end

      private

      def connection
        EM::HttpRequest.new(url)
      end

      def collect_options
        options.merge :redirects => 5, :head => HEADERS, :inactivity_timeout => 30
      end
    end
  end
end
