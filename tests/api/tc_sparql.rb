$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class SparqlTest < Test::Unit::TestCase

  SELECT_QUERY = <<-EOL
SELECT ?name WHERE { ?s rdfs:label ?name. }
  EOL

  ASK_QUERY = <<-EOL
ASK WHERE { ?s rdfs:label "Something". }
  EOL
      
  DESCRIBE_QUERY = <<-EOL
DESCRIBE <http://www.example.org>
  EOL
  
  CONSTRUCT_QUERY = <<-EOL
CONSTRUCT { ?s ?p ?o. } WHERE { ?s ?p ?o. } 
  EOL
    
  RESULTS = <<-EOL
  {  
   "head": {  "vars": [ "name" ]  } ,  
    
   "results": {    
        "bindings": [     
            {  "name": { "type": "literal" , "value": "Apollo 11 Command and Service Module (CSM)" }
            } ,     
           {   "name": { "type": "literal" , "value": "Apollo 11 SIVB" }
           } ,      
           {   "name": { "type": "literal" , "value": "Apollo 11 Lunar Module / EASEP" }
           }    
        ]  
    }
  }  
  EOL
  
  RESULTS_NO_BINDING = <<-EOL
  {  
   "head": {  "vars": [ "name" ]  } ,  
    
   "results": {    
        "bindings": [     
           { } ,     
           {   "name": { "type": "literal" , "value": "Apollo 11 SIVB" }
           }   
        ]  
    }
  }  
  EOL
    
  ASK_RESULTS = <<-EOL
  {    
    "head": {},
    "boolean": "true"
  }
  EOL

  RDF_JSON_RESULTS = <<-EOL
  {
    "http://www.example.org" : {
      "http://www.example.org/ns/resource" : [ { "value" : "http://www.example.org/page", "type" : "uri" } ]
    }
  }
  EOL
      
  RDF_JSON = <<-EOL
  {  
   "head": {  "vars": [ "name" ]  } ,  
    
   "results": {    
        "bindings": [     
            {  "name": { "type": "literal" , "value": "Apollo 11 Command and Service Module (CSM)" },
               "uri": { "type": "uri" , "value": "http://nasa.dataincubator.org/spacecraft/12345" },
               "mass": { "type": "literal" , "value": "5000.5", "datatype" : "http://www.w3.org/2001/XMLSchema#float" }
            } ,     
           {   "name": { "type": "literal" , "value": "Apollo 11 SIVB" },
               "uri": { "type": "uri" , "value": "http://nasa.dataincubator.org/spacecraft/12345" }
           }    
        ]  
    }
  }  
  EOL
  
    
  def setup
    @json = File.read(File.join(File.dirname(__FILE__), "apollo-6.json"))
  end
    
  def test_simple_query    
    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", 
      {"query" => "SPARQL"}, 
      {"X_KASABI_APIKEY" => "test-key"}).returns( 
        HTTP::Message.new_response("RESULTS") )
    
    sparql_client = Kasabi::Sparql::Client.new("http://www.example.org/sparql", 
    {:apikey => "test-key", :client => mc})
    response = sparql_client.query("SPARQL")
    assert_equal("RESULTS", response)
  end

  def test_query_with_error    
    mc = mock()
    resp = HTTP::Message.new_response("Error")
    resp.status = 500    
    mc.expects(:get).with("http://www.example.org/sparql", 
      {"query" => SELECT_QUERY}, 
      {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"}).returns( resp )
    
    client = Kasabi::Sparql::Client.new("http://www.example.org/sparql", 
      {:apikey => "test-key", :client => mc})
    assert_raises RuntimeError do
      client.select(SELECT_QUERY)
    end

  end    
  def test_query_with_mimetype
    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", 
      {"query" => "SPARQL"}, 
        {"X_KASABI_APIKEY" => "test-key", "Accept" => "application/sparql-results+xml"}).returns(
          HTTP::Message.new_response("RESULTS"))
    
    sparql_client = Kasabi::Sparql::Client.new("http://www.example.org/sparql", {:client => mc, :apikey=>"test-key"})
    response = sparql_client.query("SPARQL", "application/sparql-results+xml")
    assert_equal("RESULTS", response)     
  end
         
  def test_ask
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "ASK"}, 
        {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response("{ \"boolean\": \"true\" }"))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    response = client.ask("ASK")
    assert_equal(true, response)          
  end

  def test_exists
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "ASK { <http://www.example.org> ?p ?o }"}, 
        {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response("{ \"boolean\": \"true\" }"))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    response = client.exists?("http://www.example.org")
    assert_equal(true, response)          
  end
    
  def test_select
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "SPARQL"}, 
        {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response("{}"))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    response = client.select("SPARQL")
    assert_not_nil(response)          
  end  
      
  def test_construct
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "SPARQL"}, 
        {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response( @json ))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.construct("SPARQL")
    assert_not_nil( graph )
    assert_equal(12, graph.count )          
  end  

  def test_describe
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "SPARQL"}, 
        {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response(@json))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.describe("SPARQL")
    assert_not_nil( graph )
    assert_equal(12, graph.count )          
  end
  
  def test_multi_describe
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "DESCRIBE <http://www.example.org> <http://www.example.com>"}, 
        {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns( 
          HTTP::Message.new_response(@json))

    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    uris = []
    uris << "http://www.example.org"
    uris << "http://www.example.com"
    graph = client.multi_describe(uris)
    assert_not_nil( graph )
    assert_equal(12, graph.count )          
  end
 
  def test_describe_uri
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "DESCRIBE <http://www.example.org>"},
        {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response(@json))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.describe_uri("http://www.example.org")
    assert_not_nil( graph )
    assert_equal(12, graph.count )          
  end

  def test_describe_uri_using_cbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "DESCRIBE <http://www.example.org>"}, 
        {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response(@json))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.describe_uri("http://www.example.org", :cbd)
    assert_not_nil( graph )
    assert_equal(12, graph.count )          
  end

  def test_describe_uri_using_lcbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      anything, 
      {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
        HTTP::Message.new_response(@json))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.describe_uri("http://www.example.org", :lcbd)
    assert_not_nil( graph )
    assert_equal(12, graph.count )          

  end  

  def test_describe_uri_using_scbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      anything, 
      {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
        HTTP::Message.new_response(@json))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.describe_uri("http://www.example.org", :scbd)
    assert_not_nil( graph )
    assert_equal(12, graph.count )          
  end  
          
  def test_describe_uri_using_slcbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      anything, 
      {"Accept" => "application/json", "X_KASABI_APIKEY" => "test-key"} ).returns(
        HTTP::Message.new_response(@json))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    graph = client.describe_uri("http://www.example.org", :slcbd)
    assert_not_nil( graph )
    assert_equal(12, graph.count )          

  end  

  def test_describe_uri_using_unknown
    mc = mock()
        
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", 
      {"X_KASABI_APIKEY" => "test-key", :client => mc})
        
    assert_raises RuntimeError do
        response = client.describe_uri("http://www.example.org", :unknown)
    end
    
  end  
   
  def test_apply_initial_bindings
      query = "SELECT ?p ?o WHERE { ?s ?p ?o }"
      values = { "s" => "<http://www.example.org>" }
        
      bound = Kasabi::Sparql::Client.apply_initial_bindings(query, values)
      assert_not_nil(bound)
      assert_equal( "SELECT ?p ?o WHERE { <http://www.example.org> ?p ?o }", bound )   
  end

  def test_apply_initial_bindings_with_dollars
      query = "SELECT $p $o WHERE { $s $p $o }"
      values = { "s" => "<http://www.example.org>" }
        
      bound = Kasabi::Sparql::Client.apply_initial_bindings(query, values)
      assert_not_nil(bound)
      assert_equal( "SELECT $p $o WHERE { <http://www.example.org> $p $o }", bound )   
  end
  
  def test_apply_initial_bindings_with_literal
      query = "SELECT ?s WHERE { ?s ?p ?o }"
      values = { "o" => "'some value'" }
        
      bound = Kasabi::Sparql::Client.apply_initial_bindings(query, values)
      assert_not_nil(bound)
      assert_equal( "SELECT ?s WHERE { ?s ?p 'some value' }", bound )   
  end   
  
  def test_binding_to_hash
      json = JSON.parse(RDF_JSON)
      binding = json["results"]["bindings"][0]
      
      hash = Kasabi::Sparql::Client.result_to_query_binding(binding)
      assert_equal(3, hash.size)
      assert_equal("\"Apollo 11 Command and Service Module (CSM)\"", hash["name"])
      assert_equal("<http://nasa.dataincubator.org/spacecraft/12345>", hash["uri"])
      assert_equal("\"5000.5\"^^http://www.w3.org/2001/XMLSchema#float", hash["mass"])        
  end
    
  def test_results_to_bindings
      json = JSON.parse(RDF_JSON)           
      bindings = Kasabi::Sparql::Client.results_to_query_bindings(json)
      assert_equal(2, bindings.size)
      hash = bindings[0]
      assert_equal("\"Apollo 11 Command and Service Module (CSM)\"", hash["name"])
      assert_equal("<http://nasa.dataincubator.org/spacecraft/12345>", hash["uri"])
      assert_equal("\"5000.5\"^^http://www.w3.org/2001/XMLSchema#float", hash["mass"])        
  end    
  
  def test_select_values
      mc = mock()
      mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
        {"query" => SELECT_QUERY}, 
          {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"} ).returns(
            HTTP::Message.new_response(RESULTS))
      
      client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
      results = client.select_values(SELECT_QUERY)
      assert_not_nil( results )
      assert_equal( 3, results.length )          
  end        
  
  def test_select_values_with_empty_binding
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => SELECT_QUERY}, 
        {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response(RESULTS_NO_BINDING))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    results = client.select_values(SELECT_QUERY)
    assert_not_nil( results )
    assert_equal( 1, results.length )          
  end
    
  def test_select_single_value
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => SELECT_QUERY}, 
        {"Accept" => "application/sparql-results+json", "X_KASABI_APIKEY" => "test-key"} ).returns(
          HTTP::Message.new_response(RESULTS))
    
    client = Kasabi::Sparql::Client.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc, :apikey=>"test-key"})
    result = client.select_single_value(SELECT_QUERY)
    assert_equal( "Apollo 11 Command and Service Module (CSM)", result  )
  end        
   
end