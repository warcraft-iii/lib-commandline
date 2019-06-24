require('lib.base')

local Trigger = require('lib.oop.trigger')
local Event = require('lib.oop.event')
local Player = require('lib.oop.player')
local Timer = require('lib.oop.timer')

---@class CommandLine: object
local CommandLine = class('__CommandLine'):new()

---@class CommandHandler: table
---@field triggerPlayer Player
---@field command string
---@field onEvent fun(player:Player, str:String)
local CommandHandler

---@type CommandHandler[]
local _HANDLER = {}

---<static> addOption
---@param player Player
---@param command string
---@param cb fun(player:Player, str:String)
function CommandLine:addOption(player, command, cb)
    local commandList = string.split(command, "|")
    for i, v in ipairs(commandList) do
        if _HANDLER[v] then
            print(string.format('command %s exists.', v))
        else
            _HANDLER[v] = {}
            local h = _HANDLER[v]
            h.command = v
            h.triggerPlayer = player
            h.onEvent = cb
        end
    end
end

---<static> addOptionAnyPlayer
---@param command string
---@param cb fun(player:Player, str:String)
function CommandLine:addOptionAnyPlayer(command, cb)
    self:addOption(nil, command, cb)
end

local function onChatEvent()
    local p = Event.getTriggerPlayer()
    local text = Event.getEventPlayerChatString()
    local command, data = table.unpack(string.split(text, " ", false, 1))
    local h = _HANDLER[command]
    if h and (not h.triggerPlayer or h.triggerPlayer == p) then
        h.onEvent(p, data)
    end
end

---init
local function onLateInit()
    local t = Trigger:create()
    t:addAction(onChatEvent)
    for i = 0, 23 do
        t:registerPlayerChatEvent(Player:get(i), "", false)
    end
end

Timer:after(0.1, onLateInit)

return CommandLine
