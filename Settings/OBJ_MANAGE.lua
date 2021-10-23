-- =======================================================================================
-- Plugin: OBJ_MANAGE.lua
-- Programmer: Cooper Santillan
-- Last Modified: October 23, 2021 10:55am
-- =======================================================================================
-- Description: All functions used to maintain the Maker+ plugin suite.
-- =======================================================================================




















-- =======================================================================================
-- ========================================================================== PLUGIN =====
-- ==== maker.create.plugin ==============================================================
-- Description:
--
-- Inputs:
--		number		-- what macro number do you want to place this in
--		name		-- label name for the macro
--		task		-- what plugin to use
--		userName	-- what user is using this
-- =======================================================================================
function maker.create.plugin(number, name, task, userName)
	local makerVar = "MAKER"

	local title
	if(name == nil) then
		title = task
	else
		title = name
	end

	--gma.cmd("BlindEdit On")
	gma.cmd("Store Macro " ..number)
	gma.cmd("Store Macro 1." ..number ..".1 thru Macro 1." ..number ..".3")
	gma.cmd("Label Macro " ..number .." \"" ..maker.util.underVer(title, "Macro") .."\"")
	gma.cmd("Assign Macro 1." ..number ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..maker.util.pack({userName, task, maker.util.underVer(name, "Sequence")) .."\""})
	--gma.cmd("Assign Macro 1." ..number ..".2 /wait=0.1")
	gma.cmd("Assign Macro 1." ..number ..".3 /cmd=\"Plugin CALLER\"")
	--gma.cmd("BlindEdit Off")
end
-- ==== END OF maker.create.plugin =======================================================

-- ==== maker.edit.plugin ================================================================
-- Description:
--
-- Inputs:
--		number		-- what macro number do you want to place this in
--		name		-- label name for the macro
--		plugin		-- what plugin to use
-- =======================================================================================
function maker.edit.plugin(number, name, plugin, userName)
	local makerVar = "MAKER"

	gma.cmd("Label Macro " ..number .." \"" ..maker.util.underVer(name, "Macro") .."\"")
	gma.cmd("Assign Macro 1." ..number ..".1 /cmd=\"SetUserVar $" ..makerVar .." = " ..maker.util.pack({userName, plugin, maker.util.underVer(name, "Sequence"), nil) .."\""})
	gma.cmd("Assign Macro 1." ..number ..".2 /wait=0.1")
	gma.cmd("Assign Macro 1." ..number ..".3 /cmd=\"Plugin CALLER\"")
end
-- ==== END OF maker.edit.plugin =========================================================

-- ==== maker.delete.plugin ==============================================================
-- Description:
--
-- Inputs:
--		number		-- what macro number do you want to place this in
-- =======================================================================================
function maker.delete.plugin(number)
	gma.cmd("Delete Macro " ..number .." /nc")
end
-- ==== END OF maker.delete.plugin =======================================================

-- ==== maker.copy.plugin ================================================================
-- Description:
--
-- Inputs:
--		source			-- which one to copy
--		destination		-- new macro to create
-- =======================================================================================
function maker.copy.plugin(source, destination)
	gma.cmd("Copy Macro " ..source .." At " ..destination .." /nc")
end
-- ==== END OF maker.copy.plugin =========================================================

-- ==== maker.move.plugin ================================================================
-- Description:
--
-- Inputs:
--		source			-- macro to move
--		destination		-- where to make macro land
-- =======================================================================================
function maker.move.plugin(source, destination)
	gma.cmd("Move Macro " ..source .." At " ..destination)
end
-- ==== END OF maker.move.plugin =========================================================
-- =======================================================================================




-- =======================================================================================
-- ======================================================================== SEQUENCE =====
-- ==== maker.create.sequence ============================================================
-- Description:
--
-- Inputs:
--		number		-- what sequence number do you want to place this in
--		name		-- label name for the sequence
--		group		-- what group to use
-- =======================================================================================
function maker.create.sequence(number, name, group)
	--gma.cmd("BlindEdit On")
	maker.util.group(group)
	gma.cmd("Store Sequence " ..number .." Cue 1")
	gma.cmd("ClearAll")
	--gma.sleep(0.1)
	gma.cmd("Store Sequence " ..number .." Cue 2 /o")
	gma.cmd("Label Sequence " ..number .." \"" ..maker.util.underVer(name, "Sequence") .."\"")
	gma.cmd("Label Sequence " ..number .." Cue 1 \"S - " ..maker.util.underVer(name, "Macro"):gsub(" V%d+" , "") .."\"")
	gma.cmd("Appearance Sequence " ..number .." Cue 1 /r=50.2 /g=36.9 /b=0")
	gma.cmd("Assign Sequence " ..number .." Cue 1 /MIB=Early /Info=\"HL: %\"")
	--gma.cmd("BlindEdit Off")
