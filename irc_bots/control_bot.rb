require 'rubygems'
require 'open-uri'
require 'yaml'

$LOAD_PATH << File.join(File.dirname(__FILE__),'..','lib')
require 'ruby_irc'
require 'ext/array'

chart = YAML.load(open('http://www.bbc.co.uk/programmes/music/artists/charts.yaml').read)
artists = chart['artists_chart']['artists'].map { |a| "http://www.bbc.co.uk/music/artists/#{a['gid']}#artist" }

Thread::abort_on_exception = true

bot = IRC.new("controller", "irc.freenode.net", "6667", "Realname")
IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#bbcmusicbore') }
IRCEvent.add_callback('join') do |event|
  if event.from=='controller'
    message = [
      "Hello. I am the Music Bore. I play music and I like to tell you ALL about the music I play.",
      "I get my information from BBC Music, BBC Programmes, last fm, the Echo Nest, Yahoo Weather and the web of Linked Data.",
      "To find out more, please visit bit.ly/musicbore.",
      "Now let me play you some music.",
    ]
  
    message.each { |line| bot.send_message(event.channel, "say:#{line}") }
    sleep(5)
    bot.send_message(event.channel, artists.rand)
  end
end

IRCEvent.add_callback('privmsg') do |event|
  if event.message =~ /control:next/
    if (rand>0.1)
      artist = artists.rand
      bot.send_message(event.channel, "thebore:#{artist}")
      bot.send_message(event.channel, "playartist:#{artist}")
    else
      bot.send_message(event.channel, "say:And now for the weather.")
    end
  end
end
bot.connect

