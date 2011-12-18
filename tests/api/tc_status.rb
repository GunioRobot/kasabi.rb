$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class StatusTest < Test::Unit::TestCase

  STATUS = <<-EOL
{
  "status": "published",
  "storageMode": "read-write"
}
EOL

  STATUS_READ_ONLY = <<-EOL
{
  "status": "draft",
  "storageMode": "read-only"
}
EOL

  def test_get
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-data/status",
      nil, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( STATUS ))

    client = Kasabi::Status.new("http://api.kasabi.com/api/test-data/status",
      :apikey=>"test-key", :client=>mc)

    status = client.get_status
    assert_not_nil(status)
    assert_equal("published", status["status"])
    assert_equal("read-write", status["storageMode"])

  end

  def test_writeable
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-data/status",
      nil, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( STATUS ))

    client = Kasabi::Status.new("http://api.kasabi.com/api/test-data/status",
      :apikey=>"test-key", :client=>mc)

    assert_equal(true, client.writeable?)

    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-data/status",
      nil, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( STATUS_READ_ONLY ))

    client = Kasabi::Status.new("http://api.kasabi.com/api/test-data/status",
      :apikey=>"test-key", :client=>mc)

    assert_equal(false, client.writeable?)
  end

  def test_published
    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-data/status",
      nil, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( STATUS ))

    client = Kasabi::Status.new("http://api.kasabi.com/api/test-data/status",
      :apikey=>"test-key", :client=>mc)

    assert_equal(true, client.published?)

    mc = mock()
    mc.expects(:get).with("http://api.kasabi.com/api/test-data/status",
      nil, {"X_KASABI_APIKEY" => "test-key"} ).returns(
    HTTP::Message.new_response( STATUS_READ_ONLY ))

    client = Kasabi::Status.new("http://api.kasabi.com/api/test-data/status",
      :apikey=>"test-key", :client=>mc)

    assert_equal(false, client.published?)

  end
end