-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: FINDER.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
-- =======================================================================================
-- Description: User can type the song they are looking for in a continuous list of
--              macros. Starting from the first song, the range of the search will end at
--              the next empty macro pool object. This program's text input from the user
--              is not case-sensitive. This program is able to flash all versions of songs
--              made by Maker. Text input from the user does not have to be complete name
--              of the song, can be part of it. Plugin will flash macro match three times.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus












-- =======================================================================================
-- ==== MAIN: FINDER =====================================================================
-- =======================================================================================
local function FINDER()
	local user = localUser
	local caller = "FINDER"

	local makerVar = 'MAKER' -- User Variable used in grandMA2 software
							-- Keep as single string (no whitespace)

	if not(maker.test.seq(user, caller)) then return false; end
	if not(maker.test.pool(user, caller)) then return false; end

	local macroAmount = maker.test.count(user, caller)
	if not(macroAmount) then
		maker.util.error("Setup -> Add-ons were not setup completely!", nil, caller)
		return false
	end

    -- ask user what song they are looking for
    local songName = gma.textinput("Search Song?" , "" )
	if (songName == nil) then
		-- User has cancelled; plugin will not continue
		maker.util.print(ESC_RED .."Plugin Terminated. Song not created.", caller)
		return false;
	end


    local bOperands
    local setOperands
	setOperands, songName = maker.find.operand(user, songName, caller)

	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
	local file = {instances = {}, array = {}}
	file.array[1] = {}
	file.instances[1], file.array[1] = maker.find.ver.count(user, 1, maker.util.underVer(songName, maker.manage("Pool", user, 1), nil, caller), caller)
	for i=2, macroAmount do
		file.array[i] = {}
		file.instances[i], file.array[i] = maker.find.ver.count(user, i, maker.util.underVer(songName, maker.manage("Pool", user, i), nil, caller), caller)
	end
	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")

	local loopLen = 3
	-- flash the matching macros 3 times white
	-- reset color of macro to default color at the end
	for x=1, loopLen - 1 do
		for i=1, macroAmount do
			if (file.instances[i]) then
				gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r=100 /g=100 /b=100")
			end
		end
		gma.sleep(0.5)
		--* if ((loopLen == i) and (nil ~= setOperands)) then maker.request(user, 1, ) end
		for i=1, macroAmount do
			if (file.instances[i]) then
				gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r")
			end
		end
		gma.sleep(0.15)
	end

	for i=1, macroAmount do
		if (file.instances[i]) then
			gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r=100 /g=100 /b=100")
		end
	end
	if (nil ~= setOperands) then maker.request(user, setOperands, file.array[1]) end
	gma.sleep(0.5)
	for i=1, macroAmount do
		if (file.instances[i]) then
			gma.cmd("Appearance " ..maker.manage("Pool", user, i) .." " ..maker.util.thru(file.array[i])  .." /r")
		end
	end

end
-- =======================================================================================
-- ==== END OF FINDER ====================================================================
-- =======================================================================================

return FINDER;
