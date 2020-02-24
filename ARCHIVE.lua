-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: ARCHIVE.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Description: Intended to find the next available empty sequence starting at request
--				number. Assumes you work at church and host services on Sunday. Please
--				make sure that the MA board is setup properly with current date. If user
--				variable ASSET is set to something: it will figure out when Sunday will be
--				and automatically label new sequence as Sunday's date. If user variable is
--				not set, it will ask user for what they want the sequence to be labeled.
--				Lastly, will copy requested look (from SETUP plugin) to be the first cue
--				of archive.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus










-- =======================================================================================
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================


-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== ROUND ============================================================================
-- Description: Rounds number to the nearest integer.
--
-- Inputs:
--		num					-- Base Number
--		numDecimalPlaces	-- How many decimal places (Default is zero)
--
-- Output: rounded integer number
-- =======================================================================================
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end
-- ==== END OF ROUND =====================================================================


-- ==== DATECONV =========================================================================
-- Description: What is the date X days from now?
--
-- Inputs:
--		OFFSET			-- How many days to add from current day
--
-- Output: New Day after offset applied || month , day , year
-- =======================================================================================
local function dateConv(offset)
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
-- ==== END OF DATECONV ==================================================================

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================





-- =======================================================================================
-- ==== MAIN: ARCHIVE ====================================================================
-- =======================================================================================
local function ARCHIVE()
	local loccpySeq = localUser.service_seq -- copy global variable to update number
	local assetSeq = localUser.serv_content
	local assetCue = localUser.first_cue
	local reqDofW = localUser.weekday

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)


	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	if(type(loccpySeq) ~= "number") or not((type(assetCue) == "string") or (type(assetCue) == "number")) or not((type(assetSeq) == "string") or (type(assetSeq) == "number")) then
		gma.gui.msgbox("ERROR" , "ARCHIVE Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
		gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_RED .."Plugin Error. ARCHIVE is not setup.")
		gma.echo(ESC_WHT .."ARCHIVE Plugin : " ..ESC_RED .."Plugin Error. ARCHIVE is not setup.")
		return -13;
	end


	local G_OBJ = gma.show.getobj
	local startingHandle = G_OBJ.handle("Sequence " ..loccpySeq)
	local labelString

	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	-- check when the next available sequence is from desired starting point
	while G_OBJ.verify(startingHandle) do
		loccpySeq = loccpySeq + 1
		startingHandle = G_OBJ.handle("Sequence " ..loccpySeq)
	end
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")


	local dayOfWeek = os.date("%w")
	if (tonumber(dayOfWeek) ~= 0) then
		dayOfWeek = round(((7/dayOfWeek) - 1) * dayOfWeek)
	end

	if     (reqDofW:upper() == "SUNDAY")     then dayOfWeek = math.fmod(dayOfWeek + 0 , 7)
	elseif (reqDofW:upper() == "MONDAY")     then dayOfWeek = math.fmod(dayOfWeek + 1 , 7)
	elseif (reqDofW:upper() == "TUESDAY")    then dayOfWeek = math.fmod(dayOfWeek + 2 , 7)
	elseif (reqDofW:upper() == "WEDNESDAY")  then dayOfWeek = math.fmod(dayOfWeek + 3 , 7)
	elseif (reqDofW:upper() == "THURSDAY")   then dayOfWeek = math.fmod(dayOfWeek + 4 , 7)
	elseif (reqDofW:upper() == "FRIDAY")     then dayOfWeek = math.fmod(dayOfWeek + 5 , 7)
	elseif (reqDofW:upper() == "SATURDAY")   then dayOfWeek = math.fmod(dayOfWeek + 6 , 7)
	else
		gma.gui.msgbox("ERROR" , "ARCHIVE Plugin was NOT correctly setup!\nYou did not pick a correct day of the week!")
		gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_RED .."Plugin Terminated. No archive sequence created.")
		gma.echo(ESC_WHT .."ARCHIVE Plugin : " ..ESC_RED .."Plugin Terminated. No archive sequence created.")
		return -13
	end

	local dayOfYear = os.date("%j")
	local newMonth
	local newDay
	local newYear
	newMonth , newDay , numYear = dateConv(dayOfYear + dayOfWeek)
	labelString = string.format("%02d-%02d-%02d" , newMonth , newDay , numYear)

	local boolContinue
	local assetVar = gma.user.getvar(makerVar)
	if(assetVar ~= nil) or (tonumber(assetVar) == 0) then
		gma.user.setvar(makerVar , nil)
		repeat
			-- inform user that they are not able to use punctuation for their song name
			if (boolContinue == false) then
				if (false == (gma.gui.confirm("ERROR" , "Please choose a label name"))) then
					gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_RED .."Plugin Terminated. No archive sequence created.")
					gma.echo(ESC_WHT .."ARCHIVE Plugin : " ..ESC_RED .."Plugin Terminated. No archive sequence created.")
					return -13
				end
			end

			-- ask user for a song name
			labelString = gma.textinput("Name for Archive?" , "" )
			boolContinue = true


			-- end program if they escape from writing a name
			if (labelString == nil) then
				gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_RED .."Plugin Terminated. No archive sequence created.")
				gma.echo(ESC_WHT .."ARCHIVE Plugin : " ..ESC_RED .."Plugin Terminated. No archive sequence created.")
				return -13
			elseif (labelString == "") then
				boolContinue = false
			end

		until boolContinue
	end

	gma.cmd("ClearAll")
	gma.cmd("Store Sequence " ..loccpySeq)
	if(type(assetSeq) == "string") and (type(assetCue) == "string") then
		gma.cmd("Copy Sequence \"" ..assetSeq .."\" Cue \"" ..assetCue .."\" At Sequence " ..loccpySeq .." Cue 1 /o")
	elseif(type(assetSeq) == "number") and (type(assetCue) == "string") then
		gma.cmd("Copy Sequence " ..assetSeq .." Cue \"" ..assetCue .."\" At Sequence " ..loccpySeq .." Cue 1 /o")
	elseif(type(assetSeq) == "string") and (type(assetCue) == "number") then
		gma.cmd("Copy Sequence \"" ..assetSeq .."\" Cue " ..assetCue .." At Sequence " ..loccpySeq .." Cue 1 /o")
	elseif(type(assetSeq) == "number") and (type(assetCue) == "number") then
		gma.cmd("Copy Sequence " ..assetSeq .." Cue " ..assetCue .." At Sequence " ..loccpySeq .." Cue 1 /o")
	end

	gma.cmd("Label Sequence " ..loccpySeq .."\"" ..labelString .."\"")

	-- empty sequence found
	-- prompt user of number chosen
	gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_YEL .."========================================")
	gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_YEL .."Service    Date: " ..ESC_WHT ..labelString)
	gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_YEL .."Created Service: " ..ESC_GRN .."Sequence " ..ESC_WHT ..loccpySeq)
	gma.feedback(ESC_WHT .."ARCHIVE : " ..ESC_YEL .."========================================")

	gma.cmd("Assign Sequence " ..loccpySeq .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))

end
-- =======================================================================================
-- ==== END OF ARCHIVE ===================================================================
-- =======================================================================================

return ARCHIVE;
