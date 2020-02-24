-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: CONDENSE.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Description:
--
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus
















-- =======================================================================================
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================


-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== AUTOSIZE =========================================================================
-- Description: This will auto condense a pool but will stop until it reaches a gap more
--				two or otherwise will finish full library list
--
-- Inputs:
--		POOLSTRING		-- String of the requested pool you wish to investigate
--		POOLSTART		-- Starting pool object number
--		POOLSIZE		-- Column size width for view windows
--
-- Output: Number of last pool object in at least 2 gap
-- =======================================================================================
local function autoSize(poolString , poolStart , poolSize)
	local G_OBJ = gma.show.getobj
	local countPool = poolStart
	local stringCopy = poolString
	local poolHandle = G_OBJ.handle(poolString .." " ..countPool)
	local compensate = 0
	local boolContinue = false

	repeat
		if (0 == math.fmod(countPool + 1 , poolSize)) then
			countPool = countPool + 1
			compensate = 1
		end

		if (not(G_OBJ.verify(G_OBJ.handle(stringCopy .." " ..countPool + compensate)))) then
			if (not(G_OBJ.verify(G_OBJ.handle(stringCopy .." " ..countPool + 1 + compensate)))) then
				if (not(G_OBJ.verify(G_OBJ.handle(stringCopy .." " ..countPool + 2 + compensate)))) then
					boolContinue = true
					countPool = countPool - 1
				end
			end
		end
		countPool = countPool + 1
		compensate = 0
	until boolContinue

	return countPool;

end
-- ==== END OF AUTOSIZE ==================================================================


-- ==== MOVEOBJECT =======================================================================
-- Description: This will auto condense a pool but will stop until it reaches a gap more
--				two or otherwise will finish full library list
--
-- Inputs:
--		POOLSTRING		-- String of the requested pool you wish to investigate
--		POOLSTART		-- Starting pool object number
--		POOLSIZE		-- Column size width for view windows
--
-- Output: Nothing
-- =======================================================================================
local function moveObject(poolString , poolStart , poolEnd , poolSize)
	local G_OBJ = gma.show.getobj
	local loopIndex
	local counterGap = 1

	for loopIndex = poolStart , poolEnd , 1 do
		if (0 == math.fmod(loopIndex , poolSize)) then
			-- skip the most left pool object of a 16 wide pool
			goto skipSixteen
		end
		if (not(G_OBJ.verify(gma.show.getobj.handle(poolString  .." " ..loopIndex)))) then
			while ((not(G_OBJ.verify(G_OBJ.handle(poolString .." " ..loopIndex + counterGap)))) and (loopIndex + counterGap <= poolEnd)) do
				counterGap = counterGap + 1
			end

			if (loopIndex + counterGap <= poolEnd) then
				gma.cmd("Move " ..poolString .." " ..loopIndex + counterGap .." At " ..poolString .." " ..loopIndex)
				counterGap = 1
			end
		end
		::skipSixteen::
	end
end
-- ==== END OF MOVEOBJECT ================================================================


-- ==== INFOPROMPT =======================================================================
-- Description: Prompts the user for what is the last song in the library to condense.
--				User can leave textinput blank to call AutoSize function
--
-- Inputs:
--		POOLSTRING		-- String of the requested pool you wish to investigate
--		STRTITLE		-- GUI Title Input Title
--		STRAFFECT		-- Affected elements for Command Line Info
--		POOLSTART		-- Starting pool object number
--		POOLSIZE		-- Column size width for view windows
--
-- Output: Integer of last song is in pool to condense
-- =======================================================================================
local function infoPrompt(poolString , strTitle , strAffect , poolStart , poolSize)
	local boolContinue = true
	local libSizePool

	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid pool number for " ..poolString))) then
				gma.feedback(ESC_WHT .."CONDENSE : " ..ESC_RED .."Plugin Terminated. " ..strAffect .." library will not be moved.")
				gma.echo(ESC_WHT .."CONDENSE Plugin : " ..ESC_RED .."Plugin Terminated. " ..strAffect .." library will not be moved.")
				return -13
			end
		end

		-- ask user for a song name
		libSizePool = gma.textinput(strTitle , "Skip" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (libSizePool == nil) then
			gma.feedback(ESC_WHT .."CONDENSE : " ..ESC_RED .."Plugin Terminated. " ..strAffect .." library will not be moved.")
			gma.echo(ESC_WHT .."CONDENSE Plugin : " ..ESC_RED .."Plugin Terminated. " ..strAffect .." library will not be moved.")
			return -13;
		elseif (libSizePool == "") then
			gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
			libSizePool = autoSize(poolString , poolStart , poolSize);
			gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
		elseif (libSizePool == "Skip") then
			return "Skip"
		elseif (tonumber(libSizePool) == nil) then
			boolContinue = false
		end

	until boolContinue

	return tonumber(libSizePool)
end
-- ==== END OF INFOPROMPT ================================================================

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================














-- =======================================================================================
-- ==== MAIN: CONDENSE ===================================================================
-- =======================================================================================

local function CONDENSE()
	local sSeqCopy = localUser.song_seq
	local sMakerCopy = localUser.maker
	local sAdderCopy = localUser.adder
	local localPoolSize = localUser.pool_size

	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	if(type(sSeqCopy) ~= "number") or (type(sMakerCopy) ~= "number") or (type(sAdderCopy) ~= "number") then
		gma.gui.msgbox("ERROR" , "CONDENSE Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
		gma.feedback(ESC_WHT .."CONDENSE : " ..ESC_RED .."Plugin Error. CONDENSE is not setup.")
		gma.echo(ESC_WHT .."CONDENSE Plugin : " ..ESC_RED .."Plugin Error. CONDENSE is not setup.")
		return -13;
	end

	if(type(localPoolSize) ~= "number") then
		gma.gui.msgbox("ERROR" , "CONDENSE Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!")
		gma.feedback(ESC_WHT .."CONDENSE : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		gma.echo(ESC_WHT .."CONDENSE Plugin : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		return -13;
	elseif(localPoolSize <= 1) then
		gma.gui.msgbox("ERROR" , "CONDENSE Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!")
		gma.feedback(ESC_WHT .."CONDENSE : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		gma.echo(ESC_WHT .."CONDENSE Plugin : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		return -13;
	end

	local libSizePool

	libSizePool = infoPrompt("Sequence" ,"Sequence Ending?" , "All" , sSeqCopy , localPoolSize)
	if (libSizePool == -13) then return -13 end
	if (libSizePool == "Skip") then goto spaghettiSONG end
	libSizePool = tonumber(libSizePool)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	moveObject("Sequence" , sSeqCopy , libSizePool , localPoolSize)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	::spaghettiSONG::

	libSizePool = infoPrompt("Macro" ,"Macro Ending for Maker?" , "Maker & Adder" , sMakerCopy , localPoolSize)
	if (libSizePool == -13) then return -13 end
	if (libSizePool == "Skip") then goto spaghettiMAKER end
	libSizePool = tonumber(libSizePool)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	moveObject("Macro" , sMakerCopy , libSizePool , localPoolSize)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	::spaghettiMAKER::

	libSizePool = infoPrompt("Macro" ,"Macro Ending for Adder?" , "Adder" , sAdderCopy , localPoolSize)
	if (libSizePool == -13) then return -13 end
	if (libSizePool == "Skip") then goto spaghettiADDER end
	libSizePool = tonumber(libSizePool)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	moveObject("Macro" , sAdderCopy , libSizePool , localPoolSize)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	::spaghettiADDER::


end

return CONDENSE;
