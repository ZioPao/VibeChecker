local og_ISWorldObjectContextMenu_onSleepWalkToComplete = ISWorldObjectContextMenu.onSleepWalkToComplete

---@param playerNum number
---@param bed any
function ISWorldObjectContextMenu.onSleepWalkToComplete(playerNum, bed)
    FixedTimeHandler.SetTimeBeforeSleep(tonumber(FixedTimeHandler.time))
    FixedTimeHandler.StopFixedTime(true)     -- Stop temporarily

    og_ISWorldObjectContextMenu_onSleepWalkToComplete(playerNum, bed)
end
