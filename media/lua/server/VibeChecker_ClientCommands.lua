local ClientCommands = {}

---Set back the correct time on the server
---@param playerObj IsoPlayer
---@param args table
function ClientCommands.StopFixedTime(playerObj, args)
    FixedTimeHandler.StopFixedTime()
end

---Set the fixed time on the handler on the server
---@param playerObj IsoPlayer
---@param args table fixedTime=number
function ClientCommands.SetFixedTime(playerObj, args)
    local fixedTime = args.fixedTime
    FixedTimeHandler.SetupFixedTime(fixedTime)
end

--------------------------------

local function OnClientCommand(module, command, playerObj, args)
	if module ~= VIBE_CHECKER_COMMON.MOD_ID then return end
	if ClientCommands[command] then
		ClientCommands[command](playerObj, args)
		ModData.add(VIBE_CHECKER_COMMON.MOD_ID, ClientCommands)
	end
end
Events.OnClientCommand.Add(OnClientCommand)
