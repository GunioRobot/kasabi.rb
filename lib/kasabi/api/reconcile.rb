module Kasabi
  
  module Reconcile
    
    class Client < BaseClient

      #Initialize the client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end
      
      #Simple reconciliation request
      def reconcile_label(label, &block)
        return reconcile( Client.make_query(label), &block )
      end
      
      #Full reconciliation request, allows specifying of additional parameters
      #
      #Returns the array of results from the reconciliation request
      #
      #Accepts a block to support iteration through the results. Method will yield
      #each result and its index.
      def reconcile(query, &block)
        response = get( @endpoint, {"query" => query.to_json } )
        validate_response(response)
        results = JSON.parse( response.content )
        if results["result"] && block_given?
          results["result"].each_with_index do |r, i|
            yield r, i
          end
        end
        return results["result"]        
      end
      
      #Perform a number of reconciliation queries
      #Submits a single request with a number of queries
      #
      #Accepts a block to support iteration through the results. Method will yield
      #each result, its index, and the query      
      def reconcile_all(queries, &block)        
        #TODO add batching
        #TODO make parallel?
        json = {}
        queries.each_with_index do |query, i|
          json["q#{i}"] = query
        end
        response = get( @endpoint, {"queries" => json.to_json } )
        validate_response(response)
        results = JSON.parse( response.content )
        if block_given?
          queries.each_with_index do |query, i|
            if results["q#{i}"]
              yield results["q#{i}"]["result"], i, query
            end
          end
        end
        return results         
      end
      
      #Make an array of reconciliation queries using a standard set of options for limiting,
      #type matching and property filtering
      #
      # label:: text to reconcile on
      # limit:: limit number of results, default is 3
      # type_strict:: how to perform type matching, legal values are :any (default), :all, :should
      # type:: string identifier of type, or array of string identifiers
      # properties:: property filters, see make_property_filter      
      def Client.make_queries(labels, limit=3, type_strict=:any, type=nil, properties=nil)
        queries = []
        labels.each do |label|
          queries << Client.make_query(label, limit, type_strict, type, properties)
        end
        return queries
      end
      
      #Make a reconciliation query
      #
      # label:: text to reconcile on
      # limit:: limit number of results, default is 3
      # type_strict:: how to perform type matching, legal values are :any (default), :all, :should
      # type:: string identifier of type, or array of string identifiers
      # properties:: property filters, see make_property_filter
      def Client.make_query(label, limit=3, type_strict=:any, type=nil, properties=nil)
        query = Hash.new
        query[:query] = label
        query[:limit] = limit
        query[:type_strict] = type_strict
                  
        query[:type] = type if type != nil
        query[:properties] = properties if properties != nil
        
        return query
      end
      
      #Construct a property filter
      #
      #A property name or identifier must be specified. Both are legal but it is up to the 
      #service to decide which one it uses. Some services may have restrictions on whether 
      #they support names or identifiers.
      #
      #  value:: a single value, or an array of string or number or object literal, e.g., "Japan"
      #  name::  string, property name, e.g., "country"
      #  id:: string, property ID, e.g., "/people/person/nationality" in the Freebase ID space
      def Client.make_property_filter(value, name=nil, id=nil)
        if name == nil and id == nil
          raise "Must specify at least a property name or property identifier"
        end
        
        filter = Hash.new
        filter[:v] = value
        filter[:p] = name if name != nil
        filter[:pid] = id if id != nil
          
        return filter
      end
      
                  
    end
  end
end