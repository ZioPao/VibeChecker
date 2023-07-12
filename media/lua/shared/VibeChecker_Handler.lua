-- Main idea: fixed time, but days should advance anyway to
-- let stuff like the passing of time for seasons work.
-- TODO Make it local
---@class FixedTimeHandler
FixedTimeHandler = {}
local data = {}


---Will setup everything related to GlobalModData to save the real time and whatever else we may need
function FixedTimeHandler.Init()
    FixedTimeHandler.gameTime = getGameTime()
    FixedTimeHandler.baseDelta = FixedTimeHandler.gameTime:getTimeDelta() -- At startup, so 1x
    -- TODO JUST FOR TEST
    --Events.EveryTenMinutes.Add(FixedTimeHandler.Loop)
end

---Loop ran each in game minute. Will save the real time of the game anyway
function FixedTimeHandler.Loop()
    FixedTimeHandler.gameTime:setTimeOfDay(FixedTimeHandler.time)

    print(FixedTimeHandler.gameTime:getTimeOfDay())
    FixedTimeHandler.HandleRealTimeData()


    -- TODO Update correct real time
    -- TODO Check if we need to advance by a day, and if so, do it
end

-----------------
--* Set stuff

---Set the real time from the game
function FixedTimeHandler.SetRealTime()
    data.realTime = FixedTimeHandler.gameTime:getTimeOfDay()
    data.realDay = FixedTimeHandler.gameTime:getDay()
    data.realMonth = FixedTimeHandler.gameTime:getMonth()
    data.realYear = FixedTimeHandler.gameTime:getYear()
end

---Handles in the loop the real time stuff, to set the correct days, etc.
function FixedTimeHandler.HandleRealTimeData()
    -- TODO Use ModData for this
    data.realTime = data.realTime + FixedTimeHandler.baseDelta
    print(data.realTime)
    if (data.realTime - 24) > 0 then

        -- TODO Check if we need to advance a year

        -- TODO Check if we need to advance a month and consider leap year (+1 to feb)



        print("One day has passed, must be set here!")
        data.realDay = data.realDay + 1
        data.realTime = 0 -- Restart from 0
        FixedTimeHandler.gameTime:setDay(data.realDay)
        -- TODO Handle months!
    end
end

---Set back the correct time
function FixedTimeHandler.StopFixedTime()
    if data.realTime then
        Events.EveryOneMinute.Remove(FixedTimeHandler.Loop)
        FixedTimeHandler.gameTime:setTimeOfDay(data.realTime)
    end

    data = {} -- Clean it locally
end

--* Checks

---Check if the year ia leap year
---@param year number
---@return boolean
function FixedTimeHandler.CheckLeapYear(year)
    --local year = FixedTimeHandler.gameTime:getYear()
    if math.fmod(year/4, 1) == 0 then
        print("Remainder is 0, so...")
        if math.fmod(year/100, 1) ~= 0 then
            print("It's a leap year!")
            return true
        elseif math.fmod(year/400, 1) == 0 then
            print("It's a leap year!")
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
    Events.EveryOneMinute.Add(FixedTimeHandler.Loop)
end

-- Will run on server in MP
if isServer() and not isClient() then
    Events.OnServerStarted.Add(FixedTimeHandler.Init)
else
    Events.OnGameStart.Add(FixedTimeHandler.Init)
end




-- TODO This works only on MP :(
--Events.OnDisconnect.Add(FixedTimeHandler.StopFixedTime)

-------------------------
--* Global Mod Data *--

local function OnInitGlobalModData()
    --print("Initializing global mod data")
    data = ModData.getOrCreate(VIBE_CHECKER_COMMON.MOD_ID)
end

Events.OnInitGlobalModData.Add(OnInitGlobalModData)

--------------------------
--* Client Commands *--
if isServer() then
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
end
