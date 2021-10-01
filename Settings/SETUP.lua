-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: SETUP.lua
-- Programmer: Cooper Santillan
-- Last Modified: September 30, 2021 11:15pm
-- =======================================================================================
-- Description: Manage all users for your Maker+ program. More info in manual.
--				Place this plugin before others in the pool!
--				You MUST run THIS plugin after any changes!
-- =======================================================================================

-- =======================================================================================
-- 										NAME OF USERS
-- =======================================================================================
	user = {}
	user["main_campus"] = {name={}, first={}, last={}}	-- 1
-- =======================================================================================












-- =======================================================================================
-- MAIN_CAMPUS user config settings
-- =======================================================================================
	-- In the sequence pool
	-- Where do you want to start creating your song library?
	user["main_campus"].name[1] = "SONGS" -- Plugin label/number to call
	user["main_campus"].first[1] = 257 -- Where to start putting that pool object

	-- ==== ADDONS =======================================================================
	user["main_campus"].name[2] = "maker" -- Plugin label/number to call
	user["main_campus"].first[2] = 257 -- Where to start putting that pool object

	user["main_campus"].name[3] = "adder" -- Plugin label/number to call (NO SPACES)
	user["main_campus"].first[3] = 1121 -- Where to start putting that pool object
	-- ===================================================================================

	-- Where is the sequence with your assets (Walk In , Video , Message , etc...)
	-- You may use the label name or sequence number
	user["main_campus"].serv_content = "Service Content"

	-- In regards for the basic window
	-- How many columns wide are your sequence and macro pools?
	user["main_campus"].pool_size = 16

	-- For your service maker [ARCHIVE Plugin]
	-- In the sequence pool
	-- Where do you want to start creating your service library for archive?
	user["main_campus"].archive_seq = 1121

	-- For your service maker [ARCHIVE Plugin]
	-- First cue to import when creating a new sequence for service
	-- You may use the label name or cue number
	user["main_campus"].first_cue = "Walk In"

	-- For your service maker [ARCHIVE Plugin]
	-- What weekday is your service typically on?
	-- Not case-sensitive! Must enter a weekday (ARCHIVE Plugin will not work without)
	user["main_campus"].weekday = "Sunday"

	-- Group of fixtures that you want to program per song
	-- Reserved words: "Normal" , "Assert" , "X-Assert" , "Release" , "Break" , "X-Break"
	-- You may use a label name or a number
	user["main_campus"].group = "All"

-- =======================================================================================









-- =======================================================================================
-- ==== DEBUGGER =========================================================================
-- =======================================================================================

-- ==== DELETE ALL VARS USED FOR MAKER+ ==================================================
	function deleteVars()
		gma.show.setvar("MAKER_USER" , nil)
		gma.user.setvar("MAKER_USER" , nil)
		gma.show.setvar("MAKER_TASK" , nil)
		gma.user.setvar("MAKER_TASK" , nil)
		gma.show.setvar("MAKER_SONG" , nil)
		gma.user.setvar("MAKER_SONG" , nil)
	end

-- ==== RELOAD ALL PLUGINS ===============================================================
	local function reloadPlugins() gma.cmd("ReloadPlugins /nc") end

-- ==== IMPORT FUNCTION TABLES ===========================================================
	maker = {}
	maker.create = {}
	maker.edit = {}
	maker.delete = {}
	maker.util = {}
	maker.test = {}
	maker.copy = {}
	maker.find = {ver={}}
	maker.move = {}
	maker.task = {}

-- =======================================================================================
	return deleteVars , reloadPlugins;
-- =======================================================================================
