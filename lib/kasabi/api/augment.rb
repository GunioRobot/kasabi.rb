module Kasabi

  module Augment

    #Client for working with Kasabi Augmentation APIs
    class Client < BaseClient

      #Initialize the client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end

      # Augment an RSS feed that can be retrieved from the specified URL, against data in this store
      #
      # uri:: the URL for the RSS 1.0 feed
      def augment_uri(uri)
        response = get(@endpoint, {"data-uri" => uri})
        validate_response(response)

        return response.content
      end

      # Augment data using POSTing it to the API
      #
      # Currently this is limited to RSS 1.0 feeds
      #
      # data:: a String containing the data to augment
      def augment(data, content_type="application/rss+xml")
      response = post(@endpoint, data, {"Content-Type" => "application/rss+xml"})
        validate_response(response)
        return response.content
      end

    end
  end
end