local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.NewMedium)
local FONT_SCALE = FONT_HGT_SMALL / 14
local Y_MARGIN = 10 * FONT_SCALE

-- TODO Make it local after tests
VibeCheckerUI = ISCollapsableWindow:derive("VibeCheckerUI")
VibeCheckerUI.instance = nil
VibeCheckerUI.isTimeSet = false -- Static boolean
VibeCheckerUI.data = {}

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

function VibeCheckerUI:initialise()
    ISCollapsableWindow.initialise(self)

    if VibeCheckerUI.isTimeSet then
        Events.EveryOneMinute.Add(VibeCheckerUI.RequestTimeFromServer)
    else
        Events.EveryOneMinute.Remove(VibeCheckerUI.RequestTimeFromServer)
    end
end

function VibeCheckerUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local yOffset = 30 * FONT_SCALE
    local xMargin = 10 * FONT_SCALE
    local entryHeight = 25 * FONT_SCALE




    --* Time to be set *--

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


    --* Time already set *--

    self.setTimePanel = ISRichTextPanel:new(0, yOffset - entryHeight/2, self.width, entryHeight)
    self.setTimePanel:initialise()
    self.setTimePanel.defaultFont = UIFont.Massive
    self.setTimePanel.anchorTop = false
    self.setTimePanel.anchorLeft = false
    self.setTimePanel.anchorBottom = false
    self.setTimePanel.anchorRight = false
    self.setTimePanel.marginLeft = 0
    self.setTimePanel.marginTop = 0
    self.setTimePanel.marginRight = 0
    self.setTimePanel.marginBottom = 0
    self.setTimePanel.autosetheight = false
    self.setTimePanel.background = false
    self.setTimePanel:paginate()
    self.setTimePanel:setEnabled(false)
    self.setTimePanel:setVisible(false)
    self:addChild(self.setTimePanel)

    self.setTimeTooltip = ISToolTip:new()
    self.setTimeTooltip:setOwner(self)
    self.setTimeTooltip:addToUIManager()
    self.setTimeTooltip:setAlwaysOnTop(true)
    self.setTimeTooltip:setVisible(false)
    self.setTimeTooltip:setEnabled(false)
    self.setTimeTooltip.description =
    "This is the actual time! You will switch back to this time when you press the 'Reset' button."

    ----------------------------------

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

    -- If it's in SP, then we don't need to sync anything, it's all on the client obviously
    if not isClient() then
        VibeCheckerUI.SetRealTimeFromServer(FixedTimeHandler.GetRealTimeData())
    end

    self.entryFixedTime:setEnabled(not VibeCheckerUI.isTimeSet)
    self.entryFixedTime:setVisible(not VibeCheckerUI.isTimeSet)
    self.labelFixedTime:setVisible(not VibeCheckerUI.isTimeSet)
    self.setTimePanel:setEnabled(VibeCheckerUI.isTimeSet)
    self.setTimePanel:setVisible(VibeCheckerUI.isTimeSet)

    if VibeCheckerUI.isTimeSet then
        local formattedTime = VibeCheckerUI.GetFormattedTime()
        self.setTimePanel:setText(formattedTime)
        self.setTimePanel.textDirty = true

        self.setTimeTooltip:setEnabled(self.setTimePanel:isMouseOver())
        self.setTimeTooltip:setVisible(self.setTimePanel:isMouseOver())
        self.setTimeTooltip:setX(self:getMouseX() + 23)
        self.setTimeTooltip:setY(self:getMouseY() + 23)

        self.btnSet:setEnable(true)
        self.btnSet:setTitle("Reset")
        -- Set correct text to button. Do it here instead of the buton in case the user closes the panel
    else
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
            Events.EveryOneMinute.Remove(VibeCheckerUI.RequestTimeFromServer)
            sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "StopFixedTime", {})
        else
            Events.EveryOneMinute.Add(VibeCheckerUI.RequestTimeFromServer)
            sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "SetFixedTime", { fixedTime = fixedTime })
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
    if btn.internal == 'SET' then
        self:handleFixedTime()
    elseif btn.internal == "CLIMATE_CONTROL" then
        ClimateControlDebug.OnOpenPanel()
    end
end

function VibeCheckerUI:close()
    self:removeFromUIManager()
    ISCollapsableWindow.close(self)
    Events.EveryOneMinute.Remove(VibeCheckerUI.RequestTimeFromServer)
end

--*******************************--

function VibeCheckerUI.OnOpenPanel()

    if VibeCheckerUI.instance then
        VibeCheckerUI.instance:close()
    end

    -- TODO Make it scale based on resolution
    local width = 200 * FONT_SCALE
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

---Send a request to the server to receive the actual calculated time
function VibeCheckerUI.RequestTimeFromServer()
    sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "SendTimeToClient", {})
end

---Set the time received from the server
---@param time number
function VibeCheckerUI.SetRealTimeFromServer(time)
    VibeCheckerUI.realTime = time
end

function VibeCheckerUI.GetFormattedTime()
    if VibeCheckerUI.realTime then
        -- Get minutes
        local hour = math.floor(VibeCheckerUI.realTime)
        local decimal = math.fmod(VibeCheckerUI.realTime, 1)
        local convertedMinutes = math.floor(decimal * 60)

        return string.format(" <CENTRE> %02d:%02d", hour, convertedMinutes)
    else
        return "LOADING REAL TIME"
    end
end

--************************************-


require "ISUI/ISAdminPanelUI"
require "ServerPointsAdminPanel"
local _ISAdminPanelUICreate = ISAdminPanelUI.create

function ISAdminPanelUI:create()
    _ISAdminPanelUICreate(self)

    local lastButton = self.children[self.IDMax - 1].internal == "CANCEL" and self.children[self.IDMax - 2] or
        self.children[self.IDMax - 1]
    self.btnOpenVibeChecker = ISButton:new(lastButton.x, lastButton.y + 5 + lastButton.height,
        self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "VibeChecker Menu", self, VibeCheckerUI.OnOpenPanel)
    self.btnOpenVibeChecker:initialise()
    self.btnOpenVibeChecker:instantiate()
    self.btnOpenVibeChecker.borderColor = self.buttonBorderColor
    self:addChild(self.btnOpenVibeChecker)
end
