-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: RENAME.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
-- =======================================================================================
-- Description: Within the Maker+ library, RENAME is able to relabel a song to a different
--				name. Using this plugin will still limit the characters that are not
--				supported and will detect the version amount of songs within its own
--				library and adjust with regards to that.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus














-- =======================================================================================
-- ==== MAIN: RENAME =====================================================================
-- =======================================================================================
local function RENAME()
	local caller = "RENAME"
	local user = localUser
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


	local renameSong
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
		renameSong = gma.textinput("Which Song To Rename?" , "" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (renameSong == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. Song not created.", caller)
			return -13
		elseif (renameSong == "") then
			boolContinue = false
		end

	until boolContinue

	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	for i=1, macroAmount do user.last[i] = maker.find.avail(user, i, caller) end
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	local index
	local locations = {}


	if (tonumber(renameSong) == nil) then
		locations = maker.find.ver.pick(user, renameSong)
		if not(locations) then
			maker.util.error("Could not find " ..renameSong .." in your library!", nil, caller)
			return false;
		end
	else
		locations[1] = tonumber(renameSong)

		bContinue = true
		currPool = maker.manage("Pool", user, 1)
		if (G_OBJ.verify(G_OBJ.handle(currPool .." " ..locations[1]))) then
			currPool = maker.manage("Pool", user, i)
			index = maker.manage("Current", user, i, user.first[i])
			last = maker.find.last(user, i, caller)

			while (index <= last) do
			    if (G_OBJ.label(G_OBJ.handle(currPool .." " ..index)) == string.gsub(G_OBJ.label(G_OBJ.handle("Sequence " ..locations[1])) , "_" , " ")) then
			        locations[i] = index
			    end
			    index = maker.manage("Inc", user, i, index, 0)
			end

			for i=1, macroAmount do
				if not(locations[i]) then
					maker.util.error(ESC_RED .."Please use repairing plugin. Missing objects in song library. Try again later.", nil, caller)
					return false;
				end
			end
		else
			maker.util.error(ESC_RED .."Macro " ..renameSong .." does not exist.",
							"The number you have requested does not exist in the macro library!",
							caller)
			return false;
		end
	end

	renameSong = G_OBJ.label(G_OBJ.handle(maker.manage("Pool", user, 1) .." " ..locations[1]))
	renameSong = renameSong:gsub("_V%d+" , "")
	renameSong = renameSong:gsub("_", " ")

	boolContinue = true
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
		newSongName = gma.textinput("New Song Name?" , renameSong )
		boolContinue = true


		-- end program if they escape from writing a name
		if (newSongName == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. Song not created.", caller)
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

	local pastVersion = maker.find.ver.next(user, 1, newSongName, caller)
	newSongName = maker.util.underVer(newSongName, nil, pastVersion, caller)

	for i=1, macroAmount do
		if not(maker.manage("Edit", user, i, maker.util.underVer(newSongName, maker.manage("Pool", user, i), nil, caller), locations[i])) then return false end
	end

	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."=========================================")
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Old Song Name: " ..ESC_RED ..renameSong)
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."New Song Name: " ..ESC_WHT ..newSongName)
	for i=1, macroAmount do
		gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Changed " ..maker.manage("Pool", user, i):upper() .." : " ..ESC_GRN ..maker.manage("Pool", user, i) .." " ..ESC_WHT ..user.last[i])
	end
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."=========================================")


end
-- =======================================================================================
-- ==== END OF RENAME ====================================================================
-- =======================================================================================

return RENAME;
