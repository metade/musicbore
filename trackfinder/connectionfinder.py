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
        if e.arguments()[0].startswith("notracks") and self.last_artist_name != "":
            self.connection.privmsg(self.channel, "trackfinder:"+self.last_artist_name)
            
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

    def do_command(self, e, cmd, results = []):
        artist_name = ""
        if cmd.startswith("http://dbpedia.org"):
            uri = cmd
            sparql = """
SELECT ?pl ?tl ?p2l ?t2l ?p3l ?ol ?o ?sl WHERE {
<%s> ?p ?t ; <http://dbpedia.org/property/name> ?sl.
?t ?p2 ?t2 .
?t2 ?p3 ?o .
?p rdfs:label ?pl .
?t rdfs:label ?tl .
?p2 rdfs:label ?p2l .
?t2 rdfs:label ?t2l .
?p3 rdfs:label ?p3l .
?o <http://dbpedia.org/property/wikiPageUsesTemplate> <http://dbpedia.org/resource/Template:infobox_musical_artist> .
?o <http://dbpedia.org/property/name> ?ol .

FILTER (
(langMatches(lang(?sl), "en") || lang(?sl) = "" ) &&
(langMatches(lang(?ol), "en") || lang(?ol) = "" ) &&
(langMatches(lang(?pl), "en") || lang(?pl) = "" ) &&
(langMatches(lang(?tl), "en") || lang(?tl) = "" ) &&
(langMatches(lang(?p2l), "en") || lang(?p2l) = "" ) &&
(langMatches(lang(?t2l), "en") || lang(?t2l) = "" ) &&
(langMatches(lang(?p3l), "en") || lang(?p3l) = "" ) &&
(<%s> != ?t2 && <%s> != ?t && <%s> != ?o && ?t != ?t2 && ?t != ?o && ?t2 != ?o) &&
(str(?p) != "http://dbpedia.org/ontology/genre") &&
(str(?p2) != "http://dbpedia.org/ontology/genre")
)
}
""" % (uri, uri, uri, uri)
        else:
            artist_name = cmd
            sparql = """
SELECT ?pl ?tl ?p2l ?t2l ?p3l ?ol ?o WHERE {
?s <http://dbpedia.org/property/name> "%s"@en .
?s a <http://dbpedia.org/ontology/Band> ; ?p ?t .
?t ?p2 ?t2 .
?t2 ?p3 ?o .
?p rdfs:label ?pl .
?t rdfs:label ?tl .
?p2 rdfs:label ?p2l .
?t2 rdfs:label ?t2l .
?p3 rdfs:label ?p3l .
?o <http://dbpedia.org/property/wikiPageUsesTemplate> <http://dbpedia.org/resource/Template:infobox_musical_artist> .
?o <http://dbpedia.org/property/name> ?ol .

FILTER (
(langMatches(lang(?ol), "en") || lang(?ol) = "" ) &&
(langMatches(lang(?pl), "en") || lang(?pl) = "" ) &&
(langMatches(lang(?tl), "en") || lang(?tl) = "" ) &&
(langMatches(lang(?p2l), "en") || lang(?p2l) = "" ) &&
(langMatches(lang(?t2l), "en") || lang(?t2l) = "" ) &&
(langMatches(lang(?p3l), "en") || lang(?p3l) = "" ) &&
(?s != ?t2 && ?s != ?t && ?s != ?o && ?t != ?t2 && ?t != ?o && ?t2 != ?o) &&
(str(?p) != "http://dbpedia.org/ontology/genre") &&
(str(?p2) != "http://dbpedia.org/ontology/genre")
)
}
""" % (artist_name)
        print sparql
        dbpedia = SPARQLWrapper("http://dbpedia.org/sparql")
        dbpedia.setQuery(sparql)
        dbpedia.setReturnFormat(JSON)
        if results == []:
            results = dbpedia.query().convert()
        r = results["results"]["bindings"]
        if len(r) == 0:
            self.connection.privmsg(self.channel, "No connections found")
            return
        talis = SPARQLWrapper("http://api.talis.com/stores/bbc-backstage/services/sparql")
        result = r[self.random.randint(0, len(r) - 1)]
        talis_sparql = """PREFIX owl: <http://www.w3.org/2002/07/owl#> SELECT ?a WHERE  {?a owl:sameAs <""" + result["o"]["value"]+ """>  FILTER (regex(str(?a), "^http://www.bbc" )) }"""
        talis.setQuery(talis_sparql)
        print talis_sparql
        talis.setReturnFormat(XML)
        talis_results = talis.query().convert()
        bbc_uri = ""
        try:
            bbc_uri = talis_results.childNodes[1].childNodes[3].childNodes[1].childNodes[1].childNodes[1].childNodes[0].data
        except:
            self.do_command(e, cmd, results)
            return
        if bbc_uri == "":
            return
        print bbc_uri
        if result["ol"]["value"] in self.played_artists:
            self.do_command(e, cmd, results)
            return
        if cmd.startswith("http://dbpedia.org"):
            artist_name = result["sl"]["value"]
        sentence = artist_name
        sentence += " has " + self.prop(result["pl"]["value"])
        sentence += " " + result["tl"]["value"]
        sentence += " which has " + self.prop(result["p2l"]["value"])
        sentence += " " + result["t2l"]["value"]
        sentence += "  which has " + self.prop(result["p3l"]["value"])
        sentence += " " + result["ol"]["value"]
        self.connection.privmsg(self.channel, "say:"+ sentence.encode('ascii', 'ignore'))
        time.sleep(3)
        self.last_artist_name = result["ol"]["value"]
        self.played_artists.append(self.last_artist_name)
        self.connection.privmsg(self.channel, "playartist:"+bbc_uri)
        time.sleep(15)
        if cmd.startswith("http://dbpedia.org"):
            self.connection.privmsg(self.channel, "thebore:"+bbc_uri)

    def prop(self, p):
        if p == 'associatedMusicalArtist' or p == 'associatedBand':
            return 'played with'
        return p

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
