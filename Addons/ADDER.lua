-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: ADDER.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
-- =======================================================================================
-- Description: Able to copy one sequence into the user's selected executor's sequence.
--				This copy will be placed into the selected executor's sequence's next cue.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus
















-- =======================================================================================
-- ==== MAIN: ADDER ======================================================================
-- =======================================================================================
local function ADDER()
	-- variables needed from SETUP plugin
	local user = localUser
	local cpySeqADDER = user.song_seq
	local localPoolSize = user.pool_size
	local currPool
	local caller = "ADDER"

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)

	if not(maker.test.seq(user, caller)) then return false end
	if not(maker.test.pool(user, caller)) then return false end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("You did not setup Maker+ completely!", nil, caller)
		return false
	end

	local bContinue = true
	local poolIndex
	for i=1, macroAmount do
		currPool = maker.manage("Pool", user, i)
		if(currPool:upper() == me) then
			bContinue = false
			poolIndex = i
			break
		end
	end

	if not(bContinue) then
		maker.util.error("Could not find self in Setup.", nil, caller)
		return false
	end

	-- all local variables needed for function ADDER
	-- shortcut for GMA show objects
	local G_OBJ = gma.show.getobj
	local G_PRO = gma.show.property

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
			maker.util.print(ESC_RED .."Library Starts: " ..ESC_GRN .."Sequence " ..ESC_WHT ..cpySeqMAKER)
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
end
-- =======================================================================================
-- ==== END OF ADDER =====================================================================
-- =======================================================================================

return ADDER;
