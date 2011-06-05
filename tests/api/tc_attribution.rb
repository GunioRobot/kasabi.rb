$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class AttributionTest < Test::Unit::TestCase
  
  ATTRIBUTION = <<-EOL 
{
 "name": "name",
 "homepage": "homepage",
 "source": "source",
 "logo": "logo"
}
EOL

  def test_get
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-data/attribution", 
      nil, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( ATTRIBUTION ))
      
    client = Kasabi::Attribution.new("http://api.kasabi.com/api/test-data/attribution", 
      :apikey=>"test-key", :client=>mc)
      
    attribution = client.get_attribution
    assert_not_nil(attribution)
    
  end
  
end