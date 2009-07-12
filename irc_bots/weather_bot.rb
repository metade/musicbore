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
  
  def weather_forecast()

    require 'rubygems'
    require 'yahoo-weather'
    @client = YahooWeather::Client.new    
    response = @client.lookup_location('UKXX1822')
    
    temp_centigrade = ((response.condition.temp - 32)*(5.0/9)).round
    weather = {:temperature => temp_centigrade,
      :text => response.condition.text}
    
    if weather
      forecast = construct_forcast_text_for(weather)
      send_msg("say[victoria]: #{forecast}")
    end
    send_msg("control:next")
  end
  
  def construct_forcast_text_for(weather)
    temperature = weather[:temperature]
    text = weather[:text]

    speech = []

    # Time based greeting.
    am_greetings = ['Good morning',
                    'Hello, and good morning',
                    'Top of the morning to you']
    pm_greetings = ['Good afternoon',
                    'Good afternoon, I hope you enjoyed your lunch',
                    'Here\'s your afternoon forecast']
    
    if (Time.now.hour <= 12)
      speech << one_of(am_greetings)
    else
      speech << one_of(pm_greetings)
     end
    
    # Temperature based sentence.
    warm_text = ["It\'s warm out there! #{temperature} degrees.",
                 "A pleasant temperature: #{temperature} degrees.",
                 "A warm day, with temperatures reaching #{temperature} degrees",
                ]
    cool_text = ["It\'s quite cool out there today. #{temperature} degrees.",
                 "#{temperature} degrees today - don\'t forget your jacket",
                 "A cool day, only #{temperature} degrees.",
                ]

    if (temperature < 18)
      speech << one_of(cool_text)
    else
      speech << one_of(warm_text)
    end
    
    # Text based sentence.
    summary = ["To summarise, today\'s weather will be #{text}",
               "In summary: #{text}",
               "In other words: #{text}"]
    speech << one_of(summary)
    
    speech.join(". ")
  end

  def one_of(array)
    array[rand(array.size)]
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
      if message.downcase =~ /weatherbot: weather/
        weather_forecast()
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
irc = IRC.new('irc.freenode.net', 6667, 'weatherbot', '#bbcmusicbore')
irc.connect()
begin
  irc.main_loop()
rescue Interrupt
rescue Exception => detail
  puts detail.message()
  print detail.backtrace.join("\n")
  retry
end
