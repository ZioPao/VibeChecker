local Common = {}

--- id=3096949956 REUPLOAD
--- id=3093274467 OG

Common.MOD_ID = 'VibeChecker'

Common.MONTHS = {}
Common.MONTHS[1] = 31       -- January
Common.MONTHS[2] = 28       -- February
Common.MONTHS[3] = 31       -- March
Common.MONTHS[4] = 30       -- April
Common.MONTHS[5] = 31       -- May
Common.MONTHS[6] = 30       -- June
Common.MONTHS[7] = 31       -- July
Common.MONTHS[8] = 31       -- August
Common.MONTHS[9] = 30       -- September
Common.MONTHS[10] = 31      -- October
Common.MONTHS[11] = 30      -- November
Common.MONTHS[12] = 31      -- December


---Get formatted time
---@param time number?
---@return string
function Common.GetFormattedTime(time)
    if time == nil then return "" end

    -- Get minutes
    local hour = math.floor(time)
    local decimal = math.fmod(time, 1)
    local convertedMinutes = math.floor(decimal * 6)        -- Cap it at 10 minutes instead of checking every minutes.

    return string.format("%02d:%01d0", hour, convertedMinutes)
end

return Common