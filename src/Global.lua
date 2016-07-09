--[[ Helpers ]]

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
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


function table.isEmpty(table)
    if (table == nil) then
        return true
    end
    
    if (next(table) == nil) then
        return true
    end
    
    return false
end


function dummy()
end


--[[ Globals ]]


gameStarted = false
playerCount = 0
currentRoundNumber = 0
deckTypes = {}
playerColors = {}
actionsRemaining = {}
playerFarmScriptingZoneGUIDs = { White = "5f165b", Red = "f1ea9d", Green = "baae38", Blue = "f12186", Purple = "8e8f24" }
workerGUIDs =
{
    White = { "982e0c", "1d658c", "91230a", "339556", "8acc12" },
    Red = { "f5f9c6", "3adf43", "8c1ca6", "aed233", "e7f696" },
    Green = { "a8f720", "306232", "e3babc", "b57c85", "758634" },
    Blue = { "cc5517", "d8d05d", "6b18da", "7c565a", "35d880" },
    Purple = { "317185", "1da0ea", "96be86", "8898f4", "c1abc2" }
}
homeZoneGUIDs = { White = "cddcd1", Red = "9d9005", Green = "0f79a9", Blue = "b4d2b7", Purple = "d9e998"  }
resourceBagGUIDs = { Wood = "57458b", Clay = "8a147c", Stone = "c64ad7", Reed = "141313", Grain = "61fc77", Vegetable = "e7cb62", Food = "f249ab", Sheep = "f851b2", Boar = "e7b33c", Cattle = "f0c5e7" }
actionCardScriptingZoneGUIDs = { "26d1fc", "2a6c15", "0e1397", "0af55c", "c6e3f3", "8fdd38" }
actionBoardScriptingZoneGUIDs = { "a08297", "e9469a", "3a7f4d", "aa671d", "241264", "292428", "ac920e", "6e8819", "04f5b0", "e01044" }
actionRoundScriptingZoneGUIDs = { "8658b7", "fe050d", "ce9a11", "2cd64d", "833759", "ba2965", "5b711c", "b4381a", "5b99b7", "a2c5f0", "dce35e", "f62afb", "ccfdc4", "934f90" }
stage1CardDeckGUID = "77c9f7"
stage2CardDeckGUID = "ac1369"
stage3CardDeckGUID = "ceb91a"
stage4CardDeckGUID = "8f6c74"
stage5CardDeckGUID = "d78dfb"
kDeckBagGUID = "236391"
eDeckBagGUID = "5b947c"
iDeckBagGUID = "c4551b"
occupationDeckGUIDs = { "5fd15d", "ba39bf", "61f6d6", "5c1922", "eec2e8", "1e6207", "997c19", "9879ec", "e4d037" }
occupationShufflingZoneGUID = "d46db2"
minorImprovementDeckGUIDs = { "fd9eea", "aaa166", "6de5b0" }
minorImprovementShufflingZoneGUID = "286fa6"


--[[ These are hack functions because the API does not work correctly atm. ]]

function getObjectPositionTable(object, adjustment)
    local position = object.getPosition()
    result = {}
    positionKeys = {'x','y','z'}
    
    if (adjustment == nil) then
        result = { position['x'], position['y'], position['z'] }
    else
        for key, value in pairs(adjustment) do
            result[key] = position[positionKeys[key]] + value
        end
    end
    
    return result
end


function setDeckTypes(types)
    deckTypes = types
end


function lock(object, parameters)
    object.lock()
end

--[[ Private functions ]]


function dealCards(deck, rotation, positions)
    local parameters = {}
    parameters.rotation = rotation
    
    for _, position in pairs(positions) do
        parameters.position = position
        card = deck.takeObject(parameters)
        card.setPosition(position)
        card.setRotation(rotation)
    end
end


function initializeGameStage(stageCardDeckGUID, positions)
    stageCardDeck = getObjectFromGUID(stageCardDeckGUID)
    
    print("Shuffling " .. stageCardDeck.getName() .. " cards")
    stageCardDeck.shuffle()
    
    dealCards(stageCardDeck, {0.0, 180.0, 180.0}, positions)
