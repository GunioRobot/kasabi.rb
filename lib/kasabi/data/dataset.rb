module Kasabi
  
  class Dataset < Kasabi::BaseClient
    
    attr_reader :short_code
    attr_reader :uri
    
    #Initialize the client to work with a specific dataset endpoint
    #Dataset endpoints are available from api.kasabi.com/data/...
    #
    # The _options_ hash can contain the following values:
    # * *:apikey*: required. apikey authorized to use the API
    # * *:client*: HTTPClient object instance
    def initialize(endpoint, options={})
      super(endpoint, options)
      uri = URI.parse(endpoint)
      domain = uri.host.split(".")[0]
      case domain
        when "data"
          @uri = endpoint
          @endpoint = endpoint.gsub("http://data", "http://api")  
        when "api"
          @endpoint = endpoint
          @uri = endpoint.gsub("http://api", "http://data")
        else
          #probably website, e.g. beta.kasabi or www.kasabi
          @endpoint = "http://api.kasabi.com" + uri.path
          @uri = "http://data.kasabi.com" + uri.path
      end      
    end
    
    #Read the metadata about this dataset from the live service
    def metadata(allow_cached=true)
      if @metadata
        return @metadata
      end
      response = get(@uri, nil, 
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
      :search_api => "http://labs.kasabi.com/ns/services#searchEndpoint",
      :augmentation_api => "http://labs.kasabi.com/ns/services#augmentationEndpoint",
      :reconciliation_api => "http://labs.kasabi.com/ns/services#reconciliationEndpoint",
      :store_api => "http://labs.kasabi.com/ns/services#storeEndpoint",
      :status_api => "http://labs.kasabi.com/ns/services#statusEndpoint",
      :jobs_api => "http://labs.kasabi.com/ns/services#jobsEndpoint",
      :attribution_api => "http://labs.kasabi.com/ns/services#attributionEndpoint"
    }
          
    PROPERTIES.keys.each do |arg|
      send :define_method, arg do
        return property(PROPERTIES[arg])
      end      
    end

    STANDARD_API_CLIENTS = {
      :sparql_endpoint => Kasabi::Sparql::Client,
      :lookup_api => Kasabi::Lookup::Client,
      :search_api => Kasabi::Search::Client,
      :augmentation_api => Kasabi::Augment::Client,
      :reconciliation_api => Kasabi::Reconcile::Client,
      :store_api => Kasabi::Storage::Client,
      :status_api => Kasabi::Status,
      :jobs_api => Kasabi::Jobs::Client,
      :attribution_api => Kasabi::Attribution      
    }

    STANDARD_API_CLIENTS.keys.each do |arg|
      send :define_method, "#{arg}_client" do
        return STANDARD_API_CLIENTS[arg].method("new").call( self.method(arg).call(), self.client_options )
      end      
    end
                                      
    private
    
      def property(predicate)
        metadata()
        return @metadata[ @metadata.keys[0] ][predicate][0]["value"]     
      end
  end
end