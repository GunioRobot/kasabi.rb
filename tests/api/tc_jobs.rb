$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'kasabi'
require 'test/unit'
require 'mocha'

class JobsTest < Test::Unit::TestCase

  def test_reset
    resp = HTTP::Message.new_response("http://api.kasabi.com/dataset/test-data/jobs/abc")
    resp.status = 202
    mc = mock()
    mc.expects(:post).with("http://api.kasabi.com/dataset/test-data/jobs",
    {:jobType=>"reset", :startTime=>"2011-06-05-15:35:30Z"},
      {"Content-Type" => "application/x-www-form-urlencoded", "X_KASABI_APIKEY" => "test"} ).returns(
        resp )

    dataset = Kasabi::Jobs::Client.new("http://api.kasabi.com/dataset/test-data/jobs",
      { :apikey => "test", :client => mc })
    id = dataset.submit_job("reset", "2011-06-05-15:35:30Z")
    assert_equal("http://api.kasabi.com/dataset/test-data/jobs/abc", id)
  end

end