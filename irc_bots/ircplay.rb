#!/usr/local/bin/ruby

require "rubygems"
require "socket"
require 'digest/md5'
require 'mp3info'
require 'osc'

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
    
    def madjack(command)
      if command =~ /^(\w+) (.+)$/
        m = OSC::Message.new("/deck/#{$1}", 's', $2)
      else
        m = OSC::Message.new("/deck/#{command}", '')
      end
      puts "Sending to Madjack: #{m}"
      c = OSC::UDPSocket.new
      c.send(m, 0, '127.0.0.1', 4444)
    end
    
    def minimix(channel, dbs)
      m = OSC::Message.new("/mixer/channel/set_gain", 'if', channel, dbs.to_f)
      puts "Sending to Jack Mini Mix: #{m}"
      c = OSC::UDPSocket.new
      c.send(m, 0, '127.0.0.1', 5555)
    end

    def say(cmd, voice='Alex')
      puts "Asking #{voice} to say #{cmd}"
      IO.popen("say -v '#{voice}'", 'w') do |io|
        io.puts cmd
      end
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
                if message =~ /^say(\[\w+\])?:\s*(.+)\s*$/
                  text = $2
                  voice = ($1 || 'Alex').gsub(/\W/,'')
                  minimix(1,-10)
                  say(text, voice)
                  minimix(1,0)
                  #send_msg("I have finished speaking.")
                elsif message =~ /^play:\s*(.+)$/
                  url = $1.strip
                  puts "Playing: #{url}"
                  if url =~ /^\//
                    localfile = url
                    status = true
                  else
                    localfile = "/tmp/"+Digest::MD5.hexdigest(url)+".mp3"
                    if File.exists?(localfile)
                      status = true
                    else
                      status = system("curl -f -m 10 -o '#{localfile}' '#{url}'")
                    end
                  end
                  if status and File.exists?(localfile)
                    madjack("load #{localfile}")
                    send_msg("track queued")
                    
                    info = begin
                      Mp3Info.new(localfile)
                    rescue Mp3InfoError => exp
                      nil  
                    end
                    unless info.nil? || info.tag.artist.nil? || info.tag.title.nil?
                      send_msg("Now Playing \"#{info.tag.artist}\" by \"#{info.tag.title}\"")
                    end
                  else
                    send_msg("Failed to queue track: #{$?}")
                    File.unlink(localfile)
                  end
                elsif message =~ /^madjack:\s*(\w+)/
                  madjack($1)
                elsif message =~ /^volume:\s*([\-\d]+)/
                  minimix(1,$1)
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
irc = IRC.new('irc.freenode.net', 6667, 'irc2play', '#bbcmusicbore')
irc.connect()
begin
    irc.main_loop()
rescue Interrupt
rescue Exception => detail
    puts detail.message()
    print detail.backtrace.join("\n")
    retry
end