end


function initializeFamilyBoard()
    mainBoard = getObjectFromGUID("7db9f8")
    boardBag = getObjectFromGUID("a11e39")
    local parameters = {}
    parameters.position = getObjectPositionTable(mainBoard, nil)
    parameters.rotation = {0.0, 180.0, 0.0}
    parameters.callback = "lock"
    parameters.params = {}
    mainBoard.unlock()
    mainBoard.setPositionSmooth(getObjectPositionTable(boardBag, {0.0, 1.5, 0.0}))
    familyBoard = boardBag.takeObject(parameters)
    familyBoard.setPosition(parameters.position)
end


function initializeGameStageCards()
    initializeGameStage(
        stage1CardDeckGUID,
        {
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[1]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[2]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[3]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[4]).getPosition()
        })
    initializeGameStage(
        stage2CardDeckGUID,
        {
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[5]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[6]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[7]).getPosition()
        })
    initializeGameStage(
        stage3CardDeckGUID,
        {
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[8]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[9]).getPosition()
        })
    initializeGameStage(
        stage4CardDeckGUID,
        {
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[10]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[11]).getPosition()
        })
    initializeGameStage(
        stage5CardDeckGUID,
        {
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[12]).getPosition(),
            getObjectFromGUID(actionRoundScriptingZoneGUIDs[13]).getPosition()
        })
end


function initializeActionCards(playerCount, isFamilyGame)
    print("Initializing player cards for " .. playerCount .. " players family mode " .. tostring(isFamilyGame))
    actionCards5Players = getObjectFromGUID("590540")
    actionCards4Players = getObjectFromGUID("2dd967")
    actionCards3Players = getObjectFromGUID("4bdd23")
    actionCardsBag = getObjectFromGUID("87e8b1")
    actionCardsBagPosition = getObjectPositionTable(actionCardsBag, {0.0, 1.5, 0.0})
    rotation = {0.0, 180.0, 0.0}
    
    if (isFamilyGame) then
        rotation[3] = 180.0
    end
    
    if (playerCount == 5) then
        actionCards4Players.setPositionSmooth(actionCardsBagPosition)
        actionCards3Players.setPositionSmooth(actionCardsBagPosition)
        dealCards(
            actionCards5Players,
            rotation,
            {
                {-13.1315432, 1.35851169,-8.331627},
                {-10.2916288, 1.35850871, 0.2497616},
                {-10.1748323, 1.35851026, -4.013337},
                {-10.298852, 1.35851181, -8.452009},
                {-13.19608, 1.35850859, 0.2789259},
                {-13.1250954, 1.35851014, -3.91666961}
            })
    elseif (playerCount == 4) then
        actionCards5Players.setPositionSmooth(actionCardsBagPosition)
        actionCards3Players.setPositionSmooth(actionCardsBagPosition)
        dealCards(
            actionCards4Players,
            rotation,
            {
                {-13.2538042, 1.35851169, -8.345971},
                {-10.3602352, 1.35850859, 0.282183915},
                {-10.3508177, 1.35851014, -4.06672955},
                {-10.3133535, 1.35851169, -8.395471},
                {-13.2757206, 1.35850871, 0.223956347},
                {-13.2007608, 1.35851014, -3.87375879}
            })
    elseif (playerCount == 3) then
        actionCards5Players.setPositionSmooth(actionCardsBagPosition)
        actionCards4Players.setPositionSmooth(actionCardsBagPosition)
        dealCards(
            actionCards3Players,
            rotation,
            {
                {-10.4203014, 1.35851014, -4.19282},
                {-10.407362, 1.35851181, -8.453454},
                {-13.1756124, 1.35851026, -4.16184473},
                {-13.2102251, 1.35851169, -8.382444}
            })
    elseif (playerCount == 2 or playerCount == 1) then
        actionCards5Players.setPositionSmooth(actionCardsBagPosition)
        actionCards4Players.setPositionSmooth(actionCardsBagPosition)
        actionCards3Players.setPositionSmooth(actionCardsBagPosition)
    end
