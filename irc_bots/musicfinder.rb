#!/usr/local/bin/ruby

require "socket"

class Array
  def rand
    self[Kernel.rand(self.size)]
  end
end

# The irc class, which talks to the server and holds the main event loop
class IRC
    def initialize(server, port, nick, channel)
        @server = server
        @port = port
        @nick = nick
        @channel = channel
    end
    def send(s)
        # Send a message to the irc server and print it to the screen
        puts "--> #{s}"
        @irc.send "#{s}\n", 0 
    end
    def connect()
        # Connect to the IRC server
        @irc = TCPSocket.open(@server, @port)
        send "USER #{@nick} #{@nick} #{@nick} :#{@nick} #{@nick}"
        send "NICK #{@nick}"
        send "JOIN #{@channel}"
    end
    
    def send_msg(msg)
      send("PRIVMSG #{@channel} :#{msg}")
    end
    
    def random_surge_track(gid)
      uri = "http://www.surgeradio.co.uk/music/artists/#{gid}"
      tracks = []
      IO.popen("rapper --quiet -o ntriples #{uri}.rdf", "r") do |rapper|
        rapper.each_line do |line|
          if line =~ /<(.+)> <(.+)> <(.+)> \./
            sub,pred,obj = $1,$2,$3
            if sub == uri and pred == 'http://xmlns.com/foaf/0.1/made' and obj =~ /\.mp3$/
              tracks << o
            end
          end
        end
      end
      return tracks.rand
    end
    
    def get_artist_name(gid)
      uri = "http://www.bbc.co.uk/music/artists/#{gid}#artist"
      IO.popen("rapper --quiet -o ntriples #{uri}", "r") do |rapper|
        rapper.each_line do |line|
          if line =~ /<(.+)> <(.+)> "(.+)" \./
            sub,pred,obj = $1,$2,$3
            return obj if sub == uri and pred == 'http://xmlns.com/foaf/0.1/name'
          end
        end
      end
      return nil
    end
    
    
    
    def handle_server_input(s)
        # This isn't at all efficient, but it shows what we can do with Ruby
        # (Dave Thomas calls this construct "a multiway if on steroids")
        case s.strip
            when /^PING :(.+)$/i
                puts "[ Server ping ]"
                send "PONG :#{$1}"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]PING (.+)[\001]$/i
                puts "[ CTCP PING from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\001PING #{$4}\001"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]VERSION[\001]$/i
                puts "[ CTCP VERSION from #{$1}!#{$2}@#{$3} ]"
                send "NOTICE #{$1} :\001VERSION Ruby-irc v0.042\001"
            when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s(.+)\s:(.+)$/i
                p [$1,$2,$3,$4,$5]
                from = $1
                message = $5
                if message.downcase =~ /^playartist:.*([0-9a-f\-]{36})/
                  gid = $1
                  index_path = "./artist_index/#{gid}.txt"
                  if File.exists?(index_path)
                    track_url = File.new(index_path,'r').readlines.rand
                  else
                    track_url = random_surge_track( gid )
                  end
                  if track_url
                    send_msg("play:#{track_url}")
                    send_msg("madjack:play")
                  else
                    name = get_artist_name(gid)
                    send_msg("trackfinder:#{name}")
                  end
                end
            else
                puts s
        end
    end
    def main_loop()
        # Just keep on truckin' until we disconnect
        while true
            ready = select([@irc, $stdin], nil, nil, nil)
            next if !ready
            for s in ready[0]
                if s == $stdin then
                    return if $stdin.eof
                    s = $stdin.gets
                    send s
                elsif s == @irc then
                    return if @irc.eof
                    s = @irc.gets
                    handle_server_input(s)
                end
            end
        end
    end
end

# The main program
# If we get an exception, then print it out and keep going (we do NOT want
# to disconnect unexpectedly!)
irc = IRC.new('irc.freenode.net', 6667, 'musicfinder', '#bbcmusicbore')
irc.connect()
begin
    irc.main_loop()
rescue Interrupt
rescue Exception => detail
    puts detail.message()
    print detail.backtrace.join("\n")
    retry
end
