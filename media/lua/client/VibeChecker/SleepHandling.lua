
-- Skip this part if we're in a MP environment
if isClient() then return end
local FixedTimeHandler = require("VibeChecker/Handler")


local os_time = os.time
---@class Delay
---@field eTime number
---@field funcToRun function
local Delay = {}

---@param funcToRun function
---@param args table
---@param delay number
function Delay.RunAfter(funcToRun, args, delay)
    Delay.eTime = os_time() + delay
    Delay.funcToRun = funcToRun
    Delay.args = args
    Events.OnTick.Add(Delay.Loop)
end

function Delay.Loop()
    local cTime = os_time()
    if cTime > Delay.eTime then
        ---@diagnostic disable-next-line: deprecated
        Delay.funcToRun(unpack(Delay.args))
        Events.OnTick.Remove(Delay.Loop)
    end
end






local og_ISWorldObjectContextMenu_onSleepWalkToComplete = ISWorldObjectContextMenu.onSleepWalkToComplete

---@param playerNum number
---@param bed any
---@diagnostic disable-next-line: duplicate-set-field
function ISWorldObjectContextMenu.onSleepWalkToComplete(playerNum, bed)
    print("Stopping FixedTimeHandler, player is going to sleep")

    if FixedTimeHandler.isTimeSet then
        FixedTimeHandler.SetTimeBeforeSleep(tonumber(FixedTimeHandler.time))
        FixedTimeHandler.StopFixedTime(true)     -- Stop temporarily
        -- Wait 1 sec or so to be sure that the time has been synced. Bit of a shitty way to handle it, but I don't have other ideas for now
        Delay.RunAfter(og_ISWorldObjectContextMenu_onSleepWalkToComplete, {playerNum, bed}, 1)
    else
        og_ISWorldObjectContextMenu_onSleepWalkToComplete(playerNum, bed)
    end

end
