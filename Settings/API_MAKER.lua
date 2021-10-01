-- =======================================================================================
-- Plugin: API_MAKER.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: All functions used to maintain the Maker+ plugin suite.
-- =======================================================================================

-- currPlugin = select(1,...)

-- ==== USEFUL VARIABLES =================================================================
	ESC_RED = string.char(27) .."[31m"
	ESC_GRN = string.char(27) .."[32m"
	ESC_YEL = string.char(27) .."[33m"
	ESC_WHT = string.char(27) .."[37m"
	G_OBJ = gma.show.getobj
	G_PRO = gma.show.property
--========================================================================================









-- =======================================================================================
-- =======================================================================================
-- =======================================================================================

-- ==== maker.util.print =================================================================
-- Description: Leaves a message for the user to discover later about an error or info
--				to know for later. Displays to command line and system monitor.
--
-- Inputs:
--		message		-- message left on command line and system monitor
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.util.print(message, caller)
	gma.feedback(ESC_WHT ..caller .." : " ..tostring(message))
	gma.echo(ESC_WHT ..caller .." : " ..tostring(message))
end
-- ==== END OF maker.util.print ==========================================================



-- ==== maker.util.error =================================================================
-- Description: Will interupt the user with an error and save message for later
--
-- Inputs:
--		message		-- message left on command line and system monitor
--		extra		-- popup window
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.util.error(message, extra, caller)
	local message = message or ""
	local more = extra or "There was a problem will using the " ..caller .."\n Please check if you setup up correctly \n or contact Maker+ developer"
	gma.gui.msgbox("ERROR", more)
	maker.util.print(ESC_RED .."Plugin Terminated. " ..message, caller)
end
-- ==== END OF maker.util.error ==========================================================



-- ==== maker.util.prompt ================================================================
-- Description: Using GUI Confirm function, prompts question so that it can return boolean
--
-- Inputs:
--		pool		-- Any string, doesn't have to be literal pool name
--		action		-- What is the operation you'd like to do?
--
-- Output: Boolean statement of true or nil
-- =======================================================================================
function maker.util.prompt(pool, action)
	return gma.gui.confirm(action:gsub("^%l", string.upper) .." " ..pool .." Pool" , "Would you like to " ..action:lower() .." the " ..pool .." pool?")
end
-- ==== END OF maker.util.prompt =========================================================



