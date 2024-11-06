
--- @class Button
--- @field label string
--- @field id string|number? (optional)
--- @field onSelect function? (optional)
--- @field close boolean? (optional)
--- @field nextDialog string? (optional)
--- @field reqRep string|number?

--- @class dialog
--- @field job string
--- @field id string
--- @field ped number?
--- @field name string
--- @field text string
--- @field buttons Button[]

local dialogPromise = {}
--- @type dialog[]
local currentDialog = {}
--- @type integer
local currentDialogId = 0

local spawnedPeds = {}

local function spawnPed(model, coords)
    local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
    
    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z, coords.h, false, false)
    SetEntityAsMissionEntity(ped, true, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    DisablePedPainAudio(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanPlayGestureAnims(ped, false)
    SetPedCanUseAutoConversationLookat(ped, false)
    ClearPedTasksImmediately(ped)
    SetPedKeepTask(ped, true)
    SetPedMovementClipset(ped, "move_m@generic", 1.0)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    
    return ped
end

local function cleanupPeds()
    for pedId, pedData in pairs(spawnedPeds) do
        DeleteEntity(pedData.handle)
    end
    spawnedPeds = {}
end

local function cleanButtons(buttons)
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
    assert(dialog, 'Dialog with id: ' .. id .. ' does not exist')
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
    assert(data and data.dialog, 'Dialog data is invalid!')
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

RegisterNUICallback('resource:close', function(_, cb)
    hideDialog()
    cb('ok')
end)

RegisterNUICallback('dialog:click', function(data, cb)
    local index = tonumber(data.index)
    local button = currentDialog[currentDialogId] and currentDialog[currentDialogId].buttons[index]

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

    if button.onSelect then
        button.onSelect()
    end

    if button.nextDialog then
        switchDialog(button.nextDialog, data.ped_id)
    end

    cb('ok')
end)

local function setupPed(pedData)
    local model = pedData.ped
    local coords = pedData.coords
    local pedId = pedData.ped_id

    local pedHandle = spawnPed(model, coords)
    spawnedPeds[pedId] = { handle = pedHandle, dialog = pedData.dialog, id = pedId }
    local target = Framework.target or exports.bl_bridge:target()
    target.addLocalEntity({
        entity = pedHandle,
        options = {
            {
                label = "Talk",
                icon = "fa-regular fa-comment",
                onSelect = function()
                    showDialog(pedData)
                end
            }
        }
    })
    -- if u want  interact here it is 
    -- local interactionID = 'dialog_' .. pedId

    -- exports.interact:AddLocalEntityInteraction({
    --     entity = pedHandle,
    --     id = interactionID,
    --     distance = 8.0,
    --     interactDst = 2.0,
    --     options = {
    --         {
    --             label = 'Talk',
    --             canInteract = function(entity, coords, args)
    --                 return true
    --             end,
    --             action = function(entity, coords, args)
    --                 showDialog(pedData)
    --             end,
    --             args = {}
    --         },
    --     }
    -- })
end
exports('setupPed', setupPed)

local function removePed(pedId)
    local pedData = spawnedPeds[pedId]
    if not pedData then
        print('No ped found with id: ' .. pedId)
        return false
    end

    if DoesEntityExist(pedData.handle) then
        DeleteEntity(pedData.handle)
    end

    spawnedPeds[pedId] = nil
    return true
end

exports('removePed', removePed)

local function initializePeds()
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
