local ClientCommands = {}



---Set back the correct time on the server
---@param playerObj IsoPlayer
---@param args table
function ClientCommands.SendIsTimeSetStatus(playerObj, args)
    local isTimeSet = FixedTimeHandler.GetIsTimeSet()
	--print("[VibeChecker] Received request from client for isTimeSet. Right now it's " .. tostring(isTimeSet))
	sendServerCommand(playerObj, VIBE_CHECKER_COMMON.MOD_ID, 'ReceiveIsTimeSetFromServer', {isTimeSet=isTimeSet})
end

---Send the time on the server to the client
---@param playerObj IsoPlayer
function ClientCommands.SendTimeToClient(playerObj, _)
    local time = FixedTimeHandler.GetRealTimeData()
	sendServerCommand(playerObj, VIBE_CHECKER_COMMON.MOD_ID, 'ReceiveTimeFromServer', {time=time})
end


---Set back the correct time on the server
function ClientCommands.StopFixedTime(_, _)
    FixedTimeHandler.StopFixedTime()
end

---Set the fixed time on the handler on the server
---@param args table fixedTime=number
function ClientCommands.SetFixedTime(_, args)
    local fixedTime = args.fixedTime
    FixedTimeHandler.SetupFixedTime(fixedTime)
end

--------------------------------

local function OnClientCommand(module, command, playerObj, args)
	if module ~= VIBE_CHECKER_COMMON.MOD_ID then return end
	--print("[VibeChecker] Received command: " .. command)
	if ClientCommands[command] then
		ClientCommands[command](playerObj, args)
	end
end
Events.OnClientCommand.Add(OnClientCommand)