-- ==== maker.util.input =================================================================
-- Description: Prompts the user for what is the last song in the library to condense.
--				User can leave textinput blank to call AutoSize function
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		strTitle	-- GUI Title Input Title
--		caller		-- what plugin is using this function
--
-- Output: Integer: Last number of pool; String: Skip; String: Auto; boolean: false
-- =======================================================================================
function maker.util.input(user, poolIndex, strTitle, caller)
	local pool = maker.manage("Pool", user, poolIndex)
	local boolContinue = true
	local libSizePool

	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid pool number for " ..pool))) then
				maker.util.print(ESC_RED .."Plugin Terminated. ", caller)
				return false;
			end
		end

		-- ask user for a song name
		libSizePool = gma.textinput(strTitle , "Skip" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (libSizePool == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. ", caller)
			return false;
		elseif (libSizePool == "") then
			return "Auto";
		elseif (libSizePool == "Skip") then
			return "Skip";
		elseif (tonumber(libSizePool) == nil) then
			boolContinue = false
		end

	until boolContinue

	return tonumber(libSizePool)
end
-- ==== END OF maker.util.input ==========================================================



-- ==== maker.util.underVer ==============================================================
-- Description:
--
-- Inputs:
--		oldName		-- string that needs to be edited
--		pool		-- label is intended for this pool
--		verNum		-- version number
--		caller		-- what plugin is using this function
--
-- Output: String: Name
-- =======================================================================================
function maker.util.underVer(oldName, pool, verNum, caller)
	local newName = oldName

	if (pool == "Sequence") then
		underscore = true
		newName = newName:gsub(" ", "_")
	elseif (pool == "Macro") then
		underscore = false
		newName = newName:gsub("_", " ")
	else
		underscore = false
	end

	if(verNum) and (verNum > 1) then
		if(underscore) then return newName .."_V" ..verNum
		else return newName .." V" ..verNum end
	else return newName end
end
-- ==== END OF maker.util.underVer =======================================================



-- ==== maker.util.round =================================================================
-- Description: Rounds number to the nearest integer.
--
-- Inputs:
--		num					-- Base Number
--		numDecimalPlaces	-- How many decimal places (Default is zero)
--		caller		-- what plugin is using this function
--
-- Output: rounded integer number
-- =======================================================================================
function maker.util.round(num, numDecimalPlaces, caller)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
-- ==== END OF maker.util.round ==========================================================



-- ==== maker.util.thru ==================================================================
-- Description: If this table received a table like: {1, 2, 3, 4, 5, 6, 8, 9, 10, 15, 16}
--				this will return a string "1 Thru 6 + 8 Thru 10 + 15 + 16".
--
-- Inputs:
--		numArray	-- Table of numbers of any amount; already ordered!
--		caller		-- what plugin is using this function
--
-- Output: String
-- =======================================================================================
function maker.util.thru(numArray, caller)
	local groupSize = 3 -- control threshold of size of a thru group

    local allNumStr = ''
    local operator = ''
    local lastNum = nil
    local i = 1
    local j -- look forward for thru groups
    local k -- keeps place of initial traverse before looking ahead
    local cFlag = groupSize -- count flag -> how big does a group have to be
    local gFlag = false -- group flag -> true if you start a group that follows another
    local fFlag = false -- first flag -> true if it is the first group in the array

    while(i <= #numArray) do
        if(numArray[i+1]) then
            j = i
            k = i
            if (i == 1) then
                fFlag = true
            end
            lastNum = numArray[i]
            while ((numArray[j+1]) and (numArray[j] == numArray[j+1] - 1)) do
                cFlag = cFlag - 1
                if(cFlag <= 1) then
                    operator = ' Thru '
                    i = j + 1
                    lastNum = numArray[j + 1]
                    gFlag = true
                end
                j = j + 1

            end
            if ((gFlag) and not(fFlag)) then
                allNumStr = allNumStr ..' + ' ..numArray[k]
            elseif ((gFlag) and (fFlag)) then
                allNumStr = numArray[1]
            end
            allNumStr = allNumStr ..operator ..lastNum
            operator = ' + '
            cFlag = groupSize
            fFlag = false
            gFlag = false
        else
            allNumStr = allNumStr ..operator ..numArray[i]
        end
        i = i + 1
    end
    return allNumStr
end
-- ==== END OF maker.util.thru ===========================================================



-- ==== maker.util.group =================================================================
-- Description: Places default values in  your programmer either from a desired group or
--				everything except for a certain group. "-MINUS " keyword to pick all
--				except certain group.
--
-- Inputs:
--		option		-- String || label/string of group
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.util.group(option, caller)
	local minusOption = ""
	if (option:match("-MINUS ")) then
		option = option:gsub("-MINUS ", "")
		minusOption = "Fixture 1 Thru - "
	end

	if(nil ~= tonumber(option)) then
		-- Option is a group number
		gma.cmd("ClearAll")
		gma.sleep(0.1)
		gma.cmd(minusOption .."Group " ..option .." Default")
	else
		-- Option is a label name for the group
		gma.cmd("ClearAll")
		gma.sleep(0.1)
		gma.cmd(minusOption .."Group \"" ..option .."\" Default")
	end
end
-- ==== END OF maker.util.group ==========================================================



-- ==== maker.util.date ==================================================================
-- Description: What is the date X days from now?
--
-- Inputs:
--		offset		-- How many days to add from current day
--		caller		-- what plugin is using this function
--
-- Output: New Day after offset applied || month , day , year
-- =======================================================================================
function maker.util.date(offset, caller)
	local nxtYear = 0
	if (365 < offset) then
		nxtYear = 1
		offset = offset - 365
	end
	local numMonth = {31 , 28 , 31 , 30 , 31 , 30 , 31 , 31 , 30 , 31 , 30 , 31}
	local numYear = math.floor(os.date("%Y") + nxtYear)
	local currYear = math.floor(os.date("%y") + nxtYear)
	local currMonth
	local currDay
	local indMonth = 1
	local indDay = 0

	if((numYear % 4) == 0) then
		numMonth[2] = numMonth[2] + 1
		if((numYear % 100) == 0) then
			numMonth[2] = numMonth[2] - 1
			if((numYear % 400) == 0) then
				numMonth[2] = numMonth[2] + 1
			end
		end
	end

	for currMonth = 1 , #numMonth do
		for currDay = 1 , numMonth[indMonth] do
			indDay = indDay + 1
			if (indDay >= offset) then
				return currMonth , currDay , currYear
			end
		end
		indMonth = indMonth + 1
	end
end
-- ==== END OF maker.util.date ===========================================================



-- ==== maker.util.weekday ===============================================================
-- Description: input string of a day of the week and receive an
--
-- Inputs:
--		reqDofW		-- what is the day of the week that is wanted
--		caller		-- what plugin is using this function
--
-- Output: Integer: Days away from the input day.
-- =======================================================================================
function maker.util.weekday(reqDofW, caller)
	local dayOfWeek = os.date("%w")
	if (tonumber(dayOfWeek) ~= 0) then
		dayOfWeek = maker.util.round(((7/dayOfWeek) - 1) * dayOfWeek)
	end

	if     (reqDofW:upper() == "SUNDAY")     then dayOfWeek = math.fmod(dayOfWeek + 0 , 7)
	elseif (reqDofW:upper() == "MONDAY")     then dayOfWeek = math.fmod(dayOfWeek + 1 , 7)
	elseif (reqDofW:upper() == "TUESDAY")    then dayOfWeek = math.fmod(dayOfWeek + 2 , 7)
	elseif (reqDofW:upper() == "WEDNESDAY")  then dayOfWeek = math.fmod(dayOfWeek + 3 , 7)
	elseif (reqDofW:upper() == "THURSDAY")   then dayOfWeek = math.fmod(dayOfWeek + 4 , 7)
	elseif (reqDofW:upper() == "FRIDAY")     then dayOfWeek = math.fmod(dayOfWeek + 5 , 7)
	elseif (reqDofW:upper() == "SATURDAY")   then dayOfWeek = math.fmod(dayOfWeek + 6 , 7)
	else
		maker.util.error(ESC_RED .."Plugin Terminated. No archive sequence created.",
						"You did not pick a correct day of the week!",
						caller)
		return false;
	end

	return dayOfWeek
end
-- ==== END OF maker.util.weekday ========================================================



-- ==== maker.util.timeTravel ============================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		caller		-- what plugin is using this function
--
-- Output: String: Date in the future
-- =======================================================================================
function maker.util.timeTravel(user, caller)
	local dayOfYear = os.date("%j")
	local newMonth, newDay, newYear
	local dayOfWeek = maker.util.weekday(user.weekday)
	if not(dayOfWeek) then return false; end
	newMonth , newDay , numYear = maker.util.date(dayOfYear + dayOfWeek)
	return string.format("%02d-%02d-%02d" , newMonth , newDay , numYear)
end
-- ==== END OF maker.util.timeTravel =====================================================



-- ==== maker.util.renumber ==============================================================
-- Description: Renumbers the selected executors sequence cues' from current value into
--				its index value. Only works if there is a "Cue 1" in your sequence.
--
-- Input:
--		caller		-- what plugin is using this function
-- Output: None
-- =======================================================================================
function maker.util.renumber(caller)
	local changed = 1 --any number other than 0
	local lengthOfSeq = G_OBJ.amount(G_OBJ.parent(G_OBJ.handle("Cue 1"))) - 1
	local currCue = {}
	local nextCue = {}

	-- you could put in loop to ensure cues are being updated
	local seqTable = maker.util.cueNumbers()

	-- loop until their are no changes needed when looking at list
	while(changed ~= 0) do
		changed = 0
		for i = 1, lengthOfSeq do
			currCue = seqTable[i]
			if(seqTable[i + 1] ~= nil) then
				nextCue.current = seqTable[i + 1].current
				nextCue.future = seqTable[i + 1].future
			else
				-- for the last cue in the sequence
				nextCue.current = nil
				nextCue.future = nil
			end

			if(currCue.current == currCue.future) then
				-- nothing
			elseif(currCue.current < currCue.future) then
				-- move cue forward
				if((nextCue.future == nil) or (currCue.future < nextCue.current)) then
					-- if you don't jump the next cue, make the move
					gma.cmd("Move Cue " ..currCue.current .." At " ..currCue.future)
					currCue.current = currCue.future
				end
				changed = changed + 1
			elseif(currCue.current > currCue.future) then
				-- move cue backwards
				gma.cmd("Move Cue " ..currCue.current .." At " ..currCue.future)
				currCue.current = currCue.future
				changed = changed + 1
			end
		end
	end
end
-- ==== END OF maker.util.renumber =======================================================



-- ==== maker.util.cueNumbers ============================================================
-- Description: Returns the cue number and its index value at a static point of time.
--				Be sure to update this table for your self. I am using this to reduce
--				api calls to grandma2 software. Will not work if their is no "Cue 1".
--
-- Inputs:
--		caller		-- what plugin is using this function
-- Output: vector: <current cue number, index value for cue>
-- =======================================================================================
function maker.util.cueNumbers(caller)
	local matrix = {}
	local a, b
	local SelSeqHand = G_OBJ.parent(G_OBJ.handle("Cue 1"))
	local SelSeqAmou = G_OBJ.amount(SelSeqHand) - 1

	-- find the current value of a cue and the index
	for i=1, SelSeqAmou do
		a = tonumber(G_OBJ.number(G_OBJ.child(SelSeqHand , i)))
		b = G_OBJ.index(G_OBJ.child(SelSeqHand , i))
		matrix[i] = {current = a, future = b}
	end

	-- return the matrix
	return matrix
end
-- ==== END OF maker.util.cueNumbers =====================================================



-- ==== maker.test.count =================================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.test.count(user, caller)
	if (#user.name == #user.first) then
		return #user.name
	else
		return false
	end
end
-- ==== END OF maker.test.count ==========================================================



-- ==== maker.test.pool ==================================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.test.pool(user, caller)
	if (type(user.pool_size) ~= "number") then
		maker.util.error(ESC_RED .."Plugin Error. pool_size is not setup.",
						"Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!",
						caller)
		return false;
	elseif (user.pool_size <= 1) then
		maker.util.error(ESC_RED .."Plugin Error. pool_size is too small of a number.",
						"Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!",
						caller)
		return false;
	end

	return true;
end
-- ==== END OF maker.test.pool ===========================================================



-- ==== maker.test.seq ===================================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.test.seq(user, caller)
	local tempStr = maker.manage("Pool", user, 1)

	if (tempStr:upper() ~= string.upper("Sequence")) then
		maker.util.error(ESC_RED .."Plugin Error. " ..caller .." is not setup correctly.",
						"Plugin was NOT setup!\nThe first element of the [user].name table must be a Sequence!",
						caller)
		return false;
	end
	if (type(user.first[1]) ~= "number") then
		maker.util.error(ESC_RED .."Plugin Error. " ..caller .." is not setup correctly.",
						"Plugin was NOT setup!\nThe first element of the [user].first table must be a number!",
						caller)
		return false;
	end

	return true;
end
-- ==== END OF maker.test.seq ============================================================



-- ==== maker.test.archive ===============================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.test.archive(user, caller)
	if ((type(user.archive_seq) ~= "number") or not((type(user.first_cue) == "string") or (type(user.first_cue) == "number"))) then
		maker.util.error(ESC_RED .."Plugin Error. " ..caller .." is not setup.",
						"Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!",
						caller)
		return false;
	end

	if not(maker.test.seq(user, caller)) then
		return false;
	end

	return true;
end
-- ==== END OF maker.test.archive ========================================================



-- ==== maker.find.pool ==================================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- string: find index of sequence/addon
--		caller		-- what plugin is using this function
--
-- Output:
-- =======================================================================================
function maker.find.pool(user, poolName, caller)
	local macroAmount = maker.test.count(user)
	if not(macroAmount) then return false; end

	for poolIndex=1, macroAmount do
		if (poolName:upper() == user.name[poolIndex]:upper()) then
			return poolIndex;
		end
	end
	return false;
end
-- ==== END OF maker.find.pool ===========================================================



-- ==== maker.find.operand ===============================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		sName		-- string name to match in library
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.find.operand(user, sName, caller)
	local objects = maker.test.count(user)
	local currPool
	local trash
	local temp = {}
	for i=1, objects do
		temp[i] = user.name[i]:match("%a")
	end
	temp[1] = "E" -- for Edit... Replace [S]ONGS name
	if not(objects) then return false; end
	for i=1 , objects do
		trash, currPool = maker.manage("Pool", user, i)
		if(currPool ~= nil) then
			if(string.match(sName:upper() , "-" ..temp[i]:upper() .." ")) then
				sName = string.gsub(sName , "-" ..temp[i]:upper() .." ", "", 1)
				sName = string.gsub(sName , "-" ..temp[i]:lower() .." ", "", 1)
				maker.util.print(ESC_WHT .."Using " ..ESC_YEL ..user.name[i]:upper() ..ESC_WHT .." on " ..sName .."...", caller)
				return i , sName;
			end
		end
	end
	return nil , sName;
end
-- ==== END OF maker.find.operand ========================================================



-- ==== maker.find.avail =================================================================
-- Description: Finds the next available empty spot in a pool to store something
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		caller		-- what plugin is using this function
--
-- Output: Returns an empty pool space
-- =======================================================================================
function maker.find.avail(user, poolIndex, caller)
	local currPool = maker.manage("Pool", user, poolIndex)
	local countPoolNum = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)

	-- check if pool object already exists
	while G_OBJ.verify(poolHandle) do
		-- pool object exists
		-- check the next one and update poolHandle variable for test
		countPoolNum = maker.manage("Inc", user, poolIndex, countPoolNum, 1)
		poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)
	end
	-- empty pool object was found!
	-- return number of empty pool object
	return countPoolNum;
end
-- ==== END OF maker.find.avail ==========================================================



-- ==== maker.find.last ==================================================================
-- Description: Finds the next available empty spot in a pool to store something
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		caller		-- what plugin is using this function
--
-- Output: Returns an empty pool space
-- =======================================================================================
function maker.find.last(user, poolIndex, caller)
	if (user.last[poolIndex] == nil) then
		user.last[poolIndex] = maker.find.avail(user, poolIndex, caller)
	end
	return maker.manage("Inc", user, poolIndex, user.last[poolIndex], -1) --Decrement
end
-- ==== END OF maker.find.last ===========================================================



-- ==== maker.find.gap ===================================================================
-- Description: This will auto condense a pool but will stop until it reaches a gap more
--				two or otherwise will finish full library list
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		caller		-- what plugin is using this function
--
-- Output: Number of last pool object in at least 2 gap
-- =======================================================================================
function maker.find.gap(user, poolIndex, caller)
	local countPool = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local gapValue = countPool
	local currPool = maker.manage("Pool", user, poolIndex)
	local poolHandle = G_OBJ.handle(currPool .." " ..countPool)

	while (true) do
		if (not(G_OBJ.verify(G_OBJ.handle(currPool .." " ..gapValue)))) then
            gapValue = maker.manage("Inc", user, poolIndex, gapValue, 1)
			if (not(G_OBJ.verify(G_OBJ.handle(currPool .." " ..gapValue)))) then
                gapValue = maker.manage("Inc", user, poolIndex, gapValue, 1)
				if (not(G_OBJ.verify(G_OBJ.handle(currPool .." " ..gapValue)))) then
					gapValue = maker.manage("Inc", user, poolIndex, gapValue, 1)
					goto complete;
				end
			end
			countPool = gapValue
		end
		countPool = maker.manage("Inc", user, poolIndex, countPool, 1)
		gapValue = countPool
	end
	::complete::
	return countPool;
end
-- ==== END OF maker.find.gap ============================================================



-- ==== maker.find.count =================================================================
-- Description: Checks a continuous list of sequences to see if it's name already exists.
--				It must be entirely right without case-sensitivity.
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		sName		-- string name to match in library
--		caller		-- what plugin is using this function
--
-- Output: Returns number times name matched with other macros labels
-- =======================================================================================
function maker.find.count(user, poolIndex, sName, caller)
	local manipName = string.upper(sName)
	local currPool = maker.manage("Pool", user, poolIndex)
	local countPoolNum = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)

	-- loop to find other version of the song ending with " ...V"
	while G_OBJ.verify(poolHandle) do

		-- compare song name to upper case version of analyzing macro
		if (manipName == string.upper(G_OBJ.label(G_OBJ.handle(currPool .." " ..countPoolNum)))) then
			return countPoolNum;
		end

		countPoolNum = maker.manage("Inc", user, poolIndex, countPoolNum, 1)
		poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)
	end

	return false;
