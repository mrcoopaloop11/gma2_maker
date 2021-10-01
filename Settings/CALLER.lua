-- =======================================================================================
-- Plugin: CALLER.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: Interfaces between the console and the maker suite plugin suite.
-- =======================================================================================

	-- Take the table from the Setup.lua file, importing all users
	local setupUsers = user



















-- =======================================================================================
-- ==== MAIN: CALLER =====================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
function maker.caller()
	local localUser = setupUsers
	-- which user needs this plugin
	local UserVar = gma.user.getvar('MAKER_USER')
	-- check if it exists
	if(UserVar == nil) then
		maker.util.error("UserVar \'MAKER_USER\' was not found.",
						nil,
						caller)
		return false;
	end

	-- what task needs to be run
	local taskVar = gma.user.getvar('MAKER_TASK')
	-- check if it exists
	if(taskVar == nil) then
		maker.util.error("UserVar \'MAKER_TASK\' was not found.",
						nil,
						caller)
		return false;
	end

	-- cyle through users and determine which one is to be used
	for k in pairs(localUser) do
		if (k:match(UserVar) then
			for j in pairs(maker.task) do
				if(j:match(taskVar) then
					localUser[k].self = k
					maker.task[j](localUser[k])
				end
			end
		end
	end

end
-- =======================================================================================
-- ==== END OF CALLER ====================================================================
-- =======================================================================================

return maker.caller, deleteVars;
