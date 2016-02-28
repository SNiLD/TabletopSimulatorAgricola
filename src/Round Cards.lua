--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload ()
    local params = {}
    self.takeObject({16.55193, 1.20887554, -8.339854, 0.0, 180.0, 180.0}, 'stageDeckCallback', params)
end

--[[ Callback for taking objects from infinite bag since it takes a few frames for the object to be created and initialized. ]]
function stageDeckCallback(spawnedDeck, params)
    self.callLuaFunctionInOtherScript(spawnedDeck, "onLoad")
end
