-- TODO Make a delay handler 


local Delay = {}
Delay.instances = {}


function Delay:setup()
    local o = {}

    table.insert(Delay.instances, o)
end


function Delay.Handle()
    for i=1, #Delay.instances do
        local instance = Delay.instances[i]
    end
end