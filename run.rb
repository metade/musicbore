require 'rubygems'
require 'lib/bore'
require 'irc'

# patch for Ruby-IRC and freenode, see http://rubyforge.org/tracker/index.php?func=detail&aid=19988&group_id=1784&atid=6979
class IRCEvent
  def initialize (line)
     line.sub!(/^:/, '')
     mess_parts = line.split(':', 2);
     # mess_parts[0] is server info
     # mess_parts[1] is the message that was sent
     @message = mess_parts[1]
     @stats = mess_parts[0].scan(/[^!\s]+/)
     if @stats[0].match(/^PING/)
       @event_type = 'ping'
     elsif @stats[1] && @stats[1].match(/^\d+/)
       @event_type = EventLookup::find_by_number(@stats[1]);
       @channel = @stats[3]
     else
       @event_type = @stats[2].downcase if @stats[2]
     end

     if @event_type != 'ping'
       @from    = @stats[0] 
       @user    = IRCUser.create_user(@from)
     end
     # FIXME: this list would probably be more accurate to exclude commands than to include them
     @hostmask = @stats[1] if %W(topic privmsg join).include? @event_type
     @channel = @stats[3] if @stats[3] && !@channel
     @target  = @stats[5] if @stats[5]
     @mode    = @stats[4] if @stats[4]
     if @mode.nil? && @event_type == 'mode'
       # Server modes (like +i) are sent in the 'message' part, and not
       # the 'stat' part of the message.
       @mode = @message
     end

     # Unfortunatly, not all messages are created equal. This is our
     # special exceptions section
     if @event_type == 'join'
       @channel = @message
     end
   end
end

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
      fact_finder.statements.each do |statement|
        bot.send_message(event.channel, "say:#{statement}")
      end
      bot.send_message(event.channel, "connectionfinder:#{fact_finder.dbpedia_uri.uri}") #if event.from == 'relationshipfinder'
    rescue => e
      bot.send_message(event.channel, "doh! #{e.message}")
      puts e.message
      puts e.backtrace
    end
  end
end
bot.connect