end
-- ==== END OF maker.find.count ==========================================================



-- ==== maker.find.strOrNum ==============================================================
-- Description: Checks a continuous list of sequences to see if it's name already exists.
--				It must be entirely right without case-sensitivity. If you pass by a
--				a number, it will skip the sequence string search but will search addons
--				labels for matching sequence from number.
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		sName		-- string name or number to match in library
--		caller		-- what plugin is using this function
--
-- Output: Returns an array of pool numbers for desired song || returns false if error
-- =======================================================================================
function maker.find.strOrNum(user, sName, caller)
	local addonIndex, mainPool, addonPool
	local locations = {}

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

	if (tonumber(sName) == nil) then
		locations = maker.find.ver.pick(user, sName, caller)
		if not(locations) then
			maker.util.error("Could not find " ..sName .." in your library!", nil, caller)
			return false;
		end
	else
		locations[1] = tonumber(sName)
		mainPool = maker.manage("Pool", user, 1)
		if (G_OBJ.verify(G_OBJ.handle(mainPool .." " ..locations[1]))) then
			for i=2, macroAmount do
				currPool = maker.manage("Pool", user, i)
				addonIndex = maker.manage("Current", user, i, user.first[i])
				while (addonIndex < user.last[i]) do
				    if (G_OBJ.label(G_OBJ.handle(currPool .." " ..addonIndex)) == string.gsub(G_OBJ.label(G_OBJ.handle(mainPool .." " ..locations[1])) , "_" , " ")) then
						-- its important that in all libraries, each object has a unique name
				        locations[i] = addonIndex
				    end
				    addonIndex = maker.manage("Inc", user, i, addonIndex, 1)
				end
			end

			for i=1, macroAmount do
				if not(locations[i]) then
					maker.util.error(ESC_RED .."Please use repairing plugin. Missing objects in song library. Try again later.", nil, caller)
					return false;
				end
			end
		else
			maker.util.error(ESC_RED ..mainPool .." " ..sName .." does not exist.",
							"The number you have requested does not exist in the " ..mainPool .." library!",
							caller)
			return false;
		end
	end

	return locations
