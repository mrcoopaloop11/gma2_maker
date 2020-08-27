-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: REALPHA.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 30, 2020 06:28pm
-- =======================================================================================
-- Description: Will prompt the user to reorganize the Maker+ Library so that it is in
--				alphabetical order. User can hit 'CANCEL' or escape to skip certain area
--				in the Maker+ Library (Sequence, Maker, Adder).
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus















-- =======================================================================================
-- ==== MAIN: REALPHA ====================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
local function REALPHA()
	-- copy settings from the SETUP Plugin
	local user = localUser

	if not(maker.test.seq(user, caller)) then return false; end
	if not(maker.test.pool(user, caller)) then return false; end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

	-- prompt the user for what they would like to re-alphabetize!
	for i=1, macroAmount do
		if (maker.util.prompt(maker.manage("Pool", user, i), caller)) then
			user.last[i] = nil
			maker.move.alpha(user, i, caller)
		end
	end

end
-- =======================================================================================
-- ==== END OF REALPHA ===================================================================
-- =======================================================================================

return REALPHA;
