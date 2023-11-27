local VibeCheckerUI = require("VibeChecker/UIMain")

local keybindVal = "OpenVibeChecker"

local function InitKeybinds()
    if isServer() then return end

    table.insert(keyBinding, {value = "[VibeChecker]", key = nil})
    table.insert(keyBinding, {value = keybindVal, key = Keyboard.KEY_NUMPAD0})
end
Events.OnGameBoot.Add(InitKeybinds)

local function HandleKey(key)
    if key ~= getCore():getKey(keybindVal) then return end
    if SandboxVars.VibeChecker.SetMode == true then return end

    if isClient() and isAdmin() then
        VibeCheckerUI.RequestAccess()
    elseif not isClient() then
        VibeCheckerUI.OnOpenPanel()
    end
end
Events.OnKeyPressed.Add(HandleKey)