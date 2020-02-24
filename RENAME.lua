-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: RENAME.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Description: Within the Maker+ library, RENAME is able to relabel a song to a different
--				name. Using this plugin will still limit the characters that are not
--				supported and will detect the version amount of songs within its own
--				library and adjust with regards to that.
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
-- 		POOLSIZE	-- Column size for view windows
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



-- ==== STRINGSONGCONV ===================================================================
-- Description:
--
--
-- Inputs:
--		POOLONENAME		-- Name of pool for first pool [Sequence]
--		POOLONESTART	-- Number of starting pool number to scan [Sequence]
-- 		POOLONEEND		-- Number of ending pool number to stop scanning [Sequence]
--		POOLTWONAME		-- Name of pool for first pool [Macro MAKER]
--		POOLTWOSTART	-- Number of starting pool number to scan [Macro MAKER]
-- 		POOLTWOEND		-- Number of ending pool number to stop scanning [Macro MAKER]
--		POOLTHREENAME	-- Name of pool for first pool [Macro ADDER]
--		POOLTHREESTART	-- Number of starting pool number to scan [Macro ADDER]
-- 		POOLTHREEEND	-- Number of ending pool number to stop scanning [Macro ADDER]
--		SONGNAME		-- Name of the song
-- 		POOLSIZE		-- Column size for view windows
--
--
-- Output: Song Sequence matching number , MAKER macro matching number, ADDER macro matching number
-- =======================================================================================
local function stringSongConv (poolOneName , poolOneStart , poolOneEnd , poolTwoName , poolTwoStart , poolTwoEnd , poolThreeName , poolThreeStart , poolThreeEnd , songName , poolSize)
	local G_OBJ = gma.show.getobj
	local manipName = string.gsub(string.upper(songName) , " " , "_") -- Convert to upper case to find all versions
	local tempSong
	local index
	local boolContinue = true
	local userReq

	-- Array of all instances where song matches to pool objects (Sequence and Macros(Maker and Adder))
	local poolOneArray = {}
	local poolTwoArray = {}
	local poolThreeArray = {}
	-- Use counter variable instead of #{array} because I thought it would be less CPU intense and faster
	local verCountOne = 1
	local verCountTwo = 1
	local verCountThree = 1

	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	-- loop to find other version of the song ending with " ...V"
	for index = poolOneStart , poolOneEnd - 1 , 1 do
		-- skip if it is in the left most side of a 16 wide pool view
		if (0 ~= math.fmod(index , poolSize)) then
			tempSong = G_OBJ.label(G_OBJ.handle(poolOneName .." " ..index))
			-- compare song name to upper case version of analyzing macro
			if (manipName == tempSong:upper()) then
				-- increment version counter by one
				poolOneArray[verCountOne] = index
				verCountOne = verCountOne + 1
			end
			if (tempSong:upper():match(manipName:upper() .."_V%d+")) then
				poolOneArray[verCountOne] = index
				verCountOne = verCountOne + 1
			end
		end
	end

		-- loop to find other version of the song ending with " ...V"
	for index = poolTwoStart , poolTwoEnd - 1 , 1 do
		-- skip if it is in the left most side of a 16 wide pool view
		if (0 ~= math.fmod(index , poolSize)) then
			tempSong = G_OBJ.label(G_OBJ.handle(poolTwoName .." " ..index))
			-- compare song name to upper case version of analyzing macro
			if (songName:upper() == tempSong:upper()) then
				-- increment version counter by one
				poolTwoArray[verCountTwo] = index
				verCountTwo = verCountTwo + 1
			end
			if (tempSong:upper():match(songName:upper() .." V%d+")) then
				poolTwoArray[verCountTwo] = index
				verCountTwo = verCountTwo + 1
			end
		end
	end

	for index = poolThreeStart , poolThreeEnd - 1 , 1 do
		-- skip if it is in the left most side of a 16 wide pool view
		if (0 ~= math.fmod(index , poolSize)) then
			tempSong = G_OBJ.label(G_OBJ.handle(poolThreeName .." " ..index))
			-- compare song name to upper case version of analyzing macro
			if (songName:upper() == tempSong:upper()) then
				-- increment version counter by one
				poolThreeArray[verCountThree] = index
				verCountThree = verCountThree + 1
			end
			if (tempSong:upper():match(songName:upper() .." V%d+")) then
				poolThreeArray[verCountThree] = index
				verCountThree = verCountThree + 1
			end
		end
	end

	if (verCountOne ~= verCountTwo or verCountOne ~= verCountThree) then
		gma.gui.msgbox("ERROR" , "The amount of versions does not match \n between the sequence library and the macro library (MAKER AND/OR ADDER)! \n \n Please resolve the mismatch for " ..songName .." first and then reinitiate program")
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Please Resolve: " ..songName .." versions")
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..poolOneName .." has " ..verCountOne .." versions of " ..songName)
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..poolTwoName .." has " ..verCountTwo .." versions of " ..songName)
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..poolThreeName .." has " ..verCountThree .." versions of " ..songName)
		return -13 , -26 , -39;
	end

	if (verCountOne == 1) then
		gma.gui.msgbox("ERROR" , "Did not find any songs with that name! \n \n Please pick a existing name instead of " ..songName)
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..songName .." does not exist in the song library.")
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..poolOneName .." has " ..verCountOne .." versions of " ..songName)
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..poolTwoName .." has " ..verCountTwo .." versions of " ..songName)
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED ..poolThreeName .." has " ..verCountThree .." versions of " ..songName)
		return -13 , -26 , -39;
	end


	if (verCountOne == 2) then
		userReq = 1
	else
		local fullVerIndexOne = ""
		local fullVerIndexTwo = ""
		local fullVerIndexThree = ""
		for index = 1 , #poolOneArray , 1 do
			if (index ~= 1) then
				fullVerIndexOne = fullVerIndexOne .." + " ..poolOneArray[index]
				fullVerIndexTwo = fullVerIndexTwo .." + " ..poolTwoArray[index]
				fullVerIndexThree = fullVerIndexThree .." + " ..poolThreeArray[index]
			else
				fullVerIndexOne = poolOneArray[index]
				fullVerIndexTwo = poolTwoArray[index]
				fullVerIndexThree = poolThreeArray[index]
			end
		end
		gma.cmd("Appearance Sequence " ..fullVerIndexOne .." /r=100 /g=100 /b=100")
		gma.cmd("Appearance Macro " ..fullVerIndexTwo .." /r=100 /g=100 /b=100")
		gma.cmd("Appearance Macro " ..fullVerIndexThree .." /r=100 /g=100 /b=100")

		-- ask user for the song name
		-- loop until user inputs a string that contains no punctuation
		repeat
			-- inform user that they are not able to use punctuation for their song name
			if (boolContinue == false) then
				if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure to only put numbers"))) then
					gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Terminated. Song not created.")
					gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
					return -13 , -26 , -39;
				end
			end

			-- ask user for a song name
			userReq = gma.textinput("Which Version?" , verCountOne - 1 )
			boolContinue = true


			-- end program if they escape from writing a name
			if (userReq == nil) then
				gma.cmd("Appearance Sequence " ..fullVerIndexOne .." /r")
				gma.cmd("Appearance Macro " ..fullVerIndexTwo .." /r")
				gma.cmd("Appearance Macro " ..fullVerIndexThree .." /r")
				gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Terminated. Song not created.")
				gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
				return -13 , -26 , -39;
			elseif (userReq == "") then
				boolContinue = false
			elseif (tonumber(userReq) == nil) then
				boolContinue = false
			elseif (tonumber(userReq) >= verCountOne) and (tonumber(userReq) <= 0) then
				boolContinue = false
			end

		until boolContinue

		gma.cmd("Appearance Sequence " ..fullVerIndexOne .." /r")
		gma.cmd("Appearance Macro " ..fullVerIndexTwo .." /r")
		gma.cmd("Appearance Macro " ..fullVerIndexThree .." /r")

	end

	userReq = tonumber(userReq)

	return poolOneArray[userReq] , poolTwoArray[userReq] , poolThreeArray[userReq]
