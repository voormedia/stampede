require "em-http-request"

module Stampede
  module Modules::HTTP
    METHODS = [:get, :post, :put, :delete, :head]
    HEADERS = { "user-agent" => Stampede.banner }

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

        request.headers do
          report :latency => elapsed,
            :url => request.last_effective_url.normalize.to_s,
            :status => request.response_header.status
        end

        request.stream do |data|
        end

        request.callback do
          report :success => true,
            :length => request.response_header.length
          finish
        end

        request.errback do
          report :success => false
          finish
        end
      end

      private

      def connection
        EventMachine::HttpRequest.new(url)
      end

      def collect_options
        options.merge :redirects => 5, :head => HEADERS
      end
    end


    #
    # class Request < Action
    #   attr_reader :method, :url
    #
    #   def initialize(method, url)
    #     super(url)
    #     @method, @url = method, url
    #   end
    #
    #   def start
    #     request = connection.send(method, options)
    #     report method: method
    #
    #     length = 0
    #
    #     request.headers do
    #       report latency: elapsed,
    #         url: request.last_effective_url.normalize.to_s,
    #         status: request.response_header.status
    #     end
    #
    #     request.stream do |chunk|
    #       length += chunk.length
    #       # report length: chunk.length,
    #       #   data: chunk,
    #       #   elapsed: elapsed_ms
    #     end
    #
    #     request.callback do
    #       report success: true,
    #         url: request.last_effective_url.normalize.to_s,
    #         redirects: request.redirects,
    #         length: length
    #       finish
    #     end
    #
    #     request.errback do |*args|
    #       report success: false,
    #         error: request.error
    #       finish
    #     end
    #   end
    #
    #   def connection
    #     @connection ||= begin
    #       connection = EventMachine::HttpRequest.new(url)
    #       # if connection.respond_to? :use
    #       #   if context[:http_ntlm_authentication]
    #       #     connection.use Filters::NTLM.new(self)
    #       #   end
    #       # end
    #       # connection
    #     end
    #   end
    #
    #   def options
    #     { redirects: 5, head: headers }
    #   end
    #
    #   def headers
    #     DEFAULT_HEADERS.merge context[:http_headers]
    #   end
    # end
    #
    # def get(url)
    #   push Request.new(:get, url)
    # end
    #
    # def post(url)
    #   push Request.new(:post, url)
    # end
    #
    # def authenticate(username, password)
    #   # domain, username = username.split(/[\/\\]/) if username =~ /[\/\\]/
    #   # self[:http_ntlm_authentication] = [username, domain, password]
    # end
    #
    # def user_agent(agent)
    #   header "user-agent" => agent
    # end
    #
    # def header(headers = {})
    #   (self[:http_headers] ||= {}).merge! headers
    # end
  end
end
