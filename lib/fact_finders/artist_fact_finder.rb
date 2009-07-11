
class ArtistFactFinder < FactFinder
  def initialize(artist_uri)
    @artist = MO::Artist.new(artist_uri)
    @artist_type = @artist.rdf::type
  end
  
  def self.artist_uri_for_dbpedia_uri(dbpedia_uri)
    sparql = <<-eos
      PREFIX owl: <http://www.w3.org/2002/07/owl#>
      SELECT ?artist WHERE { ?artist owl:sameAs <#{dbpedia_uri}> . }
    eos
    results = $bbc.query(sparql)
    return if results.empty?
    results.flatten.detect { |r| r.uri =~ %r[www.bbc.co.uk/music/artists/] }
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
      similar_artists
    ].compact
  end
  
  def myspace
    Fact.new(:subject => name,
      :verb_phrase => 'has a myspace at',
      :object => tidy_url(@artist.mo::myspace),
      :gender => gender)
  end
  
  def two_degrees
    sparql = <<-eos
      SELECT ?pl ?tl ?p2l ?ol WHERE {
      <http://dbpedia.org/resource/Fugazi> a <http://dbpedia.org/ontology/Band> ; ?p ?t . 
      ?t ?p2 ?o .
      ?p rdfs:label ?pl .
      ?t rdfs:label ?tl .
      ?p2 rdfs:label ?p2l .
      ?o a <http://dbpedia.org/ontology/Band> .
      ?o <http://dbpedia.org/property/name> ?ol .

      FILTER (
      (langMatches(lang(?ol), "en") || lang(?ol) = "" ) && 
      (langMatches(lang(?pl), "en") || lang(?pl) = "" ) &&
      (langMatches(lang(?tl), "en") || lang(?tl) = "" ) &&
      (langMatches(lang(?p2l), "en") || lang(?p2l) = "" )
      )
      }
    eos
    results = $dbpedia.query(sparql)
  end
  
  def similar_artists
     uri = "http://ws.audioscrobbler.com/2.0/artist/#{URI.escape(name)}/similar.txt"
     similar_artists = []
     open(uri) do |f|
       f.each_line {|l| similar_artists << l.split(',').last.strip }
     end
     similar_artists.each { |a| a.gsub!('&amp;', '&') }
     
     Fact.new(:subject => name,
       :verb_phrase => 'sound a bit like',
       :object => similar_artists[0..2].join(", ") + " and " + similar_artists[3],
       :gender => gender)
   end
  
  def close_friend_of
    sparql = 
      "PREFIX rel: <http://purl.org/vocab/relationship/> " +
      "PREFIX foaf: <http://xmlns.com/foaf/0.1/> " + 
      "SELECT ?name WHERE { <#{@artist.uri}> rel:closeFriendOf ?friend . ?friend foaf:name ?name }"
    results = $bbc.query(sparql)
    return if results.empty?
    Fact.new(:subject => name,
      :verb_phrase => 'is a close friend of',
      :object => results.first.first,
      :gender => gender)
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
