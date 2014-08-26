This is a small wrapper utility around avplay to play your radio stations from cmdline, emacs ...etc.
To run:

$radio   (or) ./radio

This will give you a radio prompt
the following commands can be giben at the prompt

radio>h       ==> will give the usage: help

radio>list    ==> will list station codes and description.

radio><station-code>    ==> will play the station, you can provide another station any time. The previously opened station will close.

radio>fl  xxx   ==> filter list based on the string xxx to match any part of description

radio>add       ==> to add a new station. <station-code> and <description> will be prompted

radio>stop      ==> to stop the current station.

radio>quit      ==> to quit the radio

[features yet to be added]
1. stream metadata
2. auto stop
3. stop/restsrt station when screen-lock or screen-inactive
4. copy a track
5. autustart/switch stations at scheduled times     
 