end
-- ==== END OF maker.find.strOrNum =======================================================



-- ==== maker.find.ver.next ==============================================================
-- Description: Checks a continuous list of sequences to see if it's name already exists.
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		sName		-- string name to match in library
--		caller		-- what plugin is using this function
--
-- Output: Returns number times name matched with other macros labels
-- =======================================================================================
function maker.find.ver.next(user, poolIndex, sName, caller)
	local manipName = string.gsub(sName:upper() , " " , "_") -- Convert to upper case to find all versions
	local currPool = maker.manage("Pool", user, poolIndex)
	local tempSong
	local seqIndex
	local occurance = 1
	local verArray = {}
	local countPoolNum = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local last = maker.find.last(user, poolIndex, caller)

	while (countPoolNum <= last) do
		tempSong = G_OBJ.label(G_OBJ.handle(currPool .." " ..countPoolNum))
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
		countPoolNum = maker.manage("Inc", user, poolIndex, countPoolNum, 1)
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
-- ==== END OF maker.find.ver.next =======================================================



-- ==== maker.find.ver.count =============================================================
-- Description: Finds the next available empty spot in a pool to store something
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		sName		-- string name to match in library
--		caller		-- what plugin is using this function
--
-- Output: Returns an empty pool space
-- =======================================================================================
function maker.find.ver.count(user, poolIndex, sName, caller)
    local reqSong = sName
	local currPool = maker.manage("Pool", user, poolIndex)
	local countPoolNum = maker.manage("Current", user, poolIndex, user.first[poolIndex])
    local poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)
    local poolSongArray = {}
    local arrayCounter = 1
    local tempName

    -- check all macros (starting from searchMacro variable) until reach an empty macro
    while G_OBJ.verify(poolHandle) do
        -- store macro label
        tempName = G_OBJ.label(G_OBJ.handle(currPool .." " ..countPoolNum))

        -- match current macro with desired text given my user
        if (string.match(tempName:upper() , sName:upper())) then
            -- record which macro had match in pool
            poolSongArray[arrayCounter] = countPoolNum
            -- set next
            arrayCounter = arrayCounter + 1
        end

		countPoolNum = maker.manage("Inc", user, poolIndex, countPoolNum, 1)

        -- record macro handle for verification test
        poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)
    end

    return arrayCounter - 1, poolSongArray
