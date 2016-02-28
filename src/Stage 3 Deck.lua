--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload()
    print("Shuffling " .. self.getName() .. " cards")
    self.shuffle()
    
    self.takeCardFromDeck({7.650797, 1.205321, -3.60009027, 0.0, 180.0, 180.0}, false)
end
