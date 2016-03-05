function dealOccupations(object)
    print("Shuffling occupations from deck " .. object.getName() .. " GUID " .. object.getGUID())
    
    object.shuffle()

    print("Dealing 7 occupations to each player")
    object.dealToAll(7)
end


function onObjectEnterScriptingZone(zone, object)
    if (zone.getGUID() ~= self.getGUID()) then
        return
    end
    
    if (object.name == "Deck" or object.name == "DeckCustom") then
        dealOccupations(object)
    end
end
