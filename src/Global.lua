local inspect ={
  _VERSION = 'inspect.lua 3.0.2',
  _URL     = 'http://github.com/kikito/inspect.lua',
  _DESCRIPTION = 'human-readable representations of tables',
  _LICENSE = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

inspect.KEY       = setmetatable({}, {__tostring = function() return 'inspect.KEY' end})
inspect.METATABLE = setmetatable({}, {__tostring = function() return 'inspect.METATABLE' end})

-- returns the length of a table, ignoring __len (if it exists)
local rawlen = _G.rawlen or function(t) return #t end

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
    return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", controlCharsTranslation)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isSequenceKey(k, length)
  return type(k) == 'number'
     and 1 <= k
     and k <= length
     and math.floor(k) == k
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

local function getNonSequentialKeys(t)
  local keys, length = {}, rawlen(t)
  for k,_ in pairs(t) do
    if not isSequenceKey(k, length) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
    ok, str = pcall(__tostring, t)
    str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
    rawset(self, typeName, 0)
    return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
    local col = {}
    rawset(self, typeName, col)
    return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or {}

  if type(t) == 'table' then
    if not tableAppearances[t] then
      tableAppearances[t] = 1
      for k,v in pairs(t) do
        countTableAppearances(k, tableAppearances)
        countTableAppearances(v, tableAppearances)
      end
      countTableAppearances(getmetatable(t), tableAppearances)
    else
      tableAppearances[t] = tableAppearances[t] + 1
    end
  end

  return tableAppearances
end

local copySequence = function(s)
  local copy, len = {}, #s
  for i=1, len do copy[i] = s[i] end
  return copy, len
end

local function makePath(path, ...)
  local keys = {...}
  local newPath, len = copySequence(path)
  for i=1, #keys do
    newPath[len + i] = keys[i]
  end
  return newPath
end

local function processRecursive(process, item, path)
  if item == nil then return nil end

  local processed = process(item, path)
  if type(processed) == 'table' then
    local processedCopy = {}
    local processedKey

    for k,v in pairs(processed) do
      processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY))
      if processedKey ~= nil then
        processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
      end
    end

    local mt  = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE))
    setmetatable(processedCopy, mt)
    processed = processedCopy
  end
  return processed
end


-------------------------------------------------------------------

local Inspector = {}
local Inspector_mt = {__index = Inspector}

function Inspector:puts(...)
  local args   = {...}
  local buffer = self.buffer
  local len    = #buffer
  for i=1, #args do
    len = len + 1
    buffer[len] = tostring(args[i])
  end
end

function Inspector:down(f)
  self.level = self.level + 1
  f()
  self.level = self.level - 1
end

function Inspector:tabify()
  self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
  return self.ids[type(v)][v] ~= nil
end

function Inspector:getId(v)
  local tv = type(v)
  local id = self.ids[tv][v]
  if not id then
    id              = self.maxIds[tv] + 1
    self.maxIds[tv] = id
    self.ids[tv][v] = id
  end
  return id
end

function Inspector:putKey(k)
  if isIdentifier(k) then return self:puts(k) end
  self:puts("[")
  self:putValue(k)
  self:puts("]")
end

function Inspector:putTable(t)
  if t == inspect.KEY or t == inspect.METATABLE then
    self:puts(tostring(t))
  elseif self:alreadyVisited(t) then
    self:puts('<table ', self:getId(t), '>')
  elseif self.level >= self.depth then
    self:puts('{...}')
  else
    if self.tableAppearances[t] > 1 then self:puts('<', self:getId(t), '>') end

    local nonSequentialKeys = getNonSequentialKeys(t)
    local length            = rawlen(t)
    local mt                = getmetatable(t)
    local toStringResult    = getToStringResultSafely(t, mt)

    self:puts('{')
    self:down(function()
      if toStringResult then
        self:puts(' -- ', escape(toStringResult))
        if length >= 1 then self:tabify() end
      end

      local count = 0
      for i=1, length do
        if count > 0 then self:puts(',') end
        self:puts(' ')
        self:putValue(t[i])
        count = count + 1
      end

      for _,k in ipairs(nonSequentialKeys) do
        if count > 0 then self:puts(',') end
        self:tabify()
        self:putKey(k)
        self:puts(' = ')
        self:putValue(t[k])
        count = count + 1
      end

      if mt then
        if count > 0 then self:puts(',') end
        self:tabify()
        self:puts('<metatable> = ')
        self:putValue(mt)
      end
    end)

    if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
      self:tabify()
    elseif length > 0 then -- array tables have one extra space before closing }
      self:puts(' ')
    end

    self:puts('}')
  end
