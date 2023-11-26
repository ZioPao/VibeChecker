require("VibeChecker_UI")

-- TODO Normal players in MP should be able to ask the server the "real time" from a chat command
-- TODO Sandbox Option for SP to fix the time and preventing people from opening the UI
-- TODO Way to import\export presets for the Climate Control

local ServerCommands = {}

---Receive the status of the mod from the server
---@param args {isTimeSet : boolean}
function ServerCommands.ReceiveIsTimeSetFromServer(args)
    local isTimeSet = args.isTimeSet
    VibeCheckerUI.isTimeSet = isTimeSet
    --print("[VibeChecker] Received isTimeSet from the server " .. tostring(isTimeSet))
end

---Receive time from the server
---@param args {time : number}
function ServerCommands.ReceiveTimeFromServer(args)
    local time = args.time
    VibeCheckerUI.SetRealTimeFromServer(time)
end

---@param args {hasPermission : boolean}
function ServerCommands.ReceivePermission(args)
    local hasPermission = args.hasPermission

    if hasPermission then VibeCheckerUI.OnOpenPanel() else getPlayer():Say("Someone else is using the menu...") end

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
    local os_time = os.time
    local eTime = 0

    ---We need to delay it for a bit since this piece of shit won't launch at startup
    local function HandleDelayedAsk()
        local cTime = os_time()
        if cTime > eTime then
            sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "SendIsTimeSetStatus", {})
            Events.OnTick.Remove(HandleDelayedAsk)
        end
    end

    ---At startup, the client is gonna ask the server if isTimeSet is on or not
    local function AskIsTimeSetFromServer()
        --print("[VibeChecker] Should ask thing to server")

        eTime = 5 + os_time()
        Events.OnTick.Add(HandleDelayedAsk)
    end

    Events.OnCreatePlayer.Add(AskIsTimeSetFromServer)
end
