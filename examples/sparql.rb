$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'rubygems'
require 'kasabi'

client = Kasabi::Sparql::Client.new(
  "http://api.kasabi.com/api/sparql-endpoint-nasa", :apikey=>ENV["KASABI_API_KEY"])
    
SPARQL_SELECT = <<-EOL
PREFIX space: <http://purl.org/net/schemas/space/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?name
WHERE {

  ?launch space:launched "1969-07-16"^^xsd:date.

  ?spacecraft space:launch ?launch;
              foaf:name ?name.      
}

EOL

puts "Get name of spacecraft launched on 16th July 1969, as JSON"
response = client.select(SPARQL_SELECT, "application/json")
json = JSON.parse( response.content )

json["results"]["bindings"].each do |b| 
  puts b["name"]["value"]  
end    