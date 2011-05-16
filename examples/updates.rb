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

cs = "<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"" + 
    " xmlns:cs=\"http://purl.org/vocab/changeset/schema#\"> " + 
  " <cs:ChangeSet rdf:about=\"http://example.com/changesets#change\">" + 
  " <cs:subjectOfChange rdf:resource=\"#{marker}\"/> " +
  " <cs:createdDate>2011-05-16T00:00:00Z</cs:createdDate> " +
  " <cs:creatorName>Anne Onymous</cs:creatorName> " +
  " <cs:changeReason>Removal</cs:changeReason> " +
  " <cs:removal> " +
  "  <rdf:Statement> " +
  "      <rdf:subject rdf:resource=\"#{marker}\"/>" + 
  "   <rdf:predicate rdf:resource=\"http://www.w3.org/2000/01/rdf-schema#comment\"/> " +
  "      <rdf:object>Hello world</rdf:object> " +
  " </rdf:Statement> " +
  "  </cs:removal> " +
  " </cs:ChangeSet> " +
  "  </rdf:RDF> "

puts "Removing triple via changeset"
resp = dataset.apply_changeset(cs)

puts "Changeset submitted. Update URI: #{resp}"

while !dataset.applied?(resp)
  #all updates are async.
  #here we wait for update to be applied, but this is just for demo purposes
end

puts "Changeset applied"
    