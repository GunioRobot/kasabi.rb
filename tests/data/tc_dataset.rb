$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class DatasetTest < Test::Unit::TestCase
 
  def setup
    @metadata = File.read(File.join(File.dirname(__FILE__), "dataset.json"))
  end
  
  def test_read_metadata    
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/dataset/test-data", nil, {"Accept" => "application/json", "X_KASABI_API_KEY" => "test"} ).returns(
    HTTP::Message.new_response( @metadata ))
    
    dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
    metadata = dataset.metadata
    assert_not_nil(metadata)    
  end
  
  def test_read_properties
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/dataset/test-data", 
    nil, {"Accept" => "application/json", "X_KASABI_API_KEY" => "test"} ).returns(
    HTTP::Message.new_response( @metadata ))
    
    dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
    assert_equal("Test Data", dataset.title)
    assert_equal("The Test Data dataset", dataset.description)
    assert_equal("http://ldodds.kasabi.com/dataset/test-data", dataset.homepage)
    assert_equal("http://api.kasabi.com/api/test-sparql", dataset.sparql_endpoint)
    assert_equal("http://api.kasabi.com/api/test-lookup", dataset.lookup_api)
    assert_equal("http://api.kasabi.com/api/test-search", dataset.search_api)
    
    assert_equal("http://api.kasabi.com/api/test-sparql", dataset.sparql_client.endpoint)
    assert_equal("http://api.kasabi.com/api/test-lookup", dataset.lookup_api_client.endpoint)
    assert_equal("http://api.kasabi.com/api/test-search", dataset.search_api_client.endpoint)
    
  end
  
  def test_store_data
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "application/rdf+xml", "X_KASABI_API_KEY" => "test"} ).returns( resp )
     dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
     id = dataset.store_data("data")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end

  def test_store_data_as_turtle
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202    
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "text/turtle", "X_KASABI_API_KEY" => "test"} ).returns( resp )
     dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
     id = dataset.store_data("data", "text/turtle")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end

  def test_store_file
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "application/rdf+xml", "X_KASABI_API_KEY" => "test"} ).returns( resp )
     io = StringIO.new("data")
         
     dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
     id = dataset.store_file(io)
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
     assert_equal(true, io.closed?)
  end  

  def test_store_uri
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       {"data_uri" => "http://www.example.org"}, {"Content-Type" => "application/rdf+xml", "X_KASABI_API_KEY" => "test"} ).returns( resp )
     dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
     id = dataset.store_uri("http://www.example.org")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end
  
  def test_applied?
    resp = HTTP::Message.new_response("{ 'Status' => 'Applied' }")
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/dataset/test-data/changes/1", nil, {"Content-Type" => "application/json"})
    dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
    assert_equal(true, dataset.applied?("http://api.kasabi.com/dataset/test-data/changes/1"))
  end  
  
end