local Common = require("VibeChecker/Common")
local FixedTimeHandler = require("VibeChecker/Handler")
-----------------

local ClientCommands = {}

---Set back the correct time on the server
---@param playerObj IsoPlayer
function ClientCommands.SendIsTimeSetStatus(playerObj)
    local isTimeSet = FixedTimeHandler.GetIsTimeSet()
	--print("[VibeChecker] Received request from client for isTimeSet. Right now it's " .. tostring(isTimeSet))
	sendServerCommand(playerObj, Common.MOD_ID, 'ReceiveIsTimeSetFromServer', {isTimeSet=isTimeSet})
end

---Send the time on the server to the client
---@param playerObj IsoPlayer
---@param args {showInChat : boolean}
function ClientCommands.SendTimeToClient(playerObj, args)
    local time = FixedTimeHandler.GetRealTimeData()
	sendServerCommand(playerObj, Common.MOD_ID, 'ReceiveTimeFromServer', {time=time, showInChat = args.showInChat})
end

---Set back the correct time on the server
function ClientCommands.StopFixedTime()
    FixedTimeHandler.StopFixedTime()
end

---Set the fixed time on the handler on the server
---@param args {fixedTime : number}
function ClientCommands.SetFixedTime(_, args)
    local fixedTime = args.fixedTime
    FixedTimeHandler.SetupFixedTime(fixedTime)

end


--* UI PERMISSION STUFF *--


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
		ClientCommands.SendIsTimeSetStatus(playerObj)
	end
	sendServerCommand(playerObj, Common.MOD_ID, "ReceivePermission", {hasPermission = hasPermission})
end

function ClientCommands.ForfeitAccess(playerObj, _)
	if FixedTimeHandler.assignedUser == playerObj then
		print("Unassigned player " .. tostring(playerObj))
		FixedTimeHandler.assignedUser = nil
	end
end


--------------------------------

local function OnClientCommand(module, command, playerObj, args)
	if module ~= Common.MOD_ID then return end
	--print("[VibeChecker] Received command: " .. command)
	if ClientCommands[command] then
		ClientCommands[command](playerObj, args)
	end
end
Events.OnClientCommand.Add(OnClientCommand)
