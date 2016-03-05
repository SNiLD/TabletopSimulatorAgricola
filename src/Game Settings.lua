--[[ Helpers ]]

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end


function table.removeByValue(table, value)
    found = false
    for tableKey, tableValue in pairs(table) do
        if tableValue == value then
            table[tableKey] = nil
            found = true
        end
    end
    return found
end


function table.getKey(table, value)
    for tableKey, tableValue in pairs(table) do
        if (tableValue == value) then
            return tableKey
        end
    end
    return nil
end


function table.toString(table, separator)
    result = ""
    for _, value in pairs(table) do
        if (string.len(result) == 0) then
            result = result .. value
        else
            result = result .. separator .. value
        end
    end
    return result
end

--[[ Globals for this script ]]

objectGUIDsInTheZone = {}
playerCount = 0
deckTypes = {}
playerCountTokenGUIDs = { "f8d86b", "b51ba9", "feb2ff", "d5b306", "3eb5e5" }
startGameTokenGUID = "201379"
kDeckTokenGUID = "e1662e"
eDeckTokenGUID = "9752bc"
iDeckTokenGUID = "ae31c5"

--[[ Private functions ]]

function updateGameSettings()
    playerCount = 0
    startGame = false
    deckTypes = {}
    for _, objectGUID in pairs(objectGUIDsInTheZone) do
        if (table.contains(playerCountTokenGUIDs, objectGUID)) then
            updatePlayerCount(objectGUID)
        elseif (objectGUID == kDeckTokenGUID) then
            table.insert(deckTypes, "K")
        elseif (objectGUID == eDeckTokenGUID) then
            table.insert(deckTypes, "E")
        elseif (objectGUID == iDeckTokenGUID) then
            table.insert(deckTypes, "I")
        elseif (objectGUID == startGameTokenGUID) then
            startGame = true
        end
    end
    
    print("Adjusting player count to " .. playerCount)
    setGlobalScriptVar("playerCount", playerCount)
    
    print("Adjusting deck types to '" .. table.toString(deckTypes, ",") .. "'")
    -- This is broken so we need to use other function at the moment
    -- setGlobalScriptTable(deckTypes, "deckTypes")
    callLuaFunctionInOtherScriptWithParams(nil, "setDeckTypes", deckTypes)
    
    if (startGame and not getGlobalScriptVar("gameStarted")) then
        print("Starting game")
        callLuaFunctionInOtherScript(nil, "initializeBoard")
    end
end


function updatePlayerCount(objectGUID)
    count = table.getKey(playerCountTokenGUIDs, objectGUID)
    if (count ~= nil and count > playerCount) then
        playerCount = count
    end
end

--[[ Event hooks ]] 

function onObjectEnterScriptingZone(zone, object)
    objectGUID = object.getGUID()

    if (zone.getGUID() ~= self.getGUID() or
        table.contains(objectGUIDsInTheZone, objectGUID)) then
        return
    end

    print("Object " .. object.getName() .. " type " .. object.name .. " GUID " .. objectGUID .. " entered Game Settings scripting zone")
    
    table.insert(objectGUIDsInTheZone, objectGUID)
    updateGameSettings()
end


function onObjectLeaveScriptingZone(zone, object)
    objectGUID = object.getGUID()

    if (zone.getGUID() ~= self.getGUID() or
        not table.contains(objectGUIDsInTheZone, objectGUID)) then
        return
    end
    
    print("Object " .. object.getName() .. " type " .. object.name .. " GUID " .. objectGUID .. " left Game Settings scripting zone")
    
    if (not table.removeByValue(objectGUIDsInTheZone, objectGUID)) then
        print("Object " .. object.getName() .. " GUID " .. objectGUID .. " was not in object GUIDs for this zone")
        return
    end

    updateGameSettings()
end


function onload()
    local playerCountButtonParameters = {}
    playerCountButtonParameters.click_function = "dummy"
    playerCountButtonParameters.label = ""
    playerCountButtonParameters.function_owner = nil
    playerCountButtonParameters.position = {0, -0.5, 0}
    playerCountButtonParameters.rotation = {180.0, 180.0, 0}
    playerCountButtonParameters.width = 0
    playerCountButtonParameters.height = 0
    playerCountButtonParameters.font_size = 180
    
    for i=1, 5, 1 do
        playerCountButtonParameters.label = (i .. ' Players')
        getObjectFromGUID(playerCountTokenGUIDs[i]).createButton(playerCountButtonParameters)
    end
    
    playerCountButtonParameters.label = "Start\nGame"
    getObjectFromGUID(startGameTokenGUID).createButton(playerCountButtonParameters)

    playerCountButtonParameters.label = "K\nDeck"
    getObjectFromGUID(kDeckTokenGUID).createButton(playerCountButtonParameters)

    playerCountButtonParameters.label = "E\nDeck"
    getObjectFromGUID(eDeckTokenGUID).createButton(playerCountButtonParameters)

    playerCountButtonParameters.label = "I\nDeck"
    getObjectFromGUID(iDeckTokenGUID).createButton(playerCountButtonParameters)
end
