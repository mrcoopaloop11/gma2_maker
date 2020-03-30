-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: BUILD.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
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
-- ==== MAIN: BUILD ======================================================================
-- =======================================================================================
local function BUILD()
	-- store global variables (on the very top of plugin editor) to local variables
	-- this ensures every run will update a new starting pool number
	local user = localUser
	local caller = "BUILD"
	local G_OBJ = gma.show.getobj

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)

	if not(maker.test.seq(user, caller)) then return false; end
	if not(maker.test.pool(user, caller)) then return false; end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

	local songName
	local boolContinue = true

	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure there are no special characters"))) then
				maker.util.print(ESC_RED .."Plugin Terminated. Song not created.", caller)
				return -13
			end
		end

		-- ask user for a song name
		songName = gma.textinput("Name of the Song?" , "" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (songName == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. Song not created.", caller)
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
	for i=1, macroAmount do user.last[i] = maker.find.avail(user, i) end
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")


	-- create a new song (sequence and macro objects)
	-- call function to check for previous versions of a song
	local versionNumber = maker.find.ver.next(user, 1, songName)
	for i=1, macroAmount do
		maker.manage("Create", user, i, maker.util.underVer(songName, maker.manage("Pool", user, i), versionNumber), user.last[i])
	end

	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Name  &  Version: " ..ESC_WHT ..songName .." V" ..versionNumber)
	for i=1, macroAmount do
		gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Created " ..maker.manage("Pool", user, i):upper() .." : " ..ESC_GRN ..maker.manage("Pool", user, i) .." " ..ESC_WHT ..user.last[i])
	end
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")


	-- Assign the new sequence to the selected executor
	--gma.cmd("Assign Sequence " ..availSeq .." At Executor " ..gma.show.getobj.number(gma.user.getselectedexec()))
	  gma.cmd("Assign " ..maker.manage("Pool", user, 1) .." " ..user.last[1] .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))


end
-- =======================================================================================
-- ==== END OF BUILD =====================================================================
-- =======================================================================================

return BUILD;
