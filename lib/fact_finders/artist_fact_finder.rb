
class ArtistFactFinder < FactFinder
  def initialize(artist_uri)
    @artist = MO::Artist.new(artist_uri)
    if @artist.rdf::type.nil?
      puts "loading #{artist_uri}"
      ConnectionPool.adapters.first.load(artist_uri, 'rdfxml')
      ConnectionPool.adapters.first.load(dbpedia_uri.uri, 'rdfxml') unless dbpedia_uri.nil?
    end
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
      formed
    ].compact
  end
  
  def myspace
    "#{MO::myspace.bore::label} #{tidy_url(@artist.mo::myspace)}"
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
