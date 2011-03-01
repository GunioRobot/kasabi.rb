module Kasabi
  
  module Lookup
    
    class Client < BaseClient
      
      #Initialize the client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end
      
      def lookup(uri)        
        response = @client.get(@endpoint, {:about => uri, :apikey=>@apikey, :output=>"json"} )
        validate_response(response)  
        return JSON.parse( response.content )     
      end
      
    end
    
  end
end