-- ============================ 
-- === Type Definitions ===
-- ============================

--- @class Button
--- @field label string
--- @field id string|number? (optional)
--- @field onSelect function? (optional)
--- @field close boolean? (optional)
--- @field nextDialog string? (optional)
--- @field reqRep string|number?

--- @class Dialog
--- @field job string
--- @field id string
--- @field ped number?
--- @field name string
--- @field text string
--- @field buttons Button[]

--- @class Prop
--- @field propModel string|number
--- @field bone string|number
--- @field pos vector3
--- @field rot vector3

--- @class Animation
--- @field dict string
--- @field name string
--- @field loop boolean

--- @class PedData
--- @field ped string
--- @field ped_id string|number
--- @field coords vector4
--- @field animation Animation? (optional)
--- @field prop Prop? (optional)
--- @field scenario string? (optional)
--- @field dialog Dialog[]


-- ============================ 
-- === Variable Declarations ===
-- ============================

local dialogPromise = {}
local currentDialog = {}       --- @type Dialog[]
local currentDialogId = 0      --- @type integer
local spawnedPeds = {}         --- @type table<string, { handle: number, dialog: Dialog[], id: string|number }>
local spawnedProps = {}        --- @type table<string, number>

-- ============================ 
-- === Ped Management ===
-- ============================

local function playPedAnimation(ped, dict, anim, loop)
    if not dict or not anim then return end

    if not lib.requestAnimDict(dict, 10000) then
        lib.print.info("playPedAnimation: Failed to load animation dictionary:", dict)
        return
    end

    local flags = loop and 1 or 0
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flags, 0, false, false, false)

    -- Citizen.SetTimeout(5000, function()
    --     RemoveAnimDict(dict)
    -- end)
end

local function spawnPed(model, coords)
    if not model or not coords then
        lib.print.info("spawnPed: Invalid model or coordinates.")
        return nil
    end

    local modelHash = GetHashKey(model)
    if not IsModelValid(modelHash) then
        lib.print.info("spawnPed: Invalid model hash for model:", model)
        return nil
    end

    if not lib.requestModel(model, 10000) then
        lib.print.info("spawnPed: Failed to load model:", model)
        return nil
    end

    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z, coords.h, false, false)
    if not DoesEntityExist(ped) then
        lib.print.info("spawnPed: Failed to create ped for model:", model)
        SetModelAsNoLongerNeeded(modelHash)
        return nil
    end
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanBeTargetted(ped, false)
    SetPedCanRagdoll(ped, false)
    ClearPedTasksImmediately(ped)

    -- SetModelAsNoLongerNeeded(modelHash)

    return ped
end

local function cleanupPeds()
    for pedId, pedData in pairs(spawnedPeds) do
        if DoesEntityExist(pedData.handle) then
            ClearPedTasks(pedData.handle)
            DeleteEntity(pedData.handle)
        end
    end
    spawnedPeds = {}

    for pedId, prop in pairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end
    spawnedProps = {}
end

local function cleanButtons(buttons)
    if not buttons then return {} end
    for _, button in ipairs(buttons) do
        button.onSelect = nil
        button.nextDialog = nil
    end
    return buttons
end

local function findDialogById(id)
    for index, dialog in ipairs(currentDialog) do
        if dialog.id == id then
            return Utils.table_deepclone(dialog), index
        end
    end
    return nil, nil
end

local function switchDialog(id, pedId)
    local dialog, index = findDialogById(id)
    if not dialog then
        lib.print.info('switchDialog: Dialog with id:', id, 'does not exist')
        return
    end

    local reputation = lib.callback.await('bl_dialog:getRep', 500, pedId) or 0
    currentDialogId = index
    dialog.buttons = cleanButtons(dialog.buttons)

    Utils.sendNUIEvent('dialog:show', {
        dialog = dialog,
        rep = reputation,
        ped_id = pedId,
    })
end

exports('switchDialog', switchDialog)

local function showDialog(data)
    if not data or not data.dialog then
        lib.print.info('showDialog: Invalid dialog data!')
        return
    end

    local reputation = lib.callback.await('bl_dialog:getRep', 500, data.ped_id) or 0

    LocalPlayer.state.isDialogOpen = true
    currentDialog = data.dialog
    currentDialogId = 1

    local pedData = spawnedPeds[data.ped_id]
    if pedData then
        CreateCam(pedData.handle)
    end

    local initialDialog = Utils.table_deepclone(currentDialog[1])
    initialDialog.buttons = cleanButtons(initialDialog.buttons)

    Utils.sendNUIEvent('resource:visible', true)
    Utils.sendNUIEvent('dialog:show', {
        dialog = initialDialog,
        rep = reputation,
        ped_id = data.ped_id or false,
    })
    SetNuiFocus(true, true)
end

local function hideDialog()
    LocalPlayer.state.isDialogOpen = false
    Utils.sendNUIEvent('resource:visible', false)
    SetNuiFocus(false, false)
    DestroyCamera()
end


-- ============================ 
-- === NUI Callbacks ===
-- ============================

RegisterNUICallback('resource:close', function(_, cb)
    hideDialog()
    cb('ok')
end)

