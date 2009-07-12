require 'rubygems'
require 'open-uri'
require 'yaml'

$LOAD_PATH << File.join(File.dirname(__FILE__),'..','lib')
require 'ruby_irc'
require 'ext/array'

chart = YAML.load(open('http://www.bbc.co.uk/programmes/music/artists/charts.yaml').read)
artists = chart['artists_chart']['artists'].map { |a| "http://www.bbc.co.uk/music/artists/#{a['gid']}#artist" }

bot = IRC.new("controller", "irc.freenode.net", "6667", "Realname")
IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#bbcmusicbore') }
IRCEvent.add_callback('join') do |event| 
  message = [
    "Hello. I am the Music Bore. I play music and I like to tell you ALL about the music I play.",
    "I get my information from the BBC, last.fm, Linked Data...",
    "To find out more, please visit bit.ly/musicbore.",
    "Now let me play you some music.",
  ]
  
  bot.send_message(event.channel, "say:#{message}")
  sleep(5)
  bot.send_message(event.channel, artists.rand)
end

# IRCEvent.add_callback('privmsg') do |event|
#   if event.message =~ /bore:(.*)/
#     puts $1
#     begin
#       fact_finder = bore.bore($1)
#       bot.send_message(event.channel, fact_finder.resource)
#       bot.send_message(event.channel, "say:#{fact_finder.bla_bla_bla}")
#       bot.send_message(event.channel, "connectionfinder:#{fact_finder.dbpedia_uri.uri}") unless fact_finder.dbpedia_uri.nil?
#     rescue => e
#       bot.send_message(event.channel, "doh! #{e.message}")
#       puts e.message
#       puts e.backtrace
#     end
#   end
# end
# bot.connect
# 
