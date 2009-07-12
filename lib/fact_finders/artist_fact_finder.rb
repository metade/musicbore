
class ArtistFactFinder < FactFinder
  attr_accessor :subject
  
  MALE_NAMES, FEMALE_NAMES = {}, {}
  File.read(File.join(File.dirname(__FILE__), '..', '..', 'data', 'person_male.lst')).split.each { |n| MALE_NAMES[n.downcase] = true }
  File.read(File.join(File.dirname(__FILE__), '..', '..', 'data', 'person_female.lst')).split.each { |n| FEMALE_NAMES[n.downcase] = true }
  
  def initialize(artist_uri)
    @artist = MO::Artist.new(artist_uri)
    @artist_type = @artist.rdf::type
    
    @subject = ArtistSubject.new(:name => name, :gender => gender, :first_name => first_name)
  end
  
  def resource
    @artist.uri
  end
  
  def gid
    $1 if @artist.uri =~ %r[http://www.bbc.co.uk/music/artists/(.+)#artist]
  end
  
  def dbtune_uri
    "http://dbtune.org/musicbrainz/resource/artist/#{gid}"
  end
  
  def dbpedia_uri
    @dbpedia_uri ||= [@artist.owl::sameAs].flatten.compact.detect { |u| u.uri =~ /dbpedia/ }
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
  
  def name
    @name ||= @artist.foaf::name
  end
  
  def is_group?
    return true if @artist_type.nil?
    @artist_type.include?(MO::MusicGroup)
  end
  
  def first_name
    return nil if is_group?
    first_name = $1.downcase if name =~ /(\w+) /
  end
  
  def gender
    return nil if is_group?
    if MALE_NAMES[first_name]
      :male
    elsif FEMALE_NAMES[first_name]
      :female
    else
      nil
    end
  end
  
  def statements
    [
      myspace,
      formed,
      brands_played_on,
      spouse_of,
      close_friend_of,
      similar_artists,
      reviews,
      number_of_releases
    ].compact
  end
  
  def myspace
    url = @artist.mo::myspace
    return nil if url.nil?
    Fact.new(:subject => subject,
      :verb_phrase => 'has a myspace at',
      :object => tidy_url(url))
  end
  
  def similar_artists
    return nil if name.nil?
    uri = "http://ws.audioscrobbler.com/2.0/artist/#{URI.escape(name)}/similar.txt"
    similar_artists = []
    begin
     open(uri) do |f|
       f.each_line {|l| similar_artists << l.split(',').last.strip }
     end
    rescue => e
     puts "Error fetching data from last.fm: #{e.message}"
    end
    similar_artists.each { |a| a.gsub!('&amp;', '&') }
    return nil if similar_artists.empty?

    Fact.new(:subject => subject,
     :verb_phrase => 'sound a bit like',
     :object => join_sequence(similar_artists[0,1+rand(2)]))
  end
  
  def brands_played_on
    begin
      chart = YAML.load(open("http://www.bbc.co.uk/programmes/music/artists/#{gid}.yaml"))
    rescue
      return nil
    end
    
    brand = chart['artist']['brands_played_on'].first
    
    services = {
      '1xtra' => 'One Extra',
      'radio1' => 'Radio One',
      'radio2' => 'Radio Two',
      '6music' => 'Six Music',      
    }
    service = services[brand['service_key']] || brand['service_key']
    superlative = %w(super big massive).rand
    
    sentence = "#{brand['title']} on BBC #{service} is a #{superlative} fan"
    if (rand>0.5)
      fact = Fact.new(:subject => subject,
        :verb_phrase => 'has been played',
        :object => "#{brand['plays']} times on this show!") 
      sentence += '. ' + fact.to_s
    end
    
    FreeformFact.new(:sentence => sentence)
  end
  
  def spouse_of
    sparql = 
      "PREFIX rel: <http://purl.org/vocab/relationship/> " +
      "PREFIX foaf: <http://xmlns.com/foaf/0.1/> " + 
      "SELECT ?name WHERE { <#{@artist.uri}> rel:spouseOf ?spouse . ?spouse foaf:name ?name }"
    results = $bbc.query(sparql)
    return if results.empty?
    Fact.new(:subject => subject,
      :verb_phrase => 'was the spouse of',
      :object => results.first.first)
  end
  
  def close_friend_of
    sparql = 
      "PREFIX rel: <http://purl.org/vocab/relationship/> " +
      "PREFIX foaf: <http://xmlns.com/foaf/0.1/> " + 
      "SELECT ?name WHERE { <#{@artist.uri}> rel:closeFriendOf ?friend . ?friend foaf:name ?name }"
    results = $bbc.query(sparql)
    return if results.empty?
    Fact.new(:subject => subject,
      :verb_phrase => 'is a close friend of',
      :object => results.first.first)
  end
  
  def reviews
    sparql = <<-eos
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/elements/1.1/>
      SELECT ?record WHERE {
        <#{@artist.uri}> foaf:made ?r .
        ?r dc:title ?record .
      }
    eos
    results = $bbc.query(sparql).flatten
    return if results.empty?
    results.each { |r| r.gsub!(/\(.+\)/, '') }
    results.uniq!
    
    Fact.new(:subject => subject,
      :verb_phrase => 'has released',
      :object => join_sequence(results))
  end
  
  def number_of_releases
    sparql = <<-eos
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/elements/1.1/>
      PREFIX  mo: <http://purl.org/ontology/mo/>
      
      SELECT DISTINCT ?record WHERE {
        ?r foaf:maker <#{dbtune_uri}> .
        ?r a mo:Record .
        ?r dc:title ?record .
      }
    eos
    results = $musicbrainz.query(sparql).flatten
    results.each { |r| r.gsub!(/\(.+\)/, '') }
    results.uniq!
    
    favourive = results.rand
    phrases = [
      "My favourte is #{favourive}",
      "I really liked #{favourive}",
      "#{favourive} was just terrible",
    ]
    
    return if results.empty?
    Fact.new(:subject => subject,
      :verb_phrase => 'has released',
      :object => "#{results.size} records. #{phrases.rand}")
  end
  
  def reviews
    sparql = <<-eos
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/elements/1.1/>
      SELECT ?record WHERE {
        <#{@artist.uri}> foaf:made ?r .
        ?r dc:title ?record .
      }
    eos
    results = $bbc.query(sparql).flatten
    return if results.empty?
    
    Fact.new(:subject => subject,
      :verb_phrase => 'has released',
      :object => join_sequence(results))
  end
  
  def formed
    sparql = <<-eos
      PREFIX foaf: <http://xmlns.com/foaf/0.1/>
      PREFIX dc: <http://purl.org/dc/elements/1.1/>
      PREFIX bio: <http://purl.org/vocab/bio/0.1/>
      SELECT ?birth WHERE {
        <#{@artist.uri}> bio:event ?birth .
        ?birth bio:date ?birth .
      }
    eos
    puts sparql
    results = $bbc.query(sparql).flatten
    p results
    
    date = Query.new.select(:formed).
      where(@artist, BIO::event, :birth).
      where(:birth, BIO::date, :formed).execute.first
    return nil if date.nil?
    date = $1 if date =~ /(\d+)-/
    
    formed_type = is_group? ? 'formed' : 'born'
    "was #{formed_type} in #{date}"
  end
  
  def join_sequence(array)
    return nil if array.empty?
    if array.size==1
      array.first
    elsif array.size == 2
      "#{array.first} and #{array.last}"
    else
      array[0..array.size-2].join(", ") + " and " + array[array.size-1]
    end
  end
end
