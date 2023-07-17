local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.NewMedium)
local FONT_SCALE = FONT_HGT_SMALL / 14
local Y_MARGIN = 10 * FONT_SCALE

-- TODO Make it local after tests
VibeCheckerUI = ISCollapsableWindow:derive("VibeCheckerUI")
VibeCheckerUI.instance = nil
VibeCheckerUI.isTimeSet = false     -- Static boolean

function VibeCheckerUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.resizable = false
    o.width = width
    o.height = height

    o.variableColor = { r = 0.9, g = 0.55, b = 0.1, a = 1 }
    o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 1.0 }
    o.buttonBorderColor = { r = 0.7, g = 0.7, b = 0.7, a = 0.5 }
    o.moveWithMouse = true

    VibeCheckerUI.instance = o
    return o
end



function VibeCheckerUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local yOffset = 40
    local xMargin = 10 * FONT_SCALE
    print(FONT_SCALE)
    local entryHeight = 25 * FONT_SCALE

    -- self.panelTime = ISPanel:new(0, yOffset, self.width, 0)       --Height doesn't really matter, but we will set in fillSkillPanel
    -- self:addChild(self.panelTime)

    self.labelFixedTime = ISLabel:new(xMargin, yOffset, entryHeight, "Set Time: ", 1, 1, 1, 1, UIFont.NewMedium, true)
    self.labelFixedTime:initialise()
    self.labelFixedTime:instantiate()
    self:addChild(self.labelFixedTime)

    self.entryFixedTime = ISTextEntryBox:new("Hour", self.labelFixedTime:getRight() + xMargin, self.labelFixedTime.y, self.width - self.labelFixedTime.width - xMargin*4, entryHeight)
    self.entryFixedTime:initialise()
    self.entryFixedTime:instantiate()
    self.entryFixedTime.font = UIFont.NewMedium
    self.entryFixedTime:setClearButton(true)
    self.entryFixedTime:setOnlyNumbers(true)        -- TODO This means no :, fix this
    self.entryFixedTime:setMaxTextLength(2)
    self.entryFixedTime:setText("")
    self:addChild(self.entryFixedTime)

    -- self.entryFixedTimeMinutes = ISTextEntryBox:new("Hour", self.entryFixedTimeHour:getRight() + 5, self.labelFixedTime.y, self.entryFixedTimeHour - self.labelFixedTime.width - xMargin*4, entryHeight)
    -- self.entryFixedTimeMinutes:initialise()
    -- self.entryFixedTimeMinutes:instantiate()
    -- self.entryFixedTimeMinutes:setClearButton(true)
    -- self.entryFixedTimeMinutes:setOnlyNumbers(true)        
    -- self.entryFixedTimeMinutes:setText("")
    -- self:addChild(self.entryFixedTimeMinutes)

    self.btnSet = ISButton:new(xMargin, self.labelFixedTime:getBottom() + Y_MARGIN, self.width - xMargin*2, entryHeight, "Set", self, self.onOptionMouseDown)
    self.btnSet.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnSet.internal = "SET"
    self.btnSet:initialise()
    self.btnSet:instantiate()
    self.btnSet:setEnable(true)
    self:addChild(self.btnSet)


    -- Separator in pre render, need to account for that

    self.btnClimateControl = ISButton:new(xMargin, self.btnSet:getBottom() + Y_MARGIN*2, self.width - xMargin*2, entryHeight, "Climate Control", self, self.onOptionMouseDown)
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
        local hourEntry = self.entryFixedTime:getInternalText()
        local isEnabled = hourEntry ~= "" and (tonumber(hourEntry) < 24 and tonumber(hourEntry) > 0)
        self.btnSet:setEnable(isEnabled)
    end
end

function VibeCheckerUI:prerender()
    ISCollapsableWindow.prerender(self)

    -- Separator between set fixed time and the mood stuff
    self.separator = self:drawRect(1, self.btnSet:getBottom() + Y_MARGIN, self.width -2, 1, 1, 0.4, 0.4, 0.4)
end

function VibeCheckerUI:onOptionMouseDown(btn)
    print(btn.internal)
    if btn.internal == 'SET' then
        if VibeCheckerUI.isTimeSet then
            FixedTimeHandler.StopFixedTime()
            VibeCheckerUI.isTimeSet = false
        else
            FixedTimeHandler.SetupFixedTime(tonumber(self.entryFixedTime:getInternalText()))
            VibeCheckerUI.isTimeSet = true

        end
    elseif btn.internal == "CLIMATE_CONTROL" then
        ClimateControlDebug.OnOpenPanel()
    end
end

function VibeCheckerUI:close()
    ISCollapsableWindow.close(self)
end

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
