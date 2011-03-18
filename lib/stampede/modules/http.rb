require "em-http-request"
require "cookiejar"

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
          super "#{http_method} #{url}"
          self.http_method, self.url, self.options = http_method, url, options
        end
      end

      def start
        request = build_request
        report :method => http_method

        inflated_content_length = 0
        latency = nil

        request.headers do
          latency ||= elapsed
          last_url = request.last_effective_url.normalize.to_s
          set_cookies last_url, request.response_header if stateful?
          report :head => request.response_header

          report :url => last_url,
            :status => request.response_header.status,
            :latency => latency,
            :compressed => request.response_header.compressed?
        end

        request.stream do |data|
          inflated_content_length += data.length
          report_sequence :chunks,
            :length => data.length,
            :elapsed => elapsed
        end

        request.callback do
          report :success => true,
            :redirects => request.redirects,
            :length => inflated_content_length || request.response.length
          finish
        end

        request.errback do
          report :success => false,
            :error => request.error
          finish
        end
      end

      private

      def set_cookies(url, headers)
        [*headers["SET_COOKIE"]].each do |header|
          cookiejar.set_cookie url, header
        end
      end

      def cookiejar
        @cookiejar ||= (@context[:http_cookiejar] ||= CookieJar::Jar.new)
      end

      def build_request
        EM::HttpRequest.new(url).send(http_method, collect_options)
      end

      def collect_options
        options.merge :redirects => 5, :head => collect_headers, :inactivity_timeout => 30
      end

      def collect_headers
        HEADERS.dup.tap do |headers|
          headers.merge! "cookie" => cookiejar.get_cookie_header(url) if stateful?
        end
      end
    end
  end
end
