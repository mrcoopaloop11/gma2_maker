-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: CONDENSE.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 30, 2020 06:28pm
-- =======================================================================================
-- Description: Able to remove all gaps that would typically prevent a library to stop
--				see potentially other sequence/addon canditates. Prompts user for each
--				library. Will have a tolerance of two gaps to find another object, third
--				gap will assume library is finished.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus
















-- =======================================================================================
-- ==== MAIN: CONDENSE ===================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
local function CONDENSE()
	local user = localUser
	local currPool

	if not(maker.test.seq(user, caller)) then return false; end
	if not(maker.test.pool(user, caller)) then return false; end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

	local libSizePool
	for i=1, macroAmount do
		currPool = maker.manage("Pool", user, i)
		libSizePool = maker.util.input(user, i, currPool .." Ending?", caller)
		if (libSizePool == false) then return false end
		if (libSizePool == "Skip") then goto SKIP_INST end
		if (libSizePool == "Auto") then user.last[i] = maker.find.gap(user, i, caller)
		else user.last[i] = tonumber(libSizePool) end
		maker.move.obj(user, i, caller)
		::SKIP_INST::
	end
end

return CONDENSE;