end
-- ==== END OF maker.create.sequence =====================================================

-- ==== maker.edit.sequence ==============================================================
-- Description:
--
-- Inputs:
--		number		-- what sequence number do you want to place this in
--		name		-- label name for the sequence
-- =======================================================================================
function maker.edit.sequence(number, name)
	gma.cmd("Label Sequence " ..number .." \"" ..maker.util.underVer(name, "Sequence") .."\"")
	gma.cmd("Label Sequence " ..number .." Cue 1 \"S - " ..string.gsub(maker.util.underVer(name, "Macro"), " V%d+" , ""))
end
-- ==== END OF maker.edit.sequence =======================================================

-- ==== maker.delete.sequence ============================================================
-- Description:
--
-- Inputs:
--		number		-- what sequence number do you want to place this in
-- =======================================================================================
function maker.delete.sequence(number)
	gma.cmd("Delete Sequence " ..number .." /nc")
end
-- ==== END OF maker.delete.sequence =====================================================

-- ==== maker.copy.sequence ==============================================================
-- Description:
--
-- Inputs:
--		source			-- which one to copy
--		destination		-- new sequence to create
-- =======================================================================================
function maker.copy.sequence(source, destination)
	gma.cmd("Copy Sequence " ..source .." At " ..destination .." /nc")
end
-- ==== END OF maker.copy.sequence =======================================================

-- ==== maker.move.sequence ==============================================================
-- Description:
--
-- Inputs:
--		source			-- sequence to move
--		destination		-- where to make sequence land
-- =======================================================================================
function maker.move.sequence(source, destination)
	gma.cmd("Move Sequence " ..source .." At " ..destination)
end
-- ==== END OF maker.move.sequence =======================================================
-- =======================================================================================





-- =======================================================================================
-- ========================================================================== EFFECT =====
-- ==== maker.create.effect ==============================================================
-- Description:
--
-- Inputs:
--		number		-- what effect number do you want to place this in
--		name		-- label name for the effect
-- =======================================================================================
function maker.create.effect(number, name)
	--gma.cmd("BlindEdit On")
	gma.cmd("ClearAll")
	gma.cmd("Store Effect " ..number .." /o")
	gma.cmd("Label Effect " ..number .." \"" ..maker.util.underVer(name, "Macro") .."\"")
	--gma.cmd("BlindEdit Off")
end
-- ==== END OF maker.create.effect =======================================================

-- ==== maker.edit.effect ================================================================
-- Description:
--
-- Inputs:
--		number		-- what effect number do you want to place this in
--		name		-- label name for the effect
-- =======================================================================================
function maker.edit.effect(number, name)
	gma.cmd("Label Effect " ..number .." \"" ..name .."\"")
end
-- ==== END OF maker.edit.effect =========================================================

-- ==== maker.delete.effect ==============================================================
-- Description:
--
-- Inputs:
--		number		-- what effect number do you want to place this in
-- =======================================================================================
function maker.delete.effect(number)
	gma.cmd("Delete Effect " ..number .." /nc")
end
-- ==== END OF maker.delete.effect =======================================================

-- ==== maker.copy.effect ================================================================
-- Description:
--
-- Inputs:
--		source			-- which one to copy
--		destination		-- new effect to create
-- =======================================================================================
function maker.copy.effect(source, destination)
	gma.cmd("Copy Effect " ..source .." At " ..destination .." /nc")
end
-- ==== END OF maker.copy.effect =========================================================

-- ==== maker.move.effect ================================================================
-- Description:
--
-- Inputs:
--		source			-- effect to move
--		destination		-- where to make effect land
-- =======================================================================================
function maker.move.effect(source, destination, poolSize)
	gma.cmd("Move Effect " ..source .." Thru " ..(source + (poolSize - 2)) .." At " ..destination)
end
-- ==== END OF maker.move.effect =========================================================
-- =======================================================================================





