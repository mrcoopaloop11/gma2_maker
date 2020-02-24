-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: NEWSONG.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Input for plugin:
-- 			1. Group with all programmable fixtures (Called "All")
-- =======================================================================================
-- Plugin Description: Creates a sequence and macro pairing so that you may archive for
--					   later use. Plugin will assign new sequence to selected executor.
--
--		Sequence:
--		1. Creates new sequence with two cues
--		2. Stores first cue with default values from a group called “All”
--		3. Names the Sequence the song name (replaces spaces for ‘_’ )
--		4. Names the first cue 'S - ' and then the song name
--				- 'S - ' Being used to later change to 'S1' or 'S2' to indicate order
--				   of songs in the service
--		5. Changes the color of the first cue to an orange (/r=50.2 /g=36.9 /b=0)
--
--		Macro:
--		1. Creates macro with 9 lines (Creates User Variables but removes in the end)
--		2. Names the macro to the song name
--
--
-- Macro Description: The macro changes your selected executor cue to the last cue of
-- 					  the selected executor sequence. It then copies the desired song
-- 					  into the bottom of the selected executor cue list.

-- TIPS:
-- 		1. When finishing a song, create an 'OUT' cue that ends your effects. This will
--		   come in handy for when you copy the song into your master service sequence.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus











-- =======================================================================================
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================



-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== OBJECTFINDER =====================================================================
-- Description: Finds the next available empty spot in a pool to store something
--
-- Inputs:
--		POOL		-- String that has MA pool specifier (i.e. Sequence, Macro...)
--		POOLNUMBER	-- Starting number to analyze next available pool space
--		POOLSIZE	-- Column size of view window
--
-- Output: Returns an empty pool space
-- =======================================================================================
local function objectFinder(pool , poolNumber , poolSize)
	local G_OBJ = gma.show.getobj
	local poolHandle = G_OBJ.handle(pool .." " ..poolNumber)
	local countPoolNum = poolNumber

	-- check if pool object already exists
	while G_OBJ.verify(poolHandle) do
		-- check if number is along the left side of a 16 wide pool view
		-- this will align the pool objects to be easier to find while scrolling in pool
		if (0 == math.fmod(countPoolNum + 1 , poolSize)) then
			-- skip the most left pool object of a 16 wide pool
			countPoolNum = countPoolNum + 1
		end

		-- pool object exists
		-- check the next one and update poolHandle variable for test
		countPoolNum = countPoolNum + 1
		poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)
	end

	-- empty pool object was found!
	-- return number of empty pool object
	return countPoolNum;
end
-- ==== END OF OBJECTFINDER ==============================================================



-- ==== PREVIOUSVERSION ==================================================================
-- Description: Checks a continuous list of sequences to see if it's name already exists.
--				Can only make 10 versions of the same song.
--
-- Inputs:
--		STARTSEQ		-- Number of starting sequence to scan
--		ENDSEQ			-- Number of ending sequence to stop scanning
-- 		SNAME			-- String name
--		POOLSIZE	-- Column size of view window
--
-- Output: Returns number times name matched with other macros labels
-- =======================================================================================

