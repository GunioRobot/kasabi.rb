module Kasabi
  
  class Dataset < Kasabi::BaseClient
    
    #Initialize the client to work with a specific dataset endpoint
    #Dataset endpoints are available from api.kasabi.com/data/...
    #
    # The _options_ hash can contain the following values:
    # * *:apikey*: required. apikey authorized to use the API
    # * *:client*: HTTPClient object instance
    def initialize(endpoint, options={})
      super(endpoint, options)                 
    end
    
    #Read the metadata about this dataset from the live service
    def metadata(allow_cached=true)
      if @metadata
        return @metadata
      end
      response = @client.get(@endpoint, 
        {:apikey=>@apikey}, 
        {"Accept" => "application/json"})
      validate_response(response)
      @metadata = JSON.parse( response.content )
      return @metadata
    end
    
    PROPERTIES = {
      :title => "http://purl.org/dc/terms/title",
      :description => "http://purl.org/dc/terms/description",
      :homepage => "http://xmlns.com/foaf/0.1/homepage",
      :sparql_endpoint => "http://rdfs.org/ns/void#sparqlEndpoint",
      :lookup_api => "http://rdfs.org/ns/void#uriLookupEndpoint",
      :search_api => "http://labs.kasabi.com/ns/services#searchEndpoint" 
    }
          
    PROPERTIES.keys.each do |arg|
      send :define_method, arg do
        return property(PROPERTIES[arg])
      end      
    end
    
    def sparql_client()
      return Kasabi::Sparql::Client.new( self.sparql_endpoint, self.options )
    end

    def lookup_api_client()
      return Kasabi::Lookup::Client.new( self.lookup_api, self.options )
    end

    def search_api_client()
      return Kasabi::Search::Client.new( self.search_api, self.options )
    end
         
    # Store the contents of a File (or any IO stream) in the store associated with this dataset
    # The client does not support streaming submissions of data, so the stream will be fully read before data is submitted to the platform
    # file:: an IO object  
    # content_type:: mimetype of RDF serialization
    def store_file(file, content_type="application/rdf+xml")      
      data = file.read()
      file.close()
      return store_data(data, content_type)
    end
    
    #Store triples contained in the provided string    
    def store_data(data, content_type="application/rdf+xml")
      response = @client.post("#{endpoint}/store", data, {"Content-Type" => content_type } )
      if response.status != 202
        raise "Unable to perform request. Status: #{response.status}. Message: #{response.content}"
      end
      return response.content               
    end
    
    def store_uri(uri, content_type="application/rdf+xml")
      response = @client.post("#{endpoint}/store", {"data_uri" => uri }, {"Content-Type" => content_type } )
      if response.status != 202
        raise "Unable to perform request. Status: #{response.status}. Message: #{response.content}"
      end
      return response.content               
    end
    
    private
    
      def property(predicate)
        metadata()
        return @metadata[ @metadata.keys[0] ][predicate][0]["value"]     
      end
  end
end