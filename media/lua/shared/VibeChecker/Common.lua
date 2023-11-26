VIBE_CHECKER_COMMON = {}

VIBE_CHECKER_COMMON.MOD_ID = 'VibeChecker'

VIBE_CHECKER_COMMON.MONTHS = {}
VIBE_CHECKER_COMMON.MONTHS[1] = 31       -- January
VIBE_CHECKER_COMMON.MONTHS[2] = 28       -- February
VIBE_CHECKER_COMMON.MONTHS[3] = 31       -- March
VIBE_CHECKER_COMMON.MONTHS[4] = 30       -- April
VIBE_CHECKER_COMMON.MONTHS[5] = 31       -- May
VIBE_CHECKER_COMMON.MONTHS[6] = 30       -- June
VIBE_CHECKER_COMMON.MONTHS[7] = 31       -- July
VIBE_CHECKER_COMMON.MONTHS[8] = 31       -- August
VIBE_CHECKER_COMMON.MONTHS[9] = 30       -- September
VIBE_CHECKER_COMMON.MONTHS[10] = 31      -- October
VIBE_CHECKER_COMMON.MONTHS[11] = 30      -- November
VIBE_CHECKER_COMMON.MONTHS[12] = 31      -- December


---Get formatted time
---@param time number?
---@return string
function VIBE_CHECKER_COMMON.GetFormattedTime(time)
    if time == nil then return "" end

    -- Get minutes
    local hour = math.floor(time)
    local decimal = math.fmod(time, 1)
    local convertedMinutes = math.floor(decimal * 6)        -- Cap it at 10 minutes instead of checking every minutes.

    return string.format("%02d:%01d0", hour, convertedMinutes)
end