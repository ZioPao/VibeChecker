-- Way to import\export presets for the Climate Control


-- Since it's all handled with y going down and down by adding stuff, we don't have a lot of options overriding it,
-- So we're gonna do it the dirty way.
require "DebugUIs/DebugMenu/Climate/ClimateOptionsDebug"

---@alias floatsTab table<string, {tickbox : ISTickBox, slider : ISSliderPanel}>
---@alias colorsTab table<string, {tickbox : ISTickBox, sliderR : ISSliderPanel, sliderG : ISSliderPanel, sliderB : ISSliderPanel, sliderA : ISSliderPanel, sliderR_int : ISSliderPanel, sliderG_int : ISSliderPanel, sliderB_int : ISSliderPanel, sliderA_int : ISSliderPanel}>

function ClimateOptionsDebug:createChildren()
    ISPanel.createChildren(self)

    local clim = getClimateManager()
    self.clim = clim
    self.allOptions = {}

    ---@type floatsTab
    self.floats = {}
    ---@type colorsTab
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
    self:createJsonTable()      -- TODO overkill
end

function ClimateOptionsDebug:createJsonTable()
    ---@alias savedFloatsT table<string, {isTicked : boolean, value : number}>
    ---@type savedFloatsT
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
    ---@alias savedColorsT table<string, {isTicked : boolean, r : number, g : number, b : number, a : number, r_int : number, g_int : number, b_int : number, a_int : number}>
    ---@type savedColorsT
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
local json = require("VibeChecker/json")
local STR_JSON_FOLDER = "media/data/"
local STR_JSON_CLIM_COLORS = "climColors.json"
local STR_JSON_CLIM_FLOATS = "climFloats.json"

local function OnSaveSettings(btn)
    print("Save floats")
    local jsonStr = json.stringify(btn.floatsJson)
    local writer = getModFileWriter(VIBE_CHECKER_COMMON.MOD_ID, STR_JSON_FOLDER .. STR_JSON_CLIM_FLOATS, true, false)
    writer:write(jsonStr)
    writer:close()

    print("Save Colors")
    jsonStr = json.stringify(btn.colorsJson)
    writer = getModFileWriter(VIBE_CHECKER_COMMON.MOD_ID, STR_JSON_FOLDER .. STR_JSON_CLIM_COLORS, true, false)
    writer:write(jsonStr)
    writer:close()
end

--- Get JSON reader, read the files (each one) and re set the sliders
local function OnLoadSettings(btn)
    local strClimFloats = json.readFile(VIBE_CHECKER_COMMON.MOD_ID, STR_JSON_FOLDER .. STR_JSON_CLIM_FLOATS)

    ---@type savedFloatsT
    local dataFloats = json.parse(strClimFloats)
    ---@type floatsTab
    local floats = btn.floats

    for category, v in pairs(dataFloats) do
        floats[category].tickbox:setSelected(1, v.isTicked)
        btn.allOptions[category].option:setEnableAdmin(v.isTicked)
        floats[category].slider:setCurrentValue(v.value)
    end

    local strClimColors = json.readFile(VIBE_CHECKER_COMMON.MOD_ID, STR_JSON_FOLDER .. STR_JSON_CLIM_COLORS)
    
    ---@type savedColorsT
    local dataColors = json.parse(strClimColors)
    ---@type colorsTab
    local colors = btn.colors

    for category, v in pairs(dataColors) do
        colors[category].tickbox:setSelected(1, v.isTicked)
        btn.allOptions[category].option:setEnableAdmin(v.isTicked)
        colors[category].sliderR:setCurrentValue(v.r)
        colors[category].sliderG:setCurrentValue(v.g)
        colors[category].sliderB:setCurrentValue(v.b)
        colors[category].sliderR_int:setCurrentValue(v.r_int)
        colors[category].sliderG_int:setCurrentValue(v.g_int)
        colors[category].sliderB_int:setCurrentValue(v.b_int)
        colors[category].sliderA_int:setCurrentValue(v.a_int)
    end
end

local function OnResetSettings(btn)
    ---@type floatsTab
    local floats = btn.floats

    for category, v in pairs(floats) do
        floats[category].tickbox.selected[1] = false
        floats[category].slider:setCurrentValue(0)

        btn.allOptions[category].option:setEnableAdmin(false)
    end

    ---@type colorsTab
    local colors = btn.colors

    for category, v in pairs(colors) do
        colors[category].tickbox:setSelected(1, false)
        btn.allOptions[category].option:setEnableAdmin(false)
    end

end

---Buttons that will act as save\load button
---@param _x number
---@param _y number
---@param _w number
---@return number
function ClimateOptionsDebug:addSaveOption(_x, _y, _w)
    -- TODO Way to delete save
    local h = 20
    ISDebugUtils.addButton(self, self, _x, _y, _w, h, "Save", OnSaveSettings)
    _y = _y + h

    ISDebugUtils.addButton(self, self, _x, _y, _w, h, "Load", OnLoadSettings)
    _y = _y + h

    local y, _ = ISDebugUtils.addButton(self, self, _x, _y, _w, h, "Reset", OnResetSettings)


    return y
end



