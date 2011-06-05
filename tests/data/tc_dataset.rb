$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class DatasetTest < Test::Unit::TestCase
 
  def setup
    @metadata = File.read(File.join(File.dirname(__FILE__), "dataset.json"))
  end
  
  def test_constructor
    dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test" })
    assert_equal("http://api.kasabi.com/dataset/test-data", dataset.endpoint)
    assert_equal("http://data.kasabi.com/dataset/test-data", dataset.uri)

    dataset = Kasabi::Dataset.new("http://data.kasabi.com/dataset/test-data", { :apikey => "test" })
    assert_equal("http://api.kasabi.com/dataset/test-data", dataset.endpoint)
    assert_equal("http://data.kasabi.com/dataset/test-data", dataset.uri)

    dataset = Kasabi::Dataset.new("http://www.kasabi.com/dataset/test-data", { :apikey => "test" })
    assert_equal("http://api.kasabi.com/dataset/test-data", dataset.endpoint)
    assert_equal("http://data.kasabi.com/dataset/test-data", dataset.uri)
      
  end
  
  def test_read_metadata    
    mc = mock()
    mc.expects(:get).with("http://data.kasabi.com/dataset/test-data", nil, {"Accept" => "application/json", "X_KASABI_APIKEY" => "test"} ).returns(
    HTTP::Message.new_response( @metadata ))
    
    dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
    metadata = dataset.metadata
    assert_not_nil(metadata)    
  end
  
  def test_read_properties
    mc = mock()
    mc.expects(:get).with("http://data.kasabi.com/dataset/test-data", 
    nil, {"Accept" => "application/json", "X_KASABI_APIKEY" => "test"} ).returns(
    HTTP::Message.new_response( @metadata ))
    
    dataset = Kasabi::Dataset.new("http://api.kasabi.com/dataset/test-data", { :apikey => "test", :client => mc })
    assert_equal("Test Data", dataset.title)
    assert_equal("The Test Data dataset", dataset.description)
    assert_equal("http://ldodds.kasabi.com/dataset/test-data", dataset.homepage)
    assert_equal("http://api.kasabi.com/api/test-sparql", dataset.sparql_endpoint)
    assert_equal("http://api.kasabi.com/api/test-lookup", dataset.lookup_api)
    assert_equal("http://api.kasabi.com/api/test-search", dataset.search_api)
    assert_equal("http://api.kasabi.com/api/test-recon", dataset.reconciliation_api)
    assert_equal("http://api.kasabi.com/api/test-augment", dataset.augmentation_api)
    
    assert_equal("http://api.kasabi.com/api/test-sparql", dataset.sparql_endpoint_client.endpoint)
    assert_equal("http://api.kasabi.com/api/test-lookup", dataset.lookup_api_client.endpoint)
    assert_equal("http://api.kasabi.com/api/test-search", dataset.search_api_client.endpoint)
    
  end
    
end