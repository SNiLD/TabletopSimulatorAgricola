function dealMinorImprovements(object)
    print("Shuffling minor improvements from deck " .. object.getName() .. " GUID " .. object.getGUID())
    
    object.shuffle()

    print("Dealing 7 minor improvements to each player")
    object.dealToAll(7)
end


--[[ Even hooks ]]

function onObjectEnterScriptingZone(zone, object)
    if (zone.getGUID() ~= self.getGUID()) then
        return
    end
    
    if (object.name == "Deck" or object.name == "DeckCustom") then
        dealMinorImprovements(object)
    end
end
