-- =======================================================================================
-- Plugin: ALT_MAKER.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: References from the SETUP plugin a 'service content' sequence where
--				the user stores all cue essentials (Walk In, Video, Host, etc...).
--				ALT_MAKER will find a requested cue from said-sequence and copy requested
--				cue look so that it would be the last cue for your selected executor
--				sequence. The variable that it will receive can either be the cue name or
--				the number of the cue.
-- =======================================================================================















-- =======================================================================================
-- ==== MAIN: ALT_MAKER ==================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
function maker.task.altMaker(localUser)
	local altMAKERcpy = localUser.serv_content -- updating the global variable

    local makerVar = 'MAKER_SONG' -- User Variable used in grandMA2 software
    							-- Keep as single string (no whitespace)


	-- shortcut for GMA show objects
	local G_OBJ = gma.show.getobj
	local G_PRO = gma.show.property

	-- confirming that the plugin was setup
	local servHandle
	if(type(altMAKERcpy) == "string") then
	-- user setup the plugin to find sequence string label
		servHandle = G_OBJ.handle("Sequence \"" ..altMAKERcpy .."\"")
	elseif(type(altMAKERcpy) == "number") then
		-- user setup the plugin to find sequence number
		servHandle = G_OBJ.handle("Sequence " ..altMAKERcpy)
	else
		-- failed to confirm setup, please setup program
		maker.util.error(ESC_RED .."Plugin Error. ALT_MAKER is not setup.",
						"ALT_MAKER Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!",
						caller)
		return -13;
	end

	-- what is the master sequence (from setup) information
	local servSeqNumber = tonumber(G_OBJ.number(servHandle))
	local servSeqName = "Sequence " ..servSeqNumber
	local servAmou = tonumber(G_OBJ.amount(servHandle) - 1)
	-- find the information for the users selected executor
	local SelSeqHand = G_OBJ.parent(G_OBJ.handle("Cue 1"))
	local SelSeqNumber = tonumber(G_PRO.get(SelSeqHand , "No."))
	local SelSeqName = "Sequence " ..G_PRO.get(SelSeqHand , "No.")
	local SelSeqAmou = tonumber(G_OBJ.amount(SelSeqHand) - 1)
	local SelSeqLNum = tonumber(G_OBJ.number(G_OBJ.child(SelSeqHand , SelSeqAmou)))

	local index
	local servCueName
	local servCueNum
	local bContinue = false

	-- check if the asset user variable was set to something
	local assetVar = gma.user.getvar(makerVar)
	if(assetVar == nil) then
		-- user variable makerVar was not set
		maker.util.error(ESC_RED .."Plugin Error. UserVar \'" ..makerVar .."\' was not found.",
						"User Variable \'" ..makerVar .."\' is not set for a requested cue! \n Must set user variable to find cue",
						caller)
		return -13;
	end

	-- test whether the MA user variable is a number or a string
	-- assume that if variable is number, user wants specific cue number
	if(nil ~= (tonumber(assetVar))) then
		-- user called a cue number!
		servCueNum = tonumber(assetVar)
		if (servAmou <= assetVar) then
			bContinue = false
		end
	else
		-- user called to search for the cue string
		for index = 1 , servAmou do
			servCueName = G_OBJ.label(G_OBJ.child(servHandle , index))
			servCueNum = G_OBJ.number(G_OBJ.child(servHandle , index))
			if(servCueName == assetVar) then
				bContinue = true
				break;
			end
		end
	end

	if not(bContinue) then
		-- nothing was found or out of bounds
		maker.util.error(ESC_RED .."Plugin Error. " ..assetVar .." was not found in " ..altMAKERcpy .." sequence",
						"User Variable \'" ..makerVar .."\' is not found in the " ..altMAKERcpy .." sequence! \n Must set user variable to exact cue name that has already been made!",
						caller)
		return -13;
	end

	-- copy cue
	gma.cmd("Copy " ..servSeqName .." Cue " ..servCueNum .." At " ..SelSeqName .." Cue " ..SelSeqLNum + 1 .." /nc")
	gma.user.setvar(makerVar , nil)

end
-- =======================================================================================
-- ==== END OF ALT_MAKER =================================================================
-- =======================================================================================
