#!/usr/local/bin/ruby

require "socket"
require 'yaml'
require 'open-uri'

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

  def wikipedia_for(gid)
    uri = "http://www.bbc.co.uk/music/artists/#{gid}.yaml"
    data = open(uri) {|f| YAML::load(f)}
    
    artist_name = data['artist']['name']
    wikipedia_text = data['artist']['wikipedia_article']['content']

    shuffled_sentences = wikipedia_text.split('. ').sort_by{rand}
    shuffled_sentences.first
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
      message = $5
      if message.downcase =~ /wikipedia: ([0-9a-f\-]{36})/
        text = wikipedia_for($1)
        
        if text
          send_msg("say: #{text}")
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
irc = IRC.new('irc.freenode.net', 6667, 'wikipedia', '#bbcmusicbore')
irc.connect()
begin
  irc.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
