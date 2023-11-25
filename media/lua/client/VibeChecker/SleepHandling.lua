
local os_time = os.time
---@class Delay
---@field eTime number
---@field funcToRun function
local Delay = {}

---comment
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
        Delay.funcToRun(unpack(Delay.args))
        Events.OnTick.Remove(Delay.Loop)
    end
end






local og_ISWorldObjectContextMenu_onSleepWalkToComplete = ISWorldObjectContextMenu.onSleepWalkToComplete


-- TODO Loop until we're sure that stop fixed time is ok

---@param playerNum number
---@param bed any
function ISWorldObjectContextMenu.onSleepWalkToComplete(playerNum, bed)
    print("Stopping FixedTimeHandler, player is going to sleep")
    FixedTimeHandler.SetTimeBeforeSleep(tonumber(FixedTimeHandler.time))
    FixedTimeHandler.StopFixedTime(true)     -- Stop temporarily
    Delay.RunAfter(og_ISWorldObjectContextMenu_onSleepWalkToComplete, {playerNum, bed}, 1)
end