end
-- ==== END OF maker.find.ver.count ======================================================



-- ==== maker.find.ver.match =============================================================
-- Description:
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		sName		-- string name to match in library
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.find.ver.match(user, poolIndex, sName, caller)
	local array = {}
	local tempSong
	local currPool = maker.manage("Pool", user, poolIndex)
	local index = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local last = maker.find.last(user, poolIndex, caller)
	local counter = 1

	while(index <= last) do
		tempSong = G_OBJ.label(G_OBJ.handle(currPool .." " ..index))
		-- compare song name to upper case version of analyzing macro
		if (sName:upper() == tempSong:upper()) then
			-- increment version counter by one
			array[counter] = index
			counter = counter + 1
		end
		if (string.match(tempSong:upper():gsub(" " , "_") .."_V%d+", sName:upper():gsub(" " , "_") .."_V%d+")) then
			array[counter] = index
			counter = counter + 1
		end
		index = maker.manage("Inc", user, poolIndex, index, 1)
	end

	if(counter == 0) then
		return false, array;
	else
		return counter, array;
	end;
end
-- ==== END OF maker.find.ver.match ======================================================



-- ==== maker.find.ver.pick ==============================================================
-- Description:
--
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		sName		-- string name to match in library
--		caller		-- what plugin is using this function
--
--
-- Output: Song Sequence matching number , MAKER macro matching number, ADDER macro matching number
-- =======================================================================================
function maker.find.ver.pick(user, sName, caller)
	local manipName = string.gsub(string.upper(sName) , " " , "_") -- Convert to upper case to find all versions
	local boolContinue = true
	local userReq
	local sender = {}

	-- Array of all instances where song matches to pool objects (Sequence and Macros(Maker and Adder))
	local macroAmount = maker.test.count(user)
	if not(macroAmount) then
		maker.util.error(nil, nil, caller)
		return false
	end

	local file = {instances = {}, array = {}}
	file.array[1] = {}
	file.instances[1], file.array[1] = maker.find.ver.match(user, 1, manipName, y)
	for i=2, macroAmount do
		file.array[i] = {}
		file.instances[i], file.array[i] = maker.find.ver.match(user, i, sName, y)
	end

	for i=1, macroAmount do
		temp = file.instances[i]
	end

	for i=1, #file.instances do
		if not(file.instances[i]) then
			maker.util.error(ESC_RED .."Please Resolve: " ..sName .." versions",
							"The amount of versions does not match \n between the sequence library and the macro library (MAKER AND/OR ADDER)! \n \n Please resolve the mismatch for " ..sName .." first and then reinitiate program",
							caller)
			return false;
		end
	end

	if (file.instances[1] == 1) then
		maker.util.error(ESC_RED ..sName .." does not exist in the song library.",
						"Did not find any songs with that name! \n \n Please pick a existing name instead of " ..sName,
						caller)
		return false;
	end


	if (file.instances[1] == 2) then
		userReq = 1
	else
		for i=1, macroAmount do
			gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r=100 /g=100 /b=100")
		end

		-- ask user for the song name
		-- loop until user inputs a string that contains no punctuation
		repeat
			-- inform user that they are not able to use punctuation for their song name
			if (boolContinue == false) then
				if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure to only put numbers"))) then
					maker.util.print(ESC_RED .."Plugin Terminated. Song not created.",
									caller)
					return false;
				end
			end

			-- ask user for a song name
			userReq = gma.textinput("Which Version?" , file.instances[1] - 1 )
			boolContinue = true


			-- end program if they escape from writing a name
			if (userReq == nil) then
				for i=1, macroAmount do
					gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r")
				end
				maker.util.print(ESC_RED .."Plugin Terminated. Song not created.",
								caller)
				return false;
			elseif (userReq == "") then
				boolContinue = false
			elseif (tonumber(userReq) == nil) then
				boolContinue = false
			elseif (tonumber(userReq) >= file.instances[1]) and (tonumber(userReq) <= 0) then
				boolContinue = false
			end

		until boolContinue

		for i=1, macroAmount do
			gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r")
		end

	end

	userReq = tonumber(userReq)
	for i=1, macroAmount do
		sender[i] = file.array[i][userReq]
	end

	return sender
