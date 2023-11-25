
--* SP *--

if not isServer() and not isClient() then

    -- Init FixedTimeHandler
    Events.OnGameStart.Add(FixedTimeHandler.Init)


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

    local function OnFillContextMenu(player, context, worldObjects, test)
        if test then return true end
        local playerObj = getSpecificPlayer(player)
        local clickedPlayer
        for _, v in ipairs(worldObjects) do
          local movingObjects = v:getSquare():getMovingObjects()
          for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoPlayer") then
              clickedPlayer = obj
              break
            end
          end
        end
        if clickedPlayer and clickedPlayer == playerObj then
            context:addOption(getText("ContextMenu_VibeChecker_Open"), clickedPlayer, VibeCheckerUI.OnOpenPanel, false)
        end
    end

    -- For MP, we can access the menu ONLY from the admin panel
    Events.OnFillWorldObjectContextMenu.Add(OnFillContextMenu)
-- MP
elseif isServer() then
    --print("Running init on Server (MP)")
    Events.OnServerStarted.Add(FixedTimeHandler.Init)

    -- TODO Will this run when players are sleeping?
    Events.OnSave.Add(FixedTimeHandler.StopFixedTime)
end