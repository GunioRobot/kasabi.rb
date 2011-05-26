module Kasabi

  #Module providing a SPARQL client library, support for parsing SPARQL query responses into Ruby objects
  #and other useful behaviour  
  module Sparql

    SPARQL_RESULTS_XML = "application/sparql-results+xml"
    SPARQL_RESULTS_JSON = "application/sparql-results+json"
    
    #Includes all statements along both in-bound and out-bound arc paths
    #
    #See http://n2.talis.com/wiki/Bounded_Descriptions_in_RDF   
    SYMMETRIC_BOUNDED_DESCRIPTION = <<-EOL
    CONSTRUCT {?uri ?p ?o . ?s ?p2 ?uri .} WHERE { {?uri ?p ?o .} UNION {?s ?p2 ?uri .} }
    EOL
    
    #Similar to Concise Bounded Description but includes labels for referenced resources
    #
    #See http://n2.talis.com/wiki/Bounded_Descriptions_in_RDF    
    LABELLED_BOUNDED_DESCRIPTION = <<-EOL
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
    CONSTRUCT {
       ?uri ?p ?o . 
       ?o rdfs:label ?label . 
       ?o rdfs:comment ?comment . 
       ?o <http://www.w3.org/2004/02/skos/core#prefLabel> ?plabel . 
       ?o rdfs:seeAlso ?seealso.
    } WHERE {
      ?uri ?p ?o . 
      OPTIONAL { 
        ?o rdfs:label ?label .
      } 
      OPTIONAL {
        ?o <http://www.w3.org/2004/02/skos/core#prefLabel> ?plabel . 
      } 
      OPTIONAL {
        ?o rdfs:comment ?comment . 
      } 
      OPTIONAL { 
        ?o rdfs:seeAlso ?seealso.
      }
    }    
    EOL

    #Derived from both the Symmetric and Labelled Bounded Descriptions. Includes all in-bound
    #and out-bound arc paths, with labels for any referenced resources.
    #
    #See http://n2.talis.com/wiki/Bounded_Descriptions_in_RDF    
    SYMMETRIC_LABELLED_BOUNDED_DESCRIPTION = <<-EOL
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> 
    CONSTRUCT {
      ?uri ?p ?o . 
      ?o rdfs:label ?label . 
      ?o rdfs:comment ?comment . 
      ?o rdfs:seeAlso ?seealso. 
      ?s ?p2 ?uri . 
      ?s rdfs:label ?label . 
      ?s rdfs:comment ?comment . 
      ?s rdfs:seeAlso ?seealso.
    } WHERE { 
      { ?uri ?p ?o . 
        OPTIONAL { 
          ?o rdfs:label ?label .
        } 
        OPTIONAL {
          ?o rdfs:comment ?comment .
        } 
        OPTIONAL {
          ?o rdfs:seeAlso ?seealso.
        } 
      } 
      UNION {
        ?s ?p2 ?uri . 
        OPTIONAL {
          ?s rdfs:label ?label .
        } 
        OPTIONAL {
          ?s rdfs:comment ?comment .
        } 
        OPTIONAL {
          ?s rdfs:seeAlso ?seealso.
        } 
      } 
    }    
    EOL

    DESCRIPTIONS = {
      :cbd => "DESCRIBE ?uri",
      :scbd => SYMMETRIC_BOUNDED_DESCRIPTION,
      :lcbd => LABELLED_BOUNDED_DESCRIPTION,
      :slcbd => SYMMETRIC_LABELLED_BOUNDED_DESCRIPTION
    }      
    
    #A simple SPARQL client that handles the basic HTTP traffic
    class Client < BaseClient
      
        #Initialize a client for a specific endpoint
        #
        #endpoint:: uri of the SPARQL endpoint
        #options:: hash containing additional configuration options, including +:apikey+ for specifying api key
        def initialize(endpoint, options={} )
         super(endpoint, options)
        end 

        VARIABLE_MATCHER = /(\?|\$)([a-zA-Z]+)/
      
        #Apply some initial bindings to parameters in a query
        #
        #The keys in the values hash are used to replace variables in a query
        #The values are supplied as is, allowing them to be provided as URIs, or typed literals
        #according to Turtle syntax.
        #
        #Any keys in the hash that are not in the query are ignored. Any variables not found
        #in the hash remain unbound.
        #
        #query:: the query whose initial bindings are to be set
        #values:: hash of query name to value
        def Client.apply_initial_bindings(query, bindings={})
            copy = query.clone()
            copy.gsub!(VARIABLE_MATCHER) do |pattern|
              key = $2
              if bindings.has_key?(key)
                bindings[key].to_s
              else
                pattern
              end              
            end            
            return copy  
        end

        #Convert a SPARQL query result binding into a hash suitable for passing
        #to the apply_initial_bindings method.
        #
        #The result param is assumed to be a Ruby hash that reflects the structure of 
        #a binding in a SELECT query result (i.e. the result of parsing the <tt>application/sparql-results+json</tt> 
        #format and extracting an specific result binding.
        #
        #The method is intended to be used to support cases where an initial select query is 
        #performed to extract some variables that can later be plugged into a subsequent 
        #query
        #
        #result:: hash conforming to structure of a <tt>binding</tt> in the SPARQL JSON format
        def Client.result_to_query_binding(result)
          hash = {}
          result.each_pair do |key, value|
            if value["type"] == "uri"
              hash[key] = "<#{value["value"]}>"
            elsif (value["type"] == "literal" && !value.has_key?("datatype"))
              hash[key] = "\"#{value["value"]}\""
            elsif (value["type"] == "literal" && value.has_key?("datatype"))
              hash[key] = "\"#{value["value"]}\"^^#{value["datatype"]}"             
            else
              #do nothing for bnodes
            end
          end
          return hash
        end        
        #Convert Ruby hash structured according to SPARQL JSON format
        #into an array of hashes by calling result_to_query_binding on each binding
        #into the results.
        #
        #E.g:
        #<tt>results = Sparql::SparqlHelper.select(query, sparql_client)</tt>
        #<tt>bindings = Sparql::SparqlHelper.results_to_query_bindings(results)</tt>
        #
        #results:: hash conforming to SPARQL SELECT structure        
        def Client.results_to_query_bindings(results)
          bindings = []
          
          results["results"]["bindings"].each do |result|
            bindings << result_to_query_binding(result)
          end
          return bindings
        end              
                                
        #Perform a sparql query.
        #
        #sparql:: a valid SPARQL query
        #format:: specific a request format. Usually a media-type, but may be a name for a type, if not using Conneg
        #graphs:: an array of default graphs
        #named_graphs:: an array of named graphs
        def query(sparql, format=nil)          
          headers = {}
          if format != nil            
            headers["Accept"] = format  
          end
          
          response = get( @endpoint, {"query" => sparql}, headers )
          validate_response(response)
          return response.content
        end
        
        #Describe a uri, optionally specifying a form of bounded description
        #
        #uri:: the uri to describe
        #format:: mimetype for results
        #type:: symbol indicating type of description, i.e. +:cbd+, +:scbd+, +:lcbd+, or +:slcbd+
        def describe_uri(uri, type=:cbd)
          template = Sparql::DESCRIPTIONS[type]
          if template == nil
            raise "Unknown description type"
          end
          query = Client.apply_initial_bindings(template, {"uri" => "<#{uri}>"} )
          return describe(query)
        end
        
        #Perform a SPARQL DESCRIBE query.
        #
        #query:: the SPARQL query
        #format:: the preferred response format
        def describe(query)
          response = query(query, "application/json")
          graph = RDF::Graph.new()
          graph.insert( RDF::JSON::Reader.new( StringIO.new( response ) ) )
          return graph                  
        end

        #DESCRIBE multiple resources in a single query. The provided array should contain
        #the uris that are to be described
        #
        #This will generate a query like:
        # DESCRIBE <http://www.example.org> <http://www.example.com> ...
        #
        #uris:: list of the uris to be described
        #format:: the preferred response format. Default is RDF/XML
        def multi_describe(uris)
          query = "DESCRIBE " + uris.map {|u| "<#{u}>" }.join(" ")
          response = query(query, "application/json")
          graph = RDF::Graph.new()
          graph.insert( RDF::JSON::Reader.new( StringIO.new( response ) ) )
          return graph                  
        end
              
        #Perform a SPARQL CONSTRUCT query.
        #
        #query:: the SPARQL query
        #format:: the preferred response format        
        def construct(query)
          response = query(query, "application/json")
          graph = RDF::Graph.new()
          graph.insert( RDF::JSON::Reader.new( StringIO.new( response ) ) )
          return graph                  
        end
        
        #Perform a SPARQL ASK query.
        #
        #query:: the SPARQL query
        #format:: the preferred response format    
        def ask(query)
          json = JSON.parse( query(query, Sparql::SPARQL_RESULTS_JSON) )
          return json["boolean"] == "true"
        end

        #Performs an ASK query on the SPARQL endpoint to test whether there are any statements
        #in the triple store about the specified uri.
        #
        #uri:: the uri to test for
        #sparql_client:: a configured Sparql Client object
        def exists?(uri)
           return ask("ASK { <#{uri}> ?p ?o }")  
        end
                
        #Perform a SPARQL SELECT query.
        #
        #query:: the SPARQL query
        #format:: the preferred response format    
        def select(query)
          return JSON.parse( query(query, Sparql::SPARQL_RESULTS_JSON) )
        end
        
        #Perform a simple SELECT query on an endpoint and return a simple array of values
        #
        #Will request the results using the SPARQL JSON results format, and parse the
        #resulting JSON results. The assumption is that the SELECT query contains a single "column" 
        #of values, which will be returned as an array 
        #
        #Note this will lose any type information, only the value of the bindings are returned 
        #
        #Also note that if row has an empty binding for the selected variable, then this row will
        #be dropped from the resulting array
        #
        #query:: the SPARQL SELECT query
        #sparql_client:: a configured Sparql Client object
        def select_values(query)
           results = select(query)
           v = results["head"]["vars"][0];
           values = [];
           results["results"]["bindings"].each do |binding|
             values << binding[v]["value"] if binding[v]
           end
           return values           
        end
        
        #Perform a simple SELECT query and return the results as a simple array of hashes.
        #Each entry in the array will be a row in the results, and each hash will have a key for 
        #each variable.
        #
        #Note that this will lose any type information, only the value of the bindings are returned
        #
        #Also note that if a row has an empty binding for a given variable, then this variable will 
        #not be presented in the hash for that row.
        #
        #query:: the SPARQL SELECT query
        #sparql_client:: a configured Sparql Client object
        def select_into_array(query)
          results = select(query)
          rows = []
          results["results"]["bindings"].each do |binding|
            row = {}
            binding.each do |key, value|
              row[key] = value["value"]
            end
            rows << row
          end
          return rows
        end
        
        #Perform a simple SELECT query on an endpoint and return a single result
        #
        #Will request the results using the SPARQL JSON results format, and parse the
        #resulting JSON results. The assumption is that the SELECT query returns a single
        #value (i.e single variable, with single binding)
        #
        #Note this will lose any type information, only the value of the binding is returned
        #If additional results are returned, then these are ignored 
        #
        #query:: the SPARQL SELECT query
        #sparql_client:: a configured Sparql Client object                
        def select_single_value(query)
          results = select(query)
          v = results["head"]["vars"][0];
          return results["results"]["bindings"][0][v]["value"]           
        end        
    end   
  
  end
  
end