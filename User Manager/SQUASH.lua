-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: SQUASH.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
-- =======================================================================================
-- Description: Will prompt the user for a sequence label or number the user would like to
--				delete from their Maker+ Library. Will additionally ask if the user would
--				like to condense the sequence library, Maker library, and Adder Library.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus















-- =======================================================================================
-- ==== MAIN: SQUASH =====================================================================
-- =======================================================================================
local function SQUASH()
	local user = localUser
	local caller = "SQUASH"
	local G_OBJ = gma.show.getobj

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
				maker.util.print(ESC_RED .."Plugin Terminated. Song not assigned to selected executor.", caller)
				return -13
			end
		end

		-- ask user for a song name
		renameSong = gma.textinput("Which Song To Edit?" , "" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (renameSong == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. Song not assigned to selected executor.", caller)
			return -13
		elseif (renameSong == "") then
			boolContinue = false
		end

	until boolContinue

	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	for i=1, macroAmount do user.last[i] = maker.find.avail(user, i) end
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	local index, compensate, offset, currPool, last
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

	for i=1, macroAmount do
		if not(maker.manage("Delete", user, i, locations[i])) then
			maker.util.print(ESC_RED .."There was an error while trying to use " ..user.name[i], caller)
			-- return false
		end
	end

	for i=1, macroAmount do
		if (locations[i] ~= maker.manage("Inc", user, i, user.last[i], -1)) then
			if(gma.gui.confirm("Condense MAKER+ Libraries" , "Would you like to condense the MAKER+ libraries?")) then
				gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
				for i=1, macroAmount do
					user.last[i] = maker.find.gap(user, i, caller)
					maker.move.obj(user, i, caller)
				end
				gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
				break;
			end
		end
	end

	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Song  Name: " ..ESC_RED ..renameSong)
	for i=1, macroAmount do
		currPool = maker.manage("Pool", user, i)
		gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Song " ..currPool:upper() ..": " ..ESC_GRN ..currPool .." " ..ESC_WHT ..locations[i])
	end
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")

end
-- =======================================================================================
-- ==== END OF SQUASH ====================================================================
-- =======================================================================================

return SQUASH;
