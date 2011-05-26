$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class LookupTest < Test::Unit::TestCase

  def setup
    @json = File.read(File.join(File.dirname(__FILE__), "apollo-6.json"))
  end
  
  def test_describe_with_json    
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-lookup", 
      {:about => "http://www.example.org", :output=>"json"}, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( @json ))
      
    client = Kasabi::Lookup::Client.new("http://api.kasabi.com/api/test-lookup", 
      :apikey=>"test-key", :client=>mc)
      
    graph = client.lookup("http://www.example.org")
    assert_not_nil( graph )
    assert_equal(12, graph.count )
  end
    
end