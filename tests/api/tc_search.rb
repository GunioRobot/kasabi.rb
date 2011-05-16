$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class SearchTest < Test::Unit::TestCase
  
  def test_simple_search
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-search/search", {:query => "lunar", :output=>"json"}, {"X_KASABI_API_KEY" => "test-key"}).returns(
      HTTP::Message.new_response("{}") )
    
    client = Kasabi::Search::Client.new("http://api.kasabi.com/api/test-search", :apikey=>"test-key", :client=>mc)
    response = client.search("lunar")  
    assert_not_nil(response)     
  end
  
  def test_parameter_search
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-search/search", 
      {:query => "lunar", :max => "50", :offset => "10", :output=>"json"}, {"X_KASABI_API_KEY" => "test-key"}).returns(
    HTTP::Message.new_response("{}") )
    
    
    client = Kasabi::Search::Client.new("http://api.kasabi.com/api/test-search", :apikey=>"test-key", :client=>mc)
    response = client.search("lunar", {:max => "50", :offset => "10"}) 
    assert_not_nil(response)         
  end
  
end