local function previousVersion(startSeq , endSeq , sName , poolSize)
	local G_OBJ = gma.show.getobj
	local manipName = string.gsub(sName:upper() , " " , "_") -- Convert to upper case to find all versions
	local tempSong
	local seqIndex
	local occurance = 1
	local verArray = {}


	-- loop to find other version of the song ending with " ...V"
	for seqIndex = startSeq , endSeq - 1 , 1 do
		-- skip if it is in the left most side of a 16 wide pool view
		if (0 ~= math.fmod(seqIndex , poolSize)) then
			tempSong = G_OBJ.label(G_OBJ.handle("Sequence " ..seqIndex))
			-- compare song name to upper case version of analyzing macro
			if (manipName == tempSong:upper()) then
				-- increment version counter by one
				verArray[occurance] = 1
				occurance = occurance + 1
			end

			if (tempSong:upper():match(manipName:upper() .."_V%d+")) then
				-- increment version counter by one
				verArray[occurance] = tonumber(tempSong:upper():match(manipName:upper() .."_V(%d+)"))
				occurance = occurance + 1
			end
		end
	end

	-- Checks for all versions of song
	-- Re organizes it so they are numbered contiguously
	-- Returns the next available version
	if (#verArray == 0) then
		return 1
	end
	local a
	local b
	local bContinue = true
	table.sort(verArray)

	for a = 1 , #verArray + 1 do
		for b = 1 , #verArray + 1 do
			if (a == verArray[b]) then
				bContinue = false
			end
		end
		if (bContinue) then
			return a
		end
		bContinue = true
	end
end
-- ==== END OF PREVIOUSVERSION ===========================================================



-- ==== CUEMODESEL =======================================================================
-- Description: Assign the cue mode for the first cue... If option does not match any mode
--				assume that user wants to default a group with the label of the option var
--
-- Inputs:
--		OPTION		-- String || Could be cue mode option or label of group
--
-- Output: Nothing
-- =======================================================================================
local function cueModeSel(option)
	if("Normal" == option) then
		gma.cmd("Assign Cue 1 /mode=Normal")
	elseif("Assert" == option) then
		gma.cmd("Assign Cue 1 /mode=Assert")
	elseif("X-Assert" == option) then
		gma.cmd("Assign Cue 1 /mode=X-Assert")
	elseif("Release" == option) then
		gma.cmd("Assign Cue 1 /mode=Release")
	elseif("Break" == option) then
		gma.cmd("Assign Cue 1 /mode=Break")
	elseif("X-Break" == option) then
		gma.cmd("Assign Cue 1 /mode=X-Break")
	else
		if(nil ~= tonumber(option)) then
			-- Option is a group number
			gma.cmd("Group " ..option .." Default")
		else
			-- Option is a label name for the group
			gma.cmd("Group \"" ..option .."\" Default")
		end
	end
end
-- ==== END OF CUEMODESEL ================================================================

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================



















-- =======================================================================================
-- ==== MAIN: NEWSONG ====================================================================
-- =======================================================================================

local function NEWSONG()
	-- store global variables (on the very top of plugin editor) to local variables
	-- this ensures every run will update a new starting pool number
	local updateSequence = localUser.song_seq
	local updateMMacro = localUser.maker
	local updateAMacro = localUser.adder
	local localPoolSize = localUser.pool_size
	local makerPlugin = localUser.pluginMAKER
    local adderPlugin = localUser.pluginADDER
	local modeCueOpt = localUser.group

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)


	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	if(type(updateSequence) ~= "number") or (type(updateMMacro) ~= "number") or (type(updateAMacro) ~= "number") then
		gma.gui.msgbox("ERROR" , "NEWSONG Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
		gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Error. NEWSONG is not setup.")
		gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Error. NEWSONG is not setup.")
		return -13;
	end

	if(type(localPoolSize) ~= "number") then
		gma.gui.msgbox("ERROR" , "NEWSONG Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!")
		gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		return -13;
	elseif(localPoolSize <= 1) then
		gma.gui.msgbox("ERROR" , "NEWSONG Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!")
		gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		return -13;
	end

	if(type(makerPlugin) ~= "string") or (type(adderPlugin) ~= "string") then
		gma.gui.msgbox("ERROR" , "NEWSONG Plugin was NOT setup!\nPlease identify what your labels are for MAKER plugin or ADDER plugin!")
		gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Error. Identify labels for MAKER/ADDER plugins in SETUP Plugin.")
		gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Error. Identify labels for MAKER/ADDER plugins in SETUP Plugin.")
		return -13;
	end

	if makerPlugin:match("%s") or adderPlugin:match("%s") then
		gma.gui.msgbox("ERROR" , "NEWSONG Plugin was NOT correctly setup!\nNo whitespace in label for MAKER/ADDER plugin!")
		gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Error. No whitespace in label for MAKER/ADDER plugin.")
		gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Error. No whitespace in label for MAKER/ADDER plugin.")
		return -13;
	end


	local songName
	local boolContinue = true

	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure there are no special characters"))) then
				gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Terminated. Song not created.")
				gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
				return -13
			end
		end

		-- ask user for a song name
		songName = gma.textinput("Name of the Song?" , "" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (songName == nil) then
			gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_RED .."Plugin Terminated. Song not created.")
			gma.echo(ESC_WHT .."NEWSONG Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
			return -13
		elseif (songName == "") then
			boolContinue = false
		end
		-- detect if song name has punctuation in it
		if (string.match(songName , '%p..')) then
			boolContinue = false
		end

	until boolContinue

	-- if the user requested to manually place a version number, this statement will remove the version they are requesting
	-- program will take over and discover what version to pick
	if (songName:find(" V%d+")) then
		--a = songName:match(" V(%d+)")
		songName = songName:gsub(" V%d+" , "")
	end
	-- convert song name spaces with underscores for sequence label
	local singleString = string.gsub(songName , " " , "_")


	-- call functions to find next available pool number
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	local availSeq   = objectFinder("Sequence" , updateSequence , localPoolSize)
	local availMMacro = objectFinder("Macro" , updateMMacro , localPoolSize)
	local availAMacro = objectFinder("Macro" , updateAMacro , localPoolSize)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")


	-- create a new song (sequence and macro objects)
	-- call function to check for previous versions of a song
	local versionNumber = previousVersion(updateSequence , availSeq , songName , localPoolSize)
	if (versionNumber ~= 1) then
		-- for multiple version of the same song
		gma.cmd("ClearAll")
		gma.sleep(0.1)
		cueModeSel(modeCueOpt)
		gma.cmd("Store Sequence " ..availSeq .." Cue 1")
		gma.cmd("ClearAll")
		--gma.sleep(0.1)
		gma.cmd("Store Sequence " ..availSeq .." Cue 2 /o")
		gma.cmd("Store Macro " ..availMMacro)
		gma.cmd("Store Macro 1." ..availMMacro ..".1 thru Macro 1." ..availMMacro ..".3")
		gma.cmd("Store Macro " ..availAMacro)
		gma.cmd("Store Macro 1." ..availAMacro ..".1 thru Macro 1." ..availAMacro ..".3")

		gma.cmd("Label Sequence " ..availSeq .." \"" ..singleString .."_V" ..versionNumber .."\"")
		gma.cmd("Label Macro " ..availMMacro .." \"" ..songName .." V" ..versionNumber .."\"")
		gma.cmd("Label Macro " ..availAMacro .." \"" ..songName .." V" ..versionNumber .."\"")
		gma.cmd("Label Sequence " ..availSeq .." Cue 1 \"S - " ..songName)
		gma.cmd("Appearance Sequence " ..availSeq .." Cue 1 /r=50.2 /g=36.9 /b=0")

		gma.cmd("Assign Macro 1." ..availMMacro ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."_V" ..versionNumber .."\"")
		gma.cmd("Assign Macro 1." ..availMMacro ..".2 ")
		gma.cmd("Assign Macro 1." ..availMMacro ..".3 /cmd=\"Plugin " ..makerPlugin .."\"")

		gma.cmd("Assign Macro 1." ..availAMacro ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."_V" ..versionNumber .."\"")
		gma.cmd("Assign Macro 1." ..availAMacro ..".2 ")
		gma.cmd("Assign Macro 1." ..availAMacro ..".3 /cmd=\"Plugin " ..adderPlugin .."\"")

		gma.cmd("Assign Sequence " ..availSeq .." Cue 1 /MIB=Early /Info=\"HL: %\"")

	else
		-- for first song ever made
		gma.cmd("ClearAll")
		gma.sleep(0.1)
		cueModeSel(modeCueOpt)
		gma.cmd("Store Sequence " ..availSeq .." Cue 1")
		gma.cmd("ClearAll")
		--gma.sleep(0.1)
		gma.cmd("Store Sequence " ..availSeq .." Cue 2 /o")
		gma.cmd("Store Macro " ..availMMacro)
		gma.cmd("Store Macro 1." ..availMMacro ..".1 thru Macro 1." ..availMMacro ..".3")
		gma.cmd("Store Macro " ..availAMacro)
		gma.cmd("Store Macro 1." ..availAMacro ..".1 thru Macro 1." ..availAMacro ..".3")

		gma.cmd("Label Sequence " ..availSeq .." \"" ..singleString .."\"")
		gma.cmd("Label Macro " ..availMMacro .." \"" ..songName .."\"")
		gma.cmd("Label Macro " ..availAMacro .." \"" ..songName .."\"")
		gma.cmd("Label Sequence " ..availSeq .." Cue 1 \"S - " ..songName)
		gma.cmd("Appearance Sequence " ..availSeq .." Cue 1 /r=50.2 /g=36.9 /b=0")

		gma.cmd("Assign Macro 1." ..availMMacro ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."\"")
		gma.cmd("Assign Macro 1." ..availMMacro ..".2 ")
		gma.cmd("Assign Macro 1." ..availMMacro ..".3 /cmd=\"Plugin " ..makerPlugin .."\"")


		gma.cmd("Assign Macro 1." ..availAMacro ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."\"")
		gma.cmd("Assign Macro 1." ..availAMacro ..".2 ")
		gma.cmd("Assign Macro 1." ..availAMacro ..".3 /cmd=\"Plugin " ..adderPlugin .."\"")

		gma.cmd("Assign Sequence " ..availSeq .." Cue 1 /MIB=Early /Info=\"HL: %\"")

	end



	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_YEL .."========================================")
	gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_YEL .."Name  &  Version: " ..ESC_WHT ..songName .." V" ..versionNumber)
	gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_YEL .."Created Sequence: " ..ESC_GRN .."Sequence " ..ESC_WHT ..availSeq)
	gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_YEL .."Created    Maker: " ..ESC_GRN .."Macro " ..ESC_WHT ..availMMacro)
	gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_YEL .."Created    Adder: " ..ESC_GRN .."Macro " ..ESC_WHT ..availAMacro)
	gma.feedback(ESC_WHT .."NEWSONG : " ..ESC_YEL .."========================================")



	-- Assign the new sequence to the selected executor
	--gma.cmd("Assign Sequence " ..availSeq .." At Executor " ..gma.show.getobj.number(gma.user.getselectedexec()))
	  gma.cmd("Assign Sequence " ..availSeq .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))


end
-- =======================================================================================
-- ==== END OF NEWSONG ===================================================================
-- =======================================================================================

return NEWSONG;
