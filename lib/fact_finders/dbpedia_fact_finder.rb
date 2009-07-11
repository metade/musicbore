
class DBPediaFactFinder < FactFinder
  def initialize(dbpedia_uri)
    @resource = DBPEDIA::Resource.new(dbpedia_uri)
  end
  
  def name
    dbpedia_query do
      @resource.rdfs::label
    end
  end
  
  def dbpedia_query(&block)
    $dbpedia.enabled = true
    $bbc.enabled = false
    value = yield
    $dbpedia.enabled = false
    $bbc.enabled = true
    value
  end
  
  def list_statements
    p @resource.predicates
    p name
    []
  end
end