end
-- ==== END OF maker.find.ver.pick =======================================================



-- ==== maker.move.obj ===================================================================
-- Description: This will auto condense a pool but will stop until it reaches a gap more
--				two or otherwise will finish full library list
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.move.obj(user, poolIndex, caller)
	local currPool = maker.manage("Pool", user, poolIndex)
	local loopIndex = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local counterGap = loopIndex
	local last = maker.find.last(user, poolIndex, caller)


	while (loopIndex < last) do
		if (not(G_OBJ.verify(gma.show.getobj.handle(currPool .." " ..counterGap)))) then
			counterGap = maker.manage("Inc", user, poolIndex, counterGap, 0)
			while ((not(G_OBJ.verify(G_OBJ.handle(currPool .." " ..counterGap)))) and (counterGap <= last)) do
				counterGap = maker.manage("Inc", user, poolIndex, counterGap, 1)
			end

			if (counterGap <= last) then
				maker.manage("Move", user, poolIndex, counterGap, loopIndex)
			end
		end

		loopIndex = maker.manage("Inc", user, poolIndex, loopIndex, 1)
		counterGap = loopIndex
	end
end
-- ==== END OF maker.move.obj ============================================================



-- ==== maker.move.alpha =================================================================
-- Description: Re-alphabetizes a continuous line of pool objects.
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		caller		-- what plugin is using this function
--
-- Output: Nothing.
-- =======================================================================================
function maker.move.alpha(user, poolIndex, caller)
    local currPool = maker.manage("Pool", user, poolIndex)
    local source = maker.manage("Current", user, poolIndex, user.first[poolIndex])
    local last = maker.find.last(user, poolIndex, caller)
	local countPoolNum, poolHandle, counter, destination
    local refTable = {}

    -- records current pool area and compares with a reference of the pool objects that has been realphabetized
    -- comparison will see if there needs to be changes from start to finish
    -- will loop back to here every change
    ::reevaluate::

    countPoolNum = source
	destination = source
    poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)
    counter = 1
	if (last < countPoolNum) then return end

	-- copy down all labels from pool in continuous list on to an array
    while (countPoolNum <= last) do
		-- record pool object label in array
        refTable[counter] = G_OBJ.label(poolHandle)
        counter = counter + 1

        countPoolNum = maker.manage("Inc", user, poolIndex, countPoolNum, 1)
        poolHandle = G_OBJ.handle(currPool .." " ..countPoolNum)
    end

	-- re organize into alphabetical order!
    table.sort(refTable)

    for refPos, refString in ipairs(refTable) do
        if(destination >= last) then return end

        if(not(refString == G_OBJ.label(G_OBJ.handle(currPool.. " " ..destination)))) then
            repeat
                if(destination > last) then
                    goto continue
                end
                destination = maker.manage("Inc", user, poolIndex, destination, 1)
            until (refString == G_OBJ.label(G_OBJ.handle(currPool.. " " ..destination)))

            maker.manage("Move", user, poolIndex, destination, source)
            ::continue::
            source = maker.manage("Inc", user, poolIndex, source, 1)
            goto reevaluate
        end
		destination = maker.manage("Inc", user, poolIndex, destination, 1)
		source = maker.manage("Inc", user, poolIndex, source, 1)
    end
