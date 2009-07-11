require 'active_rdf'

class ArtistFactFinder < FactFinder
  def initialize(artist_uri)
    @artist = MO::Artist.new(artist_uri)
    @artist_type = @artist.rdf::type
  end
  
  
  def statements
    [
      myspace,
      formed
    ].compact
  end
  
  def myspace
    "#{@artist.foaf::name} #{MO::myspace.bore::label} #{tidy_url(@artist.mo::myspace)}"
  end
  
  def formed
    date = Query.new.select(:formed).
      where(@artist, BIO::event, :birth).
      where(:birth, BIO::date, :formed).execute.first
    return nil if date.nil?
    date = $1 if date =~ /(\d+)-/
    
    formed_type = @artist_type.include?(MO::MusicGroup) ? 'formed' : 'born'
    "#{@artist.foaf::name} :was #{formed_type} in #{date}"
  end
end