end

function Inspector:putValue(v)
  local tv = type(v)

  if tv == 'string' then
    self:puts(smartQuote(escape(v)))
  elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
    self:puts(tostring(v))
  elseif tv == 'table' then
    self:putTable(v)
  else
    self:puts('<',tv,' ',self:getId(v),'>')
  end
end

-------------------------------------------------------------------

function inspect.inspect(root, options)
  options       = options or {}

  local depth   = options.depth   or math.huge
  local newline = options.newline or '\n'
  local indent  = options.indent  or '  '
  local process = options.process

  if process then
    root = processRecursive(process, root, {})
  end

  local inspector = setmetatable({
    depth            = depth,
    buffer           = {},
    level            = 0,
    ids              = setmetatable({}, idsMetaTable),
    maxIds           = setmetatable({}, maxIdsMetaTable),
    newline          = newline,
    indent           = indent,
    tableAppearances = countTableAppearances(root)
  }, Inspector_mt)

  inspector:putValue(root)

  return table.concat(inspector.buffer)
end

setmetatable(inspect, { __call = function(_, ...) return inspect.inspect(...) end })

function split(str, delim)
    local result,pat,lastPos = {},"(.-)" .. delim .. "()",1
    for part, pos in string.gfind(str, pat) do
        table.insert(result, part); lastPos = pos
    end
    table.insert(result, string.sub(str, lastPos))
    return result
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function initializeActionCards(playerCount)
    print("Initializing player cards for " .. playerCount .. " players")
    actionCards5Players = getObjectFromGUID("590540")
    actionCards4Players = getObjectFromGUID("2dd967")
    actionCards3Players = getObjectFromGUID("4bdd23")
    actionCardsBag = getObjectFromGUID("87e8b1")
    local actionCardsPositionTemp = actionCardsBag.getPosition()
    actionCardsBagPosition = { actionCardsPositionTemp['x'], actionCardsPositionTemp['y'] + 1.5, actionCardsPositionTemp['z'] }
    
    if (playerCount == 5) then
        actionCards4Players.setPositionSmooth(actionCardsBagPosition)
        actionCards3Players.setPositionSmooth(actionCardsBagPosition)
        
        actionCards5Players.setPosition({-13.1250954, 1.35851014, -3.91666961})
        actionCards5Players.takeCardFromDeck({-13.1315432, 1.35851169,-8.331627, 0.0, 180.0, 0.0}, false)        
        actionCards5Players.takeCardFromDeck({-10.2916288, 1.35850871, 0.2497616, 0.0, 180.0, 0.0}, false)
        actionCards5Players.takeCardFromDeck({-10.1748323, 1.35851026, -4.013337, 0.0, 180.0, 0.0}, false)
        actionCards5Players.takeCardFromDeck({-10.298852, 1.35851181, -8.452009, 0.0, 180.0, 0.0}, false)
        actionCards5Players.takeCardFromDeck({-13.19608, 1.35850859, 0.2789259, 0.0, 180.0, 0.0}, false)
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
        occupations1Player.setPosition(occupationDeckPosition)
        
        if (playerCount >= 3) then
            occupations3Players.setPosition(occupationDeckPosition)
            
            if (playerCount >= 4) then
                occupations4Players.setPosition(occupationDeckPosition)
            else
                occupations4Players.setPosition(occupationBagPosition)
            end
        else
            occupations3Players.setPosition(occupationBagPosition)
            occupations4Players.setPosition(occupationBagPosition)
        end
    else
        occupations1Player.setPosition(occupationBagPosition)
        occupations3Players.setPosition(occupationBagPosition)
        occupations4Players.setPosition(occupationBagPosition)
    end
end


