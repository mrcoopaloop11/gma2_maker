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

	local makerVar = gma.user.getvar('MAKER')
	-- check if it exists
	if(makerVar == nil) then
		maker.util.error("UserVar \'MAKER\' was not found.",
						nil,
						caller)
		return false;
	end

	local userVar, taskVar, makerVar = maker.util.unpack(makerVar, caller)


	-- check if the user input user and task correctly (if it exists)
	local singleUser = localUser[userVar]
	local singleTask = maker.task[taskVar]

	if((singleUser == nil) and (singleTask == nil)) then
		gma.gui.msgbox("ERROR in CALLER Plugin", "The user and program you tried using were not found.\n\n You set: \nUser: " ..userVar .."\nTask: " ..taskVar .."")
	elseif(singleUser == nil) then
		gma.gui.msgbox("ERROR in CALLER Plugin", "The user you tried using were not found.\n\n You set: \nUser: " ..userVar)
	elseif(singleTask == nil) then
		gma.gui.msgbox("ERROR in CALLER Plugin", "The program you tried using were not found.\n\n You set: \nTask: " ..taskVar)
	else
		singleUser.self = userVar
		singleTask(singleUser) -- exits caller and performs task with requested User
	end

end
-- =======================================================================================
-- ==== END OF CALLER ====================================================================
-- =======================================================================================

function maker.debugCaller()
	-- cyle through users and determine which one is to be used
	maker.util.print("Printing all users found in USER table: ", caller)
	for k in pairs(user) do
		maker.util.print("User: "..k, caller)
		for j in pairs(user[k]) do
			maker.util.print("==> Parameter: " ..j, caller)
		end
	end

	maker.util.print("", caller)
	maker.util.print("Printing all available tasks in Maker+ suite: ", caller)
	for t in pairs(maker.task) do
		maker.util.print("Task: " ..t, caller)
	end
end

return maker.caller, deleteVars;
