local chatStream = {name = "requestRealTime", command = "/requestRealTime", shortCommand = "/rrt", tabID = 1}
table.insert(ISChat.allChatStreams, chatStream)

local og_ISChat_onCommandEntered = ISChat.onCommandEntered

function ISChat:onCommandEntered()

    og_ISChat_onCommandEntered(self)

    local command = ISChat.instance.textEntry:getText()
    if not command or command == "" then return end

    if luautils.stringStarts(command, chatStream.command) or luautils.stringStarts(command, chatStream.shortCommand) then
        sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "SendTimeToClient", {showInChat = true})
    end


end