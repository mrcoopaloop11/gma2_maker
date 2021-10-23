-- =======================================================================================
-- Plugin: STARTUP.lua
-- Programmer: Cooper Santillan
-- Last Modified: October 23, 2021 12:12am
-- =======================================================================================
-- Description: This will add all tasks as macros and cues from your service content.
-- =======================================================================================


local function listTasks()
	local temp = {}
	local c = 1
	for k in pairs(maker.task) do
		temp[c] = k
		c = c + 1
	end
	return temp
end

local function removeTasks(tasks, blacklist)
	local c = 1
	local flag = true
	local temp = {}
	for a,v in pairs(tasks) do
		for b,f in pairs(blacklist) do
			if (v:match(f)) then
				flag = false
			end
		end
		if(flag) then
			temp[c] = v
			c = c + 1
		end
		flag = true
	end
	return temp
end

local function listCues(serv_content)
	local seqHandle = G_OBJ.handle("Sequence \"" ..serv_content .."\"")
	if not(G_OBJ.verify(seqHandle)) then return nil end --return if can't find
	local seqAmount = G_OBJ.amount(seqHandle) - 1
	local childHandle
	local temp = {}

	for i=1, seqAmount do
		childHandle = G_OBJ.child(seqHandle, i)
		temp[i] = G_OBJ.label(childHandle)
	end

	return temp
end


local function userPrompt(prompt, caller)
	local userReq, boolContinue
	repeat
		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Macro Start! \n Make sure to only put numbers"))) then
				maker.util.print(ESC_RED .."Plugin Terminated. Startup macros not created.",
								caller)
				return nil;
			end
		end
		
		userReq = gma.textinput(prompt, "")
		boolContinue = true
		
		if (userReq == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. Startup macros not created.",
							caller)
			return nil
		elseif (userReq == "") then
			boolContinue = false
		elseif (tonumber(userReq) == nil) then
			boolContinue = false
		end
	until boolContinue

	return userReq
end

local function createLayout(user, caller)
	local blacklist = {"maker", "adder", "altMaker", "altAdder", "archive"}
	local tasks = removeTasks(listTasks(), blacklist)
	local cues = listCues("Service Content")
	local pool_size = user.pool_size
	local spaces = pool_size

	local start = userPrompt("Starting Macro:", caller)
	start = start - (start % pool_size) -- bring this back to correct pool_size position

	local totalTasks = #tasks
	local layers = 2 -- eventually support for multi layers (now limited to two layers)
	local layeredTasks = math.ceil(totalTasks / layers)

	if(math.ceil(spaces / layers) < layeredTasks) then return nil end -- EXIT; DON'T MAKE ANYTHING

	for i=1, totalTasks do
		number = start - layeredTasks + math.ceil(i/2) - 1
		if((i % layers) ~= 0) then
			number = number + pool_size
		else 
			number = number + (pool_size * 2)
		end
		maker.create.plugin(math.floor(number), nil, tasks[i], user.self)
	end

	spaces = spaces - layeredTasks - 1
	if (spaces <= 0) then return nil end -- NOT ENOUGH ROOM FOR CUES; EXIT

	if( #cues < spaces) then -- there is going to be empty spaces (cues don't fill rest)
		spaces = #cues
	end

	-- Archive plugin (make a new sequence!)
	maker.create.plugin(math.floor(start + 1), nil, "archive", user.self)
	maker.create.plugin(math.floor(start + 1 + pool_size), "Event", "archive", user.self)

	for i=2, spaces do
		number = start + i
		maker.create.plugin(math.floor(number), cues[i], "altMaker", user.self)
		maker.create.plugin(math.floor(number + pool_size), cues[i], "altAdder", user.self)
	end

end

local function startup()
	local caller = "startup"
	local userReq
	local boolContinue = true
	repeat
		-- inform user that they are not able to use punctuation for their song name
		if (boolContinue == false) then
			if (false == (gma.gui.confirm("ERROR" , "Invalid Username! \n Case-sensitivity matters!"))) then
				maker.util.print(ESC_RED .."Plugin Terminated. Startup macros not created.",
				caller)
				return nil;
			end
		end
		
		userReq = gma.textinput("Which user is this for?", "")
		boolContinue = true
		for k,v in pairs(user) do
			user[k].self = k
			if(userReq == k) then
				return createLayout(user[k], caller)
			end
		end
		
		if (userReq == nil) then
			maker.util.print(ESC_RED .."Plugin Terminated. Startup macros not created.",
							caller)
			return nil
		elseif (userReq == "") then
			boolContinue = false
		elseif (tonumber(userReq) == nil) then
			boolContinue = false
		end
	until boolContinue

end

return startup
