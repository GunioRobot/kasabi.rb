module Kasabi
  
  module Jobs
    
    class Client < Kasabi::BaseClient
      #Initialize the jobs client to work with a specific endpoint
      #
      # The _options_ hash can contain the following values:
      # * *:apikey*: required. apikey authorized to use the API
      # * *:client*: HTTPClient object instance
      def initialize(endpoint, options={})
        super(endpoint, options)
      end
      
      def reset(t=Time.now())
        time = t.getutc.strftime("%Y-%m-%dT%H:%M:%SZ")
        type = "reset"
        return submit_job(type, time)
      end
      
      def submit_job(type, time)
        response = post( @endpoint, {:jobType=>type, :startTime=>time}, {"Content-Type" => "application/x-www-form-urlencoded"} )
        if response.status != 202
          raise "Failed to submit job request. Status: #{response.status}. Message: #{response.content}"
        end
        
        return response.content                         
      end
      
    end
    
  end
end