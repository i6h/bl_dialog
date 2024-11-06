
local function getPlayer(source)
    if GetResourceState('qbx_core') == 'started' then
        return exports.qbx_core:GetPlayer(source)
    elseif GetResourceState('es_extended') == 'started' then
        ESX = exports["es_extended"]:getSharedObject()
        local Player = ESX.GetPlayerFromId(source)
        return Player
    elseif GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        return Player
    else
        -- your thing :D 
    end
end

local function setReputation(source, identifier, pedId, amount)
    MySQL.Async.execute('UPDATE dialog_reputation SET reputation = @amount WHERE identifier = @identifier AND ped_id = @ped_id', {
        ['@amount'] = amount,
        ['@identifier'] = identifier,
        ['@ped_id'] = pedId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('bl_dialog:updateRep', source, pedId, amount)
        else
            MySQL.Async.execute('INSERT INTO dialog_reputation (identifier, ped_id, reputation) VALUES (@identifier, @ped_id, @reputation)', {
                ['@identifier'] = identifier,
                ['@ped_id'] = pedId,
                ['@reputation'] = amount
            }, function()
                TriggerClientEvent('bl_dialog:updateRep', source, pedId, amount)
            end)
        end
    end)
end

local function addReputation(source, identifier, pedId, amount)
    MySQL.Async.fetchAll('SELECT reputation FROM dialog_reputation WHERE identifier = @identifier AND ped_id = @ped_id', {
        ['@identifier'] = identifier,
        ['@ped_id'] = pedId
    }, function(result)
        local newReputation = result[1] and result[1].reputation + amount or amount
        setReputation(source, identifier, pedId, newReputation)
    end)
end

local function removeReputation(source, identifier, pedId, amount)
    MySQL.Async.fetchAll('SELECT reputation FROM dialog_reputation WHERE identifier = @identifier AND ped_id = @ped_id', {
        ['@identifier'] = identifier,
        ['@ped_id'] = pedId
    }, function(result)
        local newReputation = result[1] and math.max(result[1].reputation - amount, 0) or 0
        setReputation(source, identifier, pedId, newReputation)
    end)
end

local function getReputation(identifier, pedId)
    local p = promise.new()
    MySQL.Async.fetchAll('SELECT reputation FROM dialog_reputation WHERE identifier = @identifier AND ped_id = @ped_id', {
        ['@identifier'] = identifier,
        ['@ped_id'] = pedId
    }, function(result)
        p:resolve(result[1] and result[1].reputation or 0)
    end)
    return Citizen.Await(p)
end

RegisterServerEvent('bl_dialog:initializeRep')
AddEventHandler('bl_dialog:initializeRep', function(pedId)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    local identifier = player.PlayerData.citizenid
    local rep = getReputation(identifier, pedId)
    TriggerClientEvent('bl_dialog:setRep', src, pedId, rep)
end)

lib.callback.register('bl_dialog:getRep', function(source, pedId)
    local player = getPlayer(source)
    if not player then return false end

    local identifier = player.PlayerData.citizenid
    return getReputation(identifier, pedId)
end)

exports('setReputation', function(source, pedId, amount)
    local player = getPlayer(source)
    if not player then return false end

    local identifier = player.PlayerData.citizenid
    setReputation(source, identifier, pedId, amount)
end)

exports('addReputation', function(source, pedId, amount)
    local player = getPlayer(source)
    if not player then return false end

    local identifier = player.PlayerData.citizenid
    addReputation(source, identifier, pedId, amount)
end)

exports('removeReputation', function(source, pedId, amount)
    local player = getPlayer(source)
    if not player then return false end

    local identifier = player.PlayerData.citizenid
    removeReputation(source, identifier, pedId, amount)
end)

-- for test 
-- RegisterCommand('addrep', function(source, args)
--     if #args < 3 then
--         print("Usage: /addrep [targetPlayerId] [pedId] [amount]")
--         return
--     end
    
--     local targetPlayerId = tonumber(args[1])
--     local pedId = args[2]
--     local amount = tonumber(args[3])
    
--     local player = getPlayer(targetPlayerId)
--     if not player then return end
    
--     local identifier = player.PlayerData.citizenid
--     addReputation(targetPlayerId, identifier, pedId, amount)
-- end, false)