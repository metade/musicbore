#!/usr/bin/python

from ircbot import SingleServerIRCBot
from irclib import nm_to_n, nm_to_h, irc_lower, ip_numstr_to_quad, ip_quad_to_numstr
from random import *
from SPARQLWrapper import SPARQLWrapper, JSON, XML
import urllib2
import time

class TestBot(SingleServerIRCBot):
    def __init__(self, channel, nickname, server, port=6667):
        SingleServerIRCBot.__init__(self, [(server, port)], nickname, nickname)
        self.channel = channel
        self.random = Random()
        self.last_artist_name = ""
        self.played_artists = []

    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_welcome(self, c, e):
        c.join(self.channel)

    def on_privmsg(self, c, e):
        self.do_command(e, e.arguments()[0])

    def on_pubmsg(self, c, e):
        a = e.arguments()[0].split(":", 1)
        if len(a) > 1 and irc_lower(a[0]) == irc_lower(self.connection.get_nickname()):
            if a[1].startswith("notracks") and self.last_artist_name != "":
                self.connection.privmsg(self.channel, "trackfinder:"+self.last_artist_name)
            else: 
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

    def do_command(self, e, cmd, results = []):
        self.place_connection(e, cmd, results)

    def prop(self, p):
        if p == 'born' or p == 'birthPlace':
            return "is born"
        if p == 'death place':
            return "died"
        if p == 'hometown':
            return "lives"
        if p == 'home town':
            return "lives"
        return p

    def place_connection(self, e, cmd, results = []):
        artist_name = ""
        uri = cmd
        sparql = """
SELECT ?sl ?pl ?p2l ?o ?ol ?place_label WHERE {
<%s> ?p ?place .
<%s> <http://dbpedia.org/property/name> ?sl .
?p rdfs:label ?pl .  
?o ?p2 ?place .
?p2 rdfs:label ?p2l .
?t <http://dbpedia.org/property/city> ?place .
?o <http://dbpedia.org/property/wikiPageUsesTemplate> <http://dbpedia.org/resource/Template:infobox_musical_artist> .
?place rdfs:label ?place_label .
?o <http://dbpedia.org/property/name> ?ol .
FILTER (
(langMatches(lang(?ol), "en") || lang(?ol) = "" ) &&
(langMatches(lang(?place_label), "en") || lang(?place_label) = "" )
)
}
""" % (uri, uri)
        print sparql
        dbpedia = SPARQLWrapper("http://dbpedia.org/sparql")
        dbpedia.setQuery(sparql)
        dbpedia.setReturnFormat(JSON)
        if results == []:
            results = dbpedia.query().convert()
        r = results["results"]["bindings"]
        if len(r) == 0:
            self.connection.privmsg(self.channel, "No connections found")
            self.connection.privmsg(self.channel, "connectionfinder:"+uri)
            return
        result = r[self.random.randint(0, len(r) - 1)]
        bbc_uri = self.bbc_uri(result)
        if bbc_uri == "":
            self.do_command(e, cmd, results)
            return
        print bbc_uri
        if result["ol"]["value"] in self.played_artists:
            self.do_command(e, cmd, results)
            return
        artist_name = result["sl"]["value"]
        sentence = "Did you know that " + artist_name + " "
        sentence += self.prop(result["pl"]["value"]) + " in " + result["place_label"]["value"] + ", and that " + result["ol"]["value"]
        sentence += " " + self.prop(result["p2l"]["value"]) + " in the same place?"
        self.connection.privmsg(self.channel, "say:"+ sentence.encode('ascii', 'ignore'))
        time.sleep(3)
        self.last_artist_name = result["ol"]["value"]
        self.played_artists.append(self.last_artist_name)
        self.connection.privmsg(self.channel, "playartist:"+bbc_uri)
        time.sleep(15)
        if cmd.startswith("http://dbpedia.org"):
            self.connection.privmsg(self.channel, "thebore:"+bbc_uri)


    def bbc_uri(self, result):
        talis = SPARQLWrapper("http://api.talis.com/stores/bbc-backstage/services/sparql")
        talis_sparql = """PREFIX owl: <http://www.w3.org/2002/07/owl#> SELECT ?a WHERE  {?a owl:sameAs <""" + result["o"]["value"]+ """>  FILTER (regex(str(?a), "^http://www.bbc" )) }"""
        talis.setQuery(talis_sparql)
        print talis_sparql
        talis.setReturnFormat(XML)
        talis_results = talis.query().convert()
        bbc_uri = ""
        try:
            bbc_uri = talis_results.childNodes[1].childNodes[3].childNodes[1].childNodes[1].childNodes[1].childNodes[0].data
            return bbc_uri
        except:
            return ""

def main():
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
