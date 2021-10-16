-- =======================================================================================
-- Plugin: REPAIR.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: This program will repair any missing macros from the sequence list.
--				Assuming that your song sequence pool is continuous. Great to use if you
--				think you may have messed up a macro by accident or want to add your own
--				sequence to your song sequence list.
-- =======================================================================================

















-- =======================================================================================
-- ==== MAIN: REPAIR =====================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
function maker.task.repair(localUser)
	local user = localUser

	if not(maker.test.seq(user, caller)) then return false; end
	if not(maker.test.pool(user, caller)) then return false; end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

	for i=2, macroAmount do
		if(maker.util.prompt(maker.manage("Pool", user, i), "Repair Maker+ Library")) then
			maker.repair(user, i, caller)
		end
	end
end
-- =======================================================================================
-- ==== END OF REPAIR ====================================================================
-- =======================================================================================
