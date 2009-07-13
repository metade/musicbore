#!/bin/bash

./irc_bots/connectionfinder.py irc.freenode.net "#bbcmusicbore" connectionfinder &
./irc_bots/placefinder.py irc.freenode.net "#bbcmusicbore" placefinder &
./irc_bots/trackfinder.py irc.freenode.net "#bbcmusicbore" trackfinder &
./irc_bots/hotnessfinder.py irc.freenode.net "#bbcmusicbore" hotnessfinder &
