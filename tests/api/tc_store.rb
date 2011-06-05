$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class StoreTest < Test::Unit::TestCase
  
  def test_store_data
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "application/rdf+xml", "X_KASABI_APIKEY" => "test"} ).returns( resp )
     dataset = Kasabi::Storage::Client.new("http://api.kasabi.com/dataset/test-data/store", { :apikey => "test", :client => mc })
     id = dataset.store_data("data")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end

  def test_store_data_as_turtle
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202    
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "text/turtle", "X_KASABI_APIKEY" => "test"} ).returns( resp )
     dataset = Kasabi::Storage::Client.new("http://api.kasabi.com/dataset/test-data/store", { :apikey => "test", :client => mc })
     id = dataset.store_data("data", "text/turtle")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end

  def test_apply_changeset
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "application/vnd.talis.changeset+xml", "X_KASABI_APIKEY" => "test"} ).returns( resp )
     dataset = Kasabi::Storage::Client.new("http://api.kasabi.com/dataset/test-data/store", { :apikey => "test", :client => mc })
     id = dataset.apply_changeset("data")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end
    
  def test_store_file
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       "data", {"Content-Type" => "application/rdf+xml", "X_KASABI_APIKEY" => "test"} ).returns( resp )
     io = StringIO.new("data")
         
     dataset = Kasabi::Storage::Client.new("http://api.kasabi.com/dataset/test-data/store", { :apikey => "test", :client => mc })
     id = dataset.store_file(io)
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
     assert_equal(true, io.closed?)
  end  

  def test_store_uri
     resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/changes/1")
     resp.status = 202
     mc = mock()
     mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/store", 
       {"data_uri" => "http://www.example.org"}, {"Content-Type" => "application/rdf+xml", "X_KASABI_APIKEY" => "test"} ).returns( resp )
     dataset = Kasabi::Storage::Client.new("http://api.kasabi.com/dataset/test-data/store", { :apikey => "test", :client => mc })
     id = dataset.store_uri("http://www.example.org")
     assert_equal("http://api.kasabi.com/dataset/test-data/changes/1", id)
  end
  
  def test_applied?
    resp = HTTP::Message.new_response("{ \"status\": \"applied\" }")
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/dataset/test-data/changes/1", nil, 
      {"Content-Type" => "application/json", "X_KASABI_APIKEY" => "test"}).returns(resp)
    dataset = Kasabi::Storage::Client.new("http://api.kasabi.com/dataset/test-data/store", { :apikey => "test", :client => mc })
    assert_equal(true, dataset.applied?("http://api.kasabi.com/dataset/test-data/changes/1"))
  end  
    
end