local os_time = os.time

---@class Delay
local Delay = {}
Delay.isRunning = false

---@param func function
---@param time number
function Delay.Add(func, args, time)
    if Delay.running == nil then
        Delay.running = {}
        Events.OnTick.Add(Delay.Loop)
    end

    table.insert(Delay.running, {
        func = func,
        args = args,
        eTime = time + os_time(),
    })
end

function Delay.StopLoop()
    Delay.running = nil
    Events.OnTick.Remove(Delay.Loop)
end

function Delay.Loop()
    local cTime = os_time()

    for i=1, #Delay.running do
        local tab = Delay.running[i]


        if tab and cTime > tab.eTime then
            ---@diagnostic disable-next-line: deprecated
            tab.func(unpack(tab.args))
            table.remove(Delay.running, i)

            if #Delay.running == 0 then
                Delay.StopLoop()
            end
            -- TODO Check
        end
    end
end

return Delay