end


function initializeOneOccupationType(isCorrect, playerCount, occupations1Player, occupations3Players, occupations4Players, occupationDeckPosition, occupationBagPosition)
    if (isCorrect) then
        occupations1Player.flip()
        occupations1Player.setPosition(occupationDeckPosition)
        
        if (playerCount >= 3) then
            occupations3Players.flip()
            occupations3Players.setPosition(occupationDeckPosition)
            
            if (playerCount >= 4) then
                occupations4Players.flip()
                occupations4Players.setPosition(occupationDeckPosition)
            else
                occupations4Players.setPositionSmooth(occupationBagPosition)
            end
        else
            occupations3Players.setPositionSmooth(occupationBagPosition)
            occupations4Players.setPositionSmooth(occupationBagPosition)
        end
    else
        occupations1Player.setPositionSmooth(occupationBagPosition)
        occupations3Players.setPositionSmooth(occupationBagPosition)
        occupations4Players.setPositionSmooth(occupationBagPosition)
    end
end


function initializeOccupations(playerCount, deckTypes)
    occupationShufflingZone = getObjectFromGUID(occupationShufflingZoneGUID)
    occupationDeckPosition = getObjectPositionTable(occupationShufflingZone, nil)
    
    initializeOneOccupationType(
        table.contains(deckTypes, "K"),
        playerCount,
        getObjectFromGUID(occupationDeckGUIDs[1]),
        getObjectFromGUID(occupationDeckGUIDs[2]),
        getObjectFromGUID(occupationDeckGUIDs[3]),
        occupationDeckPosition,
        getObjectPositionTable(getObjectFromGUID(kDeckBagGUID), {0.0, 1.5, 0.0}))
    
    initializeOneOccupationType(
        table.contains(deckTypes, "E"),
        playerCount,
        getObjectFromGUID(occupationDeckGUIDs[4]),
        getObjectFromGUID(occupationDeckGUIDs[5]),
        getObjectFromGUID(occupationDeckGUIDs[6]),
        occupationDeckPosition,
        getObjectPositionTable(getObjectFromGUID(eDeckBagGUID), {0.0, 1.5, 0.0}))
    
    initializeOneOccupationType(
        table.contains(deckTypes, "I"),
        playerCount,
        getObjectFromGUID(occupationDeckGUIDs[7]),
        getObjectFromGUID(occupationDeckGUIDs[8]),
        getObjectFromGUID(occupationDeckGUIDs[9]),
        occupationDeckPosition,
        getObjectPositionTable(getObjectFromGUID(iDeckBagGUID), {0.0, 1.5, 0.0}))
end


function initializeOneMinorImprovementType(isCorrect, minorImprovements, minorImprovementDeckPosition, minorImprovementBagPosition)
    if (isCorrect) then
        minorImprovements.flip()
        minorImprovements.setPosition(minorImprovementDeckPosition)
    else
        minorImprovements.setPositionSmooth(minorImprovementBagPosition)
    end
end


function initializeMinorImprovements(deckTypes)
    minorImprovementShufflingZone = getObjectFromGUID(minorImprovementShufflingZoneGUID)
    minorImprovementDeckPosition = getObjectPositionTable(minorImprovementShufflingZone, nil)
    
    initializeOneMinorImprovementType(
        table.contains(deckTypes, "K"),
        getObjectFromGUID(minorImprovementDeckGUIDs[1]),
        minorImprovementDeckPosition,
        getObjectPositionTable(getObjectFromGUID(kDeckBagGUID), {0.0, 1.5, 0.0}))
        
    initializeOneMinorImprovementType(
        table.contains(deckTypes, "E"),
        getObjectFromGUID(minorImprovementDeckGUIDs[2]),
        minorImprovementDeckPosition,
        getObjectPositionTable(getObjectFromGUID(eDeckBagGUID), {0.0, 1.5, 0.0}))
        
    initializeOneMinorImprovementType(
        table.contains(deckTypes, "I"),
        getObjectFromGUID(minorImprovementDeckGUIDs[3]),
        minorImprovementDeckPosition,
        getObjectPositionTable(getObjectFromGUID(iDeckBagGUID), {0.0, 1.5, 0.0}))
