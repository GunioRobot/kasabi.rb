module Kasabi

  module Lookup

    class Client < BaseClient

      #Initialize the client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end

      def lookup(uri)
        response = get(@endpoint, {:about => uri, :output=>"json"} )
        validate_response(response)
        graph = RDF::Graph.new()
        graph.insert( RDF::JSON::Reader.new( StringIO.new( response.content ) ) )
        return graph
      end

    end

  end
end