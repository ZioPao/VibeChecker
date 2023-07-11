-- Main idea: fixed time, but days should advance anyway to let stuff like the passing of time for seasons work.


---@class FixedTimeHandler
local FixedTimeHandler = {}


---Will setup everything related to GlobalModData to save the real time and whatever else we may need
function FixedTimeHandler.Init()
    -- TODO Init moddata
end


---Loop ran each in game minute. Will save the real time of the game anyway
function FixedTimeHandler.Loop()
    getGameTime():setTimeOfDay(FixedTimeHandler.time)

    -- TODO Update correct real time


    -- TODO Check if we need to advance by a day, and if so, do it
end

function FixedTimeHandler.SaveRealTime()
    -- TODO Use ModData for this
end

---Set the time, must be received from a client
---@param time number
function FixedTimeHandler.SetFixedTime(time)
    FixedTimeHandler.time = time

    FixedTimeHandler.SaveRealTime()
    Events.EveryOneMinute.Add(FixedTimeHandler.Loop)
end


function FixedTimeHandler.StopFixedTime()
    Events.EveryOneMinute.Remove(FixedTimeHandler.Loop)

    -- TODO Set back the correct time
end







-------------------------

local ClientCommands = {}

---Set the fixed time received from a client
---@param args table time=number
function ClientCommands.ReceiveFixedTime(args)
    local time = args.time
    FixedTimeHandler.SetFixedTime(time)
end


local OnClientCommand = function(module, command, playerObj, args)
    if module == VIBE_CHECKER_COMMON.MOD_ID and ClientCommands[command] then
        ClientCommands[command](playerObj, args)
    end
end

Events.OnClientCommand.Add(OnClientCommand)