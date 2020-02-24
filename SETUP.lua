-- =======================================================================================
-- WARNING: I am not responsible for any content loss or crashes while using this plugin.
-- =======================================================================================
-- Plugin: SETUP.lua
-- Programmer: Cooper Santillan
-- Last Modified: December 07 2019 05:55pm
-- =======================================================================================
-- Description: Manage all users for your Maker+ program. More info in manual.
--				Place this plugin before others in the pool!
--				You MUST run THIS plugin after any changes!
-- =======================================================================================

-- =======================================================================================
-- 										NAME OF USERS
-- =======================================================================================
	main_campus = {}	-- 1
-- =======================================================================================












-- =======================================================================================
-- MAIN_CAMPUS user config settings
-- =======================================================================================
	-- For all config option, please DO NOT pick a number below and including 1[ONE]

	-- In the sequence pool
	-- Where do you want to start creating your song library?
	main_campus.song_seq = 257

	-- In the sequence pool
	-- Where do you want to start creating your service library for archive?
	main_campus.service_seq = 1121

	-- In the macro pool
	-- Where do you want to start creating your song library for MAKER?
	main_campus.maker = 257

	-- In the macro pool
	-- Where do you want to start creating your song library for MAKER?
	main_campus.adder = 1121

	-- In regards for the basic window
	-- How many columns wide are your sequence and macro pools?
	main_campus.pool_size = 16

	-- For your service maker [ARCHIVE Plugin]
	-- What weekday is your service typically on?
	-- Not case-sensitive! Must enter a weekday (ARCHIVE Plugin will not work without)
	main_campus.weekday = "Sunday"

	-- For your service maker [ARCHIVE Plugin]
	-- Where is the sequence with your assets (Walk In , Video , Message , etc...)
	-- You may use the label name or sequence number
	main_campus.serv_content = "Service Content"

	-- For your service maker [ARCHIVE Plugin]
	-- First cue to import when creating a new sequence for service
	-- You may use the label name or cue number
	main_campus.first_cue = "Walk In"

	-- Important for multiple user setup! Change if there is more than one user!
	-- What is the label/number of the MAKER plugin?
	-- NO SPACES IN LABEL!!!
	main_campus.pluginMAKER = "MAKER"

	-- Important for multiple user setup! Change if there is more than one user!
	-- What is the label/number of the ADDER plugin?
	-- NO SPACES IN LABEL!!!
	main_campus.pluginADDER = "ADDER"

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

-- =======================================================================================
	return deleteVars , reloadPlugins;
-- =======================================================================================
