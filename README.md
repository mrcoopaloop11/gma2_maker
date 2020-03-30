MAKER
-- Places a song after the last cue
-- Uses the $MAKER user variable
-- Sets the $MAKER user variable as nothing at end of plugin
-- Looks through the sequence library for song name
-- Can ignore the label name and use the number of the sequence
-- Searching songs are not case-sensitive
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


ALT_MAKER
-- Places a asset after the last cue
-- Uses the $MAKER user variable
-- Sets the $MAKER user variable as nothing at end of plugin
-- Looks through the sequence library for song name
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


ADDER
-- Adds a song to the next cue
-- Uses the $MAKER user variable
-- Sets the $MAKER user variable as nothing at end of plugin
-- Looks through the sequence library for song name
-- Can ignore the label name and use the number of the sequence
-- Searching songs are not case-sensitive
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


ALT_ADDER
-- Adds a asset to the next cue
-- Uses the $MAKER user variable
-- Sets the $MAKER user variable as nothing at end of plugin
-- Looks through the sequence library for song name
-- Ignores the left most column of your sequence/macro pool (You choose column size!)



ARCHIVE
-- Creates a new sequence for your service
-- Labels sequence the upcoming Sunday's date if $MAKER user variable is not set
-- Asks what to label the sequence if $MAKER user variable is set to zero


NEWSONG
-- Creates sequence and macros for new song
-- Assigns song onto the selected executor
-- Not able to name a song with punctuation
-- Not able to name a song with specific version number
-- Naming songs are not case-sensitive
-- Desired group can store default values to first cue of song (Important for tracking!)
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


COPYSONG
-- Copies a song and creates another version
-- Can type the name of the song they would like copy
-- Can type the number of the song they would like copy
-- Rename the sequence label and the first cue
-- Rename the MAKER and ADDER macro labels
-- Rename the MAKER and ADDDER macro first line name
-- Assigns song onto the selected executor
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


RENAME
-- Relabel a song and the maker and adder macros
-- Can type the name of the song they would like rename
-- Can type the number of the song they would rename
-- Not able to name a song with punctuation
-- Not able to name a song with specific version number
-- Searching songs are not case-sensitive
-- Naming songs are not case-sensitive
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


EDITSONG
-- Places a song onto the selected executor
-- Can type the name of the song they would like edit
-- Can type the number of the song they would like edit
-- Searching songs are not case-sensitive
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


DELETESONG
-- Deletes the sequence and 2 macros (MAKER and ADDER) from your song library
-- Can type the name of the song they would like edit
-- Can type the number of the song they would like edit
-- Searching songs are not case-sensitive
-- Ignores the left most column of your sequence/macro pool (You choose column size!)
-- Gives you the option to condense MAKER+ libraries [NOTE: It condenses all of them]


CONDENSE
-- Helps condense your library for sequence pool
-- Helps condense your library for MAKER macro pool
-- Helps condense your library for ADDER macro pool
-- Type number of last sequence/macro that is in your library to condense all in that range
-- If you leave the text input blank: SHORTCUT condenses until it reaches something that has more than 3 spaces
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


FINDER
-- Search for a song
-- Will blink the song sequence and MAKER and ADDER macros
-- Turns the sequence/macro white and then resets the color
-- Searching songs are not case-sensitive
-- Can use '-m ' before typing the song they wish to find ; Using MAKER after search ends
-- Can use '-a ' before typing the song they wish to find ; Using ADDER after search ends
-- Can use '-e ' before typing the song they wish to find ; Assigning song to selected executor
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


REALPHA
-- Reorganizes pool to alphabetical order within a continuous list
-- Ignores the left most column of your sequence/macro pool (You choose column size!)


SETUP
-- MAKE SURE THAT THIS IS PLUGIN IS BEFORE ALL OTHER PLUGINS OF MAKER+ IN POOL
-- Manage multiple users of Maker+ and where data is stored
-- All other Maker+ plugins reference the SETUP plugin for where to put their data
-- If you make any changes in the SETUP plugin, exit MA editor and press SETUP plugin
-- TIP: Users variables could, if desired, point to the same place as another users





MAKER API FUNCTIONS:

maker.util.print(message, caller)
maker.util.error(message, extra, caller)
maker.util.prompt(pool, caller)
maker.util.input(user, poolIndex, strTitle, caller)
maker.util.underVer(oldName, pool, verNum, caller)
maker.util.round(num, numDecimalPlaces, caller)
maker.util.thru(numArray, caller)
maker.util.group(option, caller)
maker.util.date(offset, caller)
maker.util.weekday(reqDofW, caller)
maker.util.timeTravel(user, caller)

maker.test.count(user, caller)
maker.test.pool(user, caller)
maker.test.seq(user, caller)
maker.test.archive(user, caller)

maker.find.pool(user, poolName, caller)
maker.find.operand(user, songName, caller)

maker.find.avail(user, poolIndex, caller)
maker.find.last(user, poolIndex, caller)
maker.find.gap(user, poolIndex, caller)
maker.find.count(user, poolIndex, sName, caller)

maker.find.ver.next(user, poolIndex, sName, caller)
maker.find.ver.count(user, poolIndex, sName, caller)
maker.find.ver.match(user, poolIndex, strName, caller)
maker.find.ver.pick(user, songName, caller)

maker.move.obj(user, poolIndex, caller)
maker.move.alpha(user, poolIndex, caller)

maker.request(user, poolIndex, seqArray, caller)

maker.repair(user, poolIndex, caller)
