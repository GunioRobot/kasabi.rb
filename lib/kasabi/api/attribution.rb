module Kasabi

  class Attribution < BaseClient

    #Initialize the attribution client to work with a specific endpoint
    #
    # The _options_ hash can contain the following values:
    # * *:apikey*: required. apikey authorized to use the API
    # * *:client*: HTTPClient object instance
    def initialize(endpoint, options={})
      super(endpoint, options)
    end

    def get_attribution()
      response = get(@endpoint)
      validate_response(response)
      return JSON.parse( response.content )
    end

  end
end