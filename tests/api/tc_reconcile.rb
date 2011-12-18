$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'

require 'test/unit'
require 'kasabi'
require 'mocha'

class ClientTest < Test::Unit::TestCase

  def test_make_query_basic()

    query = Kasabi::Reconcile::Client.make_query("train")

    assert_equal("train", query[:query])
    assert_equal(3, query[:limit])
    assert_equal(:any, query[:type_strict])
    assert_equal(nil, query[:type])
    assert_equal(nil, query[:properties])
  end

  def test_make_queries()
    queries = Kasabi::Reconcile::Client.make_queries( ["train", "car", "boat"] )
    assert_equal(3, queries.size)

    ["train", "car", "boat"].each_with_index do |label, i|
      assert_equal(label, queries[i][:query])
      assert_equal(3, queries[i][:limit])
      assert_equal(:any, queries[i][:type_strict])
      assert_equal(nil, queries[i][:type])
      assert_equal(nil, queries[i][:properties])
    end

  end

  def test_make_query_with_limit()

    query = Kasabi::Reconcile::Client.make_query("train", 10)

    assert_equal("train", query[:query])
    assert_equal(10, query[:limit])
  end

  def test_make_query_with_type()

    query = Kasabi::Reconcile::Client.make_query("train", 3, :any, "http://example.org/type")

    assert_equal("train", query[:query])
    assert_equal(3, query[:limit])
    assert_equal(:any, query[:type_strict])
    assert_equal("http://example.org/type", query[:type])
  end

  def test_make_query_with_type_array()

    query = Kasabi::Reconcile::Client.make_query("train", 3, :any,
        ["http://example.org/type"])

    assert_equal("train", query[:query])
    assert_equal(3, query[:limit])
    assert_equal(:any, query[:type_strict])
    assert_equal(["http://example.org/type"], query[:type])
  end

  def test_make_property_filter()
    assert_raises RuntimeError do
      filter = Kasabi::Reconcile::Client.make_property_filter("Ivor")
    end
  end

  def test_make_property_filter_with_name()
    filter = Kasabi::Reconcile::Client.make_property_filter("Ivor", "name")
    assert_not_nil(filter)
    assert_equal("Ivor", filter[:v])
    assert_equal("name", filter[:p])
    assert_equal(nil, filter[:pid])
  end

  def test_make_property_filter_with_id()
    filter = Kasabi::Reconcile::Client.make_property_filter("Ivor", nil, "http://xmlns.com/foaf/0.1/name")
    assert_not_nil(filter)
    assert_equal("Ivor", filter[:v])
    assert_equal(nil, filter[:p])
    assert_equal("http://xmlns.com/foaf/0.1/name", filter[:pid])
  end

  def test_reconcile_label()

    mc = mock();
    mc.expects(:get).with("http://api.kasabi.com/api/test-reconcile",
        {"query" => {:query => "test", :limit => 3, :type_strict => :any}.to_json }, {"X_KASABI_APIKEY" => "test-key"}
      ).returns( HTTP::Message.new_response("{}") )

    reconciler = Kasabi::Reconcile::Client.new("http://api.kasabi.com/api/test-reconcile", :apikey=>"test-key", :client=>mc)
    result = reconciler.reconcile_label("test")
    assert_equal(nil, result)
  end

  def test_reconcile_label_with_result()

    resp = { "result" => [
         {
           "id" => "123",
           "score" => 1.0,
           "match" => true,
           "label" => "test"
         }
      ] }

    mc = mock();
    mc.expects(:get).with("http://api.kasabi.com/api/test-reconcile",
    {"query" => {:query => "test", :limit => 3, :type_strict => :any}.to_json }, {"X_KASABI_APIKEY" => "test-key"}
      ).returns( HTTP::Message.new_response( resp.to_json ) )

    reconciler = Kasabi::Reconcile::Client.new("http://api.kasabi.com/api/test-reconcile", :apikey=>"test-key", :client=>mc)
    result = reconciler.reconcile_label("test")
    assert_not_nil(result)
    assert_equal(1, result.size)
    assert_equal("123", result[0]["id"])
  end

  def test_reconcile_label_with_block()

    resp = { "result" => [
         {
           "id" => "123",
           "score" => 1.0,
           "match" => true,
           "label" => "test"
         }
      ] }

    mc = mock();
    mc.expects(:get).with("http://api.kasabi.com/api/test-reconcile",
        {"query" => {:query => "test", :limit => 3, :type_strict => :any}.to_json },
          {"X_KASABI_APIKEY" => "test-key"}
      ).returns( HTTP::Message.new_response( resp.to_json ) )

    reconciler = Kasabi::Reconcile::Client.new("http://api.kasabi.com/api/test-reconcile", :apikey=>"test-key", :client=>mc)
    count = 0
    result = reconciler.reconcile_label("test") do |r, index|
      count = count + 1
    end

    assert_equal(1, count)
    assert_not_nil(result)
    assert_equal(1, result.size)
  end

  def test_reconcile_all_with_block()

    resp = { "q0" => { "result" => [
                       {
                         "id" => "123",
                         "score" => 1.0,
                         "match" => true,
                         "label" => "test"
                       }
                      ]
            }
    }

    mc = mock();
    expected_query = { "q0" => { :query => "test", :limit => 3, :type_strict => :any} }
    mc.expects(:get).with("http://api.kasabi.com/api/test-reconcile",
    {"queries" => expected_query.to_json }, {"X_KASABI_APIKEY" => "test-key"}
      ).returns( HTTP::Message.new_response( resp.to_json ) )

    reconciler = Kasabi::Reconcile::Client.new("http://api.kasabi.com/api/test-reconcile", :apikey=>"test-key", :client=>mc)
    count = 0
    queries = Kasabi::Reconcile::Client.make_queries(["test"])
    result = reconciler.reconcile_all(queries) do |r, index, query|
      count = count + 1
    end

    assert_equal(1, count)
    assert_not_nil(result)
    assert_equal(1, result.size)
  end
end