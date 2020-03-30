-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: SETUP.lua
-- Programmer: Cooper Santillan
-- Last Modified: March 14, 2020 01:01pm
-- =======================================================================================
-- Description: Manage all users for your Maker+ program. More info in manual.
--				Place this plugin before others in the pool!
--				You MUST run THIS plugin after any changes!
-- =======================================================================================

-- =======================================================================================
-- 										NAME OF USERS
-- =======================================================================================
	main_campus = {name={}, first={}, last={}}	-- 1
-- =======================================================================================












-- =======================================================================================
-- MAIN_CAMPUS user config settings
-- =======================================================================================
	-- In the sequence pool
	-- Where do you want to start creating your song library?
	main_campus.name[1] = "SONGS" -- Plugin label/number to call
	main_campus.first[1] = 257 -- Where to start putting that pool object

	-- ==== ADDONS =======================================================================
	main_campus.name[2] = "MAKER" -- Plugin label/number to call
	main_campus.first[2] = 257 -- Where to start putting that pool object

	main_campus.name[3] = "ADDER" -- Plugin label/number to call (NO SPACES)
	main_campus.first[3] = 1121 -- Where to start putting that pool object
	-- ===================================================================================

	-- Where is the sequence with your assets (Walk In , Video , Message , etc...)
	-- You may use the label name or sequence number
	main_campus.serv_content = "Service Content"

	-- In regards for the basic window
	-- How many columns wide are your sequence and macro pools?
	main_campus.pool_size = 16

	-- For your service maker [ARCHIVE Plugin]
	-- In the sequence pool
	-- Where do you want to start creating your service library for archive?
	main_campus.archive_seq = 1121

	-- For your service maker [ARCHIVE Plugin]
	-- First cue to import when creating a new sequence for service
	-- You may use the label name or cue number
	main_campus.first_cue = "Walk In"

	-- For your service maker [ARCHIVE Plugin]
	-- What weekday is your service typically on?
	-- Not case-sensitive! Must enter a weekday (ARCHIVE Plugin will not work without)
	main_campus.weekday = "Sunday"

	-- Group of fixtures that you want to program per song
	-- Reserved words: "Normal" , "Assert" , "X-Assert" , "Release" , "Break" , "X-Break"
	-- You may use a label name or a number
	main_campus.group = "All"

-- =======================================================================================









-- =======================================================================================
-- ==== DEBUGGER =========================================================================
-- =======================================================================================

-- ==== DELETE ALL VARS USED FOR MAKER+ ==================================================
	local function deleteVars()
		gma.show.setvar("MAKER" , nil)
		gma.user.setvar("MAKER" , nil)
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

-- =======================================================================================
	return deleteVars , reloadPlugins;
-- =======================================================================================
