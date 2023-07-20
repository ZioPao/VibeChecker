local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.NewMedium)
local FONT_SCALE = FONT_HGT_SMALL / 14
local Y_MARGIN = 10 * FONT_SCALE

-- TODO Make it local after tests
VibeCheckerUI = ISCollapsableWindow:derive("VibeCheckerUI")
VibeCheckerUI.instance = nil
VibeCheckerUI.isTimeSet = false -- Static boolean

function VibeCheckerUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.resizable = false
    o.width = width
    o.height = height

    o.title = "Vibe Checker"
    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true

    VibeCheckerUI.instance = o
    return o
end

function VibeCheckerUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local yOffset = 30 * FONT_SCALE
    local xMargin = 10 * FONT_SCALE
    local entryHeight = 25 * FONT_SCALE

    self.labelFixedTime = ISLabel:new(xMargin, yOffset, entryHeight, "Set Time: ", 1, 1, 1, 1, UIFont.NewMedium, true)
    self.labelFixedTime:initialise()
    self.labelFixedTime:instantiate()
    self:addChild(self.labelFixedTime)

    self.entryFixedTime = ISTextEntryBox:new("Hour", self.labelFixedTime:getRight() + xMargin, self.labelFixedTime.y,
        self.width - self.labelFixedTime.width - xMargin * 4, entryHeight)
    self.entryFixedTime:initialise()
    self.entryFixedTime:instantiate()
    self.entryFixedTime:setClearButton(true)
    self.entryFixedTime:setOnlyNumbers(true)
    self.entryFixedTime:setMaxTextLength(2)
    self.entryFixedTime:setText("")
    self:addChild(self.entryFixedTime)


    self.btnSet = ISButton:new(xMargin, self.labelFixedTime:getBottom() + Y_MARGIN, self.width - xMargin * 2, entryHeight,
        "Set", self, self.onOptionMouseDown)
    self.btnSet.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnSet.internal = "SET"
    self.btnSet:initialise()
    self.btnSet:instantiate()
    self.btnSet:setEnable(true)
    self:addChild(self.btnSet)

    -- Separator in pre render, need to account for that

    self.btnClimateControl = ISButton:new(xMargin, self.btnSet:getBottom() + Y_MARGIN * 2, self.width - xMargin * 2,
        entryHeight, "Climate Control", self, self.onOptionMouseDown)
    self.btnClimateControl.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnClimateControl.internal = "CLIMATE_CONTROL"
    self.btnClimateControl:initialise()
    self.btnClimateControl:instantiate()
    self.btnClimateControl:setEnable(true)
    self:addChild(self.btnClimateControl)
end

function VibeCheckerUI:update()
    ISCollapsableWindow.update(self)

    if VibeCheckerUI.isTimeSet then
        self.entryFixedTime:setEnabled(false)
        self.btnSet:setEnable(true)
        self.btnSet:setTitle("Reset")
        -- Set correct text to button. Do it here instead of the buton in case the user closes the panel
    else
        self.entryFixedTime:setEnabled(true)
        local hourEntry = self.entryFixedTime:getInternalText()
        local isEnabled = hourEntry ~= "" and (tonumber(hourEntry) < 24 and tonumber(hourEntry) > 0)
        self.btnSet:setEnable(isEnabled)
        self.btnSet:setTitle("Set")
    end
end

function VibeCheckerUI:prerender()
    ISCollapsableWindow.prerender(self)

    -- Separator between set fixed time and the mood stuff
    self.separator = self:drawRect(1, self.btnSet:getBottom() + Y_MARGIN, self.width - 2, 1, 1, 0.4, 0.4, 0.4)
end

function VibeCheckerUI:handleFixedTime()
    local fixedTime = tonumber(self.entryFixedTime:getInternalText())

    if isClient() then
        if VibeCheckerUI.isTimeSet then
            sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "StopFixedTime", {})
        else
            sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "SetFixedTime", {fixedTime = fixedTime})
        end
    else
        if VibeCheckerUI.isTimeSet then
            FixedTimeHandler.StopFixedTime()
        else
            FixedTimeHandler.SetupFixedTime(fixedTime)
        end
    end

    VibeCheckerUI.isTimeSet = not VibeCheckerUI.isTimeSet

    -- TODO If it's mp, take note is the time was set on the server, it must not be only client side!!
end

function VibeCheckerUI:onOptionMouseDown(btn)
    print(btn.internal)
    if btn.internal == 'SET' then
        self:handleFixedTime()
    elseif btn.internal == "CLIMATE_CONTROL" then
        ClimateControlDebug.OnOpenPanel()
    end
end

function VibeCheckerUI:close()
    ISCollapsableWindow.close(self)
end

--*******************************--

function VibeCheckerUI.OnOpenPanel()
    -- TODO Make it scale based on resolution
    local width = 300 * FONT_SCALE
    local height = 150 * FONT_SCALE

    local x = getCore():getScreenWidth() / 2 - width
    local y = getCore():getScreenHeight() / 2 - height

    local pnl = VibeCheckerUI:new(x, y, width, height)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end




--************************************-


require "ISUI/ISAdminPanelUI"
require "ServerPointsAdminPanel"
local _ISAdminPanelUICreate = ISAdminPanelUI.create

function ISAdminPanelUI:create()
    _ISAdminPanelUICreate(self)

    local lastButton = self.children[self.IDMax-1].internal == "CANCEL" and self.children[self.IDMax-2] or self.children[self.IDMax-1]
    self.btnOpenVibeChecker = ISButton:new(lastButton.x, lastButton.y + 5 + lastButton.height, self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "VibeChecker Menu", self, VibeCheckerUI.OnOpenPanel)
    self.btnOpenVibeChecker:initialise()
    self.btnOpenVibeChecker:instantiate()
    self.btnOpenVibeChecker.borderColor = self.buttonBorderColor
    self:addChild(self.btnOpenVibeChecker)

end
