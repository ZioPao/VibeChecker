local keybindVal = "OpenVibeChecker"

local function InitKeybinds()
    if isServer() then return end

    table.insert(keyBinding, {value = "[VibeChecker]", key = nil})
    table.insert(keyBinding, {value = keybindVal, key = Keyboard.KEY_MINUS})
end
Events.OnGameBoot.Add(InitKeybinds)

local function HandleKey(key)
    if key ~= getCore():getKey(keybindVal) then return end

    if isClient() then
        VibeCheckerUI.RequestAccess()
    else
        VibeCheckerUI.OnOpenPanel()
    end
end
Events.OnKeyPressed.Add(HandleKey)