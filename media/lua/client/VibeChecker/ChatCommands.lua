local chatStream = {name = "requestRealTime", command = "/requestRealTime", shortCommand = "/rrt", tabID = 1}
table.insert(ISChat.allChatStreams, chatStream)

-- TODO Test this
local og_ISChat_onCommandEntered = ISChat.onCommandEntered

---@diagnostic disable-next-line: duplicate-set-field
function ISChat:onCommandEntered()


    local command = ISChat.instance.textEntry:getText()
    if not command or command == "" then return end

    if luautils.stringStarts(command, chatStream.command) or luautils.stringStarts(command, chatStream.shortCommand) then
        sendClientCommand(VIBE_CHECKER_COMMON.MOD_ID, "SendTimeToClient", {showInChat = true})
    end

    og_ISChat_onCommandEntered(self)

end