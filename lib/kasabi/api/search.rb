module Kasabi
  
  module Search
    
    # Client object for working with a Kasabi Search API
    class Client < BaseClient
            
      #Initialize the client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end
      
      # Search the Metabox indexes.
      #
      # query:: the query to perform.
      # params:: additional query parameters (see below)
      #
      # The _params_ hash can contain the following values:
      # * *:max*: The maximum number of results to return (default is 10)
      # * *:offset*: Offset into the query results (for paging; default is 0)
      # * *:sort*: ordered list of fields to be used when applying sorting        
      def search(query, params=nil)
        search_params = build_search_params(query, params)
        search_params[:output] = "json"
        response = get(search_url(), search_params)
        
        validate_response(response)
        
        #TODO provide a better structure?
        return JSON.parse( response.content )
        
      end
      
      def facet_url()
        return "#{@endpoint}/facet"
      end

      def search_url()
        return "#{@endpoint}/search"
      end
            
      # The _params_ hash can contain the following values:
      # * *:top*: the maximum number of results to return for each facet
      # * *:output*: the preferred response format, can be html or xml (the default)            
      def facet(query, facets, params=Hash.new)
        if facets == nil or facets.empty?
          throw "Must supply at least one facet"
        end
        search_params = build_search_params( query, params)
        search_params[:fields] = facets.join(",")
        response = get(facet_url(), search_params)
        
        validate_response(response)
        
        return Kasabi::Search::Facet::Results.parse( response.content )  
      end
            
      def build_search_params(query, params)
        if params != nil
          search_params = params.clone()
        else
          search_params = Hash.new  
        end
        search_params[:query] = query
        return search_params      
      end
      
    end
    
  end
end