-- =======================================================================================
-- ======================================================================== TIMECODE =====
-- ==== maker.create.timecode ============================================================
-- Description:
--
-- Inputs:
--		number		-- what timecode number do you want to place this in
--		name		-- label name for the timecode
-- =======================================================================================
function maker.create.timecode(number, name)
	--gma.cmd("BlindEdit On")
	gma.cmd("Store Timecode " ..number)
	gma.cmd("Label Timecode " ..number .." \"" ..maker.util.underVer(name, "Macro") .."\"")
	--gma.cmd("BlindEdit Off")
end
-- ==== END OF maker.create.timecode =====================================================

-- ==== maker.edit.timecode ==============================================================
-- Description:
--
-- Inputs:
--		number		-- what timecode number do you want to place this in
--		name		-- label name for the timecode
-- =======================================================================================
function maker.edit.timecode(number, name)
	gma.cmd("Label Timecode " ..number .." \"" ..name .."\"")
end
-- ==== END OF maker.edit.timecode =======================================================

-- ==== maker.delete.timecode ============================================================
-- Description:
--
-- Inputs:
--		number		-- what timecode number do you want to place this in
-- =======================================================================================
function maker.delete.timecode(number)
	gma.cmd("Delete Timecode " ..number .." /nc")
end
-- ==== END OF maker.delete.timecode =====================================================

-- ==== maker.copy.timecode ==============================================================
-- Description:
--
-- Inputs:
--		source			-- which one to copy
--		destination		-- new timecode to create
-- =======================================================================================
function maker.copy.timecode(source, destination)
	gma.cmd("Copy Timecode " ..source .." At " ..destination .." /nc")
end
-- ==== END OF maker.copy.timecode =======================================================

-- ==== maker.move.timecode ==============================================================
-- Description:
--
-- Inputs:
--		source			-- timecode to move
--		destination		-- where to make timecode land
-- =======================================================================================
function maker.move.timecode(source, destination)
	gma.cmd("Move Timecode " ..source .." At " ..destination)
end
-- ==== END OF maker.copy.timecode =======================================================
-- =======================================================================================





-- =======================================================================================
-- =======================================================================================
-- =======================================================================================
-- =======================================================================================
-- =======================================================================================





