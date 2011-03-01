module Kasabi
  
  module Augment
    
    #Client for working with Kasabi Augmentation APIs
    class Client

      attr_reader :endpoint
      attr_reader :client
      
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

      # Augment an RSS feed that can be retrieved from the specified URL, against data in this store
      #
      # uri:: the URL for the RSS 1.0 feed
      def augment_uri(uri)
        response = @client.get(@endpoint, {:apikey=>@apikey, "data-uri" => uri})
        if response.status != 200
          raise "Unable perform augmentation. Response code was #{resp.status}"
        end
          
        return response.content
      end
      
      # Augment data using POSTing it to the API
      #
      # Currently this is limited to RSS 1.0 feeds
      #
      # data:: a String containing the data to augment
      def augment(data, content_type="application/rss+xml")
        response = @client.post("#{@endpoint}?apikey=#{@apikey}", data, {"Content-Type" => "application/rss+xml"})
        if response.status != 200
          raise "Unable perform augmentation. Response code was #{resp.status}"
        end          
        return response.content
      end
      
    end
  end
end