end
-- ==== END OF maker.move.alpha ==========================================================



-- ==== maker.request ====================================================================
-- Description: First asks what version song you'd like to interact with if their are
--				others. Then uses requested plugin.
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		seqArray		-- an array of occupied sequence numbers in your library
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.request(user, poolIndex, seqArray, caller)
    local versionIndex
	local trash, currPool
	trash, currPool = maker.manage("Pool", user, poolIndex)
    local boolContinue = true
	local makerVar = "MAKER_SONG"

    if (1 == #seqArray) then
        versionIndex = 1
    elseif (1 ~= #seqArray) then
        repeat
            if (boolContinue == false) then
                if (false == (gma.gui.confirm("ERROR" , "Invalid Version Number! \n Only use a number inbetween the amount of versions available!"))) then
					maker.util.print(ESC_RED .."Plugin Terminated:" ..option .." Operand not used")
                    return false
                end
            end

            versionIndex = gma.textinput("Which Version?" , #seqArray)
            boolContinue = true

            if (versionIndex == nil) then
				maker.util.print(ESC_RED .."Plugin Terminated. Song not searched or imported.",
								caller)
                return false
            elseif (versionIndex == "") then
                boolContinue = false
            elseif (nil == string.match(versionIndex , "%d")) then
                boolContinue = false
            elseif (tonumber(versionIndex) > #seqArray) and (tonumber(versionIndex) <= 0) then
                boolContinue = false
            end
        until boolContinue

        versionIndex = tonumber(versionIndex)
    end

	if(1 == poolIndex) then
		gma.cmd("Assign " ..maker.manage("Pool", user, 1) .." " ..seqArray[versionIndex] .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))
	else
		gma.user.setvar(makerVar , seqArray[versionIndex])
		gma.sleep(0.2)
    	gma.cmd(currPool .." " ..user.name[poolIndex])
	end

end
-- ==== END OF maker.request =============================================================



-- ==== maker.repair =====================================================================
-- Description: Creates new macro to replace either old or none-existing songs.
--
-- Inputs:
--		user		-- which user in SETUP plugin to use
--		poolIndex	-- which ADDON to use (or SONGS)
--		caller		-- what plugin is using this function
--
-- Output: Nothing
-- =======================================================================================
function maker.repair(user, poolIndex, caller)
	local countPoolNum = maker.manage("Current", user, 1, user.first[1])
	local repairCount = maker.manage("Current", user, poolIndex, user.first[poolIndex])
	local seqPool = maker.manage("Pool", user, 1)
	local poolHandle = G_OBJ.handle(seqPool .." " ..countPoolNum)
	local songName, singleString

	while G_OBJ.verify(poolHandle) do
		poolHandle = G_OBJ.handle(seqPool .." " ..countPoolNum)
		singleString = G_OBJ.label(poolHandle)
		songName = singleString:gsub("_" , " ")

		maker.manage("Create", user, poolIndex, songName, repairCount)

		repairCount = maker.manage("Inc", user, poolIndex, repairCount, 1)
		countPoolNum = maker.manage("Inc", user, 1, countPoolNum, 1)
		poolHandle = G_OBJ.handle(seqPool .." " ..countPoolNum)

	end
end
-- ==== END OF maker.repair ==============================================================
