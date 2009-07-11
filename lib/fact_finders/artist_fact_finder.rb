
class ArtistFactFinder < FactFinder
  def initialize(artist_uri)
    @artist = MO::Artist.new(artist_uri)
    ConnectionPool.adapters.first.load(artist_uri, 'rdfxml')
    @artist_type = @artist.rdf::type
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
    p MO::myspace
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
