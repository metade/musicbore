#!/usr/bin/python

from ircbot import SingleServerIRCBot
from irclib import nm_to_n, nm_to_h, irc_lower, ip_numstr_to_quad, ip_quad_to_numstr
from random import *
from SPARQLWrapper import SPARQLWrapper, JSON, XML
import urllib2

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
        artist_name = cmd
        sparql = """
SELECT ?pl ?tl ?p2l ?t2l ?p3l ?ol WHERE {
?s <http://dbpedia.org/property/name> "%s"@en .
?s a <http://dbpedia.org/ontology/Band> ; ?p ?t .
?t ?p2 ?t2 .
?t2 ?p3 ?o .
?p rdfs:label ?pl .
?t rdfs:label ?tl .
?p2 rdfs:label ?p2l .
?t2 rdfs:label ?t2l .
?p3 rdfs:label ?p3l .
?o a <http://dbpedia.org/ontology/Band> .
?o <http://dbpedia.org/property/name> ?ol .

FILTER (
(langMatches(lang(?ol), "en") || lang(?ol) = "" ) &&
(langMatches(lang(?pl), "en") || lang(?pl) = "" ) &&
(langMatches(lang(?tl), "en") || lang(?tl) = "" ) &&
(langMatches(lang(?p2l), "en") || lang(?p2l) = "" ) &&
(langMatches(lang(?t2l), "en") || lang(?t2l) = "" ) &&
(langMatches(lang(?p3l), "en") || lang(?p3l) = "" ) &&
?s != ?t2 && ?s != ?t && ?s != ?o
)
}
""" % (artist_name)
        print sparql
        dbpedia = SPARQLWrapper("http://dbpedia.org/sparql")
        dbpedia.setQuery(sparql)
        dbpedia.setReturnFormat(JSON)
        results = dbpedia.query().convert()
        sentence = artist_name
        r = results["results"]["bindings"]
        if len(r) == 0:
            return
        result = r[self.random.randint(0, len(r) - 1)]
        sentence += " has " + result["pl"]["value"]
        sentence += " " + result["tl"]["value"]
        sentence += " which has " + result["p2l"]["value"]
        sentence += " " + result["t2l"]["value"]
        sentence += "  which has " + result["p3l"]["value"]
        sentence += " " + result["ol"]["value"]
        self.connection.privmsg(self.channel, "say:"+ sentence.encode('ascii', 'ignore'))

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
