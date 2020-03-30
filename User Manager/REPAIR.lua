-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: REPAIR.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
-- =======================================================================================
-- Description: This program will repair any missing macros from the sequence list.
--				Assuming that your song sequence pool is continuous. Great to use if you
--				think you may have messed up a macro by accident or want to add your own
--				sequence to your song sequence list.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus














-- =======================================================================================
-- ==== MAIN: REPAIR =====================================================================
-- =======================================================================================
local function REPAIR()
	local caller = "REPAIR"
	local user = localUser

	if not(maker.test.seq(user, caller)) then return false; end
	if not(maker.test.pool(user, caller)) then return false; end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

	for i=2, macroAmount do
		if(maker.util.prompt(maker.manage("Pool", user, i), "Realphabetize")) then
			maker.repair(user, i, caller)
		end
	end
end
-- =======================================================================================
-- ==== END OF REPAIR ====================================================================
-- =======================================================================================

return REPAIR;
