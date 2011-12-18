module Kasabi

  #Base class for API clients
  class BaseClient

    attr_reader :endpoint
    attr_reader :client
    attr_reader :apikey

    #Initialize the client to work with a specific endpoint
    #
    # The _options_ hash can contain the following values:
    # * *:apikey*: required. apikey authorized to use the API
    # * *:client*: HTTPClient object instance
    def initialize(endpoint, options={})
      @endpoint = endpoint
      @client = options[:client] || HTTPClient.new()
      @apikey = options[:apikey] || nil
    end

    def client_options
      {:apikey => @apikey, :client => @client}
    end

    def get(uri, query=nil, headers={})
      headers["X_KASABI_APIKEY"] = @apikey
      return @client.get(uri, query, headers)
    end

    def post(uri, body="", headers={})
      headers["X_KASABI_APIKEY"] = @apikey
      return @client.post(uri, body, headers)
    end

    def validate_response(response)
      if response.status != 200
        raise "Unable to perform request. Status: #{response.status}. Message: #{response.content}"
      end
    end

  end

end