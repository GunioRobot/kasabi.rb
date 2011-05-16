$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class LookupTest < Test::Unit::TestCase

  def test_describe_with_json    
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-lookup", 
      {:about => "http://www.example.org", :output=>"json"}, {"X_KASABI_API_KEY" => "test-key"} ).returns(
    HTTP::Message.new_response("{}"))
      
    client = Kasabi::Lookup::Client.new("http://api.kasabi.com/api/test-lookup", 
      :apikey=>"test-key", :client=>mc)
      
    response = client.lookup("http://www.example.org")
    assert_not_nil( response )
  end
    
end