function initializeOccupations(playerCount, deckTypes)
    occupationDeckPosition = { -16.7445259, 1.02870941, 4.87904072 }
    -- occupationsDeck = spawnObject('CustomDeck', occupationDeckPosition)
    
    kOccupationDeckBag = getObjectFromGUID("236391")
    local kOccupationDeckBagPositionTemp = kOccupationDeckBag.getPosition()
    kOccupationDeckBagPosition = { kOccupationDeckBagPositionTemp['x'], kOccupationDeckBagPositionTemp['y'], kOccupationDeckBagPositionTemp['z'] }
    
    eOccupationDeckBag = getObjectFromGUID("5b947c")
    local eOccupationDeckBagPositionTemp = eOccupationDeckBag.getPosition()
    eOccupationDeckBagPosition = { eOccupationDeckBagPositionTemp['x'], eOccupationDeckBagPositionTemp['y'] + 1.5, eOccupationDeckBagPositionTemp['z'] }
    
    iOccupationDeckBag = getObjectFromGUID("c4551b")
    local iOccupationDeckBagPositionTemp = iOccupationDeckBag.getPosition()
    iOccupationDeckBagPosition = { iOccupationDeckBagPositionTemp['x'], iOccupationDeckBagPositionTemp['y'] + 1.5, iOccupationDeckBagPositionTemp['z'] }
    
    occupationDeckGUIDs = { "5fd15d", "ba39bf", "61f6d6", "5c1922", "eec2e8", "1e6207", "997c19", "9879ec", "e4d037" }
    
    kOccupations1Player = getObjectFromGUID(occupationDeckGUIDs[1])
    kOccupations3Players = getObjectFromGUID(occupationDeckGUIDs[2])
    kOccupations4Players = getObjectFromGUID(occupationDeckGUIDs[3])
    eOccupations1Player = getObjectFromGUID(occupationDeckGUIDs[4])
    eOccupations3Players = getObjectFromGUID(occupationDeckGUIDs[5])
    eOccupations4Players = getObjectFromGUID(occupationDeckGUIDs[6])
    iOccupations1Player = getObjectFromGUID(occupationDeckGUIDs[7])
    iOccupations3Players = getObjectFromGUID(occupationDeckGUIDs[8])
    iOccupations4Players = getObjectFromGUID(occupationDeckGUIDs[9])
    
    initializeOneOccupationType(
        table.contains(deckTypes, "K"),
        playerCount,
        kOccupations1Player,
        kOccupations3Players,
        kOccupations4Players,
        occupationDeckPosition,
        kOccupationDeckBagPosition)
    
    initializeOneOccupationType(
        table.contains(deckTypes, "E"),
        playerCount,
        eOccupations1Player,
        eOccupations3Players,
        eOccupations4Players,
        occupationDeckPosition,
        eOccupationDeckBagPosition)
    
    initializeOneOccupationType(
        table.contains(deckTypes, "I"),
        playerCount,
        iOccupations1Player,
        iOccupations3Players,
        iOccupations4Players,
        occupationDeckPosition,
        iOccupationDeckBagPosition)

    -- Decks will merge and only one of the GUIDs will remain after the merger so lets find it.
    occupationDeck = nil
    for _,occupationDeckGUID in pairs(occupationDeckGUIDs) do
        occupationDeck = getObjectFromGUID(occupationDeckGUID)
        
        if (occupationDeck ~= nil) then
            break
        end
    end
    
    if (occupationDeck == nil) then
        print("No occupation decks")
    else
        print("Found occupation deck with GUID " .. occupationDeck.getGUID())
        print("Shuffling occupations")
        occupationDeck.shuffle()
        occupationDeck.flip()
    end
end


function initializeBoard(playerCount, deckTypes)
    print("Initializing board for " .. playerCount .. " players")
    initializeActionCards(playerCount)
    initializeOccupations(playerCount, deckTypes)
end

function initializeWorkPhase()
end

--[[ The OnLoad function. Called when a game finishes loading. ]]
function onload ()
    notes = {}
    for variable, value in string.gmatch(getNotes(), "([%w_]+)=([%w,]+)[\n]*") do
        notes[variable] = value
    end
    
    print(inspect(notes))
    
    players = getSeatedPlayers()
    deckTypes = {"K", "E", "I"}
    
    playerCount = #players
    
    if (notes["player_count"] ~= nil) then
        playerCount = tonumber(notes["player_count"])
    end
    
    if (notes["deck_types"] ~= nil) then
        deckTypes = {}
        for value in string.gmatch(notes["deck_types"], "(%w+)[,$]?") do
            table.insert(deckTypes, string.upper(value))
        end
    end
    
    print("Setup for " .. playerCount .. " players with " .. inspect(deckTypes) .. " decks")
    
    initializeBoard(playerCount, deckTypes)
end
