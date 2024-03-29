-- =======================================================================================
-- Plugin: ADDER.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: Able to copy one sequence into the user's selected executor's sequence.
--				This copy will be placed into the selected executor's sequence's last cue.
-- =======================================================================================



















-- =======================================================================================
-- ==== MAIN: ADDER ======================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
function maker.task.adder(localUser)
	-- variables needed from SETUP plugin
	local user = localUser
	local cpySeqADDER = maker.find.pool(user, "SONGS", caller)
	if (cpySeqADDER == false) then
		maker.util.error(nil, nil, caller)
		return false
	end

    local makerVar = 'MAKER'	-- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)

	-- test sequence variables and pool size
	if not(maker.test.seq(user, caller)) then return false end
	if not(maker.test.pool(user, caller)) then return false end

	-- make sure for every addon, it has BOTH name and first variables
	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("You did not setup Maker+ completely!", nil, caller)
		return false
	end

	-- check if user SETUP the Adder settings
	if (maker.find.pool(user, "ADDER", caller) == false) then
		maker.util.error("Could not find self in Setup.", nil, caller)
		return false
	end

	-- Information about your selected executor and what cue you are currently on
	local CURRENTCUE = gma.show.getvar('SELECTEDEXECCUE')
	local NEXTCUE = CURRENTCUE + 1
	local SelSeqHand = G_OBJ.parent(G_OBJ.handle("Cue 1"))
	local SelSeqNumber = tonumber(G_PRO.get(SelSeqHand , "No."))
	local SelSeqName = "Sequence " ..G_PRO.get(SelSeqHand , "No.")
	local SelSeqAmou = G_OBJ.amount(SelSeqHand) - 1
	local SelSeqLNum = G_OBJ.number(G_OBJ.child(SelSeqHand , SelSeqAmou))
	local songDest


	-- Get the string from user variable makerVar
	local songVar = gma.user.getvar(makerVar)
	-- check if it exists
	if(songVar == nil) then
		maker.util.error(ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' was not found.",
						"User Variable \'" ..makerVar .."\' is not set for the song name! \n Must set user variable to song name to find song",
						caller)
		return -13;
	end

	-- this function returns user, task, and song name
	-- we only need the song name
	local _,_,songVar = maker.util.unpack(songVar, caller)

	-- check if it is a number; if so, assume they want to use the sequence number instead of label
	if(nil ~= (tonumber(songVar))) then
		songDest = songVar
	else
		-- search sequence pool, starting from the localUser.songseq until you reach the first empty sequence
		-- maker.find.count will return the sequence number that matched with the makerVar variable string
		gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
		songDest = maker.find.count(user, 1, songVar, caller)
		gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
		-- if there was no match, prompt user and exit plugin...
		if (songDest == false) then
			maker.util.error(ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' in the sequence library was not found.",
							"Could not find " ..songVar .." in your song library!\n\n Check your sequence song library\n and see if it exists!",
							caller)
			maker.util.print(ESC_RED .."Library Starts: " ..ESC_GRN .."Sequence " ..ESC_WHT ..user.first[cpySeqADDER])
			return -13;
		end
	end


	-- check to see if the user is trying to copy song into itself (they have the selected executor sequence the same as the requested song)
	if(songDest == SelSeqNumber) then
		maker.util.error(ESC_RED .."Plugin Error: Cannot import the current song into itself",
						"Cannot import the current song into itself\n\n" .."Selected Executor:\nSequence " ..SelSeqNumber .."\nRequested Song:\nSequence " ..songDest,
						caller)
		return -13;
	end

	-- get information about the requested song sequence
	local songHandle = G_OBJ.handle("Sequence " ..songDest)
	local songAmount = G_OBJ.number(G_OBJ.child(songHandle , G_OBJ.amount(songHandle) - 1))

	if((NEXTCUE + songAmount) > tonumber(SelSeqLNum)) then
		-- move cues to make room for song
		-- if move gets in the way of current selected executor sequence cues: use this
		gma.cmd("Move Cue " ..NEXTCUE .." Thru At Cue " ..NEXTCUE + songAmount)
		gma.sleep(0.1)
		gma.cmd("Copy Sequence " ..songDest .." Cue 1 Thru At " ..SelSeqName .." Cue " ..NEXTCUE .." /o")
		-- delete the user variable makerVar (in case the plugin accidentally is called twice)
		gma.user.setvar(makerVar , nil)
	else
		-- move cues to make room for song
		-- if move does not gets in the way of current selected executor sequence cues: use this
		gma.cmd("Move Cue " ..NEXTCUE .." Thru At Cue " ..SelSeqLNum + songAmount)
		gma.sleep(0.1)
		gma.cmd("Copy Sequence " ..songDest .." Cue 1 Thru At " ..SelSeqName .." Cue " ..NEXTCUE .." /o")
		-- delete the user variable makerVar (in case the plugin accidentally is called twice)
		gma.user.setvar(makerVar , nil)
	end

	if(gma.gui.confirm("Renumber this Sequence" , "Would you like to renumber all cues in this sequence to its index value?")) then
		maker.util.renumber(caller)
	end
end
-- =======================================================================================
-- ==== END OF ADDER =====================================================================
-- =======================================================================================
