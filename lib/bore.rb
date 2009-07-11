require 'rubygems'
require 'active_rdf'

require 'lib/fact_finders/fact_finder'
require 'lib/fact_finders/artist_fact_finder'
require 'lib/fact_finders/dbpedia_fact_finder'

# patch activerdf to run plain sparql queries
class Query2SPARQL
  def self.translate(query, engine=nil)
    return query if query.kind_of? String
    str = ""
    if query.select?
      distinct = query.distinct? ? "DISTINCT " : ""
			select_clauses = query.select_clauses.collect{|s| construct_clause(s)}

      str << "SELECT #{distinct}#{select_clauses.join(' ')} "
      str << "WHERE { #{where_clauses(query)} #{filter_clauses(query)}} "
      str << "LIMIT #{query.limits} " if query.limits
      str << "OFFSET #{query.offsets} " if query.offsets
    elsif query.ask?
      str << "ASK { #{where_clauses(query)} } "
    end
    
    return str
  end
end

class Bore
  def initialize
    Namespace.register(:foaf, 'http://xmlns.com/foaf/0.1/')
    Namespace.register(:owl, 'http://www.w3.org/2002/07/owl#')
    Namespace.register(:mo, 'http://purl.org/ontology/mo/')
    Namespace.register(:bore, 'http://github.com/bore/')
    Namespace.register(:bio, 'http://purl.org/vocab/bio/0.1/')
    Namespace.register(:rel, 'http://purl.org/vocab/relationship/')
    
    $bbc = ConnectionPool.add_data_source(:type => :sparql, :url => 'http://api.talis.com/stores/bbc-backstage/services/sparql', :engine => :virtuoso)
    $dbpedia = ConnectionPool.add_data_source(:type => :sparql, :url => 'http://dbpedia.org/sparql', :engine => :virtuoso)
    $bbc.enabled = true
  end
  
  def bore(topic=nil)
    fact_finder = determine_fact_finder(topic)
    fact_finder.statements
  end
  
  protected
  
  def determine_fact_finder(topic)
    if topic =~ %r[http://www.bbc.co.uk/music/artists]
      ArtistFactFinder.new(topic)
    else
      dbpedia_uri = "http://dbpedia.org/resource/#{topic.gsub(' ', '_')}"
      artist_uri = ArtistFactFinder.artist_uri_for_dbpedia_uri(dbpedia_uri)
      if artist_uri
        ArtistFactFinder.new(artist_uri) 
      else
        DBPediaFactFinder.new(topic)
      end
    end
  end
  
end

# debug code
if __FILE__ == $0
  bore = Bore.new
  # p bore.bore('http://www.bbc.co.uk/music/artists/9b51f964-2f24-46f4-9550-0f260dcdad48#artist')
  # p bore.bore('http://www.bbc.co.uk/music/artists/5fee3020-513b-48c2-b1f7-4681b01db0c6#artist')
  # p bore.bore('http://www.bbc.co.uk/music/artists/f27ec8db-af05-4f36-916e-3d57f91ecf5e#artist')
  p bore.bore('Michael Jackson')
  
end

