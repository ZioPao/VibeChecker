-- TODO Way to import\export presets for the Climate Control

--ClimateOptionsDebug = ISDebugSubPanelBase:derive("ClimateOptionsDebug")


local og_ClimateOptionsDebug_createChildren = ClimateOptionsDebug.createChildren
function ClimateOptionsDebug:createChildren()
    ISPanel.createChildren(self)

    local clim = getClimateManager()
    self.clim = clim
    self.allOptions = {}
    self.floats = {}
    self.colors = {}
    self.bools = {}

    local v, obj

    local x,y,w = 10,10,self.width-30

    self:initHorzBars(x,w)
    local barMod = 3

    y, obj = ISDebugUtils.addLabel(self, "save_title", x + (w/2), y, "Save/Load", UIFont.Medium)
    obj.center = true
    y = ISDebugUtils.addHorzBar(self, y +5) + 5
    y = self:addSaveOption(x, y, w)
    y = ISDebugUtils.addHorzBar(self, y + barMod) + barMod


    y = y+5


    y, obj = ISDebugUtils.addLabel(self,"float_title",x+(w/2),y,"Climate floats", UIFont.Medium)
    obj.center = true
    y = ISDebugUtils.addHorzBar(self,y+5)+5

    --print("w = "..tostring(w))
    for i=0,clim:getFloatMax()-1 do
        v = clim:getClimateFloat(i)
        y, obj = self:addFloatOption(v:getName(),v,x,y,w)
        --print(v:getName())
        y = ISDebugUtils.addHorzBar(self,y+barMod)+barMod
    end

    y = y+5
    y, obj = ISDebugUtils.addLabel(self,"color_title",x+(w/2),y,"Climate colors", UIFont.Medium)
    obj.center = true
    y = ISDebugUtils.addHorzBar(self,y+5)+5

    for i=0,clim:getColorMax()-1 do
        v = clim:getClimateColor(i)
        y, obj = self:addColorOption(v:getName(),v,x,y,w)
        --print(v:getName())
        y = ISDebugUtils.addHorzBar(self,y+barMod)+barMod
    end

    y = y+5
    y, obj = ISDebugUtils.addLabel(self,"bool_title",x+(w/2),y,"Climate booleans", UIFont.Medium)
    obj.center = true
    y = ISDebugUtils.addHorzBar(self,y+5)+5

    for i=0,clim:getBoolMax()-1 do
        v = clim:getClimateBool(i)
        y, obj = self:addBoolOption(v:getName(),v,x,y,w)
        --print(v:getName())
        y = ISDebugUtils.addHorzBar(self,y+barMod)+barMod
    end

    --print("VAL = "..tostring(ClimateManager.FLOAT_PRECIPITATION_INTENSITY))
    --self:addButton("test1",20,20,100,20,"test1")
    --y, obj = self:addButton("test2",20,800,100,20,"test2")

    self:setScrollHeight(y+10)
end

function ClimateOptionsDebug:update()
    ISPanel.update(self)
    self:createJsonTable()

end

function ClimateOptionsDebug:createJsonTable()
    self.floatsJson = {}
    local floats = self.floats

    for category,v in pairs(floats) do
        -- category can be AMBIENT, CLOUD INTENSITY, DESATURATION, ETC
        -- Save slider value and if it's ticked
        self.floatsJson[category] = {
            isTicked = v.tickbox:isSelected(1),
            value = v.slider:getCurrentValue()
        }
    end

    self.colorsJson = {}
    local colors = self.colors
    for category,v in pairs(colors) do
        self.colorsJson[category] = {
            isTicked = v.tickbox:isSelected(1),
            r = v.sliderR:getCurrentValue(),
            g = v.sliderG:getCurrentValue(),
            b = v.sliderB:getCurrentValue(),
            a = v.sliderA:getCurrentValue(),
            r_int = v.sliderR_int:getCurrentValue(),
            g_int = v.sliderG_int:getCurrentValue(),
            b_int = v.sliderB_int:getCurrentValue(),
            a_int = v.sliderA_int:getCurrentValue(),
        }
    end
end



local function OnSaveSettings(btn)
    local json = require("VibeChecker/json")

    print("Save floats")

    local jsonStr = json.stringify(btn.floatsJson)
    local writer = getModFileWriter(VIBE_CHECKER_COMMON.MOD_ID, "media/data/climFloats.json", true, false)
    writer:write(jsonStr)
    writer:close()

    print("Save Colors")
    jsonStr = json.stringify(btn.colorsJson)
    writer = getModFileWriter(VIBE_CHECKER_COMMON.MOD_ID, "media/data/climColors.json", true, false)
    writer:write(jsonStr)
    writer:close()
end

local function OnLoadSettings(btn)
    -- TODO Do it
end

function ClimateOptionsDebug:addSaveOption(_x, _y, _w)

    -- TODO Buttons that will act as save\load button
    -- TODO Way to delete save
    local h = 20
    ISDebugUtils.addButton(self, self, _x, _y, _w, h, "Save", OnSaveSettings)
    _y = _y + h

    ISDebugUtils.addButton(self, self, _x, _y, _w, h, "Load", OnLoadSettings)
    _y = _y + h

    local y, _ = ISDebugUtils.addButton(self, self, _x, _y, _w, h, "Reset", nil)


    return y
end



