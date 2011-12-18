module Kasabi

  module Storage

    class Client < Kasabi::BaseClient

      #Initialize the store client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end

      # Store the contents of a File (or any IO stream) in the store associated with this dataset
      # The client does not support streaming submissions of data, so the stream will be fully read before data is submitted to the platform
      # file:: an IO object
      # content_type:: mimetype of RDF serialization
      def store_file(file, content_type="application/rdf+xml")
        data = file.read()
        file.close()
        return store_data(data, content_type)
      end

      #Store triples contained in the provided string
      def store_data(data, content_type="application/rdf+xml")
        response = post(endpoint, data, {"Content-Type" => content_type } )
        if response.status != 202
          raise "Unable to perform request. Status: #{response.status}. Message: #{response.content}"
        end
        return response.content
      end

      def store_uri(uri, content_type="application/rdf+xml")
        response = post(endpoint, {"data_uri" => uri }, {"Content-Type" => content_type } )
        if response.status != 202
          raise "Unable to perform request. Status: #{response.status}. Message: #{response.content}"
        end
        return response.content
      end

      def apply_changeset(cs)
        response = post(endpoint, cs, {"Content-Type" => "application/vnd.talis.changeset+xml"} )
        if response.status != 202
          raise "Unable to apply changeset. Status: #{response.status}. Message: #{response.content}"
        end
        return response.content
      end

      def applied?(update_uri)
        response = get( update_uri, nil, {"Content-Type" => "application/json"} )
        if response.status != 200
            raise "Unable to determine update status. Status: #{response.status}. Message: #{response.content}"
        end
        json = JSON.parse(response.content)
        return json["status"] && json["status"] == "applied"
      end

    end

  end
end