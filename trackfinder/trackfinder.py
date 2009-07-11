#!/usr/bin/python

from pyechonest import artist, config
from ircbot import SingleServerIRCBot
from irclib import nm_to_n, nm_to_h, irc_lower, ip_numstr_to_quad, ip_quad_to_numstr
from random import *
import urllib2
import socket

timeout = 2
socket.setdefaulttimeout(timeout)

class TestBot(SingleServerIRCBot):
    def __init__(self, channel, nickname, server, port=6667):
        SingleServerIRCBot.__init__(self, [(server, port)], nickname, nickname)
        self.channel = channel
        self.random = Random()

    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_welcome(self, c, e):
        c.join(self.channel)

    def on_privmsg(self, c, e):
        self.do_command(e, e.arguments()[0])

    def on_pubmsg(self, c, e):
        a = e.arguments()[0].split(":", 1)
        if len(a) > 1 and irc_lower(a[0]) == irc_lower(self.connection.get_nickname()):
            self.do_command(e, a[1])

    def on_dccmsg(self, c, e):
        c.privmsg("You said: " + e.arguments()[0])

    def on_dccchat(self, c, e):
        if len(e.arguments()) != 2:
            return
        args = e.arguments()[1].split()
        if len(args) == 4:
            try:
                address = ip_numstr_to_quad(args[2])
                port = int(args[3])
            except ValueError:
                return
            self.dcc_connect(address, port)

    def do_command(self, e, cmd):
        #for sim in alist[0].similar():
        #    self.connection.privmsg(self.channel, sim.name.encode('ascii', 'ignore'))
        r_track = self.find_track(cmd)
        if r_track:
            self.connection.privmsg(self.channel, "play:" +r_track['url'])
            self.connection.privmsg(self.channel, "madjack:play")

    def find_track(self, cmd, k=0):
        k = k+1
        print "Trying to get audio for %s, try %d" % (cmd,k)
        try: 
            alist = artist.search_artists(cmd)
        except:
            self.connection.privmsg(self.channel, "No matching artist")
            return
        if len(alist) == 0 or k > 5:
            self.connection.privmsg(self.channel, "No matching artist")
            return
        try:
            tracks = alist[0].audio()
        except:
            self.connection.privmsg(self.channel, "No matching tracks")
            return
        if len(tracks) == 0:
            self.connection.privmsg(self.channel, "No matching tracks")
            return
        r_track = tracks[self.random.randint(0, len(tracks) -1)]
        request = urllib2.Request(r_track['url'])
        request.get_method = lambda: "HEAD"
        try:
            http_file = urllib2.urlopen(request)
        except:
            return self.find_track(cmd, k)
        ct = http_file.headers["content-type"]
        if ct == 'audio/mpeg':
            return r_track
        else:
            return self.find_track(cmd, k)

def main():
    config.ECHO_NEST_API_KEY="O7HXFLBKKXN05PDQU"
    import sys
    if len(sys.argv) != 4:
        print "Usage: testbot <server[:port]> <channel> <nickname>"
        sys.exit(1)

    s = sys.argv[1].split(":", 1)
    server = s[0]
    if len(s) == 2:
        try:
            port = int(s[1])
        except ValueError:
            print "Error: Erroneous port."
            sys.exit(1)
    else:
        port = 6667
    channel = sys.argv[2]
    nickname = sys.argv[3]

    bot = TestBot(channel, nickname, server, port)
    bot.start()

if __name__ == "__main__":
    main()
