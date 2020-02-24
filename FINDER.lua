-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: FINDER.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
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
-- ==== DO NOT TOUCH BELOW ===============================================================
-- =======================================================================================


-- =======================================================================================
-- ==== FUNCTIONS ========================================================================
-- =======================================================================================

-- ==== SMARTGROUPS ======================================================================
-- Description: If this table received a table like: {1, 2, 3, 4, 5, 6, 8, 9, 10, 15, 16}
--				this will return a string "1 Thru 6 + 8 Thru 10 + 15 + 16".
--
-- Inputs:
--		...		-- Table of numbers of any amount; ordered
--
-- Output: String
-- =======================================================================================
local function SMARTGROUPS(...)
    local matchingSongs = {table.unpack(...)}
    local wholeNumbers
    local bContinue = true
    local counter = 1
    local anotherCounter = 0

    while counter <= #matchingSongs do
        if ((matchingSongs[counter + 1] ~= nil) and (matchingSongs[counter] == (matchingSongs[counter + 1]) - 1)) then
            if ((matchingSongs[counter + 2] ~= nil) and (matchingSongs[counter + 1] == (matchingSongs[counter + 2]) - 1)) then
                repeat
                    if (matchingSongs[counter + 3 + anotherCounter] ~= nil) then
                        if (matchingSongs[counter + 2 + anotherCounter] == (matchingSongs[counter + 3 + anotherCounter]) - 1) then
                            anotherCounter = anotherCounter + 1
                            bContinue = false
                        else
                            bContinue = true
                        end
                    else
                        bContinue = true
                    end
                until bContinue

                if (counter == 1) then
                    wholeNumbers = matchingSongs[counter] .." Thru " ..matchingSongs[counter + 2 + anotherCounter]
                else
                    wholeNumbers = wholeNumbers .." + " ..matchingSongs[counter] .." Thru " ..matchingSongs[counter + 2 + anotherCounter]
                end
                counter = counter + 2 + anotherCounter
                anotherCounter = 0
                bContinue = true

            elseif ((matchingSongs[counter + 2] ~= nil) and (matchingSongs[counter + 1] ~= (matchingSongs[counter + 2]) - 1)) then
                if (counter == 1) then
                    wholeNumbers = matchingSongs[counter] .." + " ..matchingSongs[counter + 1]
                else
                    wholeNumbers = wholeNumbers .." + " ..matchingSongs[counter] .." + " ..matchingSongs[counter + 1]
                end
                counter = counter + 1
            elseif (matchingSongs[counter + 2] == nil) then
                if (counter == 1) then
                    wholeNumbers = matchingSongs[counter]
                else
                    wholeNumbers = wholeNumbers .." + " ..matchingSongs[counter]
                end
            end
        else
            if (counter == 1) then
                wholeNumbers = matchingSongs[counter]
            else
                wholeNumbers = wholeNumbers .." + " ..matchingSongs[counter]
            end
        end
        counter = counter + 1
    end

    return wholeNumbers;
end
-- ==== END OF SMARTGROUPS ===============================================================


-- ==== POOLMATCHER ======================================================================
-- Description: Finds the next available empty spot in a pool to store something
--
-- Inputs:
--		POOL		-- String that has MA pool specifier (i.e. Sequence, Macro...)
--		POOLNUMBER	-- Starting number to analyze next available pool space
--		POOLSIZE	-- How many columns wide is view for Maker+?
--
-- Output: Returns an empty pool space
-- =======================================================================================
local function POOLMATCHER(pool , poolNumber , sName , poolSize)
    -- all local variables needed for plugin
    local G_OBJ = gma.show.getobj
    local poolCopy = pool
    local reqSong = sName
    local countPoolNum = poolNumber
    local poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)
    local poolSongArray = {}
    local arrayCounter = 1
    local tempName

    -- check all macros (starting from searchMacro variable) until reach an empty macro
    while G_OBJ.verify(poolHandle) do
        -- store macro label
        tempName = G_OBJ.label(G_OBJ.handle(pool .." " ..countPoolNum))

        -- match current macro with desired text given my user
        if (string.match(string.upper(tempName) , string.upper(reqSong))) then
            -- record which macro had match in pool
            poolSongArray[arrayCounter] = countPoolNum
            -- set next
            arrayCounter = arrayCounter + 1
        end

        -- increment to next macro
        countPoolNum = countPoolNum + 1
        -- skip macro objects from the far left of the pool
        if (0 == math.fmod(countPoolNum , poolSize)) then
            countPoolNum = countPoolNum + 1
        end

        -- record macro handle for verification test
        poolHandle = G_OBJ.handle(pool .." " ..countPoolNum)
    end

    return SMARTGROUPS(poolSongArray) , poolSongArray

end
-- ==== END OF POOLMATCHER ===============================================================


