local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.NewMedium)
local FONT_SCALE = FONT_HGT_SMALL / 14
local Y_MARGIN = 10 * FONT_SCALE

local STR_TAB = {
    REAL_TIME_STR = getText("IGUI_VibeChecker_RealTime"),
    REAL_TIME_TOOLTIP_STR = getText("IGUI_VibeChecker_RealTimeTooltip"),
    FIXED_TIME_STR = getText("IGUI_VibeChecker_FixedTime"),
    FIXED_TIME_TOOLTIP_STR = getText("IGUI_VibeChecker_FixedTimeTooltip"),
    SET_BTN_STR = getText("IGUI_VibeChecker_SetBtn"),
    RESET_BTN_STR = getText("IGUI_VibeChecker_ResetBtn"),
    WAIT_STR = getText("IGUI_VibeChecker_Wait")
}

------------------

VibeCheckerUI = ISCollapsableWindow:derive("VibeCheckerUI")
VibeCheckerUI.realTime = -1     -- Init
VibeCheckerUI.isTimeSet = false -- Static boolean
VibeCheckerUI.data = {}

function VibeCheckerUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.resizable = false
    o.width = width
    o.height = height

    o.title = getText("IGUI_VibeChecker_Title")
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

---Creates a ISRichTextPanel
---@param xMargin number
---@param yMargin number
---@param width number
---@param height number
---@return ISRichTextPanel
function VibeCheckerUI:createRichTextPanel(xMargin, yMargin, width, height)
    local panel = ISRichTextPanel:new(xMargin, yMargin, width, height)
    panel:initialise()
    panel.defaultFont = UIFont.NewLarge
    panel.anchorTop = false
    panel.anchorLeft = false
    panel.anchorBottom = false
    panel.anchorRight = false
    panel.marginLeft = 2
    panel.marginTop = height / 4
    panel.marginRight = 2
    panel.marginBottom = 0
    panel.autosetheight = false
    panel.background = true
    panel.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.4 }
    panel:paginate()
    panel:setEnabled(false)
    panel:setVisible(false)
    return panel
end

function VibeCheckerUI:createChildren()
    ISCollapsableWindow.createChildren(self)
    local yOffset = 25 * FONT_SCALE
    local xMargin = 10 * FONT_SCALE
    local entryHeight = 25 * FONT_SCALE

    --* Time to be set *--
    self.labelFixedTime = ISLabel:new(xMargin, yOffset, entryHeight, getText("IGUI_VibeChecker_SetTime"), 1, 1, 1, 1,
        UIFont.NewLarge, true)
    self.labelFixedTime:initialise()
    self.labelFixedTime:instantiate()
    self:addChild(self.labelFixedTime)

    self.entryFixedTime = ISTextEntryBox:new("Hour", self.width / 2, self.labelFixedTime.y + 8,
        self.width / 2 - xMargin, entryHeight / 2)
    self.entryFixedTime.font = UIFont.NewLarge -- Need to put it before the initialisation
    self.entryFixedTime.anchorLeft = false
    self.entryFixedTime:initialise()
    self.entryFixedTime:instantiate()
    self.entryFixedTime:setClearButton(true)
    self.entryFixedTime:setOnlyNumbers(true)
    self.entryFixedTime:setMaxTextLength(2)
    self.entryFixedTime:setText("")
    self:addChild(self.entryFixedTime)

    self.realTimeTooltip = ISToolTip:new()
    self.realTimeTooltip:setOwner(self)
    self.realTimeTooltip:addToUIManager()
    self.realTimeTooltip:setAlwaysOnTop(true)
    self.realTimeTooltip:setVisible(false)
    self.realTimeTooltip:setEnabled(false)
    self.realTimeTooltip.description = STR_TAB.REAL_TIME_TOOLTIP_STR

    self.fixedTimeTooltip = ISToolTip:new()
    self.fixedTimeTooltip:setOwner(self)
    self.fixedTimeTooltip:addToUIManager()
    self.fixedTimeTooltip:setAlwaysOnTop(true)
    self.fixedTimeTooltip:setVisible(false)
    self.fixedTimeTooltip:setEnabled(false)
    self.fixedTimeTooltip.description = STR_TAB.FIXED_TIME_TOOLTIP_STR

    ----------------------------------

    -- From the bottom

    self.btnClimateControl = ISButton:new(xMargin, self:getHeight() - entryHeight - Y_MARGIN, self.width - xMargin * 2,
        entryHeight, getText("IGUI_VibeChecker_ClimateControl"), self, self.onOptionMouseDown)
    self.btnClimateControl.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnClimateControl.internal = "CLIMATE_CONTROL"
    self.btnClimateControl:initialise()
    self.btnClimateControl:instantiate()
    self.btnClimateControl:setEnable(true)
    self:addChild(self.btnClimateControl)

    self.btnSet = ISButton:new(xMargin, self.btnClimateControl:getY() - entryHeight - Y_MARGIN * 2,
        self.width - xMargin * 2, entryHeight,
        "Set", self, self.onOptionMouseDown)
    self.btnSet.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.btnSet.internal = "SET"
    self.btnSet:initialise()
    self.btnSet:instantiate()
    self.btnSet:setEnable(true)
    self:addChild(self.btnSet)

    --* Time already set panels*--
    local th = self:titleBarHeight() + 5
    self.realTimePanel = self:createRichTextPanel(0, th, self.width / 2, self.btnSet:getY() - th - 5)
    self:addChild(self.realTimePanel)

    self.fixedTimePanel = self:createRichTextPanel(self.width / 2, th, self.width / 2, self.btnSet:getY() - th - 5)
    self:addChild(self.fixedTimePanel)
