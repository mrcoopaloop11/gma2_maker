-- =======================================================================================
-- Plugin: REVISE.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: Prompts the user for either the label or sequence number of a requested
--				song and assigns the song on to the selected executor. Additionally will
--				make sure that the songs macros for Maker and Adder exist and will not
--				assign song sequence until the problem is resolved.
-- =======================================================================================

















-- =======================================================================================
-- ==== MAIN: REVISE =====================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
function maker.task.revise(localUser)
	local user = localUser

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
	local locations = maker.find.strOrNum(user, renameSong, caller)
	if (locations == false) then return false end

	renameSong = G_OBJ.label(G_OBJ.handle(maker.manage("Pool", user, 1) .." " ..locations[1]))
	renameSong = renameSong:gsub("_V%d+" , "")
	renameSong = renameSong:gsub("_", " ")

	-- print on command line feedback information about what and where the new song is
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Song Name: " ..ESC_WHT ..renameSong)
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Song " ..maker.manage("Pool", user, 1) ..": " ..ESC_WHT ..locations[1])
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")

	-- Assign the new sequence to the selected executor
	--gma.cmd("Assign Sequence " ..availSeq .." At Executor " ..gma.show.getobj.number(gma.user.getselectedexec()))
	  gma.cmd("Assign Sequence " ..locations[1] .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))

end
-- =======================================================================================
-- ==== END OF REVISE ====================================================================
-- =======================================================================================
