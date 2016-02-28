--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload()
    print("Shuffling " .. self.getName() .. " cards")
    self.shuffle()
    
    self.takeCardFromDeck({3.30984449, 1.231528, 0.00103998382, 0.0, 180.0, 180.0}, false)
    self.takeCardFromDeck({3.24591732, 1.23985708, -4.213084, 0.0, 180.0, 180.0}, false)
end
