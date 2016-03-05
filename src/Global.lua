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


function dummy()
end


--[[ Globals ]]


gameStarted = false
playerCount = 0
deckTypes = {}
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

--[[ Private functions ]]


function initializeGameStage(stageCardDeckGUID, positions)
    local parameters = {}
    parameters.position = {}
    parameters.rotation = {0.0, 180.0, 180.0}
    parameters.callback = ""
    parameters.params = {}
    
    stageCardDeck = getObjectFromGUID(stageCardDeckGUID)
    
    print("Shuffling " .. stageCardDeck.getName() .. " cards")
    stageCardDeck.shuffle()
    
    for _, position in pairs(positions) do
        parameters.position = position
        stageCardDeck.takeObject(parameters)        
    end
end


function initializeGameStageCards()
    initializeGameStage(
        stage1CardDeckGUID,
        {
            {-2.63777614, 1.30030215, 0.194500551},
            {0.397731841, 1.26712489, 0.03501895},
            {0.316840023, 1.2755394, -4.122939}
        })
    initializeGameStage(
        stage2CardDeckGUID,
        {
            {3.30984449, 1.231528, 0.00103998382},
            {3.24591732, 1.23985708, -4.213084}
        })
    initializeGameStage(
        stage3CardDeckGUID,
        {
            {7.650797, 1.205321, -3.60009027}
        })
    initializeGameStage(
        stage4CardDeckGUID,
        {
            {10.4956465, 1.205321, -3.554801}
        })
    initializeGameStage(
        stage5CardDeckGUID,
        {
            {13.5662766, 1.20532107, -3.49873352}
        })
end


function initializeActionCards(playerCount)
    print("Initializing player cards for " .. playerCount .. " players")
    actionCards5Players = getObjectFromGUID("590540")
    actionCards4Players = getObjectFromGUID("2dd967")
    actionCards3Players = getObjectFromGUID("4bdd23")
    actionCardsBag = getObjectFromGUID("87e8b1")
    actionCardsBagPosition = getObjectPositionTable(actionCardsBag, {0.0, 1.5, 0.0})
    
    if (playerCount == 5) then
        actionCards4Players.setPositionSmooth(actionCardsBagPosition)
        actionCards3Players.setPositionSmooth(actionCardsBagPosition)
        
        actionCards5Players.setPosition({-13.1250954, 1.35851014, -3.91666961})
        
        local parameters = {}
        parameters.position = {-13.1315432, 1.35851169,-8.331627}
        parameters.rotation = {0.0, 180.0, 0.0}
        parameters.callback = ""
        parameters.params = {}
        
        actionCards5Players.takeObject(parameters)
        parameters.position = {-10.2916288, 1.35850871, 0.2497616}
        actionCards5Players.takeObject(parameters)
        parameters.position = {-10.1748323, 1.35851026, -4.013337}
        actionCards5Players.takeObject(parameters)
        parameters.position = {-10.298852, 1.35851181, -8.452009}
        actionCards5Players.takeObject(parameters)
        parameters.position = {-13.19608, 1.35850859, 0.2789259}
        actionCards5Players.takeObject(parameters)
    elseif (playerCount == 4) then
    elseif (playerCount == 3) then
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
    
    players = getSeatedPlayers()
    
    if (playerCount < #players) then
        print("Game was setup for " .. playerCount .. " players but currently " .. #players .. " players seated. Adjusting for seated player count.")
        playerCount = #players
    end

    print("Initializing board for " .. playerCount .. " players with decks '" .. table.toString(deckTypes, ",") .. "'")
    initializeGameStageCards()
    initializeActionCards(playerCount)
    initializeOccupations(playerCount, deckTypes)
    initializeMinorImprovements(deckTypes)
end


function initializeWorkPhase()
end


function dealOccupations(object)
    print("Shuffling occupations from deck " .. object.getName() .. " GUID " .. object.getGUID())
    
    object.shuffle()

    print("Dealing 7 occupations to each player")
    object.dealToAll(7)
end


function dealMinorImprovements(object)
    print("Shuffling minor improvements from deck " .. object.getName() .. " GUID " .. object.getGUID())
    
    object.shuffle()

    print("Dealing 7 minor improvements to each player")
    object.dealToAll(7)
end


--[[ Even hooks ]]

function onObjectEnterScriptingZone(zone, object)
    print("Object " .. object.getName() .. " type " .. object.name .. " GUID " .. object.getGUID() .. " entered Zone " .. zone.getName() .. " GUID " .. zone.getGUID())
    if (zone.getGUID() == occupationShufflingZoneGUID and (object.name == "Deck" or object.name == "DeckCustom")) then
        dealOccupations(object)
    elseif (zone.getGUID() == minorImprovementShufflingZoneGUID and (object.name == "Deck" or object.name == "DeckCustom")) then
        dealMinorImprovements(object)
    end
end

function onObjectLeaveScriptingZone(zone, object)
    print("Object " .. object.getName() .. " type " .. object.name .. " GUID " .. object.getGUID() .. " left Zone " .. zone.getName() .. " GUID " .. zone.getGUID())
end


-- function update()
-- end

function onload()
end
