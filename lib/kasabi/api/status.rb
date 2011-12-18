module Kasabi

  class Status < BaseClient
    #Initialize the store client to work with a specific endpoint
    #
    # The _options_ hash can contain the following values:
    # * *:apikey*: required. apikey authorized to use the API
    # * *:client*: HTTPClient object instance
    def initialize(endpoint, options={})
      super(endpoint, options)
    end

    def get_status()
      response = get(@endpoint)
      validate_response(response)
      return JSON.parse( response.content )
    end

    def status
      return get_status()["status"]
    end

    def storage_mode
      return get_status()["storageMode"]
    end

    def published?
      return status() == "published"
    end

    def writeable?
      return storage_mode() == "read-write"
    end

  end
end