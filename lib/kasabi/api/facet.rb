module Kasabi

  #This module organizes the classes related to the Facet service
  module Search

    module Facet

      #A term returned in a facet search result
      #
      #A term has a number of hits, a reference to a search uri that can
      #be used to find all of those hits, and a value
      class Term
        attr_reader :hits
        attr_reader :search_uri
        attr_reader :value

        def initialize(hits, search_uri, value)
          @hits = hits
          @search_uri = search_uri
          @value = value
        end

      end

      #The results of a facetted search
      class Results

        #The query used to generate the facet results, as echoed in the response
        attr_reader :query

        #The fields used to generate the results
        attr_reader :fields

        #An array of Term objects
        attr_reader :facets

        def initialize(query, fields, facets=Hash.new)
          @query = query
          @fields = fields
          @facets = facets
        end

        #Parses the XML format from a successful API response to generate
        #a Results object instance
        def Results.parse(data)
          doc = REXML::Document.new(data)
          root = doc.root
          head = root.elements[1]

          query = ""
          fields = ""
          queryEl = head.get_elements("query")[0]
          if queryEl != nil
            query = queryEl.text
          end
          fieldsEl = head.get_elements("fields")[0]
          if fieldsEl != nil
            fields = fieldsEl.text
          end

          results = Results.new(query, fields)

          fields = root.get_elements("fields")[0]
          if fields == nil
            raise "No fields in document!"
          end

          fields.get_elements("field").each do |field|
            field_name = field.attribute("name").value
            results.facets[field_name] = Array.new

            field.get_elements("term").each do |term|
              term = Term.new(term.attribute("number").value.to_i,
                term.attribute("search-uri").value,
                term.text() )

              results.facets[field_name] << term
            end

          end

          return results
        end

      end

    end

  end

end