-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: REALPHA.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Description: Will prompt the user to reorganize the Maker+ Library so that it is in
--				alphabetical order. User can hit 'CANCEL' or escape to skip certain area
--				in the Maker+ Library (Sequence, Maker, Adder).
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus















-- =======================================================================================
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================


-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== ENDINGPOOL =======================================================================
-- Description: Finds the next available empty spot in a pool to store something
--
-- Inputs:
--		POOL		-- String that has MA pool specifier (i.e. Sequence, Macro...)
--		POOLNUMBER	-- Starting number to analyze next available pool space
--		POOLSIZE	-- How many columns wide is view for Maker+?
--
-- Output: Returns an empty pool space
-- =======================================================================================
local function endingPool(pool , poolNumber , poolSize)
	-- variables needed
    local G_OBJ = gma.show.getobj
    local poolHandle = G_OBJ.handle(pool .." " ..poolNumber)
    local countPoolNum = poolNumber


	-- loop from start of pool until reach the first empty pool object
    while G_OBJ.verify(poolHandle) do
        if (0 == math.fmod(countPoolNum + 1 , poolSize)) then
        	-- skip the left most pool object
            countPoolNum = countPoolNum + 1
        end

        countPoolNum = countPoolNum + 1
        poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)
    end

    -- returns the last pool object of a continuous list
    return countPoolNum;
end
-- ==== END OF ENDINGPOOL ================================================================


-- ==== ALPHABAT =========================================================================
-- Description: Re-alphabetizes a continuous line of pool objects.
--
-- Inputs:
--		POOL		-- String that has MA pool specifier (i.e. Sequence, Macro...)
--		POOLNUMBER	-- Starting number to analyze next available pool space
--		POOLSIZE	-- How many columns wide is view for Maker+?
--
-- Output: Nothing.
-- =======================================================================================
local function ALPHABAT(pool , poolNumber , poolSize)
	-- change colors on gma feedback/echo
    local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

    local G_OBJ = gma.show.getobj
    gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
    local final = endingPool(pool , poolNumber , poolSize) - 1
    gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")
    local refTable = {}

    -- records current pool area and compares with a reference of the pool objects that has been realphabetized
    -- comparison will see if there needs to be changes from start to finish
    -- will loop back to here every change
    ::reevaluate::

    local poolHandle = G_OBJ.handle(pool .." " ..poolNumber)
    local countPoolNum = poolNumber
    local counter = 1
    local counterOne = 0;
    local counterTwo = 0;
    local modCounter = 0;

	-- copy down all labels from pool in continuous list on to an array
    while (countPoolNum <= final) do
        if (0 == math.fmod(countPoolNum + 1 , poolSize)) then
        	-- skip the left most pool object column
            countPoolNum = countPoolNum + 1
        end

		-- record pool object label in array
        refTable[counter] = G_OBJ.label(poolHandle)
        counter = counter + 1

        countPoolNum = countPoolNum + 1
        poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)
    end

	-- re organize into alphabetical order!
    table.sort(refTable)

    -- loop again from the beginning of the pool until end
    -- move/replace from start to beginning the
    for k , v in ipairs(refTable) do
        counterOne = poolNumber + k - 1 + modCounter
        counterTwo = poolNumber + k - 1 + modCounter

        if not(v == G_OBJ.label(G_OBJ.handle(pool .." " ..counterOne))) then
            repeat
                if (0 == math.fmod(counterOne + 1 , poolSize)) then
                    counterOne = counterOne + 1
                end
                counterOne = counterOne + 1
            until (v == G_OBJ.label(G_OBJ.handle(pool .." " ..counterOne)))
            -- found what pool object is and where it needs to be
            -- move pool object
            gma.cmd(string.format("Move %s %d At %s %d" , pool , counterOne , pool , counterTwo))
            -- go back to the beginning of this function
            goto reevaluate
        end

	     if (0 == math.fmod(counterOne + 1 , poolSize)) then
	     	-- skip the left most pool object column
            modCounter = modCounter + 1
        end
    end
end
-- ==== END OF ALPHABAT ==================================================================

-- ==== PROMPT ===========================================================================
-- Description: Using GUI Confirm function, prompts question so that it can return boolean
--
-- Inputs:
--		POOL		-- Any string, doesn't have to be literal pool name
--
-- Output: Boolean statement of true or nil
-- =======================================================================================
local function prompt(pool)
	return gma.gui.confirm("Alphabetize " ..pool .." Pool" , "Would you like to alphabetize the " ..pool .." pool?")
end
-- ==== END OF PROMPT ====================================================================

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================














-- =======================================================================================
-- ==== MAIN: REALPHA ====================================================================
-- =======================================================================================
local function REALPHA()
	-- copy settings from the SETUP Plugin
    local sSeqCopy = localUser.song_seq
    local sMakerCopy = localUser.maker
    local sAdderCopy = localUser.adder
    local localPoolSize = localUser.pool_size


    -- change colors on gma feedback/echo
    local ESC_RED = string.char(27) .."[31m"
	local ESC_GRN = string.char(27) .."[32m"
	local ESC_YEL = string.char(27) .."[33m"
	local ESC_WHT = string.char(27) .."[37m"

	-- confirming that the plugin was setup
	if(type(sSeqCopy) ~= "number") or (type(sMakerCopy) ~= "number") or (type(sAdderCopy) ~= "number") then
		gma.gui.msgbox("ERROR" , "REALPHA Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
		gma.feedback(ESC_WHT .."REALPHA : " ..ESC_RED .."Plugin Error. REALPHA is not setup.")
		gma.echo(ESC_WHT .."REALPHA Plugin : " ..ESC_RED .."Plugin Error. REALPHA is not setup.")
		return -13;
	end

	if(type(localPoolSize) ~= "number") then
		gma.gui.msgbox("ERROR" , "REALPHA Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!")
		gma.feedback(ESC_WHT .."REALPHA : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		gma.echo(ESC_WHT .."REALPHA Plugin : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		return -13;
	elseif(localPoolSize <= 1) then
		gma.gui.msgbox("ERROR" , "REALPHA Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!")
		gma.feedback(ESC_WHT .."REALPHA : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		gma.echo(ESC_WHT .."REALPHA Plugin : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		return -13;
	end


	-- prompt the user for what they would like to re-alphabetize!
	if (prompt("SEQUENCE")) then
		ALPHABAT("Sequence" , sSeqCopy , localPoolSize)
	end
    if (prompt("MAKER")) then
		ALPHABAT("Macro" , sMakerCopy , localPoolSize)
	end
	if (prompt("ADDER")) then
		ALPHABAT("Macro" , sAdderCopy , localPoolSize)
	end

end
-- =======================================================================================
-- ==== END OF REALPHA ===================================================================
-- =======================================================================================

return REALPHA;
