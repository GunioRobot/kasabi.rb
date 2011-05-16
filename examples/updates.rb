$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'kasabi'
require 'uuid'

#URI of dataset api, e.g. api.kasabi.com/dataset/...
dataset = ENV["KASABI_DATASET"]
#developer API key
apikey = ENV["KASABI_API_KEY"]
  
#base url of linked data service (no need to change, except for Kasabi developers)
base = ENV["KASABI_BASE_URI"] || "http://api.kasabi.local"
  
#generate a unique uri
marker = "http://example.org/tests/#{UUID.generate}"

#The data to add
to_add = "<#{marker}> <http://www.w3.org/2000/01/rdf-schema#comment> \"Hello world\". "

#create our client
dataset = Kasabi::Dataset.new("#{base}/dataset/#{dataset}", {:apikey => apikey})

dataset.client.debug_dev = $stderr
puts "Dataset: #{dataset.endpoint}"
puts "API key: #{apikey}"
puts "Submitting test data to Kasabi dataset:\n#{to_add}"  
resp = dataset.store_data( to_add, "text/turtle")
puts "Data submitted. Update URI: #{resp}"

while !dataset.applied?(resp)
  #all updates are async.
  #here we wait for update to be applied, but this is just for demo purposes
end

puts "Update applied"

    