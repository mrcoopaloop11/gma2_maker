-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: REPAIR.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 09 2019 10:13pm
-- =======================================================================================
-- Description: This program will repair any missing macros from the sequence list.
--				Assuming that your song sequence pool is continuous. Great to use if you
--				think you may have messed up a macro by accident or want to add your own
--				sequence to your song sequence list.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus














-- =======================================================================================
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================


-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== POOLREPAIR =======================================================================
-- Description: Creates new macro to replace either old or none-existing songs.
--
-- Inputs:
--		POOLSTRING		-- Name of the pool
--		POOLNUMBER		-- Number of starting macro to scan
-- 		SEQNUMREF		-- Number of starting sequence to scan
-- 		POOLSIZE		-- Column size for view
-- 		PLUGINNAME		-- Name of the macro type plugin
-- 		VARIABLE		-- MA User variable name
--
-- Output: Nothing
-- =======================================================================================
local function poolRepair(poolString , poolNumber , seqNumRef , poolSize , pluginName , variable)
	local countPoolNum = seqNumRef
	local availMacro = poolNumber
	local G_OBJ = gma.show.getobj
	local poolHandle = G_OBJ.handle("Sequence " ..countPoolNum)

	while G_OBJ.verify(poolHandle) do

		poolHandle = G_OBJ.handle("Sequence " ..countPoolNum)
		singleString = G_OBJ.label(poolHandle)
		songName = string.gsub(singleString , "_" , " ")


		gma.cmd("Store Macro " ..availMacro)
		gma.cmd("Store Macro 1." ..availMacro ..".1 thru Macro 1." ..availMacro ..".3")

		gma.cmd("Label Macro " ..availMacro .." \"" ..songName .."\"")

		gma.cmd("Assign Macro 1." ..availMacro ..".1 /cmd=\"SetUserVar $" ..variable .." = " ..singleString .."\"")
		gma.cmd("Assign Macro 1." ..availMacro ..".2 /wait=0.1")
		gma.cmd("Assign Macro 1." ..availMacro ..".3 /cmd=\"Plugin " ..pluginName .."\"")

		if (0 == math.fmod(countPoolNum + 1 , poolSize)) then
			countPoolNum = countPoolNum + 1
			availMacro = availMacro + 1
		end

		availMacro = availMacro + 1
		countPoolNum = countPoolNum + 1
		poolHandle = G_OBJ.handle("Sequence " ..countPoolNum)

	end
end
-- ==== END OF POOLREPAIR ================================================================


-- ==== PROMPT ===========================================================================
-- Description: Using GUI Confirm function, prompts question so that it can return boolean
--
-- Inputs:
--		POOL		-- Any string, doesn't have to be literal pool name
--
-- Output: Boolean statement of true or nil
-- =======================================================================================
local function prompt(pool)
	return gma.gui.confirm("Repair " ..pool .." Pool" , "Would you like to repair the " ..pool .." pool?")
end
-- ==== END OF PROMPT ====================================================================


-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================





-- =======================================================================================
-- ==== MAIN: REPAIR =====================================================================
-- =======================================================================================

local function REPAIR()
	local cpySeq = localUser.song_seq
	local cpyMaker = localUser.maker
	local cpyAdder = localUser.adder
	local localPoolSize = localUser.pool_size
	local makerPlugin = localUser.pluginMAKER
	local adderPlugin = localUser.pluginADDER

    local makerVar = 'MAKER' -- User Variable used in grandMA2 software
    						-- Keep as single string (no whitespace)
	local adderVar = 'MAKER' -- User Variable used in grandMA2 software
							-- Keep as single string (no whitespace)

	-- escape codes to color the system monitor and commandline
	local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	if(type(cpySeq) ~= "number") or (type(cpyMaker) ~= "number") or (type(cpyAdder) ~= "number") then
		gma.gui.msgbox("ERROR" , "REPAIR Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
		gma.feedback(ESC_WHT .."REPAIR : " ..ESC_RED .."Plugin Error. REPAIR is not setup.")
		gma.echo(ESC_WHT .."REPAIR Plugin : " ..ESC_RED .."Plugin Error. REPAIR is not setup.")
		return -13;
	end

	if(type(localPoolSize) ~= "number") then
		gma.gui.msgbox("ERROR" , "REPAIR Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!")
		gma.feedback(ESC_WHT .."REPAIR : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		gma.echo(ESC_WHT .."REPAIR Plugin : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		return -13;
	elseif(localPoolSize <= 1) then
		gma.gui.msgbox("ERROR" , "REPAIR Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!")
		gma.feedback(ESC_WHT .."REPAIR : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		gma.echo(ESC_WHT .."REPAIR Plugin : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		return -13;
	end

	if(type(makerPlugin) ~= "string") or (type(adderPlugin) ~= "string") then
		gma.gui.msgbox("ERROR" , "REPAIR Plugin was NOT setup!\nPlease identify what your labels are for MAKER plugin or ADDER plugin!")
		gma.feedback(ESC_WHT .."REPAIR : " ..ESC_RED .."Plugin Error. Identify labels for MAKER/ADDER plugins in SETUP Plugin.")
		gma.echo(ESC_WHT .."REPAIR Plugin : " ..ESC_RED .."Plugin Error. Identify labels for MAKER/ADDER plugins in SETUP Plugin.")
		return -13;
	end

	if makerPlugin:match("%s") or adderPlugin:match("%s") then
		gma.gui.msgbox("ERROR" , "REPAIR Plugin was NOT correctly setup!\nNo whitespace in label for MAKER/ADDER plugin!")
		gma.feedback(ESC_WHT .."REPAIR : " ..ESC_RED .."Plugin Error. No whitespace in label for MAKER/ADDER plugin.")
		gma.echo(ESC_WHT .."REPAIR Plugin : " ..ESC_RED .."Plugin Error. No whitespace in label for MAKER/ADDER plugin.")
		return -13;
	end



	if (prompt("MAKER")) then
		poolRepair("Macro" , cpyMaker , cpySeq , localPoolSize , makerPlugin , makerVar)
	end
	if (prompt("ADDER")) then
		poolRepair("Macro" , cpyAdder , cpySeq , localPoolSize , adderPlugin , adderVar)
	end


end
-- =======================================================================================
-- ==== END OF REPAIR ====================================================================
-- =======================================================================================

return REPAIR;
