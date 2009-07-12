require 'rubygems'

$LOAD_PATH << File.join(File.dirname(__FILE__),'..','lib')
require 'bore'
require 'ruby_irc'
require 'ext/array'

Thread::abort_on_exception = true

bore = Bore.new
bot = IRC.new("thebore", "irc.freenode.net", "6667", "Realname")
IRCEvent.add_callback('endofmotd') { |event| bot.add_channel('#bbcmusicbore') }
IRCEvent.add_callback('privmsg') do |event|
  if event.message =~ /bore:(.*)/
    puts $1
    begin
      fact_finder = bore.bore($1)
      bot.send_message(event.channel, fact_finder.resource)
      bot.send_message(event.channel, "say:#{fact_finder.bla_bla_bla}")
      bot.send_message(event.channel, "connectionfinder:#{fact_finder.dbpedia_uri.uri}") unless fact_finder.dbpedia_uri.nil?
    rescue => e
      bot.send_message(event.channel, "doh! #{e.message}")
      puts e.message
      puts e.backtrace
    end
  end
end
bot.connect
