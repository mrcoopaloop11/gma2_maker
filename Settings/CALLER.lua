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

	local uflag = true	-- user flag, true if no user was found in match
	local tflag = true	-- task flag, true if no task was found in match

	-- cyle through users and determine which one is to be used
	for k in pairs(localUser) do
		if (k:match(UserVar) then
			uflag = false
			for j in pairs(maker.task) do
				if(j:match(taskVar) then
					localUser[k].self = k
					maker.task[j](localUser[k])
					tflag = false
				end
			end
		end
	end

	-- prompt the user if there was an error
	if(uflag and tflag) then
		gma.gui.msgbox("ERROR in CALLER Plugin", "The user and program you tried using were not found.\n You set " ..UserVar .." as a user and " ..taskVar .." as the program to use.")
	elseif(uflag) then
		gma.gui.msgbox("ERROR in CALLER Plugin", "The user you tried using were not found.\n You tried using " ..UserVar .." as a user but it does not exist.")
	elseif(tflag) then
		gma.gui.msgbox("ERROR in CALLER Plugin", "The program you tried using were not found.\n You tried using the " ..taskVar .." program but it does not exist.")
	end

end
-- =======================================================================================
-- ==== END OF CALLER ====================================================================
-- =======================================================================================

return maker.caller, deleteVars;
