-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: ADDER.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Description: Able to copy one sequence into the user's selected executor's sequence.
--				This copy will be placed into the selected executor's sequence's next cue.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus
















-- =======================================================================================
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================


-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== MATCHSONG ========================================================================
-- Description: Checks a continuous list of sequences to see if it's name already exists.
--				It must be entirely right without case-sensitivity.
--
-- Inputs:
--		POOL			-- Name of the pool
--		STARTSEQ		-- Number of starting sequence to scan
-- 		SNAME			-- String name
--		POOLSIZE		-- How many columns do you use for your pool view
--
-- Output: Returns number times name matched with other macros labels
-- =======================================================================================
local function matchSong(pool , startSeq ,sName , poolSize)
	local G_OBJ = gma.show.getobj
	local manipName = string.upper(sName)
	local countPoolNum = startSeq
	local poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)

	-- loop to find other version of the song ending with " ...V"
	while G_OBJ.verify(poolHandle) do

		-- compare song name to upper case version of analyzing macro
		if (manipName == string.upper(G_OBJ.label(G_OBJ.handle("Sequence " ..countPoolNum)))) then
			return countPoolNum;
		end

		-- skip if it is in the left most side of a poolSize wide pool view
		if (0 == math.fmod(countPoolNum + 1 , poolSize)) then
			countPoolNum = countPoolNum + 1
		end
		countPoolNum = countPoolNum + 1
		poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)
	end

	return false;
end
-- ==== END OF MATCHSONG =================================================================

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================





-- =======================================================================================
-- ==== MAIN: ADDER ======================================================================
-- =======================================================================================
local function ADDER()
	-- variables needed from SETUP plugin
	local cpySeqADDER = localUser.song_seq
	local localPoolSize = localUser.pool_size

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)

	-- escape codes for system monitor. able to color string of text
	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	-- check if variables from SETUP plugin exist
	if(type(cpySeqADDER) ~= "number") then
		-- cannot setup adder macro number as nil or string
		gma.gui.msgbox("ERROR" , "ADDER Plugin was NOT setup!\nPlease setup where the song library must start in the sequence pool!")
		gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. song_seq is not setup.")
		gma.echo(ESC_WHT .."ADDER Plugin : " ..ESC_RED .."Plugin Error. song_seq is not setup.")
		return -13;
	end

	if(type(localPoolSize) ~= "number") then
		-- cannot setup pool size as nil or string
		gma.gui.msgbox("ERROR" , "ADDER Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!")
		gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		gma.echo(ESC_WHT .."ADDER Plugin : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		return -13;
	elseif(localPoolSize <= 1) then
		-- pool size is too small
		gma.gui.msgbox("ERROR" , "ADDER Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!")
		gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		gma.echo(ESC_WHT .."ADDER Plugin : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		return -13;
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
		gma.gui.msgbox("ERROR" , "User Variable \'" ..makerVar .."\' is not set for the song name! \n Must set user variable to song name to find song")
		gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' was not found.")
		gma.echo(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' was not found.")
		return -13;
	end

	-- check if it is a number; if so, assume they want to use the sequence number instead of label
	if(nil ~= (tonumber(songVar))) then
		songDest = songVar
	else
		-- search sequence pool, starting from the localUser.songseq until you reach the first empty sequence
		-- matchSong will return the sequence number that matched with the makerVar variable string
		gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
		songDest = matchSong("Sequence" , cpySeqADDER , songVar , localPoolSize)
		gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
		-- if there was no match, prompt user and exit plugin...
		if (songDest == false) then
			gma.gui.msgbox("ERROR" , "Could not find " ..songVar .." in your song library!\n\n Check your sequence song library\n and see if it exists!")
			gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' in the sequence library was not found.")
			gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Library Starts: " ..ESC_GRN .."Sequence " ..ESC_WHT ..cpySeqMAKER)
			gma.echo(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' in the sequence library was not found.")
			gma.echo(ESC_WHT .."ADDER : " ..ESC_RED .."Library Starts: " ..ESC_GRN .."Sequence " ..ESC_WHT ..cpySeqMAKER)
			return -13;
		end
	end


	-- check to see if the user is trying to copy song into itself (they have the selected executor sequence the same as the requested song)
	if(songDest == SelSeqNumber) then
		gma.gui.msgbox("ERROR" , "Cannot import the current song into itself\n\n" .."Selected Executor:\nSequence " ..SelSeqNumber .."\nRequested Song:\nSequence " ..songDest)
		gma.feedback(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error: Cannot import the current song into itself")
		gma.echo(ESC_WHT .."ADDER : " ..ESC_RED .."Plugin Error: Cannot import the current song into itself")
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