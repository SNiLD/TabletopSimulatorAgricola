--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload()
    print("Shuffling " .. self.getName() .. " cards")
    self.shuffle()
    
    self.takeCardFromDeck({10.4956465, 1.205321, -3.554801, 0.0, 180.0, 180.0}, false)
end
