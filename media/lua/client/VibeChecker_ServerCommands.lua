local ServerCommands = {}

---Receive the status of the mod from the server
---@param args table isTimeSet=boolean
function ServerCommands.ReceiveIsTimeSetFromServer(args)
    local isTimeSet = args.isTimeSet
    VibeCheckerUI.isTimeSet = isTimeSet

    print("Received isTimeSet from the server " .. tostring(isTimeSet))

end


--------------------------------

local function OnServerCommand(module, command, args)
	if module ~= VIBE_CHECKER_COMMON.MOD_ID then return end
	if ServerCommands[command] then
		ServerCommands[command](args)
	end
end
Events.OnServerCommand.Add(OnServerCommand)


---------------------------------

-- If we're in a mp environment, most of the mod logic is done on the server. This means we need to
-- ask the server if isTimeSet is on there too, so we can sync it on the client

if isClient() then
    ---At startup, the client is gonna ask the server if isTimeSet is on or not
    local function AskIsTimeSetFromServer()
        sendClientCommand(getPlayer(), VIBE_CHECKER_COMMON.MOD_ID, 'SendIsTimeSetStatus', {})
    end

    Events.OnConnected.Add(AskIsTimeSetFromServer)
end
