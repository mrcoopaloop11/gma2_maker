-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: ARCHIVE.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
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













-- =======================================================================================
-- ==== MAIN: ARCHIVE ====================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
local function maker.task.archive(localUser)
	local loccpySeq = localUser.archive_seq
	local assetSeq = localUser.serv_content
	local assetCue = localUser.first_cue

    local makerVar = 'MAKER_SONG' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)

	if not(maker.test.archive(localUser, caller)) then return false; end

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

	local labelString = maker.util.timeTravel(localUser, caller)
	if (labelString == false) then return false end

	local boolContinue
	local assetVar = gma.user.getvar(makerVar)
	if(assetVar ~= nil) or (tonumber(assetVar) == 0) then
		gma.user.setvar(makerVar , nil)
		repeat
			-- inform user that they are not able to use punctuation for their song name
			if (boolContinue == false) then
				if (false == (gma.gui.confirm("ERROR" , "Please choose a label name"))) then
					maker.util.print(ESC_RED .."Plugin Terminated. No archive sequence created.", caller)
					return -13
				end
			end

			-- ask user for a song name
			labelString = gma.textinput("Name for Archive?" , "" )
			boolContinue = true


			-- end program if they escape from writing a name
			if (labelString == nil) then
				maker.util.print(ESC_RED .."Plugin Terminated. No archive sequence created.", caller)
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
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Service    Name: " ..ESC_WHT ..labelString)
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."Created Service: " ..ESC_GRN .."Sequence " ..ESC_WHT ..loccpySeq)
	gma.feedback(ESC_WHT ..caller .." : " ..ESC_YEL .."========================================")

	gma.cmd("Assign Sequence " ..loccpySeq .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))

end
-- =======================================================================================
-- ==== END OF ARCHIVE ===================================================================
-- =======================================================================================

return ARCHIVE;
