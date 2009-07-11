
class ArtistFactFinder < FactFinder
  def initialize(artist_uri)
    @artist = MO::Artist.new(artist_uri)
    @artist_type = @artist.rdf::type
  end
  
  def dbpedia_uri
    @dbpedia_uri ||= [@artist.owl::sameAs].flatten.detect { |u| u.uri =~ /dbpedia/ }
  end
  
  def name
    @artist.foaf::name
  end
  
  def list_statements
    [
      myspace,
      formed,
      close_friend_of,
    ].compact
  end
  
  def myspace
    "#{MO::myspace.bore::label} #{tidy_url(@artist.mo::myspace)}"
  end
  
  def close_friend_of
    sparql = 
      "PREFIX rel: <http://purl.org/vocab/relationship/> " +
      "PREFIX foaf: <http://xmlns.com/foaf/0.1/> " + 
      "SELECT ?name WHERE { <#{@artist.uri}> rel:closeFriendOf ?friend . ?friend foaf:name ?name }"
    results = $bbc.query(sparql)
    return if results.empty?
    return "is a close friend of #{results.first.first}"
  end
  
  def formed
    date = Query.new.select(:formed).
      where(@artist, BIO::event, :birth).
      where(:birth, BIO::date, :formed).execute.first
    return nil if date.nil?
    date = $1 if date =~ /(\d+)-/
    
    formed_type = @artist_type.include?(MO::MusicGroup) ? 'formed' : 'born'
    "was #{formed_type} in #{date}"
  end
end
