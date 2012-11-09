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
    Namespace.register(:dbpedia, 'http://dbpedia.org/resource/')

    $bbc = ConnectionPool.add_data_source(:type => :sparql, :url => 'http://api.talis.com/stores/bbc-backstage/services/sparql', :engine => :virtuoso)
    $bbc.enabled = true

    $dbpedia = ConnectionPool.add_data_source(:type => :sparql, :url => 'http://dbpedia.org/sparql', :engine => :virtuoso)
    $musicbrainz = ConnectionPool.add_data_source(:type => :sparql, :url => 'http://dbtune.org/musicbrainz/sparql', :engine => :virtuoso)
  end

  def bore(topic=nil)
    determine_fact_finder(topic)
  end

  protected

  def determine_fact_finder(topic)
    if topic =~ %r[http://www.bbc.co.uk/music/artists]
      ArtistFactFinder.new(topic)
    else
      if topic =~ %r[http://dbpedia.org/resource/]
        dbpedia_uri = topic
      else
        dbpedia_uri = "http://dbpedia.org/resource/#{topic.gsub(' ', '_')}"
      end
      artist_uri = ArtistFactFinder.artist_uri_for_dbpedia_uri(dbpedia_uri)
      if artist_uri
        ArtistFactFinder.new(artist_uri)
      else
        DBPediaFactFinder.new(dbpedia_uri)
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
  finder = bore.bore('Michael Jackson')
  p finder.wikipedia_sentence
  # finder = bore.bore('http://dbpedia.org/resource/Barry_White')
  # finder = bore.bore('http://www.bbc.co.uk/music/artists/67b5ddb2-c2e3-467a-ad6a-4c1b981e6748#artist')
  # finder.statements.each { |s| puts s }
  puts '---'
  puts finder.bla_bla_bla
end

