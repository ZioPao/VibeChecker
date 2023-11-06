local ClientCommands = {}



---Set back the correct time on the server
---@param playerObj IsoPlayer
function ClientCommands.SendIsTimeSetStatus(playerObj, _)
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
---@param playerObj IsoPlayer
---@param args {fixedTime : number}
function ClientCommands.SetFixedTime(playerObj, args)
    local fixedTime = args.fixedTime
    FixedTimeHandler.SetupFixedTime(fixedTime)

end


function ClientCommands.RequestAccess(playerObj, _)
	local hasPermission = FixedTimeHandler.assignedUser == nil

	if not hasPermission then
		local foundPlayer = false
		local onlinePlayers = getOnlinePlayers()

		for i=0, onlinePlayers:size() - 1 do
			local pl = onlinePlayers:get(i)
			if pl == FixedTimeHandler.assignedUser then
				foundPlayer = true
			end
		end

		if foundPlayer == false then
			hasPermission = true
		end
	end



	if hasPermission then
		print("Assigning player: " .. tostring(playerObj))
		FixedTimeHandler.AssignUser(playerObj)
	end
	sendServerCommand(playerObj, VIBE_CHECKER_COMMON.MOD_ID, "ReceivePermission", {hasPermission = hasPermission})
end

function ClientCommands.ForfeitAccess(playerObj, _)
	if FixedTimeHandler.assignedUser == playerObj then
		print("Unassigned player " .. tostring(playerObj))
		FixedTimeHandler.assignedUser = nil
	end
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