end


--[[ Global functions ]]


function initializeBoard()
    if (gameStarted) then
        print("Game already started.")
        return
    end
    
    gameStarted = true
    isFamilyGame = false
    
    players = getSeatedPlayers()
    
    if (playerCount < #players) then
        print("Game was setup for " .. playerCount .. " players but currently " .. #players .. " players seated. Adjusting for seated player count.")
        playerCount = #players
    end

    print("Initializing board for " .. playerCount .. " players with decks '" .. table.toString(deckTypes, ",") .. "'")
    
    if (next(deckTypes) == nil) then
        print("No decks were chosen, using family rules")
        isFamilyGame = true
        initializeFamilyBoard()
    end
    
    if (playerCount == 1) then
        -- In single player mode the 3-wood action space gets only 2 wood.
        woodScriptingZone = getObjectFromGUID("ac920e")
        zoneResources = woodScriptingZone.getTable("resources")
        zoneResources["Wood"] = 2
        woodScriptingZone.setTable("resources", zoneResources)
    end
    
    initializeGameStageCards()
    initializeActionCards(playerCount, isFamilyGame)
    initializeOccupations(playerCount, deckTypes)
    initializeMinorImprovements(deckTypes)
    startLuaCoroutine(nil, 'initializeWorkPhase')
end


function initializeWorkPhase()
    coroutine.yield(0)
    startRound()
    return 1
end


function setActionsRemaining(color, count)
    actionsRemaining[color] = count
end


function isEndOfRound()
    if (actionsRemaining == nil or next(actionsRemaining) == nil) then
        return true
    end

    for color, actions in pairs(actionsRemaining) do
        if (actions ~= nil and actions > 0) then
            print("Atleast player " .. color .. " still has " .. actions .. " actions")
            return false
        end
    end
    
    print("No player has turns remaining")
    return true
end


function returnWorker(object)
    guid = object.getGUID()
    for color, workerGUIDsForColor in pairs(workerGUIDs) do
        for _, workerGUID in pairs(workerGUIDsForColor) do
            if (guid == workerGUID) then
                homeZone = getObjectFromGUID(homeZoneGUIDs[color])
                object.setPositionSmooth(getObjectPositionTable(homeZone, nil))
                return
            end
        end
    end
end


function returnWorkersFromZone(zoneGUID)
    zone = getObjectFromGUID(zoneGUID)
    
    for _, object in pairs(zone.getObjects()) do
        returnWorker(object)
    end
end


function returnWorkers()
    print("Returning workers")
    
    for _, guid in pairs(actionCardScriptingZoneGUIDs) do
        returnWorkersFromZone(guid)
    end
    for _, guid in pairs(actionBoardScriptingZoneGUIDs) do
        returnWorkersFromZone(guid)
    end
    for _, guid in pairs(actionRoundScriptingZoneGUIDs) do
        returnWorkersFromZone(guid)
    end    
end


function flipNewRoundCard()
    print("Flipping new round card")
    zone = getObjectFromGUID(actionRoundScriptingZoneGUIDs[currentRoundNumber])
    for _, object in pairs(zone.getObjects()) do
        if (object.name == "Card") then
            object.setRotation({0.0, 180.0, 0.0})
        end
    end
end


function fillResourceToZone(zone, resources)
    zonePosition = getObjectPositionTable(zone, {0.0, 2.0, 0.0})
    for resource, amount in pairs(resources) do
        print("Adding " .. amount .. " " .. resource .. " to " .. zone.getName())
        resourceBag = getObjectFromGUID(resourceBagGUIDs[resource])
        print("Taking resources from " .. resourceBag.getName())
        local parameters = {}
        parameters.position = zonePosition
        parameters.rotation = {0.0, 0.0, 0.0}
        parameters.callback = ""
        parameters.params = {}
        for i = 1, amount, 1 do
            object = resourceBag.takeObject(parameters)
            object.setPosition(zonePosition)
        end
    end
end


function fillResourcesToZone(zoneGUID)
    zone = getObjectFromGUID(zoneGUID)
    print("Filling resources to zone " .. zone.getName())
    zoneResources = zone.getTable("resources")
    
    if (not table.isEmpty(zoneResources)) then
        fillResourceToZone(zone, zoneResources)
        return
    end
    
    for _, object in pairs(zone.getObjects()) do
        if (object.name == "Card") then
            print("Getting resources for card " .. object.getName())
            objectResources = object.getTable("resources")
            if (not table.isEmpty(objectResources)) then
                fillResourceToZone(zone, objectResources)
            end
        end
    end
end


function fillResources()
    print("Filling resources")
    
    for _, guid in pairs(actionCardScriptingZoneGUIDs) do
        fillResourcesToZone(guid)
    end
    for _, guid in pairs(actionBoardScriptingZoneGUIDs) do
        fillResourcesToZone(guid)
    end
    for roundNumber, guid in pairs(actionRoundScriptingZoneGUIDs) do
        if (roundNumber <= currentRoundNumber) then
            fillResourcesToZone(guid)
        end
    end    
end


function startRound()
    currentRoundNumber = currentRoundNumber + 1
    print("Starting round " .. currentRoundNumber)
    flipNewRoundCard()
    fillResources()
end


function endRound()
    print("Ending round " .. currentRoundNumber)
    returnWorkers()
end


function addAction(color)
    actionsRemaining[color] = actionsRemaining[color] + 1
    print("Adding action to player " .. color .. " player now has " .. actionsRemaining[color] .. " actions left")
end


function removeAction(color)
    actionsRemaining[color] = actionsRemaining[color] - 1
    print("Removing action from player " .. color .. " player now has " .. actionsRemaining[color] .. " actions left")
end


function getActions(color)
    count = 0
    farmGUID = playerFarmScriptingZoneGUIDs[color]
    farmZone = getObjectFromGUID(farmGUID)
    farmWorkerGUIDs = workerGUIDs[color]
    
    for _, object in pairs(farmZone.getObjects()) do
        if (table.contains(farmWorkerGUIDs, object.getGUID())) then
            count = count + 1
        end
    end
    
    return count
end


function updateActions()
    actionsRemaining = {}
    players = getSeatedPlayers()
    print("Updating remaining actions for " .. #players .. " players")
    for _, color in pairs(players) do
        actionsRemaining[color] = getActions(color)
    end
    
    for color, actions in pairs(actionsRemaining) do
        print("Player " .. color .. " has " .. actions .. " actions remaining")
    end
end


--[[ Even hooks ]]

function onObjectEnterScriptingZone(zone, object)
    for color, zoneGUID in pairs(playerFarmScriptingZoneGUIDs) do
        if (zoneGUID == zone.getGUID()) then
            for _, workerGUID in pairs(workerGUIDs[color]) do
                if (workerGUID == object.getGUID()) then
                    addAction(color)
                    return
                end
            end
        end
    end
end

function onObjectLeaveScriptingZone(zone, object)
    for color, zoneGUID in pairs(playerFarmScriptingZoneGUIDs) do
        if (zoneGUID == zone.getGUID()) then
            for _, workerGUID in pairs(workerGUIDs[color]) do
                if (workerGUID == object.getGUID()) then
                    removeAction(color)
                    return
                end
            end
        end
    end
end


-- function update()
-- end

function onload()
    updateActions()
end

function onPlayerTurnEnd(color)
    if (isEndOfRound()) then
        endRound()
        if (currentRoundNumber < 14) then
            startRound()
        end
    end
end

function onPlayerChangedColor(color)
    updateActions()
end
