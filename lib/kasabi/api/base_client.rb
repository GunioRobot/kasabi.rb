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
    
  end
  
end