-- ==== maker.manage =====================================================================
-- Description:
--
-- Inputs:
--		option		-- Action wanted from SONGS or ADDONS
--		user		-- Table of information for SONGS and ADDONS
--		number		-- Choose workspace of either SONGS or ADDONS
--		arg1		-- argument 1
--		arg2		-- argument 2
--
-- Output: {...} or false if option/addon could not be found
-- =======================================================================================
function maker.manage(option, user, number, arg1, arg2)
	-- ===== MAKER =======================================================================
	if     ("MAKER" == string.upper(user.name[number])) then
		if(option:upper() == "INC") then
			local compensate = 0
			if (0 == math.fmod(arg1 + arg2 , user.pool_size)) and (0 < arg1) then
				if(arg2 == 0) then arg2 = 1 end
				if(arg2 >  0) then compensate = 1
				elseif(arg2 <  0) then compensate = -1 end
			end
			if(arg2 == 0) then arg2 = 1 end
			return arg1 + arg2 + compensate;
		elseif(option:upper() == "CURRENT") then
			if (0 == math.fmod(arg1, user.pool_size)) then return arg1 + 1
			else return arg1 end
		elseif(option:upper() == "CREATE") then maker.create.plugin(arg2, arg1, user.name[number], user.self)
		elseif(option:upper() == "EDIT"  ) then maker.edit.plugin(arg2, arg1, user.name[number], user.self)
		elseif(option:upper() == "DELETE") then maker.delete.plugin(arg1)
		elseif(option:upper() == "COPY"  ) then maker.copy.plugin(arg1, arg2)
		elseif(option:upper() == "MOVE"  ) then maker.move.plugin(arg1, arg2)
		elseif(option:upper() == "POOL"  ) then return "Macro", "Plugin"
		else return false end
	-- ===== ADDER =======================================================================
	elseif ("ADDER" == string.upper(user.name[number])) then
		if(option:upper() == "INC") then
			local compensate = 0
			if (0 == math.fmod(arg1 + arg2 , user.pool_size)) and (0 < arg1) then
				if(arg2 == 0) then arg2 = 1 end
				if(arg2 >  0) then compensate = 1
				elseif(arg2 <  0) then compensate = -1 end
			end
			if(arg2 == 0) then arg2 = 1 end
			return arg1 + arg2 + compensate;
		elseif(option:upper() == "CURRENT") then
			if (0 == math.fmod(arg1, user.pool_size)) then return arg1 + 1
			else return arg1 end
		elseif(option:upper() == "CREATE") then maker.create.plugin(arg2, arg1, user.name[number], user.self)
		elseif(option:upper() == "EDIT"  ) then maker.edit.plugin(arg2, arg1, user.name[number], user.self)
		elseif(option:upper() == "DELETE") then maker.delete.plugin(arg1)
		elseif(option:upper() == "COPY"  ) then maker.copy.plugin(arg1, arg2)
		elseif(option:upper() == "MOVE"  ) then maker.move.plugin(arg1, arg2)
		elseif(option:upper() == "POOL"  ) then return "Macro", "Plugin"
		else return false end
	-- ===== SONGS =======================================================================
	elseif ("SONGS" == string.upper(user.name[number])) then
		if(option:upper() == "INC") then
			local compensate = 0
			if (0 == math.fmod(arg1 + arg2 , user.pool_size)) and (0 < arg1) then
				if(arg2 == 0) then arg2 = 1 end
				if(arg2 >  0) then compensate = 1
				elseif(arg2 <  0) then compensate = -1 end
			end
			if(arg2 == 0) then arg2 = 1 end
			return arg1 + arg2 + compensate;
		elseif(option:upper() == "CURRENT") then
			if (0 == math.fmod(arg1, user.pool_size)) then return arg1 + 1
			else return arg1 end
		elseif(option:upper() == "CREATE") then maker.create.sequence(arg2, arg1, user.group)
		elseif(option:upper() == "EDIT"  ) then maker.edit.sequence(arg2, arg1)
		elseif(option:upper() == "DELETE") then maker.delete.sequence(arg1)
		elseif(option:upper() == "COPY"  ) then maker.copy.sequence(arg1, arg2)
		elseif(option:upper() == "MOVE"  ) then maker.move.sequence(arg1, arg2)
		elseif(option:upper() == "POOL"  ) then return "Sequence", "Sequence"
		else return false end
	-- ===== EFFECT ======================================================================
	elseif ("EFFECT" == string.upper(user.name[number])) then
		if(option:upper() == "INC") then
			local compensate = 1
			if (arg1 == 0) then compensate = 0 end
			if(arg2 == 0) then arg2 = 1 end
			return (((math.floor(arg1/user.pool_size)) * user.pool_size) + (user.pool_size * arg2)) + compensate
		elseif(option:upper() == "CURRENT") then
			return (((math.floor(arg1/user.pool_size)) * user.pool_size)) + 1
		elseif(option:upper() == "CREATE") then maker.create.effect(arg2, arg1)
		elseif(option:upper() == "EDIT"  ) then maker.edit.effect(arg2, arg1)
		elseif(option:upper() == "DELETE") then maker.delete.effect(arg1)
		elseif(option:upper() == "COPY"  ) then maker.copy.effect(arg1, arg2)
		elseif(option:upper() == "MOVE"  ) then maker.move.effect(arg1, arg2, user.pool_size)
		elseif(option:upper() == "POOL"  ) then return "Effect", nil
		else return false end
	-- ===== TIMECODE ====================================================================
	elseif ("TIMECODE" == string.upper(user.name[number])) then
		if(option:upper() == "INC") then
			if(arg2 == 0) then arg2 = 1 end
			return arg1 + arg2
		elseif(option:upper() == "CURRENT") then
			return arg1
		elseif(option:upper() == "CREATE") then maker.create.timecode(arg2, arg1)
		elseif(option:upper() == "EDIT"  ) then maker.edit.timecode(arg2, arg1)
		elseif(option:upper() == "DELETE") then maker.delete.timecode(arg1)
		elseif(option:upper() == "COPY"  ) then maker.copy.timecode(arg1, arg2)
		elseif(option:upper() == "MOVE"  ) then maker.move.timecode(arg1, arg2)
		elseif(option:upper() == "POOL"  ) then return "Timecode", nil
		else return false end
	else
		return false;
	end
	return true;
end
-- ==== END OF maker.manage ==============================================================