end
-- ==== END OF STRINGSONGCONV ============================================================



-- ==== PREVIOUSVERSION ==================================================================
-- Description: Checks a continuous list of sequences to see if it's name already exists.
--				Can only make 10 versions of the same song.
--
-- Inputs:
--		STARTSEQ		-- Number of starting sequence to scan
--		ENDSEQ			-- Number of ending sequence to stop scanning
-- 		SNAME			-- String name
-- 		POOLSIZE	-- Column size for view windows
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

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================














-- =======================================================================================
-- ==== MAIN: RENAME =====================================================================
-- =======================================================================================

local function RENAME()
	local sSeqCopy = localUser.song_seq
	local sMakerCopy = localUser.maker
	local sAdderCopy = localUser.adder
	local localPoolSize = localUser.pool_size

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)

	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	if(type(sSeqCopy) ~= "number") or (type(sMakerCopy) ~= "number") or (type(sAdderCopy) ~= "number") then
		gma.gui.msgbox("ERROR" , "RENAME Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
		gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Error. RENAME is not setup.")
		gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Error. RENAME is not setup.")
		return -13;
	end


	local renameSong
	local boolContinue = true
	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure there are no special characters"))) then
				gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Terminated. Song not created.")
				gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
				return -13
			end
		end

		-- ask user for a song name
		renameSong = gma.textinput("Which Song To Rename?" , "" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (renameSong == nil) then
			gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Terminated. Song not created.")
			gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
			return -13
		elseif (renameSong == "") then
			boolContinue = false
		end

	until boolContinue

	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	local eSeqCopy = objectFinder("Sequence" , sSeqCopy , localPoolSize)
	local eMakerCopy = objectFinder("Macro" , sMakerCopy , localPoolSize)
	local eAdderCopy = objectFinder("Macro" , sAdderCopy , localPoolSize)
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	local seqTarget
	local makerTarget
	local adderTarget
	local index
	local pastVersion
	local newSongName


	if (tonumber(renameSong) == nil) then
		seqTarget , makerTarget , adderTarget = stringSongConv("Sequence" , sSeqCopy , eSeqCopy , "Macro" , sMakerCopy , eMakerCopy , "Macro" , sAdderCopy , eAdderCopy , renameSong , localPoolSize)
		if (seqTarget == -13 and makerTarget == -26 and adderTarget == -39) then
			return -13;
		end
	else
		local G_OBJ = gma.show.getobj
		makerTarget = tonumber(renameSong)
		bContinue = true

		if (G_OBJ.verify(G_OBJ.handle("Macro " ..makerTarget))) then
			for index = sSeqCopy , eSeqCopy - 1 , 1 do
				if (0 ~= math.fmod(index , localPoolSize)) then
					if (G_OBJ.label(G_OBJ.handle("Macro " ..makerTarget)) == string.gsub(G_OBJ.label(G_OBJ.handle("Sequence " ..index)) , "_" , " ")) then
						seqTarget = index
						renameSong = string.gsub(G_OBJ.label(G_OBJ.handle("Macro " ..makerTarget)) , " V%d+" , "")
					end
				end
			end

			if (seqTarget == nil) then
				gma.gui.msgbox("ERROR" , "Found the MAKER macro for requested song \n could not find the matching sequence for it")
				return -13;
			end

			for index = sAdderCopy , eAdderCopy - 1 , 1 do
				if (0 ~= math.fmod(index , localPoolSize)) then
					if (G_OBJ.label(G_OBJ.handle("Macro " ..makerTarget)) == G_OBJ.label(G_OBJ.handle("Macro " ..index))) then
						adderTarget = index
					end
				end
			end

			if (adderTarget == nil) then
				gma.gui.msgbox("ERROR" , "Found the MAKER macro for requested song \n could not find the matching ADDER macro for it")
				return -13;
			end

		else
			gma.gui.msgbox("ERROR" , "The number you have requested does not exist in the macro library!")
			gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Macro " ..renameSong .." does not exist. Plugin Terminated.")
			gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated.")
			return -13;
		end
	end




	boolContinue = true
	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure there are no special characters"))) then
				gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Terminated. Song not created.")
				gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
				return -13
			end
		end

		-- ask user for a song name
		newSongName = gma.textinput("New Song Name?" , renameSong )
		boolContinue = true


		-- end program if they escape from writing a name
		if (newSongName == nil) then
			gma.feedback(ESC_WHT .."RENAME : " ..ESC_RED .."Plugin Terminated. Song not created.")
			gma.echo(ESC_WHT .."RENAME Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
			return -13
		elseif (newSongName == "") then
			boolContinue = false
		end
		-- detect if song name has punctuation in it
		if (string.match(newSongName , '%p..')) then
			boolContinue = false
		end

	until boolContinue

	-- if the user requested to manually place a version number, this statement will remove the version they are requesting
	-- program will take over and discover what version to pick
	if (newSongName:find(" V%d+")) then
		--a = songName:match(" V(%d+)")
		newSongName = newSongName:gsub(" V%d+" , "")
	end

	local singleString = string.gsub(newSongName , " " , "_")

	pastVersion = previousVersion(sSeqCopy , eSeqCopy , newSongName , localPoolSize)

	if (pastVersion ~= 1) then
		-- for multiple version of the same song
		gma.cmd("Label Sequence " ..seqTarget .." \"" ..singleString .."_V" ..pastVersion .."\"")
		gma.cmd("Label Macro " ..makerTarget .." \"" ..newSongName .." V" ..pastVersion .."\"")
		gma.cmd("Label Macro " ..adderTarget .." \"" ..newSongName .." V" ..pastVersion .."\"")
		gma.cmd("Label Sequence " ..seqTarget .." Cue 1 \"S - " ..newSongName)
		gma.cmd("Assign Macro 1." ..makerTarget ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."_V" ..pastVersion .."\"")
		gma.cmd("Assign Macro 1." ..adderTarget ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."_V" ..pastVersion .."\"")

	else
		-- for first song ever made
		gma.cmd("Label Sequence " ..seqTarget .." \"" ..singleString .."\"")
		gma.cmd("Label Macro " ..makerTarget .." \"" ..newSongName .."\"")
		gma.cmd("Label Macro " ..adderTarget .." \"" ..newSongName .."\"")
		gma.cmd("Label Sequence " ..seqTarget .." Cue 1 \"S - " ..newSongName)
		gma.cmd("Assign Macro 1." ..makerTarget ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."\"")
		gma.cmd("Assign Macro 1." ..adderTarget ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..singleString .."\"")

	end

	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."=========================================")
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."Old Song Name: " ..ESC_RED ..renameSong)
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."New Song Name: " ..ESC_WHT ..newSongName .." V" ..pastVersion)
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."Changed Sequence: " ..ESC_GRN .."Sequence " ..ESC_WHT ..seqTarget)
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."Changed    Maker: " ..ESC_GRN .."Macro " ..ESC_WHT ..makerTarget)
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."Changed    Adder: " ..ESC_GRN .."Macro " ..ESC_WHT ..adderTarget)
	gma.feedback(ESC_WHT .."RENAME : " ..ESC_YEL .."=========================================")


end
-- =======================================================================================
-- ==== END OF RENAME ====================================================================
-- =======================================================================================

return RENAME;
