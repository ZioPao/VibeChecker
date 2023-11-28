--todo add TestFramework test stuff

if not getActivatedMods():contains("TEST_FRAMEWORK") or not isDebugEnabled() then return end
local TestFramework = require("TestFramework/TestFramework")
local TestUtils = require("TestFramework/TestUtils")
local Delay = require("VibeChecker/Delay")


TestFramework.registerTestModule("Delay", "Setup", function()
    local Tests = {}
    function Tests.RunPrintAfter5Seconds()
        Delay.Add(print, {"Running this after 5 seconds"}, 5)
    end

    function Tests.RunPrintAfter10Seconds()
        Delay.Add(print, {"Running this after 10 seconds"}, 10)
    end

    function Tests.RunConcurrentPrintDelays()
        Delay.Add(print, {"Delay: 5 seconds"}, 5)
        Delay.Add(print, {"Delay: 10 seconds"}, 10)
    end

    return Tests
end)