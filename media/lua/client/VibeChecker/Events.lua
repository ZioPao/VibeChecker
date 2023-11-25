
if isServer() or isClient() then return end


-- TODO Handle ONLY SP, we need to check MP too


local function HandleSaves()
    print("Saving")
    local timeBeforeSleep = FixedTimeHandler.GetTimeBeforeSleep()
    if getPlayer():isAsleep() and timeBeforeSleep then
        print("Not running on save since we're sleeping")
    elseif timeBeforeSleep then
        -- Second time, after player is done sleeping
        print("Player has woken up, resetting fixedTimeHandler")
        FixedTimeHandler.SetupFixedTime(timeBeforeSleep)
        FixedTimeHandler.SetTimeBeforeSleep(nil)
    else
        -- Player is stopping playing
        print("Stopping time")
        FixedTimeHandler.StopFixedTime()
    end
end
Events.OnSave.Add(HandleSaves)