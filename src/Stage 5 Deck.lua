--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload()
    print("Shuffling " .. self.getName() .. " cards")
    self.shuffle()
    
    self.takeCardFromDeck({13.5662766, 1.20532107, -3.49873352, 0.0, 180.0, 180.0}, false)
end