-- ==== OPERMA ===========================================================================
-- Description: First asks what version song you'd like to interact with if their are
--				others. Then uses requested plugin.
--
-- Inputs:
--		OPTION			-- 'Adder' or 'Maker' or 'Edit' or nil
--		MAKERPLUGIN		-- Label name of Maker Plugin requested
--		ADDERPLUGIN		-- Label name of Adder Plugin requested
--		MAKERVAR		-- MA User Variable so other plugins can use
--
-- Output: Nothing
-- =======================================================================================
local function OPERMA(option , makerPlugin , adderPlugin , makerVar , ...)
    local versionIndex
    local boolContinue = true
    local seqArray = {table.unpack(...)}

    local ESC_RED = string.char(27) .."[31m"
    local ESC_GRN = string.char(27) .."[32m"
    local ESC_YEL = string.char(27) .."[33m"
    local ESC_WHT = string.char(27) .."[37m"

    if (1 == #seqArray) then
        versionIndex = 1
    elseif (1 ~= #seqArray) then
        repeat
            if (boolContinue == false) then
                if (false == (gma.gui.confirm("ERROR" , "Invalid Version Number! \n Only use a number inbetween the amount of versions available!"))) then
                    gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Terminated:" ..option .." Operand not used")
                    gma.echo(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Terminated:" ..option .." Operand not used")
                    return -13
                end
            end

            versionIndex = gma.textinput("Which Version?" , "")
            boolContinue = true

            if (versionIndex == nil) then
                gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Terminated. Song not searched or imported.")
                gma.echo(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Terminated. Song not searched or imported.")
                return -13
            elseif (versionIndex == "") then
                boolContinue = false
            elseif (nil == string.match(versionIndex , "%d")) then
                boolContinue = false
            elseif (tonumber(versionIndex) > #seqArray) and (tonumber(versionIndex) <= 0) then
                boolContinue = false
            end
        until boolContinue

        versionIndex = tonumber(versionIndex)
    end

    if (option == "Adder") then
        gma.user.setvar(makerVar , seqArray[versionIndex])
        gma.sleep(0.2)
        gma.cmd("Plugin " ..adderPlugin)
    elseif (option == "Maker") then
        gma.user.setvar(makerVar , seqArray[versionIndex])
        gma.sleep(0.2)
        gma.cmd("Plugin " ..makerPlugin)
    elseif (option == "Edit") then
        gma.cmd("Assign Sequence " ..seqArray[versionIndex] .." At Executor " ..gma.show.getvar('SELECTEDEXEC'))
    end
end
-- ==== END OF OPERMA ====================================================================

-- =======================================================================================
-- ==== END OF FUNCTIONS =================================================================
-- =======================================================================================




-- =======================================================================================
-- ==== MAIN: FINDER =====================================================================
-- =======================================================================================
local function FINDER()
    local sSeqCopy = localUser.song_seq
    local sMakerCopy = localUser.maker
    local sAdderCopy = localUser.adder
    local localPoolSize = localUser.pool_size
    local makerPlugin = localUser.pluginMAKER
    local adderPlugin = localUser.pluginADDER

	local makerVar = 'MAKER' -- User Variable used in grandMA2 software
							-- Keep as single string (no whitespace)


    local ESC_RED = string.char(27) .."[31m"
    local ESC_GRN = string.char(27) .."[32m"
    local ESC_YEL = string.char(27) .."[33m"
    local ESC_WHT = string.char(27) .."[37m"

    if(type(sSeqCopy) ~= "number") or (type(sMakerCopy) ~= "number") or (type(sAdderCopy) ~= "number") then
        gma.gui.msgbox("ERROR" , "FINDER Plugin was NOT setup!\nPlease read manual for more information on setting up plugin!")
        gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Error. FINDER is not setup.")
        gma.echo(ESC_WHT .."FINDER Plugin : " ..ESC_RED .."Plugin Error. FINDER is not setup.")
        return -13;
    end

	if(type(localPoolSize) ~= "number") then
		gma.gui.msgbox("ERROR" , "FINDER Plugin was NOT setup!\n\nPlease setup how many columns you want \nto use for your MAKER+ library!")
		gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		gma.echo(ESC_WHT .."FINDER Plugin : " ..ESC_RED .."Plugin Error. pool_size is not setup.")
		return -13;
	elseif(localPoolSize <= 1) then
		gma.gui.msgbox("ERROR" , "FINDER Plugin was NOT setup!\n\nPlease choose a number bigger but not including 1 for your pool size\n This is regarding how many columns you are using the basic window for your views!")
		gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		gma.echo(ESC_WHT .."FINDER Plugin : " ..ESC_RED .."Plugin Error. pool_size is too small of a number.")
		return -13;
	end

    if(type(makerPlugin) ~= "string") or (type(adderPlugin) ~= "string") then
        gma.gui.msgbox("ERROR" , "FINDER Plugin was NOT setup!\nPlease identify what your labels are for MAKER plugin or ADDER plugin!")
        gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Error. Identify labels for MAKER/ADDER plugins in SETUP Plugin.")
        gma.echo(ESC_WHT .."FINDER Plugin : " ..ESC_RED .."Plugin Error. Identify labels for MAKER/ADDER plugins in SETUP Plugin.")
        return -13;
    end

	if makerPlugin:match("%s") or adderPlugin:match("%s") then
		gma.gui.msgbox("ERROR" , "FINDER Plugin was NOT correctly setup!\nNo whitespace in label for MAKER/ADDER plugin!")
		gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Error. No whitespace in label for MAKER/ADDER plugin.")
		gma.echo(ESC_WHT .."FINDER Plugin : " ..ESC_RED .."Plugin Error. No whitespace in label for MAKER/ADDER plugin.")
		return -13;
	end

    -- ask user what song they are looking for
    local songName = gma.textinput("Search Song?" , "" )
      if (songName == nil) then
        -- User has cancelled; plugin will not continue
        gma.feedback(ESC_WHT .."FINDER : " ..ESC_RED .."Plugin Terminated. Song not created.")
        gma.echo(ESC_WHT .."FINDER Plugin : " ..ESC_RED .."Plugin Terminated. Song not created.")
        return -13
      end


    local bOperands
    local setOperands = nil

    bOperands = string.match(string.upper(songName) , "-A ")
    if (nil ~= bOperands) then
        setOperands = "Adder"
        songName = string.gsub(string.upper(songName) , "-A " , "" , 1)
    end

    bOperands = string.match(string.upper(songName) , "-M ")
    if (nil ~= bOperands) then
        setOperands = "Maker"
        songName = string.gsub(string.upper(songName) , "-M " , "" , 1)
    end

    bOperands = string.match(string.upper(songName) , "-E ")
    if (nil ~= bOperands) then
        setOperands = "Edit"
        songName = string.gsub(string.upper(songName) , "-E " , "" , 1)
    end


	gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-START-" ..ESC_RED .."========================")
    local seqString
    local seqArray
    seqString , seqArray = POOLMATCHER("Sequence" , sSeqCopy , string.gsub(songName , " " , "_") , localPoolSize)
    local makerString = POOLMATCHER("Macro" , sMakerCopy , songName , localPoolSize)
    local adderString = POOLMATCHER("Macro" , sAdderCopy , songName , localPoolSize)
    gma.echo(ESC_RED .."========================" ..ESC_WHT .."-INTENTIONAL-SYNTAX-ERROR-END-" ..ESC_RED .."==========================")


    local loopLen = 3
    -- flash the matching macros 3 times white
    -- reset color of macro to default color at the end
    if (seqString ~= nil and makerString ~= nil and adderString ~= nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Sequence " ..seqString .." /r=100 /g=100 /b=100")
            gma.cmd("Appearance Macro " ..makerString .." /r=100 /g=100 /b=100")
            gma.cmd("Appearance Macro " ..adderString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(setOperands , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Sequence " ..seqString .." /r")
            gma.cmd("Appearance Macro " ..makerString .." /r")
            gma.cmd("Appearance Macro " ..adderString .." /r")
            gma.sleep(0.15)
        end
    elseif (seqString == nil and makerString ~= nil and adderString ~= nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Macro " ..makerString .." /r=100 /g=100 /b=100")
            gma.cmd("Appearance Macro " ..adderString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(nil , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Macro " ..makerString .." /r")
            gma.cmd("Appearance Macro " ..adderString .." /r")
            gma.sleep(0.15)
        end
    elseif (seqString ~= nil and makerString ~= nil and adderString == nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Sequence " ..seqString .." /r=100 /g=100 /b=100")
            gma.cmd("Appearance Macro " ..makerString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(setOperands , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Sequence " ..seqString .." /r")
            gma.cmd("Appearance Macro " ..makerString .." /r")
            gma.sleep(0.15)
        end
    elseif (seqString ~= nil and makerString == nil and adderString ~= nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Sequence " ..seqString .." /r=100 /g=100 /b=100")
            gma.cmd("Appearance Macro " ..adderString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(setOperands , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Sequence " ..seqString .." /r")
            gma.cmd("Appearance Macro " ..adderString .." /r")
            gma.sleep(0.15)
        end
    elseif (seqString ~= nil and makerString == nil and adderString == nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Sequence " ..seqString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(setOperands , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Sequence " ..seqString .." /r")
            gma.sleep(0.15)
        end
    elseif (seqString == nil and makerString ~= nil and adderString == nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Macro " ..makerString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(nil , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Macro " ..makerString .." /r")
            gma.sleep(0.15)
        end
    elseif (seqString == nil and makerString == nil and adderString ~= nil) then
        for i = 1 , loopLen , 1 do
            gma.cmd("Appearance Macro " ..adderString .." /r=100 /g=100 /b=100")
            gma.sleep(0.5)
            if ((loopLen == i) and (nil ~= setOperands)) then OPERMA(nil , makerPlugin , adderPlugin , makerVar , seqArray) end
            gma.cmd("Appearance Macro " ..adderString .." /r")
            gma.sleep(0.15)
        end
    end
end
-- =======================================================================================
-- ==== END OF FINDER ====================================================================
-- =======================================================================================

return FINDER;
