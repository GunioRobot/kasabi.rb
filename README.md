KASABI.RB
---------

Kasabi.rb provides a lightweight Ruby client library for interacting with the 
Kasabi API

[http://kasabi.com][0]

AUTHOR
------

Leigh Dodds (leigh@kasabi.com)

INSTALLATION
------------

Kasabi.rb is packaged as a Ruby Gem and can be installed as follows:

	sudo gem install kasabi
	
The source for the project is maintained in github at:

http://github.com/kasabi/kasabi.rb

USAGE
-----

  require 'rubygems'
  require 'kasabi'
  
  client = Kasabi::Sparql::Client.new("http://api.kasabi.com/api/example-api", ENV["KASABI_API_KEY"])
  results = client.query(...)
  
See the examples directory for example scripts.
  
LICENSE
-------

Copyright 2011 Talis Systems Ltd 
 
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
  
You may obtain a copy of the License at 
  
http://www.apache.org/licenses/LICENSE-2.0 
  
Unless required by applicable law or agreed to in writing, 
software distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
  
See the License for the specific language governing permissions and limitations 
under the License.

[0]: [http://kasabi.com] 