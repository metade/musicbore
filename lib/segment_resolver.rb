#!/usr/bin/ruby

require 'rubygems'
require 'mp3info'

SEGMENTS_DIR='/Volumes/My Passport/segments/'

def add_track_to_artist_index(artist,path)
  # Read in the existing index
  index_path = "./artist_index/#{artist}.txt"
  if File.exists?(index_path)
    segments = File.new(index_path,'r').readlines.map { |line| line.strip }
  else
    segments = []
  end

  segments << path
  segments = segments.uniq.delete_if { |segment| segment.nil? or segment.empty? }
  
  File.open(index_path,'w') do |file|
    file.print segments.uniq.compact.join("\n")
  end
end

def fetch_artist_gid(pid, filepath)
  uri = "http://www.bbc.co.uk/programmes/#{pid}#track"
  IO.popen("rapper --quiet -o ntriples #{uri}", "r") do |rapper|
    rapper.each_line do |line|
      if line =~ /<(.+)> <(.+)> <(.+)> \./
        sub,pred,obj = $1,$2,$3
        if sub == uri and pred == 'http://xmlns.com/foaf/0.1/maker'
          if obj =~ /([0-9a-f\-]{36})/
            gid = $1
            system( 'eyeD3', '--set-user-text-frame', "MusicBrainz Artist Id:#{gid}", filepath )
            return gid
          end
        end
      end
    end
  end
  return nil
end


Dir.foreach(SEGMENTS_DIR) do |file|
  
  if file =~ /^(\w{8})\.mp3$/
    pid = $1
    filepath = File.join(SEGMENTS_DIR, file)
  
    # Check the samplerate of the MP3
    begin
      info = Mp3Info.new(filepath)
      if info.samplerate.to_i != 44100
        puts "Wrong samplerate: #{filepath}"
        next
      end
    rescue Mp3InfoError => exp
      $stderr.puts "Failed to parse file: #{exp}"
      next
    end
    
    # Get the artist GID
    gid = nil
    txxx = info.tag2["TXXX"]
    unless txxx.nil?
      txxx.each do |frame|
        gid = $1 if frame =~ /^MusicBrainz Artist Id\000(.+)/
      end
    end
    if gid.nil?
      gid = fetch_artist_gid(pid, filepath)
    end
    
    unless gid.nil?
      add_track_to_artist_index(gid, filepath)
    end
  end
end

