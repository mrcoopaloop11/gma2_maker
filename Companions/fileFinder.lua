-- =======================================================================================
-- Plugin: fileFinder.lua
-- Programmer: Cooper Santillan
-- Last Modified: October 18, 2021 10:10am
-- =======================================================================================
-- Description: Find files in determined path (and ALL subfolders) in search for all
--              files with certain extension. Only works for onPC systems. 
-- =======================================================================================



















-- =======================================================================================
-- ==== MAIN: fileFinder =================================================================
-- =======================================================================================
-- https://stackoverflow.com/questions/1426954/split-string-in-lua
local function mysplit (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- https://stackoverflow.com/questions/1410862/concatenation-of-tables-in-lua
local function TableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

local function tableCat(t1, t2)
    if t1 == nil then
        return t2
    end

    for k,v in pairs(t2) do
        t1[k] = v
    end
	return t1
end

-- purpose: append the path to a batch of files in table
local function tableAppend(t1, descript)
    local t2 = {}
    for i=1, #t1 do
        t2[t1[i]] = descript
    end
    return t2
end


local function fileFinder(path, ext)
    local aFiles = {}
    local luas = io.popen("dir \"" ..path .."\\*." ..ext .."\" /b") --finds all files with this extension in folder
    if luas then
        aFiles = luas:read("*a")
        aFiles = mysplit(aFiles)

        if (aFiles ~= nil) then
            aFiles = tableAppend(aFiles, path)
        end

        local newDir = io.popen("dir \"" ..path .."\" /b /ad")  --finds all folders in the directory
        if newDir then
            local newDirRead = newDir:read("*a")
            if newDirRead ~= "" then
                local dirTable = mysplit(newDirRead)
                for i=1, #dirTable do
                    aFiles =  tableCat(aFiles, fileFinder(path .."\\"..dirTable[i], ext))
                end
            end
        end
    end
    return aFiles
end



local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
local callerNumber = select(2,...):match("%d+$") -- number of the plugin
local function foo()
    local pluginPath = gma.show.getvar("PLUGINPATH")
    local githubFolder = "gma2-maker"
    local f = fileFinder(pluginPath .."\\" ..githubFolder, "lua") -- returns a table of all lua files
	local c = callerNumber + 1

    -- gma2 doesn't want to use this command :/
	-- for k, v in pairs(f) do
	-- 	gma.cmd("Import \"" ..k .."\" At Plugin " ..c .." /nc /p=\"" ..v .."\"")
	-- 	c = c + 1
	-- end
    
end
 
 
return foo
-- =======================================================================================
-- ==== END OF fileFinder ================================================================
-- =======================================================================================