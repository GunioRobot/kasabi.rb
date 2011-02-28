$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class SparqlTest < Test::Unit::TestCase
  
  def test_simple_query
    
    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", {"query" => "SPARQL"}, {})
    
    sparql_client = Kasabi::Sparql::SparqlClient.new("http://www.example.org/sparql", 
    {:client => mc})
    sparql_client.query("SPARQL")
        
  end

  def test_query_with_default_graph

    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", {"query" => "SPARQL", "default-graph-uri" => ["http://www.example.com"]}, {})
    
    sparql_client = Kasabi::Sparql::SparqlClient.new("http://www.example.org/sparql", {:client => mc})
    sparql_client.add_default_graph("http://www.example.com")
    sparql_client.query("SPARQL")
        
  end

  def test_query_with_named_graph

    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", {"query" => "SPARQL", "named-graph-uri" => ["http://www.example.com"]}, {})
    
    sparql_client = Kasabi::Sparql::SparqlClient.new("http://www.example.org/sparql", {:client => mc})
    sparql_client.add_named_graph("http://www.example.com")
    sparql_client.query("SPARQL")
        
  end
  
  def test_query_with_both_graphs

    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", {"query" => "SPARQL", "named-graph-uri" => ["http://www.example.com"], "default-graph-uri" => ["http://www.example.org"]}, {})
    
    sparql_client = Kasabi::Sparql::SparqlClient.new("http://www.example.org/sparql", {:client => mc})
    sparql_client.add_named_graph("http://www.example.com")
    sparql_client.add_default_graph("http://www.example.org")
    sparql_client.query("SPARQL")
        
  end
            
  def test_sparql_with_mimetype
    mc = mock()
    mc.expects(:get).with("http://www.example.org/sparql", {"query" => "SPARQL"}, {"Accept" => "application/sparql-results+xml"})
    
    sparql_client = Kasabi::Sparql::SparqlClient.new("http://www.example.org/sparql", {:client => mc})
    sparql_client.query("SPARQL", "application/sparql-results+xml")
     
  end
         
  def test_ask
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", {"query" => "SPARQL"}, {"Accept" => "application/sparql-results+json"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.ask("SPARQL")
    assert_equal("RESULTS", response.content)          
  end
  
  def test_store_sparql_select
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", {"query" => "SPARQL"}, {"Accept" => "application/sparql-results+json"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.select("SPARQL")
    assert_equal("RESULTS", response.content)          
  end  
      
  def test_construct
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", {"query" => "SPARQL"}, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.construct("SPARQL")
    assert_equal("RESULTS", response.content)          
  end  

  def test_describe
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", {"query" => "SPARQL"}, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.describe("SPARQL")
    assert_equal("RESULTS", response.content)          
  end
  
  def test_multi_describe
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", 
      {"query" => "DESCRIBE <http://www.example.org> <http://www.example.com>"}, 
        {"Accept" => "application/rdf+xml"} ).returns( HTTP::Message.new_response("RESULTS"))

    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    uris = []
    uris << "http://www.example.org"
    uris << "http://www.example.com"
    response = client.multi_describe(uris)
    assert_equal("RESULTS", response.content)
                            
  end
 
  def test_describe_uri
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", {"query" => "DESCRIBE <http://www.example.org>"}, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.describe_uri("http://www.example.org")
    assert_equal("RESULTS", response.content)
  end

  def test_describe_uri_using_cbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", {"query" => "DESCRIBE <http://www.example.org>"}, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.describe_uri("http://www.example.org", "application/rdf+xml", :cbd)
    assert_equal("RESULTS", response.content)
  end

  def test_describe_uri_using_lcbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", anything, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.describe_uri("http://www.example.org", "application/rdf+xml", :lcbd)
    assert_equal("RESULTS", response.content)
  end  

  def test_describe_uri_using_scbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", anything, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.describe_uri("http://www.example.org", "application/rdf+xml", :scbd)
    assert_equal("RESULTS", response.content)
  end  
          
  def test_describe_uri_using_slcbd
    mc = mock()
    mc.expects(:get).with("http://api.talis.com/stores/testing/services/sparql", anything, {"Accept" => "application/rdf+xml"} ).returns(
      HTTP::Message.new_response("RESULTS"))
    
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    response = client.describe_uri("http://www.example.org", "application/rdf+xml", :slcbd)
    assert_equal("RESULTS", response.content)
  end  

  def test_describe_uri_using_unknown
    mc = mock()
        
    client = Kasabi::Sparql::SparqlClient.new("http://api.talis.com/stores/testing/services/sparql", {:client => mc})
    assert_raises RuntimeError do
        response = client.describe_uri("http://www.example.org", "application/rdf+xml", :unknown)
    end
    
  end  
    
end