RegisterNUICallback('dialog:click', function(data, cb)
    if not data or not data.index then
        cb('invalid data')
        return
    end

    local index = tonumber(data.index)
    local currentDlg = currentDialog[currentDialogId]
    if not currentDlg or not currentDlg.buttons then
        cb('no current dialog or buttons')
        return
    end

    local button = currentDlg.buttons[index]
    if not button then
        cb('invalid button')
        return
    end

    local reputation = lib.callback.await('bl_dialog:getRep', 500, data.ped_id) or 0

    if button.reqRep and reputation < button.reqRep then
        cb('not enough reputation')
        return
    end

    if button.close then
        hideDialog()
    end

    if button.onSelect and type(button.onSelect) == "function" then
        local success, err = pcall(button.onSelect)
        if not success then
            lib.print.info('Error in button onSelect callback:', err)
        end
    end

    if button.nextDialog then
        switchDialog(button.nextDialog, data.ped_id)
    end

    cb('ok')
end)


-- ============================ 
-- === Interaction Management ===
-- ============================

local function setupPed(pedData)
    if not pedData or not pedData.ped_id or not pedData.ped or not pedData.coords then
        lib.print.info('setupPed: Invalid pedData:', pedData)
        return
    end

    local pedHandle = spawnPed(pedData.ped, pedData.coords)
    if not pedHandle then
        lib.print.info('setupPed: Failed to spawn ped with ID:', pedData.ped_id)
        return
    end
    if Config.interaction == 'target' then
        local target = Framework.target or exports.bl_bridge:target()
        target.addLocalEntity({
            entity = pedHandle,
            options = {
                {
                    label = "Talk",
                    icon = "fa-regular fa-comment",
                    onSelect = function()
                        showDialog({
                            dialog = pedData.dialog,
                            ped_id = pedData.ped_id
                        })
                    end
                }
            }
        })
    elseif Config.interaction == 'interact' then
        exports.interact:AddLocalEntityInteraction({
            entity = pedHandle,
            id = 'dialog_' .. pedData.ped_id,
            distance = 8.0,
            interactDst = 2.0,
            options = {
                {
                    label = 'Talk',
                    canInteract = function(entity, coords, args)
                        return true
                    end,
                    action = function(entity, coords, args)
                        showDialog({
                            dialog = pedData.dialog,
                            ped_id = pedData.ped_id
                        })
                    end,
                },
            }
        })
    else
        lib.print.info('setupPed: interaction resource not available.')
    end
    spawnedPeds[pedData.ped_id] = { handle = pedHandle, dialog = pedData.dialog, id = pedData.ped_id }

    if pedData.animation and pedData.animation.dict and pedData.animation.name then
        local animDict = pedData.animation.dict
        local animName = pedData.animation.name
        local loop = pedData.animation.loop or false

        if lib.requestAnimDict(animDict, 10000) then
            playPedAnimation(pedHandle, animDict, animName, loop)
        else
            lib.print.info("setupPed: Failed to load animation dictionary:", animDict)
        end
    end

    if pedData.prop and pedData.prop.propModel and pedData.prop.bone then
        local propModel = pedData.prop.propModel
        local bone = pedData.prop.bone
        local pos = pedData.prop.pos or vector3(0.0, 0.0, 0.0)
        local rot = pedData.prop.rot or vector3(0.0, 0.0, 0.0)

        if lib.requestModel(propModel, 10000) then
            local propHash = GetHashKey(propModel)
            local prop = CreateObject(propHash, 0, 0, 0, true, true, false)
            if DoesEntityExist(prop) then
                AttachEntityToEntity(prop, pedHandle, GetPedBoneIndex(pedHandle, bone), pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, true, true, false, true, 1, true)
                spawnedProps[pedData.ped_id] = prop
                SetModelAsNoLongerNeeded(propHash)
            else
                lib.print.info("setupPed: Failed to create prop:", propModel)
                SetModelAsNoLongerNeeded(propHash)
            end
        else
            lib.print.info("setupPed: Failed to load prop model:", propModel)
        end
    end

    if pedData.scenario and type(pedData.scenario) == "string" then
        if not IsPedUsingAnyScenario(pedHandle) then
             TaskStartScenarioInPlace(pedHandle, pedData.scenario, 0, true)
        end
    end
end

exports('setupPed', setupPed)

local function removePed(pedId)
    local pedData = spawnedPeds[pedId]
    if not pedData then
        lib.print.info('removePed: No ped found with id:', pedId)
        return false
    end

    if DoesEntityExist(pedData.handle) then
        ClearPedTasks(pedData.handle)
        DeleteEntity(pedData.handle)
    end

    spawnedPeds[pedId] = nil

    if spawnedProps[pedId] then
        local prop = spawnedProps[pedId]
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
        spawnedProps[pedId] = nil
    end

    return true
end

exports('removePed', removePed)


-- ============================ 
-- === Initialization ===
-- ============================

local function initializePeds()
    if not Config or not Config.pedDataList then
        lib.print.info('initializePeds: Config.pedDataList is not defined.')
        return
    end

    for _, pedData in ipairs(Config.pedDataList) do
        setupPed(pedData)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        cleanupPeds()
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    initializePeds()
end)