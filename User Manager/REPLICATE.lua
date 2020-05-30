-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: REPLICATE.lua
-- Programmer: Cooper Santillan
-- Last Modified: May 30, 2020 12:22am
-- =======================================================================================
-- Description: Will prompt the user for the label or sequence number of a requested song
--				to copy: song's sequence, Maker macro, and Adder macro. Will automatically
--				place a tag at the end of labels for a next version type. If the requested
--				song has multiple versions found, the program will ask the user for what
--				version they would like to copy.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus













-- =======================================================================================
-- ==== MAIN: REPLICATE ==================================================================
-- =======================================================================================
local function REPLICATE()
	local user = localUser
	local caller = "REPLICATE"
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
	local currPool
	local boolContinue = true

	-- ask user for the song name
	-- loop until user inputs a string that contains no punctuation
	repeat

		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Song Name! \n Make sure there are no special characters"))) then
				maker.util.print(ESC_RED .."Plugin Terminated: Song name not changed.", caller)
				return -13
			end
		end

		-- ask user for a song name
		renameSong = gma.textinput("Which Song To Copy?" , "" )
		boolContinue = true


		-- end program if they escape from writing a name
		if (renameSong == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated: Song name not changed.", caller)
			return -13
		elseif (renameSong == "") then
			boolContinue = false
		end

	until boolContinue

	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	for i=1, macroAmount do user.last[i] = maker.find.avail(user, i) end
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
	local locations = maker.find.strOrNum(user, renameSong, caller)
	if (locations == false) then return false end

	renameSong = G_OBJ.label(G_OBJ.handle(maker.manage("Pool", user, 1) .." " ..locations[1]))
	renameSong = renameSong:gsub("_V%d+" , "")
	renameSong = renameSong:gsub("_", " ")

	-- -- if the user requested to manually place a version number, this statement will remove the version they are requesting
	-- -- program will take over and discover what version to pick
	-- if (renameSong:find(" V%d+")) then
	-- 	--a = songName:match(" V(%d+)")
	-- 	renameSong = renameSong:gsub(" V%d+" , "")
	-- end

	local pastVersion = maker.find.ver.next(user, 1, renameSong)
	renameSong = maker.util.underVer(renameSong, nil, pastVersion)

	for i=1, macroAmount do
		if not(maker.manage("Copy", user, i, locations[i], user.last[i])) then return false end
		if not(maker.manage("Edit", user, i, renameSong, user.last[i])) then return false end
	end

	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."================================================================")
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Source      Song Name: " ..ESC_WHT ..gma.show.getobj.label(gma.show.getobj.handle(maker.manage("Pool", user, 1) .." " ..locations[1])))
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Destination Song Name: " ..ESC_WHT ..renameSong)
	for i=1, macroAmount do
		gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."SRC to DEST " ..maker.manage("Pool", user, i):upper() .." : " ..ESC_GRN ..maker.manage("Pool", user, i) .." " ..ESC_WHT ..locations[i]  ..ESC_YEL .."  --->  " ..ESC_GRN ..maker.manage("Pool", user, i) .." " ..ESC_WHT ..user.last[i])
	end
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."================================================================")

	-- Assign the new sequence to the selected executor
	--gma.cmd("Assign Sequence " ..availSeq .." At Executor " ..gma.show.getobj.number(gma.user.getselectedexec()))
	  gma.cmd("Assign " ..maker.manage("Pool", user, 1) .." " ..user.last[1] .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))



end
-- =======================================================================================
-- ==== END OF REPLICATE =================================================================
-- =======================================================================================

return REPLICATE;
