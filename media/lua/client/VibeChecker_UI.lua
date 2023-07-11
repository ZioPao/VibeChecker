-- TODO Make it local after tests
VibeCheckerUI = ISCollapsableWindow:derive("VibeCheckerUI")
VibeCheckerUI.instance = nil

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

end


function VibeCheckerUI:update()
    ISCollapsableWindow.update(self)
end

function VibeCheckerUI:close()
    ISCollapsableWindow.close(self)
end

function VibeCheckerUI.OnOpenPanel()
    -- TODO Make it scale based on resolution
    local width = 400
    local height = 300

    local x = getCore():getScreenWidth() / 2 - width
    local y = getCore():getScreenHeight() / 2 - height

    local pnl = VibeCheckerUI:new(x, y, width, height)
    pnl:initialise()
    pnl:instantiate()
    pnl:addToUIManager()
    pnl:bringToTop()
    return pnl
end
