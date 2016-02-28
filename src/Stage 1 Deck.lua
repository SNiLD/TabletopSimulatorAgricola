--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload()
    print("Shuffling " .. self.getName() .. " cards")
    self.shuffle()
    self.takeCardFromDeck({-2.63777614, 1.30030215, 0.194500551, 0.0, 180.0, 180.0}, true)
    self.takeCardFromDeck({0.397731841, 1.26712489, 0.03501895, 0.0, 180.0, 180.0}, false)
    self.takeCardFromDeck({0.316840023, 1.2755394, -4.122939, 0.0, 180.0, 180.0}, false)
end
