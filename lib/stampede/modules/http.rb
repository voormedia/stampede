require "em-http-request"
require "cookiejar"
require "ntlm"

module Stampede
  module Modules::HTTP
    METHODS = [:get, :post, :put, :delete, :head]

    DEFAULT_OPTIONS = { :keepalive => true, :redirects => 0, :inactivity_timeout => 30 }
    DEFAULT_HEADERS = { "user-agent" => Stampede.user_agent }

    METHODS.each do |method|
      class_eval <<-RUBY
        def #{method}(url, options = {})
          push Request.create(:#{method}, url, options)
        end
      RUBY
    end

    def authenticate(username, password)
      domain = username.slice!(/\A\w+[\\\/]/)
      if domain and domain.chop!
        # NTLM
        options :ntlm_auth => [username, domain, password]
        headers "authorization" => "NTLM " + NTLM.negotiate.to_base64
      else
        # HTTP Basic
        headers "authorization" => [username, password]
      end
    end

    def user_agent(agent)
      headers "user-agent" => agent
    end

    def headers(head)
      extend_parent
      self.http_headers.merge! head
    end

    def options(options)
      extend_parent
      self.http_options.merge! options
    end

    private

    def extend_parent
      return if respond_to? :http_headers and respond_to? :http_options
      class_attribute :http_headers, :http_options
      self.http_headers = {}
      self.http_options = {}
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
        @requests = 0
        start_request http_method, url, collect_options
      end

      def finish_request
        @requests -= 1
        finish if @requests == 0
      end

      def start_request(http_method, url, options)
        @requests += 1

        request = connection.send(http_method, options)

        request_report = {}
        inflated_content_length = 0
        latency = nil
        primary_request = true

        request.headers do
          latency ||= elapsed
          last_url = request.last_effective_url.normalize.to_s
          if stateful?
            set_cookies last_url, request.response_header
            if authenticate_ntlm request.response_header
              primary_request = false
            end
          end

          request_report.merge! :method => http_method,
            :url => last_url,
            :status => request.response_header.status,
            :latency => latency,
            :compressed => request.response_header.compressed?
        end

        request.stream do |data|
          inflated_content_length += data.length
          request_report[:chunks] ||= []
          request_report[:chunks] << { :length => data.length, :elapsed => elapsed }
        end

        request.callback do
          request_report.merge!(:success => true, :length => inflated_content_length || request.response.length)
          if primary_request
            report request_report
          else
            report_sequence :subrequests, request_report
          end
          finish_request
        end

        request.errback do
          request_report.merge!(:success => false, :error => request.error)
          if primary_request
            report request_report
          else
            report_sequence :subrequests, request_report
          end
          finish_request
        end
      end

      private

      def set_cookies(url, header)
        # Split the cookie header, because em-http-request (incorrectly) folds
        # multiple Set-Cookie headers into one.
        header.cookie.to_s.split(/(?<!expires=\w{3}),\s*/i).each do |cookie_header|
          cookiejar.set_cookie url, cookie_header rescue nil
        end
      end

      def authenticate_ntlm(header)
        challenge = header["WWW_AUTHENTICATE"][/NTLM (.*)/, 1].unpack('m').first rescue nil
        if challenge and header.status == 401
          ntlm_response = "NTLM " + NTLM.authenticate(challenge, *@context.http_options[:ntlm_auth]).to_base64
          start_request http_method, url, collect_options.tap { |opts| opts[:head]["authorization"] = ntlm_response }
          true
        end
      end

      def cookiejar
        @cookiejar ||= (@context[:http_cookiejar] ||= CookieJar::Jar.new)
      end

      def connection
        @connection ||= EM::HttpRequest.new(url)
      end

      def collect_options
        DEFAULT_OPTIONS.dup.tap do |options|
          options.merge! @context.http_options if @context.respond_to? :http_options
          options.merge! :head => collect_headers
        end
      end

      def collect_headers
        DEFAULT_HEADERS.dup.tap do |headers|
          headers.merge! @context.http_headers if @context.respond_to? :http_headers
          if stateful?
            cookies = cookiejar.get_cookie_header(url)
            headers.merge! "cookie" => cookies unless cookies.blank?
          end
        end
      end
    end
  end
end
