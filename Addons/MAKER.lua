-- =======================================================================================
-- Plugin: MAKER.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: Able to copy one sequence into the user's selected executor's sequence.
--				This copy will be placed into the selected executor's sequence's next cue.
-- =======================================================================================



















-- =======================================================================================
-- ==== MAIN: MAKER ======================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
function maker.task.maker(localUser)
	-- variables needed from SETUP plugin
	local user = localUser
	local cpySeqMAKER = maker.find.pool(user, "SONGS", caller)
	if (cpySeqMAKER == false) then
		maker.util.error(nil, nil, caller)
		return false
	end

    local makerVar = 'MAKER' 	-- User Variable used in grandMA2 software
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
	if (maker.find.pool(user, "MAKER", caller) == false) then
		maker.util.error("Could not find self in Setup.", nil, caller)
		return false
	end


	-- Information about your selected executor and what cue you are currently on
	local SelSeqHand = G_OBJ.parent(G_OBJ.handle("Cue 1"))
	local SelSeqNumber = tonumber(G_PRO.get(SelSeqHand , "No."))
	local SelSeqName = "Sequence " ..G_PRO.get(SelSeqHand , "No.")
	local SelSeqAmou = G_OBJ.amount(SelSeqHand) - 1
	local SelSeqLNum = G_OBJ.number(G_OBJ.child(SelSeqHand , SelSeqAmou))

	-- Get the string from user variable makerVar
	local songVar = gma.user.getvar(makerVar)
	-- check if it exists
	if(songVar == nil) then
		maker.util.error("UserVar \'" ..makerVar .."\' was not found.",
						nil,
						caller)
		return false;
	end

	-- this function returns user, task, and song name
	-- we only need the song name
	local _,_,songVar = maker.util.unpack(songVar, caller)

	-- check if it is a number; if so, assume they want to use the sequence number instead of label
	if(nil ~= (tonumber(songVar))) then
		gma.cmd("Copy Sequence " ..songVar .." Cue 1 Thru At " ..SelSeqName .." Cue " ..SelSeqLNum + 1 .." /o")
		gma.user.setvar(makerVar , nil)
		return 0;
	end

	-- search sequence pool, starting from the localUser.songseq until you reach the first empty sequence
	-- matchSong will return the sequence number that matched with the makerVar variable string
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	local songDest = maker.find.count(user, 1, songVar, caller)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	-- if there was no match, prompt user and exit plugin...
	if (songDest == false) then
		maker.util.error(ESC_RED .."UserVar \'" ..makerVar .."\' string was not found in sequence library... " ..ESC_WHT .."Library Starts: " ..ESC_GRN .."Sequence " ..user.first[cpySeqMAKER],
						"Could not find " ..songVar .." in your song library \n\n Check your sequence song library \n and see if it exists!",
						caller)
		return false;
	end

	-- check to see if the user is trying to copy song into itself (they have the selected executor sequence the same as the requested song)
	if(songDest == SelSeqNumber) then
		maker.util.error(ESC_RED .."Plugin Error: Cannot import the current song into itself",
						"Cannot import the current song into itself\n\n" .."Selected Executor:\nSequence " ..SelSeqNumber .."\nRequested Song:\nSequence " ..songDest,
						caller)
		return false;
	end

	-- copy song into the selected executor sequence's next available cue
	gma.cmd("Copy Sequence " ..songDest .." Cue 1 Thru At " ..SelSeqName .." Cue " ..SelSeqLNum + 1 .." /o")
	gma.user.setvar(makerVar , nil)
	-- delete the user variable makerVar (in case the plugin accidentally is called twice)
end
-- =======================================================================================
-- ==== END OF MAKER =====================================================================
-- =======================================================================================
