-- Main idea: fixed time, but days should advance anyway to
-- let stuff like the passing of time for seasons work.

---@class FixedTimeHandler
FixedTimeHandler = {}
local data = {}

---Will setup everything related to GlobalModData to save the real time and whatever else we may need
function FixedTimeHandler.Init()
    FixedTimeHandler.gameTime = getGameTime()
    FixedTimeHandler.baseDelta = FixedTimeHandler.gameTime:getTimeDelta() -- At startup, so 1x
end

---Loop ran each in game minute. Will save the real time of the game anyway
function FixedTimeHandler.Loop()
    FixedTimeHandler.gameTime:setTimeOfDay(FixedTimeHandler.time)
    FixedTimeHandler.HandleRealTimeData()
end

-----------------
--* Setters and getters

---Set isTimeSet value
---@param isTimeSet boolean
function FixedTimeHandler.SetIsTimeSet(isTimeSet)
    FixedTimeHandler.isTimeSet = isTimeSet
end

---Get isTimeSet value
---@returns isTimeSet boolean
function FixedTimeHandler.GetIsTimeSet()
    return FixedTimeHandler.isTimeSet or false
end

---Get realTime value
---@returns number
function FixedTimeHandler.GetRealTimeData()
    return data.realTime
end

-----------------
--* Set stuff

---Set the real time from the game
function FixedTimeHandler.SetRealTime()

    data.realTime = FixedTimeHandler.gameTime:getTimeOfDay()

    data.realDay = FixedTimeHandler.gameTime:getDay()    -- Day is offset by one for some reason
    data.realMonth = FixedTimeHandler.gameTime:getMonth()
    data.realYear = FixedTimeHandler.gameTime:getYear()
end

---Handles in the loop the real time stuff, to set the correct days, etc.
function FixedTimeHandler.HandleRealTimeData()
    -- TODO Use ModData for this
    data.realTime = data.realTime + FixedTimeHandler.baseDelta
    --print(data.realTime)
    if (data.realTime - 24) > 0 then
        local months = VIBE_CHECKER_COMMON.GetNewMonthsTable()

        -- Check month
        --print("One day has passed, must be set here!")
        data.realDay = data.realDay + 1
        local isLeapYear = FixedTimeHandler.CheckLeapYear(data.realYear)

        -- February, needs adjustmenet because of leap years
        if isLeapYear and data.realMonth == 2 then
            months[2] = months[2] + 1
        end

        -- Check month
        if data.realDay > months[data.realMonth] then
            data.realDay = 1
            data.realMonth = data.realMonth + 1

            -- Check year
            if data.realMonth > 12 then
                data.realMonth = 1
                data.realYear = data.realYear + 1
            end
        end


        data.realTime = 0 -- Restart from 0

        FixedTimeHandler.gameTime:setDay(data.realDay)
        FixedTimeHandler.gameTime:setMonth(data.realMonth)
        FixedTimeHandler.gameTime:setYear(data.realYear)
    end
end

---Set back the correct time
function FixedTimeHandler.StopFixedTime()
    if data.realTime then
        Events.EveryOneMinute.Remove(FixedTimeHandler.Loop)
        FixedTimeHandler.gameTime:setTimeOfDay(data.realTime)
    end

    FixedTimeHandler.SetIsTimeSet(false)
    data = {} -- Clean it locally
end

--* Checks

---Check if the year is a leap year
---@param year number
---@return boolean
function FixedTimeHandler.CheckLeapYear(year)
    --local year = FixedTimeHandler.gameTime:getYear()
    if math.fmod(year / 4, 1) == 0 then
        --print("Remainder is 0, so...")
        if math.fmod(year / 100, 1) ~= 0 then
            --print("It's a leap year!")
            return true
        elseif math.fmod(year / 400, 1) == 0 then
            --print("It's a leap year!")
            return true
        end
    end

    return false
end

--*************************-
--* Remote setup

---Set the time, must be received from a client
---@param time number
function FixedTimeHandler.SetupFixedTime(time)
    FixedTimeHandler.time = time
    FixedTimeHandler.SetRealTime()
    FixedTimeHandler.SetIsTimeSet(true)
    Events.EveryOneMinute.Add(FixedTimeHandler.Loop)
end


--- Assign a user, so that other players can't set stuff on the menu
---@param player IsoPlayer
function FixedTimeHandler.AssignUser(player)
    FixedTimeHandler.assignedUser = player
end


-- SP
if not isServer() and not isClient() then
    --print("Running init on client (SP)")
    Events.OnGameStart.Add(FixedTimeHandler.Init)
    Events.OnSave.Add(function()
        if getPlayer():isAsleep() then
            print("Not running on save since we're sleeping")
        else
            print("RUNNING ON SAVE")
            FixedTimeHandler.StopFixedTime()
        end
    end)

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
            print("Found player")
            context:addOption("Open VibeChecker", clickedPlayer, VibeCheckerUI.OnOpenPanel, false)
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