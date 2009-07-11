class DBPediaFactFinder < FactFinder
  def initialize(dbpedia_uri)
    @resource = DBPEDIA::Resource.new(dbpedia_uri)
  end
  
  def name
    return @name if @name
    sparql = <<-eos
      SELECT ?label WHERE { 
        <#{@resource.uri}> rdfs:label ?label . 
        FILTER (langMatches(lang(?label), "en"))
      }
    eos
    results = $dbpedia.query(sparql).flatten
    @name = results.empty? ? nil : results.first
  end
  
  def list_statements
    statements = []
    sparql_1 = <<-eos
      SELECT ?p ?object WHERE {
        <#{@resource.uri}> ?p ?object .
        FILTER ((langMatches(lang(?object), "en")))
      }
    eos
    sparql_2 = <<-eos
      SELECT ?p ?object WHERE {
        <#{@resource.uri}> ?p ?o .
        ?o rdfs:label ?object .
        FILTER ((langMatches(lang(?object), "en")))
      }
    eos
    results = $dbpedia.query(sparql_1) + $dbpedia.query(sparql_2)
    
    results.each do |result|
      p result
    end
    
    # @name = results.empty? ? nil : results.first
    []
  end
  
  def dbpedia_query(&block)
    $dbpedia.enabled = true
    $bbc.enabled = false
    value = yield
    $dbpedia.enabled = false
    $bbc.enabled = true
    value
  end
  
  
  
end
