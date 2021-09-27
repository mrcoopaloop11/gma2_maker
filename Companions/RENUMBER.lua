-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: RENUMBER.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 27, 2020 02:32pm
-- =======================================================================================
-- Description: Renumbers your current selected executors sequence cues into their index
--				value. Only works if there is a "Cue 1" in your sequence already.
-- =======================================================================================

-- Which user is this for? (Refer to SETUP Plugin)
	local localUser = main_campus










-- =======================================================================================
-- ==== MAIN: RENUMBER ===================================================================
-- =======================================================================================
local caller = select(2,...):gsub("%d+$", "") -- label of the plugin
local function RENUMBER()
	local user = localUser
	
	maker.util.renumber()
end
-- =======================================================================================
-- ==== END OF RENUMBER ==================================================================
-- =======================================================================================

return RENUMBER;
