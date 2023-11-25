VIBE_CHECKER_COMMON = {
    MOD_ID = 'VibeChecker',
    MONTHS = {
        31, -- Jan
        28, -- Feb
        31, -- March
        30, -- April
        31, -- May
        30, -- June
        31, -- July
        31, -- August
        30, -- Sep
        31, -- October
        30, -- Nov
        31, -- Dec
    },

}

---Get a new months table
---@return table
function VIBE_CHECKER_COMMON.GetNewMonthsTable()
    local months = {}
    for i = 1, #VIBE_CHECKER_COMMON.MONTHS do
        months[i] = VIBE_CHECKER_COMMON.MONTHS[i]
    end

    return months
end

-- TODO Add debugprint
