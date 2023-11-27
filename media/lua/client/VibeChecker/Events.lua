
if isServer() or isClient() then return end
local Common = require("VibeChecker/Common")
local FixedTimeHandler = require("VibeChecker/Handler")

-- TODO Handle ONLY SP, we need to check MP too

local function HandleSaves()
    Common.debugPrint("Saving")
    local timeBeforeSleep = FixedTimeHandler.GetTimeBeforeSleep()
    if getPlayer():isAsleep() and timeBeforeSleep then
        Common.debugPrint("Not running on save since we're sleeping")
    elseif timeBeforeSleep then
        -- Second time, after player is done sleeping
        Common.debugPrint("Player has woken up, resetting fixedTimeHandler")
        FixedTimeHandler.SetupFixedTime(timeBeforeSleep)
        FixedTimeHandler.SetTimeBeforeSleep(nil)
    else
        -- Player is stopping playing
        Common.debugPrint("Stopping time")
        FixedTimeHandler.StopFixedTime()
    end
end
Events.OnSave.Add(HandleSaves)