end

---Updated the text for a certain ISRichTextPanel
---@param panel ISRichTextPanel
---@param topLine string
---@param time number | string?
function VibeCheckerUI:updateText(panel, topLine, time)
    local formattedString = VibeCheckerUI.GetFormattedTime(tonumber(time))
    local finalStr
    if formattedString == nil or formattedString == "" then
        finalStr = " <CENTRE> " .. topLine .. " <LINE> " .. STR_TAB.WAIT_STR
    else
        finalStr = " <CENTRE> " .. topLine .. " <LINE> " .. formattedString
    end

    --print(finalStr)
    panel:setText(finalStr)
    panel.textDirty = true
end

---Set a panel as active
---@param panel ISUIElement
---@param isActive boolean
function VibeCheckerUI:activatePanel(panel, isActive)
    panel:setEnabled(isActive)
    panel:setVisible(isActive)
end

---Activate a tooltip if the connect one is hovered on
---@param tooltipPanel ISToolTip
---@param connectedPanel ISUIElement
function VibeCheckerUI:handleTooltip(tooltipPanel, connectedPanel)
    tooltipPanel:setEnabled(connectedPanel:isMouseOver())
    tooltipPanel:setVisible(connectedPanel:isMouseOver())
    tooltipPanel:setX(self:getMouseX() + 23)
    tooltipPanel:setY(self:getMouseY() + 23)
end

