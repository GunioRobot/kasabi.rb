$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class AugmentTest < Test::Unit::TestCase

  def test_augment_uri
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-augment-api", {"data-uri" => "http://www.example.org/index.rss"},
    {"X_KASABI_APIKEY" => "test-key"}).returns(
    HTTP::Message.new_response("OK") )

    client = Kasabi::Augment::Client.new( "http://api.kasabi.com/api/test-augment-api", :apikey=>"test-key", :client=>mc)
    response = client.augment_uri("http://www.example.org/index.rss")
    assert_equal("OK", response)
  end

  def test_augment
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/api/test-augment-api", "data",
       {"Content-Type" => "application/rss+xml", "X_KASABI_APIKEY" => "test-key"}).returns(
    HTTP::Message.new_response("OK") )

    client = Kasabi::Augment::Client.new( "http://api.kasabi.com/api/test-augment-api", {:apikey=>"test-key", :client=>mc})
    response = client.augment("data")
    assert_equal("OK", response)
  end

end