function VibeCheckerUI:update()
    ISCollapsableWindow.update(self)
    -- If it's in SP, then we don't need to sync anything, it's all on the client obviously
    if not isClient() then
        VibeCheckerUI.SetRealTimeFromServer(FixedTimeHandler.GetRealTimeData())
    end

    self:activatePanel(self.entryFixedTime, not VibeCheckerUI.isTimeSet)
    self:activatePanel(self.labelFixedTime, not VibeCheckerUI.isTimeSet)
    self:activatePanel(self.realTimePanel, VibeCheckerUI.isTimeSet)
    self:activatePanel(self.fixedTimePanel, VibeCheckerUI.isTimeSet)

    if VibeCheckerUI.isTimeSet then
        self:updateText(self.realTimePanel, STR_TAB.REAL_TIME_STR, VibeCheckerUI.realTime)
        self:updateText(self.fixedTimePanel, STR_TAB.FIXED_TIME_STR, getGameTime():getTimeOfDay())

        self:handleTooltip(self.realTimeTooltip, self.realTimePanel)
        self:handleTooltip(self.fixedTimeTooltip, self.fixedTimePanel)

        -- Set correct text to button.
        -- Do it here instead of the buton in case the user closes the panel
        self.btnSet:setEnable(true)
        self.btnSet:setTitle(STR_TAB.RESET_BTN_STR)
    else
        local hourEntry = self.entryFixedTime:getInternalText()
        local isEnabled = hourEntry ~= "" and (tonumber(hourEntry) < 24 and tonumber(hourEntry) > 0)
        self.btnSet:setEnable(isEnabled)
        self.btnSet:setTitle(STR_TAB.SET_BTN_STR)
    end
end

function VibeCheckerUI:render()
    ISCollapsableWindow.render(self)

    -- Handle openPanel syncing with the main one
    if self.openedPanel then
        self.openedPanel:setX(self:getRight())
        self.openedPanel:setY(self:getBottom() - self:getHeight())
    end
end

function VibeCheckerUI:prerender()
    ISCollapsableWindow.prerender(self)

    -- Separator between set fixed time and the mood stuff
    self.separator = self:drawRect(1, self.btnClimateControl:getY() - Y_MARGIN, self.width - 2, 1, 1, 0.4, 0.4, 0.4)
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
        elseif fixedTime then
            FixedTimeHandler.SetupFixedTime(fixedTime)
        end
    end

    VibeCheckerUI.isTimeSet = not VibeCheckerUI.isTimeSet
end

function VibeCheckerUI:onOptionMouseDown(btn)
    if btn.internal == 'SET' then
        self:handleFixedTime()
    elseif btn.internal == "CLIMATE_CONTROL" then
        if self.openedPanel then
            self.openedPanel:close()
            self.openedPanel = nil
        else
            self.openedPanel = ISDebugPanelBase.OnOpenPanel(ClimateControlDebug, self:getRight(),
                self:getBottom() - self:getHeight(), 800, 600, "CLIMATE CONTROL")
        end
    end
end

function VibeCheckerUI:close()
    self:removeFromUIManager()
    ISCollapsableWindow.close(self)
    Events.EveryOneMinute.Remove(VibeCheckerUI.RequestTimeFromServer)

    -- Manage and close the side panel
    if self.openedPanel then
        self.openedPanel:close()
        self.openedPanel = nil
    end

    if isClient() then
        sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "ForfeitAccess", {})
    end

    VibeCheckerUI.instance = nil
end

--*******************************--

function VibeCheckerUI.RequestAccess()
    sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "RequestAccess", {})
end

function VibeCheckerUI.OnOpenPanel()
    if VibeCheckerUI.instance then
        VibeCheckerUI.instance:close()
    end

    -- TODO Make it scale based on resolution
    local width = 150 * FONT_SCALE
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

---Get formatted time
---@param time number?
---@return string
function VibeCheckerUI.GetFormattedTime(time)
    if time == nil then return "" end

    -- Get minutes
    local hour = math.floor(time)
    local decimal = math.fmod(time, 1)
    local convertedMinutes = math.floor(decimal * 6)        -- Cap it at 10 minutes instead of checking every minutes.

    return string.format("%02d:%01d0", hour, convertedMinutes)
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
        self.sandboxOptionsBtn.width, self.sandboxOptionsBtn.height, "VibeChecker Menu", self,
        VibeCheckerUI.RequestAccess)
    self.btnOpenVibeChecker:initialise()
    self.btnOpenVibeChecker:instantiate()
    self.btnOpenVibeChecker.borderColor = self.buttonBorderColor
    self:addChild(self.btnOpenVibeChecker)
end
