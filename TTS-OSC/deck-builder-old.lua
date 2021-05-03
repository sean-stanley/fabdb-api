--[[

FaB Deck Builder
Created by David Owens @ Owens Satisfactory Cards (satifsactorycards.com).

Currently, there are two ways to import a deck:
  1. JSON output from FaB DB
  2. JSON output from thepitchzone.com (thanks @Ever)

These follow the format defined here: https://gist.github.com/owensd/af086ac73d2b3692558ed804865fa319

--]]

deck_builder_input = nil

-- The GUID of the deck that contains the 'All Cards' deck. THIS MUST NOT CHANGE.
ALL_CARDS_DECK_GUID = "8b701f"
all_cards_deck_ref = nil
spawning_deck = false

function onLoad()
  math.randomseed(os.time())

  -- Generate the dynamic UI for the deck builder.
  createDeckUI()

  -- The reference to all of the cards to spawn from.
  all_cards_deck_ref = getObjectFromGUID(ALL_CARDS_DECK_GUID)
  if all_cards_deck_ref == nil then
    broadcastToAll("unable to find the 'All Cards' deck.")
    return
  end
end

function createDeckUI()
  -- Create the text input. This is for the deck ID or the raw CSV.
  local text_params = {
    input_function = "onDeckInputChanged",
    function_owner = self,
    position = {-2.75,0.2,0.3},
    width = 250,
    height = 80,
    font_size = 40,
    tooltip = "Enter the full URL (any deck builder supporting OSC) or the unique ID of the deck from fabdb.net.",
    alignment = 3
  }
  self.createInput(text_params)

  -- Make button to start import process
  local btn_params = {
    click_function = "onCreateDeckButtonPressed",
    function_owner = self,
    position = {-3.2,-0.2,0.6},
    width = 300,
    height = 150,
    tooltip = "Click to import deck"
  }
  self.createButton(btn_params)

  -- Create the buttons for simulated sealed play:
  local wtr_params = {
    click_function = "onCreateSimulatedDeckButtonPressed_WTR",
    function_owner = self,
    position = {-3.45,-0.2,-0.65},
    width = 170,
    height = 80,
    colors = "white|white|white|white",
    tooltip = "Spawn Welcome to Rathe Pack"
  }
  self.createButton(wtr_params)
  local arc_params = {
    click_function = "onCreateSimulatedDeckButtonPressed_ARC",
    function_owner = self,
    position = {-3.05,-0.2,-0.65},
    width = 170,
    height = 80,
    colors = "white|white|white|white",
    tooltip = "Spawn Arcane Rising Pack"
  }
  self.createButton(arc_params)
  local cru_params = {
    click_function = "onCreateSimulatedDeckButtonPressed_CRU",
    function_owner = self,
    position = {-2.65,-0.2,-0.65},
    width = 170,
    height = 80,
    colors = "white|white|white|white",
    tooltip = "Spawn Crucible of War Pack (not out yet!)"
  }
  self.createButton(cru_params)
end

function onDeckInputChanged(ref, player, value)
  deck_builder_input = value
end

function onCreateDeckButtonPressed(ref, player)
  -- It would be better for different providers to register themselves here... but alas.
  if string.find(deck_builder_input, "fabdb.net") != nil then
    fabdb_createDeckFromAPI(deck_builder_input)
  elseif string.find(deck_builder_input, "thepitchzone.com") != nil then
    osc_getDeckFromURL(deck_builder_input)
  else
    -- assume fabdb for now, allow for a special handling of IDs as well?
    fabdb_createDeckFromURL(deck_builder_input)
  end
end

function findCardInDeck(deck, identifier)
  local cards = deck.getObjects()
  for k,v in pairs(cards) do
    if v.description:lower() == identifier:lower() then
      return k - 1
    end
  end

  return -1
end

function spawnCard(deck, identifier, position, rotation)
  -- The cards are found by their identifier, which is in the description of the object.
  local cards = deck.getObjects()
  for k,v in pairs(cards) do
    if v.description:lower() == identifier:lower() then
      -- Grab the card from the deck.
      local new_card = deck.takeObject({
        index = k-1,
        position = position,
        rotation = rotation,
        smooth = false
      })

      -- Put the card back into the deck so it can be found again later.
      deck.putObject(new_card.clone({position = all_cards_deck_ref.getPosition()}))

      -- Return the instance. Note that this instance may not be fully spawned in the game world yet.
      return new_card
    end
  end

  -- The function should return before this is hit if the card is found.
  broadcastToAll("Unable to find card: " .. identifier)
end

SPAWN_BASELINE_LEFT = -5.55
SPAWN_BASELINE_ZOFF = (5.55 - 1.85)
SPAWN_BASELINE_XOFF = -0.25
SPAWN_HEIGHT = 1.25
CARD_HEIGHT_OFFSET = 0.2

function spawnPack(pack)
  -- Spawn each of the cards, offsetting them to ensure the ordering can be maintained.
  for n, card_id in pairs(pack) do
    spawnPackCard(all_cards_deck_ref, card_id, n)
  end
end

function spawnPackCard(deck, card, card_number)
  local pos = self.getPosition()
  local position = { x=pos.x + SPAWN_BASELINE_XOFF, y=pos.y + SPAWN_HEIGHT + (card_number * CARD_HEIGHT_OFFSET), z=pos.z + SPAWN_BASELINE_LEFT + (SPAWN_BASELINE_ZOFF * 0) }
  local rotation = { x=0, y=90, z=180 }
  return spawnCard(deck, card, position, rotation)
end

function spawnHero(deck, card, card_number)
  local pos = self.getPosition()
  local position = { x=pos.x + SPAWN_BASELINE_XOFF, y=pos.y + SPAWN_HEIGHT + (card_number * CARD_HEIGHT_OFFSET), z=pos.z + SPAWN_BASELINE_LEFT + (SPAWN_BASELINE_ZOFF * 0) }
  local rotation = { x=0, y=90, z=0 }
  return spawnCard(deck, card, position, rotation)
end

function spawnWeapon(deck, card, card_number)
  local pos = self.getPosition()
  local position = { x=pos.x + SPAWN_BASELINE_XOFF, y=pos.y + SPAWN_HEIGHT + (card_number * CARD_HEIGHT_OFFSET), z=pos.z + SPAWN_BASELINE_LEFT + (SPAWN_BASELINE_ZOFF * 1) }
  local rotation = { x=0, y=90, z=180 }
  spawnCard(deck, card, position, rotation)
end

function spawnEquipment(deck, card, card_number)
  local pos = self.getPosition()
  local position = { x=pos.x + SPAWN_BASELINE_XOFF, y=pos.y + SPAWN_HEIGHT + (card_number * CARD_HEIGHT_OFFSET), z=pos.z + SPAWN_BASELINE_LEFT + (SPAWN_BASELINE_ZOFF * 2) }
  local rotation = { x=0, y=90, z=180 }
  spawnCard(deck, card, position, rotation)
end

function spawnDeck(deck, card, card_number)
  local pos = self.getPosition()
  local position = { x=pos.x + SPAWN_BASELINE_XOFF, y=pos.y + SPAWN_HEIGHT + (card_number * CARD_HEIGHT_OFFSET), z=pos.z + SPAWN_BASELINE_LEFT + (SPAWN_BASELINE_ZOFF * 3) }
  local rotation = { x=0, y=90, z=180 }
  spawnCard(deck, card, position, rotation)
end

function spawnSideboard(deck, card, card_number)
  local pos = self.getPosition()
  local position = { x=pos.x + SPAWN_BASELINE_XOFF, y=pos.y + SPAWN_HEIGHT + (card_number * CARD_HEIGHT_OFFSET), z=pos.z + SPAWN_BASELINE_LEFT + (SPAWN_BASELINE_ZOFF * 4) }
  local rotation = { x=0, y=90, z=180 }
  spawnCard(deck, card, position, rotation)
end

function sanitizeJSON(text)
  -- Handle the unicode apostophes...
  local result = string.gsub(text, "‘", "'")
  result = string.gsub(result, "’", "'")
  result = string.gsub(result, "\\u2018", "'")
  return result
end

function onCreateSimulatedDeckButtonPressed_WTR()
  local box = wtr_boxes[math.random(1, 80)]
  local pack = box[math.random(1, 24)]
  spawnPack(pack)
end

function onCreateSimulatedDeckButtonPressed_ARC()
  local box = arc_boxes[math.random(1, 80)]
  local pack = box[math.random(1, 24)]
  spawnPack(pack)
end

function onCreateSimulatedDeckButtonPressed_CRU()
  print("Spawning CRU packs is not yet supported.")
end

--[[

Standard Deck Loading Methods for OSC format.

]]--

function osc_getDeckFromURL(deck_url)
  if spawning_deck then
    return
  end
  spawning_deck = true
  WebRequest.get(deck_url, osc_loadDeck)
end

function osc_loadDeck(resp)
  local json = sanitizeJSON(resp.text)
  if type(json) != "string" or json:sub(1, 1) != "{" then
    broadcastToAll("Unable to retrieve data from URL: " .. deck_builder_input)
    spawning_deck = false
    return
  end

  local deck = JSON.decode(json)
  if deck == nil then
    broadcastToAll("Deck JSON format invalid.")
    spawning_deck = false
    return
  end
  if deck.weapons == nil and deck.equipment == nil and deck.maindeck == nil then
    broadcastToAll("Deck does not have cards.")
    spawning_deck = false
    return
  end

  local n_heroes = 1
  local n_weapons = 1
  local n_equipment = 1
  local n_deck = 1
  local n_sideboard = 1

  spawnHero(all_cards_deck_ref, deck.hero_id, n_heroes)
  n_heroes = n_heroes + 1
  for _, card in pairs(deck.weapons) do
    local num_to_spawn = card.count or 1
    for _ = 1, num_to_spawn do
      spawnWeapon(all_cards_deck_ref, card.id, n_weapons)
      n_weapons = n_weapons + 1
    end
  end
  for _, card in pairs(deck.equipment) do
    local num_to_spawn = card.count or 1
    for _ = 1, num_to_spawn do
      spawnEquipment(all_cards_deck_ref, card.id, n_equipment)
      n_equipment = n_equipment + 1
    end
  end
  for _, card in pairs(deck.maindeck) do
    local num_to_spawn = card.count or 1
    for _ = 1,num_to_spawn do
      spawnDeck(all_cards_deck_ref, card.id, n_deck)
      n_deck = n_deck + 1
    end
  end
  for _, card in pairs(deck.sideboard) do
    local num_to_spawn = card.count or 1
    for _ = 1,num_to_spawn do
      spawnSideboard(all_cards_deck_ref, card.id, n_sideboard)
      n_sideboard = n_sideboard + 1
    end
  end

  spawning_deck = false
end

--[[

FaB DB Parsing Methods.

]]--

function fabdb_packRetrieved(resp)
  local json = sanitizeJSON(resp.text)
  local info = JSON.decode(json)
  if info == nil then
    broadcastToAll("Unable to load pack for set.")
    return
  end

  -- First, find out if there are any duplicate cards. Doing this means the temporary deck does not need to be created multiple times.
  local cards = {}

  for _, card in pairs(info) do
    if cards[card.identifier] == nil then
      cards[card.identifier] = 1
    else
      cards[card.identifier] = cards[card.identifier] + 1
    end
  end

  local count = 0
  local base_deck = nil
  -- Spawn the cards!
  for key, num in pairs(cards) do
    spawnPackCard(all_cards_deck_ref, key, num, count)
    count = count + 1
  end
end

function fabdb_deckRetrieved(resp)
  local json = sanitizeJSON(resp.text)
  if type(json) != "string" or json:sub(1, 1) != "{" then
    broadcastToAll("Unable to retrieve deck from: " .. deck_builder_input)
    spawning_deck = false
    return
  end

  local info = JSON.decode(json)
  if info == nil then
    broadcastToAll("Unable to load deck from ID.")
    spawning_deck = false
    return
  end
  if info.cards == nil then
    broadcastToAll("JSON does not have a cards collection.")
    spawning_deck = false
    return
  end

  local n_heroes = 1
  local n_weapons = 1
  local n_equipment = 1
  local n_deck = 1
  local n_sideboard = 1

  -- fabdb has _all_ cards the cards in `info.cards`. This table stores the `card.identifier` and the number of
  -- instances contained in the sideboard.
  local in_sideboard = {}

  -- Load up the sideboard.
  for _, card in pairs(info.sideboard) do
    in_sideboard[card.identifier] = card.total

    for _ = 1,card.total do
      spawnSideboard(all_cards_deck_ref, card.identifier, n_sideboard)
      n_sideboard = n_sideboard + 1
    end
  end

  -- Spawn the cards!
  for _, card in pairs(info.cards) do
    local num_in_sideboard = in_sideboard[card.identifier]
    if num_in_sideboard == nil then
      num_in_sideboard = 0
    end
    local num_to_spawn = card.total - num_in_sideboard

    for _ = 1,num_to_spawn do
      if table.contains(card.keywords, "hero") then
        spawnHero(all_cards_deck_ref, card.identifier, n_heroes)
        n_heroes = n_heroes + 1
      elseif table.contains(card.keywords, "weapon") then
        spawnWeapon(all_cards_deck_ref, card.identifier, n_weapons)
        n_weapons = n_weapons + 1
      elseif table.contains(card.keywords, "equipment") then
        spawnEquipment(all_cards_deck_ref, card.identifier, n_equipment)
        n_equipment = n_equipment + 1
      else
        spawnDeck(all_cards_deck_ref, card.identifier, n_deck)
        n_deck = n_deck + 1
      end
    end
  end



  spawning_deck = false
end

function fabdb_createDeckFromAPI(deck_url_or_id)
  if spawning_deck then
    return
  end

  if deck_url_or_id == nil then
    return
  end

  -- Support the full URL or just the deck ID
  deck_url_or_id = deck_url_or_id:trim()
  if deck_url_or_id == "" then
    return
  end

  local deck_id = ""
  local s_index = string.find(deck_url_or_id, "/[^/]*$")
  if s_index == nil then
    deck_id = deck_url_or_id
  else
    deck_id = deck_url_or_id:sub(s_index + 1)
  end

  local fabdb_url = "https://api.fabdb.net/decks/" .. deck_id .. "/osc"
  osc_getDeckFromURL(fabdb_url)
end


--[[
  Table helpers.
]]
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

--[[
  String helpers.
]]

function string.trim(s)
  -- source: http://lua-users.org/wiki/StringTrim
   local from = s:match"^%s*()"
   return from > #s and "" or s:match(".*%S", from)
end

--[[
  Boxes to simulate boosters.
]]


wtr_boxes = {
    -- box #1
    [1] = {
        -- pack #1 in box #1
        [1] = {
            "WTR177","WTR221","WTR191","WTR220","WTR080","WTR050","WTR127","WTR022","WTR021","WTR070","WTR029","WTR139","WTR110","WTR139","WTR104","WTR076","WTR039"
        },
        -- pack #2 in box #1
        [2] = {
            "WTR216","WTR188","WTR201","WTR184","WTR154","WTR088","WTR094","WTR110","WTR059","WTR035","WTR069","WTR101","WTR149","WTR105","WTR136","WTR078","WTR001"
        },
        -- pack #3 in box #1
        [3] = {
            "WTR194","WTR177","WTR202","WTR193","WTR158","WTR174","WTR173","WTR087","WTR023","WTR070","WTR027","WTR062","WTR104","WTR132","WTR111","WTR038","WTR039"
        },
        -- pack #4 in box #1
        [4] = {
            "WTR207","WTR186","WTR217","WTR215","WTR155","WTR017","WTR128","WTR020","WTR031","WTR064","WTR021","WTR144","WTR110","WTR136","WTR103","WTR003","WTR001"
        },
        -- pack #5 in box #1
        [5] = {
            "WTR181","WTR213","WTR219","WTR199","WTR155","WTR050","WTR043","WTR185","WTR066","WTR035","WTR060","WTR034","WTR139","WTR102","WTR148","WTR077","WTR039"
        },
        -- pack #6 in box #1
        [6] = {
            "WTR220","WTR193","WTR180","WTR199","WTR153","WTR014","WTR121","WTR028","WTR031","WTR059","WTR023","WTR142","WTR106","WTR134","WTR107","WTR224"
        },
        -- pack #7 in box #1
        [7] = {
            "WTR191","WTR191","WTR208","WTR217","WTR153","WTR165","WTR124","WTR200","WTR026","WTR058","WTR036","WTR139","WTR109","WTR146","WTR099","WTR225","WTR078"
        },
        -- pack #8 in box #1
        [8] = {
            "WTR214","WTR180","WTR181","WTR182","WTR042","WTR167","WTR129","WTR216","WTR060","WTR025","WTR074","WTR024","WTR136","WTR100","WTR134","WTR001","WTR113"
        },
        -- pack #9 in box #1
        [9] = {
            "WTR200","WTR198","WTR188","WTR183","WTR005","WTR090","WTR124","WTR143","WTR037","WTR071","WTR029","WTR058","WTR107","WTR147","WTR103","WTR114","WTR076"
        },
        -- pack #10 in box #1
        [10] = {
            "WTR207","WTR189","WTR184","WTR190","WTR117","WTR167","WTR008","WTR222","WTR036","WTR065","WTR031","WTR073","WTR109","WTR140","WTR095","WTR225","WTR077"
        },
        -- pack #11 in box #1
        [11] = {
            "WTR189","WTR216","WTR220","WTR216","WTR117","WTR055","WTR049","WTR197","WTR065","WTR032","WTR057","WTR024","WTR146","WTR103","WTR146","WTR040","WTR078"
        },
        -- pack #12 in box #1
        [12] = {
            "WTR179","WTR197","WTR210","WTR218","WTR158","WTR172","WTR162","WTR155","WTR037","WTR070","WTR027","WTR063","WTR101","WTR139","WTR099","WTR076","WTR040"
        },
        -- pack #13 in box #1
        [13] = {
            "WTR215","WTR206","WTR179","WTR198","WTR117","WTR015","WTR162","WTR019","WTR067","WTR027","WTR073","WTR030","WTR135","WTR097","WTR139","WTR039","WTR040"
        },
        -- pack #14 in box #1
        [14] = {
            "WTR192","WTR191","WTR220","WTR183","WTR156","WTR168","WTR015","WTR059","WTR024","WTR059","WTR035","WTR135","WTR109","WTR146","WTR109","WTR113","WTR078"
        },
        -- pack #15 in box #1
        [15] = {
            "WTR197","WTR210","WTR215","WTR218","WTR157","WTR086","WTR011","WTR025","WTR069","WTR034","WTR064","WTR112","WTR145","WTR102","WTR147","WTR003","WTR114"
        },
        -- pack #16 in box #1
        [16] = {
            "WTR194","WTR195","WTR177","WTR208","WTR153","WTR173","WTR164","WTR138","WTR030","WTR059","WTR031","WTR143","WTR106","WTR142","WTR111","WTR075","WTR001"
        },
        -- pack #17 in box #1
        [17] = {
            "WTR213","WTR223","WTR200","WTR176","WTR080","WTR086","WTR008","WTR066","WTR067","WTR030","WTR065","WTR098","WTR135","WTR099","WTR136","WTR039","WTR001"
        },
        -- pack #18 in box #1
        [18] = {
            "WTR191","WTR221","WTR221","WTR186","WTR117","WTR165","WTR049","WTR142","WTR071","WTR020","WTR067","WTR025","WTR139","WTR102","WTR146","WTR076","WTR040"
        },
        -- pack #19 in box #1
        [19] = {
            "WTR207","WTR186","WTR206","WTR187","WTR156","WTR164","WTR166","WTR004","WTR061","WTR028","WTR069","WTR111","WTR144","WTR107","WTR140","WTR076","WTR001"
        },
        -- pack #20 in box #1
        [20] = {
            "WTR207","WTR215","WTR181","WTR209","WTR152","WTR086","WTR173","WTR017","WTR066","WTR032","WTR074","WTR037","WTR137","WTR108","WTR134","WTR077","WTR002"
        },
        -- pack #21 in box #1
        [21] = {
            "WTR210","WTR194","WTR220","WTR179","WTR156","WTR166","WTR043","WTR064","WTR071","WTR023","WTR059","WTR100","WTR134","WTR095","WTR142","WTR001","WTR225"
        },
        -- pack #22 in box #1
        [22] = {
            "WTR206","WTR202","WTR183","WTR201","WTR151","WTR172","WTR044","WTR064","WTR023","WTR073","WTR034","WTR064","WTR109","WTR140","WTR096","WTR078","WTR113"
        },
        -- pack #23 in box #1
        [23] = {
            "WTR222","WTR189","WTR205","WTR203","WTR155","WTR054","WTR125","WTR183","WTR070","WTR032","WTR070","WTR105","WTR135","WTR096","WTR133","WTR115","WTR002"
        },
        -- pack #24 in box #1
        [24] = {
            "WTR181","WTR219","WTR182","WTR201","WTR080","WTR129","WTR126","WTR106","WTR028","WTR063","WTR036","WTR066","WTR112","WTR147","WTR100","WTR076","WTR075"
        },
    },
    -- box #2
    [2] = {
        -- pack #1 in box #2
        [1] = {
            "WTR203","WTR222","WTR215","WTR197","WTR158","WTR049","WTR160","WTR199","WTR020","WTR062","WTR023","WTR072","WTR095","WTR144","WTR112","WTR038","WTR003"
        },
        -- pack #2 in box #2
        [2] = {
            "WTR223","WTR207","WTR189","WTR199","WTR152","WTR167","WTR012","WTR034","WTR031","WTR072","WTR027","WTR065","WTR107","WTR133","WTR103","WTR038","WTR075"
        },
        -- pack #3 in box #2
        [3] = {
            "WTR180","WTR184","WTR221","WTR206","WTR158","WTR173","WTR129","WTR136","WTR066","WTR030","WTR072","WTR096","WTR141","WTR102","WTR141","WTR075","WTR114"
        },
        -- pack #4 in box #2
        [4] = {
            "WTR177","WTR218","WTR189","WTR178","WTR080","WTR175","WTR174","WTR065","WTR073","WTR031","WTR063","WTR104","WTR135","WTR103","WTR143","WTR039","WTR113"
        },
        -- pack #5 in box #2
        [5] = {
            "WTR206","WTR189","WTR213","WTR198","WTR155","WTR011","WTR017","WTR080","WTR068","WTR027","WTR070","WTR112","WTR134","WTR097","WTR145","WTR038","WTR115"
        },
        -- pack #6 in box #2
        [6] = {
            "WTR221","WTR186","WTR202","WTR197","WTR117","WTR125","WTR056","WTR005","WTR033","WTR065","WTR025","WTR063","WTR096","WTR140","WTR100","WTR224"
        },
        -- pack #7 in box #2
        [7] = {
            "WTR202","WTR180","WTR193","WTR178","WTR152","WTR051","WTR123","WTR202","WTR070","WTR032","WTR066","WTR032","WTR146","WTR107","WTR133","WTR001","WTR002"
        },
        -- pack #8 in box #2
        [8] = {
            "WTR221","WTR198","WTR207","WTR178","WTR158","WTR055","WTR128","WTR156","WTR068","WTR031","WTR061","WTR030","WTR137","WTR099","WTR143","WTR038","WTR003"
        },
        -- pack #9 in box #2
        [9] = {
            "WTR198","WTR210","WTR215","WTR194","WTR153","WTR126","WTR160","WTR189","WTR036","WTR069","WTR020","WTR136","WTR096","WTR146","WTR100","WTR039","WTR113"
        },
        -- pack #10 in box #2
        [10] = {
            "WTR197","WTR202","WTR201","WTR176","WTR005","WTR164","WTR122","WTR005","WTR058","WTR024","WTR062","WTR025","WTR135","WTR102","WTR132","WTR001","WTR076"
        },
        -- pack #11 in box #2
        [11] = {
            "WTR199","WTR192","WTR179","WTR192","WTR152","WTR016","WTR127","WTR107","WTR037","WTR074","WTR032","WTR073","WTR100","WTR139","WTR096","WTR039","WTR075"
        },
        -- pack #12 in box #2
        [12] = {
            "WTR197","WTR180","WTR209","WTR177","WTR157","WTR055","WTR131","WTR067","WTR037","WTR058","WTR028","WTR067","WTR108","WTR145","WTR101","WTR002","WTR001"
        },
        -- pack #13 in box #2
        [13] = {
            "WTR222","WTR185","WTR214","WTR215","WTR005","WTR164","WTR092","WTR029","WTR069","WTR031","WTR057","WTR037","WTR144","WTR095","WTR144","WTR001","WTR114"
        },
        -- pack #14 in box #2
        [14] = {
            "WTR212","WTR183","WTR206","WTR212","WTR155","WTR123","WTR092","WTR079","WTR070","WTR026","WTR062","WTR104","WTR137","WTR099","WTR136","WTR003","WTR039"
        },
        -- pack #15 in box #2
        [15] = {
            "WTR183","WTR177","WTR193","WTR207","WTR117","WTR055","WTR047","WTR143","WTR072","WTR030","WTR073","WTR031","WTR140","WTR108","WTR144","WTR002","WTR075"
        },
        -- pack #16 in box #2
        [16] = {
            "WTR209","WTR200","WTR184","WTR192","WTR005","WTR090","WTR164","WTR219","WTR071","WTR022","WTR064","WTR108","WTR134","WTR110","WTR149","WTR002","WTR039"
        },
        -- pack #17 in box #2
        [17] = {
            "WTR183","WTR209","WTR218","WTR200","WTR117","WTR049","WTR093","WTR055","WTR026","WTR058","WTR024","WTR132","WTR098","WTR138","WTR095","WTR115","WTR038"
        },
        -- pack #18 in box #2
        [18] = {
            "WTR190","WTR211","WTR222","WTR191","WTR153","WTR127","WTR055","WTR014","WTR032","WTR074","WTR022","WTR144","WTR107","WTR146","WTR111","WTR113","WTR040"
        },
        -- pack #19 in box #2
        [19] = {
            "WTR185","WTR199","WTR209","WTR211","WTR151","WTR168","WTR013","WTR109","WTR025","WTR067","WTR033","WTR140","WTR095","WTR146","WTR095","WTR039","WTR076"
        },
        -- pack #20 in box #2
        [20] = {
            "WTR185","WTR203","WTR178","WTR211","WTR157","WTR130","WTR126","WTR177","WTR061","WTR034","WTR068","WTR112","WTR145","WTR111","WTR136","WTR002","WTR038"
        },
        -- pack #21 in box #2
        [21] = {
            "WTR198","WTR200","WTR216","WTR193","WTR152","WTR053","WTR055","WTR182","WTR024","WTR069","WTR037","WTR137","WTR109","WTR134","WTR100","WTR224"
        },
        -- pack #22 in box #2
        [22] = {
            "WTR186","WTR177","WTR219","WTR195","WTR151","WTR164","WTR123","WTR168","WTR073","WTR037","WTR061","WTR030","WTR133","WTR097","WTR140","WTR115","WTR040"
        },
        -- pack #23 in box #2
        [23] = {
            "WTR184","WTR197","WTR201","WTR182","WTR080","WTR054","WTR056","WTR158","WTR030","WTR062","WTR028","WTR143","WTR096","WTR145","WTR110","WTR114","WTR040"
        },
        -- pack #24 in box #2
        [24] = {
            "WTR200","WTR193","WTR202","WTR181","WTR157","WTR094","WTR053","WTR064","WTR020","WTR072","WTR022","WTR072","WTR101","WTR139","WTR102","WTR001","WTR075"
        },
    },
    -- box #3
    [3] = {
        -- pack #1 in box #3
        [1] = {
            "WTR222","WTR190","WTR215","WTR218","WTR153","WTR086","WTR048","WTR214","WTR060","WTR031","WTR067","WTR107","WTR143","WTR098","WTR145","WTR114","WTR113"
        },
        -- pack #2 in box #3
        [2] = {
            "WTR178","WTR203","WTR186","WTR180","WTR152","WTR091","WTR169","WTR206","WTR029","WTR071","WTR021","WTR070","WTR100","WTR145","WTR103","WTR002","WTR075"
        },
        -- pack #3 in box #3
        [3] = {
            "WTR201","WTR208","WTR202","WTR214","WTR156","WTR166","WTR018","WTR067","WTR029","WTR064","WTR029","WTR057","WTR109","WTR147","WTR102","WTR075","WTR078"
        },
        -- pack #4 in box #3
        [4] = {
            "WTR208","WTR221","WTR178","WTR202","WTR152","WTR056","WTR119","WTR047","WTR065","WTR032","WTR059","WTR024","WTR134","WTR107","WTR143","WTR001","WTR002"
        },
        -- pack #5 in box #3
        [5] = {
            "WTR203","WTR221","WTR192","WTR216","WTR156","WTR124","WTR049","WTR185","WTR072","WTR022","WTR072","WTR104","WTR145","WTR104","WTR149","WTR002","WTR076"
        },
        -- pack #6 in box #3
        [6] = {
            "WTR219","WTR179","WTR194","WTR196","WTR117","WTR172","WTR011","WTR109","WTR070","WTR021","WTR062","WTR099","WTR141","WTR109","WTR142","WTR225","WTR075"
        },
        -- pack #7 in box #3
        [7] = {
            "WTR213","WTR211","WTR184","WTR211","WTR156","WTR129","WTR051","WTR095","WTR031","WTR069","WTR028","WTR140","WTR097","WTR134","WTR101","WTR077","WTR225"
        },
        -- pack #8 in box #3
        [8] = {
            "WTR213","WTR198","WTR217","WTR220","WTR042","WTR011","WTR014","WTR106","WTR071","WTR027","WTR071","WTR021","WTR139","WTR102","WTR147","WTR001","WTR078"
        },
        -- pack #9 in box #3
        [9] = {
            "WTR209","WTR211","WTR189","WTR212","WTR042","WTR125","WTR159","WTR166","WTR027","WTR060","WTR030","WTR145","WTR099","WTR133","WTR112","WTR038","WTR001"
        },
        -- pack #10 in box #3
        [10] = {
            "WTR221","WTR185","WTR194","WTR193","WTR154","WTR015","WTR171","WTR203","WTR062","WTR032","WTR058","WTR036","WTR144","WTR108","WTR132","WTR114","WTR225"
        },
        -- pack #11 in box #3
        [11] = {
            "WTR193","WTR198","WTR199","WTR218","WTR158","WTR092","WTR163","WTR125","WTR020","WTR066","WTR033","WTR059","WTR097","WTR146","WTR098","WTR075","WTR113"
        },
        -- pack #12 in box #3
        [12] = {
            "WTR209","WTR195","WTR214","WTR191","WTR153","WTR168","WTR124","WTR099","WTR059","WTR035","WTR062","WTR024","WTR133","WTR105","WTR133","WTR040","WTR076"
        },
        -- pack #13 in box #3
        [13] = {
            "WTR178","WTR206","WTR211","WTR223","WTR156","WTR130","WTR016","WTR199","WTR032","WTR073","WTR031","WTR073","WTR110","WTR139","WTR098","WTR075","WTR077"
        },
        -- pack #14 in box #3
        [14] = {
            "WTR180","WTR206","WTR219","WTR188","WTR080","WTR165","WTR018","WTR218","WTR068","WTR020","WTR061","WTR110","WTR146","WTR105","WTR146","WTR075","WTR225"
        },
        -- pack #15 in box #3
        [15] = {
            "WTR195","WTR204","WTR217","WTR214","WTR157","WTR094","WTR160","WTR022","WTR034","WTR073","WTR028","WTR057","WTR102","WTR149","WTR108","WTR225","WTR075"
        },
        -- pack #16 in box #3
        [16] = {
            "WTR187","WTR211","WTR207","WTR217","WTR117","WTR123","WTR174","WTR059","WTR029","WTR072","WTR023","WTR141","WTR112","WTR142","WTR098","WTR075","WTR039"
        },
        -- pack #17 in box #3
        [17] = {
            "WTR222","WTR177","WTR188","WTR177","WTR151","WTR086","WTR056","WTR068","WTR023","WTR064","WTR025","WTR064","WTR097","WTR145","WTR109","WTR225","WTR078"
        },
        -- pack #18 in box #3
        [18] = {
            "WTR179","WTR180","WTR195","WTR201","WTR152","WTR170","WTR084","WTR192","WTR062","WTR036","WTR071","WTR031","WTR135","WTR107","WTR145","WTR078","WTR001"
        },
        -- pack #19 in box #3
        [19] = {
            "WTR220","WTR200","WTR203","WTR199","WTR151","WTR124","WTR013","WTR058","WTR058","WTR022","WTR071","WTR109","WTR133","WTR100","WTR139","WTR115","WTR001"
        },
        -- pack #20 in box #3
        [20] = {
            "WTR193","WTR198","WTR183","WTR220","WTR152","WTR088","WTR089","WTR179","WTR025","WTR060","WTR034","WTR139","WTR100","WTR146","WTR099","WTR001","WTR115"
        },
        -- pack #21 in box #3
        [21] = {
            "WTR187","WTR219","WTR203","WTR206","WTR151","WTR086","WTR016","WTR023","WTR069","WTR033","WTR060","WTR032","WTR149","WTR111","WTR145","WTR114","WTR001"
        },
        -- pack #22 in box #3
        [22] = {
            "WTR190","WTR188","WTR185","WTR177","WTR158","WTR012","WTR081","WTR095","WTR031","WTR062","WTR031","WTR145","WTR097","WTR135","WTR110","WTR039","WTR078"
        },
        -- pack #23 in box #3
        [23] = {
            "WTR195","WTR178","WTR189","WTR177","WTR042","WTR123","WTR161","WTR173","WTR024","WTR067","WTR022","WTR132","WTR095","WTR142","WTR102","WTR115","WTR038"
        },
        -- pack #24 in box #3
        [24] = {
            "WTR215","WTR193","WTR215","WTR207","WTR153","WTR092","WTR088","WTR201","WTR062","WTR036","WTR057","WTR112","WTR149","WTR095","WTR132","WTR040","WTR002"
        },
    },
    -- box #4
    [4] = {
        -- pack #1 in box #4
        [1] = {
            "WTR189","WTR211","WTR193","WTR179","WTR153","WTR016","WTR016","WTR028","WTR026","WTR066","WTR028","WTR070","WTR109","WTR143","WTR104","WTR075","WTR040"
        },
        -- pack #2 in box #4
        [2] = {
            "WTR204","WTR182","WTR202","WTR188","WTR154","WTR089","WTR050","WTR015","WTR029","WTR071","WTR037","WTR060","WTR108","WTR141","WTR101","WTR002","WTR115"
        },
        -- pack #3 in box #4
        [3] = {
            "WTR211","WTR193","WTR208","WTR183","WTR152","WTR011","WTR045","WTR024","WTR059","WTR026","WTR071","WTR103","WTR147","WTR095","WTR147","WTR077","WTR078"
        },
        -- pack #4 in box #4
        [4] = {
            "WTR183","WTR186","WTR204","WTR197","WTR042","WTR087","WTR171","WTR195","WTR072","WTR034","WTR073","WTR103","WTR144","WTR098","WTR147","WTR076","WTR039"
        },
        -- pack #5 in box #4
        [5] = {
            "WTR217","WTR187","WTR210","WTR213","WTR042","WTR089","WTR165","WTR097","WTR032","WTR071","WTR028","WTR074","WTR104","WTR147","WTR099","WTR113","WTR039"
        },
        -- pack #6 in box #4
        [6] = {
            "WTR197","WTR213","WTR209","WTR206","WTR155","WTR015","WTR129","WTR098","WTR070","WTR024","WTR068","WTR095","WTR148","WTR096","WTR149","WTR001","WTR077"
        },
        -- pack #7 in box #4
        [7] = {
            "WTR219","WTR219","WTR193","WTR201","WTR155","WTR013","WTR126","WTR215","WTR033","WTR058","WTR031","WTR134","WTR105","WTR149","WTR108","WTR113","WTR114"
        },
        -- pack #8 in box #4
        [8] = {
            "WTR211","WTR193","WTR220","WTR201","WTR152","WTR174","WTR119","WTR067","WTR034","WTR060","WTR028","WTR068","WTR108","WTR134","WTR095","WTR075","WTR039"
        },
        -- pack #9 in box #4
        [9] = {
            "WTR195","WTR217","WTR196","WTR209","WTR155","WTR054","WTR168","WTR095","WTR069","WTR029","WTR058","WTR021","WTR138","WTR099","WTR143","WTR039","WTR076"
        },
        -- pack #10 in box #4
        [10] = {
            "WTR195","WTR206","WTR198","WTR187","WTR042","WTR130","WTR082","WTR020","WTR024","WTR061","WTR034","WTR139","WTR110","WTR141","WTR109","WTR003","WTR115"
        },
        -- pack #11 in box #4
        [11] = {
            "WTR219","WTR204","WTR196","WTR185","WTR042","WTR129","WTR084","WTR215","WTR071","WTR024","WTR060","WTR095","WTR136","WTR096","WTR147","WTR078","WTR039"
        },
        -- pack #12 in box #4
        [12] = {
            "WTR219","WTR184","WTR219","WTR193","WTR080","WTR172","WTR092","WTR029","WTR033","WTR057","WTR027","WTR068","WTR108","WTR132","WTR096","WTR078","WTR075"
        },
        -- pack #13 in box #4
        [13] = {
            "WTR212","WTR204","WTR220","WTR218","WTR158","WTR053","WTR051","WTR023","WTR072","WTR037","WTR068","WTR022","WTR136","WTR110","WTR132","WTR001","WTR040"
        },
        -- pack #14 in box #4
        [14] = {
            "WTR206","WTR195","WTR203","WTR190","WTR155","WTR168","WTR086","WTR206","WTR027","WTR057","WTR028","WTR059","WTR111","WTR141","WTR100","WTR038","WTR040"
        },
        -- pack #15 in box #4
        [15] = {
            "WTR203","WTR187","WTR217","WTR193","WTR152","WTR017","WTR120","WTR143","WTR035","WTR067","WTR028","WTR142","WTR096","WTR143","WTR106","WTR078","WTR002"
        },
        -- pack #16 in box #4
        [16] = {
            "WTR180","WTR220","WTR191","WTR218","WTR080","WTR018","WTR163","WTR166","WTR020","WTR057","WTR023","WTR138","WTR095","WTR146","WTR102","WTR077","WTR001"
        },
        -- pack #17 in box #4
        [17] = {
            "WTR211","WTR189","WTR194","WTR203","WTR155","WTR052","WTR172","WTR099","WTR067","WTR037","WTR066","WTR020","WTR142","WTR095","WTR141","WTR039","WTR002"
        },
        -- pack #18 in box #4
        [18] = {
            "WTR205","WTR181","WTR202","WTR182","WTR005","WTR124","WTR044","WTR010","WTR030","WTR072","WTR030","WTR137","WTR096","WTR146","WTR101","WTR077","WTR115"
        },
        -- pack #19 in box #4
        [19] = {
            "WTR181","WTR195","WTR206","WTR178","WTR080","WTR048","WTR015","WTR134","WTR072","WTR021","WTR071","WTR096","WTR135","WTR106","WTR137","WTR225","WTR040"
        },
        -- pack #20 in box #4
        [20] = {
            "WTR194","WTR213","WTR212","WTR202","WTR151","WTR014","WTR163","WTR149","WTR067","WTR035","WTR057","WTR036","WTR141","WTR098","WTR138","WTR076","WTR077"
        },
        -- pack #21 in box #4
        [21] = {
            "WTR218","WTR202","WTR178","WTR187","WTR151","WTR054","WTR173","WTR198","WTR066","WTR020","WTR067","WTR026","WTR143","WTR107","WTR141","WTR077","WTR040"
        },
        -- pack #22 in box #4
        [22] = {
            "WTR201","WTR181","WTR193","WTR193","WTR156","WTR092","WTR175","WTR058","WTR021","WTR068","WTR022","WTR134","WTR101","WTR148","WTR096","WTR115","WTR078"
        },
        -- pack #23 in box #4
        [23] = {
            "WTR188","WTR177","WTR192","WTR183","WTR155","WTR014","WTR010","WTR196","WTR059","WTR024","WTR062","WTR108","WTR134","WTR107","WTR144","WTR002","WTR075"
        },
        -- pack #24 in box #4
        [24] = {
            "WTR192","WTR209","WTR205","WTR194","WTR080","WTR170","WTR010","WTR106","WTR068","WTR020","WTR064","WTR036","WTR146","WTR097","WTR135","WTR039","WTR225"
        },
    },
    -- box #5
    [5] = {
        -- pack #1 in box #5
        [1] = {
            "WTR220","WTR210","WTR218","WTR198","WTR005","WTR012","WTR125","WTR072","WTR066","WTR037","WTR074","WTR033","WTR139","WTR111","WTR137","WTR075","WTR040"
        },
        -- pack #2 in box #5
        [2] = {
            "WTR180","WTR177","WTR213","WTR206","WTR153","WTR129","WTR054","WTR057","WTR069","WTR031","WTR065","WTR095","WTR148","WTR098","WTR136","WTR075","WTR225"
        },
        -- pack #3 in box #5
        [3] = {
            "WTR185","WTR191","WTR189","WTR195","WTR080","WTR123","WTR014","WTR164","WTR074","WTR022","WTR057","WTR029","WTR145","WTR099","WTR138","WTR040","WTR078"
        },
        -- pack #4 in box #5
        [4] = {
            "WTR188","WTR223","WTR221","WTR180","WTR151","WTR090","WTR160","WTR126","WTR065","WTR028","WTR059","WTR103","WTR135","WTR095","WTR144","WTR039","WTR075"
        },
        -- pack #5 in box #5
        [5] = {
            "WTR181","WTR178","WTR188","WTR189","WTR157","WTR049","WTR019","WTR183","WTR069","WTR021","WTR072","WTR024","WTR142","WTR100","WTR144","WTR002","WTR039"
        },
        -- pack #6 in box #5
        [6] = {
            "WTR188","WTR213","WTR212","WTR183","WTR153","WTR014","WTR174","WTR043","WTR068","WTR034","WTR063","WTR105","WTR132","WTR098","WTR135","WTR113","WTR003"
        },
        -- pack #7 in box #5
        [7] = {
            "WTR184","WTR199","WTR201","WTR206","WTR155","WTR175","WTR014","WTR021","WTR035","WTR059","WTR031","WTR062","WTR096","WTR132","WTR102","WTR077","WTR040"
        },
        -- pack #8 in box #5
        [8] = {
            "WTR177","WTR199","WTR216","WTR195","WTR042","WTR091","WTR090","WTR144","WTR072","WTR035","WTR057","WTR030","WTR146","WTR111","WTR147","WTR002","WTR003"
        },
        -- pack #9 in box #5
        [9] = {
            "WTR182","WTR212","WTR183","WTR201","WTR153","WTR092","WTR168","WTR183","WTR033","WTR067","WTR024","WTR149","WTR112","WTR142","WTR102","WTR039","WTR114"
        },
        -- pack #10 in box #5
        [10] = {
            "WTR180","WTR216","WTR185","WTR188","WTR005","WTR128","WTR128","WTR101","WTR025","WTR067","WTR026","WTR065","WTR097","WTR140","WTR105","WTR002","WTR075"
        },
        -- pack #11 in box #5
        [11] = {
            "WTR203","WTR213","WTR217","WTR207","WTR151","WTR172","WTR159","WTR070","WTR035","WTR071","WTR025","WTR146","WTR099","WTR133","WTR106","WTR078","WTR114"
        },
        -- pack #12 in box #5
        [12] = {
            "WTR189","WTR218","WTR196","WTR195","WTR005","WTR090","WTR053","WTR156","WTR029","WTR064","WTR030","WTR062","WTR111","WTR141","WTR109","WTR002","WTR078"
        },
        -- pack #13 in box #5
        [13] = {
            "WTR214","WTR209","WTR190","WTR178","WTR117","WTR055","WTR045","WTR066","WTR072","WTR025","WTR073","WTR111","WTR149","WTR102","WTR140","WTR225","WTR001"
        },
        -- pack #14 in box #5
        [14] = {
            "WTR205","WTR185","WTR186","WTR205","WTR005","WTR170","WTR159","WTR186","WTR031","WTR057","WTR023","WTR134","WTR099","WTR132","WTR110","WTR224"
        },
        -- pack #15 in box #5
        [15] = {
            "WTR185","WTR201","WTR212","WTR198","WTR151","WTR171","WTR130","WTR195","WTR067","WTR031","WTR073","WTR029","WTR142","WTR102","WTR135","WTR225","WTR001"
        },
        -- pack #16 in box #5
        [16] = {
            "WTR184","WTR202","WTR211","WTR217","WTR157","WTR125","WTR051","WTR060","WTR035","WTR066","WTR020","WTR134","WTR100","WTR148","WTR109","WTR038","WTR076"
        },
        -- pack #17 in box #5
        [17] = {
            "WTR181","WTR183","WTR219","WTR177","WTR155","WTR090","WTR164","WTR072","WTR025","WTR058","WTR036","WTR064","WTR111","WTR135","WTR110","WTR039","WTR001"
        },
        -- pack #18 in box #5
        [18] = {
            "WTR210","WTR209","WTR216","WTR206","WTR154","WTR129","WTR090","WTR222","WTR022","WTR060","WTR030","WTR134","WTR100","WTR141","WTR095","WTR040","WTR076"
        },
        -- pack #19 in box #5
        [19] = {
            "WTR183","WTR202","WTR219","WTR189","WTR154","WTR054","WTR013","WTR215","WTR066","WTR032","WTR065","WTR103","WTR145","WTR104","WTR138","WTR076","WTR001"
        },
        -- pack #20 in box #5
        [20] = {
            "WTR205","WTR200","WTR210","WTR220","WTR155","WTR055","WTR019","WTR024","WTR027","WTR072","WTR030","WTR062","WTR106","WTR141","WTR098","WTR114","WTR076"
        },
        -- pack #21 in box #5
        [21] = {
            "WTR218","WTR191","WTR190","WTR194","WTR005","WTR174","WTR018","WTR192","WTR023","WTR058","WTR026","WTR057","WTR102","WTR137","WTR105","WTR224"
        },
        -- pack #22 in box #5
        [22] = {
            "WTR198","WTR222","WTR194","WTR221","WTR154","WTR168","WTR045","WTR109","WTR074","WTR033","WTR064","WTR108","WTR132","WTR102","WTR135","WTR075","WTR002"
        },
        -- pack #23 in box #5
        [23] = {
            "WTR181","WTR202","WTR214","WTR211","WTR155","WTR049","WTR049","WTR033","WTR022","WTR061","WTR024","WTR148","WTR105","WTR132","WTR109","WTR224"
        },
        -- pack #24 in box #5
        [24] = {
            "WTR205","WTR208","WTR221","WTR213","WTR153","WTR018","WTR047","WTR054","WTR070","WTR029","WTR063","WTR037","WTR142","WTR107","WTR137","WTR115","WTR002"
        },
    },
    -- box #6
    [6] = {
        -- pack #1 in box #6
        [1] = {
            "WTR208","WTR218","WTR213","WTR186","WTR155","WTR130","WTR007","WTR144","WTR026","WTR072","WTR031","WTR067","WTR096","WTR138","WTR099","WTR115","WTR003"
        },
        -- pack #2 in box #6
        [2] = {
            "WTR177","WTR216","WTR198","WTR183","WTR117","WTR165","WTR012","WTR204","WTR061","WTR035","WTR065","WTR037","WTR144","WTR096","WTR148","WTR224"
        },
        -- pack #3 in box #6
        [3] = {
            "WTR201","WTR195","WTR209","WTR200","WTR154","WTR055","WTR123","WTR189","WTR063","WTR037","WTR064","WTR032","WTR148","WTR100","WTR136","WTR115","WTR075"
        },
        -- pack #4 in box #6
        [4] = {
            "WTR207","WTR223","WTR210","WTR194","WTR152","WTR050","WTR089","WTR173","WTR021","WTR068","WTR023","WTR135","WTR105","WTR135","WTR112","WTR114","WTR077"
        },
        -- pack #5 in box #6
        [5] = {
            "WTR196","WTR196","WTR176","WTR209","WTR117","WTR016","WTR019","WTR141","WTR033","WTR067","WTR027","WTR068","WTR099","WTR143","WTR104","WTR224"
        },
        -- pack #6 in box #6
        [6] = {
            "WTR219","WTR185","WTR206","WTR220","WTR157","WTR013","WTR016","WTR063","WTR035","WTR061","WTR023","WTR132","WTR111","WTR140","WTR108","WTR039","WTR078"
        },
        -- pack #7 in box #6
        [7] = {
            "WTR184","WTR196","WTR186","WTR213","WTR158","WTR090","WTR094","WTR032","WTR072","WTR022","WTR058","WTR099","WTR149","WTR098","WTR135","WTR001","WTR078"
        },
        -- pack #8 in box #6
        [8] = {
            "WTR200","WTR200","WTR198","WTR187","WTR158","WTR015","WTR050","WTR201","WTR065","WTR033","WTR073","WTR025","WTR140","WTR097","WTR141","WTR224"
        },
        -- pack #9 in box #6
        [9] = {
            "WTR222","WTR216","WTR212","WTR210","WTR153","WTR128","WTR094","WTR174","WTR071","WTR030","WTR060","WTR021","WTR140","WTR108","WTR142","WTR039","WTR113"
        },
        -- pack #10 in box #6
        [10] = {
            "WTR184","WTR182","WTR179","WTR206","WTR154","WTR174","WTR163","WTR042","WTR072","WTR022","WTR063","WTR024","WTR148","WTR107","WTR135","WTR224"
        },
        -- pack #11 in box #6
        [11] = {
            "WTR204","WTR213","WTR218","WTR206","WTR005","WTR014","WTR174","WTR014","WTR063","WTR026","WTR071","WTR095","WTR142","WTR104","WTR132","WTR115","WTR039"
        },
        -- pack #12 in box #6
        [12] = {
            "WTR196","WTR211","WTR195","WTR202","WTR157","WTR090","WTR084","WTR156","WTR068","WTR028","WTR070","WTR029","WTR136","WTR107","WTR149","WTR039","WTR075"
        },
        -- pack #13 in box #6
        [13] = {
            "WTR201","WTR185","WTR196","WTR215","WTR117","WTR123","WTR128","WTR138","WTR022","WTR063","WTR033","WTR140","WTR111","WTR139","WTR096","WTR075","WTR003"
        },
        -- pack #14 in box #6
        [14] = {
            "WTR203","WTR204","WTR222","WTR217","WTR157","WTR170","WTR089","WTR223","WTR057","WTR036","WTR057","WTR109","WTR143","WTR103","WTR142","WTR225","WTR076"
        },
        -- pack #15 in box #6
        [15] = {
            "WTR185","WTR210","WTR185","WTR205","WTR158","WTR052","WTR084","WTR063","WTR068","WTR027","WTR065","WTR111","WTR132","WTR111","WTR132","WTR225","WTR040"
        },
        -- pack #16 in box #6
        [16] = {
            "WTR181","WTR222","WTR222","WTR210","WTR005","WTR056","WTR118","WTR141","WTR024","WTR072","WTR025","WTR072","WTR101","WTR139","WTR105","WTR076","WTR038"
        },
        -- pack #17 in box #6
        [17] = {
            "WTR205","WTR211","WTR193","WTR210","WTR042","WTR090","WTR053","WTR200","WTR062","WTR028","WTR057","WTR098","WTR144","WTR110","WTR147","WTR039","WTR075"
        },
        -- pack #18 in box #6
        [18] = {
            "WTR205","WTR192","WTR214","WTR198","WTR158","WTR128","WTR019","WTR020","WTR031","WTR072","WTR033","WTR145","WTR100","WTR138","WTR096","WTR225","WTR002"
        },
        -- pack #19 in box #6
        [19] = {
            "WTR221","WTR180","WTR216","WTR218","WTR152","WTR173","WTR090","WTR096","WTR028","WTR072","WTR025","WTR068","WTR105","WTR141","WTR107","WTR225","WTR115"
        },
        -- pack #20 in box #6
        [20] = {
            "WTR181","WTR185","WTR197","WTR185","WTR158","WTR169","WTR169","WTR204","WTR021","WTR059","WTR020","WTR067","WTR099","WTR142","WTR107","WTR224"
        },
        -- pack #21 in box #6
        [21] = {
            "WTR193","WTR209","WTR188","WTR215","WTR155","WTR091","WTR011","WTR223","WTR020","WTR059","WTR033","WTR143","WTR102","WTR135","WTR105","WTR225","WTR038"
        },
        -- pack #22 in box #6
        [22] = {
            "WTR209","WTR204","WTR185","WTR216","WTR157","WTR164","WTR055","WTR107","WTR028","WTR071","WTR025","WTR149","WTR101","WTR147","WTR097","WTR003","WTR077"
        },
        -- pack #23 in box #6
        [23] = {
            "WTR186","WTR186","WTR212","WTR184","WTR152","WTR011","WTR086","WTR010","WTR062","WTR034","WTR074","WTR095","WTR145","WTR100","WTR148","WTR039","WTR001"
        },
        -- pack #24 in box #6
        [24] = {
            "WTR207","WTR217","WTR187","WTR205","WTR005","WTR048","WTR046","WTR103","WTR023","WTR070","WTR027","WTR066","WTR100","WTR146","WTR112","WTR224"
        },
    },
    -- box #7
    [7] = {
        -- pack #1 in box #7
        [1] = {
            "WTR208","WTR189","WTR177","WTR183","WTR157","WTR018","WTR165","WTR111","WTR061","WTR036","WTR074","WTR107","WTR144","WTR098","WTR133","WTR225","WTR113"
        },
        -- pack #2 in box #7
        [2] = {
            "WTR216","WTR183","WTR217","WTR184","WTR153","WTR175","WTR015","WTR098","WTR074","WTR020","WTR063","WTR108","WTR133","WTR108","WTR134","WTR040","WTR115"
        },
        -- pack #3 in box #7
        [3] = {
            "WTR201","WTR205","WTR213","WTR206","WTR157","WTR053","WTR047","WTR110","WTR022","WTR062","WTR033","WTR063","WTR095","WTR135","WTR101","WTR077","WTR076"
        },
        -- pack #4 in box #7
        [4] = {
            "WTR192","WTR206","WTR191","WTR189","WTR042","WTR013","WTR123","WTR111","WTR029","WTR058","WTR030","WTR058","WTR100","WTR135","WTR096","WTR038","WTR003"
        },
        -- pack #5 in box #7
        [5] = {
            "WTR222","WTR220","WTR213","WTR202","WTR158","WTR165","WTR161","WTR070","WTR036","WTR058","WTR034","WTR133","WTR111","WTR137","WTR102","WTR078","WTR114"
        },
        -- pack #6 in box #7
        [6] = {
            "WTR192","WTR179","WTR187","WTR223","WTR152","WTR166","WTR053","WTR029","WTR068","WTR030","WTR064","WTR032","WTR136","WTR111","WTR133","WTR078","WTR038"
        },
        -- pack #7 in box #7
        [7] = {
            "WTR221","WTR199","WTR218","WTR196","WTR080","WTR017","WTR094","WTR069","WTR028","WTR063","WTR024","WTR067","WTR099","WTR146","WTR096","WTR075","WTR113"
        },
        -- pack #8 in box #7
        [8] = {
            "WTR207","WTR193","WTR184","WTR220","WTR080","WTR018","WTR173","WTR105","WTR057","WTR033","WTR061","WTR098","WTR144","WTR095","WTR143","WTR114","WTR076"
        },
        -- pack #9 in box #7
        [9] = {
            "WTR218","WTR214","WTR185","WTR213","WTR155","WTR092","WTR044","WTR187","WTR026","WTR059","WTR022","WTR139","WTR106","WTR132","WTR112","WTR113","WTR076"
        },
        -- pack #10 in box #7
        [10] = {
            "WTR223","WTR190","WTR199","WTR189","WTR117","WTR128","WTR122","WTR022","WTR035","WTR062","WTR037","WTR061","WTR096","WTR134","WTR097","WTR113","WTR076"
        },
        -- pack #11 in box #7
        [11] = {
            "WTR223","WTR186","WTR197","WTR195","WTR156","WTR171","WTR046","WTR209","WTR022","WTR063","WTR035","WTR148","WTR108","WTR149","WTR098","WTR115","WTR001"
        },
        -- pack #12 in box #7
        [12] = {
            "WTR212","WTR217","WTR221","WTR195","WTR152","WTR175","WTR087","WTR182","WTR059","WTR022","WTR067","WTR033","WTR136","WTR103","WTR143","WTR040","WTR115"
        },
        -- pack #13 in box #7
        [13] = {
            "WTR210","WTR186","WTR213","WTR219","WTR155","WTR172","WTR166","WTR180","WTR063","WTR034","WTR070","WTR026","WTR136","WTR111","WTR145","WTR039","WTR225"
        },
        -- pack #14 in box #7
        [14] = {
            "WTR217","WTR183","WTR221","WTR188","WTR080","WTR053","WTR091","WTR041","WTR058","WTR027","WTR064","WTR020","WTR143","WTR097","WTR145","WTR225","WTR039"
        },
        -- pack #15 in box #7
        [15] = {
            "WTR222","WTR182","WTR215","WTR199","WTR151","WTR087","WTR094","WTR051","WTR067","WTR034","WTR065","WTR107","WTR135","WTR112","WTR138","WTR076","WTR001"
        },
        -- pack #16 in box #7
        [16] = {
            "WTR199","WTR208","WTR197","WTR207","WTR117","WTR131","WTR015","WTR168","WTR027","WTR073","WTR022","WTR141","WTR105","WTR143","WTR102","WTR039","WTR003"
        },
        -- pack #17 in box #7
        [17] = {
            "WTR211","WTR223","WTR216","WTR197","WTR042","WTR128","WTR169","WTR145","WTR068","WTR035","WTR069","WTR025","WTR139","WTR097","WTR139","WTR038","WTR040"
        },
        -- pack #18 in box #7
        [18] = {
            "WTR197","WTR213","WTR223","WTR180","WTR158","WTR168","WTR166","WTR172","WTR035","WTR063","WTR027","WTR138","WTR109","WTR138","WTR110","WTR001","WTR076"
        },
        -- pack #19 in box #7
        [19] = {
            "WTR191","WTR214","WTR220","WTR190","WTR042","WTR011","WTR049","WTR148","WTR026","WTR069","WTR027","WTR063","WTR105","WTR141","WTR095","WTR078","WTR076"
        },
        -- pack #20 in box #7
        [20] = {
            "WTR177","WTR180","WTR194","WTR184","WTR042","WTR123","WTR009","WTR037","WTR069","WTR036","WTR070","WTR107","WTR138","WTR099","WTR136","WTR078","WTR003"
        },
        -- pack #21 in box #7
        [21] = {
            "WTR213","WTR213","WTR216","WTR204","WTR042","WTR092","WTR087","WTR103","WTR033","WTR071","WTR026","WTR137","WTR102","WTR133","WTR102","WTR114","WTR003"
        },
        -- pack #22 in box #7
        [22] = {
            "WTR210","WTR212","WTR217","WTR202","WTR156","WTR094","WTR165","WTR099","WTR060","WTR021","WTR069","WTR023","WTR144","WTR102","WTR138","WTR039","WTR078"
        },
        -- pack #23 in box #7
        [23] = {
            "WTR190","WTR189","WTR188","WTR188","WTR005","WTR091","WTR018","WTR147","WTR074","WTR026","WTR065","WTR101","WTR142","WTR110","WTR145","WTR114","WTR038"
        },
        -- pack #24 in box #7
        [24] = {
            "WTR190","WTR212","WTR216","WTR221","WTR042","WTR169","WTR019","WTR153","WTR034","WTR064","WTR020","WTR057","WTR103","WTR132","WTR106","WTR040","WTR002"
        },
    },
    -- box #8
    [8] = {
        -- pack #1 in box #8
        [1] = {
            "WTR210","WTR193","WTR217","WTR215","WTR080","WTR088","WTR012","WTR005","WTR030","WTR069","WTR033","WTR057","WTR098","WTR143","WTR110","WTR115","WTR002"
        },
        -- pack #2 in box #8
        [2] = {
            "WTR204","WTR206","WTR210","WTR191","WTR154","WTR172","WTR119","WTR108","WTR022","WTR061","WTR023","WTR074","WTR100","WTR149","WTR096","WTR115","WTR077"
        },
        -- pack #3 in box #8
        [3] = {
            "WTR191","WTR180","WTR197","WTR194","WTR158","WTR093","WTR056","WTR065","WTR059","WTR035","WTR069","WTR105","WTR147","WTR107","WTR141","WTR001","WTR076"
        },
        -- pack #4 in box #8
        [4] = {
            "WTR204","WTR205","WTR189","WTR216","WTR153","WTR087","WTR049","WTR084","WTR022","WTR068","WTR023","WTR061","WTR111","WTR144","WTR103","WTR040","WTR039"
        },
        -- pack #5 in box #8
        [5] = {
            "WTR196","WTR207","WTR218","WTR181","WTR158","WTR092","WTR090","WTR222","WTR020","WTR074","WTR020","WTR064","WTR103","WTR146","WTR107","WTR078","WTR002"
        },
        -- pack #6 in box #8
        [6] = {
            "WTR216","WTR178","WTR191","WTR177","WTR151","WTR052","WTR175","WTR101","WTR020","WTR057","WTR023","WTR136","WTR096","WTR133","WTR098","WTR038","WTR002"
        },
        -- pack #7 in box #8
        [7] = {
            "WTR176","WTR204","WTR198","WTR201","WTR157","WTR128","WTR130","WTR032","WTR028","WTR061","WTR035","WTR139","WTR095","WTR141","WTR107","WTR076","WTR113"
        },
        -- pack #8 in box #8
        [8] = {
            "WTR200","WTR181","WTR203","WTR178","WTR155","WTR093","WTR045","WTR034","WTR067","WTR033","WTR062","WTR025","WTR149","WTR107","WTR140","WTR001","WTR038"
        },
        -- pack #9 in box #8
        [9] = {
            "WTR176","WTR203","WTR201","WTR205","WTR153","WTR013","WTR131","WTR047","WTR026","WTR068","WTR024","WTR149","WTR107","WTR143","WTR106","WTR078","WTR038"
        },
        -- pack #10 in box #8
        [10] = {
            "WTR220","WTR176","WTR217","WTR179","WTR152","WTR170","WTR172","WTR104","WTR064","WTR028","WTR063","WTR025","WTR146","WTR107","WTR132","WTR038","WTR002"
        },
        -- pack #11 in box #8
        [11] = {
            "WTR187","WTR222","WTR222","WTR194","WTR154","WTR129","WTR092","WTR156","WTR062","WTR034","WTR062","WTR100","WTR134","WTR104","WTR149","WTR002","WTR001"
        },
        -- pack #12 in box #8
        [12] = {
            "WTR217","WTR192","WTR186","WTR217","WTR151","WTR054","WTR052","WTR079","WTR023","WTR069","WTR026","WTR138","WTR102","WTR139","WTR110","WTR040","WTR115"
        },
        -- pack #13 in box #8
        [13] = {
            "WTR186","WTR191","WTR196","WTR195","WTR156","WTR131","WTR088","WTR065","WTR067","WTR030","WTR061","WTR020","WTR137","WTR098","WTR140","WTR001","WTR075"
        },
        -- pack #14 in box #8
        [14] = {
            "WTR211","WTR220","WTR188","WTR191","WTR156","WTR014","WTR119","WTR181","WTR021","WTR063","WTR022","WTR140","WTR101","WTR148","WTR101","WTR038","WTR078"
        },
        -- pack #15 in box #8
        [15] = {
            "WTR200","WTR196","WTR183","WTR183","WTR152","WTR018","WTR118","WTR221","WTR072","WTR036","WTR067","WTR100","WTR143","WTR096","WTR140","WTR001","WTR038"
        },
        -- pack #16 in box #8
        [16] = {
            "WTR217","WTR207","WTR218","WTR184","WTR080","WTR088","WTR172","WTR186","WTR024","WTR062","WTR027","WTR057","WTR106","WTR147","WTR095","WTR001","WTR225"
        },
        -- pack #17 in box #8
        [17] = {
            "WTR200","WTR188","WTR182","WTR192","WTR156","WTR164","WTR088","WTR032","WTR071","WTR031","WTR067","WTR026","WTR138","WTR104","WTR135","WTR038","WTR003"
        },
        -- pack #18 in box #8
        [18] = {
            "WTR194","WTR187","WTR193","WTR193","WTR152","WTR089","WTR050","WTR069","WTR059","WTR026","WTR065","WTR027","WTR137","WTR099","WTR137","WTR040","WTR075"
        },
        -- pack #19 in box #8
        [19] = {
            "WTR218","WTR187","WTR201","WTR210","WTR151","WTR125","WTR046","WTR056","WTR021","WTR074","WTR037","WTR133","WTR110","WTR138","WTR112","WTR077","WTR113"
        },
        -- pack #20 in box #8
        [20] = {
            "WTR188","WTR201","WTR204","WTR221","WTR155","WTR054","WTR091","WTR091","WTR022","WTR064","WTR035","WTR063","WTR099","WTR134","WTR110","WTR038","WTR076"
        },
        -- pack #21 in box #8
        [21] = {
            "WTR176","WTR208","WTR187","WTR205","WTR157","WTR011","WTR174","WTR123","WTR074","WTR023","WTR070","WTR033","WTR139","WTR106","WTR147","WTR003","WTR001"
        },
        -- pack #22 in box #8
        [22] = {
            "WTR181","WTR203","WTR211","WTR187","WTR153","WTR016","WTR010","WTR058","WTR063","WTR030","WTR060","WTR096","WTR132","WTR101","WTR136","WTR225","WTR075"
        },
        -- pack #23 in box #8
        [23] = {
            "WTR180","WTR194","WTR190","WTR177","WTR117","WTR088","WTR164","WTR202","WTR074","WTR034","WTR073","WTR105","WTR136","WTR099","WTR139","WTR038","WTR078"
        },
        -- pack #24 in box #8
        [24] = {
            "WTR214","WTR190","WTR198","WTR194","WTR155","WTR089","WTR012","WTR007","WTR062","WTR031","WTR074","WTR111","WTR135","WTR103","WTR135","WTR077","WTR115"
        },
    },
    -- box #9
    [9] = {
        -- pack #1 in box #9
        [1] = {
            "WTR208","WTR220","WTR197","WTR176","WTR156","WTR171","WTR120","WTR218","WTR029","WTR064","WTR028","WTR138","WTR104","WTR141","WTR108","WTR040","WTR001"
        },
        -- pack #2 in box #9
        [2] = {
            "WTR210","WTR177","WTR203","WTR182","WTR156","WTR086","WTR051","WTR056","WTR072","WTR036","WTR070","WTR023","WTR138","WTR102","WTR146","WTR040","WTR078"
        },
        -- pack #3 in box #9
        [3] = {
            "WTR217","WTR191","WTR206","WTR203","WTR157","WTR131","WTR044","WTR060","WTR026","WTR059","WTR026","WTR134","WTR103","WTR147","WTR108","WTR115","WTR076"
        },
        -- pack #4 in box #9
        [4] = {
            "WTR213","WTR181","WTR210","WTR190","WTR158","WTR053","WTR121","WTR195","WTR067","WTR026","WTR069","WTR021","WTR140","WTR111","WTR137","WTR040","WTR075"
        },
        -- pack #5 in box #9
        [5] = {
            "WTR212","WTR196","WTR220","WTR209","WTR154","WTR055","WTR163","WTR133","WTR064","WTR035","WTR074","WTR027","WTR144","WTR107","WTR141","WTR115","WTR077"
        },
        -- pack #6 in box #9
        [6] = {
            "WTR190","WTR216","WTR213","WTR199","WTR151","WTR086","WTR052","WTR096","WTR020","WTR068","WTR036","WTR067","WTR106","WTR140","WTR108","WTR077","WTR001"
        },
        -- pack #7 in box #9
        [7] = {
            "WTR193","WTR220","WTR182","WTR209","WTR151","WTR091","WTR165","WTR173","WTR057","WTR037","WTR069","WTR106","WTR140","WTR098","WTR148","WTR038","WTR113"
        },
        -- pack #8 in box #9
        [8] = {
            "WTR194","WTR195","WTR194","WTR181","WTR042","WTR087","WTR161","WTR027","WTR026","WTR064","WTR026","WTR074","WTR095","WTR139","WTR102","WTR225","WTR003"
        },
        -- pack #9 in box #9
        [9] = {
            "WTR178","WTR185","WTR217","WTR204","WTR042","WTR123","WTR018","WTR210","WTR029","WTR066","WTR027","WTR134","WTR111","WTR139","WTR103","WTR003","WTR115"
        },
        -- pack #10 in box #9
        [10] = {
            "WTR223","WTR211","WTR188","WTR200","WTR151","WTR093","WTR127","WTR210","WTR028","WTR058","WTR022","WTR145","WTR108","WTR136","WTR097","WTR224"
        },
        -- pack #11 in box #9
        [11] = {
            "WTR210","WTR193","WTR209","WTR222","WTR005","WTR053","WTR094","WTR212","WTR064","WTR032","WTR064","WTR110","WTR135","WTR096","WTR144","WTR077","WTR039"
        },
        -- pack #12 in box #9
        [12] = {
            "WTR216","WTR207","WTR216","WTR190","WTR157","WTR050","WTR043","WTR097","WTR026","WTR060","WTR036","WTR066","WTR099","WTR132","WTR095","WTR001","WTR113"
        },
        -- pack #13 in box #9
        [13] = {
            "WTR201","WTR217","WTR176","WTR208","WTR005","WTR124","WTR163","WTR206","WTR074","WTR033","WTR064","WTR099","WTR142","WTR112","WTR142","WTR001","WTR078"
        },
        -- pack #14 in box #9
        [14] = {
            "WTR213","WTR190","WTR204","WTR179","WTR156","WTR054","WTR088","WTR204","WTR031","WTR059","WTR023","WTR149","WTR096","WTR145","WTR105","WTR225","WTR114"
        },
        -- pack #15 in box #9
        [15] = {
            "WTR176","WTR191","WTR207","WTR220","WTR080","WTR012","WTR013","WTR137","WTR064","WTR025","WTR062","WTR103","WTR135","WTR108","WTR147","WTR077","WTR225"
        },
        -- pack #16 in box #9
        [16] = {
            "WTR194","WTR205","WTR198","WTR221","WTR153","WTR175","WTR090","WTR191","WTR067","WTR023","WTR064","WTR096","WTR133","WTR111","WTR144","WTR224"
        },
        -- pack #17 in box #9
        [17] = {
            "WTR197","WTR196","WTR212","WTR220","WTR154","WTR087","WTR015","WTR147","WTR021","WTR073","WTR026","WTR070","WTR107","WTR134","WTR112","WTR075","WTR114"
        },
        -- pack #18 in box #9
        [18] = {
            "WTR203","WTR202","WTR207","WTR192","WTR153","WTR165","WTR171","WTR105","WTR059","WTR031","WTR063","WTR036","WTR149","WTR108","WTR137","WTR114","WTR115"
        },
        -- pack #19 in box #9
        [19] = {
            "WTR208","WTR196","WTR185","WTR190","WTR042","WTR129","WTR120","WTR141","WTR037","WTR070","WTR035","WTR057","WTR095","WTR147","WTR112","WTR003","WTR078"
        },
        -- pack #20 in box #9
        [20] = {
            "WTR214","WTR195","WTR207","WTR222","WTR151","WTR175","WTR047","WTR123","WTR025","WTR069","WTR024","WTR071","WTR104","WTR140","WTR099","WTR075","WTR040"
        },
        -- pack #21 in box #9
        [21] = {
            "WTR180","WTR204","WTR192","WTR221","WTR117","WTR175","WTR171","WTR069","WTR071","WTR031","WTR068","WTR030","WTR138","WTR106","WTR140","WTR075","WTR040"
        },
        -- pack #22 in box #9
        [22] = {
            "WTR223","WTR210","WTR199","WTR201","WTR154","WTR125","WTR054","WTR222","WTR061","WTR026","WTR061","WTR030","WTR147","WTR105","WTR143","WTR115","WTR076"
        },
        -- pack #23 in box #9
        [23] = {
            "WTR222","WTR191","WTR189","WTR198","WTR154","WTR173","WTR051","WTR194","WTR036","WTR060","WTR034","WTR137","WTR100","WTR143","WTR104","WTR039","WTR225"
        },
        -- pack #24 in box #9
        [24] = {
            "WTR205","WTR201","WTR200","WTR211","WTR117","WTR166","WTR014","WTR068","WTR060","WTR024","WTR065","WTR098","WTR143","WTR102","WTR135","WTR001","WTR077"
        },
    },
    -- box #10
    [10] = {
        -- pack #1 in box #10
        [1] = {
            "WTR180","WTR216","WTR195","WTR216","WTR151","WTR171","WTR161","WTR021","WTR069","WTR037","WTR073","WTR021","WTR134","WTR095","WTR138","WTR078","WTR002"
        },
        -- pack #2 in box #10
        [2] = {
            "WTR204","WTR214","WTR201","WTR194","WTR157","WTR127","WTR016","WTR096","WTR032","WTR064","WTR031","WTR060","WTR100","WTR134","WTR097","WTR225","WTR075"
        },
        -- pack #3 in box #10
        [3] = {
            "WTR182","WTR176","WTR194","WTR185","WTR005","WTR167","WTR083","WTR112","WTR073","WTR034","WTR064","WTR103","WTR148","WTR102","WTR140","WTR225","WTR115"
        },
        -- pack #4 in box #10
        [4] = {
            "WTR185","WTR201","WTR197","WTR205","WTR080","WTR175","WTR125","WTR004","WTR024","WTR070","WTR020","WTR073","WTR103","WTR134","WTR105","WTR076","WTR113"
        },
        -- pack #5 in box #10
        [5] = {
            "WTR199","WTR182","WTR181","WTR218","WTR151","WTR016","WTR172","WTR197","WTR061","WTR023","WTR064","WTR030","WTR140","WTR109","WTR132","WTR001","WTR075"
        },
        -- pack #6 in box #10
        [6] = {
            "WTR193","WTR216","WTR177","WTR186","WTR117","WTR015","WTR011","WTR092","WTR066","WTR025","WTR063","WTR028","WTR137","WTR097","WTR143","WTR075","WTR113"
        },
        -- pack #7 in box #10
        [7] = {
            "WTR199","WTR218","WTR218","WTR181","WTR005","WTR174","WTR131","WTR037","WTR073","WTR033","WTR066","WTR107","WTR142","WTR102","WTR149","WTR077","WTR038"
        },
        -- pack #8 in box #10
        [8] = {
            "WTR214","WTR189","WTR190","WTR180","WTR153","WTR175","WTR092","WTR193","WTR023","WTR065","WTR025","WTR140","WTR110","WTR149","WTR109","WTR114","WTR078"
        },
        -- pack #9 in box #10
        [9] = {
            "WTR220","WTR217","WTR217","WTR209","WTR154","WTR050","WTR056","WTR025","WTR059","WTR022","WTR058","WTR021","WTR148","WTR101","WTR143","WTR113","WTR077"
        },
        -- pack #10 in box #10
        [10] = {
            "WTR176","WTR200","WTR203","WTR185","WTR158","WTR130","WTR082","WTR131","WTR068","WTR030","WTR071","WTR100","WTR132","WTR096","WTR142","WTR075","WTR003"
        },
        -- pack #11 in box #10
        [11] = {
            "WTR185","WTR194","WTR194","WTR210","WTR157","WTR123","WTR009","WTR030","WTR030","WTR071","WTR037","WTR137","WTR106","WTR134","WTR105","WTR078","WTR038"
        },
        -- pack #12 in box #10
        [12] = {
            "WTR221","WTR206","WTR191","WTR191","WTR151","WTR015","WTR090","WTR032","WTR030","WTR070","WTR020","WTR144","WTR104","WTR141","WTR099","WTR078","WTR040"
        },
        -- pack #13 in box #10
        [13] = {
            "WTR214","WTR179","WTR181","WTR201","WTR117","WTR087","WTR010","WTR208","WTR027","WTR063","WTR033","WTR060","WTR101","WTR144","WTR103","WTR076","WTR038"
        },
        -- pack #14 in box #10
        [14] = {
            "WTR180","WTR176","WTR213","WTR183","WTR153","WTR051","WTR054","WTR181","WTR061","WTR036","WTR064","WTR108","WTR138","WTR108","WTR146","WTR040","WTR039"
        },
        -- pack #15 in box #10
        [15] = {
            "WTR191","WTR223","WTR202","WTR220","WTR151","WTR049","WTR126","WTR154","WTR033","WTR072","WTR036","WTR059","WTR108","WTR145","WTR099","WTR114","WTR077"
        },
        -- pack #16 in box #10
        [16] = {
            "WTR212","WTR212","WTR221","WTR178","WTR042","WTR126","WTR049","WTR149","WTR060","WTR021","WTR071","WTR025","WTR141","WTR107","WTR147","WTR003","WTR078"
        },
        -- pack #17 in box #10
        [17] = {
            "WTR189","WTR186","WTR185","WTR176","WTR080","WTR124","WTR048","WTR125","WTR024","WTR074","WTR036","WTR065","WTR102","WTR134","WTR106","WTR114","WTR078"
        },
        -- pack #18 in box #10
        [18] = {
            "WTR195","WTR194","WTR216","WTR220","WTR158","WTR011","WTR055","WTR110","WTR057","WTR026","WTR059","WTR104","WTR137","WTR109","WTR138","WTR113","WTR003"
        },
        -- pack #19 in box #10
        [19] = {
            "WTR193","WTR179","WTR190","WTR210","WTR155","WTR088","WTR006","WTR213","WTR065","WTR036","WTR064","WTR027","WTR137","WTR104","WTR147","WTR075","WTR076"
        },
        -- pack #20 in box #10
        [20] = {
            "WTR212","WTR184","WTR213","WTR181","WTR153","WTR171","WTR087","WTR108","WTR034","WTR062","WTR033","WTR139","WTR101","WTR139","WTR108","WTR078","WTR001"
        },
        -- pack #21 in box #10
        [21] = {
            "WTR202","WTR176","WTR204","WTR213","WTR080","WTR051","WTR008","WTR188","WTR022","WTR073","WTR027","WTR132","WTR097","WTR135","WTR095","WTR225","WTR001"
        },
        -- pack #22 in box #10
        [22] = {
            "WTR190","WTR203","WTR218","WTR189","WTR080","WTR054","WTR121","WTR132","WTR063","WTR029","WTR071","WTR110","WTR144","WTR097","WTR144","WTR001","WTR039"
        },
        -- pack #23 in box #10
        [23] = {
            "WTR187","WTR218","WTR219","WTR188","WTR155","WTR172","WTR092","WTR065","WTR023","WTR070","WTR026","WTR147","WTR102","WTR140","WTR106","WTR224"
        },
        -- pack #24 in box #10
        [24] = {
            "WTR192","WTR202","WTR215","WTR187","WTR152","WTR167","WTR173","WTR033","WTR021","WTR068","WTR028","WTR072","WTR106","WTR135","WTR095","WTR078","WTR039"
        },
    },
    -- box #11
    [11] = {
        -- pack #1 in box #11
        [1] = {
            "WTR188","WTR214","WTR178","WTR207","WTR154","WTR049","WTR124","WTR123","WTR058","WTR022","WTR070","WTR034","WTR141","WTR112","WTR145","WTR003","WTR078"
        },
        -- pack #2 in box #11
        [2] = {
            "WTR186","WTR200","WTR216","WTR181","WTR156","WTR168","WTR174","WTR084","WTR059","WTR030","WTR068","WTR098","WTR149","WTR103","WTR142","WTR114","WTR225"
        },
        -- pack #3 in box #11
        [3] = {
            "WTR185","WTR223","WTR189","WTR201","WTR080","WTR016","WTR131","WTR095","WTR037","WTR068","WTR028","WTR133","WTR100","WTR136","WTR101","WTR040","WTR076"
        },
        -- pack #4 in box #11
        [4] = {
            "WTR212","WTR182","WTR180","WTR213","WTR155","WTR128","WTR050","WTR090","WTR070","WTR026","WTR067","WTR021","WTR144","WTR108","WTR147","WTR075","WTR113"
        },
        -- pack #5 in box #11
        [5] = {
            "WTR223","WTR215","WTR181","WTR213","WTR156","WTR127","WTR129","WTR107","WTR030","WTR065","WTR022","WTR064","WTR099","WTR148","WTR102","WTR001","WTR076"
        },
        -- pack #6 in box #11
        [6] = {
            "WTR184","WTR207","WTR215","WTR207","WTR154","WTR171","WTR174","WTR212","WTR028","WTR070","WTR035","WTR137","WTR101","WTR136","WTR106","WTR115","WTR114"
        },
        -- pack #7 in box #11
        [7] = {
            "WTR180","WTR203","WTR202","WTR209","WTR158","WTR086","WTR125","WTR142","WTR071","WTR028","WTR072","WTR037","WTR143","WTR106","WTR148","WTR114","WTR225"
        },
        -- pack #8 in box #11
        [8] = {
            "WTR210","WTR204","WTR185","WTR195","WTR152","WTR126","WTR089","WTR034","WTR032","WTR069","WTR032","WTR071","WTR112","WTR149","WTR098","WTR003","WTR225"
        },
        -- pack #9 in box #11
        [9] = {
            "WTR182","WTR192","WTR217","WTR210","WTR080","WTR128","WTR015","WTR144","WTR061","WTR032","WTR074","WTR103","WTR149","WTR101","WTR143","WTR001","WTR040"
        },
        -- pack #10 in box #11
        [10] = {
            "WTR191","WTR177","WTR179","WTR206","WTR156","WTR086","WTR090","WTR207","WTR070","WTR025","WTR059","WTR095","WTR132","WTR111","WTR148","WTR113","WTR115"
        },
        -- pack #11 in box #11
        [11] = {
            "WTR193","WTR188","WTR204","WTR210","WTR080","WTR166","WTR126","WTR122","WTR058","WTR021","WTR074","WTR098","WTR146","WTR104","WTR133","WTR077","WTR115"
        },
        -- pack #12 in box #11
        [12] = {
            "WTR199","WTR220","WTR209","WTR198","WTR117","WTR087","WTR125","WTR217","WTR026","WTR063","WTR024","WTR132","WTR112","WTR143","WTR097","WTR039","WTR075"
        },
        -- pack #13 in box #11
        [13] = {
            "WTR199","WTR197","WTR205","WTR178","WTR158","WTR087","WTR082","WTR021","WTR058","WTR033","WTR074","WTR031","WTR148","WTR108","WTR140","WTR077","WTR076"
        },
        -- pack #14 in box #11
        [14] = {
            "WTR206","WTR204","WTR199","WTR220","WTR153","WTR091","WTR175","WTR190","WTR020","WTR060","WTR026","WTR061","WTR099","WTR137","WTR095","WTR077","WTR038"
        },
        -- pack #15 in box #11
        [15] = {
            "WTR211","WTR187","WTR204","WTR212","WTR080","WTR052","WTR084","WTR024","WTR069","WTR026","WTR058","WTR027","WTR133","WTR103","WTR146","WTR225","WTR040"
        },
        -- pack #16 in box #11
        [16] = {
            "WTR187","WTR221","WTR220","WTR200","WTR117","WTR013","WTR172","WTR026","WTR029","WTR074","WTR022","WTR062","WTR104","WTR145","WTR112","WTR076","WTR038"
        },
        -- pack #17 in box #11
        [17] = {
            "WTR193","WTR211","WTR190","WTR214","WTR157","WTR128","WTR008","WTR018","WTR074","WTR035","WTR063","WTR033","WTR133","WTR105","WTR147","WTR114","WTR076"
        },
        -- pack #18 in box #11
        [18] = {
            "WTR181","WTR213","WTR181","WTR200","WTR158","WTR016","WTR124","WTR018","WTR022","WTR061","WTR022","WTR141","WTR104","WTR136","WTR109","WTR038","WTR225"
        },
        -- pack #19 in box #11
        [19] = {
            "WTR190","WTR193","WTR223","WTR197","WTR005","WTR174","WTR085","WTR087","WTR036","WTR061","WTR028","WTR073","WTR097","WTR142","WTR098","WTR076","WTR075"
        },
        -- pack #20 in box #11
        [20] = {
            "WTR181","WTR177","WTR217","WTR185","WTR152","WTR131","WTR050","WTR139","WTR068","WTR021","WTR069","WTR110","WTR140","WTR110","WTR139","WTR077","WTR113"
        },
        -- pack #21 in box #11
        [21] = {
            "WTR178","WTR190","WTR191","WTR218","WTR158","WTR172","WTR012","WTR146","WTR037","WTR060","WTR035","WTR143","WTR108","WTR146","WTR104","WTR114","WTR039"
        },
        -- pack #22 in box #11
        [22] = {
            "WTR191","WTR176","WTR211","WTR176","WTR080","WTR171","WTR169","WTR111","WTR065","WTR034","WTR067","WTR111","WTR137","WTR112","WTR141","WTR076","WTR077"
        },
        -- pack #23 in box #11
        [23] = {
            "WTR208","WTR203","WTR219","WTR219","WTR042","WTR127","WTR131","WTR144","WTR032","WTR066","WTR022","WTR065","WTR104","WTR147","WTR103","WTR113","WTR039"
        },
        -- pack #24 in box #11
        [24] = {
            "WTR197","WTR184","WTR178","WTR192","WTR005","WTR174","WTR016","WTR129","WTR034","WTR063","WTR027","WTR132","WTR098","WTR141","WTR109","WTR039","WTR115"
        },
    },
    -- box #12
    [12] = {
        -- pack #1 in box #12
        [1] = {
            "WTR193","WTR185","WTR179","WTR215","WTR157","WTR164","WTR008","WTR048","WTR057","WTR024","WTR074","WTR100","WTR136","WTR095","WTR132","WTR002","WTR038"
        },
        -- pack #2 in box #12
        [2] = {
            "WTR189","WTR208","WTR217","WTR187","WTR156","WTR169","WTR173","WTR197","WTR065","WTR035","WTR069","WTR110","WTR138","WTR100","WTR142","WTR002","WTR003"
        },
        -- pack #3 in box #12
        [3] = {
            "WTR199","WTR198","WTR201","WTR186","WTR154","WTR088","WTR120","WTR074","WTR065","WTR034","WTR070","WTR101","WTR135","WTR111","WTR142","WTR224"
        },
        -- pack #4 in box #12
        [4] = {
            "WTR192","WTR185","WTR204","WTR212","WTR042","WTR086","WTR175","WTR197","WTR060","WTR033","WTR058","WTR021","WTR132","WTR099","WTR137","WTR039","WTR077"
        },
        -- pack #5 in box #12
        [5] = {
            "WTR187","WTR204","WTR190","WTR200","WTR155","WTR016","WTR046","WTR026","WTR031","WTR057","WTR029","WTR139","WTR106","WTR135","WTR106","WTR078","WTR077"
        },
        -- pack #6 in box #12
        [6] = {
            "WTR200","WTR185","WTR219","WTR205","WTR157","WTR050","WTR128","WTR213","WTR033","WTR061","WTR024","WTR073","WTR095","WTR138","WTR099","WTR225","WTR001"
        },
        -- pack #7 in box #12
        [7] = {
            "WTR184","WTR183","WTR220","WTR208","WTR117","WTR015","WTR172","WTR053","WTR023","WTR066","WTR032","WTR139","WTR098","WTR147","WTR097","WTR040","WTR113"
        },
        -- pack #8 in box #12
        [8] = {
            "WTR184","WTR193","WTR176","WTR200","WTR080","WTR056","WTR165","WTR176","WTR030","WTR066","WTR026","WTR063","WTR102","WTR144","WTR105","WTR077","WTR078"
        },
        -- pack #9 in box #12
        [9] = {
            "WTR219","WTR194","WTR180","WTR196","WTR156","WTR052","WTR094","WTR185","WTR031","WTR068","WTR032","WTR142","WTR110","WTR138","WTR104","WTR115","WTR038"
        },
        -- pack #10 in box #12
        [10] = {
            "WTR215","WTR219","WTR190","WTR220","WTR151","WTR012","WTR012","WTR108","WTR063","WTR030","WTR074","WTR109","WTR146","WTR101","WTR134","WTR115","WTR002"
        },
        -- pack #11 in box #12
        [11] = {
            "WTR204","WTR195","WTR189","WTR216","WTR152","WTR093","WTR013","WTR041","WTR074","WTR020","WTR065","WTR105","WTR138","WTR106","WTR148","WTR040","WTR115"
        },
        -- pack #12 in box #12
        [12] = {
            "WTR222","WTR198","WTR201","WTR218","WTR153","WTR093","WTR081","WTR061","WTR067","WTR029","WTR073","WTR020","WTR138","WTR110","WTR142","WTR001","WTR002"
        },
        -- pack #13 in box #12
        [13] = {
            "WTR192","WTR210","WTR196","WTR221","WTR154","WTR124","WTR125","WTR082","WTR022","WTR074","WTR020","WTR060","WTR097","WTR141","WTR105","WTR115","WTR003"
        },
        -- pack #14 in box #12
        [14] = {
            "WTR203","WTR212","WTR185","WTR210","WTR152","WTR013","WTR008","WTR220","WTR070","WTR021","WTR067","WTR100","WTR142","WTR106","WTR146","WTR224"
        },
        -- pack #15 in box #12
        [15] = {
            "WTR207","WTR187","WTR217","WTR198","WTR155","WTR173","WTR125","WTR164","WTR074","WTR030","WTR060","WTR023","WTR144","WTR100","WTR143","WTR001","WTR114"
        },
        -- pack #16 in box #12
        [16] = {
            "WTR178","WTR176","WTR201","WTR195","WTR155","WTR052","WTR130","WTR011","WTR026","WTR071","WTR030","WTR057","WTR105","WTR142","WTR095","WTR039","WTR040"
        },
        -- pack #17 in box #12
        [17] = {
            "WTR197","WTR180","WTR178","WTR193","WTR005","WTR051","WTR165","WTR179","WTR032","WTR066","WTR028","WTR145","WTR109","WTR148","WTR109","WTR225","WTR002"
        },
        -- pack #18 in box #12
        [18] = {
            "WTR176","WTR179","WTR209","WTR216","WTR151","WTR126","WTR018","WTR029","WTR062","WTR034","WTR057","WTR030","WTR132","WTR096","WTR139","WTR075","WTR001"
        },
        -- pack #19 in box #12
        [19] = {
            "WTR178","WTR222","WTR200","WTR177","WTR158","WTR053","WTR054","WTR071","WTR024","WTR072","WTR030","WTR073","WTR108","WTR137","WTR100","WTR038","WTR115"
        },
        -- pack #20 in box #12
        [20] = {
            "WTR189","WTR221","WTR193","WTR201","WTR156","WTR126","WTR130","WTR223","WTR061","WTR020","WTR068","WTR029","WTR139","WTR097","WTR146","WTR224"
        },
        -- pack #21 in box #12
        [21] = {
            "WTR207","WTR184","WTR177","WTR179","WTR157","WTR092","WTR174","WTR189","WTR022","WTR063","WTR026","WTR133","WTR109","WTR148","WTR100","WTR038","WTR040"
        },
        -- pack #22 in box #12
        [22] = {
            "WTR209","WTR194","WTR187","WTR178","WTR154","WTR094","WTR125","WTR169","WTR031","WTR068","WTR024","WTR067","WTR111","WTR134","WTR101","WTR077","WTR003"
        },
        -- pack #23 in box #12
        [23] = {
            "WTR221","WTR216","WTR197","WTR184","WTR158","WTR013","WTR086","WTR025","WTR035","WTR071","WTR032","WTR138","WTR105","WTR134","WTR110","WTR040","WTR114"
        },
        -- pack #24 in box #12
        [24] = {
            "WTR215","WTR185","WTR204","WTR211","WTR152","WTR127","WTR165","WTR025","WTR065","WTR031","WTR070","WTR031","WTR142","WTR106","WTR146","WTR114","WTR225"
        },
    },
    -- box #13
    [13] = {
        -- pack #1 in box #13
        [1] = {
            "WTR211","WTR214","WTR209","WTR192","WTR154","WTR125","WTR174","WTR015","WTR020","WTR060","WTR022","WTR137","WTR112","WTR139","WTR107","WTR001","WTR039"
        },
        -- pack #2 in box #13
        [2] = {
            "WTR180","WTR213","WTR178","WTR179","WTR153","WTR088","WTR011","WTR071","WTR074","WTR036","WTR062","WTR035","WTR135","WTR101","WTR137","WTR224"
        },
        -- pack #3 in box #13
        [3] = {
            "WTR191","WTR188","WTR195","WTR178","WTR154","WTR128","WTR013","WTR110","WTR037","WTR059","WTR025","WTR148","WTR106","WTR149","WTR101","WTR001","WTR003"
        },
        -- pack #4 in box #13
        [4] = {
            "WTR192","WTR192","WTR194","WTR193","WTR156","WTR130","WTR019","WTR063","WTR020","WTR070","WTR028","WTR066","WTR111","WTR145","WTR097","WTR038","WTR113"
        },
        -- pack #5 in box #13
        [5] = {
            "WTR211","WTR208","WTR190","WTR180","WTR152","WTR050","WTR124","WTR074","WTR022","WTR068","WTR022","WTR072","WTR098","WTR135","WTR106","WTR224"
        },
        -- pack #6 in box #13
        [6] = {
            "WTR216","WTR223","WTR188","WTR214","WTR042","WTR087","WTR054","WTR132","WTR068","WTR021","WTR062","WTR103","WTR135","WTR100","WTR146","WTR224"
        },
        -- pack #7 in box #13
        [7] = {
            "WTR206","WTR208","WTR183","WTR221","WTR154","WTR016","WTR166","WTR058","WTR037","WTR065","WTR024","WTR061","WTR110","WTR137","WTR098","WTR040","WTR038"
        },
        -- pack #8 in box #13
        [8] = {
            "WTR221","WTR217","WTR214","WTR190","WTR117","WTR131","WTR164","WTR030","WTR071","WTR031","WTR069","WTR105","WTR147","WTR100","WTR148","WTR003","WTR225"
        },
        -- pack #9 in box #13
        [9] = {
            "WTR199","WTR214","WTR176","WTR199","WTR154","WTR049","WTR169","WTR102","WTR035","WTR059","WTR033","WTR143","WTR112","WTR142","WTR110","WTR001","WTR075"
        },
        -- pack #10 in box #13
        [10] = {
            "WTR186","WTR208","WTR192","WTR177","WTR153","WTR013","WTR090","WTR072","WTR057","WTR033","WTR061","WTR109","WTR145","WTR110","WTR135","WTR225","WTR113"
        },
        -- pack #11 in box #13
        [11] = {
            "WTR216","WTR188","WTR197","WTR209","WTR151","WTR017","WTR010","WTR170","WTR029","WTR061","WTR031","WTR138","WTR111","WTR142","WTR099","WTR076","WTR003"
        },
        -- pack #12 in box #13
        [12] = {
            "WTR223","WTR188","WTR176","WTR205","WTR042","WTR130","WTR125","WTR196","WTR037","WTR072","WTR021","WTR062","WTR096","WTR146","WTR097","WTR115","WTR076"
        },
        -- pack #13 in box #13
        [13] = {
            "WTR197","WTR215","WTR200","WTR217","WTR152","WTR056","WTR167","WTR107","WTR032","WTR070","WTR023","WTR065","WTR101","WTR134","WTR107","WTR076","WTR115"
        },
        -- pack #14 in box #13
        [14] = {
            "WTR191","WTR176","WTR178","WTR217","WTR157","WTR174","WTR088","WTR193","WTR058","WTR020","WTR074","WTR033","WTR149","WTR097","WTR143","WTR224"
        },
        -- pack #15 in box #13
        [15] = {
            "WTR216","WTR180","WTR191","WTR176","WTR117","WTR171","WTR125","WTR188","WTR025","WTR060","WTR031","WTR143","WTR108","WTR136","WTR107","WTR224"
        },
        -- pack #16 in box #13
        [16] = {
            "WTR184","WTR200","WTR178","WTR185","WTR157","WTR053","WTR055","WTR099","WTR061","WTR031","WTR072","WTR109","WTR142","WTR106","WTR141","WTR115","WTR078"
        },
        -- pack #17 in box #13
        [17] = {
            "WTR214","WTR217","WTR219","WTR209","WTR154","WTR127","WTR129","WTR159","WTR036","WTR063","WTR031","WTR072","WTR099","WTR136","WTR095","WTR040","WTR076"
        },
        -- pack #18 in box #13
        [18] = {
            "WTR179","WTR184","WTR215","WTR218","WTR158","WTR015","WTR128","WTR108","WTR059","WTR029","WTR062","WTR031","WTR146","WTR109","WTR146","WTR075","WTR114"
        },
        -- pack #19 in box #13
        [19] = {
            "WTR188","WTR213","WTR209","WTR178","WTR156","WTR173","WTR170","WTR155","WTR065","WTR029","WTR064","WTR029","WTR134","WTR111","WTR142","WTR113","WTR075"
        },
        -- pack #20 in box #13
        [20] = {
            "WTR199","WTR210","WTR200","WTR213","WTR154","WTR052","WTR164","WTR135","WTR057","WTR026","WTR067","WTR102","WTR139","WTR106","WTR137","WTR038","WTR113"
        },
        -- pack #21 in box #13
        [21] = {
            "WTR223","WTR178","WTR204","WTR208","WTR151","WTR018","WTR014","WTR170","WTR026","WTR070","WTR020","WTR145","WTR095","WTR148","WTR108","WTR001","WTR003"
        },
        -- pack #22 in box #13
        [22] = {
            "WTR190","WTR182","WTR179","WTR219","WTR042","WTR127","WTR173","WTR008","WTR058","WTR031","WTR072","WTR035","WTR136","WTR101","WTR137","WTR114","WTR039"
        },
        -- pack #23 in box #13
        [23] = {
            "WTR197","WTR221","WTR189","WTR190","WTR005","WTR017","WTR126","WTR057","WTR057","WTR034","WTR058","WTR024","WTR140","WTR099","WTR142","WTR002","WTR075"
        },
        -- pack #24 in box #13
        [24] = {
            "WTR199","WTR210","WTR190","WTR207","WTR080","WTR014","WTR054","WTR100","WTR068","WTR036","WTR058","WTR108","WTR136","WTR096","WTR143","WTR002","WTR001"
        },
    },
    -- box #14
    [14] = {
        -- pack #1 in box #14
        [1] = {
            "WTR182","WTR212","WTR204","WTR197","WTR117","WTR019","WTR162","WTR212","WTR066","WTR035","WTR069","WTR112","WTR147","WTR096","WTR132","WTR039","WTR001"
        },
        -- pack #2 in box #14
        [2] = {
            "WTR223","WTR197","WTR181","WTR199","WTR154","WTR126","WTR092","WTR021","WTR071","WTR029","WTR066","WTR097","WTR148","WTR108","WTR143","WTR040","WTR077"
        },
        -- pack #3 in box #14
        [3] = {
            "WTR192","WTR193","WTR223","WTR214","WTR155","WTR171","WTR129","WTR124","WTR031","WTR066","WTR035","WTR132","WTR100","WTR133","WTR095","WTR001","WTR114"
        },
        -- pack #4 in box #14
        [4] = {
            "WTR194","WTR183","WTR196","WTR196","WTR154","WTR016","WTR162","WTR091","WTR058","WTR026","WTR067","WTR111","WTR142","WTR103","WTR133","WTR076","WTR003"
        },
        -- pack #5 in box #14
        [5] = {
            "WTR181","WTR192","WTR223","WTR190","WTR151","WTR129","WTR015","WTR073","WTR025","WTR071","WTR034","WTR064","WTR102","WTR146","WTR104","WTR077","WTR040"
        },
        -- pack #6 in box #14
        [6] = {
            "WTR223","WTR191","WTR215","WTR182","WTR080","WTR092","WTR125","WTR153","WTR066","WTR026","WTR063","WTR104","WTR145","WTR098","WTR139","WTR075","WTR039"
        },
        -- pack #7 in box #14
        [7] = {
            "WTR209","WTR194","WTR208","WTR222","WTR155","WTR015","WTR047","WTR062","WTR021","WTR058","WTR037","WTR066","WTR101","WTR133","WTR112","WTR039","WTR001"
        },
        -- pack #8 in box #14
        [8] = {
            "WTR207","WTR197","WTR220","WTR218","WTR005","WTR171","WTR085","WTR157","WTR071","WTR020","WTR068","WTR034","WTR138","WTR102","WTR146","WTR078","WTR039"
        },
        -- pack #9 in box #14
        [9] = {
            "WTR198","WTR217","WTR198","WTR184","WTR155","WTR086","WTR043","WTR141","WTR059","WTR037","WTR067","WTR022","WTR147","WTR103","WTR134","WTR078","WTR002"
        },
        -- pack #10 in box #14
        [10] = {
            "WTR218","WTR211","WTR215","WTR200","WTR151","WTR089","WTR083","WTR036","WTR067","WTR031","WTR068","WTR035","WTR132","WTR105","WTR133","WTR225","WTR077"
        },
        -- pack #11 in box #14
        [11] = {
            "WTR199","WTR200","WTR206","WTR195","WTR154","WTR092","WTR048","WTR176","WTR020","WTR071","WTR024","WTR134","WTR101","WTR149","WTR101","WTR039","WTR001"
        },
        -- pack #12 in box #14
        [12] = {
            "WTR217","WTR210","WTR214","WTR210","WTR151","WTR015","WTR013","WTR030","WTR069","WTR021","WTR058","WTR107","WTR147","WTR103","WTR134","WTR075","WTR113"
        },
        -- pack #13 in box #14
        [13] = {
            "WTR176","WTR193","WTR195","WTR199","WTR117","WTR092","WTR093","WTR166","WTR025","WTR057","WTR026","WTR066","WTR099","WTR146","WTR105","WTR003","WTR076"
        },
        -- pack #14 in box #14
        [14] = {
            "WTR204","WTR197","WTR209","WTR195","WTR152","WTR164","WTR123","WTR131","WTR037","WTR074","WTR020","WTR148","WTR107","WTR134","WTR105","WTR076","WTR077"
        },
        -- pack #15 in box #14
        [15] = {
            "WTR218","WTR183","WTR179","WTR181","WTR153","WTR088","WTR006","WTR025","WTR026","WTR064","WTR030","WTR140","WTR107","WTR141","WTR104","WTR076","WTR113"
        },
        -- pack #16 in box #14
        [16] = {
            "WTR207","WTR210","WTR206","WTR179","WTR153","WTR049","WTR011","WTR088","WTR057","WTR030","WTR072","WTR036","WTR133","WTR097","WTR139","WTR114","WTR077"
        },
        -- pack #17 in box #14
        [17] = {
            "WTR221","WTR220","WTR215","WTR188","WTR151","WTR017","WTR019","WTR064","WTR025","WTR068","WTR036","WTR066","WTR105","WTR138","WTR106","WTR003","WTR114"
        },
        -- pack #18 in box #14
        [18] = {
            "WTR220","WTR209","WTR193","WTR204","WTR080","WTR170","WTR017","WTR184","WTR031","WTR070","WTR033","WTR139","WTR109","WTR148","WTR105","WTR003","WTR075"
        },
        -- pack #19 in box #14
        [19] = {
            "WTR179","WTR204","WTR204","WTR180","WTR154","WTR168","WTR050","WTR221","WTR066","WTR033","WTR066","WTR021","WTR144","WTR111","WTR144","WTR225","WTR114"
        },
        -- pack #20 in box #14
        [20] = {
            "WTR214","WTR215","WTR184","WTR184","WTR157","WTR175","WTR165","WTR186","WTR036","WTR072","WTR032","WTR058","WTR107","WTR147","WTR106","WTR078","WTR115"
        },
        -- pack #21 in box #14
        [21] = {
            "WTR208","WTR219","WTR181","WTR206","WTR042","WTR014","WTR054","WTR175","WTR029","WTR064","WTR030","WTR070","WTR111","WTR139","WTR103","WTR040","WTR039"
        },
        -- pack #22 in box #14
        [22] = {
            "WTR184","WTR220","WTR222","WTR182","WTR153","WTR126","WTR050","WTR031","WTR061","WTR028","WTR070","WTR108","WTR142","WTR099","WTR137","WTR224"
        },
        -- pack #23 in box #14
        [23] = {
            "WTR218","WTR209","WTR192","WTR204","WTR153","WTR175","WTR089","WTR074","WTR034","WTR074","WTR021","WTR137","WTR101","WTR149","WTR109","WTR115","WTR039"
        },
        -- pack #24 in box #14
        [24] = {
            "WTR222","WTR188","WTR223","WTR208","WTR155","WTR094","WTR019","WTR209","WTR066","WTR030","WTR060","WTR031","WTR149","WTR108","WTR145","WTR076","WTR039"
        },
    },
    -- box #15
    [15] = {
        -- pack #1 in box #15
        [1] = {
            "WTR220","WTR192","WTR210","WTR207","WTR005","WTR123","WTR056","WTR216","WTR027","WTR058","WTR037","WTR061","WTR109","WTR135","WTR110","WTR077","WTR076"
        },
        -- pack #2 in box #15
        [2] = {
            "WTR194","WTR202","WTR219","WTR178","WTR151","WTR164","WTR088","WTR100","WTR074","WTR025","WTR058","WTR098","WTR146","WTR101","WTR135","WTR040","WTR038"
        },
        -- pack #3 in box #15
        [3] = {
            "WTR206","WTR179","WTR186","WTR201","WTR080","WTR091","WTR054","WTR208","WTR034","WTR059","WTR033","WTR145","WTR095","WTR138","WTR098","WTR001","WTR075"
        },
        -- pack #4 in box #15
        [4] = {
            "WTR219","WTR210","WTR186","WTR197","WTR117","WTR053","WTR053","WTR033","WTR033","WTR070","WTR031","WTR133","WTR097","WTR139","WTR099","WTR115","WTR075"
        },
        -- pack #5 in box #15
        [5] = {
            "WTR205","WTR183","WTR199","WTR192","WTR005","WTR092","WTR012","WTR178","WTR074","WTR036","WTR064","WTR037","WTR147","WTR102","WTR143","WTR002","WTR038"
        },
        -- pack #6 in box #15
        [6] = {
            "WTR177","WTR183","WTR219","WTR176","WTR152","WTR126","WTR086","WTR057","WTR065","WTR021","WTR065","WTR100","WTR148","WTR097","WTR132","WTR038","WTR113"
        },
        -- pack #7 in box #15
        [7] = {
            "WTR209","WTR219","WTR181","WTR188","WTR153","WTR131","WTR088","WTR176","WTR060","WTR021","WTR072","WTR025","WTR132","WTR104","WTR139","WTR001","WTR040"
        },
        -- pack #8 in box #15
        [8] = {
            "WTR191","WTR207","WTR186","WTR198","WTR156","WTR019","WTR088","WTR099","WTR063","WTR026","WTR060","WTR025","WTR139","WTR107","WTR149","WTR114","WTR077"
        },
        -- pack #9 in box #15
        [9] = {
            "WTR204","WTR178","WTR194","WTR191","WTR080","WTR049","WTR047","WTR184","WTR025","WTR060","WTR025","WTR063","WTR108","WTR136","WTR102","WTR224"
        },
        -- pack #10 in box #15
        [10] = {
            "WTR203","WTR205","WTR191","WTR220","WTR151","WTR172","WTR167","WTR203","WTR032","WTR061","WTR026","WTR067","WTR100","WTR149","WTR100","WTR114","WTR078"
        },
        -- pack #11 in box #15
        [11] = {
            "WTR210","WTR207","WTR192","WTR178","WTR153","WTR125","WTR162","WTR187","WTR030","WTR064","WTR022","WTR134","WTR099","WTR136","WTR100","WTR075","WTR077"
        },
        -- pack #12 in box #15
        [12] = {
            "WTR189","WTR221","WTR198","WTR197","WTR042","WTR168","WTR128","WTR184","WTR024","WTR072","WTR033","WTR070","WTR100","WTR143","WTR096","WTR003","WTR113"
        },
        -- pack #13 in box #15
        [13] = {
            "WTR188","WTR179","WTR185","WTR219","WTR158","WTR014","WTR046","WTR214","WTR020","WTR070","WTR036","WTR146","WTR105","WTR135","WTR112","WTR002","WTR114"
        },
        -- pack #14 in box #15
        [14] = {
            "WTR191","WTR223","WTR202","WTR205","WTR158","WTR130","WTR125","WTR022","WTR027","WTR072","WTR026","WTR064","WTR107","WTR140","WTR105","WTR077","WTR075"
        },
        -- pack #15 in box #15
        [15] = {
            "WTR177","WTR211","WTR195","WTR216","WTR158","WTR131","WTR009","WTR175","WTR020","WTR063","WTR033","WTR143","WTR108","WTR141","WTR097","WTR040","WTR075"
        },
        -- pack #16 in box #15
        [16] = {
            "WTR187","WTR187","WTR220","WTR186","WTR158","WTR165","WTR052","WTR223","WTR033","WTR059","WTR035","WTR068","WTR096","WTR149","WTR101","WTR224"
        },
        -- pack #17 in box #15
        [17] = {
            "WTR187","WTR200","WTR187","WTR197","WTR080","WTR019","WTR052","WTR068","WTR065","WTR025","WTR062","WTR104","WTR133","WTR103","WTR142","WTR078","WTR075"
        },
        -- pack #18 in box #15
        [18] = {
            "WTR217","WTR180","WTR176","WTR182","WTR155","WTR167","WTR017","WTR204","WTR057","WTR035","WTR073","WTR098","WTR147","WTR104","WTR138","WTR040","WTR039"
        },
        -- pack #19 in box #15
        [19] = {
            "WTR206","WTR203","WTR198","WTR222","WTR042","WTR086","WTR055","WTR137","WTR071","WTR029","WTR074","WTR033","WTR138","WTR103","WTR133","WTR113","WTR115"
        },
        -- pack #20 in box #15
        [20] = {
            "WTR218","WTR210","WTR206","WTR188","WTR156","WTR171","WTR083","WTR161","WTR060","WTR020","WTR073","WTR033","WTR143","WTR104","WTR143","WTR076","WTR002"
        },
        -- pack #21 in box #15
        [21] = {
            "WTR209","WTR194","WTR222","WTR181","WTR153","WTR089","WTR052","WTR000","WTR024","WTR069","WTR028","WTR141","WTR104","WTR135","WTR110","WTR038","WTR001"
        },
        -- pack #22 in box #15
        [22] = {
            "WTR201","WTR185","WTR179","WTR217","WTR153","WTR094","WTR127","WTR085","WTR062","WTR036","WTR062","WTR109","WTR147","WTR102","WTR145","WTR078","WTR039"
        },
        -- pack #23 in box #15
        [23] = {
            "WTR192","WTR181","WTR208","WTR215","WTR154","WTR018","WTR083","WTR187","WTR066","WTR020","WTR065","WTR029","WTR138","WTR098","WTR140","WTR113","WTR078"
        },
        -- pack #24 in box #15
        [24] = {
            "WTR184","WTR202","WTR187","WTR202","WTR155","WTR017","WTR175","WTR062","WTR059","WTR025","WTR059","WTR109","WTR141","WTR103","WTR143","WTR225","WTR076"
        },
    },
    -- box #16
    [16] = {
        -- pack #1 in box #16
        [1] = {
            "WTR192","WTR201","WTR222","WTR221","WTR117","WTR012","WTR018","WTR017","WTR062","WTR031","WTR062","WTR033","WTR147","WTR096","WTR145","WTR114","WTR038"
        },
        -- pack #2 in box #16
        [2] = {
            "WTR200","WTR192","WTR201","WTR220","WTR117","WTR093","WTR051","WTR194","WTR074","WTR035","WTR060","WTR030","WTR134","WTR110","WTR136","WTR002","WTR077"
        },
        -- pack #3 in box #16
        [3] = {
            "WTR201","WTR177","WTR216","WTR201","WTR152","WTR125","WTR164","WTR027","WTR036","WTR064","WTR037","WTR143","WTR111","WTR146","WTR100","WTR075","WTR002"
        },
        -- pack #4 in box #16
        [4] = {
            "WTR223","WTR184","WTR217","WTR211","WTR005","WTR124","WTR015","WTR134","WTR026","WTR068","WTR029","WTR073","WTR107","WTR149","WTR101","WTR039","WTR002"
        },
        -- pack #5 in box #16
        [5] = {
            "WTR215","WTR199","WTR188","WTR201","WTR153","WTR089","WTR085","WTR069","WTR068","WTR036","WTR057","WTR103","WTR140","WTR100","WTR144","WTR115","WTR078"
        },
        -- pack #6 in box #16
        [6] = {
            "WTR179","WTR192","WTR189","WTR197","WTR156","WTR049","WTR175","WTR145","WTR064","WTR022","WTR068","WTR095","WTR133","WTR103","WTR147","WTR003","WTR078"
        },
        -- pack #7 in box #16
        [7] = {
            "WTR199","WTR182","WTR215","WTR189","WTR151","WTR167","WTR087","WTR201","WTR061","WTR030","WTR065","WTR096","WTR137","WTR103","WTR136","WTR115","WTR039"
        },
        -- pack #8 in box #16
        [8] = {
            "WTR180","WTR207","WTR213","WTR214","WTR152","WTR165","WTR055","WTR052","WTR037","WTR068","WTR028","WTR148","WTR112","WTR146","WTR111","WTR078","WTR002"
        },
        -- pack #9 in box #16
        [9] = {
            "WTR198","WTR195","WTR183","WTR189","WTR152","WTR129","WTR018","WTR042","WTR024","WTR073","WTR034","WTR063","WTR097","WTR133","WTR110","WTR114","WTR075"
        },
        -- pack #10 in box #16
        [10] = {
            "WTR187","WTR207","WTR188","WTR221","WTR042","WTR127","WTR162","WTR089","WTR034","WTR057","WTR021","WTR144","WTR110","WTR148","WTR095","WTR003","WTR038"
        },
        -- pack #11 in box #16
        [11] = {
            "WTR176","WTR178","WTR191","WTR209","WTR157","WTR123","WTR127","WTR221","WTR070","WTR034","WTR072","WTR031","WTR146","WTR096","WTR149","WTR003","WTR001"
        },
        -- pack #12 in box #16
        [12] = {
            "WTR202","WTR188","WTR193","WTR223","WTR156","WTR056","WTR091","WTR013","WTR029","WTR073","WTR024","WTR137","WTR112","WTR148","WTR097","WTR077","WTR113"
        },
        -- pack #13 in box #16
        [13] = {
            "WTR222","WTR214","WTR196","WTR211","WTR154","WTR126","WTR085","WTR080","WTR032","WTR065","WTR032","WTR064","WTR111","WTR138","WTR111","WTR115","WTR077"
        },
        -- pack #14 in box #16
        [14] = {
            "WTR205","WTR217","WTR178","WTR206","WTR157","WTR053","WTR164","WTR180","WTR031","WTR073","WTR021","WTR058","WTR109","WTR141","WTR095","WTR001","WTR077"
        },
        -- pack #15 in box #16
        [15] = {
            "WTR217","WTR213","WTR188","WTR217","WTR153","WTR017","WTR015","WTR014","WTR025","WTR057","WTR031","WTR066","WTR109","WTR148","WTR096","WTR113","WTR040"
        },
        -- pack #16 in box #16
        [16] = {
            "WTR200","WTR199","WTR180","WTR194","WTR117","WTR169","WTR052","WTR020","WTR063","WTR022","WTR069","WTR104","WTR134","WTR111","WTR136","WTR039","WTR040"
        },
        -- pack #17 in box #16
        [17] = {
            "WTR222","WTR199","WTR179","WTR189","WTR005","WTR012","WTR044","WTR111","WTR059","WTR033","WTR057","WTR105","WTR149","WTR111","WTR140","WTR077","WTR001"
        },
        -- pack #18 in box #16
        [18] = {
            "WTR197","WTR213","WTR205","WTR196","WTR042","WTR052","WTR051","WTR177","WTR061","WTR021","WTR068","WTR031","WTR143","WTR103","WTR136","WTR078","WTR038"
        },
        -- pack #19 in box #16
        [19] = {
            "WTR196","WTR212","WTR195","WTR206","WTR080","WTR011","WTR082","WTR062","WTR035","WTR068","WTR027","WTR138","WTR101","WTR145","WTR104","WTR038","WTR114"
        },
        -- pack #20 in box #16
        [20] = {
            "WTR206","WTR188","WTR178","WTR184","WTR080","WTR127","WTR130","WTR206","WTR068","WTR036","WTR070","WTR026","WTR147","WTR111","WTR132","WTR224"
        },
        -- pack #21 in box #16
        [21] = {
            "WTR188","WTR207","WTR180","WTR204","WTR042","WTR012","WTR161","WTR214","WTR034","WTR072","WTR028","WTR074","WTR100","WTR134","WTR110","WTR038","WTR114"
        },
        -- pack #22 in box #16
        [22] = {
            "WTR186","WTR210","WTR213","WTR176","WTR080","WTR124","WTR047","WTR148","WTR065","WTR030","WTR073","WTR105","WTR147","WTR099","WTR142","WTR002","WTR078"
        },
        -- pack #23 in box #16
        [23] = {
            "WTR200","WTR216","WTR179","WTR194","WTR151","WTR130","WTR088","WTR061","WTR030","WTR068","WTR020","WTR146","WTR112","WTR142","WTR105","WTR003","WTR114"
        },
        -- pack #24 in box #16
        [24] = {
            "WTR179","WTR197","WTR218","WTR216","WTR153","WTR126","WTR045","WTR022","WTR064","WTR033","WTR065","WTR028","WTR134","WTR106","WTR142","WTR078","WTR114"
        },
    },
    -- box #17
    [17] = {
        -- pack #1 in box #17
        [1] = {
            "WTR208","WTR214","WTR179","WTR184","WTR158","WTR055","WTR017","WTR150","WTR058","WTR032","WTR058","WTR106","WTR133","WTR109","WTR144","WTR001","WTR076"
        },
        -- pack #2 in box #17
        [2] = {
            "WTR221","WTR196","WTR207","WTR183","WTR157","WTR013","WTR049","WTR137","WTR073","WTR033","WTR073","WTR104","WTR133","WTR101","WTR133","WTR002","WTR039"
        },
        -- pack #3 in box #17
        [3] = {
            "WTR203","WTR202","WTR203","WTR188","WTR156","WTR088","WTR051","WTR205","WTR058","WTR026","WTR068","WTR026","WTR132","WTR111","WTR144","WTR075","WTR115"
        },
        -- pack #4 in box #17
        [4] = {
            "WTR203","WTR186","WTR217","WTR185","WTR117","WTR092","WTR048","WTR049","WTR067","WTR036","WTR060","WTR025","WTR145","WTR101","WTR144","WTR040","WTR078"
        },
        -- pack #5 in box #17
        [5] = {
            "WTR210","WTR214","WTR186","WTR182","WTR152","WTR093","WTR084","WTR131","WTR074","WTR026","WTR070","WTR021","WTR136","WTR103","WTR138","WTR078","WTR076"
        },
        -- pack #6 in box #17
        [6] = {
            "WTR185","WTR199","WTR217","WTR208","WTR080","WTR171","WTR129","WTR037","WTR066","WTR029","WTR068","WTR030","WTR145","WTR107","WTR143","WTR113","WTR225"
        },
        -- pack #7 in box #17
        [7] = {
            "WTR209","WTR203","WTR215","WTR193","WTR117","WTR169","WTR170","WTR219","WTR029","WTR064","WTR037","WTR142","WTR099","WTR143","WTR095","WTR077","WTR040"
        },
        -- pack #8 in box #17
        [8] = {
            "WTR187","WTR217","WTR203","WTR217","WTR158","WTR173","WTR013","WTR217","WTR064","WTR035","WTR058","WTR103","WTR141","WTR107","WTR136","WTR075","WTR078"
        },
        -- pack #9 in box #17
        [9] = {
            "WTR185","WTR204","WTR214","WTR176","WTR151","WTR171","WTR019","WTR196","WTR024","WTR063","WTR028","WTR071","WTR104","WTR144","WTR106","WTR002","WTR077"
        },
        -- pack #10 in box #17
        [10] = {
            "WTR223","WTR193","WTR223","WTR188","WTR117","WTR169","WTR019","WTR172","WTR057","WTR031","WTR074","WTR024","WTR140","WTR101","WTR142","WTR003","WTR075"
        },
        -- pack #11 in box #17
        [11] = {
            "WTR203","WTR179","WTR193","WTR219","WTR042","WTR012","WTR051","WTR198","WTR022","WTR070","WTR030","WTR065","WTR109","WTR139","WTR102","WTR113","WTR039"
        },
        -- pack #12 in box #17
        [12] = {
            "WTR188","WTR191","WTR179","WTR184","WTR151","WTR093","WTR052","WTR035","WTR065","WTR020","WTR068","WTR110","WTR136","WTR108","WTR143","WTR040","WTR077"
        },
        -- pack #13 in box #17
        [13] = {
            "WTR185","WTR208","WTR191","WTR180","WTR042","WTR166","WTR053","WTR103","WTR021","WTR061","WTR032","WTR139","WTR112","WTR141","WTR096","WTR002","WTR001"
        },
        -- pack #14 in box #17
        [14] = {
            "WTR197","WTR202","WTR181","WTR214","WTR155","WTR090","WTR086","WTR206","WTR030","WTR071","WTR028","WTR063","WTR107","WTR132","WTR106","WTR225","WTR113"
        },
        -- pack #15 in box #17
        [15] = {
            "WTR197","WTR194","WTR216","WTR223","WTR153","WTR050","WTR094","WTR218","WTR073","WTR028","WTR072","WTR095","WTR139","WTR103","WTR133","WTR077","WTR078"
        },
        -- pack #16 in box #17
        [16] = {
            "WTR208","WTR184","WTR196","WTR186","WTR157","WTR125","WTR131","WTR184","WTR026","WTR071","WTR034","WTR147","WTR110","WTR133","WTR112","WTR225","WTR001"
        },
        -- pack #17 in box #17
        [17] = {
            "WTR207","WTR213","WTR203","WTR181","WTR158","WTR174","WTR123","WTR112","WTR067","WTR025","WTR057","WTR099","WTR143","WTR102","WTR134","WTR225","WTR114"
        },
        -- pack #18 in box #17
        [18] = {
            "WTR193","WTR214","WTR210","WTR178","WTR152","WTR123","WTR091","WTR163","WTR066","WTR035","WTR061","WTR028","WTR149","WTR109","WTR138","WTR115","WTR003"
        },
        -- pack #19 in box #17
        [19] = {
            "WTR208","WTR218","WTR203","WTR219","WTR080","WTR051","WTR126","WTR094","WTR025","WTR058","WTR031","WTR066","WTR112","WTR141","WTR102","WTR076","WTR040"
        },
        -- pack #20 in box #17
        [20] = {
            "WTR211","WTR217","WTR177","WTR213","WTR154","WTR123","WTR055","WTR067","WTR035","WTR061","WTR028","WTR071","WTR109","WTR133","WTR111","WTR114","WTR040"
        },
        -- pack #21 in box #17
        [21] = {
            "WTR221","WTR187","WTR181","WTR196","WTR080","WTR048","WTR085","WTR018","WTR033","WTR074","WTR030","WTR134","WTR101","WTR148","WTR107","WTR225","WTR077"
        },
        -- pack #22 in box #17
        [22] = {
            "WTR178","WTR214","WTR209","WTR177","WTR151","WTR089","WTR013","WTR070","WTR029","WTR060","WTR029","WTR146","WTR110","WTR134","WTR097","WTR003","WTR038"
        },
        -- pack #23 in box #17
        [23] = {
            "WTR209","WTR216","WTR195","WTR188","WTR005","WTR053","WTR121","WTR149","WTR020","WTR063","WTR031","WTR149","WTR105","WTR134","WTR101","WTR038","WTR003"
        },
        -- pack #24 in box #17
        [24] = {
            "WTR188","WTR197","WTR187","WTR213","WTR117","WTR050","WTR043","WTR005","WTR028","WTR074","WTR024","WTR073","WTR112","WTR144","WTR099","WTR078","WTR113"
        },
    },
    -- box #18
    [18] = {
        -- pack #1 in box #18
        [1] = {
            "WTR209","WTR204","WTR185","WTR196","WTR154","WTR092","WTR171","WTR035","WTR065","WTR030","WTR070","WTR029","WTR146","WTR106","WTR137","WTR225","WTR077"
        },
        -- pack #2 in box #18
        [2] = {
            "WTR211","WTR181","WTR204","WTR223","WTR042","WTR013","WTR129","WTR140","WTR068","WTR032","WTR062","WTR102","WTR140","WTR111","WTR149","WTR077","WTR078"
        },
        -- pack #3 in box #18
        [3] = {
            "WTR195","WTR200","WTR207","WTR184","WTR151","WTR011","WTR092","WTR183","WTR022","WTR062","WTR030","WTR136","WTR102","WTR132","WTR110","WTR114","WTR003"
        },
        -- pack #4 in box #18
        [4] = {
            "WTR221","WTR215","WTR218","WTR202","WTR117","WTR017","WTR048","WTR098","WTR070","WTR027","WTR062","WTR025","WTR136","WTR106","WTR146","WTR040","WTR075"
        },
        -- pack #5 in box #18
        [5] = {
            "WTR189","WTR212","WTR190","WTR185","WTR152","WTR166","WTR086","WTR133","WTR027","WTR070","WTR034","WTR132","WTR095","WTR132","WTR100","WTR077","WTR078"
        },
        -- pack #6 in box #18
        [6] = {
            "WTR186","WTR204","WTR178","WTR189","WTR117","WTR050","WTR011","WTR044","WTR036","WTR065","WTR032","WTR073","WTR096","WTR137","WTR099","WTR114","WTR075"
        },
        -- pack #7 in box #18
        [7] = {
            "WTR205","WTR200","WTR199","WTR192","WTR156","WTR129","WTR170","WTR122","WTR058","WTR034","WTR066","WTR025","WTR134","WTR107","WTR143","WTR003","WTR113"
        },
        -- pack #8 in box #18
        [8] = {
            "WTR217","WTR184","WTR183","WTR191","WTR151","WTR127","WTR093","WTR193","WTR020","WTR067","WTR025","WTR140","WTR100","WTR148","WTR095","WTR001","WTR115"
        },
        -- pack #9 in box #18
        [9] = {
            "WTR208","WTR189","WTR199","WTR205","WTR154","WTR056","WTR162","WTR094","WTR073","WTR034","WTR061","WTR112","WTR134","WTR101","WTR149","WTR001","WTR002"
        },
        -- pack #10 in box #18
        [10] = {
            "WTR177","WTR212","WTR182","WTR182","WTR154","WTR012","WTR173","WTR080","WTR063","WTR024","WTR064","WTR110","WTR140","WTR111","WTR148","WTR224"
        },
        -- pack #11 in box #18
        [11] = {
            "WTR203","WTR218","WTR209","WTR196","WTR155","WTR090","WTR083","WTR056","WTR029","WTR068","WTR024","WTR138","WTR103","WTR132","WTR108","WTR001","WTR078"
        },
        -- pack #12 in box #18
        [12] = {
            "WTR193","WTR209","WTR187","WTR212","WTR152","WTR048","WTR168","WTR181","WTR062","WTR035","WTR068","WTR031","WTR132","WTR099","WTR142","WTR115","WTR077"
        },
        -- pack #13 in box #18
        [13] = {
            "WTR180","WTR221","WTR195","WTR221","WTR153","WTR048","WTR087","WTR177","WTR064","WTR032","WTR071","WTR095","WTR146","WTR099","WTR147","WTR076","WTR225"
        },
        -- pack #14 in box #18
        [14] = {
            "WTR189","WTR201","WTR182","WTR182","WTR153","WTR173","WTR017","WTR027","WTR025","WTR066","WTR031","WTR072","WTR099","WTR145","WTR108","WTR075","WTR078"
        },
        -- pack #15 in box #18
        [15] = {
            "WTR197","WTR203","WTR214","WTR205","WTR151","WTR019","WTR120","WTR165","WTR035","WTR074","WTR029","WTR147","WTR100","WTR133","WTR110","WTR039","WTR115"
        },
        -- pack #16 in box #18
        [16] = {
            "WTR221","WTR216","WTR220","WTR185","WTR151","WTR090","WTR017","WTR117","WTR027","WTR064","WTR037","WTR063","WTR097","WTR136","WTR103","WTR077","WTR113"
        },
        -- pack #17 in box #18
        [17] = {
            "WTR212","WTR202","WTR196","WTR204","WTR042","WTR094","WTR050","WTR089","WTR029","WTR067","WTR022","WTR058","WTR102","WTR145","WTR100","WTR038","WTR113"
        },
        -- pack #18 in box #18
        [18] = {
            "WTR217","WTR211","WTR188","WTR221","WTR117","WTR089","WTR121","WTR068","WTR025","WTR072","WTR037","WTR147","WTR105","WTR148","WTR103","WTR225","WTR113"
        },
        -- pack #19 in box #18
        [19] = {
            "WTR220","WTR186","WTR221","WTR222","WTR153","WTR011","WTR017","WTR205","WTR058","WTR028","WTR068","WTR035","WTR138","WTR098","WTR135","WTR040","WTR077"
        },
        -- pack #20 in box #18
        [20] = {
            "WTR193","WTR204","WTR183","WTR181","WTR156","WTR019","WTR091","WTR086","WTR065","WTR033","WTR072","WTR104","WTR149","WTR098","WTR137","WTR001","WTR077"
        },
        -- pack #21 in box #18
        [21] = {
            "WTR205","WTR218","WTR180","WTR190","WTR117","WTR016","WTR010","WTR200","WTR035","WTR072","WTR026","WTR066","WTR100","WTR146","WTR102","WTR075","WTR003"
        },
        -- pack #22 in box #18
        [22] = {
            "WTR181","WTR219","WTR194","WTR223","WTR152","WTR086","WTR173","WTR128","WTR024","WTR074","WTR026","WTR062","WTR107","WTR144","WTR107","WTR001","WTR114"
        },
        -- pack #23 in box #18
        [23] = {
            "WTR183","WTR213","WTR191","WTR185","WTR157","WTR174","WTR011","WTR141","WTR072","WTR027","WTR067","WTR109","WTR144","WTR097","WTR137","WTR002","WTR225"
        },
        -- pack #24 in box #18
        [24] = {
            "WTR219","WTR178","WTR213","WTR204","WTR155","WTR048","WTR118","WTR094","WTR074","WTR036","WTR070","WTR021","WTR134","WTR099","WTR144","WTR113","WTR001"
        },
    },
    -- box #19
    [19] = {
        -- pack #1 in box #19
        [1] = {
            "WTR216","WTR205","WTR192","WTR206","WTR152","WTR051","WTR126","WTR035","WTR058","WTR030","WTR063","WTR021","WTR143","WTR108","WTR144","WTR225","WTR078"
        },
        -- pack #2 in box #19
        [2] = {
            "WTR199","WTR215","WTR194","WTR190","WTR152","WTR170","WTR167","WTR121","WTR035","WTR062","WTR035","WTR071","WTR102","WTR145","WTR110","WTR115","WTR114"
        },
        -- pack #3 in box #19
        [3] = {
            "WTR206","WTR205","WTR203","WTR223","WTR005","WTR048","WTR050","WTR132","WTR025","WTR057","WTR021","WTR134","WTR106","WTR137","WTR102","WTR076","WTR038"
        },
        -- pack #4 in box #19
        [4] = {
            "WTR177","WTR178","WTR190","WTR186","WTR005","WTR018","WTR165","WTR070","WTR063","WTR026","WTR068","WTR107","WTR136","WTR096","WTR132","WTR038","WTR075"
        },
        -- pack #5 in box #19
        [5] = {
            "WTR178","WTR213","WTR193","WTR196","WTR042","WTR093","WTR125","WTR134","WTR073","WTR033","WTR072","WTR096","WTR146","WTR098","WTR132","WTR114","WTR039"
        },
        -- pack #6 in box #19
        [6] = {
            "WTR195","WTR215","WTR198","WTR209","WTR080","WTR019","WTR018","WTR169","WTR073","WTR021","WTR074","WTR021","WTR135","WTR106","WTR141","WTR224"
        },
        -- pack #7 in box #19
        [7] = {
            "WTR219","WTR207","WTR196","WTR190","WTR154","WTR168","WTR161","WTR098","WTR020","WTR058","WTR027","WTR137","WTR099","WTR132","WTR096","WTR001","WTR039"
        },
        -- pack #8 in box #19
        [8] = {
            "WTR219","WTR206","WTR190","WTR221","WTR155","WTR088","WTR170","WTR093","WTR064","WTR037","WTR071","WTR023","WTR145","WTR111","WTR132","WTR038","WTR075"
        },
        -- pack #9 in box #19
        [9] = {
            "WTR216","WTR223","WTR200","WTR195","WTR152","WTR164","WTR047","WTR188","WTR068","WTR023","WTR074","WTR098","WTR147","WTR099","WTR140","WTR114","WTR113"
        },
        -- pack #10 in box #19
        [10] = {
            "WTR218","WTR198","WTR182","WTR181","WTR117","WTR056","WTR044","WTR061","WTR067","WTR025","WTR057","WTR027","WTR140","WTR098","WTR142","WTR115","WTR225"
        },
        -- pack #11 in box #19
        [11] = {
            "WTR220","WTR188","WTR194","WTR177","WTR154","WTR050","WTR124","WTR117","WTR028","WTR068","WTR034","WTR070","WTR096","WTR140","WTR101","WTR038","WTR076"
        },
        -- pack #12 in box #19
        [12] = {
            "WTR189","WTR200","WTR201","WTR191","WTR154","WTR015","WTR048","WTR059","WTR026","WTR061","WTR022","WTR142","WTR106","WTR137","WTR096","WTR115","WTR039"
        },
        -- pack #13 in box #19
        [13] = {
            "WTR182","WTR212","WTR185","WTR200","WTR157","WTR126","WTR130","WTR154","WTR069","WTR025","WTR058","WTR097","WTR139","WTR112","WTR133","WTR076","WTR038"
        },
        -- pack #14 in box #19
        [14] = {
            "WTR183","WTR202","WTR206","WTR213","WTR158","WTR173","WTR091","WTR194","WTR022","WTR061","WTR023","WTR057","WTR097","WTR140","WTR098","WTR115","WTR003"
        },
        -- pack #15 in box #19
        [15] = {
            "WTR176","WTR198","WTR216","WTR189","WTR158","WTR012","WTR049","WTR139","WTR029","WTR058","WTR023","WTR145","WTR107","WTR149","WTR098","WTR039","WTR038"
        },
        -- pack #16 in box #19
        [16] = {
            "WTR179","WTR202","WTR198","WTR221","WTR080","WTR090","WTR019","WTR104","WTR026","WTR066","WTR032","WTR073","WTR111","WTR133","WTR106","WTR003","WTR001"
        },
        -- pack #17 in box #19
        [17] = {
            "WTR220","WTR176","WTR183","WTR190","WTR042","WTR056","WTR050","WTR068","WTR074","WTR030","WTR057","WTR103","WTR144","WTR109","WTR142","WTR224"
        },
        -- pack #18 in box #19
        [18] = {
            "WTR223","WTR202","WTR198","WTR185","WTR155","WTR019","WTR171","WTR176","WTR021","WTR057","WTR024","WTR147","WTR112","WTR140","WTR107","WTR113","WTR075"
        },
        -- pack #19 in box #19
        [19] = {
            "WTR187","WTR192","WTR205","WTR222","WTR117","WTR125","WTR011","WTR050","WTR073","WTR030","WTR069","WTR026","WTR148","WTR111","WTR141","WTR002","WTR225"
        },
        -- pack #20 in box #19
        [20] = {
            "WTR191","WTR205","WTR190","WTR188","WTR157","WTR129","WTR121","WTR022","WTR022","WTR066","WTR032","WTR132","WTR099","WTR145","WTR102","WTR075","WTR002"
        },
        -- pack #21 in box #19
        [21] = {
            "WTR183","WTR201","WTR218","WTR216","WTR158","WTR056","WTR166","WTR208","WTR064","WTR027","WTR069","WTR097","WTR145","WTR100","WTR133","WTR115","WTR077"
        },
        -- pack #22 in box #19
        [22] = {
            "WTR206","WTR189","WTR219","WTR210","WTR155","WTR050","WTR084","WTR104","WTR028","WTR057","WTR033","WTR064","WTR108","WTR148","WTR109","WTR115","WTR038"
        },
        -- pack #23 in box #19
        [23] = {
            "WTR181","WTR213","WTR216","WTR203","WTR158","WTR019","WTR174","WTR072","WTR034","WTR067","WTR024","WTR068","WTR097","WTR139","WTR108","WTR225","WTR076"
        },
        -- pack #24 in box #19
        [24] = {
            "WTR207","WTR217","WTR220","WTR205","WTR157","WTR124","WTR011","WTR066","WTR065","WTR020","WTR065","WTR025","WTR149","WTR112","WTR145","WTR113","WTR002"
        },
    },
    -- box #20
    [20] = {
        -- pack #1 in box #20
        [1] = {
            "WTR223","WTR219","WTR192","WTR217","WTR042","WTR124","WTR087","WTR220","WTR029","WTR073","WTR036","WTR061","WTR107","WTR142","WTR097","WTR113","WTR002"
        },
        -- pack #2 in box #20
        [2] = {
            "WTR184","WTR208","WTR194","WTR205","WTR117","WTR087","WTR052","WTR190","WTR061","WTR036","WTR065","WTR109","WTR133","WTR107","WTR141","WTR113","WTR115"
        },
        -- pack #3 in box #20
        [3] = {
            "WTR189","WTR198","WTR189","WTR186","WTR156","WTR011","WTR055","WTR119","WTR069","WTR029","WTR073","WTR035","WTR145","WTR101","WTR147","WTR039","WTR075"
        },
        -- pack #4 in box #20
        [4] = {
            "WTR184","WTR212","WTR186","WTR199","WTR156","WTR048","WTR169","WTR060","WTR034","WTR057","WTR027","WTR062","WTR103","WTR147","WTR103","WTR075","WTR077"
        },
        -- pack #5 in box #20
        [5] = {
            "WTR177","WTR221","WTR182","WTR217","WTR151","WTR091","WTR047","WTR139","WTR057","WTR024","WTR057","WTR030","WTR140","WTR098","WTR144","WTR076","WTR001"
        },
        -- pack #6 in box #20
        [6] = {
            "WTR194","WTR206","WTR223","WTR195","WTR155","WTR018","WTR085","WTR101","WTR062","WTR036","WTR074","WTR021","WTR138","WTR099","WTR148","WTR039","WTR114"
        },
        -- pack #7 in box #20
        [7] = {
            "WTR220","WTR192","WTR202","WTR184","WTR151","WTR165","WTR162","WTR196","WTR069","WTR022","WTR061","WTR026","WTR149","WTR102","WTR133","WTR040","WTR039"
        },
        -- pack #8 in box #20
        [8] = {
            "WTR201","WTR192","WTR196","WTR204","WTR080","WTR012","WTR015","WTR101","WTR021","WTR061","WTR030","WTR141","WTR103","WTR147","WTR103","WTR224"
        },
        -- pack #9 in box #20
        [9] = {
            "WTR218","WTR222","WTR207","WTR205","WTR158","WTR125","WTR131","WTR216","WTR060","WTR024","WTR062","WTR112","WTR144","WTR105","WTR142","WTR075","WTR113"
        },
        -- pack #10 in box #20
        [10] = {
            "WTR215","WTR191","WTR191","WTR216","WTR005","WTR015","WTR086","WTR187","WTR067","WTR020","WTR070","WTR103","WTR139","WTR111","WTR146","WTR077","WTR002"
        },
        -- pack #11 in box #20
        [11] = {
            "WTR213","WTR178","WTR185","WTR190","WTR157","WTR015","WTR049","WTR016","WTR033","WTR061","WTR029","WTR148","WTR100","WTR146","WTR095","WTR077","WTR040"
        },
        -- pack #12 in box #20
        [12] = {
            "WTR177","WTR205","WTR184","WTR202","WTR158","WTR123","WTR130","WTR200","WTR025","WTR067","WTR023","WTR067","WTR110","WTR143","WTR107","WTR225","WTR078"
        },
        -- pack #13 in box #20
        [13] = {
            "WTR218","WTR203","WTR195","WTR182","WTR154","WTR166","WTR013","WTR214","WTR061","WTR029","WTR058","WTR027","WTR144","WTR097","WTR133","WTR076","WTR115"
        },
        -- pack #14 in box #20
        [14] = {
            "WTR194","WTR201","WTR207","WTR196","WTR117","WTR175","WTR016","WTR193","WTR023","WTR074","WTR022","WTR138","WTR095","WTR139","WTR107","WTR078","WTR075"
        },
        -- pack #15 in box #20
        [15] = {
            "WTR192","WTR202","WTR216","WTR177","WTR158","WTR168","WTR125","WTR083","WTR035","WTR064","WTR035","WTR134","WTR096","WTR140","WTR095","WTR113","WTR039"
        },
        -- pack #16 in box #20
        [16] = {
            "WTR210","WTR192","WTR182","WTR214","WTR155","WTR124","WTR014","WTR191","WTR032","WTR068","WTR027","WTR141","WTR108","WTR137","WTR106","WTR077","WTR076"
        },
        -- pack #17 in box #20
        [17] = {
            "WTR219","WTR201","WTR182","WTR218","WTR158","WTR051","WTR081","WTR042","WTR067","WTR026","WTR066","WTR035","WTR149","WTR106","WTR145","WTR040","WTR038"
        },
        -- pack #18 in box #20
        [18] = {
            "WTR208","WTR222","WTR182","WTR220","WTR156","WTR019","WTR094","WTR009","WTR059","WTR023","WTR069","WTR095","WTR146","WTR097","WTR134","WTR038","WTR001"
        },
        -- pack #19 in box #20
        [19] = {
            "WTR216","WTR193","WTR208","WTR179","WTR117","WTR175","WTR121","WTR031","WTR023","WTR058","WTR031","WTR135","WTR110","WTR149","WTR106","WTR225","WTR040"
        },
        -- pack #20 in box #20
        [20] = {
            "WTR221","WTR203","WTR190","WTR182","WTR042","WTR166","WTR165","WTR034","WTR030","WTR066","WTR033","WTR062","WTR110","WTR149","WTR101","WTR115","WTR075"
        },
        -- pack #21 in box #20
        [21] = {
            "WTR176","WTR222","WTR180","WTR214","WTR154","WTR012","WTR019","WTR178","WTR061","WTR033","WTR074","WTR099","WTR140","WTR101","WTR136","WTR001","WTR077"
        },
        -- pack #22 in box #20
        [22] = {
            "WTR183","WTR193","WTR203","WTR207","WTR080","WTR015","WTR167","WTR072","WTR029","WTR063","WTR023","WTR065","WTR106","WTR145","WTR106","WTR038","WTR225"
        },
        -- pack #23 in box #20
        [23] = {
            "WTR187","WTR205","WTR193","WTR208","WTR117","WTR169","WTR091","WTR106","WTR060","WTR022","WTR060","WTR111","WTR137","WTR102","WTR148","WTR113","WTR039"
        },
        -- pack #24 in box #20
        [24] = {
            "WTR187","WTR194","WTR195","WTR199","WTR156","WTR018","WTR121","WTR030","WTR030","WTR068","WTR024","WTR066","WTR107","WTR147","WTR104","WTR002","WTR076"
        },
    },
    -- box #21
    [21] = {
        -- pack #1 in box #21
        [1] = {
            "WTR209","WTR211","WTR212","WTR192","WTR080","WTR093","WTR118","WTR191","WTR032","WTR072","WTR032","WTR065","WTR112","WTR138","WTR098","WTR078","WTR114"
        },
        -- pack #2 in box #21
        [2] = {
            "WTR200","WTR221","WTR184","WTR186","WTR005","WTR048","WTR122","WTR222","WTR059","WTR021","WTR074","WTR097","WTR147","WTR098","WTR147","WTR113","WTR002"
        },
        -- pack #3 in box #21
        [3] = {
            "WTR189","WTR223","WTR199","WTR196","WTR042","WTR126","WTR055","WTR193","WTR032","WTR066","WTR031","WTR132","WTR102","WTR142","WTR099","WTR115","WTR077"
        },
        -- pack #4 in box #21
        [4] = {
            "WTR179","WTR188","WTR195","WTR217","WTR156","WTR014","WTR083","WTR202","WTR065","WTR023","WTR074","WTR025","WTR143","WTR103","WTR132","WTR001","WTR002"
        },
        -- pack #5 in box #21
        [5] = {
            "WTR191","WTR184","WTR177","WTR187","WTR042","WTR128","WTR017","WTR065","WTR024","WTR060","WTR024","WTR146","WTR107","WTR143","WTR110","WTR039","WTR077"
        },
        -- pack #6 in box #21
        [6] = {
            "WTR223","WTR223","WTR192","WTR214","WTR154","WTR048","WTR053","WTR146","WTR020","WTR059","WTR031","WTR138","WTR111","WTR141","WTR100","WTR115","WTR001"
        },
        -- pack #7 in box #21
        [7] = {
            "WTR197","WTR193","WTR182","WTR211","WTR151","WTR094","WTR007","WTR107","WTR069","WTR026","WTR060","WTR023","WTR136","WTR112","WTR134","WTR001","WTR075"
        },
        -- pack #8 in box #21
        [8] = {
            "WTR199","WTR211","WTR190","WTR179","WTR005","WTR164","WTR175","WTR192","WTR062","WTR027","WTR063","WTR037","WTR144","WTR105","WTR134","WTR115","WTR003"
        },
        -- pack #9 in box #21
        [9] = {
            "WTR189","WTR218","WTR177","WTR181","WTR153","WTR087","WTR123","WTR134","WTR026","WTR060","WTR034","WTR060","WTR107","WTR144","WTR099","WTR075","WTR113"
        },
        -- pack #10 in box #21
        [10] = {
            "WTR179","WTR179","WTR182","WTR212","WTR158","WTR054","WTR055","WTR127","WTR023","WTR057","WTR029","WTR145","WTR108","WTR135","WTR102","WTR076","WTR225"
        },
        -- pack #11 in box #21
        [11] = {
            "WTR184","WTR220","WTR214","WTR221","WTR005","WTR056","WTR167","WTR158","WTR059","WTR020","WTR066","WTR109","WTR144","WTR095","WTR138","WTR076","WTR002"
        },
        -- pack #12 in box #21
        [12] = {
            "WTR188","WTR211","WTR189","WTR178","WTR153","WTR014","WTR090","WTR142","WTR064","WTR023","WTR063","WTR110","WTR143","WTR099","WTR143","WTR078","WTR115"
        },
        -- pack #13 in box #21
        [13] = {
            "WTR202","WTR184","WTR200","WTR220","WTR117","WTR091","WTR009","WTR132","WTR061","WTR020","WTR073","WTR037","WTR136","WTR096","WTR147","WTR001","WTR076"
        },
        -- pack #14 in box #21
        [14] = {
            "WTR217","WTR192","WTR185","WTR206","WTR158","WTR129","WTR089","WTR192","WTR023","WTR064","WTR022","WTR060","WTR110","WTR142","WTR098","WTR003","WTR001"
        },
        -- pack #15 in box #21
        [15] = {
            "WTR220","WTR178","WTR181","WTR204","WTR158","WTR125","WTR047","WTR164","WTR022","WTR061","WTR025","WTR068","WTR112","WTR142","WTR097","WTR038","WTR040"
        },
        -- pack #16 in box #21
        [16] = {
            "WTR192","WTR218","WTR215","WTR207","WTR155","WTR126","WTR084","WTR211","WTR028","WTR057","WTR031","WTR060","WTR111","WTR139","WTR098","WTR040","WTR001"
        },
        -- pack #17 in box #21
        [17] = {
            "WTR179","WTR203","WTR214","WTR209","WTR117","WTR174","WTR165","WTR104","WTR037","WTR068","WTR033","WTR143","WTR103","WTR149","WTR106","WTR003","WTR040"
        },
        -- pack #18 in box #21
        [18] = {
            "WTR197","WTR177","WTR178","WTR202","WTR080","WTR164","WTR122","WTR207","WTR027","WTR059","WTR021","WTR136","WTR101","WTR135","WTR098","WTR038","WTR113"
        },
        -- pack #19 in box #21
        [19] = {
            "WTR203","WTR213","WTR202","WTR198","WTR158","WTR123","WTR166","WTR198","WTR061","WTR024","WTR062","WTR100","WTR147","WTR108","WTR147","WTR075","WTR113"
        },
        -- pack #20 in box #21
        [20] = {
            "WTR214","WTR198","WTR194","WTR199","WTR156","WTR129","WTR093","WTR223","WTR060","WTR033","WTR066","WTR096","WTR137","WTR109","WTR134","WTR076","WTR225"
        },
        -- pack #21 in box #21
        [21] = {
            "WTR186","WTR182","WTR221","WTR217","WTR151","WTR017","WTR173","WTR029","WTR060","WTR035","WTR065","WTR101","WTR137","WTR103","WTR139","WTR039","WTR078"
        },
        -- pack #22 in box #21
        [22] = {
            "WTR211","WTR217","WTR179","WTR181","WTR154","WTR049","WTR119","WTR019","WTR028","WTR059","WTR029","WTR059","WTR095","WTR147","WTR095","WTR114","WTR078"
        },
        -- pack #23 in box #21
        [23] = {
            "WTR186","WTR194","WTR219","WTR184","WTR153","WTR089","WTR121","WTR185","WTR066","WTR022","WTR067","WTR037","WTR149","WTR104","WTR134","WTR076","WTR002"
        },
        -- pack #24 in box #21
        [24] = {
            "WTR213","WTR220","WTR182","WTR214","WTR155","WTR012","WTR055","WTR031","WTR073","WTR037","WTR058","WTR020","WTR132","WTR112","WTR132","WTR038","WTR040"
        },
    },
    -- box #22
    [22] = {
        -- pack #1 in box #22
        [1] = {
            "WTR214","WTR223","WTR201","WTR191","WTR155","WTR170","WTR093","WTR028","WTR022","WTR065","WTR037","WTR072","WTR112","WTR135","WTR112","WTR040","WTR113"
        },
        -- pack #2 in box #22
        [2] = {
            "WTR177","WTR189","WTR199","WTR176","WTR151","WTR011","WTR048","WTR152","WTR031","WTR057","WTR025","WTR133","WTR112","WTR139","WTR103","WTR039","WTR040"
        },
        -- pack #3 in box #22
        [3] = {
            "WTR176","WTR182","WTR195","WTR207","WTR154","WTR014","WTR128","WTR210","WTR059","WTR035","WTR065","WTR025","WTR145","WTR108","WTR147","WTR113","WTR001"
        },
        -- pack #4 in box #22
        [4] = {
            "WTR210","WTR179","WTR206","WTR177","WTR155","WTR017","WTR118","WTR130","WTR064","WTR030","WTR069","WTR033","WTR136","WTR103","WTR145","WTR078","WTR076"
        },
        -- pack #5 in box #22
        [5] = {
            "WTR180","WTR218","WTR209","WTR216","WTR155","WTR172","WTR014","WTR181","WTR070","WTR026","WTR067","WTR098","WTR146","WTR101","WTR147","WTR115","WTR113"
        },
        -- pack #6 in box #22
        [6] = {
            "WTR201","WTR218","WTR177","WTR192","WTR158","WTR017","WTR048","WTR028","WTR027","WTR074","WTR025","WTR066","WTR095","WTR148","WTR106","WTR039","WTR113"
        },
        -- pack #7 in box #22
        [7] = {
            "WTR197","WTR198","WTR216","WTR189","WTR117","WTR016","WTR168","WTR062","WTR074","WTR030","WTR070","WTR096","WTR140","WTR109","WTR146","WTR040","WTR115"
        },
        -- pack #8 in box #22
        [8] = {
            "WTR217","WTR191","WTR183","WTR195","WTR153","WTR166","WTR127","WTR085","WTR033","WTR064","WTR033","WTR057","WTR112","WTR142","WTR095","WTR076","WTR115"
        },
        -- pack #9 in box #22
        [9] = {
            "WTR182","WTR204","WTR222","WTR207","WTR155","WTR013","WTR166","WTR143","WTR066","WTR027","WTR058","WTR032","WTR136","WTR104","WTR132","WTR040","WTR075"
        },
        -- pack #10 in box #22
        [10] = {
            "WTR184","WTR183","WTR182","WTR196","WTR156","WTR164","WTR017","WTR120","WTR036","WTR068","WTR026","WTR062","WTR100","WTR143","WTR107","WTR113","WTR078"
        },
        -- pack #11 in box #22
        [11] = {
            "WTR194","WTR216","WTR177","WTR223","WTR080","WTR173","WTR085","WTR025","WTR071","WTR032","WTR070","WTR112","WTR142","WTR097","WTR141","WTR003","WTR078"
        },
        -- pack #12 in box #22
        [12] = {
            "WTR195","WTR190","WTR187","WTR184","WTR117","WTR052","WTR093","WTR058","WTR063","WTR030","WTR067","WTR025","WTR144","WTR100","WTR132","WTR076","WTR038"
        },
        -- pack #13 in box #22
        [13] = {
            "WTR187","WTR219","WTR210","WTR196","WTR153","WTR129","WTR089","WTR202","WTR034","WTR066","WTR033","WTR074","WTR110","WTR145","WTR104","WTR040","WTR114"
        },
        -- pack #14 in box #22
        [14] = {
            "WTR192","WTR197","WTR176","WTR184","WTR152","WTR055","WTR167","WTR214","WTR074","WTR028","WTR073","WTR109","WTR133","WTR107","WTR147","WTR078","WTR077"
        },
        -- pack #15 in box #22
        [15] = {
            "WTR210","WTR219","WTR185","WTR204","WTR117","WTR091","WTR012","WTR023","WTR025","WTR065","WTR035","WTR135","WTR106","WTR146","WTR102","WTR039","WTR225"
        },
        -- pack #16 in box #22
        [16] = {
            "WTR202","WTR203","WTR195","WTR215","WTR153","WTR015","WTR171","WTR211","WTR029","WTR061","WTR036","WTR132","WTR101","WTR148","WTR105","WTR003","WTR002"
        },
        -- pack #17 in box #22
        [17] = {
            "WTR194","WTR216","WTR209","WTR198","WTR153","WTR131","WTR127","WTR071","WTR062","WTR020","WTR058","WTR107","WTR142","WTR103","WTR134","WTR224"
        },
        -- pack #18 in box #22
        [18] = {
            "WTR213","WTR190","WTR186","WTR184","WTR117","WTR127","WTR161","WTR194","WTR036","WTR072","WTR023","WTR132","WTR107","WTR144","WTR099","WTR225","WTR002"
        },
        -- pack #19 in box #22
        [19] = {
            "WTR200","WTR196","WTR193","WTR185","WTR005","WTR019","WTR167","WTR144","WTR023","WTR072","WTR024","WTR141","WTR095","WTR132","WTR102","WTR002","WTR039"
        },
        -- pack #20 in box #22
        [20] = {
            "WTR189","WTR177","WTR200","WTR206","WTR157","WTR123","WTR169","WTR105","WTR073","WTR020","WTR064","WTR108","WTR135","WTR095","WTR138","WTR003","WTR039"
        },
        -- pack #21 in box #22
        [21] = {
            "WTR187","WTR213","WTR179","WTR198","WTR005","WTR055","WTR122","WTR189","WTR061","WTR036","WTR060","WTR035","WTR149","WTR112","WTR136","WTR115","WTR076"
        },
        -- pack #22 in box #22
        [22] = {
            "WTR176","WTR187","WTR180","WTR197","WTR080","WTR169","WTR017","WTR199","WTR031","WTR069","WTR024","WTR139","WTR101","WTR141","WTR096","WTR002","WTR076"
        },
        -- pack #23 in box #22
        [23] = {
            "WTR217","WTR216","WTR178","WTR215","WTR152","WTR052","WTR087","WTR138","WTR023","WTR073","WTR029","WTR067","WTR106","WTR134","WTR095","WTR038","WTR002"
        },
        -- pack #24 in box #22
        [24] = {
            "WTR183","WTR189","WTR197","WTR191","WTR005","WTR131","WTR053","WTR220","WTR063","WTR029","WTR066","WTR027","WTR145","WTR112","WTR132","WTR114","WTR115"
        },
    },
    -- box #23
    [23] = {
        -- pack #1 in box #23
        [1] = {
            "WTR187","WTR182","WTR208","WTR180","WTR156","WTR091","WTR129","WTR198","WTR024","WTR063","WTR028","WTR057","WTR104","WTR134","WTR109","WTR075","WTR039"
        },
        -- pack #2 in box #23
        [2] = {
            "WTR201","WTR220","WTR200","WTR180","WTR158","WTR169","WTR044","WTR192","WTR022","WTR063","WTR024","WTR148","WTR105","WTR141","WTR110","WTR039","WTR076"
        },
        -- pack #3 in box #23
        [3] = {
            "WTR221","WTR184","WTR209","WTR187","WTR155","WTR014","WTR171","WTR045","WTR024","WTR057","WTR037","WTR069","WTR099","WTR148","WTR100","WTR078","WTR075"
        },
        -- pack #4 in box #23
        [4] = {
            "WTR218","WTR183","WTR181","WTR220","WTR157","WTR169","WTR007","WTR126","WTR070","WTR023","WTR059","WTR034","WTR144","WTR109","WTR148","WTR113","WTR038"
        },
        -- pack #5 in box #23
        [5] = {
            "WTR208","WTR204","WTR189","WTR200","WTR152","WTR174","WTR011","WTR024","WTR073","WTR031","WTR074","WTR099","WTR132","WTR096","WTR134","WTR001","WTR075"
        },
        -- pack #6 in box #23
        [6] = {
            "WTR207","WTR199","WTR189","WTR210","WTR080","WTR165","WTR093","WTR169","WTR034","WTR071","WTR023","WTR147","WTR106","WTR142","WTR106","WTR078","WTR038"
        },
        -- pack #7 in box #23
        [7] = {
            "WTR216","WTR206","WTR191","WTR190","WTR005","WTR165","WTR018","WTR199","WTR071","WTR028","WTR072","WTR105","WTR147","WTR095","WTR134","WTR075","WTR077"
        },
        -- pack #8 in box #23
        [8] = {
            "WTR177","WTR219","WTR186","WTR194","WTR156","WTR166","WTR010","WTR184","WTR067","WTR024","WTR073","WTR037","WTR138","WTR104","WTR134","WTR040","WTR077"
        },
        -- pack #9 in box #23
        [9] = {
            "WTR221","WTR190","WTR186","WTR215","WTR005","WTR093","WTR173","WTR059","WTR061","WTR027","WTR059","WTR032","WTR136","WTR095","WTR138","WTR224"
        },
        -- pack #10 in box #23
        [10] = {
            "WTR200","WTR191","WTR185","WTR223","WTR152","WTR173","WTR160","WTR081","WTR021","WTR066","WTR037","WTR133","WTR101","WTR137","WTR107","WTR040","WTR225"
        },
        -- pack #11 in box #23
        [11] = {
            "WTR215","WTR206","WTR207","WTR216","WTR158","WTR129","WTR120","WTR060","WTR031","WTR063","WTR036","WTR142","WTR103","WTR139","WTR101","WTR225","WTR113"
        },
        -- pack #12 in box #23
        [12] = {
            "WTR198","WTR202","WTR176","WTR184","WTR155","WTR055","WTR094","WTR201","WTR029","WTR074","WTR029","WTR060","WTR107","WTR141","WTR099","WTR039","WTR002"
        },
        -- pack #13 in box #23
        [13] = {
            "WTR221","WTR199","WTR196","WTR201","WTR080","WTR165","WTR167","WTR221","WTR067","WTR027","WTR067","WTR097","WTR135","WTR099","WTR146","WTR075","WTR225"
        },
        -- pack #14 in box #23
        [14] = {
            "WTR184","WTR217","WTR201","WTR192","WTR154","WTR090","WTR018","WTR098","WTR028","WTR069","WTR024","WTR065","WTR107","WTR134","WTR111","WTR076","WTR003"
        },
        -- pack #15 in box #23
        [15] = {
            "WTR208","WTR221","WTR197","WTR208","WTR154","WTR171","WTR082","WTR049","WTR030","WTR070","WTR028","WTR062","WTR109","WTR146","WTR098","WTR002","WTR225"
        },
        -- pack #16 in box #23
        [16] = {
            "WTR210","WTR196","WTR197","WTR204","WTR153","WTR123","WTR131","WTR216","WTR060","WTR027","WTR060","WTR027","WTR144","WTR106","WTR137","WTR002","WTR040"
        },
        -- pack #17 in box #23
        [17] = {
            "WTR184","WTR192","WTR195","WTR201","WTR156","WTR091","WTR008","WTR187","WTR060","WTR035","WTR064","WTR026","WTR134","WTR104","WTR135","WTR113","WTR039"
        },
        -- pack #18 in box #23
        [18] = {
            "WTR199","WTR184","WTR207","WTR178","WTR153","WTR164","WTR163","WTR055","WTR065","WTR027","WTR066","WTR107","WTR135","WTR106","WTR140","WTR114","WTR001"
        },
        -- pack #19 in box #23
        [19] = {
            "WTR203","WTR203","WTR190","WTR202","WTR157","WTR087","WTR017","WTR214","WTR037","WTR058","WTR023","WTR072","WTR110","WTR138","WTR109","WTR077","WTR114"
        },
        -- pack #20 in box #23
        [20] = {
            "WTR223","WTR218","WTR218","WTR191","WTR155","WTR175","WTR085","WTR067","WTR069","WTR033","WTR059","WTR105","WTR138","WTR099","WTR148","WTR113","WTR039"
        },
        -- pack #21 in box #23
        [21] = {
            "WTR214","WTR217","WTR215","WTR184","WTR151","WTR172","WTR007","WTR162","WTR074","WTR031","WTR067","WTR023","WTR139","WTR098","WTR149","WTR038","WTR003"
        },
        -- pack #22 in box #23
        [22] = {
            "WTR178","WTR180","WTR212","WTR223","WTR080","WTR048","WTR056","WTR182","WTR060","WTR023","WTR073","WTR095","WTR146","WTR097","WTR148","WTR078","WTR114"
        },
        -- pack #23 in box #23
        [23] = {
            "WTR184","WTR221","WTR218","WTR209","WTR158","WTR128","WTR016","WTR020","WTR023","WTR067","WTR033","WTR132","WTR111","WTR146","WTR098","WTR038","WTR113"
        },
        -- pack #24 in box #23
        [24] = {
            "WTR215","WTR219","WTR186","WTR195","WTR117","WTR089","WTR056","WTR167","WTR025","WTR070","WTR024","WTR145","WTR112","WTR143","WTR105","WTR040","WTR113"
        },
    },
    -- box #24
    [24] = {
        -- pack #1 in box #24
        [1] = {
            "WTR183","WTR182","WTR192","WTR215","WTR154","WTR130","WTR119","WTR205","WTR023","WTR067","WTR021","WTR069","WTR098","WTR140","WTR102","WTR224"
        },
        -- pack #2 in box #24
        [2] = {
            "WTR208","WTR179","WTR221","WTR222","WTR155","WTR050","WTR089","WTR021","WTR073","WTR025","WTR068","WTR032","WTR133","WTR099","WTR133","WTR078","WTR225"
        },
        -- pack #3 in box #24
        [3] = {
            "WTR189","WTR202","WTR187","WTR220","WTR151","WTR013","WTR050","WTR130","WTR028","WTR074","WTR033","WTR061","WTR103","WTR148","WTR100","WTR114","WTR040"
        },
        -- pack #4 in box #24
        [4] = {
            "WTR179","WTR188","WTR182","WTR222","WTR005","WTR012","WTR164","WTR068","WTR064","WTR025","WTR072","WTR111","WTR136","WTR104","WTR146","WTR038","WTR225"
        },
        -- pack #5 in box #24
        [5] = {
            "WTR193","WTR185","WTR186","WTR222","WTR151","WTR089","WTR120","WTR031","WTR020","WTR065","WTR027","WTR074","WTR109","WTR148","WTR099","WTR077","WTR003"
        },
        -- pack #6 in box #24
        [6] = {
            "WTR208","WTR209","WTR222","WTR203","WTR153","WTR089","WTR123","WTR117","WTR062","WTR037","WTR062","WTR025","WTR133","WTR110","WTR147","WTR077","WTR001"
        },
        -- pack #7 in box #24
        [7] = {
            "WTR184","WTR194","WTR197","WTR191","WTR154","WTR089","WTR166","WTR069","WTR022","WTR067","WTR020","WTR138","WTR098","WTR140","WTR104","WTR039","WTR225"
        },
        -- pack #8 in box #24
        [8] = {
            "WTR185","WTR192","WTR195","WTR196","WTR042","WTR171","WTR014","WTR217","WTR026","WTR062","WTR026","WTR147","WTR098","WTR148","WTR097","WTR002","WTR039"
        },
        -- pack #9 in box #24
        [9] = {
            "WTR193","WTR215","WTR223","WTR212","WTR153","WTR126","WTR128","WTR090","WTR064","WTR035","WTR067","WTR037","WTR136","WTR106","WTR147","WTR039","WTR114"
        },
        -- pack #10 in box #24
        [10] = {
            "WTR191","WTR209","WTR212","WTR207","WTR158","WTR169","WTR131","WTR127","WTR061","WTR036","WTR069","WTR028","WTR136","WTR103","WTR142","WTR002","WTR039"
        },
        -- pack #11 in box #24
        [11] = {
            "WTR196","WTR210","WTR198","WTR188","WTR154","WTR011","WTR051","WTR105","WTR026","WTR061","WTR021","WTR142","WTR111","WTR135","WTR109","WTR075","WTR040"
        },
        -- pack #12 in box #24
        [12] = {
            "WTR182","WTR198","WTR189","WTR217","WTR156","WTR167","WTR085","WTR212","WTR059","WTR023","WTR069","WTR026","WTR140","WTR095","WTR136","WTR003","WTR113"
        },
        -- pack #13 in box #24
        [13] = {
            "WTR212","WTR185","WTR218","WTR200","WTR005","WTR052","WTR129","WTR132","WTR067","WTR028","WTR060","WTR024","WTR145","WTR106","WTR135","WTR113","WTR040"
        },
        -- pack #14 in box #24
        [14] = {
            "WTR202","WTR193","WTR217","WTR213","WTR154","WTR093","WTR120","WTR097","WTR073","WTR025","WTR065","WTR109","WTR145","WTR101","WTR138","WTR002","WTR115"
        },
        -- pack #15 in box #24
        [15] = {
            "WTR187","WTR176","WTR222","WTR202","WTR154","WTR052","WTR130","WTR107","WTR027","WTR074","WTR027","WTR066","WTR098","WTR136","WTR110","WTR224"
        },
        -- pack #16 in box #24
        [16] = {
            "WTR177","WTR219","WTR215","WTR186","WTR117","WTR049","WTR006","WTR155","WTR020","WTR057","WTR036","WTR067","WTR106","WTR134","WTR107","WTR077","WTR002"
        },
        -- pack #17 in box #24
        [17] = {
            "WTR179","WTR222","WTR222","WTR193","WTR005","WTR012","WTR009","WTR096","WTR058","WTR027","WTR066","WTR112","WTR148","WTR101","WTR139","WTR003","WTR077"
        },
        -- pack #18 in box #24
        [18] = {
            "WTR210","WTR212","WTR223","WTR207","WTR155","WTR014","WTR169","WTR103","WTR020","WTR067","WTR027","WTR141","WTR095","WTR147","WTR105","WTR002","WTR039"
        },
        -- pack #19 in box #24
        [19] = {
            "WTR179","WTR176","WTR196","WTR198","WTR152","WTR053","WTR017","WTR071","WTR064","WTR021","WTR069","WTR105","WTR137","WTR101","WTR133","WTR225","WTR115"
        },
        -- pack #20 in box #24
        [20] = {
            "WTR180","WTR214","WTR211","WTR220","WTR155","WTR019","WTR173","WTR157","WTR060","WTR036","WTR073","WTR104","WTR134","WTR103","WTR136","WTR225","WTR115"
        },
        -- pack #21 in box #24
        [21] = {
            "WTR217","WTR187","WTR214","WTR185","WTR042","WTR012","WTR175","WTR183","WTR033","WTR062","WTR032","WTR140","WTR101","WTR145","WTR101","WTR224"
        },
        -- pack #22 in box #24
        [22] = {
            "WTR179","WTR197","WTR214","WTR208","WTR158","WTR131","WTR018","WTR211","WTR030","WTR061","WTR031","WTR065","WTR103","WTR149","WTR103","WTR225","WTR003"
        },
        -- pack #23 in box #24
        [23] = {
            "WTR220","WTR213","WTR180","WTR212","WTR151","WTR014","WTR056","WTR219","WTR022","WTR067","WTR031","WTR142","WTR104","WTR148","WTR097","WTR039","WTR003"
        },
        -- pack #24 in box #24
        [24] = {
            "WTR209","WTR181","WTR176","WTR194","WTR158","WTR019","WTR126","WTR059","WTR072","WTR027","WTR069","WTR102","WTR142","WTR095","WTR144","WTR002","WTR076"
        },
    },
    -- box #25
    [25] = {
        -- pack #1 in box #25
        [1] = {
            "WTR184","WTR208","WTR209","WTR207","WTR117","WTR019","WTR120","WTR109","WTR069","WTR027","WTR065","WTR102","WTR136","WTR104","WTR145","WTR075","WTR115"
        },
        -- pack #2 in box #25
        [2] = {
            "WTR212","WTR180","WTR200","WTR207","WTR157","WTR169","WTR169","WTR130","WTR062","WTR023","WTR069","WTR023","WTR137","WTR112","WTR139","WTR077","WTR040"
        },
        -- pack #3 in box #25
        [3] = {
            "WTR199","WTR222","WTR183","WTR212","WTR005","WTR018","WTR087","WTR028","WTR033","WTR073","WTR021","WTR057","WTR112","WTR147","WTR102","WTR224"
        },
        -- pack #4 in box #25
        [4] = {
            "WTR214","WTR185","WTR178","WTR198","WTR153","WTR125","WTR170","WTR171","WTR037","WTR060","WTR028","WTR060","WTR101","WTR145","WTR112","WTR003","WTR113"
        },
        -- pack #5 in box #25
        [5] = {
            "WTR206","WTR217","WTR191","WTR208","WTR157","WTR173","WTR045","WTR180","WTR024","WTR057","WTR028","WTR143","WTR105","WTR137","WTR107","WTR002","WTR076"
        },
        -- pack #6 in box #25
        [6] = {
            "WTR195","WTR220","WTR202","WTR211","WTR080","WTR131","WTR123","WTR204","WTR022","WTR068","WTR030","WTR146","WTR098","WTR145","WTR096","WTR225","WTR076"
        },
        -- pack #7 in box #25
        [7] = {
            "WTR193","WTR189","WTR188","WTR203","WTR157","WTR131","WTR006","WTR100","WTR036","WTR068","WTR037","WTR061","WTR095","WTR148","WTR106","WTR224"
        },
        -- pack #8 in box #25
        [8] = {
            "WTR211","WTR197","WTR193","WTR218","WTR042","WTR056","WTR015","WTR209","WTR060","WTR026","WTR071","WTR096","WTR137","WTR097","WTR141","WTR003","WTR040"
        },
        -- pack #9 in box #25
        [9] = {
            "WTR205","WTR187","WTR212","WTR186","WTR117","WTR128","WTR169","WTR133","WTR057","WTR025","WTR068","WTR031","WTR142","WTR097","WTR141","WTR078","WTR076"
        },
        -- pack #10 in box #25
        [10] = {
            "WTR212","WTR190","WTR181","WTR183","WTR155","WTR018","WTR174","WTR061","WTR059","WTR031","WTR072","WTR109","WTR133","WTR103","WTR134","WTR040","WTR003"
        },
        -- pack #11 in box #25
        [11] = {
            "WTR187","WTR210","WTR194","WTR182","WTR151","WTR127","WTR053","WTR165","WTR021","WTR065","WTR035","WTR065","WTR106","WTR145","WTR098","WTR002","WTR113"
        },
        -- pack #12 in box #25
        [12] = {
            "WTR188","WTR223","WTR176","WTR216","WTR154","WTR093","WTR173","WTR202","WTR058","WTR034","WTR069","WTR023","WTR146","WTR110","WTR139","WTR078","WTR075"
        },
        -- pack #13 in box #25
        [13] = {
            "WTR179","WTR220","WTR201","WTR207","WTR154","WTR171","WTR050","WTR063","WTR068","WTR029","WTR069","WTR029","WTR140","WTR104","WTR149","WTR224"
        },
        -- pack #14 in box #25
        [14] = {
            "WTR207","WTR201","WTR191","WTR176","WTR080","WTR017","WTR009","WTR026","WTR072","WTR023","WTR070","WTR112","WTR137","WTR103","WTR137","WTR113","WTR040"
        },
        -- pack #15 in box #25
        [15] = {
            "WTR189","WTR223","WTR185","WTR200","WTR153","WTR013","WTR175","WTR215","WTR070","WTR024","WTR057","WTR105","WTR139","WTR108","WTR144","WTR075","WTR003"
        },
        -- pack #16 in box #25
        [16] = {
            "WTR216","WTR195","WTR207","WTR222","WTR153","WTR055","WTR166","WTR129","WTR061","WTR032","WTR059","WTR028","WTR137","WTR097","WTR132","WTR038","WTR078"
        },
        -- pack #17 in box #25
        [17] = {
            "WTR203","WTR203","WTR216","WTR177","WTR156","WTR088","WTR054","WTR136","WTR027","WTR070","WTR032","WTR141","WTR110","WTR148","WTR096","WTR077","WTR113"
        },
        -- pack #18 in box #25
        [18] = {
            "WTR183","WTR196","WTR215","WTR205","WTR005","WTR053","WTR089","WTR176","WTR022","WTR071","WTR030","WTR141","WTR102","WTR136","WTR108","WTR003","WTR001"
        },
        -- pack #19 in box #25
        [19] = {
            "WTR180","WTR204","WTR212","WTR192","WTR042","WTR051","WTR159","WTR033","WTR060","WTR035","WTR064","WTR029","WTR134","WTR112","WTR135","WTR078","WTR076"
        },
        -- pack #20 in box #25
        [20] = {
            "WTR180","WTR180","WTR192","WTR204","WTR154","WTR167","WTR016","WTR129","WTR058","WTR024","WTR072","WTR110","WTR141","WTR105","WTR148","WTR039","WTR113"
        },
        -- pack #21 in box #25
        [21] = {
            "WTR182","WTR213","WTR201","WTR222","WTR154","WTR174","WTR175","WTR033","WTR028","WTR073","WTR029","WTR139","WTR111","WTR143","WTR110","WTR114","WTR225"
        },
        -- pack #22 in box #25
        [22] = {
            "WTR218","WTR187","WTR190","WTR209","WTR153","WTR018","WTR131","WTR066","WTR022","WTR069","WTR022","WTR139","WTR112","WTR141","WTR097","WTR077","WTR001"
        },
        -- pack #23 in box #25
        [23] = {
            "WTR188","WTR215","WTR189","WTR188","WTR158","WTR094","WTR170","WTR101","WTR037","WTR060","WTR034","WTR059","WTR100","WTR141","WTR112","WTR039","WTR078"
        },
        -- pack #24 in box #25
        [24] = {
            "WTR212","WTR211","WTR212","WTR216","WTR042","WTR092","WTR085","WTR206","WTR034","WTR073","WTR032","WTR063","WTR105","WTR137","WTR112","WTR225","WTR076"
        },
    },
    -- box #26
    [26] = {
        -- pack #1 in box #26
        [1] = {
            "WTR179","WTR208","WTR220","WTR187","WTR156","WTR173","WTR047","WTR179","WTR062","WTR033","WTR058","WTR024","WTR148","WTR104","WTR136","WTR076","WTR003"
        },
        -- pack #2 in box #26
        [2] = {
            "WTR205","WTR207","WTR221","WTR218","WTR117","WTR054","WTR081","WTR012","WTR074","WTR029","WTR063","WTR032","WTR135","WTR097","WTR141","WTR002","WTR039"
        },
        -- pack #3 in box #26
        [3] = {
            "WTR201","WTR201","WTR200","WTR219","WTR158","WTR167","WTR089","WTR011","WTR020","WTR064","WTR029","WTR142","WTR103","WTR145","WTR097","WTR040","WTR075"
        },
        -- pack #4 in box #26
        [4] = {
            "WTR195","WTR178","WTR206","WTR187","WTR080","WTR128","WTR159","WTR180","WTR033","WTR067","WTR027","WTR146","WTR100","WTR139","WTR095","WTR001","WTR076"
        },
        -- pack #5 in box #26
        [5] = {
            "WTR185","WTR187","WTR202","WTR184","WTR152","WTR016","WTR048","WTR148","WTR021","WTR071","WTR027","WTR137","WTR104","WTR147","WTR097","WTR003","WTR077"
        },
        -- pack #6 in box #26
        [6] = {
            "WTR182","WTR211","WTR180","WTR200","WTR151","WTR170","WTR050","WTR153","WTR023","WTR071","WTR032","WTR140","WTR099","WTR133","WTR103","WTR038","WTR001"
        },
        -- pack #7 in box #26
        [7] = {
            "WTR187","WTR205","WTR220","WTR191","WTR158","WTR011","WTR049","WTR103","WTR033","WTR073","WTR020","WTR058","WTR104","WTR137","WTR101","WTR114","WTR003"
        },
        -- pack #8 in box #26
        [8] = {
            "WTR196","WTR180","WTR212","WTR185","WTR005","WTR048","WTR168","WTR135","WTR060","WTR032","WTR068","WTR111","WTR147","WTR100","WTR143","WTR002","WTR003"
        },
        -- pack #9 in box #26
        [9] = {
            "WTR193","WTR213","WTR208","WTR211","WTR042","WTR172","WTR049","WTR135","WTR057","WTR033","WTR073","WTR096","WTR144","WTR109","WTR142","WTR114","WTR113"
        },
        -- pack #10 in box #26
        [10] = {
            "WTR220","WTR204","WTR207","WTR215","WTR005","WTR054","WTR119","WTR026","WTR034","WTR074","WTR031","WTR062","WTR112","WTR143","WTR099","WTR040","WTR225"
        },
        -- pack #11 in box #26
        [11] = {
            "WTR219","WTR193","WTR219","WTR202","WTR005","WTR170","WTR086","WTR140","WTR058","WTR027","WTR061","WTR023","WTR135","WTR104","WTR132","WTR225","WTR002"
        },
        -- pack #12 in box #26
        [12] = {
            "WTR214","WTR216","WTR209","WTR215","WTR156","WTR167","WTR087","WTR210","WTR034","WTR058","WTR024","WTR066","WTR105","WTR144","WTR096","WTR040","WTR114"
        },
        -- pack #13 in box #26
        [13] = {
            "WTR213","WTR181","WTR188","WTR221","WTR042","WTR166","WTR168","WTR017","WTR066","WTR037","WTR057","WTR101","WTR146","WTR112","WTR149","WTR039","WTR113"
        },
        -- pack #14 in box #26
        [14] = {
            "WTR215","WTR186","WTR206","WTR201","WTR157","WTR054","WTR159","WTR151","WTR036","WTR074","WTR032","WTR139","WTR095","WTR148","WTR109","WTR039","WTR040"
        },
        -- pack #15 in box #26
        [15] = {
            "WTR176","WTR204","WTR193","WTR185","WTR153","WTR126","WTR127","WTR095","WTR064","WTR027","WTR068","WTR030","WTR141","WTR104","WTR141","WTR075","WTR115"
        },
        -- pack #16 in box #26
        [16] = {
            "WTR186","WTR183","WTR190","WTR207","WTR080","WTR053","WTR018","WTR073","WTR060","WTR020","WTR061","WTR106","WTR137","WTR104","WTR149","WTR113","WTR039"
        },
        -- pack #17 in box #26
        [17] = {
            "WTR192","WTR198","WTR205","WTR199","WTR156","WTR054","WTR083","WTR127","WTR020","WTR062","WTR037","WTR071","WTR099","WTR137","WTR097","WTR003","WTR115"
        },
        -- pack #18 in box #26
        [18] = {
            "WTR196","WTR192","WTR198","WTR203","WTR157","WTR051","WTR166","WTR145","WTR033","WTR064","WTR034","WTR143","WTR100","WTR140","WTR096","WTR113","WTR003"
        },
        -- pack #19 in box #26
        [19] = {
            "WTR214","WTR208","WTR198","WTR176","WTR157","WTR167","WTR056","WTR172","WTR074","WTR030","WTR060","WTR029","WTR144","WTR106","WTR140","WTR077","WTR075"
        },
        -- pack #20 in box #26
        [20] = {
            "WTR215","WTR197","WTR212","WTR201","WTR042","WTR053","WTR015","WTR217","WTR059","WTR037","WTR059","WTR105","WTR137","WTR096","WTR136","WTR038","WTR003"
        },
        -- pack #21 in box #26
        [21] = {
            "WTR196","WTR182","WTR183","WTR193","WTR151","WTR087","WTR014","WTR152","WTR062","WTR037","WTR071","WTR020","WTR136","WTR102","WTR136","WTR225","WTR003"
        },
        -- pack #22 in box #26
        [22] = {
            "WTR217","WTR219","WTR202","WTR188","WTR005","WTR167","WTR011","WTR151","WTR029","WTR061","WTR020","WTR073","WTR101","WTR148","WTR105","WTR077","WTR225"
        },
        -- pack #23 in box #26
        [23] = {
            "WTR217","WTR204","WTR189","WTR207","WTR080","WTR174","WTR123","WTR074","WTR064","WTR032","WTR064","WTR104","WTR147","WTR099","WTR135","WTR002","WTR075"
        },
        -- pack #24 in box #26
        [24] = {
            "WTR186","WTR210","WTR201","WTR194","WTR158","WTR054","WTR171","WTR102","WTR027","WTR068","WTR037","WTR064","WTR096","WTR134","WTR096","WTR040","WTR225"
        },
    },
    -- box #27
    [27] = {
        -- pack #1 in box #27
        [1] = {
            "WTR201","WTR176","WTR186","WTR191","WTR042","WTR173","WTR051","WTR105","WTR058","WTR028","WTR066","WTR030","WTR133","WTR110","WTR146","WTR225","WTR075"
        },
        -- pack #2 in box #27
        [2] = {
            "WTR211","WTR208","WTR211","WTR194","WTR156","WTR015","WTR172","WTR151","WTR023","WTR060","WTR020","WTR133","WTR104","WTR135","WTR103","WTR114","WTR113"
        },
        -- pack #3 in box #27
        [3] = {
            "WTR180","WTR186","WTR177","WTR183","WTR154","WTR130","WTR046","WTR177","WTR057","WTR024","WTR072","WTR029","WTR149","WTR102","WTR134","WTR038","WTR039"
        },
        -- pack #4 in box #27
        [4] = {
            "WTR176","WTR177","WTR215","WTR186","WTR156","WTR049","WTR130","WTR027","WTR057","WTR029","WTR067","WTR105","WTR146","WTR100","WTR134","WTR038","WTR078"
        },
        -- pack #5 in box #27
        [5] = {
            "WTR177","WTR176","WTR195","WTR176","WTR157","WTR016","WTR090","WTR132","WTR073","WTR030","WTR063","WTR101","WTR138","WTR103","WTR145","WTR113","WTR002"
        },
        -- pack #6 in box #27
        [6] = {
            "WTR208","WTR181","WTR178","WTR189","WTR080","WTR017","WTR090","WTR074","WTR037","WTR059","WTR037","WTR072","WTR104","WTR139","WTR097","WTR038","WTR075"
        },
        -- pack #7 in box #27
        [7] = {
            "WTR210","WTR209","WTR179","WTR205","WTR154","WTR126","WTR127","WTR155","WTR034","WTR063","WTR036","WTR065","WTR107","WTR149","WTR110","WTR077","WTR075"
        },
        -- pack #8 in box #27
        [8] = {
            "WTR211","WTR188","WTR184","WTR209","WTR156","WTR094","WTR160","WTR142","WTR036","WTR074","WTR036","WTR060","WTR101","WTR137","WTR110","WTR077","WTR078"
        },
        -- pack #9 in box #27
        [9] = {
            "WTR193","WTR214","WTR222","WTR185","WTR152","WTR056","WTR170","WTR213","WTR069","WTR037","WTR057","WTR101","WTR139","WTR105","WTR135","WTR114","WTR040"
        },
        -- pack #10 in box #27
        [10] = {
            "WTR206","WTR178","WTR223","WTR218","WTR157","WTR093","WTR090","WTR152","WTR021","WTR058","WTR023","WTR144","WTR105","WTR138","WTR101","WTR001","WTR077"
        },
        -- pack #11 in box #27
        [11] = {
            "WTR212","WTR183","WTR209","WTR207","WTR155","WTR094","WTR086","WTR186","WTR037","WTR069","WTR023","WTR135","WTR107","WTR138","WTR110","WTR115","WTR075"
        },
        -- pack #12 in box #27
        [12] = {
            "WTR190","WTR189","WTR199","WTR187","WTR042","WTR053","WTR127","WTR106","WTR028","WTR072","WTR036","WTR133","WTR109","WTR143","WTR104","WTR115","WTR078"
        },
        -- pack #13 in box #27
        [13] = {
            "WTR207","WTR203","WTR222","WTR202","WTR158","WTR171","WTR054","WTR177","WTR035","WTR059","WTR021","WTR064","WTR109","WTR140","WTR106","WTR076","WTR225"
        },
        -- pack #14 in box #27
        [14] = {
            "WTR195","WTR189","WTR222","WTR177","WTR042","WTR088","WTR085","WTR147","WTR068","WTR032","WTR074","WTR036","WTR134","WTR108","WTR133","WTR002","WTR038"
        },
        -- pack #15 in box #27
        [15] = {
            "WTR222","WTR221","WTR198","WTR201","WTR080","WTR124","WTR084","WTR046","WTR057","WTR021","WTR060","WTR036","WTR138","WTR106","WTR147","WTR114","WTR038"
        },
        -- pack #16 in box #27
        [16] = {
            "WTR203","WTR183","WTR179","WTR181","WTR042","WTR018","WTR056","WTR088","WTR069","WTR022","WTR071","WTR098","WTR134","WTR095","WTR140","WTR003","WTR001"
        },
        -- pack #17 in box #27
        [17] = {
            "WTR178","WTR221","WTR223","WTR179","WTR151","WTR166","WTR168","WTR220","WTR063","WTR026","WTR057","WTR023","WTR146","WTR109","WTR147","WTR078","WTR002"
        },
        -- pack #18 in box #27
        [18] = {
            "WTR201","WTR205","WTR198","WTR208","WTR152","WTR168","WTR056","WTR197","WTR061","WTR033","WTR067","WTR020","WTR139","WTR111","WTR147","WTR115","WTR114"
        },
        -- pack #19 in box #27
        [19] = {
            "WTR210","WTR187","WTR177","WTR187","WTR152","WTR175","WTR162","WTR209","WTR037","WTR057","WTR023","WTR136","WTR111","WTR148","WTR100","WTR114","WTR115"
        },
        -- pack #20 in box #27
        [20] = {
            "WTR180","WTR203","WTR221","WTR188","WTR153","WTR056","WTR094","WTR133","WTR071","WTR031","WTR060","WTR104","WTR133","WTR095","WTR139","WTR075","WTR002"
        },
        -- pack #21 in box #27
        [21] = {
            "WTR209","WTR202","WTR177","WTR211","WTR154","WTR050","WTR089","WTR220","WTR033","WTR067","WTR032","WTR141","WTR096","WTR149","WTR100","WTR114","WTR115"
        },
        -- pack #22 in box #27
        [22] = {
            "WTR197","WTR186","WTR196","WTR214","WTR152","WTR049","WTR091","WTR016","WTR020","WTR069","WTR028","WTR065","WTR097","WTR136","WTR104","WTR077","WTR040"
        },
        -- pack #23 in box #27
        [23] = {
            "WTR205","WTR205","WTR182","WTR216","WTR153","WTR174","WTR092","WTR200","WTR070","WTR028","WTR063","WTR101","WTR147","WTR109","WTR140","WTR002","WTR038"
        },
        -- pack #24 in box #27
        [24] = {
            "WTR222","WTR223","WTR192","WTR195","WTR042","WTR131","WTR175","WTR174","WTR033","WTR057","WTR034","WTR057","WTR104","WTR143","WTR112","WTR078","WTR076"
        },
    },
    -- box #28
    [28] = {
        -- pack #1 in box #28
        [1] = {
            "WTR210","WTR219","WTR206","WTR213","WTR151","WTR093","WTR006","WTR089","WTR063","WTR020","WTR072","WTR098","WTR144","WTR105","WTR138","WTR039","WTR038"
        },
        -- pack #2 in box #28
        [2] = {
            "WTR221","WTR222","WTR195","WTR222","WTR005","WTR125","WTR127","WTR134","WTR029","WTR072","WTR035","WTR073","WTR097","WTR138","WTR095","WTR002","WTR039"
        },
        -- pack #3 in box #28
        [3] = {
            "WTR199","WTR192","WTR180","WTR214","WTR154","WTR054","WTR091","WTR086","WTR071","WTR029","WTR074","WTR025","WTR143","WTR112","WTR134","WTR225","WTR075"
        },
        -- pack #4 in box #28
        [4] = {
            "WTR201","WTR190","WTR210","WTR196","WTR158","WTR125","WTR051","WTR136","WTR034","WTR072","WTR020","WTR074","WTR096","WTR147","WTR105","WTR038","WTR040"
        },
        -- pack #5 in box #28
        [5] = {
            "WTR209","WTR218","WTR219","WTR216","WTR156","WTR173","WTR090","WTR191","WTR034","WTR073","WTR028","WTR070","WTR108","WTR141","WTR108","WTR075","WTR114"
        },
        -- pack #6 in box #28
        [6] = {
            "WTR199","WTR179","WTR211","WTR215","WTR042","WTR017","WTR130","WTR012","WTR060","WTR031","WTR071","WTR095","WTR138","WTR109","WTR141","WTR040","WTR077"
        },
        -- pack #7 in box #28
        [7] = {
            "WTR214","WTR197","WTR197","WTR181","WTR151","WTR014","WTR168","WTR191","WTR028","WTR066","WTR025","WTR058","WTR099","WTR144","WTR100","WTR114","WTR040"
        },
        -- pack #8 in box #28
        [8] = {
            "WTR197","WTR185","WTR205","WTR203","WTR117","WTR167","WTR159","WTR175","WTR029","WTR069","WTR033","WTR059","WTR101","WTR140","WTR112","WTR225","WTR078"
        },
        -- pack #9 in box #28
        [9] = {
            "WTR196","WTR215","WTR201","WTR213","WTR117","WTR086","WTR083","WTR128","WTR066","WTR035","WTR062","WTR033","WTR133","WTR098","WTR149","WTR113","WTR039"
        },
        -- pack #10 in box #28
        [10] = {
            "WTR196","WTR193","WTR210","WTR181","WTR157","WTR051","WTR050","WTR207","WTR066","WTR034","WTR070","WTR098","WTR145","WTR096","WTR146","WTR077","WTR039"
        },
        -- pack #11 in box #28
        [11] = {
            "WTR203","WTR220","WTR199","WTR202","WTR154","WTR094","WTR015","WTR194","WTR061","WTR032","WTR057","WTR034","WTR147","WTR111","WTR135","WTR114","WTR003"
        },
        -- pack #12 in box #28
        [12] = {
            "WTR196","WTR216","WTR182","WTR208","WTR042","WTR170","WTR168","WTR112","WTR032","WTR060","WTR030","WTR149","WTR101","WTR146","WTR103","WTR077","WTR225"
        },
        -- pack #13 in box #28
        [13] = {
            "WTR216","WTR218","WTR183","WTR216","WTR154","WTR169","WTR164","WTR064","WTR069","WTR020","WTR065","WTR020","WTR145","WTR102","WTR146","WTR075","WTR077"
        },
        -- pack #14 in box #28
        [14] = {
            "WTR185","WTR221","WTR206","WTR196","WTR158","WTR129","WTR167","WTR029","WTR073","WTR030","WTR073","WTR028","WTR141","WTR112","WTR143","WTR113","WTR225"
        },
        -- pack #15 in box #28
        [15] = {
            "WTR195","WTR208","WTR204","WTR182","WTR117","WTR165","WTR172","WTR136","WTR063","WTR022","WTR071","WTR023","WTR136","WTR098","WTR143","WTR115","WTR040"
        },
        -- pack #16 in box #28
        [16] = {
            "WTR222","WTR212","WTR206","WTR211","WTR157","WTR124","WTR012","WTR128","WTR074","WTR036","WTR057","WTR096","WTR149","WTR096","WTR143","WTR225","WTR114"
        },
        -- pack #17 in box #28
        [17] = {
            "WTR189","WTR202","WTR221","WTR192","WTR117","WTR055","WTR044","WTR215","WTR032","WTR063","WTR036","WTR132","WTR112","WTR137","WTR101","WTR002","WTR077"
        },
        -- pack #18 in box #28
        [18] = {
            "WTR205","WTR209","WTR213","WTR180","WTR154","WTR088","WTR130","WTR217","WTR027","WTR062","WTR032","WTR142","WTR102","WTR132","WTR109","WTR076","WTR040"
        },
        -- pack #19 in box #28
        [19] = {
            "WTR209","WTR197","WTR205","WTR202","WTR157","WTR052","WTR089","WTR097","WTR027","WTR059","WTR031","WTR146","WTR096","WTR149","WTR098","WTR224"
        },
        -- pack #20 in box #28
        [20] = {
            "WTR186","WTR190","WTR188","WTR186","WTR080","WTR173","WTR015","WTR194","WTR034","WTR062","WTR031","WTR148","WTR112","WTR136","WTR098","WTR039","WTR115"
        },
        -- pack #21 in box #28
        [21] = {
            "WTR190","WTR210","WTR216","WTR176","WTR156","WTR089","WTR093","WTR143","WTR029","WTR074","WTR035","WTR068","WTR105","WTR135","WTR111","WTR115","WTR225"
        },
        -- pack #22 in box #28
        [22] = {
            "WTR220","WTR219","WTR200","WTR179","WTR151","WTR056","WTR123","WTR023","WTR059","WTR032","WTR072","WTR098","WTR136","WTR096","WTR135","WTR224"
        },
        -- pack #23 in box #28
        [23] = {
            "WTR192","WTR220","WTR200","WTR199","WTR158","WTR130","WTR130","WTR050","WTR070","WTR036","WTR057","WTR097","WTR135","WTR106","WTR137","WTR001","WTR075"
        },
        -- pack #24 in box #28
        [24] = {
            "WTR202","WTR180","WTR217","WTR214","WTR154","WTR171","WTR172","WTR048","WTR025","WTR071","WTR027","WTR140","WTR107","WTR139","WTR097","WTR003","WTR002"
        },
    },
    -- box #29
    [29] = {
        -- pack #1 in box #29
        [1] = {
            "WTR191","WTR212","WTR180","WTR211","WTR152","WTR168","WTR012","WTR070","WTR036","WTR071","WTR029","WTR063","WTR111","WTR145","WTR111","WTR224"
        },
        -- pack #2 in box #29
        [2] = {
            "WTR176","WTR212","WTR201","WTR191","WTR158","WTR086","WTR170","WTR133","WTR069","WTR020","WTR064","WTR111","WTR146","WTR101","WTR146","WTR113","WTR078"
        },
        -- pack #3 in box #29
        [3] = {
            "WTR217","WTR178","WTR209","WTR216","WTR155","WTR164","WTR125","WTR145","WTR059","WTR021","WTR062","WTR106","WTR148","WTR096","WTR146","WTR040","WTR002"
        },
        -- pack #4 in box #29
        [4] = {
            "WTR177","WTR196","WTR186","WTR218","WTR152","WTR131","WTR009","WTR054","WTR028","WTR070","WTR031","WTR146","WTR109","WTR134","WTR108","WTR002","WTR078"
        },
        -- pack #5 in box #29
        [5] = {
            "WTR209","WTR206","WTR187","WTR191","WTR151","WTR089","WTR053","WTR205","WTR027","WTR068","WTR023","WTR143","WTR108","WTR145","WTR097","WTR225","WTR003"
        },
        -- pack #6 in box #29
        [6] = {
            "WTR205","WTR179","WTR212","WTR197","WTR005","WTR169","WTR170","WTR073","WTR058","WTR022","WTR065","WTR108","WTR148","WTR105","WTR139","WTR115","WTR078"
        },
        -- pack #7 in box #29
        [7] = {
            "WTR203","WTR220","WTR182","WTR204","WTR151","WTR017","WTR093","WTR145","WTR070","WTR022","WTR063","WTR108","WTR144","WTR109","WTR133","WTR001","WTR114"
        },
        -- pack #8 in box #29
        [8] = {
            "WTR195","WTR184","WTR180","WTR223","WTR154","WTR054","WTR093","WTR149","WTR030","WTR069","WTR025","WTR138","WTR098","WTR145","WTR112","WTR224"
        },
        -- pack #9 in box #29
        [9] = {
            "WTR201","WTR179","WTR202","WTR198","WTR153","WTR164","WTR051","WTR223","WTR074","WTR024","WTR057","WTR096","WTR143","WTR106","WTR149","WTR078","WTR039"
        },
        -- pack #10 in box #29
        [10] = {
            "WTR179","WTR176","WTR216","WTR215","WTR152","WTR169","WTR012","WTR146","WTR036","WTR059","WTR035","WTR066","WTR109","WTR145","WTR100","WTR115","WTR078"
        },
        -- pack #11 in box #29
        [11] = {
            "WTR219","WTR218","WTR197","WTR192","WTR157","WTR124","WTR082","WTR021","WTR037","WTR067","WTR027","WTR060","WTR112","WTR136","WTR098","WTR075","WTR002"
        },
        -- pack #12 in box #29
        [12] = {
            "WTR178","WTR182","WTR197","WTR190","WTR155","WTR051","WTR128","WTR205","WTR062","WTR036","WTR058","WTR112","WTR140","WTR110","WTR137","WTR001","WTR002"
        },
        -- pack #13 in box #29
        [13] = {
            "WTR194","WTR201","WTR209","WTR182","WTR005","WTR091","WTR010","WTR096","WTR059","WTR023","WTR059","WTR036","WTR147","WTR104","WTR135","WTR077","WTR114"
        },
        -- pack #14 in box #29
        [14] = {
            "WTR203","WTR207","WTR208","WTR186","WTR155","WTR094","WTR013","WTR034","WTR071","WTR030","WTR061","WTR025","WTR149","WTR103","WTR149","WTR038","WTR076"
        },
        -- pack #15 in box #29
        [15] = {
            "WTR216","WTR221","WTR205","WTR217","WTR157","WTR129","WTR086","WTR118","WTR070","WTR028","WTR070","WTR037","WTR145","WTR109","WTR137","WTR075","WTR076"
        },
        -- pack #16 in box #29
        [16] = {
            "WTR202","WTR188","WTR176","WTR221","WTR152","WTR173","WTR008","WTR203","WTR060","WTR037","WTR061","WTR023","WTR133","WTR110","WTR138","WTR077","WTR038"
        },
        -- pack #17 in box #29
        [17] = {
            "WTR200","WTR211","WTR197","WTR206","WTR156","WTR167","WTR014","WTR148","WTR072","WTR020","WTR065","WTR034","WTR134","WTR099","WTR133","WTR115","WTR038"
        },
        -- pack #18 in box #29
        [18] = {
            "WTR222","WTR196","WTR222","WTR185","WTR005","WTR127","WTR123","WTR162","WTR027","WTR061","WTR030","WTR063","WTR098","WTR138","WTR108","WTR001","WTR075"
        },
        -- pack #19 in box #29
        [19] = {
            "WTR182","WTR190","WTR198","WTR181","WTR157","WTR172","WTR129","WTR181","WTR032","WTR063","WTR022","WTR132","WTR098","WTR148","WTR096","WTR225","WTR114"
        },
        -- pack #20 in box #29
        [20] = {
            "WTR200","WTR192","WTR222","WTR187","WTR154","WTR165","WTR165","WTR142","WTR034","WTR058","WTR026","WTR140","WTR108","WTR136","WTR110","WTR114","WTR002"
        },
        -- pack #21 in box #29
        [21] = {
            "WTR201","WTR195","WTR176","WTR180","WTR154","WTR168","WTR046","WTR222","WTR024","WTR063","WTR020","WTR063","WTR097","WTR132","WTR105","WTR077","WTR114"
        },
        -- pack #22 in box #29
        [22] = {
            "WTR188","WTR195","WTR207","WTR192","WTR158","WTR094","WTR053","WTR140","WTR020","WTR058","WTR025","WTR146","WTR107","WTR147","WTR103","WTR038","WTR114"
        },
        -- pack #23 in box #29
        [23] = {
            "WTR219","WTR211","WTR206","WTR223","WTR151","WTR167","WTR126","WTR065","WTR066","WTR037","WTR058","WTR022","WTR147","WTR106","WTR138","WTR114","WTR077"
        },
        -- pack #24 in box #29
        [24] = {
            "WTR203","WTR213","WTR200","WTR187","WTR158","WTR088","WTR091","WTR216","WTR034","WTR059","WTR034","WTR065","WTR105","WTR135","WTR100","WTR001","WTR114"
        },
    },
    -- box #30
    [30] = {
        -- pack #1 in box #30
        [1] = {
            "WTR215","WTR200","WTR194","WTR212","WTR156","WTR013","WTR171","WTR100","WTR034","WTR068","WTR034","WTR059","WTR105","WTR147","WTR112","WTR113","WTR077"
        },
        -- pack #2 in box #30
        [2] = {
            "WTR176","WTR191","WTR221","WTR219","WTR155","WTR167","WTR170","WTR217","WTR026","WTR067","WTR022","WTR074","WTR100","WTR139","WTR101","WTR039","WTR115"
        },
        -- pack #3 in box #30
        [3] = {
            "WTR218","WTR206","WTR221","WTR206","WTR157","WTR051","WTR165","WTR199","WTR067","WTR025","WTR057","WTR102","WTR144","WTR101","WTR149","WTR225","WTR038"
        },
        -- pack #4 in box #30
        [4] = {
            "WTR213","WTR216","WTR209","WTR194","WTR117","WTR019","WTR127","WTR151","WTR029","WTR061","WTR021","WTR136","WTR099","WTR136","WTR102","WTR003","WTR040"
        },
        -- pack #5 in box #30
        [5] = {
            "WTR182","WTR223","WTR203","WTR182","WTR157","WTR051","WTR121","WTR184","WTR058","WTR035","WTR060","WTR020","WTR139","WTR112","WTR146","WTR076","WTR113"
        },
        -- pack #6 in box #30
        [6] = {
            "WTR194","WTR185","WTR204","WTR191","WTR117","WTR170","WTR052","WTR199","WTR029","WTR069","WTR036","WTR074","WTR106","WTR139","WTR100","WTR002","WTR001"
        },
        -- pack #7 in box #30
        [7] = {
            "WTR204","WTR186","WTR211","WTR212","WTR154","WTR168","WTR087","WTR136","WTR073","WTR024","WTR071","WTR037","WTR145","WTR098","WTR141","WTR075","WTR113"
        },
        -- pack #8 in box #30
        [8] = {
            "WTR181","WTR189","WTR218","WTR202","WTR153","WTR051","WTR048","WTR060","WTR070","WTR030","WTR069","WTR033","WTR137","WTR104","WTR133","WTR003","WTR002"
        },
        -- pack #9 in box #30
        [9] = {
            "WTR190","WTR199","WTR193","WTR205","WTR042","WTR175","WTR082","WTR177","WTR030","WTR072","WTR033","WTR148","WTR096","WTR134","WTR103","WTR225","WTR115"
        },
        -- pack #10 in box #30
        [10] = {
            "WTR213","WTR215","WTR193","WTR206","WTR157","WTR172","WTR124","WTR207","WTR062","WTR020","WTR070","WTR110","WTR137","WTR112","WTR140","WTR114","WTR078"
        },
        -- pack #11 in box #30
        [11] = {
            "WTR215","WTR215","WTR207","WTR195","WTR156","WTR089","WTR120","WTR033","WTR057","WTR024","WTR069","WTR034","WTR139","WTR104","WTR137","WTR076","WTR040"
        },
        -- pack #12 in box #30
        [12] = {
            "WTR217","WTR209","WTR183","WTR205","WTR151","WTR089","WTR171","WTR086","WTR033","WTR071","WTR028","WTR061","WTR111","WTR137","WTR107","WTR076","WTR040"
        },
        -- pack #13 in box #30
        [13] = {
            "WTR182","WTR189","WTR202","WTR217","WTR153","WTR131","WTR164","WTR195","WTR060","WTR035","WTR066","WTR111","WTR144","WTR109","WTR136","WTR038","WTR075"
        },
        -- pack #14 in box #30
        [14] = {
            "WTR206","WTR188","WTR181","WTR206","WTR005","WTR130","WTR175","WTR125","WTR034","WTR067","WTR029","WTR138","WTR109","WTR146","WTR110","WTR078","WTR115"
        },
        -- pack #15 in box #30
        [15] = {
            "WTR214","WTR176","WTR212","WTR205","WTR080","WTR169","WTR019","WTR112","WTR027","WTR058","WTR025","WTR060","WTR101","WTR148","WTR107","WTR039","WTR225"
        },
        -- pack #16 in box #30
        [16] = {
            "WTR190","WTR210","WTR176","WTR181","WTR117","WTR019","WTR160","WTR148","WTR074","WTR023","WTR064","WTR021","WTR144","WTR108","WTR135","WTR225","WTR113"
        },
        -- pack #17 in box #30
        [17] = {
            "WTR198","WTR196","WTR180","WTR209","WTR155","WTR090","WTR050","WTR196","WTR024","WTR066","WTR032","WTR135","WTR111","WTR135","WTR105","WTR040","WTR075"
        },
        -- pack #18 in box #30
        [18] = {
            "WTR209","WTR213","WTR196","WTR178","WTR156","WTR090","WTR012","WTR031","WTR022","WTR057","WTR034","WTR068","WTR099","WTR139","WTR111","WTR114","WTR001"
        },
        -- pack #19 in box #30
        [19] = {
            "WTR193","WTR177","WTR182","WTR195","WTR153","WTR130","WTR014","WTR057","WTR073","WTR029","WTR071","WTR025","WTR132","WTR095","WTR138","WTR075","WTR038"
        },
        -- pack #20 in box #30
        [20] = {
            "WTR219","WTR203","WTR203","WTR191","WTR005","WTR089","WTR084","WTR058","WTR059","WTR025","WTR060","WTR098","WTR133","WTR102","WTR140","WTR077","WTR078"
        },
        -- pack #21 in box #30
        [21] = {
            "WTR199","WTR180","WTR179","WTR205","WTR151","WTR123","WTR091","WTR008","WTR027","WTR070","WTR022","WTR149","WTR097","WTR133","WTR111","WTR113","WTR114"
        },
        -- pack #22 in box #30
        [22] = {
            "WTR177","WTR196","WTR182","WTR187","WTR157","WTR170","WTR160","WTR178","WTR059","WTR036","WTR062","WTR096","WTR146","WTR106","WTR145","WTR225","WTR113"
        },
        -- pack #23 in box #30
        [23] = {
            "WTR193","WTR188","WTR208","WTR211","WTR042","WTR015","WTR124","WTR066","WTR027","WTR064","WTR023","WTR138","WTR106","WTR135","WTR106","WTR225","WTR078"
        },
        -- pack #24 in box #30
        [24] = {
            "WTR181","WTR194","WTR204","WTR180","WTR154","WTR088","WTR094","WTR060","WTR062","WTR023","WTR069","WTR108","WTR132","WTR106","WTR134","WTR076","WTR001"
        },
    },
    -- box #31
    [31] = {
        -- pack #1 in box #31
        [1] = {
            "WTR194","WTR190","WTR195","WTR218","WTR155","WTR131","WTR088","WTR167","WTR073","WTR020","WTR073","WTR096","WTR143","WTR102","WTR145","WTR076","WTR040"
        },
        -- pack #2 in box #31
        [2] = {
            "WTR216","WTR208","WTR183","WTR190","WTR156","WTR126","WTR093","WTR109","WTR034","WTR064","WTR024","WTR145","WTR112","WTR149","WTR102","WTR115","WTR039"
        },
        -- pack #3 in box #31
        [3] = {
            "WTR211","WTR220","WTR186","WTR202","WTR005","WTR051","WTR121","WTR202","WTR025","WTR070","WTR022","WTR062","WTR095","WTR136","WTR106","WTR003","WTR114"
        },
        -- pack #4 in box #31
        [4] = {
            "WTR192","WTR196","WTR196","WTR214","WTR158","WTR128","WTR167","WTR013","WTR058","WTR028","WTR066","WTR105","WTR132","WTR097","WTR138","WTR078","WTR077"
        },
        -- pack #5 in box #31
        [5] = {
            "WTR218","WTR200","WTR190","WTR199","WTR042","WTR051","WTR128","WTR031","WTR030","WTR057","WTR024","WTR147","WTR112","WTR135","WTR102","WTR115","WTR225"
        },
        -- pack #6 in box #31
        [6] = {
            "WTR186","WTR200","WTR194","WTR191","WTR080","WTR124","WTR090","WTR212","WTR060","WTR026","WTR073","WTR106","WTR142","WTR112","WTR138","WTR038","WTR002"
        },
        -- pack #7 in box #31
        [7] = {
            "WTR197","WTR206","WTR179","WTR179","WTR157","WTR088","WTR120","WTR145","WTR063","WTR026","WTR063","WTR033","WTR132","WTR109","WTR136","WTR076","WTR113"
        },
        -- pack #8 in box #31
        [8] = {
            "WTR202","WTR219","WTR207","WTR198","WTR158","WTR011","WTR124","WTR192","WTR037","WTR058","WTR026","WTR147","WTR097","WTR140","WTR097","WTR002","WTR038"
        },
        -- pack #9 in box #31
        [9] = {
            "WTR212","WTR222","WTR191","WTR202","WTR154","WTR087","WTR163","WTR140","WTR069","WTR035","WTR073","WTR031","WTR138","WTR107","WTR136","WTR225","WTR038"
        },
        -- pack #10 in box #31
        [10] = {
            "WTR218","WTR211","WTR223","WTR183","WTR155","WTR090","WTR014","WTR092","WTR063","WTR028","WTR063","WTR037","WTR138","WTR100","WTR144","WTR002","WTR003"
        },
        -- pack #11 in box #31
        [11] = {
            "WTR181","WTR182","WTR202","WTR222","WTR042","WTR127","WTR014","WTR190","WTR069","WTR022","WTR064","WTR105","WTR132","WTR098","WTR132","WTR113","WTR077"
        },
        -- pack #12 in box #31
        [12] = {
            "WTR210","WTR180","WTR179","WTR219","WTR156","WTR011","WTR168","WTR027","WTR069","WTR032","WTR062","WTR021","WTR143","WTR110","WTR142","WTR003","WTR076"
        },
        -- pack #13 in box #31
        [13] = {
            "WTR203","WTR216","WTR183","WTR193","WTR152","WTR170","WTR049","WTR201","WTR023","WTR068","WTR021","WTR144","WTR096","WTR144","WTR095","WTR001","WTR003"
        },
        -- pack #14 in box #31
        [14] = {
            "WTR197","WTR192","WTR176","WTR188","WTR154","WTR166","WTR084","WTR102","WTR026","WTR063","WTR028","WTR063","WTR109","WTR140","WTR102","WTR039","WTR115"
        },
        -- pack #15 in box #31
        [15] = {
            "WTR188","WTR181","WTR223","WTR189","WTR152","WTR166","WTR171","WTR032","WTR034","WTR062","WTR022","WTR062","WTR100","WTR142","WTR106","WTR038","WTR078"
        },
        -- pack #16 in box #31
        [16] = {
            "WTR197","WTR212","WTR213","WTR192","WTR157","WTR168","WTR010","WTR093","WTR035","WTR062","WTR036","WTR144","WTR104","WTR145","WTR095","WTR113","WTR039"
        },
        -- pack #17 in box #31
        [17] = {
            "WTR197","WTR195","WTR204","WTR199","WTR155","WTR088","WTR166","WTR190","WTR065","WTR029","WTR065","WTR022","WTR148","WTR110","WTR133","WTR113","WTR038"
        },
        -- pack #18 in box #31
        [18] = {
            "WTR181","WTR215","WTR190","WTR203","WTR151","WTR131","WTR119","WTR111","WTR037","WTR063","WTR036","WTR059","WTR111","WTR133","WTR097","WTR114","WTR003"
        },
        -- pack #19 in box #31
        [19] = {
            "WTR179","WTR178","WTR181","WTR206","WTR156","WTR049","WTR174","WTR024","WTR029","WTR059","WTR036","WTR132","WTR102","WTR140","WTR101","WTR113","WTR077"
        },
        -- pack #20 in box #31
        [20] = {
            "WTR190","WTR216","WTR202","WTR222","WTR156","WTR092","WTR011","WTR117","WTR072","WTR021","WTR066","WTR109","WTR149","WTR098","WTR135","WTR076","WTR113"
        },
        -- pack #21 in box #31
        [21] = {
            "WTR207","WTR212","WTR188","WTR198","WTR080","WTR052","WTR169","WTR180","WTR068","WTR021","WTR063","WTR111","WTR147","WTR107","WTR140","WTR002","WTR075"
        },
        -- pack #22 in box #31
        [22] = {
            "WTR219","WTR205","WTR192","WTR181","WTR005","WTR053","WTR014","WTR137","WTR024","WTR074","WTR035","WTR069","WTR111","WTR135","WTR097","WTR075","WTR040"
        },
        -- pack #23 in box #31
        [23] = {
            "WTR181","WTR178","WTR180","WTR214","WTR153","WTR048","WTR016","WTR181","WTR072","WTR030","WTR067","WTR021","WTR133","WTR108","WTR144","WTR077","WTR078"
        },
        -- pack #24 in box #31
        [24] = {
            "WTR181","WTR183","WTR203","WTR180","WTR155","WTR017","WTR170","WTR048","WTR027","WTR058","WTR029","WTR058","WTR106","WTR133","WTR109","WTR113","WTR003"
        },
    },
    -- box #32
    [32] = {
        -- pack #1 in box #32
        [1] = {
            "WTR201","WTR189","WTR181","WTR176","WTR157","WTR174","WTR012","WTR080","WTR031","WTR059","WTR035","WTR148","WTR110","WTR145","WTR101","WTR076","WTR114"
        },
        -- pack #2 in box #32
        [2] = {
            "WTR198","WTR188","WTR187","WTR195","WTR005","WTR123","WTR019","WTR110","WTR073","WTR021","WTR073","WTR095","WTR136","WTR106","WTR135","WTR113","WTR001"
        },
        -- pack #3 in box #32
        [3] = {
            "WTR219","WTR189","WTR214","WTR194","WTR042","WTR167","WTR018","WTR135","WTR028","WTR070","WTR032","WTR136","WTR102","WTR133","WTR099","WTR224"
        },
        -- pack #4 in box #32
        [4] = {
            "WTR223","WTR208","WTR207","WTR198","WTR153","WTR013","WTR128","WTR036","WTR066","WTR023","WTR057","WTR022","WTR136","WTR096","WTR139","WTR225","WTR003"
        },
        -- pack #5 in box #32
        [5] = {
            "WTR214","WTR204","WTR207","WTR214","WTR151","WTR168","WTR118","WTR027","WTR024","WTR065","WTR025","WTR148","WTR101","WTR135","WTR104","WTR115","WTR038"
        },
        -- pack #6 in box #32
        [6] = {
            "WTR179","WTR181","WTR200","WTR176","WTR005","WTR094","WTR175","WTR140","WTR037","WTR073","WTR037","WTR071","WTR102","WTR141","WTR098","WTR040","WTR038"
        },
        -- pack #7 in box #32
        [7] = {
            "WTR206","WTR222","WTR199","WTR190","WTR117","WTR164","WTR122","WTR062","WTR066","WTR033","WTR063","WTR029","WTR149","WTR098","WTR137","WTR113","WTR075"
        },
        -- pack #8 in box #32
        [8] = {
            "WTR213","WTR194","WTR210","WTR176","WTR042","WTR167","WTR168","WTR088","WTR034","WTR074","WTR023","WTR071","WTR109","WTR144","WTR100","WTR076","WTR038"
        },
        -- pack #9 in box #32
        [9] = {
            "WTR214","WTR186","WTR218","WTR212","WTR154","WTR051","WTR122","WTR191","WTR020","WTR072","WTR034","WTR068","WTR102","WTR143","WTR106","WTR040","WTR225"
        },
        -- pack #10 in box #32
        [10] = {
            "WTR213","WTR214","WTR182","WTR199","WTR158","WTR168","WTR051","WTR051","WTR036","WTR073","WTR032","WTR072","WTR095","WTR145","WTR099","WTR115","WTR075"
        },
        -- pack #11 in box #32
        [11] = {
            "WTR205","WTR176","WTR199","WTR215","WTR154","WTR053","WTR048","WTR213","WTR030","WTR065","WTR031","WTR145","WTR105","WTR138","WTR101","WTR078","WTR038"
        },
        -- pack #12 in box #32
        [12] = {
            "WTR202","WTR181","WTR187","WTR212","WTR005","WTR166","WTR089","WTR053","WTR026","WTR060","WTR020","WTR135","WTR108","WTR140","WTR099","WTR039","WTR113"
        },
        -- pack #13 in box #32
        [13] = {
            "WTR184","WTR193","WTR177","WTR217","WTR042","WTR090","WTR169","WTR064","WTR069","WTR023","WTR060","WTR104","WTR135","WTR104","WTR148","WTR001","WTR077"
        },
        -- pack #14 in box #32
        [14] = {
            "WTR181","WTR177","WTR218","WTR204","WTR158","WTR169","WTR167","WTR055","WTR065","WTR025","WTR062","WTR108","WTR143","WTR102","WTR145","WTR114","WTR077"
        },
        -- pack #15 in box #32
        [15] = {
            "WTR209","WTR201","WTR208","WTR217","WTR154","WTR018","WTR166","WTR187","WTR064","WTR026","WTR070","WTR105","WTR133","WTR104","WTR134","WTR114","WTR115"
        },
        -- pack #16 in box #32
        [16] = {
            "WTR191","WTR183","WTR191","WTR210","WTR080","WTR175","WTR007","WTR188","WTR071","WTR029","WTR071","WTR034","WTR140","WTR101","WTR144","WTR113","WTR225"
        },
        -- pack #17 in box #32
        [17] = {
            "WTR183","WTR209","WTR200","WTR186","WTR156","WTR087","WTR015","WTR054","WTR072","WTR037","WTR062","WTR109","WTR134","WTR095","WTR144","WTR224"
        },
        -- pack #18 in box #32
        [18] = {
            "WTR189","WTR176","WTR218","WTR219","WTR153","WTR169","WTR093","WTR097","WTR031","WTR067","WTR036","WTR060","WTR110","WTR132","WTR110","WTR038","WTR002"
        },
        -- pack #19 in box #32
        [19] = {
            "WTR183","WTR182","WTR205","WTR209","WTR152","WTR167","WTR092","WTR116","WTR060","WTR034","WTR059","WTR025","WTR140","WTR104","WTR133","WTR075","WTR039"
        },
        -- pack #20 in box #32
        [20] = {
            "WTR187","WTR196","WTR190","WTR198","WTR151","WTR051","WTR169","WTR087","WTR070","WTR027","WTR062","WTR110","WTR143","WTR104","WTR136","WTR224"
        },
        -- pack #21 in box #32
        [21] = {
            "WTR204","WTR194","WTR186","WTR216","WTR157","WTR172","WTR052","WTR153","WTR032","WTR072","WTR037","WTR064","WTR109","WTR145","WTR109","WTR078","WTR113"
        },
        -- pack #22 in box #32
        [22] = {
            "WTR212","WTR195","WTR201","WTR204","WTR005","WTR125","WTR054","WTR180","WTR066","WTR036","WTR069","WTR020","WTR138","WTR107","WTR140","WTR115","WTR113"
        },
        -- pack #23 in box #32
        [23] = {
            "WTR204","WTR186","WTR177","WTR203","WTR152","WTR124","WTR053","WTR168","WTR060","WTR031","WTR059","WTR030","WTR142","WTR099","WTR142","WTR075","WTR077"
        },
        -- pack #24 in box #32
        [24] = {
            "WTR219","WTR177","WTR177","WTR214","WTR151","WTR018","WTR174","WTR016","WTR030","WTR066","WTR026","WTR144","WTR097","WTR147","WTR098","WTR078","WTR077"
        },
    },
    -- box #33
    [33] = {
        -- pack #1 in box #33
        [1] = {
            "WTR194","WTR218","WTR186","WTR221","WTR152","WTR052","WTR054","WTR116","WTR028","WTR064","WTR035","WTR058","WTR105","WTR132","WTR107","WTR113","WTR076"
        },
        -- pack #2 in box #33
        [2] = {
            "WTR190","WTR211","WTR212","WTR222","WTR156","WTR091","WTR129","WTR216","WTR031","WTR071","WTR025","WTR059","WTR111","WTR140","WTR108","WTR075","WTR225"
        },
        -- pack #3 in box #33
        [3] = {
            "WTR208","WTR210","WTR217","WTR178","WTR117","WTR123","WTR045","WTR050","WTR061","WTR021","WTR071","WTR107","WTR135","WTR109","WTR141","WTR076","WTR002"
        },
        -- pack #4 in box #33
        [4] = {
            "WTR177","WTR188","WTR204","WTR210","WTR080","WTR054","WTR093","WTR186","WTR027","WTR065","WTR036","WTR064","WTR097","WTR144","WTR111","WTR003","WTR039"
        },
        -- pack #5 in box #33
        [5] = {
            "WTR178","WTR211","WTR178","WTR192","WTR080","WTR165","WTR174","WTR146","WTR024","WTR061","WTR036","WTR137","WTR102","WTR137","WTR100","WTR078","WTR002"
        },
        -- pack #6 in box #33
        [6] = {
            "WTR177","WTR196","WTR195","WTR214","WTR157","WTR170","WTR054","WTR179","WTR067","WTR036","WTR058","WTR035","WTR145","WTR107","WTR139","WTR038","WTR076"
        },
        -- pack #7 in box #33
        [7] = {
            "WTR181","WTR209","WTR219","WTR206","WTR151","WTR169","WTR089","WTR189","WTR024","WTR060","WTR037","WTR148","WTR105","WTR143","WTR104","WTR224"
        },
        -- pack #8 in box #33
        [8] = {
            "WTR180","WTR218","WTR212","WTR178","WTR157","WTR094","WTR083","WTR109","WTR064","WTR028","WTR061","WTR104","WTR141","WTR112","WTR148","WTR076","WTR077"
        },
        -- pack #9 in box #33
        [9] = {
            "WTR182","WTR187","WTR194","WTR195","WTR151","WTR053","WTR046","WTR178","WTR064","WTR037","WTR068","WTR103","WTR138","WTR110","WTR140","WTR076","WTR003"
        },
        -- pack #10 in box #33
        [10] = {
            "WTR207","WTR198","WTR192","WTR194","WTR153","WTR086","WTR090","WTR178","WTR069","WTR035","WTR071","WTR098","WTR144","WTR096","WTR135","WTR075","WTR039"
        },
        -- pack #11 in box #33
        [11] = {
            "WTR223","WTR192","WTR193","WTR189","WTR154","WTR130","WTR094","WTR028","WTR074","WTR030","WTR059","WTR031","WTR141","WTR097","WTR143","WTR039","WTR114"
        },
        -- pack #12 in box #33
        [12] = {
            "WTR178","WTR213","WTR179","WTR178","WTR156","WTR164","WTR089","WTR023","WTR021","WTR058","WTR032","WTR071","WTR112","WTR141","WTR105","WTR078","WTR003"
        },
        -- pack #13 in box #33
        [13] = {
            "WTR179","WTR192","WTR179","WTR187","WTR005","WTR127","WTR091","WTR161","WTR059","WTR035","WTR062","WTR030","WTR143","WTR099","WTR133","WTR002","WTR038"
        },
        -- pack #14 in box #33
        [14] = {
            "WTR190","WTR218","WTR222","WTR195","WTR005","WTR016","WTR008","WTR036","WTR021","WTR074","WTR029","WTR135","WTR098","WTR142","WTR107","WTR224"
        },
        -- pack #15 in box #33
        [15] = {
            "WTR215","WTR216","WTR211","WTR208","WTR005","WTR175","WTR173","WTR063","WTR024","WTR063","WTR030","WTR071","WTR107","WTR135","WTR097","WTR113","WTR114"
        },
        -- pack #16 in box #33
        [16] = {
            "WTR182","WTR195","WTR214","WTR209","WTR005","WTR168","WTR013","WTR135","WTR037","WTR072","WTR025","WTR139","WTR109","WTR142","WTR109","WTR040","WTR078"
        },
        -- pack #17 in box #33
        [17] = {
            "WTR199","WTR183","WTR182","WTR187","WTR156","WTR172","WTR052","WTR102","WTR069","WTR021","WTR069","WTR109","WTR133","WTR104","WTR135","WTR038","WTR225"
        },
        -- pack #18 in box #33
        [18] = {
            "WTR181","WTR214","WTR211","WTR191","WTR005","WTR087","WTR165","WTR186","WTR033","WTR057","WTR023","WTR138","WTR111","WTR146","WTR109","WTR075","WTR114"
        },
        -- pack #19 in box #33
        [19] = {
            "WTR183","WTR201","WTR196","WTR182","WTR080","WTR052","WTR168","WTR174","WTR072","WTR034","WTR071","WTR032","WTR145","WTR099","WTR133","WTR003","WTR113"
        },
        -- pack #20 in box #33
        [20] = {
            "WTR200","WTR197","WTR182","WTR215","WTR154","WTR052","WTR130","WTR139","WTR032","WTR061","WTR034","WTR148","WTR102","WTR142","WTR111","WTR040","WTR078"
        },
        -- pack #21 in box #33
        [21] = {
            "WTR219","WTR190","WTR219","WTR186","WTR152","WTR048","WTR092","WTR183","WTR035","WTR061","WTR035","WTR066","WTR102","WTR136","WTR110","WTR225","WTR001"
        },
        -- pack #22 in box #33
        [22] = {
            "WTR211","WTR211","WTR186","WTR177","WTR158","WTR166","WTR008","WTR136","WTR073","WTR032","WTR060","WTR020","WTR137","WTR099","WTR135","WTR224"
        },
        -- pack #23 in box #33
        [23] = {
            "WTR202","WTR200","WTR211","WTR208","WTR153","WTR127","WTR129","WTR158","WTR071","WTR027","WTR069","WTR035","WTR143","WTR101","WTR148","WTR001","WTR002"
        },
        -- pack #24 in box #33
        [24] = {
            "WTR215","WTR211","WTR186","WTR219","WTR042","WTR012","WTR131","WTR133","WTR058","WTR026","WTR065","WTR096","WTR134","WTR098","WTR148","WTR225","WTR040"
        },
    },
    -- box #34
    [34] = {
        -- pack #1 in box #34
        [1] = {
            "WTR178","WTR201","WTR179","WTR198","WTR155","WTR091","WTR017","WTR096","WTR034","WTR065","WTR032","WTR057","WTR097","WTR146","WTR096","WTR001","WTR038"
        },
        -- pack #2 in box #34
        [2] = {
            "WTR210","WTR201","WTR204","WTR203","WTR156","WTR129","WTR086","WTR100","WTR059","WTR025","WTR066","WTR034","WTR149","WTR103","WTR149","WTR003","WTR038"
        },
        -- pack #3 in box #34
        [3] = {
            "WTR182","WTR188","WTR200","WTR199","WTR153","WTR013","WTR165","WTR170","WTR027","WTR073","WTR030","WTR136","WTR105","WTR139","WTR106","WTR114","WTR076"
        },
        -- pack #4 in box #34
        [4] = {
            "WTR180","WTR184","WTR179","WTR212","WTR005","WTR056","WTR123","WTR188","WTR058","WTR023","WTR071","WTR032","WTR144","WTR112","WTR148","WTR002","WTR003"
        },
        -- pack #5 in box #34
        [5] = {
            "WTR199","WTR221","WTR211","WTR189","WTR158","WTR052","WTR046","WTR071","WTR072","WTR035","WTR059","WTR095","WTR141","WTR097","WTR134","WTR224"
        },
        -- pack #6 in box #34
        [6] = {
            "WTR177","WTR181","WTR183","WTR218","WTR155","WTR054","WTR087","WTR220","WTR022","WTR072","WTR021","WTR149","WTR104","WTR138","WTR108","WTR075","WTR039"
        },
        -- pack #7 in box #34
        [7] = {
            "WTR189","WTR206","WTR205","WTR206","WTR152","WTR086","WTR051","WTR207","WTR020","WTR063","WTR021","WTR058","WTR097","WTR147","WTR107","WTR224"
        },
        -- pack #8 in box #34
        [8] = {
            "WTR222","WTR198","WTR181","WTR205","WTR157","WTR016","WTR016","WTR112","WTR035","WTR068","WTR035","WTR147","WTR111","WTR132","WTR097","WTR003","WTR113"
        },
        -- pack #9 in box #34
        [9] = {
            "WTR183","WTR222","WTR197","WTR222","WTR152","WTR126","WTR172","WTR073","WTR029","WTR070","WTR024","WTR074","WTR110","WTR147","WTR104","WTR113","WTR038"
        },
        -- pack #10 in box #34
        [10] = {
            "WTR220","WTR190","WTR198","WTR178","WTR042","WTR090","WTR163","WTR154","WTR074","WTR035","WTR058","WTR020","WTR149","WTR100","WTR134","WTR039","WTR225"
        },
        -- pack #11 in box #34
        [11] = {
            "WTR181","WTR207","WTR189","WTR187","WTR080","WTR086","WTR081","WTR210","WTR071","WTR022","WTR066","WTR108","WTR133","WTR108","WTR145","WTR078","WTR225"
        },
        -- pack #12 in box #34
        [12] = {
            "WTR177","WTR214","WTR198","WTR204","WTR154","WTR011","WTR016","WTR091","WTR021","WTR070","WTR028","WTR070","WTR112","WTR141","WTR104","WTR076","WTR039"
        },
        -- pack #13 in box #34
        [13] = {
            "WTR212","WTR211","WTR176","WTR193","WTR156","WTR169","WTR126","WTR147","WTR057","WTR022","WTR060","WTR032","WTR145","WTR108","WTR143","WTR075","WTR003"
        },
        -- pack #14 in box #34
        [14] = {
            "WTR177","WTR222","WTR198","WTR204","WTR156","WTR087","WTR055","WTR015","WTR028","WTR058","WTR033","WTR136","WTR099","WTR133","WTR108","WTR003","WTR040"
        },
        -- pack #15 in box #34
        [15] = {
            "WTR180","WTR192","WTR190","WTR178","WTR117","WTR093","WTR129","WTR045","WTR063","WTR027","WTR063","WTR023","WTR140","WTR106","WTR134","WTR115","WTR076"
        },
        -- pack #16 in box #34
        [16] = {
            "WTR189","WTR220","WTR200","WTR198","WTR005","WTR054","WTR088","WTR006","WTR037","WTR072","WTR023","WTR066","WTR097","WTR149","WTR107","WTR077","WTR038"
        },
        -- pack #17 in box #34
        [17] = {
            "WTR193","WTR193","WTR188","WTR185","WTR005","WTR130","WTR170","WTR196","WTR067","WTR023","WTR072","WTR111","WTR143","WTR109","WTR148","WTR039","WTR114"
        },
        -- pack #18 in box #34
        [18] = {
            "WTR210","WTR189","WTR205","WTR210","WTR155","WTR011","WTR123","WTR208","WTR059","WTR021","WTR065","WTR110","WTR141","WTR099","WTR141","WTR115","WTR077"
        },
        -- pack #19 in box #34
        [19] = {
            "WTR200","WTR179","WTR195","WTR190","WTR158","WTR128","WTR017","WTR171","WTR071","WTR032","WTR067","WTR107","WTR134","WTR095","WTR138","WTR113","WTR039"
        },
        -- pack #20 in box #34
        [20] = {
            "WTR191","WTR208","WTR188","WTR214","WTR042","WTR056","WTR128","WTR104","WTR061","WTR028","WTR060","WTR111","WTR137","WTR099","WTR140","WTR114","WTR039"
        },
        -- pack #21 in box #34
        [21] = {
            "WTR186","WTR179","WTR186","WTR195","WTR152","WTR131","WTR130","WTR211","WTR025","WTR064","WTR021","WTR138","WTR106","WTR141","WTR112","WTR002","WTR114"
        },
        -- pack #22 in box #34
        [22] = {
            "WTR204","WTR220","WTR205","WTR199","WTR157","WTR173","WTR017","WTR150","WTR063","WTR028","WTR057","WTR033","WTR145","WTR108","WTR146","WTR038","WTR077"
        },
        -- pack #23 in box #34
        [23] = {
            "WTR190","WTR188","WTR184","WTR214","WTR005","WTR053","WTR045","WTR061","WTR028","WTR072","WTR030","WTR069","WTR108","WTR141","WTR097","WTR039","WTR038"
        },
        -- pack #24 in box #34
        [24] = {
            "WTR207","WTR216","WTR205","WTR205","WTR117","WTR174","WTR161","WTR219","WTR027","WTR072","WTR029","WTR140","WTR105","WTR140","WTR101","WTR003","WTR040"
        },
    },
    -- box #35
    [35] = {
        -- pack #1 in box #35
        [1] = {
            "WTR196","WTR179","WTR215","WTR199","WTR152","WTR091","WTR049","WTR144","WTR024","WTR058","WTR024","WTR138","WTR110","WTR138","WTR103","WTR115","WTR078"
        },
        -- pack #2 in box #35
        [2] = {
            "WTR178","WTR214","WTR184","WTR223","WTR154","WTR175","WTR164","WTR073","WTR021","WTR062","WTR036","WTR149","WTR099","WTR149","WTR100","WTR078","WTR115"
        },
        -- pack #3 in box #35
        [3] = {
            "WTR192","WTR223","WTR219","WTR187","WTR157","WTR128","WTR172","WTR124","WTR029","WTR071","WTR031","WTR071","WTR107","WTR148","WTR101","WTR039","WTR076"
        },
        -- pack #4 in box #35
        [4] = {
            "WTR221","WTR199","WTR189","WTR220","WTR152","WTR174","WTR045","WTR146","WTR065","WTR023","WTR073","WTR035","WTR135","WTR109","WTR143","WTR224"
        },
        -- pack #5 in box #35
        [5] = {
            "WTR219","WTR212","WTR178","WTR176","WTR153","WTR011","WTR086","WTR105","WTR067","WTR020","WTR059","WTR036","WTR135","WTR096","WTR135","WTR114","WTR075"
        },
        -- pack #6 in box #35
        [6] = {
            "WTR188","WTR203","WTR204","WTR192","WTR156","WTR048","WTR081","WTR139","WTR024","WTR064","WTR030","WTR148","WTR105","WTR142","WTR096","WTR075","WTR225"
        },
        -- pack #7 in box #35
        [7] = {
            "WTR179","WTR214","WTR198","WTR206","WTR151","WTR124","WTR046","WTR024","WTR069","WTR036","WTR063","WTR108","WTR145","WTR111","WTR140","WTR003","WTR078"
        },
        -- pack #8 in box #35
        [8] = {
            "WTR208","WTR206","WTR192","WTR196","WTR152","WTR055","WTR164","WTR208","WTR021","WTR060","WTR034","WTR133","WTR099","WTR136","WTR106","WTR075","WTR002"
        },
        -- pack #9 in box #35
        [9] = {
            "WTR215","WTR212","WTR209","WTR205","WTR080","WTR093","WTR048","WTR035","WTR037","WTR064","WTR032","WTR066","WTR101","WTR132","WTR111","WTR039","WTR114"
        },
        -- pack #10 in box #35
        [10] = {
            "WTR177","WTR177","WTR204","WTR191","WTR080","WTR124","WTR056","WTR152","WTR021","WTR070","WTR035","WTR136","WTR097","WTR144","WTR111","WTR075","WTR078"
        },
        -- pack #11 in box #35
        [11] = {
            "WTR206","WTR200","WTR185","WTR207","WTR155","WTR052","WTR124","WTR149","WTR063","WTR025","WTR067","WTR029","WTR133","WTR110","WTR137","WTR224"
        },
        -- pack #12 in box #35
        [12] = {
            "WTR200","WTR194","WTR195","WTR181","WTR155","WTR018","WTR052","WTR074","WTR074","WTR026","WTR069","WTR102","WTR149","WTR110","WTR139","WTR040","WTR075"
        },
        -- pack #13 in box #35
        [13] = {
            "WTR195","WTR208","WTR199","WTR211","WTR117","WTR131","WTR013","WTR090","WTR023","WTR070","WTR034","WTR071","WTR104","WTR142","WTR100","WTR115","WTR113"
        },
        -- pack #14 in box #35
        [14] = {
            "WTR193","WTR190","WTR196","WTR199","WTR152","WTR056","WTR167","WTR207","WTR063","WTR027","WTR060","WTR028","WTR148","WTR097","WTR138","WTR003","WTR077"
        },
        -- pack #15 in box #35
        [15] = {
            "WTR191","WTR212","WTR222","WTR221","WTR117","WTR170","WTR056","WTR213","WTR070","WTR033","WTR067","WTR024","WTR132","WTR100","WTR145","WTR077","WTR002"
        },
        -- pack #16 in box #35
        [16] = {
            "WTR185","WTR208","WTR215","WTR177","WTR152","WTR129","WTR172","WTR213","WTR072","WTR031","WTR058","WTR104","WTR133","WTR102","WTR146","WTR078","WTR114"
        },
        -- pack #17 in box #35
        [17] = {
            "WTR210","WTR188","WTR206","WTR177","WTR157","WTR014","WTR009","WTR026","WTR067","WTR020","WTR068","WTR031","WTR140","WTR096","WTR135","WTR002","WTR040"
        },
        -- pack #18 in box #35
        [18] = {
            "WTR214","WTR198","WTR205","WTR221","WTR117","WTR048","WTR166","WTR193","WTR064","WTR032","WTR065","WTR100","WTR141","WTR104","WTR144","WTR225","WTR114"
        },
        -- pack #19 in box #35
        [19] = {
            "WTR205","WTR195","WTR204","WTR220","WTR152","WTR014","WTR162","WTR137","WTR025","WTR058","WTR023","WTR061","WTR103","WTR139","WTR102","WTR002","WTR001"
        },
        -- pack #20 in box #35
        [20] = {
            "WTR210","WTR223","WTR189","WTR210","WTR155","WTR127","WTR170","WTR197","WTR037","WTR073","WTR033","WTR063","WTR104","WTR144","WTR109","WTR224"
        },
        -- pack #21 in box #35
        [21] = {
            "WTR187","WTR211","WTR191","WTR194","WTR080","WTR090","WTR088","WTR219","WTR057","WTR025","WTR061","WTR105","WTR138","WTR103","WTR136","WTR113","WTR003"
        },
        -- pack #22 in box #35
        [22] = {
            "WTR184","WTR210","WTR185","WTR221","WTR156","WTR125","WTR161","WTR108","WTR032","WTR059","WTR028","WTR073","WTR105","WTR144","WTR102","WTR076","WTR001"
        },
        -- pack #23 in box #35
        [23] = {
            "WTR200","WTR208","WTR197","WTR199","WTR156","WTR130","WTR126","WTR023","WTR028","WTR069","WTR032","WTR142","WTR107","WTR141","WTR096","WTR002","WTR038"
        },
        -- pack #24 in box #35
        [24] = {
            "WTR192","WTR222","WTR185","WTR209","WTR042","WTR019","WTR094","WTR011","WTR061","WTR031","WTR070","WTR097","WTR143","WTR097","WTR144","WTR040","WTR002"
        },
    },
    -- box #36
    [36] = {
        -- pack #1 in box #36
        [1] = {
            "WTR221","WTR185","WTR182","WTR187","WTR155","WTR048","WTR043","WTR157","WTR073","WTR035","WTR057","WTR036","WTR133","WTR095","WTR145","WTR038","WTR039"
        },
        -- pack #2 in box #36
        [2] = {
            "WTR199","WTR188","WTR183","WTR196","WTR080","WTR092","WTR087","WTR171","WTR073","WTR025","WTR062","WTR098","WTR147","WTR105","WTR142","WTR114","WTR075"
        },
        -- pack #3 in box #36
        [3] = {
            "WTR214","WTR185","WTR184","WTR192","WTR157","WTR091","WTR045","WTR009","WTR061","WTR020","WTR067","WTR027","WTR133","WTR110","WTR134","WTR077","WTR001"
        },
        -- pack #4 in box #36
        [4] = {
            "WTR204","WTR198","WTR204","WTR199","WTR156","WTR092","WTR086","WTR035","WTR021","WTR066","WTR023","WTR149","WTR106","WTR149","WTR103","WTR077","WTR003"
        },
        -- pack #5 in box #36
        [5] = {
            "WTR213","WTR204","WTR198","WTR194","WTR158","WTR051","WTR166","WTR218","WTR032","WTR066","WTR030","WTR146","WTR111","WTR141","WTR100","WTR113","WTR002"
        },
        -- pack #6 in box #36
        [6] = {
            "WTR187","WTR219","WTR200","WTR197","WTR152","WTR094","WTR092","WTR102","WTR067","WTR029","WTR070","WTR028","WTR140","WTR104","WTR146","WTR078","WTR002"
        },
        -- pack #7 in box #36
        [7] = {
            "WTR212","WTR214","WTR213","WTR183","WTR005","WTR171","WTR129","WTR071","WTR025","WTR074","WTR028","WTR143","WTR098","WTR136","WTR111","WTR002","WTR039"
        },
        -- pack #8 in box #36
        [8] = {
            "WTR183","WTR190","WTR190","WTR217","WTR157","WTR128","WTR162","WTR121","WTR035","WTR060","WTR035","WTR132","WTR105","WTR132","WTR111","WTR076","WTR225"
        },
        -- pack #9 in box #36
        [9] = {
            "WTR202","WTR223","WTR192","WTR180","WTR153","WTR125","WTR043","WTR209","WTR037","WTR072","WTR032","WTR068","WTR106","WTR143","WTR110","WTR077","WTR113"
        },
        -- pack #10 in box #36
        [10] = {
            "WTR212","WTR221","WTR206","WTR177","WTR005","WTR093","WTR048","WTR120","WTR031","WTR063","WTR031","WTR057","WTR105","WTR139","WTR107","WTR075","WTR225"
        },
        -- pack #11 in box #36
        [11] = {
            "WTR209","WTR201","WTR202","WTR180","WTR151","WTR052","WTR093","WTR069","WTR061","WTR032","WTR059","WTR030","WTR133","WTR108","WTR148","WTR114","WTR077"
        },
        -- pack #12 in box #36
        [12] = {
            "WTR195","WTR212","WTR212","WTR213","WTR157","WTR174","WTR007","WTR185","WTR022","WTR059","WTR021","WTR135","WTR100","WTR138","WTR101","WTR040","WTR038"
        },
        -- pack #13 in box #36
        [13] = {
            "WTR219","WTR187","WTR178","WTR196","WTR158","WTR019","WTR010","WTR211","WTR065","WTR023","WTR071","WTR031","WTR142","WTR096","WTR133","WTR114","WTR002"
        },
        -- pack #14 in box #36
        [14] = {
            "WTR203","WTR191","WTR211","WTR179","WTR157","WTR124","WTR170","WTR051","WTR065","WTR032","WTR061","WTR104","WTR137","WTR100","WTR138","WTR001","WTR002"
        },
        -- pack #15 in box #36
        [15] = {
            "WTR188","WTR215","WTR185","WTR223","WTR157","WTR094","WTR122","WTR073","WTR064","WTR036","WTR074","WTR101","WTR143","WTR108","WTR144","WTR224"
        },
        -- pack #16 in box #36
        [16] = {
            "WTR181","WTR220","WTR220","WTR213","WTR158","WTR165","WTR016","WTR147","WTR065","WTR021","WTR067","WTR110","WTR141","WTR111","WTR134","WTR115","WTR002"
        },
        -- pack #17 in box #36
        [17] = {
            "WTR180","WTR180","WTR215","WTR177","WTR153","WTR173","WTR088","WTR100","WTR062","WTR027","WTR060","WTR028","WTR141","WTR106","WTR139","WTR114","WTR113"
        },
        -- pack #18 in box #36
        [18] = {
            "WTR179","WTR199","WTR221","WTR219","WTR005","WTR013","WTR010","WTR134","WTR031","WTR067","WTR034","WTR073","WTR107","WTR138","WTR105","WTR075","WTR113"
        },
        -- pack #19 in box #36
        [19] = {
            "WTR208","WTR207","WTR186","WTR216","WTR005","WTR086","WTR049","WTR097","WTR034","WTR065","WTR034","WTR072","WTR096","WTR139","WTR101","WTR076","WTR040"
        },
        -- pack #20 in box #36
        [20] = {
            "WTR183","WTR176","WTR212","WTR220","WTR153","WTR050","WTR131","WTR112","WTR035","WTR059","WTR036","WTR070","WTR109","WTR147","WTR103","WTR003","WTR002"
        },
        -- pack #21 in box #36
        [21] = {
            "WTR191","WTR219","WTR219","WTR215","WTR117","WTR126","WTR055","WTR139","WTR021","WTR064","WTR029","WTR060","WTR108","WTR133","WTR111","WTR076","WTR075"
        },
        -- pack #22 in box #36
        [22] = {
            "WTR201","WTR184","WTR215","WTR183","WTR042","WTR015","WTR170","WTR072","WTR062","WTR026","WTR064","WTR098","WTR144","WTR097","WTR140","WTR113","WTR225"
        },
        -- pack #23 in box #36
        [23] = {
            "WTR186","WTR208","WTR183","WTR196","WTR156","WTR012","WTR053","WTR140","WTR023","WTR070","WTR033","WTR132","WTR096","WTR149","WTR098","WTR002","WTR001"
        },
        -- pack #24 in box #36
        [24] = {
            "WTR217","WTR217","WTR215","WTR206","WTR042","WTR091","WTR173","WTR176","WTR071","WTR032","WTR069","WTR112","WTR146","WTR105","WTR137","WTR040","WTR076"
        },
    },
    -- box #37
    [37] = {
        -- pack #1 in box #37
        [1] = {
            "WTR197","WTR189","WTR187","WTR188","WTR157","WTR165","WTR169","WTR099","WTR058","WTR021","WTR073","WTR037","WTR137","WTR105","WTR132","WTR077","WTR002"
        },
        -- pack #2 in box #37
        [2] = {
            "WTR212","WTR176","WTR178","WTR210","WTR156","WTR051","WTR083","WTR070","WTR023","WTR058","WTR022","WTR140","WTR110","WTR139","WTR098","WTR002","WTR114"
        },
        -- pack #3 in box #37
        [3] = {
            "WTR203","WTR176","WTR194","WTR180","WTR155","WTR014","WTR055","WTR101","WTR062","WTR020","WTR058","WTR030","WTR146","WTR108","WTR140","WTR003","WTR077"
        },
        -- pack #4 in box #37
        [4] = {
            "WTR197","WTR223","WTR198","WTR193","WTR151","WTR016","WTR082","WTR195","WTR063","WTR024","WTR057","WTR100","WTR142","WTR102","WTR136","WTR076","WTR001"
        },
        -- pack #5 in box #37
        [5] = {
            "WTR204","WTR211","WTR223","WTR222","WTR154","WTR172","WTR168","WTR030","WTR067","WTR032","WTR061","WTR100","WTR136","WTR099","WTR138","WTR038","WTR040"
        },
        -- pack #6 in box #37
        [6] = {
            "WTR190","WTR218","WTR210","WTR178","WTR153","WTR165","WTR093","WTR203","WTR029","WTR065","WTR021","WTR059","WTR101","WTR137","WTR106","WTR038","WTR077"
        },
        -- pack #7 in box #37
        [7] = {
            "WTR200","WTR206","WTR207","WTR213","WTR005","WTR092","WTR124","WTR062","WTR029","WTR069","WTR037","WTR074","WTR096","WTR132","WTR103","WTR075","WTR039"
        },
        -- pack #8 in box #37
        [8] = {
            "WTR203","WTR216","WTR211","WTR198","WTR152","WTR164","WTR127","WTR034","WTR058","WTR024","WTR070","WTR099","WTR134","WTR111","WTR141","WTR003","WTR001"
        },
        -- pack #9 in box #37
        [9] = {
            "WTR185","WTR193","WTR179","WTR191","WTR152","WTR174","WTR175","WTR138","WTR070","WTR036","WTR071","WTR025","WTR144","WTR111","WTR146","WTR076","WTR040"
        },
        -- pack #10 in box #37
        [10] = {
            "WTR200","WTR215","WTR176","WTR208","WTR117","WTR127","WTR054","WTR179","WTR061","WTR029","WTR071","WTR036","WTR140","WTR098","WTR143","WTR115","WTR040"
        },
        -- pack #11 in box #37
        [11] = {
            "WTR184","WTR204","WTR206","WTR215","WTR117","WTR049","WTR174","WTR154","WTR072","WTR029","WTR065","WTR026","WTR149","WTR107","WTR140","WTR002","WTR038"
        },
        -- pack #12 in box #37
        [12] = {
            "WTR190","WTR222","WTR183","WTR186","WTR151","WTR011","WTR056","WTR158","WTR031","WTR065","WTR022","WTR059","WTR103","WTR148","WTR109","WTR001","WTR114"
        },
        -- pack #13 in box #37
        [13] = {
            "WTR182","WTR205","WTR223","WTR199","WTR117","WTR017","WTR012","WTR049","WTR059","WTR022","WTR069","WTR099","WTR133","WTR110","WTR149","WTR113","WTR114"
        },
        -- pack #14 in box #37
        [14] = {
            "WTR211","WTR196","WTR180","WTR213","WTR080","WTR049","WTR088","WTR124","WTR026","WTR071","WTR023","WTR070","WTR109","WTR135","WTR100","WTR003","WTR225"
        },
        -- pack #15 in box #37
        [15] = {
            "WTR204","WTR203","WTR186","WTR176","WTR158","WTR050","WTR052","WTR020","WTR033","WTR068","WTR021","WTR060","WTR103","WTR132","WTR096","WTR115","WTR078"
        },
        -- pack #16 in box #37
        [16] = {
            "WTR196","WTR212","WTR222","WTR183","WTR042","WTR048","WTR087","WTR013","WTR059","WTR021","WTR058","WTR099","WTR148","WTR108","WTR144","WTR038","WTR075"
        },
        -- pack #17 in box #37
        [17] = {
            "WTR200","WTR211","WTR207","WTR176","WTR157","WTR089","WTR081","WTR126","WTR020","WTR065","WTR024","WTR142","WTR098","WTR139","WTR103","WTR225","WTR075"
        },
        -- pack #18 in box #37
        [18] = {
            "WTR222","WTR183","WTR205","WTR194","WTR042","WTR049","WTR161","WTR026","WTR029","WTR071","WTR033","WTR141","WTR104","WTR132","WTR105","WTR113","WTR002"
        },
        -- pack #19 in box #37
        [19] = {
            "WTR196","WTR187","WTR196","WTR213","WTR151","WTR165","WTR006","WTR190","WTR026","WTR068","WTR036","WTR064","WTR095","WTR138","WTR112","WTR077","WTR115"
        },
        -- pack #20 in box #37
        [20] = {
            "WTR177","WTR185","WTR200","WTR177","WTR080","WTR128","WTR092","WTR211","WTR060","WTR023","WTR072","WTR102","WTR134","WTR098","WTR142","WTR040","WTR002"
        },
        -- pack #21 in box #37
        [21] = {
            "WTR223","WTR210","WTR203","WTR216","WTR080","WTR124","WTR164","WTR012","WTR037","WTR062","WTR034","WTR139","WTR103","WTR132","WTR102","WTR078","WTR077"
        },
        -- pack #22 in box #37
        [22] = {
            "WTR208","WTR208","WTR219","WTR176","WTR042","WTR017","WTR081","WTR092","WTR068","WTR034","WTR070","WTR034","WTR146","WTR095","WTR138","WTR114","WTR001"
        },
        -- pack #23 in box #37
        [23] = {
            "WTR207","WTR218","WTR176","WTR194","WTR005","WTR012","WTR168","WTR106","WTR029","WTR065","WTR036","WTR137","WTR110","WTR132","WTR101","WTR078","WTR077"
        },
        -- pack #24 in box #37
        [24] = {
            "WTR218","WTR210","WTR223","WTR210","WTR158","WTR123","WTR011","WTR141","WTR035","WTR063","WTR034","WTR137","WTR099","WTR148","WTR108","WTR076","WTR002"
        },
    },
    -- box #38
    [38] = {
        -- pack #1 in box #38
        [1] = {
            "WTR223","WTR223","WTR214","WTR222","WTR155","WTR055","WTR007","WTR066","WTR035","WTR068","WTR031","WTR139","WTR099","WTR144","WTR097","WTR078","WTR040"
        },
        -- pack #2 in box #38
        [2] = {
            "WTR179","WTR187","WTR186","WTR185","WTR157","WTR055","WTR012","WTR063","WTR032","WTR063","WTR027","WTR074","WTR098","WTR143","WTR102","WTR115","WTR075"
        },
        -- pack #3 in box #38
        [3] = {
            "WTR178","WTR185","WTR208","WTR198","WTR151","WTR050","WTR043","WTR215","WTR035","WTR063","WTR037","WTR133","WTR099","WTR137","WTR107","WTR040","WTR113"
        },
        -- pack #4 in box #38
        [4] = {
            "WTR205","WTR176","WTR188","WTR214","WTR158","WTR172","WTR163","WTR143","WTR024","WTR074","WTR026","WTR136","WTR100","WTR141","WTR112","WTR224"
        },
        -- pack #5 in box #38
        [5] = {
            "WTR186","WTR208","WTR208","WTR183","WTR080","WTR127","WTR122","WTR212","WTR020","WTR063","WTR032","WTR061","WTR097","WTR139","WTR098","WTR003","WTR038"
        },
        -- pack #6 in box #38
        [6] = {
            "WTR184","WTR207","WTR219","WTR181","WTR152","WTR130","WTR168","WTR037","WTR028","WTR062","WTR036","WTR141","WTR095","WTR145","WTR108","WTR003","WTR040"
        },
        -- pack #7 in box #38
        [7] = {
            "WTR213","WTR223","WTR215","WTR180","WTR153","WTR019","WTR092","WTR036","WTR026","WTR063","WTR027","WTR066","WTR100","WTR141","WTR107","WTR003","WTR075"
        },
        -- pack #8 in box #38
        [8] = {
            "WTR218","WTR200","WTR221","WTR203","WTR158","WTR015","WTR009","WTR163","WTR062","WTR037","WTR066","WTR105","WTR133","WTR106","WTR149","WTR038","WTR078"
        },
        -- pack #9 in box #38
        [9] = {
            "WTR208","WTR203","WTR200","WTR201","WTR153","WTR164","WTR008","WTR052","WTR065","WTR032","WTR069","WTR023","WTR142","WTR112","WTR143","WTR003","WTR002"
        },
        -- pack #10 in box #38
        [10] = {
            "WTR198","WTR208","WTR214","WTR183","WTR153","WTR017","WTR130","WTR098","WTR022","WTR061","WTR021","WTR149","WTR100","WTR144","WTR103","WTR224"
        },
        -- pack #11 in box #38
        [11] = {
            "WTR218","WTR194","WTR215","WTR204","WTR151","WTR087","WTR086","WTR218","WTR027","WTR057","WTR033","WTR061","WTR112","WTR133","WTR110","WTR114","WTR225"
        },
        -- pack #12 in box #38
        [12] = {
            "WTR202","WTR187","WTR199","WTR182","WTR157","WTR088","WTR013","WTR179","WTR061","WTR022","WTR058","WTR099","WTR147","WTR097","WTR140","WTR002","WTR039"
        },
        -- pack #13 in box #38
        [13] = {
            "WTR214","WTR211","WTR212","WTR212","WTR156","WTR093","WTR013","WTR052","WTR062","WTR028","WTR067","WTR095","WTR143","WTR103","WTR138","WTR113","WTR001"
        },
        -- pack #14 in box #38
        [14] = {
            "WTR180","WTR211","WTR194","WTR189","WTR080","WTR056","WTR124","WTR219","WTR059","WTR032","WTR071","WTR026","WTR140","WTR103","WTR144","WTR039","WTR001"
        },
        -- pack #15 in box #38
        [15] = {
            "WTR195","WTR190","WTR202","WTR181","WTR157","WTR050","WTR172","WTR053","WTR037","WTR059","WTR031","WTR072","WTR109","WTR136","WTR110","WTR003","WTR040"
        },
        -- pack #16 in box #38
        [16] = {
            "WTR202","WTR223","WTR221","WTR199","WTR042","WTR125","WTR048","WTR195","WTR065","WTR022","WTR060","WTR033","WTR138","WTR112","WTR140","WTR040","WTR038"
        },
        -- pack #17 in box #38
        [17] = {
            "WTR213","WTR202","WTR206","WTR187","WTR156","WTR170","WTR094","WTR188","WTR028","WTR057","WTR022","WTR142","WTR098","WTR138","WTR100","WTR113","WTR076"
        },
        -- pack #18 in box #38
        [18] = {
            "WTR205","WTR197","WTR184","WTR184","WTR117","WTR055","WTR009","WTR059","WTR069","WTR029","WTR068","WTR095","WTR138","WTR104","WTR134","WTR114","WTR225"
        },
        -- pack #19 in box #38
        [19] = {
            "WTR208","WTR182","WTR200","WTR194","WTR152","WTR131","WTR016","WTR138","WTR064","WTR024","WTR066","WTR020","WTR141","WTR104","WTR141","WTR114","WTR115"
        },
        -- pack #20 in box #38
        [20] = {
            "WTR223","WTR182","WTR215","WTR183","WTR151","WTR173","WTR159","WTR032","WTR062","WTR028","WTR061","WTR025","WTR149","WTR095","WTR135","WTR113","WTR076"
        },
        -- pack #21 in box #38
        [21] = {
            "WTR183","WTR176","WTR189","WTR184","WTR152","WTR088","WTR088","WTR160","WTR033","WTR068","WTR025","WTR059","WTR108","WTR140","WTR106","WTR003","WTR115"
        },
        -- pack #22 in box #38
        [22] = {
            "WTR217","WTR208","WTR184","WTR193","WTR152","WTR019","WTR128","WTR218","WTR069","WTR020","WTR061","WTR101","WTR141","WTR102","WTR134","WTR224"
        },
        -- pack #23 in box #38
        [23] = {
            "WTR193","WTR219","WTR208","WTR202","WTR042","WTR128","WTR131","WTR200","WTR072","WTR027","WTR061","WTR106","WTR147","WTR096","WTR141","WTR077","WTR038"
        },
        -- pack #24 in box #38
        [24] = {
            "WTR218","WTR197","WTR223","WTR215","WTR158","WTR170","WTR126","WTR030","WTR067","WTR026","WTR069","WTR035","WTR142","WTR101","WTR137","WTR078","WTR076"
        },
    },
    -- box #39
    [39] = {
        -- pack #1 in box #39
        [1] = {
            "WTR203","WTR211","WTR177","WTR206","WTR117","WTR175","WTR091","WTR165","WTR064","WTR027","WTR059","WTR026","WTR141","WTR103","WTR139","WTR039","WTR076"
        },
        -- pack #2 in box #39
        [2] = {
            "WTR194","WTR181","WTR187","WTR198","WTR005","WTR019","WTR163","WTR210","WTR059","WTR032","WTR059","WTR024","WTR132","WTR098","WTR143","WTR040","WTR075"
        },
        -- pack #3 in box #39
        [3] = {
            "WTR219","WTR198","WTR207","WTR196","WTR157","WTR016","WTR006","WTR201","WTR027","WTR066","WTR021","WTR137","WTR112","WTR149","WTR106","WTR115","WTR077"
        },
        -- pack #4 in box #39
        [4] = {
            "WTR214","WTR217","WTR212","WTR176","WTR080","WTR130","WTR169","WTR182","WTR027","WTR062","WTR028","WTR143","WTR101","WTR136","WTR105","WTR040","WTR077"
        },
        -- pack #5 in box #39
        [5] = {
            "WTR218","WTR197","WTR214","WTR196","WTR042","WTR092","WTR131","WTR178","WTR071","WTR025","WTR066","WTR035","WTR142","WTR098","WTR137","WTR003","WTR115"
        },
        -- pack #6 in box #39
        [6] = {
            "WTR182","WTR199","WTR220","WTR199","WTR156","WTR166","WTR091","WTR203","WTR032","WTR062","WTR037","WTR066","WTR109","WTR139","WTR108","WTR114","WTR038"
        },
        -- pack #7 in box #39
        [7] = {
            "WTR205","WTR209","WTR211","WTR195","WTR080","WTR172","WTR124","WTR148","WTR071","WTR026","WTR066","WTR095","WTR148","WTR110","WTR146","WTR038","WTR115"
        },
        -- pack #8 in box #39
        [8] = {
            "WTR178","WTR188","WTR208","WTR182","WTR117","WTR129","WTR087","WTR108","WTR069","WTR028","WTR069","WTR101","WTR144","WTR104","WTR137","WTR040","WTR038"
        },
        -- pack #9 in box #39
        [9] = {
            "WTR179","WTR222","WTR177","WTR191","WTR152","WTR171","WTR046","WTR146","WTR066","WTR021","WTR060","WTR096","WTR141","WTR111","WTR137","WTR001","WTR113"
        },
        -- pack #10 in box #39
        [10] = {
            "WTR215","WTR196","WTR200","WTR209","WTR005","WTR165","WTR131","WTR057","WTR037","WTR066","WTR035","WTR057","WTR105","WTR145","WTR106","WTR224"
        },
        -- pack #11 in box #39
        [11] = {
            "WTR184","WTR178","WTR176","WTR201","WTR156","WTR056","WTR171","WTR061","WTR064","WTR022","WTR062","WTR021","WTR147","WTR100","WTR141","WTR224"
        },
        -- pack #12 in box #39
        [12] = {
            "WTR184","WTR220","WTR198","WTR196","WTR117","WTR013","WTR053","WTR189","WTR062","WTR035","WTR071","WTR099","WTR135","WTR104","WTR141","WTR078","WTR077"
        },
        -- pack #13 in box #39
        [13] = {
            "WTR203","WTR220","WTR193","WTR196","WTR151","WTR166","WTR019","WTR157","WTR069","WTR033","WTR061","WTR105","WTR149","WTR108","WTR149","WTR224"
        },
        -- pack #14 in box #39
        [14] = {
            "WTR192","WTR196","WTR215","WTR222","WTR042","WTR018","WTR054","WTR137","WTR030","WTR067","WTR026","WTR144","WTR108","WTR132","WTR102","WTR003","WTR001"
        },
        -- pack #15 in box #39
        [15] = {
            "WTR212","WTR199","WTR221","WTR207","WTR151","WTR087","WTR118","WTR138","WTR036","WTR067","WTR035","WTR142","WTR106","WTR142","WTR103","WTR113","WTR114"
        },
        -- pack #16 in box #39
        [16] = {
            "WTR205","WTR223","WTR186","WTR205","WTR080","WTR055","WTR018","WTR036","WTR069","WTR029","WTR074","WTR111","WTR137","WTR104","WTR142","WTR224"
        },
        -- pack #17 in box #39
        [17] = {
            "WTR183","WTR220","WTR195","WTR176","WTR005","WTR130","WTR118","WTR198","WTR024","WTR065","WTR037","WTR142","WTR112","WTR142","WTR100","WTR038","WTR114"
        },
        -- pack #18 in box #39
        [18] = {
            "WTR186","WTR203","WTR182","WTR223","WTR155","WTR050","WTR048","WTR182","WTR022","WTR063","WTR024","WTR071","WTR101","WTR136","WTR095","WTR224"
        },
        -- pack #19 in box #39
        [19] = {
            "WTR186","WTR213","WTR197","WTR184","WTR153","WTR168","WTR052","WTR095","WTR066","WTR036","WTR057","WTR023","WTR132","WTR110","WTR137","WTR002","WTR040"
        },
        -- pack #20 in box #39
        [20] = {
            "WTR200","WTR207","WTR209","WTR176","WTR155","WTR125","WTR083","WTR037","WTR029","WTR072","WTR023","WTR147","WTR104","WTR142","WTR097","WTR077","WTR114"
        },
        -- pack #21 in box #39
        [21] = {
            "WTR219","WTR201","WTR183","WTR205","WTR005","WTR090","WTR128","WTR083","WTR034","WTR062","WTR032","WTR068","WTR110","WTR134","WTR112","WTR078","WTR115"
        },
        -- pack #22 in box #39
        [22] = {
            "WTR191","WTR199","WTR187","WTR194","WTR157","WTR049","WTR171","WTR221","WTR036","WTR069","WTR027","WTR068","WTR108","WTR145","WTR105","WTR003","WTR075"
        },
        -- pack #23 in box #39
        [23] = {
            "WTR218","WTR197","WTR223","WTR190","WTR157","WTR091","WTR011","WTR019","WTR034","WTR073","WTR034","WTR071","WTR100","WTR148","WTR102","WTR076","WTR114"
        },
        -- pack #24 in box #39
        [24] = {
            "WTR198","WTR195","WTR222","WTR196","WTR042","WTR013","WTR122","WTR205","WTR070","WTR030","WTR066","WTR028","WTR133","WTR103","WTR142","WTR224"
        },
    },
    -- box #40
    [40] = {
        -- pack #1 in box #40
        [1] = {
            "WTR203","WTR206","WTR212","WTR196","WTR042","WTR012","WTR122","WTR102","WTR020","WTR073","WTR021","WTR057","WTR096","WTR142","WTR110","WTR076","WTR225"
        },
        -- pack #2 in box #40
        [2] = {
            "WTR184","WTR192","WTR191","WTR202","WTR042","WTR055","WTR167","WTR036","WTR065","WTR029","WTR068","WTR024","WTR144","WTR107","WTR144","WTR076","WTR075"
        },
        -- pack #3 in box #40
        [3] = {
            "WTR183","WTR221","WTR201","WTR205","WTR157","WTR166","WTR087","WTR057","WTR022","WTR059","WTR028","WTR139","WTR102","WTR148","WTR100","WTR002","WTR114"
        },
        -- pack #4 in box #40
        [4] = {
            "WTR177","WTR202","WTR184","WTR191","WTR155","WTR015","WTR171","WTR185","WTR069","WTR024","WTR072","WTR105","WTR147","WTR108","WTR148","WTR001","WTR113"
        },
        -- pack #5 in box #40
        [5] = {
            "WTR197","WTR194","WTR215","WTR200","WTR117","WTR018","WTR126","WTR046","WTR073","WTR034","WTR060","WTR033","WTR148","WTR108","WTR141","WTR076","WTR113"
        },
        -- pack #6 in box #40
        [6] = {
            "WTR178","WTR191","WTR178","WTR204","WTR155","WTR091","WTR175","WTR204","WTR067","WTR035","WTR070","WTR025","WTR147","WTR112","WTR143","WTR003","WTR001"
        },
        -- pack #7 in box #40
        [7] = {
            "WTR198","WTR210","WTR216","WTR189","WTR042","WTR087","WTR092","WTR221","WTR058","WTR025","WTR058","WTR020","WTR149","WTR106","WTR144","WTR078","WTR115"
        },
        -- pack #8 in box #40
        [8] = {
            "WTR217","WTR185","WTR187","WTR176","WTR154","WTR050","WTR167","WTR190","WTR067","WTR022","WTR067","WTR095","WTR133","WTR107","WTR149","WTR077","WTR002"
        },
        -- pack #9 in box #40
        [9] = {
            "WTR223","WTR185","WTR180","WTR202","WTR152","WTR094","WTR009","WTR149","WTR065","WTR029","WTR070","WTR103","WTR145","WTR109","WTR135","WTR077","WTR040"
        },
        -- pack #10 in box #40
        [10] = {
            "WTR219","WTR213","WTR205","WTR208","WTR080","WTR126","WTR045","WTR167","WTR020","WTR057","WTR030","WTR136","WTR103","WTR148","WTR103","WTR001","WTR114"
        },
        -- pack #11 in box #40
        [11] = {
            "WTR220","WTR203","WTR210","WTR194","WTR156","WTR170","WTR086","WTR042","WTR023","WTR065","WTR026","WTR071","WTR097","WTR137","WTR108","WTR038","WTR001"
        },
        -- pack #12 in box #40
        [12] = {
            "WTR203","WTR180","WTR199","WTR219","WTR155","WTR048","WTR007","WTR037","WTR022","WTR072","WTR022","WTR073","WTR098","WTR138","WTR101","WTR040","WTR077"
        },
        -- pack #13 in box #40
        [13] = {
            "WTR179","WTR220","WTR183","WTR205","WTR155","WTR018","WTR123","WTR104","WTR070","WTR034","WTR073","WTR099","WTR132","WTR108","WTR132","WTR114","WTR078"
        },
        -- pack #14 in box #40
        [14] = {
            "WTR221","WTR202","WTR182","WTR208","WTR158","WTR056","WTR006","WTR111","WTR032","WTR073","WTR034","WTR058","WTR107","WTR149","WTR109","WTR113","WTR075"
        },
        -- pack #15 in box #40
        [15] = {
            "WTR192","WTR178","WTR197","WTR186","WTR156","WTR094","WTR127","WTR203","WTR070","WTR027","WTR068","WTR098","WTR140","WTR108","WTR133","WTR113","WTR114"
        },
        -- pack #16 in box #40
        [16] = {
            "WTR222","WTR186","WTR178","WTR222","WTR080","WTR048","WTR166","WTR135","WTR060","WTR027","WTR064","WTR104","WTR145","WTR108","WTR137","WTR076","WTR002"
        },
        -- pack #17 in box #40
        [17] = {
            "WTR222","WTR209","WTR210","WTR202","WTR152","WTR049","WTR053","WTR103","WTR068","WTR027","WTR072","WTR034","WTR135","WTR097","WTR138","WTR002","WTR225"
        },
        -- pack #18 in box #40
        [18] = {
            "WTR183","WTR185","WTR210","WTR189","WTR005","WTR013","WTR016","WTR067","WTR037","WTR069","WTR020","WTR147","WTR107","WTR139","WTR095","WTR040","WTR038"
        },
        -- pack #19 in box #40
        [19] = {
            "WTR191","WTR222","WTR180","WTR197","WTR156","WTR014","WTR124","WTR147","WTR027","WTR064","WTR028","WTR061","WTR111","WTR149","WTR096","WTR039","WTR225"
        },
        -- pack #20 in box #40
        [20] = {
            "WTR200","WTR179","WTR198","WTR222","WTR154","WTR016","WTR052","WTR093","WTR030","WTR069","WTR036","WTR148","WTR112","WTR139","WTR105","WTR078","WTR002"
        },
        -- pack #21 in box #40
        [21] = {
            "WTR188","WTR213","WTR223","WTR181","WTR117","WTR127","WTR167","WTR198","WTR066","WTR033","WTR073","WTR032","WTR144","WTR100","WTR136","WTR078","WTR076"
        },
        -- pack #22 in box #40
        [22] = {
            "WTR216","WTR211","WTR180","WTR186","WTR151","WTR170","WTR172","WTR110","WTR037","WTR066","WTR023","WTR068","WTR110","WTR137","WTR100","WTR115","WTR114"
        },
        -- pack #23 in box #40
        [23] = {
            "WTR213","WTR180","WTR195","WTR197","WTR153","WTR016","WTR161","WTR208","WTR036","WTR066","WTR026","WTR146","WTR095","WTR134","WTR110","WTR113","WTR077"
        },
        -- pack #24 in box #40
        [24] = {
            "WTR182","WTR219","WTR206","WTR201","WTR156","WTR093","WTR127","WTR209","WTR022","WTR057","WTR025","WTR148","WTR102","WTR132","WTR102","WTR001","WTR038"
        },
    },
    -- box #41
    [41] = {
        -- pack #1 in box #41
        [1] = {
            "WTR223","WTR193","WTR185","WTR207","WTR152","WTR086","WTR168","WTR074","WTR033","WTR062","WTR021","WTR145","WTR098","WTR132","WTR104","WTR115","WTR039"
        },
        -- pack #2 in box #41
        [2] = {
            "WTR210","WTR199","WTR203","WTR178","WTR080","WTR011","WTR087","WTR047","WTR036","WTR074","WTR027","WTR148","WTR107","WTR136","WTR105","WTR115","WTR039"
        },
        -- pack #3 in box #41
        [3] = {
            "WTR194","WTR221","WTR220","WTR190","WTR117","WTR170","WTR043","WTR196","WTR035","WTR058","WTR030","WTR146","WTR108","WTR143","WTR109","WTR115","WTR003"
        },
        -- pack #4 in box #41
        [4] = {
            "WTR200","WTR223","WTR188","WTR218","WTR005","WTR130","WTR169","WTR177","WTR035","WTR061","WTR027","WTR136","WTR105","WTR143","WTR102","WTR040","WTR115"
        },
        -- pack #5 in box #41
        [5] = {
            "WTR184","WTR207","WTR191","WTR196","WTR042","WTR088","WTR174","WTR207","WTR067","WTR027","WTR072","WTR033","WTR149","WTR104","WTR136","WTR003","WTR076"
        },
        -- pack #6 in box #41
        [6] = {
            "WTR207","WTR216","WTR214","WTR221","WTR152","WTR171","WTR126","WTR165","WTR060","WTR032","WTR068","WTR026","WTR136","WTR106","WTR139","WTR001","WTR114"
        },
        -- pack #7 in box #41
        [7] = {
            "WTR191","WTR181","WTR205","WTR177","WTR042","WTR166","WTR013","WTR184","WTR036","WTR066","WTR024","WTR143","WTR101","WTR136","WTR106","WTR225","WTR077"
        },
        -- pack #8 in box #41
        [8] = {
            "WTR192","WTR200","WTR215","WTR210","WTR155","WTR171","WTR124","WTR179","WTR073","WTR029","WTR066","WTR023","WTR140","WTR097","WTR147","WTR115","WTR114"
        },
        -- pack #9 in box #41
        [9] = {
            "WTR188","WTR197","WTR183","WTR180","WTR155","WTR052","WTR052","WTR144","WTR059","WTR020","WTR067","WTR034","WTR136","WTR107","WTR135","WTR077","WTR078"
        },
        -- pack #10 in box #41
        [10] = {
            "WTR208","WTR207","WTR189","WTR223","WTR157","WTR051","WTR086","WTR058","WTR058","WTR025","WTR059","WTR037","WTR143","WTR112","WTR147","WTR114","WTR001"
        },
        -- pack #11 in box #41
        [11] = {
            "WTR217","WTR221","WTR223","WTR182","WTR005","WTR171","WTR094","WTR082","WTR063","WTR036","WTR062","WTR108","WTR136","WTR101","WTR143","WTR039","WTR115"
        },
        -- pack #12 in box #41
        [12] = {
            "WTR185","WTR208","WTR207","WTR178","WTR152","WTR088","WTR173","WTR171","WTR027","WTR064","WTR023","WTR067","WTR110","WTR137","WTR111","WTR038","WTR075"
        },
        -- pack #13 in box #41
        [13] = {
            "WTR215","WTR206","WTR180","WTR188","WTR153","WTR051","WTR164","WTR190","WTR027","WTR065","WTR029","WTR132","WTR106","WTR136","WTR104","WTR114","WTR077"
        },
        -- pack #14 in box #41
        [14] = {
            "WTR180","WTR197","WTR191","WTR177","WTR158","WTR126","WTR093","WTR007","WTR026","WTR062","WTR029","WTR063","WTR103","WTR135","WTR099","WTR076","WTR002"
        },
        -- pack #15 in box #41
        [15] = {
            "WTR194","WTR189","WTR184","WTR222","WTR080","WTR089","WTR053","WTR088","WTR065","WTR021","WTR065","WTR109","WTR144","WTR109","WTR143","WTR075","WTR113"
        },
        -- pack #16 in box #41
        [16] = {
            "WTR203","WTR212","WTR186","WTR203","WTR042","WTR050","WTR052","WTR012","WTR061","WTR021","WTR068","WTR095","WTR148","WTR104","WTR148","WTR077","WTR114"
        },
        -- pack #17 in box #41
        [17] = {
            "WTR177","WTR218","WTR220","WTR181","WTR042","WTR172","WTR051","WTR018","WTR073","WTR035","WTR061","WTR095","WTR144","WTR111","WTR138","WTR113","WTR075"
        },
        -- pack #18 in box #41
        [18] = {
            "WTR184","WTR186","WTR185","WTR216","WTR157","WTR125","WTR047","WTR105","WTR029","WTR074","WTR035","WTR068","WTR111","WTR149","WTR108","WTR076","WTR001"
        },
        -- pack #19 in box #41
        [19] = {
            "WTR219","WTR187","WTR194","WTR216","WTR080","WTR166","WTR170","WTR095","WTR060","WTR022","WTR069","WTR099","WTR141","WTR106","WTR141","WTR003","WTR002"
        },
        -- pack #20 in box #41
        [20] = {
            "WTR194","WTR197","WTR199","WTR220","WTR157","WTR056","WTR046","WTR148","WTR020","WTR061","WTR034","WTR057","WTR112","WTR144","WTR097","WTR077","WTR076"
        },
        -- pack #21 in box #41
        [21] = {
            "WTR185","WTR215","WTR210","WTR181","WTR080","WTR091","WTR173","WTR210","WTR068","WTR023","WTR062","WTR032","WTR133","WTR098","WTR132","WTR077","WTR114"
        },
        -- pack #22 in box #41
        [22] = {
            "WTR204","WTR208","WTR181","WTR196","WTR117","WTR092","WTR165","WTR052","WTR026","WTR074","WTR027","WTR058","WTR105","WTR147","WTR111","WTR115","WTR075"
        },
        -- pack #23 in box #41
        [23] = {
            "WTR179","WTR193","WTR202","WTR193","WTR158","WTR015","WTR161","WTR212","WTR066","WTR032","WTR060","WTR107","WTR133","WTR102","WTR143","WTR076","WTR075"
        },
        -- pack #24 in box #41
        [24] = {
            "WTR178","WTR182","WTR219","WTR196","WTR005","WTR126","WTR129","WTR048","WTR037","WTR066","WTR030","WTR064","WTR095","WTR133","WTR102","WTR039","WTR003"
        },
    },
    -- box #42
    [42] = {
        -- pack #1 in box #42
        [1] = {
            "WTR207","WTR197","WTR201","WTR182","WTR158","WTR017","WTR084","WTR066","WTR073","WTR023","WTR073","WTR105","WTR137","WTR096","WTR136","WTR077","WTR076"
        },
        -- pack #2 in box #42
        [2] = {
            "WTR194","WTR203","WTR196","WTR201","WTR117","WTR165","WTR088","WTR171","WTR073","WTR031","WTR058","WTR022","WTR146","WTR103","WTR149","WTR039","WTR114"
        },
        -- pack #3 in box #42
        [3] = {
            "WTR180","WTR201","WTR194","WTR195","WTR042","WTR087","WTR014","WTR162","WTR033","WTR073","WTR027","WTR145","WTR111","WTR144","WTR109","WTR113","WTR038"
        },
        -- pack #4 in box #42
        [4] = {
            "WTR191","WTR210","WTR186","WTR201","WTR152","WTR128","WTR167","WTR132","WTR063","WTR035","WTR058","WTR112","WTR143","WTR095","WTR143","WTR002","WTR114"
        },
        -- pack #5 in box #42
        [5] = {
            "WTR197","WTR204","WTR182","WTR206","WTR158","WTR175","WTR093","WTR201","WTR072","WTR029","WTR068","WTR099","WTR133","WTR095","WTR136","WTR003","WTR225"
        },
        -- pack #6 in box #42
        [6] = {
            "WTR176","WTR198","WTR202","WTR215","WTR151","WTR175","WTR011","WTR178","WTR020","WTR068","WTR025","WTR074","WTR111","WTR133","WTR097","WTR076","WTR077"
        },
        -- pack #7 in box #42
        [7] = {
            "WTR205","WTR219","WTR222","WTR191","WTR157","WTR166","WTR172","WTR111","WTR025","WTR065","WTR036","WTR074","WTR095","WTR140","WTR105","WTR076","WTR075"
        },
        -- pack #8 in box #42
        [8] = {
            "WTR215","WTR219","WTR214","WTR221","WTR080","WTR013","WTR124","WTR215","WTR073","WTR028","WTR059","WTR032","WTR138","WTR112","WTR143","WTR114","WTR038"
        },
        -- pack #9 in box #42
        [9] = {
            "WTR190","WTR222","WTR203","WTR207","WTR005","WTR056","WTR165","WTR024","WTR022","WTR057","WTR023","WTR133","WTR100","WTR149","WTR106","WTR002","WTR039"
        },
        -- pack #10 in box #42
        [10] = {
            "WTR223","WTR219","WTR213","WTR182","WTR117","WTR128","WTR047","WTR174","WTR061","WTR035","WTR064","WTR028","WTR144","WTR110","WTR133","WTR076","WTR113"
        },
        -- pack #11 in box #42
        [11] = {
            "WTR189","WTR198","WTR182","WTR201","WTR151","WTR052","WTR091","WTR014","WTR036","WTR066","WTR026","WTR070","WTR095","WTR145","WTR097","WTR078","WTR113"
        },
        -- pack #12 in box #42
        [12] = {
            "WTR212","WTR210","WTR183","WTR223","WTR005","WTR056","WTR163","WTR102","WTR059","WTR024","WTR059","WTR103","WTR142","WTR108","WTR146","WTR002","WTR114"
        },
        -- pack #13 in box #42
        [13] = {
            "WTR212","WTR201","WTR216","WTR193","WTR156","WTR127","WTR167","WTR158","WTR071","WTR028","WTR058","WTR020","WTR144","WTR098","WTR141","WTR078","WTR039"
        },
        -- pack #14 in box #42
        [14] = {
            "WTR198","WTR219","WTR181","WTR219","WTR152","WTR174","WTR045","WTR032","WTR062","WTR027","WTR069","WTR032","WTR148","WTR101","WTR149","WTR039","WTR076"
        },
        -- pack #15 in box #42
        [15] = {
            "WTR191","WTR180","WTR185","WTR214","WTR042","WTR055","WTR009","WTR021","WTR070","WTR025","WTR060","WTR105","WTR132","WTR102","WTR132","WTR003","WTR113"
        },
        -- pack #16 in box #42
        [16] = {
            "WTR196","WTR180","WTR218","WTR182","WTR154","WTR018","WTR016","WTR189","WTR031","WTR065","WTR032","WTR134","WTR102","WTR141","WTR103","WTR115","WTR001"
        },
        -- pack #17 in box #42
        [17] = {
            "WTR205","WTR223","WTR209","WTR181","WTR153","WTR013","WTR089","WTR142","WTR032","WTR070","WTR034","WTR074","WTR103","WTR132","WTR098","WTR002","WTR039"
        },
        -- pack #18 in box #42
        [18] = {
            "WTR208","WTR210","WTR184","WTR191","WTR157","WTR088","WTR087","WTR199","WTR030","WTR066","WTR032","WTR069","WTR099","WTR141","WTR102","WTR038","WTR114"
        },
        -- pack #19 in box #42
        [19] = {
            "WTR210","WTR205","WTR209","WTR188","WTR154","WTR051","WTR007","WTR023","WTR034","WTR064","WTR033","WTR140","WTR096","WTR147","WTR104","WTR115","WTR002"
        },
        -- pack #20 in box #42
        [20] = {
            "WTR183","WTR220","WTR181","WTR217","WTR080","WTR013","WTR175","WTR200","WTR037","WTR057","WTR024","WTR143","WTR096","WTR146","WTR109","WTR225","WTR002"
        },
        -- pack #21 in box #42
        [21] = {
            "WTR189","WTR178","WTR216","WTR201","WTR042","WTR013","WTR094","WTR060","WTR031","WTR074","WTR035","WTR057","WTR104","WTR135","WTR107","WTR224"
        },
        -- pack #22 in box #42
        [22] = {
            "WTR219","WTR182","WTR200","WTR180","WTR117","WTR167","WTR055","WTR147","WTR068","WTR030","WTR074","WTR100","WTR136","WTR095","WTR133","WTR002","WTR114"
        },
        -- pack #23 in box #42
        [23] = {
            "WTR218","WTR208","WTR214","WTR185","WTR042","WTR172","WTR170","WTR170","WTR026","WTR063","WTR029","WTR134","WTR106","WTR147","WTR100","WTR040","WTR115"
        },
        -- pack #24 in box #42
        [24] = {
            "WTR179","WTR214","WTR194","WTR210","WTR005","WTR049","WTR089","WTR044","WTR060","WTR030","WTR068","WTR021","WTR149","WTR108","WTR144","WTR078","WTR113"
        },
    },
    -- box #43
    [43] = {
        -- pack #1 in box #43
        [1] = {
            "WTR186","WTR212","WTR195","WTR176","WTR153","WTR055","WTR169","WTR189","WTR070","WTR023","WTR059","WTR102","WTR135","WTR112","WTR140","WTR225","WTR038"
        },
        -- pack #2 in box #43
        [2] = {
            "WTR207","WTR222","WTR179","WTR216","WTR117","WTR053","WTR091","WTR211","WTR067","WTR030","WTR058","WTR108","WTR140","WTR112","WTR149","WTR039","WTR115"
        },
        -- pack #3 in box #43
        [3] = {
            "WTR187","WTR194","WTR197","WTR210","WTR156","WTR123","WTR175","WTR034","WTR032","WTR059","WTR036","WTR133","WTR097","WTR135","WTR109","WTR225","WTR001"
        },
        -- pack #4 in box #43
        [4] = {
            "WTR222","WTR192","WTR214","WTR205","WTR005","WTR127","WTR014","WTR042","WTR020","WTR073","WTR032","WTR065","WTR107","WTR136","WTR098","WTR114","WTR003"
        },
        -- pack #5 in box #43
        [5] = {
            "WTR194","WTR214","WTR193","WTR220","WTR042","WTR171","WTR120","WTR023","WTR059","WTR028","WTR070","WTR030","WTR134","WTR100","WTR138","WTR038","WTR002"
        },
        -- pack #6 in box #43
        [6] = {
            "WTR203","WTR201","WTR184","WTR211","WTR155","WTR172","WTR094","WTR156","WTR063","WTR032","WTR060","WTR100","WTR140","WTR098","WTR147","WTR039","WTR113"
        },
        -- pack #7 in box #43
        [7] = {
            "WTR192","WTR206","WTR212","WTR184","WTR155","WTR048","WTR129","WTR023","WTR033","WTR066","WTR020","WTR148","WTR111","WTR136","WTR110","WTR115","WTR039"
        },
        -- pack #8 in box #43
        [8] = {
            "WTR185","WTR197","WTR189","WTR220","WTR157","WTR169","WTR017","WTR135","WTR036","WTR066","WTR030","WTR070","WTR095","WTR148","WTR099","WTR077","WTR002"
        },
        -- pack #9 in box #43
        [9] = {
            "WTR219","WTR189","WTR181","WTR210","WTR151","WTR013","WTR170","WTR057","WTR068","WTR036","WTR065","WTR100","WTR145","WTR107","WTR132","WTR075","WTR077"
        },
        -- pack #10 in box #43
        [10] = {
            "WTR202","WTR199","WTR213","WTR214","WTR151","WTR123","WTR091","WTR212","WTR037","WTR074","WTR022","WTR146","WTR095","WTR138","WTR107","WTR224"
        },
        -- pack #11 in box #43
        [11] = {
            "WTR185","WTR189","WTR220","WTR181","WTR155","WTR050","WTR170","WTR013","WTR024","WTR067","WTR030","WTR069","WTR097","WTR136","WTR099","WTR075","WTR076"
        },
        -- pack #12 in box #43
        [12] = {
            "WTR193","WTR201","WTR216","WTR210","WTR151","WTR168","WTR052","WTR067","WTR060","WTR025","WTR063","WTR027","WTR132","WTR099","WTR143","WTR077","WTR076"
        },
        -- pack #13 in box #43
        [13] = {
            "WTR222","WTR201","WTR213","WTR180","WTR156","WTR015","WTR163","WTR112","WTR058","WTR022","WTR073","WTR100","WTR135","WTR100","WTR143","WTR038","WTR225"
        },
        -- pack #14 in box #43
        [14] = {
            "WTR211","WTR223","WTR209","WTR211","WTR117","WTR131","WTR167","WTR022","WTR057","WTR025","WTR059","WTR028","WTR136","WTR095","WTR136","WTR115","WTR039"
        },
        -- pack #15 in box #43
        [15] = {
            "WTR203","WTR178","WTR220","WTR204","WTR151","WTR166","WTR124","WTR035","WTR021","WTR067","WTR034","WTR073","WTR110","WTR134","WTR103","WTR114","WTR003"
        },
        -- pack #16 in box #43
        [16] = {
            "WTR222","WTR218","WTR220","WTR220","WTR117","WTR091","WTR052","WTR106","WTR035","WTR065","WTR031","WTR138","WTR105","WTR149","WTR100","WTR114","WTR039"
        },
        -- pack #17 in box #43
        [17] = {
            "WTR222","WTR199","WTR178","WTR223","WTR154","WTR014","WTR126","WTR111","WTR026","WTR058","WTR037","WTR071","WTR104","WTR142","WTR097","WTR039","WTR114"
        },
        -- pack #18 in box #43
        [18] = {
            "WTR191","WTR184","WTR196","WTR190","WTR153","WTR168","WTR170","WTR049","WTR067","WTR035","WTR059","WTR023","WTR148","WTR103","WTR141","WTR076","WTR038"
        },
        -- pack #19 in box #43
        [19] = {
            "WTR219","WTR209","WTR184","WTR222","WTR155","WTR175","WTR081","WTR217","WTR072","WTR029","WTR065","WTR031","WTR139","WTR111","WTR135","WTR040","WTR039"
        },
        -- pack #20 in box #43
        [20] = {
            "WTR182","WTR210","WTR182","WTR210","WTR080","WTR168","WTR124","WTR030","WTR058","WTR029","WTR072","WTR024","WTR134","WTR108","WTR140","WTR075","WTR038"
        },
        -- pack #21 in box #43
        [21] = {
            "WTR219","WTR179","WTR204","WTR223","WTR158","WTR169","WTR123","WTR092","WTR031","WTR059","WTR031","WTR144","WTR096","WTR140","WTR102","WTR039","WTR115"
        },
        -- pack #22 in box #43
        [22] = {
            "WTR218","WTR221","WTR214","WTR221","WTR117","WTR169","WTR093","WTR104","WTR069","WTR032","WTR072","WTR103","WTR144","WTR100","WTR138","WTR002","WTR113"
        },
        -- pack #23 in box #43
        [23] = {
            "WTR204","WTR217","WTR186","WTR215","WTR151","WTR088","WTR089","WTR024","WTR035","WTR063","WTR027","WTR058","WTR097","WTR137","WTR096","WTR224"
        },
        -- pack #24 in box #43
        [24] = {
            "WTR189","WTR193","WTR214","WTR186","WTR117","WTR017","WTR093","WTR166","WTR037","WTR071","WTR029","WTR140","WTR110","WTR138","WTR098","WTR115","WTR078"
        },
    },
    -- box #44
    [44] = {
        -- pack #1 in box #44
        [1] = {
            "WTR220","WTR176","WTR181","WTR202","WTR154","WTR018","WTR045","WTR102","WTR060","WTR028","WTR062","WTR032","WTR133","WTR105","WTR141","WTR225","WTR076"
        },
        -- pack #2 in box #44
        [2] = {
            "WTR183","WTR211","WTR212","WTR213","WTR151","WTR086","WTR086","WTR148","WTR070","WTR029","WTR067","WTR031","WTR135","WTR098","WTR143","WTR003","WTR039"
        },
        -- pack #3 in box #44
        [3] = {
            "WTR215","WTR186","WTR188","WTR200","WTR153","WTR126","WTR124","WTR024","WTR026","WTR073","WTR033","WTR149","WTR107","WTR146","WTR108","WTR003","WTR076"
        },
        -- pack #4 in box #44
        [4] = {
            "WTR187","WTR211","WTR222","WTR221","WTR153","WTR124","WTR119","WTR144","WTR069","WTR024","WTR063","WTR106","WTR136","WTR108","WTR135","WTR115","WTR113"
        },
        -- pack #5 in box #44
        [5] = {
            "WTR202","WTR190","WTR181","WTR222","WTR154","WTR125","WTR163","WTR157","WTR031","WTR068","WTR021","WTR138","WTR108","WTR143","WTR099","WTR003","WTR078"
        },
        -- pack #6 in box #44
        [6] = {
            "WTR222","WTR217","WTR195","WTR213","WTR005","WTR126","WTR121","WTR071","WTR059","WTR031","WTR067","WTR111","WTR147","WTR100","WTR147","WTR115","WTR077"
        },
        -- pack #7 in box #44
        [7] = {
            "WTR205","WTR215","WTR203","WTR220","WTR154","WTR166","WTR019","WTR060","WTR020","WTR068","WTR032","WTR140","WTR102","WTR144","WTR109","WTR114","WTR001"
        },
        -- pack #8 in box #44
        [8] = {
            "WTR211","WTR205","WTR188","WTR198","WTR155","WTR088","WTR094","WTR143","WTR028","WTR063","WTR036","WTR058","WTR106","WTR146","WTR103","WTR075","WTR038"
        },
        -- pack #9 in box #44
        [9] = {
            "WTR208","WTR178","WTR208","WTR182","WTR156","WTR123","WTR084","WTR215","WTR057","WTR029","WTR065","WTR022","WTR132","WTR106","WTR134","WTR113","WTR038"
        },
        -- pack #10 in box #44
        [10] = {
            "WTR210","WTR178","WTR222","WTR183","WTR156","WTR172","WTR129","WTR101","WTR023","WTR067","WTR036","WTR145","WTR098","WTR137","WTR100","WTR225","WTR114"
        },
        -- pack #11 in box #44
        [11] = {
            "WTR182","WTR223","WTR176","WTR180","WTR158","WTR090","WTR086","WTR069","WTR069","WTR020","WTR064","WTR036","WTR140","WTR111","WTR142","WTR113","WTR114"
        },
        -- pack #12 in box #44
        [12] = {
            "WTR211","WTR200","WTR179","WTR220","WTR156","WTR053","WTR093","WTR180","WTR036","WTR059","WTR033","WTR059","WTR104","WTR139","WTR110","WTR040","WTR001"
        },
        -- pack #13 in box #44
        [13] = {
            "WTR184","WTR212","WTR195","WTR183","WTR042","WTR087","WTR083","WTR149","WTR024","WTR070","WTR020","WTR066","WTR112","WTR148","WTR095","WTR078","WTR076"
        },
        -- pack #14 in box #44
        [14] = {
            "WTR198","WTR199","WTR192","WTR207","WTR154","WTR015","WTR015","WTR080","WTR066","WTR030","WTR064","WTR099","WTR139","WTR095","WTR147","WTR039","WTR075"
        },
        -- pack #15 in box #44
        [15] = {
            "WTR217","WTR197","WTR186","WTR183","WTR154","WTR167","WTR121","WTR112","WTR073","WTR024","WTR068","WTR102","WTR148","WTR107","WTR133","WTR078","WTR076"
        },
        -- pack #16 in box #44
        [16] = {
            "WTR219","WTR183","WTR207","WTR202","WTR080","WTR129","WTR083","WTR070","WTR073","WTR028","WTR070","WTR101","WTR147","WTR104","WTR138","WTR115","WTR040"
        },
        -- pack #17 in box #44
        [17] = {
            "WTR194","WTR208","WTR188","WTR203","WTR152","WTR092","WTR084","WTR204","WTR034","WTR069","WTR030","WTR073","WTR103","WTR137","WTR103","WTR225","WTR113"
        },
        -- pack #18 in box #44
        [18] = {
            "WTR214","WTR197","WTR211","WTR203","WTR005","WTR091","WTR131","WTR027","WTR059","WTR029","WTR061","WTR033","WTR137","WTR107","WTR132","WTR002","WTR001"
        },
        -- pack #19 in box #44
        [19] = {
            "WTR206","WTR213","WTR178","WTR206","WTR156","WTR169","WTR092","WTR212","WTR021","WTR059","WTR034","WTR065","WTR098","WTR147","WTR106","WTR115","WTR038"
        },
        -- pack #20 in box #44
        [20] = {
            "WTR180","WTR179","WTR214","WTR188","WTR005","WTR128","WTR127","WTR095","WTR070","WTR023","WTR060","WTR101","WTR142","WTR105","WTR135","WTR078","WTR077"
        },
        -- pack #21 in box #44
        [21] = {
            "WTR214","WTR195","WTR185","WTR212","WTR005","WTR125","WTR173","WTR177","WTR026","WTR057","WTR022","WTR068","WTR103","WTR135","WTR105","WTR076","WTR225"
        },
        -- pack #22 in box #44
        [22] = {
            "WTR209","WTR198","WTR185","WTR191","WTR157","WTR123","WTR048","WTR195","WTR025","WTR057","WTR021","WTR145","WTR100","WTR147","WTR112","WTR038","WTR076"
        },
        -- pack #23 in box #44
        [23] = {
            "WTR195","WTR220","WTR206","WTR220","WTR153","WTR056","WTR056","WTR149","WTR030","WTR074","WTR020","WTR137","WTR106","WTR136","WTR100","WTR224"
        },
        -- pack #24 in box #44
        [24] = {
            "WTR198","WTR179","WTR201","WTR209","WTR080","WTR128","WTR014","WTR031","WTR059","WTR020","WTR057","WTR024","WTR143","WTR101","WTR138","WTR001","WTR077"
        },
    },
    -- box #45
    [45] = {
        -- pack #1 in box #45
        [1] = {
            "WTR212","WTR198","WTR187","WTR216","WTR157","WTR012","WTR081","WTR192","WTR059","WTR020","WTR071","WTR029","WTR136","WTR095","WTR146","WTR003","WTR225"
        },
        -- pack #2 in box #45
        [2] = {
            "WTR180","WTR207","WTR221","WTR215","WTR042","WTR124","WTR051","WTR036","WTR057","WTR024","WTR064","WTR109","WTR146","WTR112","WTR147","WTR115","WTR040"
        },
        -- pack #3 in box #45
        [3] = {
            "WTR178","WTR180","WTR222","WTR193","WTR005","WTR172","WTR171","WTR085","WTR065","WTR035","WTR071","WTR098","WTR141","WTR097","WTR135","WTR225","WTR114"
        },
        -- pack #4 in box #45
        [4] = {
            "WTR199","WTR218","WTR213","WTR221","WTR155","WTR125","WTR121","WTR209","WTR066","WTR035","WTR068","WTR029","WTR140","WTR107","WTR133","WTR113","WTR078"
        },
        -- pack #5 in box #45
        [5] = {
            "WTR216","WTR189","WTR199","WTR196","WTR155","WTR169","WTR048","WTR089","WTR023","WTR065","WTR022","WTR063","WTR104","WTR133","WTR096","WTR225","WTR113"
        },
        -- pack #6 in box #45
        [6] = {
            "WTR190","WTR210","WTR200","WTR220","WTR155","WTR093","WTR126","WTR100","WTR027","WTR066","WTR032","WTR069","WTR096","WTR138","WTR099","WTR077","WTR001"
        },
        -- pack #7 in box #45
        [7] = {
            "WTR219","WTR184","WTR180","WTR215","WTR153","WTR016","WTR165","WTR092","WTR022","WTR062","WTR033","WTR064","WTR096","WTR142","WTR101","WTR003","WTR113"
        },
        -- pack #8 in box #45
        [8] = {
            "WTR204","WTR176","WTR176","WTR198","WTR152","WTR093","WTR166","WTR189","WTR021","WTR072","WTR026","WTR143","WTR107","WTR137","WTR112","WTR114","WTR039"
        },
        -- pack #9 in box #45
        [9] = {
            "WTR219","WTR190","WTR206","WTR205","WTR155","WTR055","WTR173","WTR209","WTR058","WTR035","WTR066","WTR020","WTR134","WTR102","WTR132","WTR225","WTR115"
        },
        -- pack #10 in box #45
        [10] = {
            "WTR210","WTR188","WTR205","WTR183","WTR154","WTR011","WTR128","WTR080","WTR058","WTR032","WTR066","WTR028","WTR147","WTR095","WTR142","WTR115","WTR001"
        },
        -- pack #11 in box #45
        [11] = {
            "WTR210","WTR213","WTR180","WTR200","WTR005","WTR173","WTR162","WTR102","WTR031","WTR066","WTR027","WTR074","WTR107","WTR132","WTR106","WTR114","WTR002"
        },
        -- pack #12 in box #45
        [12] = {
            "WTR189","WTR191","WTR204","WTR213","WTR117","WTR054","WTR128","WTR211","WTR073","WTR034","WTR061","WTR098","WTR135","WTR110","WTR140","WTR038","WTR075"
        },
        -- pack #13 in box #45
        [13] = {
            "WTR213","WTR177","WTR185","WTR218","WTR156","WTR016","WTR054","WTR146","WTR022","WTR067","WTR029","WTR134","WTR098","WTR139","WTR100","WTR039","WTR038"
        },
        -- pack #14 in box #45
        [14] = {
            "WTR189","WTR217","WTR209","WTR216","WTR117","WTR087","WTR120","WTR212","WTR026","WTR058","WTR037","WTR148","WTR097","WTR137","WTR110","WTR040","WTR038"
        },
        -- pack #15 in box #45
        [15] = {
            "WTR219","WTR206","WTR189","WTR182","WTR152","WTR094","WTR159","WTR029","WTR021","WTR057","WTR025","WTR148","WTR110","WTR137","WTR095","WTR038","WTR002"
        },
        -- pack #16 in box #45
        [16] = {
            "WTR193","WTR178","WTR179","WTR182","WTR005","WTR093","WTR161","WTR155","WTR028","WTR071","WTR026","WTR071","WTR097","WTR138","WTR110","WTR001","WTR075"
        },
        -- pack #17 in box #45
        [17] = {
            "WTR188","WTR219","WTR184","WTR177","WTR154","WTR087","WTR051","WTR134","WTR058","WTR032","WTR062","WTR098","WTR134","WTR100","WTR135","WTR224"
        },
        -- pack #18 in box #45
        [18] = {
            "WTR183","WTR185","WTR222","WTR207","WTR155","WTR016","WTR016","WTR140","WTR066","WTR029","WTR073","WTR106","WTR148","WTR100","WTR136","WTR076","WTR225"
        },
        -- pack #19 in box #45
        [19] = {
            "WTR178","WTR205","WTR198","WTR194","WTR151","WTR048","WTR086","WTR109","WTR059","WTR031","WTR068","WTR097","WTR137","WTR104","WTR145","WTR225","WTR076"
        },
        -- pack #20 in box #45
        [20] = {
            "WTR207","WTR207","WTR223","WTR211","WTR154","WTR128","WTR014","WTR214","WTR033","WTR061","WTR035","WTR068","WTR097","WTR135","WTR111","WTR002","WTR001"
        },
        -- pack #21 in box #45
        [21] = {
            "WTR177","WTR203","WTR197","WTR223","WTR042","WTR090","WTR170","WTR135","WTR035","WTR067","WTR021","WTR137","WTR104","WTR132","WTR109","WTR115","WTR075"
        },
        -- pack #22 in box #45
        [22] = {
            "WTR184","WTR217","WTR199","WTR196","WTR157","WTR173","WTR131","WTR160","WTR065","WTR022","WTR060","WTR036","WTR148","WTR100","WTR138","WTR077","WTR113"
        },
        -- pack #23 in box #45
        [23] = {
            "WTR205","WTR212","WTR180","WTR176","WTR153","WTR090","WTR171","WTR223","WTR062","WTR031","WTR072","WTR021","WTR138","WTR104","WTR142","WTR224"
        },
        -- pack #24 in box #45
        [24] = {
            "WTR176","WTR201","WTR202","WTR187","WTR155","WTR019","WTR126","WTR095","WTR033","WTR065","WTR028","WTR141","WTR107","WTR147","WTR101","WTR224"
        },
    },
    -- box #46
    [46] = {
        -- pack #1 in box #46
        [1] = {
            "WTR194","WTR200","WTR178","WTR200","WTR080","WTR165","WTR015","WTR208","WTR035","WTR070","WTR025","WTR062","WTR103","WTR136","WTR106","WTR077","WTR001"
        },
        -- pack #2 in box #46
        [2] = {
            "WTR188","WTR208","WTR192","WTR208","WTR155","WTR164","WTR088","WTR012","WTR074","WTR037","WTR063","WTR029","WTR140","WTR098","WTR148","WTR076","WTR115"
        },
        -- pack #3 in box #46
        [3] = {
            "WTR208","WTR195","WTR197","WTR182","WTR042","WTR055","WTR166","WTR218","WTR061","WTR021","WTR069","WTR023","WTR142","WTR095","WTR140","WTR115","WTR113"
        },
        -- pack #4 in box #46
        [4] = {
            "WTR180","WTR211","WTR185","WTR221","WTR080","WTR056","WTR120","WTR117","WTR030","WTR066","WTR031","WTR149","WTR101","WTR138","WTR097","WTR003","WTR038"
        },
        -- pack #5 in box #46
        [5] = {
            "WTR201","WTR182","WTR219","WTR186","WTR117","WTR014","WTR016","WTR063","WTR063","WTR027","WTR059","WTR031","WTR141","WTR099","WTR143","WTR003","WTR114"
        },
        -- pack #6 in box #46
        [6] = {
            "WTR204","WTR214","WTR221","WTR193","WTR154","WTR055","WTR165","WTR107","WTR029","WTR057","WTR020","WTR062","WTR102","WTR134","WTR105","WTR076","WTR039"
        },
        -- pack #7 in box #46
        [7] = {
            "WTR201","WTR194","WTR202","WTR221","WTR156","WTR015","WTR121","WTR198","WTR029","WTR074","WTR035","WTR145","WTR102","WTR140","WTR101","WTR003","WTR001"
        },
        -- pack #8 in box #46
        [8] = {
            "WTR211","WTR181","WTR192","WTR180","WTR152","WTR012","WTR087","WTR022","WTR068","WTR023","WTR063","WTR095","WTR145","WTR107","WTR147","WTR038","WTR076"
        },
        -- pack #9 in box #46
        [9] = {
            "WTR222","WTR177","WTR206","WTR199","WTR157","WTR165","WTR086","WTR144","WTR065","WTR020","WTR061","WTR101","WTR136","WTR100","WTR145","WTR224"
        },
        -- pack #10 in box #46
        [10] = {
            "WTR176","WTR179","WTR218","WTR218","WTR005","WTR093","WTR013","WTR014","WTR072","WTR034","WTR070","WTR104","WTR137","WTR100","WTR141","WTR077","WTR002"
        },
        -- pack #11 in box #46
        [11] = {
            "WTR183","WTR181","WTR210","WTR215","WTR156","WTR170","WTR016","WTR147","WTR063","WTR024","WTR063","WTR100","WTR142","WTR106","WTR142","WTR078","WTR114"
        },
        -- pack #12 in box #46
        [12] = {
            "WTR188","WTR208","WTR184","WTR183","WTR154","WTR170","WTR091","WTR056","WTR064","WTR023","WTR073","WTR099","WTR134","WTR096","WTR148","WTR002","WTR077"
        },
        -- pack #13 in box #46
        [13] = {
            "WTR205","WTR179","WTR184","WTR198","WTR153","WTR012","WTR050","WTR203","WTR025","WTR063","WTR023","WTR063","WTR105","WTR132","WTR109","WTR224"
        },
        -- pack #14 in box #46
        [14] = {
            "WTR208","WTR217","WTR190","WTR223","WTR151","WTR093","WTR083","WTR193","WTR021","WTR066","WTR036","WTR066","WTR103","WTR141","WTR100","WTR002","WTR039"
        },
        -- pack #15 in box #46
        [15] = {
            "WTR215","WTR185","WTR213","WTR211","WTR152","WTR017","WTR086","WTR163","WTR037","WTR071","WTR024","WTR068","WTR106","WTR133","WTR099","WTR113","WTR002"
        },
        -- pack #16 in box #46
        [16] = {
            "WTR216","WTR198","WTR199","WTR202","WTR080","WTR128","WTR162","WTR031","WTR064","WTR028","WTR066","WTR097","WTR149","WTR098","WTR142","WTR113","WTR038"
        },
        -- pack #17 in box #46
        [17] = {
            "WTR207","WTR186","WTR206","WTR212","WTR080","WTR167","WTR092","WTR220","WTR037","WTR062","WTR027","WTR140","WTR112","WTR144","WTR096","WTR075","WTR040"
        },
        -- pack #18 in box #46
        [18] = {
            "WTR196","WTR195","WTR197","WTR215","WTR005","WTR054","WTR092","WTR062","WTR069","WTR023","WTR072","WTR028","WTR138","WTR107","WTR144","WTR114","WTR039"
        },
        -- pack #19 in box #46
        [19] = {
            "WTR203","WTR204","WTR202","WTR204","WTR155","WTR011","WTR167","WTR148","WTR023","WTR074","WTR028","WTR139","WTR101","WTR148","WTR112","WTR078","WTR113"
        },
        -- pack #20 in box #46
        [20] = {
            "WTR217","WTR192","WTR215","WTR179","WTR152","WTR129","WTR019","WTR072","WTR036","WTR066","WTR036","WTR073","WTR108","WTR136","WTR099","WTR077","WTR075"
        },
        -- pack #21 in box #46
        [21] = {
            "WTR204","WTR206","WTR223","WTR214","WTR158","WTR056","WTR125","WTR168","WTR064","WTR037","WTR065","WTR037","WTR143","WTR096","WTR136","WTR075","WTR076"
        },
        -- pack #22 in box #46
        [22] = {
            "WTR178","WTR210","WTR196","WTR183","WTR080","WTR129","WTR009","WTR143","WTR070","WTR034","WTR063","WTR033","WTR137","WTR112","WTR134","WTR039","WTR078"
        },
        -- pack #23 in box #46
        [23] = {
            "WTR196","WTR185","WTR195","WTR188","WTR152","WTR125","WTR127","WTR223","WTR034","WTR062","WTR036","WTR132","WTR106","WTR145","WTR106","WTR076","WTR038"
        },
        -- pack #24 in box #46
        [24] = {
            "WTR206","WTR218","WTR205","WTR182","WTR154","WTR093","WTR121","WTR124","WTR037","WTR071","WTR028","WTR135","WTR102","WTR139","WTR097","WTR078","WTR003"
        },
    },
    -- box #47
    [47] = {
        -- pack #1 in box #47
        [1] = {
            "WTR183","WTR202","WTR219","WTR213","WTR117","WTR050","WTR167","WTR173","WTR062","WTR024","WTR066","WTR109","WTR149","WTR112","WTR147","WTR078","WTR225"
        },
        -- pack #2 in box #47
        [2] = {
            "WTR194","WTR200","WTR179","WTR194","WTR117","WTR019","WTR018","WTR174","WTR032","WTR060","WTR020","WTR142","WTR096","WTR133","WTR108","WTR077","WTR038"
        },
        -- pack #3 in box #47
        [3] = {
            "WTR203","WTR181","WTR203","WTR201","WTR152","WTR130","WTR052","WTR141","WTR057","WTR032","WTR068","WTR107","WTR137","WTR104","WTR139","WTR003","WTR075"
        },
        -- pack #4 in box #47
        [4] = {
            "WTR212","WTR197","WTR187","WTR192","WTR155","WTR092","WTR092","WTR033","WTR059","WTR026","WTR058","WTR097","WTR135","WTR106","WTR139","WTR113","WTR115"
        },
        -- pack #5 in box #47
        [5] = {
            "WTR221","WTR192","WTR223","WTR219","WTR080","WTR012","WTR053","WTR222","WTR022","WTR071","WTR026","WTR057","WTR107","WTR140","WTR110","WTR076","WTR114"
        },
        -- pack #6 in box #47
        [6] = {
            "WTR194","WTR202","WTR214","WTR190","WTR042","WTR086","WTR121","WTR207","WTR073","WTR020","WTR058","WTR100","WTR149","WTR105","WTR149","WTR225","WTR115"
        },
        -- pack #7 in box #47
        [7] = {
            "WTR221","WTR211","WTR210","WTR208","WTR152","WTR130","WTR046","WTR049","WTR069","WTR033","WTR065","WTR023","WTR133","WTR106","WTR132","WTR040","WTR077"
        },
        -- pack #8 in box #47
        [8] = {
            "WTR216","WTR184","WTR177","WTR180","WTR042","WTR129","WTR008","WTR214","WTR070","WTR027","WTR066","WTR020","WTR133","WTR107","WTR146","WTR002","WTR115"
        },
        -- pack #9 in box #47
        [9] = {
            "WTR177","WTR201","WTR215","WTR200","WTR158","WTR052","WTR051","WTR051","WTR065","WTR031","WTR061","WTR026","WTR144","WTR099","WTR139","WTR075","WTR115"
        },
        -- pack #10 in box #47
        [10] = {
            "WTR222","WTR198","WTR206","WTR191","WTR157","WTR013","WTR166","WTR147","WTR030","WTR060","WTR035","WTR142","WTR104","WTR138","WTR106","WTR078","WTR001"
        },
        -- pack #11 in box #47
        [11] = {
            "WTR176","WTR206","WTR189","WTR188","WTR117","WTR052","WTR128","WTR033","WTR073","WTR035","WTR061","WTR099","WTR145","WTR095","WTR135","WTR038","WTR076"
        },
        -- pack #12 in box #47
        [12] = {
            "WTR220","WTR218","WTR211","WTR221","WTR005","WTR166","WTR125","WTR153","WTR035","WTR069","WTR023","WTR064","WTR110","WTR142","WTR099","WTR113","WTR075"
        },
        -- pack #13 in box #47
        [13] = {
            "WTR177","WTR204","WTR213","WTR191","WTR080","WTR171","WTR009","WTR137","WTR070","WTR026","WTR066","WTR025","WTR135","WTR112","WTR144","WTR001","WTR077"
        },
        -- pack #14 in box #47
        [14] = {
            "WTR209","WTR208","WTR206","WTR217","WTR117","WTR088","WTR172","WTR017","WTR033","WTR067","WTR030","WTR073","WTR110","WTR139","WTR107","WTR001","WTR115"
        },
        -- pack #15 in box #47
        [15] = {
            "WTR195","WTR219","WTR183","WTR195","WTR152","WTR126","WTR171","WTR213","WTR071","WTR031","WTR071","WTR028","WTR134","WTR103","WTR148","WTR077","WTR003"
        },
        -- pack #16 in box #47
        [16] = {
            "WTR204","WTR210","WTR199","WTR191","WTR042","WTR015","WTR048","WTR063","WTR037","WTR070","WTR022","WTR062","WTR109","WTR147","WTR102","WTR113","WTR040"
        },
        -- pack #17 in box #47
        [17] = {
            "WTR199","WTR210","WTR213","WTR201","WTR151","WTR055","WTR164","WTR089","WTR026","WTR065","WTR025","WTR135","WTR109","WTR141","WTR101","WTR077","WTR003"
        },
        -- pack #18 in box #47
        [18] = {
            "WTR201","WTR187","WTR209","WTR204","WTR080","WTR019","WTR089","WTR006","WTR067","WTR031","WTR062","WTR107","WTR143","WTR104","WTR141","WTR078","WTR076"
        },
        -- pack #19 in box #47
        [19] = {
            "WTR181","WTR179","WTR198","WTR178","WTR154","WTR052","WTR049","WTR103","WTR020","WTR067","WTR020","WTR132","WTR102","WTR146","WTR098","WTR224"
        },
        -- pack #20 in box #47
        [20] = {
            "WTR176","WTR202","WTR217","WTR204","WTR117","WTR090","WTR016","WTR129","WTR027","WTR061","WTR020","WTR145","WTR097","WTR133","WTR110","WTR002","WTR038"
        },
        -- pack #21 in box #47
        [21] = {
            "WTR188","WTR197","WTR213","WTR176","WTR156","WTR093","WTR168","WTR202","WTR023","WTR063","WTR024","WTR139","WTR112","WTR142","WTR108","WTR078","WTR002"
        },
        -- pack #22 in box #47
        [22] = {
            "WTR217","WTR196","WTR183","WTR205","WTR157","WTR051","WTR017","WTR029","WTR060","WTR033","WTR066","WTR031","WTR134","WTR107","WTR136","WTR078","WTR114"
        },
        -- pack #23 in box #47
        [23] = {
            "WTR219","WTR191","WTR203","WTR209","WTR157","WTR171","WTR128","WTR158","WTR021","WTR058","WTR026","WTR064","WTR105","WTR132","WTR097","WTR040","WTR078"
        },
        -- pack #24 in box #47
        [24] = {
            "WTR184","WTR201","WTR189","WTR179","WTR154","WTR052","WTR086","WTR097","WTR030","WTR071","WTR024","WTR057","WTR112","WTR141","WTR112","WTR225","WTR038"
        },
    },
    -- box #48
    [48] = {
        -- pack #1 in box #48
        [1] = {
            "WTR221","WTR211","WTR196","WTR202","WTR151","WTR088","WTR089","WTR133","WTR032","WTR062","WTR020","WTR063","WTR103","WTR133","WTR108","WTR039","WTR076"
        },
        -- pack #2 in box #48
        [2] = {
            "WTR176","WTR183","WTR216","WTR216","WTR156","WTR131","WTR162","WTR063","WTR070","WTR027","WTR058","WTR030","WTR141","WTR109","WTR146","WTR077","WTR075"
        },
        -- pack #3 in box #48
        [3] = {
            "WTR202","WTR179","WTR212","WTR201","WTR156","WTR175","WTR093","WTR062","WTR022","WTR072","WTR033","WTR065","WTR112","WTR148","WTR096","WTR075","WTR115"
        },
        -- pack #4 in box #48
        [4] = {
            "WTR176","WTR192","WTR218","WTR181","WTR158","WTR172","WTR094","WTR125","WTR027","WTR060","WTR021","WTR132","WTR108","WTR148","WTR095","WTR224"
        },
        -- pack #5 in box #48
        [5] = {
            "WTR220","WTR184","WTR214","WTR183","WTR153","WTR056","WTR013","WTR159","WTR027","WTR061","WTR023","WTR068","WTR110","WTR143","WTR100","WTR002","WTR075"
        },
        -- pack #6 in box #48
        [6] = {
            "WTR186","WTR193","WTR185","WTR183","WTR152","WTR052","WTR175","WTR107","WTR061","WTR028","WTR057","WTR029","WTR141","WTR107","WTR147","WTR076","WTR113"
        },
        -- pack #7 in box #48
        [7] = {
            "WTR192","WTR218","WTR206","WTR189","WTR152","WTR171","WTR130","WTR188","WTR060","WTR022","WTR065","WTR029","WTR145","WTR106","WTR147","WTR078","WTR039"
        },
        -- pack #8 in box #48
        [8] = {
            "WTR195","WTR179","WTR191","WTR212","WTR155","WTR125","WTR014","WTR020","WTR061","WTR022","WTR074","WTR027","WTR139","WTR095","WTR132","WTR001","WTR038"
        },
        -- pack #9 in box #48
        [9] = {
            "WTR221","WTR207","WTR179","WTR215","WTR154","WTR086","WTR166","WTR196","WTR070","WTR033","WTR061","WTR024","WTR141","WTR098","WTR133","WTR076","WTR115"
        },
        -- pack #10 in box #48
        [10] = {
            "WTR197","WTR213","WTR193","WTR206","WTR080","WTR056","WTR010","WTR025","WTR057","WTR035","WTR061","WTR109","WTR138","WTR109","WTR132","WTR002","WTR075"
        },
        -- pack #11 in box #48
        [11] = {
            "WTR208","WTR212","WTR207","WTR183","WTR151","WTR016","WTR088","WTR094","WTR022","WTR065","WTR037","WTR137","WTR100","WTR149","WTR111","WTR115","WTR038"
        },
        -- pack #12 in box #48
        [12] = {
            "WTR181","WTR203","WTR209","WTR203","WTR154","WTR093","WTR007","WTR197","WTR060","WTR024","WTR059","WTR108","WTR144","WTR105","WTR137","WTR114","WTR002"
        },
        -- pack #13 in box #48
        [13] = {
            "WTR187","WTR199","WTR199","WTR177","WTR080","WTR052","WTR167","WTR127","WTR028","WTR069","WTR031","WTR147","WTR110","WTR133","WTR109","WTR078","WTR002"
        },
        -- pack #14 in box #48
        [14] = {
            "WTR191","WTR185","WTR214","WTR218","WTR151","WTR012","WTR048","WTR119","WTR070","WTR023","WTR057","WTR098","WTR134","WTR111","WTR144","WTR076","WTR039"
        },
        -- pack #15 in box #48
        [15] = {
            "WTR190","WTR179","WTR183","WTR193","WTR153","WTR094","WTR012","WTR129","WTR059","WTR027","WTR074","WTR095","WTR143","WTR108","WTR145","WTR224"
        },
        -- pack #16 in box #48
        [16] = {
            "WTR187","WTR189","WTR216","WTR220","WTR158","WTR093","WTR118","WTR065","WTR028","WTR062","WTR030","WTR067","WTR111","WTR141","WTR102","WTR076","WTR114"
        },
        -- pack #17 in box #48
        [17] = {
            "WTR203","WTR211","WTR195","WTR209","WTR005","WTR049","WTR012","WTR134","WTR028","WTR062","WTR030","WTR062","WTR107","WTR135","WTR107","WTR114","WTR115"
        },
        -- pack #18 in box #48
        [18] = {
            "WTR181","WTR196","WTR194","WTR221","WTR151","WTR125","WTR118","WTR105","WTR027","WTR073","WTR026","WTR147","WTR105","WTR149","WTR108","WTR001","WTR077"
        },
        -- pack #19 in box #48
        [19] = {
            "WTR178","WTR192","WTR201","WTR205","WTR005","WTR164","WTR013","WTR072","WTR020","WTR067","WTR026","WTR141","WTR096","WTR140","WTR108","WTR001","WTR225"
        },
        -- pack #20 in box #48
        [20] = {
            "WTR216","WTR217","WTR176","WTR196","WTR005","WTR130","WTR083","WTR221","WTR057","WTR030","WTR065","WTR103","WTR143","WTR098","WTR149","WTR002","WTR038"
        },
        -- pack #21 in box #48
        [21] = {
            "WTR197","WTR209","WTR180","WTR185","WTR152","WTR123","WTR008","WTR124","WTR066","WTR033","WTR068","WTR110","WTR147","WTR101","WTR141","WTR002","WTR115"
        },
        -- pack #22 in box #48
        [22] = {
            "WTR188","WTR197","WTR212","WTR180","WTR154","WTR127","WTR010","WTR094","WTR023","WTR060","WTR026","WTR138","WTR100","WTR146","WTR102","WTR078","WTR114"
        },
        -- pack #23 in box #48
        [23] = {
            "WTR198","WTR204","WTR208","WTR204","WTR154","WTR011","WTR091","WTR152","WTR073","WTR036","WTR060","WTR021","WTR134","WTR110","WTR144","WTR038","WTR001"
        },
        -- pack #24 in box #48
        [24] = {
            "WTR196","WTR187","WTR178","WTR223","WTR151","WTR017","WTR019","WTR221","WTR037","WTR062","WTR021","WTR073","WTR103","WTR139","WTR096","WTR113","WTR114"
        },
    },
    -- box #49
    [49] = {
        -- pack #1 in box #49
        [1] = {
            "WTR208","WTR222","WTR180","WTR216","WTR155","WTR012","WTR125","WTR109","WTR028","WTR059","WTR022","WTR142","WTR096","WTR135","WTR095","WTR113","WTR040"
        },
        -- pack #2 in box #49
        [2] = {
            "WTR180","WTR194","WTR213","WTR212","WTR042","WTR126","WTR088","WTR095","WTR023","WTR074","WTR033","WTR073","WTR109","WTR133","WTR103","WTR076","WTR038"
        },
        -- pack #3 in box #49
        [3] = {
            "WTR220","WTR217","WTR210","WTR201","WTR155","WTR165","WTR088","WTR148","WTR024","WTR061","WTR027","WTR072","WTR101","WTR144","WTR104","WTR115","WTR001"
        },
        -- pack #4 in box #49
        [4] = {
            "WTR205","WTR209","WTR204","WTR179","WTR156","WTR089","WTR174","WTR218","WTR066","WTR037","WTR067","WTR095","WTR139","WTR110","WTR138","WTR114","WTR003"
        },
        -- pack #5 in box #49
        [5] = {
            "WTR207","WTR199","WTR191","WTR186","WTR152","WTR175","WTR084","WTR193","WTR071","WTR036","WTR065","WTR112","WTR133","WTR096","WTR142","WTR001","WTR115"
        },
        -- pack #6 in box #49
        [6] = {
            "WTR177","WTR215","WTR215","WTR212","WTR005","WTR172","WTR056","WTR057","WTR070","WTR035","WTR072","WTR099","WTR138","WTR099","WTR139","WTR003","WTR075"
        },
        -- pack #7 in box #49
        [7] = {
            "WTR202","WTR220","WTR180","WTR217","WTR151","WTR169","WTR126","WTR073","WTR069","WTR022","WTR072","WTR033","WTR144","WTR098","WTR133","WTR225","WTR076"
        },
        -- pack #8 in box #49
        [8] = {
            "WTR219","WTR187","WTR218","WTR178","WTR151","WTR126","WTR131","WTR154","WTR022","WTR069","WTR031","WTR068","WTR098","WTR144","WTR100","WTR114","WTR225"
        },
        -- pack #9 in box #49
        [9] = {
            "WTR198","WTR217","WTR203","WTR203","WTR154","WTR088","WTR088","WTR186","WTR057","WTR022","WTR061","WTR036","WTR148","WTR097","WTR144","WTR003","WTR038"
        },
        -- pack #10 in box #49
        [10] = {
            "WTR178","WTR178","WTR223","WTR178","WTR080","WTR052","WTR049","WTR097","WTR032","WTR062","WTR028","WTR133","WTR095","WTR143","WTR109","WTR039","WTR225"
        },
        -- pack #11 in box #49
        [11] = {
            "WTR177","WTR220","WTR184","WTR200","WTR156","WTR167","WTR131","WTR074","WTR063","WTR031","WTR059","WTR027","WTR139","WTR098","WTR141","WTR038","WTR075"
        },
        -- pack #12 in box #49
        [12] = {
            "WTR198","WTR187","WTR180","WTR211","WTR005","WTR017","WTR053","WTR181","WTR072","WTR037","WTR064","WTR095","WTR147","WTR096","WTR141","WTR113","WTR078"
        },
        -- pack #13 in box #49
        [13] = {
            "WTR219","WTR199","WTR222","WTR207","WTR154","WTR055","WTR046","WTR116","WTR030","WTR057","WTR026","WTR133","WTR097","WTR147","WTR095","WTR075","WTR003"
        },
        -- pack #14 in box #49
        [14] = {
            "WTR207","WTR207","WTR184","WTR208","WTR042","WTR173","WTR167","WTR058","WTR027","WTR069","WTR035","WTR142","WTR105","WTR147","WTR101","WTR225","WTR076"
        },
        -- pack #15 in box #49
        [15] = {
            "WTR197","WTR199","WTR179","WTR190","WTR151","WTR051","WTR171","WTR197","WTR067","WTR021","WTR072","WTR022","WTR149","WTR099","WTR138","WTR076","WTR114"
        },
        -- pack #16 in box #49
        [16] = {
            "WTR206","WTR188","WTR199","WTR206","WTR156","WTR124","WTR051","WTR066","WTR073","WTR036","WTR072","WTR025","WTR149","WTR105","WTR141","WTR075","WTR002"
        },
        -- pack #17 in box #49
        [17] = {
            "WTR222","WTR204","WTR176","WTR194","WTR157","WTR172","WTR090","WTR005","WTR021","WTR072","WTR028","WTR068","WTR106","WTR149","WTR095","WTR076","WTR225"
        },
        -- pack #18 in box #49
        [18] = {
            "WTR179","WTR217","WTR206","WTR192","WTR042","WTR123","WTR084","WTR217","WTR027","WTR066","WTR030","WTR133","WTR108","WTR134","WTR095","WTR113","WTR078"
        },
        -- pack #19 in box #49
        [19] = {
            "WTR217","WTR183","WTR208","WTR189","WTR153","WTR048","WTR171","WTR158","WTR063","WTR021","WTR057","WTR095","WTR142","WTR104","WTR138","WTR003","WTR001"
        },
        -- pack #20 in box #49
        [20] = {
            "WTR185","WTR201","WTR223","WTR218","WTR152","WTR131","WTR087","WTR198","WTR059","WTR036","WTR063","WTR096","WTR148","WTR105","WTR134","WTR075","WTR113"
        },
        -- pack #21 in box #49
        [21] = {
            "WTR192","WTR212","WTR200","WTR206","WTR151","WTR052","WTR128","WTR054","WTR034","WTR072","WTR030","WTR148","WTR112","WTR147","WTR097","WTR077","WTR039"
        },
        -- pack #22 in box #49
        [22] = {
            "WTR189","WTR212","WTR209","WTR193","WTR155","WTR019","WTR006","WTR181","WTR033","WTR061","WTR028","WTR063","WTR108","WTR134","WTR103","WTR039","WTR077"
        },
        -- pack #23 in box #49
        [23] = {
            "WTR193","WTR221","WTR213","WTR185","WTR156","WTR123","WTR050","WTR215","WTR061","WTR035","WTR065","WTR021","WTR140","WTR109","WTR143","WTR075","WTR115"
        },
        -- pack #24 in box #49
        [24] = {
            "WTR180","WTR219","WTR203","WTR181","WTR157","WTR127","WTR164","WTR149","WTR023","WTR057","WTR034","WTR058","WTR106","WTR146","WTR098","WTR075","WTR115"
        },
    },
    -- box #50
    [50] = {
        -- pack #1 in box #50
        [1] = {
            "WTR193","WTR195","WTR195","WTR210","WTR153","WTR087","WTR084","WTR055","WTR068","WTR034","WTR065","WTR024","WTR148","WTR099","WTR145","WTR115","WTR113"
        },
        -- pack #2 in box #50
        [2] = {
            "WTR202","WTR181","WTR222","WTR192","WTR152","WTR168","WTR123","WTR069","WTR031","WTR066","WTR029","WTR140","WTR102","WTR144","WTR101","WTR077","WTR038"
        },
        -- pack #3 in box #50
        [3] = {
            "WTR192","WTR190","WTR222","WTR199","WTR158","WTR164","WTR174","WTR057","WTR071","WTR033","WTR061","WTR034","WTR138","WTR101","WTR147","WTR003","WTR002"
        },
        -- pack #4 in box #50
        [4] = {
            "WTR199","WTR223","WTR183","WTR195","WTR042","WTR089","WTR010","WTR136","WTR026","WTR057","WTR027","WTR061","WTR101","WTR139","WTR104","WTR114","WTR038"
        },
        -- pack #5 in box #50
        [5] = {
            "WTR219","WTR196","WTR188","WTR185","WTR152","WTR124","WTR128","WTR202","WTR020","WTR074","WTR031","WTR132","WTR096","WTR145","WTR098","WTR001","WTR077"
        },
        -- pack #6 in box #50
        [6] = {
            "WTR208","WTR184","WTR213","WTR182","WTR157","WTR053","WTR125","WTR128","WTR063","WTR021","WTR057","WTR096","WTR134","WTR110","WTR148","WTR001","WTR078"
        },
        -- pack #7 in box #50
        [7] = {
            "WTR223","WTR200","WTR193","WTR190","WTR154","WTR054","WTR123","WTR123","WTR060","WTR032","WTR063","WTR029","WTR138","WTR105","WTR142","WTR038","WTR078"
        },
        -- pack #8 in box #50
        [8] = {
            "WTR213","WTR220","WTR223","WTR179","WTR151","WTR053","WTR043","WTR153","WTR061","WTR029","WTR061","WTR025","WTR149","WTR110","WTR133","WTR077","WTR039"
        },
        -- pack #9 in box #50
        [9] = {
            "WTR223","WTR202","WTR176","WTR213","WTR154","WTR174","WTR051","WTR205","WTR026","WTR072","WTR021","WTR139","WTR100","WTR144","WTR099","WTR077","WTR078"
        },
        -- pack #10 in box #50
        [10] = {
            "WTR200","WTR204","WTR220","WTR183","WTR153","WTR174","WTR048","WTR203","WTR071","WTR020","WTR071","WTR111","WTR142","WTR098","WTR149","WTR039","WTR225"
        },
        -- pack #11 in box #50
        [11] = {
            "WTR197","WTR195","WTR182","WTR223","WTR151","WTR016","WTR092","WTR139","WTR035","WTR074","WTR024","WTR072","WTR111","WTR144","WTR109","WTR040","WTR038"
        },
        -- pack #12 in box #50
        [12] = {
            "WTR196","WTR180","WTR196","WTR178","WTR151","WTR051","WTR162","WTR219","WTR036","WTR069","WTR032","WTR142","WTR098","WTR143","WTR099","WTR225","WTR077"
        },
        -- pack #13 in box #50
        [13] = {
            "WTR189","WTR214","WTR179","WTR186","WTR080","WTR091","WTR014","WTR202","WTR023","WTR073","WTR034","WTR144","WTR097","WTR133","WTR108","WTR076","WTR115"
        },
        -- pack #14 in box #50
        [14] = {
            "WTR206","WTR203","WTR222","WTR186","WTR080","WTR017","WTR018","WTR145","WTR026","WTR058","WTR033","WTR073","WTR101","WTR133","WTR105","WTR225","WTR039"
        },
        -- pack #15 in box #50
        [15] = {
            "WTR196","WTR194","WTR207","WTR213","WTR152","WTR087","WTR124","WTR111","WTR071","WTR027","WTR057","WTR101","WTR138","WTR104","WTR140","WTR225","WTR001"
        },
        -- pack #16 in box #50
        [16] = {
            "WTR203","WTR201","WTR202","WTR177","WTR152","WTR168","WTR016","WTR146","WTR074","WTR032","WTR069","WTR024","WTR149","WTR112","WTR145","WTR224"
        },
        -- pack #17 in box #50
        [17] = {
            "WTR189","WTR210","WTR186","WTR216","WTR152","WTR172","WTR056","WTR130","WTR026","WTR066","WTR035","WTR071","WTR109","WTR132","WTR098","WTR003","WTR113"
        },
        -- pack #18 in box #50
        [18] = {
            "WTR200","WTR195","WTR210","WTR223","WTR042","WTR056","WTR009","WTR192","WTR064","WTR022","WTR062","WTR106","WTR148","WTR109","WTR132","WTR224"
        },
        -- pack #19 in box #50
        [19] = {
            "WTR199","WTR205","WTR207","WTR186","WTR158","WTR019","WTR164","WTR041","WTR021","WTR064","WTR031","WTR060","WTR103","WTR136","WTR104","WTR040","WTR001"
        },
        -- pack #20 in box #50
        [20] = {
            "WTR193","WTR209","WTR219","WTR214","WTR156","WTR124","WTR056","WTR110","WTR069","WTR030","WTR066","WTR108","WTR133","WTR101","WTR138","WTR114","WTR115"
        },
        -- pack #21 in box #50
        [21] = {
            "WTR185","WTR184","WTR198","WTR201","WTR153","WTR019","WTR120","WTR187","WTR063","WTR034","WTR062","WTR028","WTR149","WTR106","WTR147","WTR002","WTR077"
        },
        -- pack #22 in box #50
        [22] = {
            "WTR207","WTR200","WTR206","WTR179","WTR117","WTR055","WTR012","WTR209","WTR022","WTR068","WTR022","WTR136","WTR095","WTR147","WTR105","WTR039","WTR001"
        },
        -- pack #23 in box #50
        [23] = {
            "WTR209","WTR193","WTR182","WTR192","WTR155","WTR056","WTR013","WTR181","WTR071","WTR023","WTR062","WTR109","WTR149","WTR102","WTR147","WTR077","WTR115"
        },
        -- pack #24 in box #50
        [24] = {
            "WTR208","WTR196","WTR197","WTR220","WTR153","WTR019","WTR159","WTR093","WTR020","WTR063","WTR036","WTR060","WTR098","WTR137","WTR099","WTR224"
        },
    },
    -- box #51
    [51] = {
        -- pack #1 in box #51
        [1] = {
            "WTR212","WTR207","WTR191","WTR177","WTR042","WTR174","WTR127","WTR137","WTR022","WTR064","WTR022","WTR060","WTR111","WTR135","WTR097","WTR113","WTR038"
        },
        -- pack #2 in box #51
        [2] = {
            "WTR189","WTR181","WTR221","WTR203","WTR117","WTR125","WTR129","WTR142","WTR069","WTR031","WTR068","WTR096","WTR137","WTR111","WTR135","WTR115","WTR078"
        },
        -- pack #3 in box #51
        [3] = {
            "WTR188","WTR194","WTR220","WTR202","WTR117","WTR170","WTR091","WTR108","WTR035","WTR063","WTR022","WTR148","WTR096","WTR147","WTR109","WTR224"
        },
        -- pack #4 in box #51
        [4] = {
            "WTR207","WTR212","WTR185","WTR203","WTR042","WTR174","WTR088","WTR013","WTR069","WTR032","WTR067","WTR101","WTR133","WTR105","WTR146","WTR077","WTR114"
        },
        -- pack #5 in box #51
        [5] = {
            "WTR222","WTR210","WTR192","WTR210","WTR005","WTR017","WTR123","WTR034","WTR021","WTR059","WTR033","WTR067","WTR108","WTR132","WTR109","WTR003","WTR040"
        },
        -- pack #6 in box #51
        [6] = {
            "WTR181","WTR183","WTR185","WTR176","WTR080","WTR056","WTR120","WTR068","WTR068","WTR022","WTR073","WTR112","WTR136","WTR108","WTR134","WTR002","WTR040"
        },
        -- pack #7 in box #51
        [7] = {
            "WTR183","WTR209","WTR205","WTR200","WTR157","WTR175","WTR088","WTR031","WTR069","WTR025","WTR060","WTR103","WTR138","WTR102","WTR135","WTR076","WTR113"
        },
        -- pack #8 in box #51
        [8] = {
            "WTR212","WTR183","WTR186","WTR184","WTR042","WTR172","WTR012","WTR032","WTR074","WTR036","WTR070","WTR033","WTR139","WTR100","WTR149","WTR224"
        },
        -- pack #9 in box #51
        [9] = {
            "WTR213","WTR216","WTR178","WTR191","WTR157","WTR126","WTR047","WTR144","WTR065","WTR030","WTR072","WTR100","WTR137","WTR108","WTR139","WTR115","WTR077"
        },
        -- pack #10 in box #51
        [10] = {
            "WTR188","WTR181","WTR199","WTR197","WTR154","WTR053","WTR127","WTR146","WTR062","WTR021","WTR072","WTR028","WTR138","WTR100","WTR137","WTR039","WTR076"
        },
        -- pack #11 in box #51
        [11] = {
            "WTR190","WTR194","WTR183","WTR190","WTR117","WTR091","WTR128","WTR216","WTR020","WTR072","WTR021","WTR139","WTR098","WTR136","WTR106","WTR113","WTR077"
        },
        -- pack #12 in box #51
        [12] = {
            "WTR218","WTR211","WTR178","WTR214","WTR151","WTR168","WTR088","WTR131","WTR071","WTR036","WTR062","WTR035","WTR145","WTR109","WTR133","WTR114","WTR002"
        },
        -- pack #13 in box #51
        [13] = {
            "WTR219","WTR194","WTR182","WTR198","WTR151","WTR092","WTR130","WTR062","WTR026","WTR069","WTR031","WTR138","WTR100","WTR135","WTR101","WTR040","WTR077"
        },
        -- pack #14 in box #51
        [14] = {
            "WTR209","WTR216","WTR205","WTR185","WTR157","WTR091","WTR015","WTR141","WTR020","WTR067","WTR033","WTR064","WTR100","WTR135","WTR105","WTR039","WTR075"
        },
        -- pack #15 in box #51
        [15] = {
            "WTR207","WTR177","WTR190","WTR176","WTR156","WTR174","WTR013","WTR028","WTR058","WTR027","WTR064","WTR036","WTR146","WTR101","WTR132","WTR076","WTR038"
        },
        -- pack #16 in box #51
        [16] = {
            "WTR210","WTR198","WTR219","WTR221","WTR154","WTR018","WTR131","WTR028","WTR020","WTR067","WTR025","WTR063","WTR111","WTR141","WTR096","WTR115","WTR001"
        },
        -- pack #17 in box #51
        [17] = {
            "WTR182","WTR179","WTR201","WTR184","WTR080","WTR175","WTR084","WTR181","WTR057","WTR022","WTR071","WTR031","WTR143","WTR110","WTR137","WTR078","WTR001"
        },
        -- pack #18 in box #51
        [18] = {
            "WTR192","WTR196","WTR218","WTR199","WTR080","WTR091","WTR128","WTR151","WTR034","WTR064","WTR037","WTR069","WTR098","WTR132","WTR098","WTR077","WTR113"
        },
        -- pack #19 in box #51
        [19] = {
            "WTR213","WTR182","WTR200","WTR222","WTR154","WTR018","WTR125","WTR104","WTR071","WTR026","WTR072","WTR102","WTR148","WTR108","WTR140","WTR003","WTR113"
        },
        -- pack #20 in box #51
        [20] = {
            "WTR203","WTR185","WTR209","WTR183","WTR080","WTR087","WTR130","WTR194","WTR037","WTR072","WTR030","WTR063","WTR104","WTR141","WTR110","WTR113","WTR038"
        },
        -- pack #21 in box #51
        [21] = {
            "WTR207","WTR205","WTR204","WTR192","WTR042","WTR052","WTR013","WTR041","WTR071","WTR025","WTR071","WTR021","WTR139","WTR109","WTR148","WTR040","WTR039"
        },
        -- pack #22 in box #51
        [22] = {
            "WTR208","WTR202","WTR203","WTR180","WTR157","WTR051","WTR056","WTR138","WTR025","WTR066","WTR035","WTR140","WTR104","WTR136","WTR112","WTR224"
        },
        -- pack #23 in box #51
        [23] = {
            "WTR203","WTR217","WTR177","WTR182","WTR157","WTR012","WTR167","WTR101","WTR027","WTR062","WTR031","WTR132","WTR109","WTR132","WTR106","WTR113","WTR076"
        },
        -- pack #24 in box #51
        [24] = {
            "WTR190","WTR201","WTR187","WTR182","WTR152","WTR013","WTR175","WTR157","WTR025","WTR074","WTR020","WTR136","WTR109","WTR134","WTR095","WTR115","WTR002"
        },
    },
    -- box #52
    [52] = {
        -- pack #1 in box #52
        [1] = {
            "WTR176","WTR198","WTR195","WTR192","WTR156","WTR054","WTR093","WTR198","WTR036","WTR061","WTR034","WTR146","WTR112","WTR140","WTR105","WTR075","WTR039"
        },
        -- pack #2 in box #52
        [2] = {
            "WTR185","WTR176","WTR220","WTR186","WTR080","WTR011","WTR124","WTR185","WTR030","WTR065","WTR028","WTR060","WTR100","WTR147","WTR106","WTR003","WTR040"
        },
        -- pack #3 in box #52
        [3] = {
            "WTR192","WTR197","WTR206","WTR203","WTR154","WTR131","WTR119","WTR165","WTR070","WTR022","WTR069","WTR095","WTR139","WTR103","WTR141","WTR038","WTR115"
        },
        -- pack #4 in box #52
        [4] = {
            "WTR205","WTR195","WTR212","WTR176","WTR005","WTR048","WTR046","WTR103","WTR074","WTR024","WTR066","WTR112","WTR148","WTR110","WTR146","WTR224"
        },
        -- pack #5 in box #52
        [5] = {
            "WTR218","WTR201","WTR181","WTR201","WTR080","WTR013","WTR164","WTR203","WTR057","WTR024","WTR071","WTR101","WTR145","WTR110","WTR134","WTR225","WTR113"
        },
        -- pack #6 in box #52
        [6] = {
            "WTR179","WTR214","WTR203","WTR182","WTR156","WTR094","WTR175","WTR037","WTR024","WTR058","WTR034","WTR137","WTR106","WTR143","WTR104","WTR040","WTR114"
        },
        -- pack #7 in box #52
        [7] = {
            "WTR197","WTR193","WTR200","WTR216","WTR042","WTR168","WTR160","WTR222","WTR023","WTR067","WTR031","WTR067","WTR102","WTR140","WTR098","WTR003","WTR225"
        },
        -- pack #8 in box #52
        [8] = {
            "WTR208","WTR181","WTR220","WTR176","WTR156","WTR018","WTR049","WTR138","WTR036","WTR064","WTR036","WTR062","WTR099","WTR139","WTR103","WTR003","WTR078"
        },
        -- pack #9 in box #52
        [9] = {
            "WTR194","WTR209","WTR213","WTR199","WTR152","WTR131","WTR123","WTR034","WTR021","WTR060","WTR032","WTR063","WTR110","WTR145","WTR111","WTR114","WTR076"
        },
        -- pack #10 in box #52
        [10] = {
            "WTR208","WTR188","WTR200","WTR204","WTR151","WTR018","WTR161","WTR143","WTR029","WTR066","WTR028","WTR058","WTR104","WTR145","WTR110","WTR003","WTR038"
        },
        -- pack #11 in box #52
        [11] = {
            "WTR219","WTR198","WTR219","WTR218","WTR042","WTR048","WTR123","WTR193","WTR035","WTR063","WTR026","WTR137","WTR095","WTR145","WTR107","WTR040","WTR077"
        },
        -- pack #12 in box #52
        [12] = {
            "WTR221","WTR177","WTR215","WTR208","WTR042","WTR011","WTR085","WTR108","WTR022","WTR065","WTR025","WTR133","WTR109","WTR141","WTR106","WTR225","WTR003"
        },
        -- pack #13 in box #52
        [13] = {
            "WTR181","WTR199","WTR182","WTR179","WTR005","WTR164","WTR170","WTR192","WTR063","WTR031","WTR071","WTR098","WTR134","WTR098","WTR133","WTR003","WTR113"
        },
        -- pack #14 in box #52
        [14] = {
            "WTR222","WTR189","WTR203","WTR216","WTR157","WTR048","WTR126","WTR108","WTR057","WTR035","WTR063","WTR027","WTR140","WTR096","WTR135","WTR113","WTR225"
        },
        -- pack #15 in box #52
        [15] = {
            "WTR204","WTR221","WTR212","WTR201","WTR117","WTR048","WTR126","WTR071","WTR068","WTR031","WTR074","WTR028","WTR135","WTR096","WTR140","WTR078","WTR040"
        },
        -- pack #16 in box #52
        [16] = {
            "WTR190","WTR178","WTR187","WTR189","WTR155","WTR090","WTR049","WTR213","WTR064","WTR034","WTR065","WTR037","WTR141","WTR112","WTR132","WTR113","WTR114"
        },
        -- pack #17 in box #52
        [17] = {
            "WTR205","WTR180","WTR178","WTR177","WTR154","WTR174","WTR054","WTR096","WTR027","WTR057","WTR036","WTR057","WTR098","WTR141","WTR109","WTR002","WTR075"
        },
        -- pack #18 in box #52
        [18] = {
            "WTR220","WTR215","WTR214","WTR177","WTR155","WTR130","WTR171","WTR103","WTR057","WTR029","WTR061","WTR100","WTR143","WTR101","WTR149","WTR038","WTR075"
        },
        -- pack #19 in box #52
        [19] = {
            "WTR206","WTR201","WTR219","WTR186","WTR156","WTR174","WTR048","WTR012","WTR025","WTR061","WTR037","WTR146","WTR105","WTR140","WTR096","WTR075","WTR003"
        },
        -- pack #20 in box #52
        [20] = {
            "WTR217","WTR177","WTR198","WTR216","WTR151","WTR128","WTR170","WTR145","WTR067","WTR026","WTR059","WTR099","WTR149","WTR104","WTR148","WTR003","WTR113"
        },
        -- pack #21 in box #52
        [21] = {
            "WTR211","WTR220","WTR205","WTR177","WTR153","WTR167","WTR087","WTR221","WTR065","WTR031","WTR061","WTR024","WTR132","WTR107","WTR134","WTR115","WTR078"
        },
        -- pack #22 in box #52
        [22] = {
            "WTR205","WTR202","WTR179","WTR192","WTR151","WTR086","WTR168","WTR188","WTR061","WTR036","WTR069","WTR027","WTR148","WTR098","WTR137","WTR038","WTR076"
        },
        -- pack #23 in box #52
        [23] = {
            "WTR196","WTR217","WTR199","WTR184","WTR005","WTR014","WTR169","WTR021","WTR061","WTR033","WTR061","WTR020","WTR142","WTR112","WTR137","WTR077","WTR040"
        },
        -- pack #24 in box #52
        [24] = {
            "WTR206","WTR212","WTR185","WTR209","WTR005","WTR093","WTR164","WTR097","WTR025","WTR066","WTR029","WTR140","WTR099","WTR133","WTR111","WTR114","WTR225"
        },
    },
    -- box #53
    [53] = {
        -- pack #1 in box #53
        [1] = {
            "WTR178","WTR212","WTR202","WTR177","WTR156","WTR015","WTR085","WTR112","WTR027","WTR069","WTR034","WTR138","WTR098","WTR138","WTR098","WTR115","WTR076"
        },
        -- pack #2 in box #53
        [2] = {
            "WTR218","WTR181","WTR195","WTR217","WTR117","WTR167","WTR056","WTR198","WTR028","WTR062","WTR037","WTR064","WTR103","WTR138","WTR108","WTR114","WTR115"
        },
        -- pack #3 in box #53
        [3] = {
            "WTR212","WTR211","WTR177","WTR176","WTR152","WTR171","WTR050","WTR050","WTR060","WTR030","WTR062","WTR035","WTR142","WTR102","WTR142","WTR077","WTR113"
        },
        -- pack #4 in box #53
        [4] = {
            "WTR220","WTR178","WTR192","WTR195","WTR156","WTR127","WTR050","WTR034","WTR033","WTR063","WTR034","WTR138","WTR103","WTR145","WTR096","WTR078","WTR003"
        },
        -- pack #5 in box #53
        [5] = {
            "WTR204","WTR192","WTR206","WTR192","WTR080","WTR127","WTR123","WTR190","WTR064","WTR024","WTR074","WTR103","WTR132","WTR103","WTR137","WTR040","WTR113"
        },
        -- pack #6 in box #53
        [6] = {
            "WTR199","WTR219","WTR221","WTR191","WTR042","WTR127","WTR056","WTR028","WTR027","WTR072","WTR032","WTR148","WTR104","WTR144","WTR100","WTR040","WTR003"
        },
        -- pack #7 in box #53
        [7] = {
            "WTR211","WTR222","WTR198","WTR195","WTR155","WTR018","WTR125","WTR138","WTR065","WTR027","WTR060","WTR109","WTR142","WTR106","WTR135","WTR002","WTR039"
        },
        -- pack #8 in box #53
        [8] = {
            "WTR222","WTR200","WTR178","WTR189","WTR154","WTR164","WTR163","WTR202","WTR067","WTR020","WTR066","WTR112","WTR144","WTR110","WTR134","WTR225","WTR115"
        },
        -- pack #9 in box #53
        [9] = {
            "WTR213","WTR210","WTR190","WTR183","WTR042","WTR129","WTR168","WTR060","WTR033","WTR067","WTR033","WTR068","WTR103","WTR141","WTR109","WTR040","WTR002"
        },
        -- pack #10 in box #53
        [10] = {
            "WTR220","WTR190","WTR218","WTR201","WTR156","WTR170","WTR044","WTR019","WTR021","WTR059","WTR029","WTR145","WTR111","WTR143","WTR106","WTR002","WTR040"
        },
        -- pack #11 in box #53
        [11] = {
            "WTR204","WTR220","WTR198","WTR176","WTR152","WTR168","WTR084","WTR035","WTR037","WTR071","WTR033","WTR147","WTR099","WTR139","WTR106","WTR077","WTR113"
        },
        -- pack #12 in box #53
        [12] = {
            "WTR197","WTR188","WTR190","WTR191","WTR153","WTR129","WTR081","WTR186","WTR023","WTR073","WTR036","WTR132","WTR098","WTR132","WTR105","WTR003","WTR039"
        },
        -- pack #13 in box #53
        [13] = {
            "WTR220","WTR177","WTR216","WTR211","WTR005","WTR012","WTR092","WTR206","WTR057","WTR031","WTR063","WTR028","WTR140","WTR105","WTR134","WTR076","WTR075"
        },
        -- pack #14 in box #53
        [14] = {
            "WTR205","WTR197","WTR202","WTR207","WTR042","WTR127","WTR006","WTR219","WTR072","WTR022","WTR059","WTR034","WTR140","WTR109","WTR141","WTR113","WTR003"
        },
        -- pack #15 in box #53
        [15] = {
            "WTR182","WTR202","WTR216","WTR205","WTR157","WTR051","WTR121","WTR099","WTR037","WTR057","WTR033","WTR057","WTR101","WTR138","WTR097","WTR001","WTR113"
        },
        -- pack #16 in box #53
        [16] = {
            "WTR211","WTR184","WTR209","WTR191","WTR156","WTR169","WTR010","WTR090","WTR060","WTR034","WTR061","WTR095","WTR149","WTR109","WTR137","WTR224"
        },
        -- pack #17 in box #53
        [17] = {
            "WTR202","WTR181","WTR193","WTR178","WTR153","WTR054","WTR124","WTR116","WTR027","WTR058","WTR021","WTR062","WTR097","WTR134","WTR110","WTR001","WTR002"
        },
        -- pack #18 in box #53
        [18] = {
            "WTR202","WTR179","WTR202","WTR177","WTR117","WTR094","WTR016","WTR066","WTR034","WTR063","WTR024","WTR069","WTR106","WTR136","WTR099","WTR002","WTR075"
        },
        -- pack #19 in box #53
        [19] = {
            "WTR217","WTR180","WTR183","WTR219","WTR157","WTR051","WTR085","WTR146","WTR069","WTR027","WTR064","WTR030","WTR142","WTR112","WTR133","WTR001","WTR115"
        },
        -- pack #20 in box #53
        [20] = {
            "WTR186","WTR213","WTR201","WTR214","WTR042","WTR173","WTR008","WTR086","WTR060","WTR027","WTR059","WTR102","WTR136","WTR108","WTR141","WTR002","WTR003"
        },
        -- pack #21 in box #53
        [21] = {
            "WTR222","WTR208","WTR182","WTR215","WTR154","WTR131","WTR167","WTR143","WTR068","WTR023","WTR066","WTR024","WTR134","WTR103","WTR145","WTR075","WTR038"
        },
        -- pack #22 in box #53
        [22] = {
            "WTR182","WTR216","WTR219","WTR209","WTR151","WTR174","WTR019","WTR060","WTR030","WTR064","WTR031","WTR074","WTR104","WTR137","WTR112","WTR039","WTR040"
        },
        -- pack #23 in box #53
        [23] = {
            "WTR198","WTR216","WTR196","WTR210","WTR005","WTR018","WTR089","WTR187","WTR064","WTR026","WTR069","WTR111","WTR138","WTR103","WTR143","WTR001","WTR113"
        },
        -- pack #24 in box #53
        [24] = {
            "WTR194","WTR211","WTR199","WTR179","WTR154","WTR090","WTR090","WTR182","WTR068","WTR035","WTR071","WTR024","WTR133","WTR099","WTR134","WTR040","WTR077"
        },
    },
    -- box #54
    [54] = {
        -- pack #1 in box #54
        [1] = {
            "WTR186","WTR221","WTR206","WTR218","WTR154","WTR165","WTR173","WTR020","WTR032","WTR073","WTR030","WTR070","WTR103","WTR137","WTR099","WTR038","WTR002"
        },
        -- pack #2 in box #54
        [2] = {
            "WTR176","WTR178","WTR209","WTR198","WTR153","WTR090","WTR013","WTR149","WTR073","WTR034","WTR073","WTR022","WTR132","WTR111","WTR146","WTR078","WTR113"
        },
        -- pack #3 in box #54
        [3] = {
            "WTR206","WTR191","WTR183","WTR219","WTR042","WTR056","WTR048","WTR086","WTR070","WTR031","WTR073","WTR098","WTR145","WTR096","WTR139","WTR075","WTR114"
        },
        -- pack #4 in box #54
        [4] = {
            "WTR203","WTR199","WTR187","WTR178","WTR158","WTR054","WTR085","WTR022","WTR020","WTR064","WTR023","WTR148","WTR110","WTR143","WTR102","WTR076","WTR077"
        },
        -- pack #5 in box #54
        [5] = {
            "WTR205","WTR186","WTR209","WTR199","WTR152","WTR171","WTR018","WTR154","WTR069","WTR025","WTR064","WTR096","WTR132","WTR104","WTR139","WTR113","WTR003"
        },
        -- pack #6 in box #54
        [6] = {
            "WTR220","WTR197","WTR178","WTR184","WTR153","WTR019","WTR092","WTR073","WTR026","WTR058","WTR025","WTR140","WTR109","WTR138","WTR106","WTR039","WTR225"
        },
        -- pack #7 in box #54
        [7] = {
            "WTR203","WTR195","WTR186","WTR207","WTR151","WTR124","WTR007","WTR178","WTR070","WTR022","WTR065","WTR033","WTR147","WTR106","WTR146","WTR039","WTR075"
        },
        -- pack #8 in box #54
        [8] = {
            "WTR218","WTR207","WTR196","WTR189","WTR117","WTR015","WTR014","WTR070","WTR058","WTR034","WTR058","WTR029","WTR135","WTR107","WTR148","WTR002","WTR115"
        },
        -- pack #9 in box #54
        [9] = {
            "WTR192","WTR193","WTR218","WTR182","WTR042","WTR170","WTR009","WTR136","WTR024","WTR061","WTR024","WTR138","WTR105","WTR139","WTR099","WTR078","WTR077"
        },
        -- pack #10 in box #54
        [10] = {
            "WTR205","WTR186","WTR177","WTR188","WTR158","WTR011","WTR054","WTR178","WTR072","WTR031","WTR073","WTR112","WTR133","WTR111","WTR139","WTR038","WTR078"
        },
        -- pack #11 in box #54
        [11] = {
            "WTR187","WTR185","WTR218","WTR203","WTR042","WTR090","WTR094","WTR221","WTR068","WTR032","WTR066","WTR095","WTR142","WTR095","WTR145","WTR115","WTR039"
        },
        -- pack #12 in box #54
        [12] = {
            "WTR195","WTR216","WTR217","WTR196","WTR155","WTR164","WTR052","WTR214","WTR029","WTR064","WTR021","WTR072","WTR109","WTR139","WTR105","WTR077","WTR075"
        },
        -- pack #13 in box #54
        [13] = {
            "WTR195","WTR196","WTR208","WTR191","WTR005","WTR173","WTR174","WTR069","WTR034","WTR063","WTR026","WTR132","WTR104","WTR146","WTR108","WTR113","WTR038"
        },
        -- pack #14 in box #54
        [14] = {
            "WTR183","WTR213","WTR177","WTR193","WTR158","WTR093","WTR056","WTR004","WTR032","WTR069","WTR032","WTR142","WTR098","WTR148","WTR099","WTR078","WTR038"
        },
        -- pack #15 in box #54
        [15] = {
            "WTR192","WTR222","WTR218","WTR183","WTR117","WTR170","WTR173","WTR166","WTR029","WTR064","WTR029","WTR136","WTR104","WTR139","WTR096","WTR003","WTR075"
        },
        -- pack #16 in box #54
        [16] = {
            "WTR187","WTR181","WTR181","WTR217","WTR151","WTR092","WTR019","WTR197","WTR063","WTR036","WTR071","WTR030","WTR135","WTR095","WTR138","WTR114","WTR115"
        },
        -- pack #17 in box #54
        [17] = {
            "WTR209","WTR181","WTR193","WTR202","WTR080","WTR094","WTR173","WTR220","WTR034","WTR065","WTR023","WTR057","WTR098","WTR146","WTR111","WTR040","WTR001"
        },
        -- pack #18 in box #54
        [18] = {
            "WTR201","WTR209","WTR196","WTR202","WTR153","WTR049","WTR048","WTR199","WTR059","WTR032","WTR061","WTR096","WTR149","WTR107","WTR137","WTR038","WTR075"
        },
        -- pack #19 in box #54
        [19] = {
            "WTR222","WTR195","WTR198","WTR201","WTR153","WTR019","WTR122","WTR026","WTR028","WTR067","WTR036","WTR063","WTR101","WTR138","WTR098","WTR078","WTR002"
        },
        -- pack #20 in box #54
        [20] = {
            "WTR213","WTR181","WTR191","WTR222","WTR157","WTR167","WTR126","WTR195","WTR072","WTR020","WTR073","WTR023","WTR148","WTR107","WTR145","WTR003","WTR113"
        },
        -- pack #21 in box #54
        [21] = {
            "WTR190","WTR194","WTR203","WTR199","WTR153","WTR123","WTR053","WTR134","WTR023","WTR065","WTR025","WTR073","WTR101","WTR143","WTR100","WTR224"
        },
        -- pack #22 in box #54
        [22] = {
            "WTR183","WTR222","WTR207","WTR188","WTR154","WTR048","WTR171","WTR110","WTR064","WTR025","WTR069","WTR110","WTR139","WTR101","WTR134","WTR076","WTR003"
        },
        -- pack #23 in box #54
        [23] = {
            "WTR202","WTR219","WTR182","WTR203","WTR154","WTR051","WTR163","WTR042","WTR031","WTR060","WTR025","WTR057","WTR111","WTR143","WTR108","WTR075","WTR076"
        },
        -- pack #24 in box #54
        [24] = {
            "WTR217","WTR218","WTR195","WTR194","WTR154","WTR053","WTR011","WTR024","WTR072","WTR028","WTR072","WTR024","WTR147","WTR108","WTR137","WTR002","WTR076"
        },
    },
    -- box #55
    [55] = {
        -- pack #1 in box #55
        [1] = {
            "WTR180","WTR179","WTR181","WTR186","WTR042","WTR127","WTR087","WTR066","WTR029","WTR063","WTR033","WTR141","WTR095","WTR146","WTR101","WTR003","WTR078"
        },
        -- pack #2 in box #55
        [2] = {
            "WTR197","WTR184","WTR195","WTR216","WTR042","WTR175","WTR088","WTR168","WTR036","WTR060","WTR036","WTR063","WTR099","WTR132","WTR110","WTR114","WTR003"
        },
        -- pack #3 in box #55
        [3] = {
            "WTR221","WTR200","WTR218","WTR179","WTR157","WTR128","WTR131","WTR145","WTR065","WTR022","WTR058","WTR025","WTR132","WTR109","WTR139","WTR001","WTR039"
        },
        -- pack #4 in box #55
        [4] = {
            "WTR221","WTR192","WTR211","WTR216","WTR005","WTR124","WTR043","WTR000","WTR027","WTR058","WTR027","WTR071","WTR107","WTR148","WTR098","WTR077","WTR001"
        },
        -- pack #5 in box #55
        [5] = {
            "WTR203","WTR206","WTR208","WTR205","WTR080","WTR048","WTR174","WTR172","WTR059","WTR034","WTR069","WTR102","WTR143","WTR108","WTR135","WTR077","WTR039"
        },
        -- pack #6 in box #55
        [6] = {
            "WTR182","WTR192","WTR182","WTR219","WTR156","WTR127","WTR093","WTR220","WTR061","WTR036","WTR063","WTR104","WTR148","WTR103","WTR137","WTR075","WTR115"
        },
        -- pack #7 in box #55
        [7] = {
            "WTR203","WTR190","WTR211","WTR194","WTR154","WTR170","WTR161","WTR027","WTR065","WTR026","WTR072","WTR033","WTR147","WTR098","WTR149","WTR115","WTR075"
        },
        -- pack #8 in box #55
        [8] = {
            "WTR183","WTR178","WTR200","WTR199","WTR151","WTR050","WTR050","WTR145","WTR063","WTR029","WTR067","WTR037","WTR145","WTR095","WTR132","WTR040","WTR114"
        },
        -- pack #9 in box #55
        [9] = {
            "WTR211","WTR178","WTR216","WTR211","WTR156","WTR166","WTR084","WTR209","WTR020","WTR069","WTR036","WTR059","WTR111","WTR144","WTR106","WTR039","WTR001"
        },
        -- pack #10 in box #55
        [10] = {
            "WTR179","WTR214","WTR185","WTR207","WTR152","WTR164","WTR011","WTR133","WTR068","WTR023","WTR067","WTR106","WTR136","WTR101","WTR136","WTR224"
        },
        -- pack #11 in box #55
        [11] = {
            "WTR198","WTR196","WTR192","WTR208","WTR152","WTR015","WTR087","WTR188","WTR061","WTR035","WTR062","WTR036","WTR135","WTR111","WTR149","WTR040","WTR002"
        },
        -- pack #12 in box #55
        [12] = {
            "WTR179","WTR221","WTR214","WTR223","WTR153","WTR167","WTR016","WTR056","WTR030","WTR074","WTR020","WTR132","WTR103","WTR149","WTR095","WTR075","WTR076"
        },
        -- pack #13 in box #55
        [13] = {
            "WTR182","WTR215","WTR206","WTR182","WTR152","WTR171","WTR171","WTR026","WTR025","WTR064","WTR033","WTR148","WTR106","WTR141","WTR105","WTR003","WTR114"
        },
        -- pack #14 in box #55
        [14] = {
            "WTR188","WTR216","WTR198","WTR193","WTR152","WTR087","WTR055","WTR130","WTR027","WTR063","WTR026","WTR065","WTR097","WTR149","WTR109","WTR001","WTR078"
        },
        -- pack #15 in box #55
        [15] = {
            "WTR217","WTR180","WTR183","WTR196","WTR005","WTR175","WTR056","WTR208","WTR034","WTR072","WTR022","WTR064","WTR106","WTR134","WTR107","WTR078","WTR115"
        },
        -- pack #16 in box #55
        [16] = {
            "WTR190","WTR186","WTR218","WTR180","WTR154","WTR090","WTR053","WTR058","WTR021","WTR069","WTR036","WTR145","WTR104","WTR147","WTR102","WTR075","WTR225"
        },
        -- pack #17 in box #55
        [17] = {
            "WTR202","WTR220","WTR186","WTR191","WTR156","WTR164","WTR054","WTR098","WTR058","WTR033","WTR074","WTR026","WTR144","WTR111","WTR147","WTR076","WTR002"
        },
        -- pack #18 in box #55
        [18] = {
            "WTR194","WTR182","WTR185","WTR216","WTR153","WTR093","WTR168","WTR191","WTR062","WTR031","WTR071","WTR022","WTR146","WTR101","WTR144","WTR002","WTR040"
        },
        -- pack #19 in box #55
        [19] = {
            "WTR213","WTR192","WTR199","WTR177","WTR157","WTR089","WTR088","WTR030","WTR066","WTR022","WTR066","WTR105","WTR146","WTR097","WTR145","WTR077","WTR115"
        },
        -- pack #20 in box #55
        [20] = {
            "WTR179","WTR221","WTR195","WTR194","WTR117","WTR168","WTR166","WTR073","WTR021","WTR064","WTR021","WTR065","WTR106","WTR149","WTR101","WTR003","WTR115"
        },
        -- pack #21 in box #55
        [21] = {
            "WTR185","WTR181","WTR177","WTR191","WTR005","WTR018","WTR168","WTR206","WTR036","WTR071","WTR027","WTR138","WTR107","WTR143","WTR096","WTR039","WTR113"
        },
        -- pack #22 in box #55
        [22] = {
            "WTR204","WTR184","WTR178","WTR215","WTR152","WTR014","WTR093","WTR035","WTR072","WTR023","WTR057","WTR105","WTR147","WTR106","WTR146","WTR002","WTR001"
        },
        -- pack #23 in box #55
        [23] = {
            "WTR212","WTR223","WTR202","WTR192","WTR156","WTR128","WTR013","WTR199","WTR022","WTR070","WTR027","WTR148","WTR112","WTR138","WTR097","WTR114","WTR040"
        },
        -- pack #24 in box #55
        [24] = {
            "WTR186","WTR180","WTR199","WTR213","WTR157","WTR129","WTR091","WTR169","WTR059","WTR031","WTR060","WTR112","WTR144","WTR101","WTR138","WTR002","WTR077"
        },
    },
    -- box #56
    [56] = {
        -- pack #1 in box #56
        [1] = {
            "WTR191","WTR204","WTR187","WTR189","WTR117","WTR049","WTR011","WTR029","WTR065","WTR034","WTR066","WTR024","WTR136","WTR106","WTR139","WTR001","WTR225"
        },
        -- pack #2 in box #56
        [2] = {
            "WTR196","WTR186","WTR217","WTR202","WTR155","WTR050","WTR009","WTR054","WTR069","WTR020","WTR060","WTR109","WTR132","WTR095","WTR140","WTR040","WTR038"
        },
        -- pack #3 in box #56
        [3] = {
            "WTR220","WTR176","WTR191","WTR222","WTR153","WTR129","WTR119","WTR025","WTR029","WTR072","WTR032","WTR134","WTR099","WTR136","WTR111","WTR224"
        },
        -- pack #4 in box #56
        [4] = {
            "WTR197","WTR195","WTR215","WTR181","WTR153","WTR173","WTR008","WTR191","WTR021","WTR068","WTR027","WTR072","WTR111","WTR140","WTR096","WTR003","WTR114"
        },
        -- pack #5 in box #56
        [5] = {
            "WTR186","WTR206","WTR181","WTR193","WTR158","WTR167","WTR087","WTR099","WTR072","WTR034","WTR070","WTR095","WTR137","WTR107","WTR145","WTR113","WTR001"
        },
        -- pack #6 in box #56
        [6] = {
            "WTR223","WTR192","WTR185","WTR216","WTR155","WTR088","WTR093","WTR223","WTR071","WTR026","WTR073","WTR024","WTR133","WTR105","WTR144","WTR078","WTR038"
        },
        -- pack #7 in box #56
        [7] = {
            "WTR211","WTR191","WTR188","WTR194","WTR156","WTR055","WTR164","WTR124","WTR031","WTR061","WTR026","WTR074","WTR103","WTR141","WTR103","WTR076","WTR003"
        },
        -- pack #8 in box #56
        [8] = {
            "WTR187","WTR221","WTR205","WTR189","WTR152","WTR086","WTR118","WTR202","WTR028","WTR074","WTR021","WTR061","WTR110","WTR138","WTR104","WTR076","WTR002"
        },
        -- pack #9 in box #56
        [9] = {
            "WTR206","WTR210","WTR194","WTR178","WTR005","WTR089","WTR082","WTR016","WTR037","WTR062","WTR023","WTR069","WTR096","WTR134","WTR112","WTR075","WTR003"
        },
        -- pack #10 in box #56
        [10] = {
            "WTR203","WTR215","WTR213","WTR190","WTR005","WTR013","WTR050","WTR042","WTR064","WTR035","WTR073","WTR024","WTR136","WTR103","WTR144","WTR113","WTR075"
        },
        -- pack #11 in box #56
        [11] = {
            "WTR222","WTR188","WTR221","WTR199","WTR155","WTR091","WTR082","WTR101","WTR037","WTR057","WTR024","WTR149","WTR096","WTR140","WTR104","WTR113","WTR078"
        },
        -- pack #12 in box #56
        [12] = {
            "WTR186","WTR190","WTR205","WTR221","WTR080","WTR052","WTR008","WTR186","WTR062","WTR037","WTR057","WTR022","WTR140","WTR100","WTR141","WTR076","WTR001"
        },
        -- pack #13 in box #56
        [13] = {
            "WTR207","WTR193","WTR216","WTR219","WTR117","WTR129","WTR016","WTR182","WTR037","WTR071","WTR023","WTR071","WTR104","WTR143","WTR110","WTR077","WTR076"
        },
        -- pack #14 in box #56
        [14] = {
            "WTR179","WTR221","WTR205","WTR200","WTR042","WTR091","WTR166","WTR025","WTR067","WTR036","WTR069","WTR107","WTR139","WTR110","WTR137","WTR078","WTR001"
        },
        -- pack #15 in box #56
        [15] = {
            "WTR196","WTR206","WTR209","WTR197","WTR080","WTR164","WTR127","WTR176","WTR035","WTR070","WTR035","WTR139","WTR103","WTR143","WTR106","WTR113","WTR225"
        },
        -- pack #16 in box #56
        [16] = {
            "WTR203","WTR198","WTR193","WTR204","WTR042","WTR170","WTR122","WTR182","WTR021","WTR058","WTR022","WTR139","WTR103","WTR137","WTR099","WTR114","WTR038"
        },
        -- pack #17 in box #56
        [17] = {
            "WTR177","WTR196","WTR190","WTR178","WTR156","WTR089","WTR055","WTR061","WTR023","WTR061","WTR030","WTR146","WTR105","WTR135","WTR107","WTR038","WTR115"
        },
        -- pack #18 in box #56
        [18] = {
            "WTR180","WTR206","WTR192","WTR223","WTR152","WTR093","WTR161","WTR178","WTR061","WTR028","WTR065","WTR099","WTR140","WTR102","WTR143","WTR039","WTR076"
        },
        -- pack #19 in box #56
        [19] = {
            "WTR200","WTR188","WTR215","WTR181","WTR153","WTR127","WTR122","WTR058","WTR023","WTR066","WTR025","WTR074","WTR107","WTR135","WTR105","WTR001","WTR002"
        },
        -- pack #20 in box #56
        [20] = {
            "WTR193","WTR221","WTR188","WTR206","WTR154","WTR174","WTR015","WTR081","WTR060","WTR020","WTR067","WTR033","WTR143","WTR107","WTR145","WTR075","WTR038"
        },
        -- pack #21 in box #56
        [21] = {
            "WTR204","WTR213","WTR212","WTR205","WTR151","WTR017","WTR127","WTR136","WTR059","WTR026","WTR074","WTR109","WTR137","WTR107","WTR145","WTR002","WTR003"
        },
        -- pack #22 in box #56
        [22] = {
            "WTR217","WTR200","WTR216","WTR201","WTR157","WTR019","WTR169","WTR100","WTR063","WTR023","WTR074","WTR020","WTR132","WTR103","WTR140","WTR039","WTR038"
        },
        -- pack #23 in box #56
        [23] = {
            "WTR197","WTR196","WTR201","WTR213","WTR117","WTR126","WTR056","WTR092","WTR068","WTR027","WTR058","WTR098","WTR139","WTR105","WTR145","WTR077","WTR225"
        },
        -- pack #24 in box #56
        [24] = {
            "WTR197","WTR212","WTR200","WTR189","WTR005","WTR164","WTR015","WTR065","WTR029","WTR072","WTR022","WTR134","WTR111","WTR140","WTR101","WTR078","WTR039"
        },
    },
    -- box #57
    [57] = {
        -- pack #1 in box #57
        [1] = {
            "WTR209","WTR177","WTR193","WTR201","WTR158","WTR175","WTR171","WTR036","WTR035","WTR069","WTR020","WTR145","WTR108","WTR144","WTR103","WTR075","WTR076"
        },
        -- pack #2 in box #57
        [2] = {
            "WTR180","WTR187","WTR216","WTR176","WTR117","WTR049","WTR089","WTR028","WTR027","WTR070","WTR022","WTR071","WTR105","WTR138","WTR099","WTR040","WTR114"
        },
        -- pack #3 in box #57
        [3] = {
            "WTR185","WTR199","WTR193","WTR222","WTR156","WTR125","WTR092","WTR068","WTR020","WTR058","WTR035","WTR062","WTR112","WTR135","WTR109","WTR001","WTR078"
        },
        -- pack #4 in box #57
        [4] = {
            "WTR210","WTR188","WTR178","WTR193","WTR156","WTR015","WTR159","WTR109","WTR031","WTR069","WTR033","WTR073","WTR107","WTR139","WTR111","WTR040","WTR078"
        },
        -- pack #5 in box #57
        [5] = {
            "WTR217","WTR185","WTR198","WTR206","WTR005","WTR086","WTR048","WTR049","WTR022","WTR062","WTR037","WTR141","WTR109","WTR141","WTR110","WTR225","WTR114"
        },
        -- pack #6 in box #57
        [6] = {
            "WTR187","WTR194","WTR209","WTR209","WTR158","WTR011","WTR018","WTR005","WTR064","WTR033","WTR067","WTR023","WTR146","WTR111","WTR146","WTR224"
        },
        -- pack #7 in box #57
        [7] = {
            "WTR222","WTR209","WTR198","WTR206","WTR151","WTR089","WTR018","WTR131","WTR032","WTR058","WTR020","WTR063","WTR097","WTR139","WTR110","WTR224"
        },
        -- pack #8 in box #57
        [8] = {
            "WTR188","WTR204","WTR188","WTR215","WTR155","WTR170","WTR010","WTR193","WTR034","WTR068","WTR029","WTR070","WTR095","WTR135","WTR096","WTR076","WTR113"
        },
        -- pack #9 in box #57
        [9] = {
            "WTR177","WTR204","WTR192","WTR211","WTR154","WTR016","WTR174","WTR206","WTR026","WTR060","WTR035","WTR147","WTR110","WTR136","WTR101","WTR113","WTR115"
        },
        -- pack #10 in box #57
        [10] = {
            "WTR210","WTR179","WTR198","WTR180","WTR152","WTR014","WTR082","WTR180","WTR057","WTR030","WTR058","WTR033","WTR149","WTR107","WTR149","WTR039","WTR114"
        },
        -- pack #11 in box #57
        [11] = {
            "WTR196","WTR199","WTR189","WTR189","WTR156","WTR130","WTR051","WTR053","WTR065","WTR023","WTR067","WTR108","WTR140","WTR100","WTR144","WTR115","WTR114"
        },
        -- pack #12 in box #57
        [12] = {
            "WTR199","WTR198","WTR221","WTR192","WTR042","WTR088","WTR049","WTR050","WTR028","WTR071","WTR034","WTR137","WTR109","WTR132","WTR110","WTR039","WTR002"
        },
        -- pack #13 in box #57
        [13] = {
            "WTR216","WTR219","WTR179","WTR220","WTR158","WTR094","WTR085","WTR199","WTR067","WTR025","WTR074","WTR109","WTR138","WTR095","WTR146","WTR115","WTR038"
        },
        -- pack #14 in box #57
        [14] = {
            "WTR184","WTR191","WTR197","WTR182","WTR155","WTR166","WTR048","WTR060","WTR064","WTR023","WTR071","WTR110","WTR138","WTR106","WTR140","WTR038","WTR076"
        },
        -- pack #15 in box #57
        [15] = {
            "WTR201","WTR210","WTR211","WTR178","WTR042","WTR054","WTR173","WTR102","WTR058","WTR029","WTR067","WTR097","WTR145","WTR111","WTR136","WTR077","WTR114"
        },
        -- pack #16 in box #57
        [16] = {
            "WTR208","WTR220","WTR220","WTR185","WTR151","WTR168","WTR161","WTR027","WTR072","WTR020","WTR066","WTR028","WTR135","WTR096","WTR133","WTR115","WTR002"
        },
        -- pack #17 in box #57
        [17] = {
            "WTR214","WTR178","WTR200","WTR209","WTR158","WTR012","WTR086","WTR187","WTR025","WTR058","WTR037","WTR060","WTR101","WTR148","WTR105","WTR113","WTR115"
        },
        -- pack #18 in box #57
        [18] = {
            "WTR223","WTR220","WTR214","WTR193","WTR117","WTR089","WTR174","WTR216","WTR067","WTR023","WTR059","WTR028","WTR133","WTR112","WTR143","WTR077","WTR225"
        },
        -- pack #19 in box #57
        [19] = {
            "WTR191","WTR188","WTR181","WTR210","WTR152","WTR126","WTR120","WTR018","WTR023","WTR074","WTR035","WTR134","WTR110","WTR146","WTR101","WTR002","WTR003"
        },
        -- pack #20 in box #57
        [20] = {
            "WTR190","WTR194","WTR215","WTR186","WTR155","WTR166","WTR054","WTR139","WTR073","WTR022","WTR059","WTR037","WTR134","WTR107","WTR147","WTR114","WTR039"
        },
        -- pack #21 in box #57
        [21] = {
            "WTR222","WTR189","WTR195","WTR193","WTR158","WTR131","WTR006","WTR084","WTR029","WTR074","WTR029","WTR132","WTR106","WTR139","WTR101","WTR115","WTR039"
        },
        -- pack #22 in box #57
        [22] = {
            "WTR182","WTR188","WTR196","WTR214","WTR005","WTR017","WTR089","WTR144","WTR060","WTR034","WTR068","WTR100","WTR147","WTR109","WTR143","WTR039","WTR001"
        },
        -- pack #23 in box #57
        [23] = {
            "WTR181","WTR179","WTR222","WTR207","WTR152","WTR014","WTR174","WTR110","WTR072","WTR033","WTR073","WTR095","WTR141","WTR100","WTR145","WTR040","WTR078"
        },
        -- pack #24 in box #57
        [24] = {
            "WTR201","WTR191","WTR191","WTR190","WTR154","WTR086","WTR118","WTR096","WTR073","WTR037","WTR072","WTR022","WTR137","WTR109","WTR134","WTR077","WTR113"
        },
    },
    -- box #58
    [58] = {
        -- pack #1 in box #58
        [1] = {
            "WTR197","WTR183","WTR188","WTR191","WTR151","WTR053","WTR164","WTR073","WTR066","WTR034","WTR058","WTR031","WTR148","WTR097","WTR144","WTR001","WTR078"
        },
        -- pack #2 in box #58
        [2] = {
            "WTR191","WTR199","WTR222","WTR222","WTR155","WTR049","WTR055","WTR156","WTR029","WTR069","WTR024","WTR067","WTR112","WTR144","WTR104","WTR115","WTR113"
        },
        -- pack #3 in box #58
        [3] = {
            "WTR200","WTR176","WTR191","WTR191","WTR157","WTR055","WTR173","WTR046","WTR061","WTR022","WTR068","WTR101","WTR132","WTR103","WTR138","WTR001","WTR078"
        },
        -- pack #4 in box #58
        [4] = {
            "WTR190","WTR196","WTR221","WTR196","WTR157","WTR167","WTR130","WTR074","WTR074","WTR024","WTR063","WTR105","WTR148","WTR104","WTR149","WTR038","WTR075"
        },
        -- pack #5 in box #58
        [5] = {
            "WTR209","WTR192","WTR200","WTR180","WTR158","WTR049","WTR175","WTR140","WTR035","WTR065","WTR023","WTR071","WTR100","WTR142","WTR109","WTR078","WTR075"
        },
        -- pack #6 in box #58
        [6] = {
            "WTR184","WTR197","WTR198","WTR204","WTR042","WTR015","WTR159","WTR213","WTR072","WTR027","WTR064","WTR034","WTR148","WTR097","WTR141","WTR224"
        },
        -- pack #7 in box #58
        [7] = {
            "WTR206","WTR207","WTR199","WTR198","WTR151","WTR019","WTR127","WTR156","WTR036","WTR059","WTR027","WTR064","WTR110","WTR133","WTR107","WTR076","WTR002"
        },
        -- pack #8 in box #58
        [8] = {
            "WTR208","WTR177","WTR209","WTR222","WTR152","WTR013","WTR090","WTR142","WTR064","WTR020","WTR069","WTR021","WTR144","WTR100","WTR132","WTR075","WTR003"
        },
        -- pack #9 in box #58
        [9] = {
            "WTR181","WTR193","WTR223","WTR206","WTR152","WTR172","WTR094","WTR155","WTR030","WTR067","WTR032","WTR074","WTR095","WTR141","WTR099","WTR040","WTR039"
        },
        -- pack #10 in box #58
        [10] = {
            "WTR213","WTR177","WTR179","WTR195","WTR155","WTR051","WTR129","WTR127","WTR067","WTR031","WTR064","WTR100","WTR145","WTR099","WTR140","WTR002","WTR113"
        },
        -- pack #11 in box #58
        [11] = {
            "WTR180","WTR205","WTR192","WTR222","WTR151","WTR016","WTR083","WTR216","WTR033","WTR058","WTR020","WTR149","WTR104","WTR146","WTR111","WTR001","WTR225"
        },
        -- pack #12 in box #58
        [12] = {
            "WTR222","WTR212","WTR205","WTR184","WTR154","WTR088","WTR008","WTR176","WTR068","WTR035","WTR070","WTR108","WTR147","WTR112","WTR135","WTR113","WTR225"
        },
        -- pack #13 in box #58
        [13] = {
            "WTR221","WTR221","WTR206","WTR184","WTR080","WTR094","WTR017","WTR117","WTR020","WTR058","WTR036","WTR144","WTR103","WTR139","WTR106","WTR224"
        },
        -- pack #14 in box #58
        [14] = {
            "WTR188","WTR209","WTR188","WTR217","WTR156","WTR056","WTR047","WTR217","WTR074","WTR035","WTR071","WTR033","WTR148","WTR105","WTR133","WTR038","WTR076"
        },
        -- pack #15 in box #58
        [15] = {
            "WTR188","WTR193","WTR216","WTR198","WTR042","WTR011","WTR131","WTR200","WTR036","WTR062","WTR037","WTR067","WTR111","WTR134","WTR097","WTR225","WTR001"
        },
        -- pack #16 in box #58
        [16] = {
            "WTR186","WTR210","WTR202","WTR218","WTR151","WTR094","WTR051","WTR219","WTR061","WTR030","WTR058","WTR098","WTR139","WTR108","WTR142","WTR040","WTR077"
        },
        -- pack #17 in box #58
        [17] = {
            "WTR218","WTR215","WTR199","WTR203","WTR042","WTR013","WTR015","WTR164","WTR027","WTR063","WTR025","WTR149","WTR099","WTR140","WTR100","WTR115","WTR003"
        },
        -- pack #18 in box #58
        [18] = {
            "WTR182","WTR205","WTR183","WTR181","WTR153","WTR013","WTR019","WTR112","WTR061","WTR037","WTR070","WTR025","WTR133","WTR105","WTR139","WTR003","WTR075"
        },
        -- pack #19 in box #58
        [19] = {
            "WTR203","WTR197","WTR193","WTR221","WTR080","WTR019","WTR129","WTR143","WTR035","WTR062","WTR025","WTR133","WTR108","WTR136","WTR112","WTR040","WTR113"
        },
        -- pack #20 in box #58
        [20] = {
            "WTR217","WTR214","WTR206","WTR202","WTR155","WTR167","WTR044","WTR182","WTR036","WTR068","WTR025","WTR132","WTR112","WTR142","WTR104","WTR040","WTR115"
        },
        -- pack #21 in box #58
        [21] = {
            "WTR214","WTR218","WTR201","WTR215","WTR158","WTR052","WTR121","WTR204","WTR072","WTR026","WTR057","WTR022","WTR148","WTR105","WTR139","WTR077","WTR113"
        },
        -- pack #22 in box #58
        [22] = {
            "WTR184","WTR187","WTR179","WTR222","WTR158","WTR131","WTR131","WTR064","WTR030","WTR066","WTR026","WTR070","WTR099","WTR144","WTR104","WTR078","WTR115"
        },
        -- pack #23 in box #58
        [23] = {
            "WTR209","WTR191","WTR194","WTR185","WTR117","WTR086","WTR129","WTR061","WTR021","WTR068","WTR021","WTR137","WTR103","WTR145","WTR098","WTR039","WTR078"
        },
        -- pack #24 in box #58
        [24] = {
            "WTR222","WTR187","WTR202","WTR181","WTR117","WTR053","WTR119","WTR190","WTR061","WTR021","WTR062","WTR096","WTR132","WTR107","WTR142","WTR077","WTR114"
        },
    },
    -- box #59
    [59] = {
        -- pack #1 in box #59
        [1] = {
            "WTR195","WTR187","WTR215","WTR204","WTR117","WTR090","WTR159","WTR208","WTR060","WTR025","WTR060","WTR024","WTR149","WTR106","WTR133","WTR113","WTR078"
        },
        -- pack #2 in box #59
        [2] = {
            "WTR196","WTR200","WTR219","WTR177","WTR155","WTR174","WTR052","WTR063","WTR063","WTR020","WTR058","WTR022","WTR136","WTR109","WTR139","WTR113","WTR077"
        },
        -- pack #3 in box #59
        [3] = {
            "WTR206","WTR189","WTR209","WTR187","WTR154","WTR128","WTR131","WTR069","WTR072","WTR022","WTR063","WTR105","WTR143","WTR112","WTR149","WTR114","WTR039"
        },
        -- pack #4 in box #59
        [4] = {
            "WTR207","WTR179","WTR202","WTR177","WTR158","WTR128","WTR082","WTR072","WTR031","WTR065","WTR026","WTR057","WTR110","WTR140","WTR105","WTR224"
        },
        -- pack #5 in box #59
        [5] = {
            "WTR192","WTR199","WTR215","WTR195","WTR042","WTR172","WTR082","WTR189","WTR066","WTR033","WTR057","WTR033","WTR138","WTR102","WTR146","WTR076","WTR075"
        },
        -- pack #6 in box #59
        [6] = {
            "WTR181","WTR198","WTR213","WTR197","WTR157","WTR092","WTR122","WTR185","WTR031","WTR071","WTR023","WTR057","WTR112","WTR138","WTR104","WTR077","WTR038"
        },
        -- pack #7 in box #59
        [7] = {
            "WTR185","WTR190","WTR206","WTR187","WTR158","WTR167","WTR126","WTR209","WTR034","WTR069","WTR031","WTR141","WTR095","WTR140","WTR099","WTR003","WTR115"
        },
        -- pack #8 in box #59
        [8] = {
            "WTR209","WTR178","WTR199","WTR192","WTR005","WTR055","WTR130","WTR068","WTR066","WTR032","WTR071","WTR026","WTR143","WTR108","WTR137","WTR225","WTR039"
        },
        -- pack #9 in box #59
        [9] = {
            "WTR211","WTR180","WTR220","WTR223","WTR154","WTR087","WTR017","WTR183","WTR068","WTR020","WTR072","WTR095","WTR138","WTR105","WTR132","WTR078","WTR076"
        },
        -- pack #10 in box #59
        [10] = {
            "WTR200","WTR195","WTR200","WTR223","WTR155","WTR086","WTR044","WTR171","WTR023","WTR060","WTR036","WTR132","WTR109","WTR141","WTR111","WTR077","WTR115"
        },
        -- pack #11 in box #59
        [11] = {
            "WTR212","WTR203","WTR184","WTR181","WTR158","WTR125","WTR008","WTR023","WTR022","WTR070","WTR028","WTR062","WTR105","WTR138","WTR104","WTR115","WTR039"
        },
        -- pack #12 in box #59
        [12] = {
            "WTR190","WTR185","WTR214","WTR215","WTR080","WTR166","WTR090","WTR147","WTR064","WTR030","WTR065","WTR107","WTR137","WTR108","WTR133","WTR225","WTR077"
        },
        -- pack #13 in box #59
        [13] = {
            "WTR222","WTR214","WTR216","WTR199","WTR080","WTR169","WTR011","WTR133","WTR026","WTR073","WTR020","WTR135","WTR109","WTR134","WTR108","WTR077","WTR225"
        },
        -- pack #14 in box #59
        [14] = {
            "WTR213","WTR222","WTR200","WTR189","WTR158","WTR087","WTR159","WTR146","WTR029","WTR064","WTR023","WTR064","WTR112","WTR145","WTR096","WTR113","WTR075"
        },
        -- pack #15 in box #59
        [15] = {
            "WTR210","WTR200","WTR189","WTR217","WTR153","WTR125","WTR091","WTR176","WTR027","WTR062","WTR035","WTR147","WTR096","WTR145","WTR104","WTR077","WTR225"
        },
        -- pack #16 in box #59
        [16] = {
            "WTR214","WTR211","WTR195","WTR215","WTR005","WTR174","WTR087","WTR042","WTR067","WTR025","WTR058","WTR037","WTR144","WTR101","WTR139","WTR003","WTR115"
        },
        -- pack #17 in box #59
        [17] = {
            "WTR197","WTR204","WTR192","WTR180","WTR153","WTR049","WTR053","WTR025","WTR069","WTR034","WTR072","WTR110","WTR146","WTR104","WTR141","WTR038","WTR076"
        },
        -- pack #18 in box #59
        [18] = {
            "WTR216","WTR191","WTR189","WTR195","WTR117","WTR091","WTR167","WTR029","WTR037","WTR071","WTR026","WTR067","WTR107","WTR136","WTR109","WTR039","WTR114"
        },
        -- pack #19 in box #59
        [19] = {
            "WTR211","WTR192","WTR182","WTR223","WTR151","WTR018","WTR045","WTR106","WTR026","WTR057","WTR027","WTR073","WTR107","WTR145","WTR102","WTR076","WTR115"
        },
        -- pack #20 in box #59
        [20] = {
            "WTR211","WTR184","WTR192","WTR191","WTR080","WTR168","WTR127","WTR020","WTR033","WTR072","WTR037","WTR143","WTR103","WTR140","WTR101","WTR115","WTR114"
        },
        -- pack #21 in box #59
        [21] = {
            "WTR190","WTR200","WTR214","WTR198","WTR117","WTR054","WTR011","WTR022","WTR058","WTR026","WTR062","WTR032","WTR146","WTR098","WTR144","WTR076","WTR077"
        },
        -- pack #22 in box #59
        [22] = {
            "WTR176","WTR201","WTR219","WTR197","WTR158","WTR130","WTR010","WTR172","WTR024","WTR066","WTR026","WTR134","WTR111","WTR137","WTR100","WTR113","WTR114"
        },
        -- pack #23 in box #59
        [23] = {
            "WTR184","WTR214","WTR212","WTR207","WTR158","WTR165","WTR018","WTR065","WTR060","WTR028","WTR066","WTR097","WTR135","WTR102","WTR148","WTR001","WTR225"
        },
        -- pack #24 in box #59
        [24] = {
            "WTR177","WTR189","WTR205","WTR203","WTR153","WTR011","WTR169","WTR064","WTR067","WTR027","WTR067","WTR102","WTR139","WTR111","WTR136","WTR114","WTR040"
        },
    },
    -- box #60
    [60] = {
        -- pack #1 in box #60
        [1] = {
            "WTR189","WTR193","WTR186","WTR198","WTR117","WTR130","WTR049","WTR180","WTR025","WTR068","WTR029","WTR071","WTR097","WTR142","WTR112","WTR038","WTR076"
        },
        -- pack #2 in box #60
        [2] = {
            "WTR218","WTR203","WTR219","WTR198","WTR154","WTR055","WTR171","WTR134","WTR067","WTR021","WTR058","WTR024","WTR136","WTR111","WTR148","WTR114","WTR003"
        },
        -- pack #3 in box #60
        [3] = {
            "WTR195","WTR178","WTR187","WTR216","WTR158","WTR173","WTR048","WTR222","WTR035","WTR074","WTR024","WTR133","WTR102","WTR139","WTR109","WTR113","WTR077"
        },
        -- pack #4 in box #60
        [4] = {
            "WTR181","WTR197","WTR192","WTR209","WTR153","WTR171","WTR125","WTR089","WTR021","WTR071","WTR025","WTR136","WTR101","WTR145","WTR102","WTR113","WTR077"
        },
        -- pack #5 in box #60
        [5] = {
            "WTR181","WTR179","WTR215","WTR186","WTR153","WTR123","WTR083","WTR107","WTR032","WTR059","WTR037","WTR137","WTR108","WTR136","WTR109","WTR114","WTR113"
        },
        -- pack #6 in box #60
        [6] = {
            "WTR208","WTR201","WTR211","WTR217","WTR151","WTR086","WTR089","WTR102","WTR033","WTR063","WTR032","WTR136","WTR110","WTR133","WTR099","WTR113","WTR076"
        },
        -- pack #7 in box #60
        [7] = {
            "WTR199","WTR223","WTR210","WTR220","WTR005","WTR052","WTR017","WTR101","WTR057","WTR021","WTR059","WTR112","WTR149","WTR103","WTR132","WTR003","WTR115"
        },
        -- pack #8 in box #60
        [8] = {
            "WTR223","WTR214","WTR179","WTR187","WTR158","WTR127","WTR087","WTR204","WTR059","WTR029","WTR059","WTR111","WTR144","WTR103","WTR147","WTR075","WTR113"
        },
        -- pack #9 in box #60
        [9] = {
            "WTR182","WTR215","WTR203","WTR198","WTR158","WTR164","WTR093","WTR221","WTR029","WTR070","WTR029","WTR069","WTR110","WTR141","WTR096","WTR001","WTR003"
        },
        -- pack #10 in box #60
        [10] = {
            "WTR189","WTR196","WTR185","WTR211","WTR156","WTR175","WTR172","WTR065","WTR059","WTR037","WTR057","WTR033","WTR136","WTR111","WTR146","WTR077","WTR078"
        },
        -- pack #11 in box #60
        [11] = {
            "WTR190","WTR177","WTR177","WTR191","WTR117","WTR126","WTR094","WTR101","WTR036","WTR070","WTR036","WTR143","WTR109","WTR141","WTR108","WTR038","WTR001"
        },
        -- pack #12 in box #60
        [12] = {
            "WTR176","WTR201","WTR196","WTR182","WTR157","WTR091","WTR090","WTR195","WTR072","WTR028","WTR070","WTR022","WTR147","WTR097","WTR136","WTR224"
        },
        -- pack #13 in box #60
        [13] = {
            "WTR223","WTR207","WTR183","WTR186","WTR005","WTR014","WTR161","WTR105","WTR071","WTR021","WTR069","WTR101","WTR144","WTR095","WTR146","WTR114","WTR001"
        },
        -- pack #14 in box #60
        [14] = {
            "WTR179","WTR183","WTR195","WTR177","WTR156","WTR090","WTR094","WTR176","WTR064","WTR027","WTR069","WTR101","WTR132","WTR111","WTR135","WTR039","WTR077"
        },
        -- pack #15 in box #60
        [15] = {
            "WTR201","WTR197","WTR208","WTR186","WTR153","WTR053","WTR008","WTR205","WTR073","WTR025","WTR067","WTR034","WTR140","WTR111","WTR146","WTR224"
        },
        -- pack #16 in box #60
        [16] = {
            "WTR214","WTR204","WTR204","WTR200","WTR157","WTR166","WTR168","WTR132","WTR021","WTR074","WTR029","WTR142","WTR096","WTR137","WTR110","WTR076","WTR075"
        },
        -- pack #17 in box #60
        [17] = {
            "WTR181","WTR215","WTR195","WTR199","WTR152","WTR088","WTR081","WTR196","WTR074","WTR025","WTR070","WTR026","WTR144","WTR109","WTR143","WTR038","WTR003"
        },
        -- pack #18 in box #60
        [18] = {
            "WTR187","WTR208","WTR184","WTR210","WTR042","WTR014","WTR118","WTR154","WTR020","WTR064","WTR020","WTR065","WTR111","WTR146","WTR111","WTR077","WTR225"
        },
        -- pack #19 in box #60
        [19] = {
            "WTR199","WTR223","WTR181","WTR220","WTR042","WTR166","WTR129","WTR205","WTR073","WTR029","WTR074","WTR034","WTR144","WTR097","WTR138","WTR001","WTR003"
        },
        -- pack #20 in box #60
        [20] = {
            "WTR192","WTR176","WTR187","WTR178","WTR117","WTR050","WTR046","WTR067","WTR074","WTR033","WTR063","WTR105","WTR140","WTR103","WTR134","WTR039","WTR114"
        },
        -- pack #21 in box #60
        [21] = {
            "WTR199","WTR223","WTR185","WTR189","WTR158","WTR086","WTR046","WTR167","WTR035","WTR064","WTR037","WTR073","WTR104","WTR132","WTR110","WTR002","WTR077"
        },
        -- pack #22 in box #60
        [22] = {
            "WTR211","WTR207","WTR216","WTR183","WTR155","WTR086","WTR172","WTR059","WTR027","WTR070","WTR022","WTR069","WTR097","WTR145","WTR102","WTR003","WTR225"
        },
        -- pack #23 in box #60
        [23] = {
            "WTR204","WTR185","WTR205","WTR202","WTR156","WTR050","WTR172","WTR015","WTR028","WTR074","WTR021","WTR068","WTR099","WTR146","WTR095","WTR001","WTR115"
        },
        -- pack #24 in box #60
        [24] = {
            "WTR212","WTR186","WTR220","WTR200","WTR158","WTR051","WTR047","WTR011","WTR073","WTR029","WTR069","WTR107","WTR149","WTR096","WTR144","WTR039","WTR078"
        },
    },
    -- box #61
    [61] = {
        -- pack #1 in box #61
        [1] = {
            "WTR180","WTR194","WTR193","WTR218","WTR157","WTR090","WTR163","WTR186","WTR023","WTR059","WTR023","WTR136","WTR101","WTR147","WTR099","WTR113","WTR114"
        },
        -- pack #2 in box #61
        [2] = {
            "WTR176","WTR210","WTR208","WTR196","WTR080","WTR054","WTR016","WTR031","WTR036","WTR065","WTR037","WTR147","WTR095","WTR144","WTR108","WTR075","WTR225"
        },
        -- pack #3 in box #61
        [3] = {
            "WTR205","WTR209","WTR210","WTR216","WTR153","WTR015","WTR090","WTR194","WTR037","WTR074","WTR032","WTR140","WTR099","WTR146","WTR105","WTR114","WTR078"
        },
        -- pack #4 in box #61
        [4] = {
            "WTR211","WTR214","WTR210","WTR180","WTR042","WTR018","WTR046","WTR030","WTR071","WTR035","WTR058","WTR102","WTR132","WTR101","WTR143","WTR115","WTR114"
        },
        -- pack #5 in box #61
        [5] = {
            "WTR211","WTR198","WTR221","WTR198","WTR154","WTR172","WTR172","WTR201","WTR024","WTR057","WTR020","WTR137","WTR096","WTR148","WTR111","WTR075","WTR039"
        },
        -- pack #6 in box #61
        [6] = {
            "WTR188","WTR202","WTR202","WTR195","WTR158","WTR048","WTR124","WTR100","WTR063","WTR029","WTR071","WTR106","WTR149","WTR096","WTR149","WTR078","WTR076"
        },
        -- pack #7 in box #61
        [7] = {
            "WTR222","WTR217","WTR209","WTR207","WTR153","WTR094","WTR159","WTR059","WTR033","WTR071","WTR032","WTR134","WTR100","WTR145","WTR109","WTR001","WTR078"
        },
        -- pack #8 in box #61
        [8] = {
            "WTR221","WTR179","WTR186","WTR188","WTR158","WTR054","WTR168","WTR083","WTR064","WTR034","WTR067","WTR108","WTR132","WTR098","WTR141","WTR078","WTR115"
        },
        -- pack #9 in box #61
        [9] = {
            "WTR180","WTR196","WTR221","WTR188","WTR153","WTR014","WTR175","WTR028","WTR073","WTR024","WTR058","WTR025","WTR149","WTR111","WTR138","WTR040","WTR003"
        },
        -- pack #10 in box #61
        [10] = {
            "WTR201","WTR189","WTR223","WTR223","WTR158","WTR054","WTR045","WTR048","WTR072","WTR037","WTR070","WTR098","WTR142","WTR110","WTR134","WTR224"
        },
        -- pack #11 in box #61
        [11] = {
            "WTR221","WTR210","WTR223","WTR178","WTR158","WTR015","WTR169","WTR192","WTR031","WTR062","WTR036","WTR062","WTR100","WTR134","WTR099","WTR038","WTR039"
        },
        -- pack #12 in box #61
        [12] = {
            "WTR215","WTR196","WTR192","WTR201","WTR005","WTR169","WTR171","WTR004","WTR074","WTR030","WTR061","WTR033","WTR143","WTR096","WTR149","WTR003","WTR115"
        },
        -- pack #13 in box #61
        [13] = {
            "WTR176","WTR208","WTR193","WTR190","WTR154","WTR048","WTR130","WTR196","WTR073","WTR025","WTR064","WTR037","WTR135","WTR102","WTR143","WTR225","WTR077"
        },
        -- pack #14 in box #61
        [14] = {
            "WTR177","WTR220","WTR201","WTR183","WTR155","WTR014","WTR045","WTR104","WTR029","WTR063","WTR033","WTR071","WTR108","WTR147","WTR111","WTR075","WTR076"
        },
        -- pack #15 in box #61
        [15] = {
            "WTR179","WTR220","WTR203","WTR188","WTR153","WTR164","WTR046","WTR139","WTR068","WTR032","WTR067","WTR112","WTR149","WTR111","WTR132","WTR077","WTR075"
        },
        -- pack #16 in box #61
        [16] = {
            "WTR182","WTR213","WTR180","WTR178","WTR042","WTR170","WTR014","WTR097","WTR029","WTR068","WTR027","WTR061","WTR096","WTR143","WTR103","WTR076","WTR038"
        },
        -- pack #17 in box #61
        [17] = {
            "WTR200","WTR180","WTR177","WTR212","WTR117","WTR091","WTR044","WTR142","WTR063","WTR031","WTR068","WTR025","WTR135","WTR105","WTR148","WTR113","WTR114"
        },
        -- pack #18 in box #61
        [18] = {
            "WTR212","WTR176","WTR192","WTR184","WTR157","WTR054","WTR090","WTR135","WTR036","WTR061","WTR025","WTR065","WTR107","WTR136","WTR106","WTR076","WTR225"
        },
        -- pack #19 in box #61
        [19] = {
            "WTR214","WTR207","WTR217","WTR210","WTR155","WTR127","WTR122","WTR059","WTR063","WTR031","WTR062","WTR020","WTR138","WTR096","WTR147","WTR040","WTR038"
        },
        -- pack #20 in box #61
        [20] = {
            "WTR200","WTR191","WTR221","WTR217","WTR005","WTR127","WTR171","WTR102","WTR024","WTR058","WTR032","WTR069","WTR111","WTR135","WTR098","WTR075","WTR225"
        },
        -- pack #21 in box #61
        [21] = {
            "WTR214","WTR202","WTR200","WTR189","WTR158","WTR012","WTR087","WTR195","WTR034","WTR063","WTR020","WTR138","WTR107","WTR134","WTR102","WTR077","WTR003"
        },
        -- pack #22 in box #61
        [22] = {
            "WTR223","WTR189","WTR219","WTR223","WTR080","WTR124","WTR119","WTR179","WTR028","WTR073","WTR029","WTR069","WTR109","WTR149","WTR103","WTR001","WTR039"
        },
        -- pack #23 in box #61
        [23] = {
            "WTR190","WTR178","WTR211","WTR205","WTR157","WTR049","WTR130","WTR179","WTR073","WTR028","WTR059","WTR098","WTR139","WTR096","WTR146","WTR114","WTR077"
        },
        -- pack #24 in box #61
        [24] = {
            "WTR186","WTR203","WTR179","WTR208","WTR117","WTR092","WTR084","WTR108","WTR057","WTR037","WTR070","WTR030","WTR149","WTR096","WTR141","WTR075","WTR225"
        },
    },
    -- box #62
    [62] = {
        -- pack #1 in box #62
        [1] = {
            "WTR197","WTR179","WTR220","WTR178","WTR157","WTR093","WTR019","WTR183","WTR032","WTR057","WTR032","WTR058","WTR104","WTR138","WTR106","WTR039","WTR002"
        },
        -- pack #2 in box #62
        [2] = {
            "WTR192","WTR176","WTR184","WTR196","WTR158","WTR173","WTR054","WTR180","WTR027","WTR067","WTR029","WTR134","WTR099","WTR139","WTR097","WTR225","WTR002"
        },
        -- pack #3 in box #62
        [3] = {
            "WTR186","WTR205","WTR186","WTR184","WTR080","WTR056","WTR091","WTR088","WTR031","WTR070","WTR024","WTR062","WTR098","WTR137","WTR096","WTR039","WTR078"
        },
        -- pack #4 in box #62
        [4] = {
            "WTR208","WTR187","WTR191","WTR187","WTR042","WTR171","WTR123","WTR203","WTR031","WTR059","WTR030","WTR136","WTR102","WTR137","WTR100","WTR224"
        },
        -- pack #5 in box #62
        [5] = {
            "WTR187","WTR185","WTR207","WTR183","WTR152","WTR175","WTR052","WTR191","WTR025","WTR060","WTR032","WTR065","WTR111","WTR140","WTR098","WTR002","WTR077"
        },
        -- pack #6 in box #62
        [6] = {
            "WTR185","WTR179","WTR202","WTR178","WTR158","WTR090","WTR017","WTR141","WTR062","WTR034","WTR066","WTR095","WTR138","WTR104","WTR140","WTR224"
        },
        -- pack #7 in box #62
        [7] = {
            "WTR189","WTR185","WTR206","WTR212","WTR154","WTR171","WTR093","WTR200","WTR066","WTR029","WTR068","WTR097","WTR149","WTR097","WTR137","WTR039","WTR038"
        },
        -- pack #8 in box #62
        [8] = {
            "WTR200","WTR214","WTR210","WTR199","WTR005","WTR049","WTR056","WTR140","WTR033","WTR071","WTR022","WTR146","WTR107","WTR141","WTR103","WTR001","WTR075"
        },
        -- pack #9 in box #62
        [9] = {
            "WTR189","WTR194","WTR195","WTR208","WTR117","WTR016","WTR015","WTR217","WTR024","WTR057","WTR026","WTR060","WTR099","WTR145","WTR104","WTR001","WTR075"
        },
        -- pack #10 in box #62
        [10] = {
            "WTR200","WTR179","WTR221","WTR193","WTR153","WTR090","WTR010","WTR061","WTR069","WTR033","WTR058","WTR097","WTR139","WTR111","WTR145","WTR038","WTR076"
        },
        -- pack #11 in box #62
        [11] = {
            "WTR205","WTR198","WTR204","WTR188","WTR154","WTR167","WTR017","WTR152","WTR066","WTR035","WTR070","WTR035","WTR137","WTR109","WTR146","WTR114","WTR001"
        },
        -- pack #12 in box #62
        [12] = {
            "WTR199","WTR223","WTR186","WTR207","WTR152","WTR018","WTR174","WTR111","WTR061","WTR031","WTR073","WTR035","WTR144","WTR112","WTR132","WTR076","WTR038"
        },
        -- pack #13 in box #62
        [13] = {
            "WTR216","WTR191","WTR193","WTR186","WTR117","WTR127","WTR053","WTR213","WTR067","WTR034","WTR072","WTR112","WTR135","WTR101","WTR143","WTR038","WTR225"
        },
        -- pack #14 in box #62
        [14] = {
            "WTR181","WTR182","WTR223","WTR205","WTR157","WTR127","WTR054","WTR032","WTR069","WTR022","WTR072","WTR034","WTR146","WTR098","WTR133","WTR040","WTR077"
        },
        -- pack #15 in box #62
        [15] = {
            "WTR181","WTR215","WTR211","WTR218","WTR080","WTR130","WTR086","WTR169","WTR063","WTR023","WTR071","WTR034","WTR137","WTR103","WTR146","WTR078","WTR001"
        },
        -- pack #16 in box #62
        [16] = {
            "WTR205","WTR209","WTR209","WTR184","WTR157","WTR013","WTR056","WTR033","WTR057","WTR023","WTR061","WTR100","WTR147","WTR104","WTR144","WTR001","WTR002"
        },
        -- pack #17 in box #62
        [17] = {
            "WTR192","WTR204","WTR192","WTR212","WTR005","WTR166","WTR006","WTR183","WTR037","WTR068","WTR020","WTR132","WTR108","WTR146","WTR110","WTR224"
        },
        -- pack #18 in box #62
        [18] = {
            "WTR215","WTR178","WTR203","WTR195","WTR158","WTR050","WTR016","WTR096","WTR035","WTR066","WTR030","WTR148","WTR097","WTR137","WTR107","WTR113","WTR040"
        },
        -- pack #19 in box #62
        [19] = {
            "WTR218","WTR183","WTR196","WTR206","WTR151","WTR169","WTR162","WTR153","WTR061","WTR023","WTR065","WTR097","WTR145","WTR106","WTR146","WTR003","WTR075"
        },
        -- pack #20 in box #62
        [20] = {
            "WTR180","WTR215","WTR194","WTR205","WTR117","WTR175","WTR121","WTR071","WTR062","WTR032","WTR066","WTR030","WTR145","WTR096","WTR140","WTR078","WTR075"
        },
        -- pack #21 in box #62
        [21] = {
            "WTR188","WTR178","WTR222","WTR220","WTR151","WTR055","WTR013","WTR096","WTR073","WTR032","WTR063","WTR028","WTR141","WTR106","WTR140","WTR039","WTR002"
        },
        -- pack #22 in box #62
        [22] = {
            "WTR213","WTR200","WTR222","WTR204","WTR153","WTR165","WTR045","WTR072","WTR023","WTR063","WTR021","WTR147","WTR098","WTR135","WTR108","WTR078","WTR225"
        },
        -- pack #23 in box #62
        [23] = {
            "WTR200","WTR190","WTR201","WTR180","WTR153","WTR056","WTR129","WTR191","WTR025","WTR064","WTR024","WTR070","WTR110","WTR133","WTR107","WTR002","WTR039"
        },
        -- pack #24 in box #62
        [24] = {
            "WTR211","WTR209","WTR199","WTR196","WTR156","WTR164","WTR175","WTR184","WTR037","WTR065","WTR021","WTR065","WTR104","WTR140","WTR097","WTR114","WTR002"
        },
    },
    -- box #63
    [63] = {
        -- pack #1 in box #63
        [1] = {
            "WTR203","WTR187","WTR221","WTR205","WTR154","WTR173","WTR009","WTR187","WTR073","WTR030","WTR072","WTR024","WTR140","WTR107","WTR136","WTR002","WTR225"
        },
        -- pack #2 in box #63
        [2] = {
            "WTR204","WTR213","WTR208","WTR213","WTR154","WTR165","WTR086","WTR135","WTR064","WTR020","WTR069","WTR023","WTR136","WTR096","WTR148","WTR040","WTR076"
        },
        -- pack #3 in box #63
        [3] = {
            "WTR198","WTR176","WTR196","WTR207","WTR154","WTR124","WTR008","WTR064","WTR074","WTR022","WTR057","WTR095","WTR134","WTR106","WTR142","WTR001","WTR075"
        },
        -- pack #4 in box #63
        [4] = {
            "WTR181","WTR194","WTR223","WTR188","WTR155","WTR172","WTR017","WTR030","WTR028","WTR066","WTR024","WTR061","WTR105","WTR136","WTR097","WTR224"
        },
        -- pack #5 in box #63
        [5] = {
            "WTR185","WTR178","WTR206","WTR192","WTR156","WTR128","WTR049","WTR201","WTR036","WTR058","WTR028","WTR062","WTR102","WTR148","WTR103","WTR002","WTR040"
        },
        -- pack #6 in box #63
        [6] = {
            "WTR218","WTR203","WTR210","WTR192","WTR151","WTR091","WTR124","WTR021","WTR035","WTR064","WTR021","WTR135","WTR101","WTR146","WTR111","WTR076","WTR040"
        },
        -- pack #7 in box #63
        [7] = {
            "WTR200","WTR205","WTR183","WTR218","WTR154","WTR167","WTR012","WTR169","WTR030","WTR057","WTR031","WTR073","WTR097","WTR143","WTR104","WTR038","WTR115"
        },
        -- pack #8 in box #63
        [8] = {
            "WTR177","WTR217","WTR214","WTR214","WTR157","WTR014","WTR090","WTR175","WTR034","WTR068","WTR037","WTR144","WTR108","WTR135","WTR097","WTR076","WTR078"
        },
        -- pack #9 in box #63
        [9] = {
            "WTR199","WTR213","WTR204","WTR187","WTR005","WTR089","WTR011","WTR035","WTR021","WTR066","WTR029","WTR068","WTR097","WTR146","WTR106","WTR075","WTR113"
        },
        -- pack #10 in box #63
        [10] = {
            "WTR178","WTR184","WTR209","WTR212","WTR156","WTR053","WTR017","WTR073","WTR074","WTR022","WTR059","WTR109","WTR135","WTR105","WTR144","WTR113","WTR076"
        },
        -- pack #11 in box #63
        [11] = {
            "WTR186","WTR190","WTR180","WTR192","WTR158","WTR016","WTR166","WTR057","WTR033","WTR063","WTR029","WTR143","WTR097","WTR138","WTR104","WTR225","WTR113"
        },
        -- pack #12 in box #63
        [12] = {
            "WTR217","WTR179","WTR217","WTR201","WTR154","WTR016","WTR051","WTR036","WTR027","WTR068","WTR026","WTR059","WTR099","WTR145","WTR102","WTR002","WTR003"
        },
        -- pack #13 in box #63
        [13] = {
            "WTR184","WTR193","WTR191","WTR216","WTR151","WTR089","WTR018","WTR191","WTR071","WTR033","WTR059","WTR105","WTR146","WTR110","WTR147","WTR078","WTR001"
        },
        -- pack #14 in box #63
        [14] = {
            "WTR208","WTR216","WTR190","WTR179","WTR152","WTR174","WTR054","WTR045","WTR074","WTR020","WTR074","WTR096","WTR145","WTR095","WTR135","WTR075","WTR113"
        },
        -- pack #15 in box #63
        [15] = {
            "WTR180","WTR195","WTR194","WTR184","WTR153","WTR131","WTR120","WTR071","WTR067","WTR022","WTR072","WTR025","WTR143","WTR105","WTR136","WTR115","WTR075"
        },
        -- pack #16 in box #63
        [16] = {
            "WTR198","WTR223","WTR184","WTR204","WTR042","WTR129","WTR123","WTR022","WTR027","WTR071","WTR035","WTR144","WTR102","WTR141","WTR105","WTR001","WTR113"
        },
        -- pack #17 in box #63
        [17] = {
            "WTR219","WTR179","WTR217","WTR208","WTR042","WTR128","WTR127","WTR121","WTR069","WTR035","WTR063","WTR027","WTR142","WTR105","WTR141","WTR001","WTR038"
        },
        -- pack #18 in box #63
        [18] = {
            "WTR193","WTR206","WTR211","WTR190","WTR155","WTR056","WTR164","WTR184","WTR066","WTR025","WTR060","WTR107","WTR148","WTR111","WTR148","WTR039","WTR114"
        },
        -- pack #19 in box #63
        [19] = {
            "WTR182","WTR184","WTR204","WTR223","WTR155","WTR087","WTR170","WTR120","WTR074","WTR029","WTR067","WTR029","WTR149","WTR109","WTR137","WTR114","WTR113"
        },
        -- pack #20 in box #63
        [20] = {
            "WTR218","WTR187","WTR209","WTR193","WTR005","WTR087","WTR130","WTR215","WTR064","WTR029","WTR065","WTR034","WTR137","WTR095","WTR145","WTR040","WTR002"
        },
        -- pack #21 in box #63
        [21] = {
            "WTR184","WTR220","WTR197","WTR200","WTR153","WTR123","WTR055","WTR053","WTR069","WTR032","WTR070","WTR103","WTR136","WTR099","WTR141","WTR002","WTR038"
        },
        -- pack #22 in box #63
        [22] = {
            "WTR198","WTR206","WTR206","WTR222","WTR158","WTR054","WTR044","WTR214","WTR022","WTR060","WTR028","WTR063","WTR103","WTR137","WTR107","WTR039","WTR040"
        },
        -- pack #23 in box #63
        [23] = {
            "WTR183","WTR185","WTR198","WTR210","WTR154","WTR019","WTR014","WTR139","WTR031","WTR058","WTR029","WTR134","WTR111","WTR132","WTR107","WTR003","WTR113"
        },
        -- pack #24 in box #63
        [24] = {
            "WTR177","WTR195","WTR215","WTR213","WTR156","WTR126","WTR164","WTR059","WTR026","WTR066","WTR030","WTR138","WTR107","WTR145","WTR098","WTR224"
        },
    },
    -- box #64
    [64] = {
        -- pack #1 in box #64
        [1] = {
            "WTR197","WTR186","WTR215","WTR212","WTR042","WTR165","WTR086","WTR128","WTR029","WTR065","WTR030","WTR135","WTR106","WTR139","WTR112","WTR038","WTR076"
        },
        -- pack #2 in box #64
        [2] = {
            "WTR212","WTR218","WTR189","WTR208","WTR005","WTR087","WTR126","WTR157","WTR061","WTR030","WTR067","WTR098","WTR135","WTR103","WTR145","WTR078","WTR225"
        },
        -- pack #3 in box #64
        [3] = {
            "WTR211","WTR193","WTR186","WTR221","WTR154","WTR164","WTR054","WTR223","WTR026","WTR062","WTR021","WTR058","WTR109","WTR149","WTR112","WTR225","WTR040"
        },
        -- pack #4 in box #64
        [4] = {
            "WTR198","WTR208","WTR201","WTR195","WTR155","WTR129","WTR053","WTR139","WTR070","WTR031","WTR074","WTR028","WTR133","WTR103","WTR142","WTR076","WTR115"
        },
        -- pack #5 in box #64
        [5] = {
            "WTR187","WTR216","WTR178","WTR182","WTR153","WTR088","WTR049","WTR151","WTR074","WTR022","WTR064","WTR110","WTR149","WTR101","WTR144","WTR040","WTR038"
        },
        -- pack #6 in box #64
        [6] = {
            "WTR182","WTR220","WTR190","WTR182","WTR157","WTR052","WTR166","WTR061","WTR065","WTR035","WTR066","WTR105","WTR133","WTR096","WTR145","WTR224"
        },
        -- pack #7 in box #64
        [7] = {
            "WTR220","WTR207","WTR176","WTR181","WTR005","WTR129","WTR015","WTR100","WTR023","WTR066","WTR028","WTR065","WTR107","WTR135","WTR101","WTR113","WTR114"
        },
        -- pack #8 in box #64
        [8] = {
            "WTR191","WTR203","WTR184","WTR208","WTR157","WTR055","WTR165","WTR005","WTR062","WTR021","WTR074","WTR032","WTR139","WTR111","WTR133","WTR114","WTR038"
        },
        -- pack #9 in box #64
        [9] = {
            "WTR204","WTR214","WTR177","WTR179","WTR155","WTR124","WTR118","WTR023","WTR070","WTR035","WTR068","WTR029","WTR135","WTR101","WTR143","WTR076","WTR039"
        },
        -- pack #10 in box #64
        [10] = {
            "WTR213","WTR213","WTR219","WTR218","WTR158","WTR012","WTR090","WTR180","WTR024","WTR073","WTR030","WTR134","WTR109","WTR136","WTR108","WTR002","WTR114"
        },
        -- pack #11 in box #64
        [11] = {
            "WTR210","WTR184","WTR196","WTR216","WTR158","WTR090","WTR092","WTR062","WTR060","WTR027","WTR057","WTR027","WTR147","WTR099","WTR147","WTR115","WTR078"
        },
        -- pack #12 in box #64
        [12] = {
            "WTR201","WTR219","WTR196","WTR223","WTR157","WTR051","WTR160","WTR061","WTR029","WTR070","WTR035","WTR149","WTR112","WTR144","WTR108","WTR075","WTR003"
        },
        -- pack #13 in box #64
        [13] = {
            "WTR221","WTR215","WTR178","WTR201","WTR042","WTR170","WTR129","WTR211","WTR025","WTR065","WTR027","WTR066","WTR100","WTR135","WTR096","WTR224"
        },
        -- pack #14 in box #64
        [14] = {
            "WTR211","WTR222","WTR218","WTR193","WTR158","WTR089","WTR123","WTR172","WTR072","WTR030","WTR058","WTR095","WTR137","WTR109","WTR149","WTR114","WTR113"
        },
        -- pack #15 in box #64
        [15] = {
            "WTR194","WTR185","WTR203","WTR221","WTR158","WTR089","WTR053","WTR066","WTR058","WTR037","WTR074","WTR023","WTR136","WTR102","WTR137","WTR003","WTR075"
        },
        -- pack #16 in box #64
        [16] = {
            "WTR214","WTR220","WTR194","WTR199","WTR152","WTR168","WTR015","WTR023","WTR020","WTR060","WTR026","WTR136","WTR108","WTR142","WTR112","WTR040","WTR113"
        },
        -- pack #17 in box #64
        [17] = {
            "WTR212","WTR221","WTR199","WTR207","WTR117","WTR126","WTR010","WTR150","WTR069","WTR034","WTR067","WTR106","WTR143","WTR104","WTR135","WTR077","WTR075"
        },
        -- pack #18 in box #64
        [18] = {
            "WTR220","WTR219","WTR178","WTR217","WTR080","WTR089","WTR128","WTR210","WTR023","WTR057","WTR036","WTR072","WTR110","WTR132","WTR110","WTR038","WTR001"
        },
        -- pack #19 in box #64
        [19] = {
            "WTR187","WTR213","WTR214","WTR189","WTR155","WTR169","WTR167","WTR063","WTR025","WTR057","WTR023","WTR073","WTR101","WTR134","WTR096","WTR076","WTR078"
        },
        -- pack #20 in box #64
        [20] = {
            "WTR194","WTR190","WTR207","WTR191","WTR153","WTR173","WTR167","WTR133","WTR031","WTR073","WTR031","WTR133","WTR110","WTR144","WTR098","WTR078","WTR040"
        },
        -- pack #21 in box #64
        [21] = {
            "WTR211","WTR195","WTR215","WTR213","WTR151","WTR050","WTR050","WTR173","WTR035","WTR058","WTR022","WTR069","WTR112","WTR149","WTR112","WTR038","WTR076"
        },
        -- pack #22 in box #64
        [22] = {
            "WTR191","WTR193","WTR212","WTR180","WTR005","WTR168","WTR165","WTR096","WTR023","WTR069","WTR028","WTR136","WTR098","WTR136","WTR102","WTR039","WTR075"
        },
        -- pack #23 in box #64
        [23] = {
            "WTR200","WTR188","WTR179","WTR180","WTR154","WTR086","WTR162","WTR204","WTR068","WTR035","WTR067","WTR105","WTR142","WTR112","WTR136","WTR077","WTR115"
        },
        -- pack #24 in box #64
        [24] = {
            "WTR189","WTR177","WTR177","WTR192","WTR154","WTR017","WTR166","WTR110","WTR065","WTR034","WTR058","WTR032","WTR142","WTR100","WTR142","WTR075","WTR039"
        },
    },
    -- box #65
    [65] = {
        -- pack #1 in box #65
        [1] = {
            "WTR199","WTR178","WTR188","WTR198","WTR042","WTR054","WTR050","WTR091","WTR029","WTR066","WTR031","WTR073","WTR100","WTR143","WTR108","WTR113","WTR040"
        },
        -- pack #2 in box #65
        [2] = {
            "WTR221","WTR216","WTR196","WTR217","WTR156","WTR124","WTR165","WTR052","WTR058","WTR034","WTR065","WTR105","WTR133","WTR097","WTR135","WTR225","WTR115"
        },
        -- pack #3 in box #65
        [3] = {
            "WTR182","WTR207","WTR198","WTR220","WTR042","WTR094","WTR122","WTR216","WTR060","WTR033","WTR057","WTR099","WTR145","WTR111","WTR135","WTR003","WTR113"
        },
        -- pack #4 in box #65
        [4] = {
            "WTR187","WTR186","WTR177","WTR192","WTR042","WTR174","WTR051","WTR214","WTR074","WTR026","WTR064","WTR021","WTR149","WTR097","WTR136","WTR225","WTR002"
        },
        -- pack #5 in box #65
        [5] = {
            "WTR187","WTR207","WTR187","WTR176","WTR156","WTR092","WTR090","WTR126","WTR029","WTR074","WTR023","WTR140","WTR106","WTR142","WTR103","WTR076","WTR075"
        },
        -- pack #6 in box #65
        [6] = {
            "WTR185","WTR176","WTR191","WTR203","WTR157","WTR056","WTR011","WTR164","WTR029","WTR074","WTR021","WTR069","WTR112","WTR133","WTR104","WTR040","WTR003"
        },
        -- pack #7 in box #65
        [7] = {
            "WTR189","WTR190","WTR215","WTR177","WTR080","WTR170","WTR125","WTR064","WTR028","WTR057","WTR020","WTR144","WTR096","WTR133","WTR098","WTR039","WTR038"
        },
        -- pack #8 in box #65
        [8] = {
            "WTR198","WTR207","WTR189","WTR218","WTR117","WTR050","WTR083","WTR195","WTR057","WTR037","WTR073","WTR027","WTR140","WTR100","WTR134","WTR078","WTR225"
        },
        -- pack #9 in box #65
        [9] = {
            "WTR207","WTR183","WTR192","WTR217","WTR042","WTR168","WTR086","WTR083","WTR069","WTR021","WTR066","WTR035","WTR141","WTR095","WTR132","WTR039","WTR225"
        },
        -- pack #10 in box #65
        [10] = {
            "WTR197","WTR184","WTR205","WTR187","WTR153","WTR175","WTR082","WTR194","WTR026","WTR064","WTR020","WTR060","WTR099","WTR140","WTR107","WTR225","WTR040"
        },
        -- pack #11 in box #65
        [11] = {
            "WTR177","WTR186","WTR201","WTR218","WTR154","WTR165","WTR052","WTR175","WTR073","WTR023","WTR067","WTR101","WTR144","WTR101","WTR134","WTR224"
        },
        -- pack #12 in box #65
        [12] = {
            "WTR203","WTR223","WTR209","WTR189","WTR156","WTR164","WTR018","WTR008","WTR023","WTR066","WTR030","WTR148","WTR096","WTR138","WTR105","WTR075","WTR077"
        },
        -- pack #13 in box #65
        [13] = {
            "WTR181","WTR222","WTR201","WTR209","WTR158","WTR171","WTR011","WTR054","WTR036","WTR073","WTR020","WTR072","WTR103","WTR132","WTR112","WTR076","WTR039"
        },
        -- pack #14 in box #65
        [14] = {
            "WTR192","WTR192","WTR217","WTR212","WTR151","WTR051","WTR120","WTR064","WTR027","WTR071","WTR023","WTR071","WTR097","WTR132","WTR108","WTR075","WTR003"
        },
        -- pack #15 in box #65
        [15] = {
            "WTR176","WTR205","WTR219","WTR206","WTR154","WTR087","WTR131","WTR196","WTR058","WTR024","WTR067","WTR101","WTR143","WTR105","WTR142","WTR224"
        },
        -- pack #16 in box #65
        [16] = {
            "WTR176","WTR191","WTR206","WTR189","WTR042","WTR165","WTR051","WTR190","WTR023","WTR070","WTR035","WTR136","WTR095","WTR148","WTR104","WTR002","WTR115"
        },
        -- pack #17 in box #65
        [17] = {
            "WTR186","WTR196","WTR178","WTR209","WTR080","WTR131","WTR166","WTR190","WTR032","WTR073","WTR025","WTR147","WTR104","WTR135","WTR100","WTR040","WTR075"
        },
        -- pack #18 in box #65
        [18] = {
            "WTR176","WTR209","WTR183","WTR186","WTR158","WTR016","WTR050","WTR008","WTR061","WTR020","WTR057","WTR109","WTR148","WTR095","WTR133","WTR224"
        },
        -- pack #19 in box #65
        [19] = {
            "WTR212","WTR206","WTR189","WTR177","WTR152","WTR056","WTR055","WTR087","WTR068","WTR020","WTR074","WTR024","WTR138","WTR102","WTR132","WTR039","WTR040"
        },
        -- pack #20 in box #65
        [20] = {
            "WTR211","WTR202","WTR196","WTR193","WTR080","WTR051","WTR012","WTR211","WTR026","WTR064","WTR022","WTR069","WTR098","WTR139","WTR104","WTR077","WTR078"
        },
        -- pack #21 in box #65
        [21] = {
            "WTR176","WTR208","WTR210","WTR187","WTR005","WTR165","WTR015","WTR153","WTR060","WTR033","WTR064","WTR025","WTR139","WTR106","WTR134","WTR113","WTR076"
        },
        -- pack #22 in box #65
        [22] = {
            "WTR184","WTR195","WTR218","WTR222","WTR080","WTR167","WTR093","WTR026","WTR030","WTR070","WTR027","WTR132","WTR095","WTR147","WTR101","WTR078","WTR002"
        },
        -- pack #23 in box #65
        [23] = {
            "WTR191","WTR202","WTR203","WTR222","WTR080","WTR088","WTR053","WTR189","WTR057","WTR028","WTR065","WTR030","WTR134","WTR110","WTR143","WTR076","WTR078"
        },
        -- pack #24 in box #65
        [24] = {
            "WTR182","WTR215","WTR207","WTR176","WTR005","WTR011","WTR131","WTR137","WTR068","WTR025","WTR072","WTR103","WTR133","WTR112","WTR141","WTR076","WTR001"
        },
    },
    -- box #66
    [66] = {
        -- pack #1 in box #66
        [1] = {
            "WTR178","WTR187","WTR185","WTR209","WTR157","WTR166","WTR171","WTR074","WTR072","WTR025","WTR072","WTR032","WTR145","WTR095","WTR148","WTR077","WTR114"
        },
        -- pack #2 in box #66
        [2] = {
            "WTR183","WTR203","WTR204","WTR209","WTR158","WTR054","WTR172","WTR084","WTR025","WTR073","WTR021","WTR060","WTR104","WTR139","WTR110","WTR002","WTR040"
        },
        -- pack #3 in box #66
        [3] = {
            "WTR184","WTR213","WTR202","WTR185","WTR157","WTR170","WTR163","WTR121","WTR060","WTR037","WTR057","WTR021","WTR144","WTR102","WTR145","WTR113","WTR003"
        },
        -- pack #4 in box #66
        [4] = {
            "WTR210","WTR201","WTR192","WTR213","WTR151","WTR048","WTR007","WTR191","WTR025","WTR070","WTR037","WTR133","WTR112","WTR139","WTR106","WTR115","WTR113"
        },
        -- pack #5 in box #66
        [5] = {
            "WTR201","WTR212","WTR190","WTR202","WTR155","WTR165","WTR131","WTR021","WTR028","WTR058","WTR033","WTR149","WTR097","WTR138","WTR109","WTR075","WTR003"
        },
        -- pack #6 in box #66
        [6] = {
            "WTR214","WTR212","WTR213","WTR223","WTR158","WTR093","WTR013","WTR197","WTR066","WTR036","WTR070","WTR036","WTR143","WTR104","WTR133","WTR076","WTR115"
        },
        -- pack #7 in box #66
        [7] = {
            "WTR177","WTR221","WTR218","WTR186","WTR158","WTR130","WTR165","WTR185","WTR031","WTR063","WTR025","WTR059","WTR097","WTR143","WTR097","WTR003","WTR038"
        },
        -- pack #8 in box #66
        [8] = {
            "WTR221","WTR223","WTR176","WTR187","WTR156","WTR092","WTR086","WTR216","WTR072","WTR025","WTR060","WTR024","WTR134","WTR108","WTR141","WTR114","WTR003"
        },
        -- pack #9 in box #66
        [9] = {
            "WTR190","WTR215","WTR188","WTR182","WTR042","WTR048","WTR012","WTR112","WTR065","WTR026","WTR070","WTR022","WTR140","WTR099","WTR132","WTR114","WTR113"
        },
        -- pack #10 in box #66
        [10] = {
            "WTR214","WTR193","WTR177","WTR191","WTR151","WTR086","WTR043","WTR107","WTR025","WTR074","WTR028","WTR070","WTR105","WTR138","WTR102","WTR038","WTR076"
        },
        -- pack #11 in box #66
        [11] = {
            "WTR176","WTR193","WTR204","WTR193","WTR157","WTR124","WTR049","WTR144","WTR063","WTR036","WTR071","WTR100","WTR136","WTR107","WTR133","WTR078","WTR115"
        },
        -- pack #12 in box #66
        [12] = {
            "WTR187","WTR207","WTR212","WTR194","WTR156","WTR126","WTR054","WTR105","WTR026","WTR068","WTR020","WTR137","WTR096","WTR144","WTR103","WTR003","WTR115"
        },
        -- pack #13 in box #66
        [13] = {
            "WTR190","WTR180","WTR193","WTR211","WTR152","WTR013","WTR161","WTR207","WTR020","WTR057","WTR024","WTR062","WTR101","WTR133","WTR103","WTR038","WTR039"
        },
        -- pack #14 in box #66
        [14] = {
            "WTR202","WTR184","WTR176","WTR220","WTR157","WTR012","WTR054","WTR179","WTR064","WTR035","WTR060","WTR112","WTR149","WTR110","WTR138","WTR003","WTR114"
        },
        -- pack #15 in box #66
        [15] = {
            "WTR214","WTR199","WTR193","WTR215","WTR117","WTR169","WTR089","WTR037","WTR032","WTR059","WTR026","WTR142","WTR098","WTR145","WTR103","WTR076","WTR077"
        },
        -- pack #16 in box #66
        [16] = {
            "WTR190","WTR184","WTR189","WTR213","WTR155","WTR167","WTR047","WTR107","WTR063","WTR032","WTR069","WTR104","WTR134","WTR110","WTR143","WTR115","WTR001"
        },
        -- pack #17 in box #66
        [17] = {
            "WTR204","WTR201","WTR211","WTR187","WTR158","WTR050","WTR125","WTR093","WTR067","WTR034","WTR074","WTR098","WTR132","WTR099","WTR147","WTR075","WTR038"
        },
        -- pack #18 in box #66
        [18] = {
            "WTR197","WTR188","WTR210","WTR195","WTR157","WTR094","WTR093","WTR183","WTR069","WTR037","WTR073","WTR104","WTR135","WTR104","WTR137","WTR075","WTR039"
        },
        -- pack #19 in box #66
        [19] = {
            "WTR212","WTR210","WTR212","WTR222","WTR005","WTR014","WTR175","WTR177","WTR030","WTR069","WTR027","WTR060","WTR102","WTR146","WTR106","WTR225","WTR038"
        },
        -- pack #20 in box #66
        [20] = {
            "WTR214","WTR197","WTR198","WTR206","WTR158","WTR012","WTR120","WTR193","WTR037","WTR070","WTR034","WTR137","WTR102","WTR139","WTR095","WTR075","WTR001"
        },
        -- pack #21 in box #66
        [21] = {
            "WTR204","WTR197","WTR178","WTR185","WTR152","WTR130","WTR165","WTR140","WTR031","WTR071","WTR027","WTR134","WTR100","WTR137","WTR108","WTR075","WTR076"
        },
        -- pack #22 in box #66
        [22] = {
            "WTR176","WTR220","WTR220","WTR187","WTR151","WTR049","WTR088","WTR222","WTR074","WTR035","WTR073","WTR022","WTR133","WTR105","WTR138","WTR113","WTR040"
        },
        -- pack #23 in box #66
        [23] = {
            "WTR214","WTR222","WTR211","WTR179","WTR151","WTR049","WTR125","WTR101","WTR033","WTR059","WTR022","WTR065","WTR095","WTR140","WTR107","WTR039","WTR001"
        },
        -- pack #24 in box #66
        [24] = {
            "WTR205","WTR180","WTR214","WTR191","WTR153","WTR055","WTR019","WTR097","WTR065","WTR027","WTR068","WTR108","WTR140","WTR102","WTR146","WTR115","WTR075"
        },
    },
    -- box #67
    [67] = {
        -- pack #1 in box #67
        [1] = {
            "WTR214","WTR178","WTR221","WTR187","WTR157","WTR130","WTR010","WTR033","WTR036","WTR074","WTR032","WTR148","WTR107","WTR147","WTR103","WTR002","WTR038"
        },
        -- pack #2 in box #67
        [2] = {
            "WTR183","WTR214","WTR181","WTR198","WTR042","WTR016","WTR043","WTR165","WTR059","WTR036","WTR065","WTR028","WTR145","WTR108","WTR144","WTR075","WTR114"
        },
        -- pack #3 in box #67
        [3] = {
            "WTR177","WTR192","WTR185","WTR215","WTR155","WTR017","WTR012","WTR188","WTR021","WTR074","WTR021","WTR149","WTR103","WTR138","WTR100","WTR113","WTR040"
        },
        -- pack #4 in box #67
        [4] = {
            "WTR195","WTR221","WTR219","WTR217","WTR005","WTR166","WTR170","WTR011","WTR023","WTR065","WTR034","WTR059","WTR095","WTR149","WTR109","WTR113","WTR075"
        },
        -- pack #5 in box #67
        [5] = {
            "WTR200","WTR188","WTR203","WTR213","WTR158","WTR168","WTR089","WTR037","WTR024","WTR063","WTR023","WTR057","WTR108","WTR148","WTR104","WTR039","WTR076"
        },
        -- pack #6 in box #67
        [6] = {
            "WTR207","WTR178","WTR198","WTR182","WTR156","WTR088","WTR082","WTR150","WTR025","WTR057","WTR030","WTR057","WTR103","WTR133","WTR095","WTR038","WTR077"
        },
        -- pack #7 in box #67
        [7] = {
            "WTR219","WTR201","WTR202","WTR200","WTR152","WTR050","WTR052","WTR110","WTR021","WTR064","WTR029","WTR142","WTR105","WTR146","WTR098","WTR225","WTR076"
        },
        -- pack #8 in box #67
        [8] = {
            "WTR213","WTR183","WTR190","WTR193","WTR155","WTR129","WTR174","WTR071","WTR072","WTR036","WTR074","WTR109","WTR136","WTR107","WTR133","WTR113","WTR040"
        },
        -- pack #9 in box #67
        [9] = {
            "WTR207","WTR205","WTR188","WTR206","WTR158","WTR013","WTR162","WTR164","WTR073","WTR037","WTR071","WTR100","WTR148","WTR111","WTR139","WTR078","WTR225"
        },
        -- pack #10 in box #67
        [10] = {
            "WTR207","WTR185","WTR176","WTR190","WTR152","WTR053","WTR017","WTR091","WTR061","WTR025","WTR072","WTR033","WTR149","WTR110","WTR136","WTR040","WTR077"
        },
        -- pack #11 in box #67
        [11] = {
            "WTR191","WTR198","WTR202","WTR219","WTR157","WTR087","WTR050","WTR126","WTR060","WTR021","WTR069","WTR112","WTR138","WTR110","WTR149","WTR224"
        },
        -- pack #12 in box #67
        [12] = {
            "WTR194","WTR190","WTR223","WTR212","WTR155","WTR015","WTR118","WTR181","WTR026","WTR063","WTR025","WTR144","WTR101","WTR133","WTR107","WTR038","WTR114"
        },
        -- pack #13 in box #67
        [13] = {
            "WTR221","WTR211","WTR203","WTR217","WTR005","WTR053","WTR162","WTR190","WTR065","WTR021","WTR065","WTR022","WTR141","WTR105","WTR133","WTR225","WTR077"
        },
        -- pack #14 in box #67
        [14] = {
            "WTR217","WTR200","WTR189","WTR181","WTR005","WTR015","WTR165","WTR138","WTR065","WTR035","WTR059","WTR101","WTR137","WTR107","WTR139","WTR003","WTR077"
        },
        -- pack #15 in box #67
        [15] = {
            "WTR208","WTR210","WTR184","WTR189","WTR157","WTR011","WTR123","WTR203","WTR034","WTR067","WTR022","WTR145","WTR100","WTR132","WTR104","WTR115","WTR077"
        },
        -- pack #16 in box #67
        [16] = {
            "WTR209","WTR222","WTR214","WTR197","WTR155","WTR094","WTR172","WTR057","WTR034","WTR069","WTR032","WTR136","WTR103","WTR149","WTR095","WTR001","WTR113"
        },
        -- pack #17 in box #67
        [17] = {
            "WTR220","WTR204","WTR192","WTR181","WTR153","WTR050","WTR047","WTR064","WTR074","WTR030","WTR066","WTR098","WTR145","WTR104","WTR140","WTR001","WTR038"
        },
        -- pack #18 in box #67
        [18] = {
            "WTR194","WTR217","WTR201","WTR200","WTR156","WTR011","WTR044","WTR067","WTR070","WTR020","WTR062","WTR031","WTR149","WTR102","WTR144","WTR038","WTR002"
        },
        -- pack #19 in box #67
        [19] = {
            "WTR204","WTR215","WTR215","WTR179","WTR117","WTR056","WTR165","WTR158","WTR060","WTR022","WTR067","WTR029","WTR146","WTR110","WTR148","WTR038","WTR076"
        },
        -- pack #20 in box #67
        [20] = {
            "WTR218","WTR216","WTR211","WTR206","WTR151","WTR165","WTR050","WTR134","WTR058","WTR031","WTR060","WTR101","WTR138","WTR108","WTR134","WTR114","WTR075"
        },
        -- pack #21 in box #67
        [21] = {
            "WTR184","WTR213","WTR222","WTR197","WTR042","WTR174","WTR013","WTR019","WTR030","WTR065","WTR022","WTR065","WTR097","WTR149","WTR102","WTR224"
        },
        -- pack #22 in box #67
        [22] = {
            "WTR177","WTR200","WTR191","WTR215","WTR042","WTR123","WTR006","WTR080","WTR032","WTR069","WTR031","WTR072","WTR097","WTR132","WTR102","WTR001","WTR078"
        },
        -- pack #23 in box #67
        [23] = {
            "WTR178","WTR188","WTR184","WTR219","WTR005","WTR165","WTR045","WTR151","WTR069","WTR028","WTR063","WTR034","WTR132","WTR108","WTR146","WTR038","WTR001"
        },
        -- pack #24 in box #67
        [24] = {
            "WTR222","WTR205","WTR190","WTR210","WTR156","WTR017","WTR129","WTR175","WTR024","WTR074","WTR033","WTR065","WTR105","WTR148","WTR095","WTR225","WTR114"
        },
    },
    -- box #68
    [68] = {
        -- pack #1 in box #68
        [1] = {
            "WTR208","WTR180","WTR187","WTR176","WTR153","WTR131","WTR089","WTR219","WTR026","WTR060","WTR024","WTR143","WTR095","WTR145","WTR096","WTR038","WTR002"
        },
        -- pack #2 in box #68
        [2] = {
            "WTR200","WTR176","WTR190","WTR222","WTR154","WTR011","WTR174","WTR014","WTR068","WTR025","WTR060","WTR031","WTR132","WTR107","WTR141","WTR076","WTR078"
        },
        -- pack #3 in box #68
        [3] = {
            "WTR218","WTR219","WTR192","WTR199","WTR154","WTR015","WTR125","WTR070","WTR033","WTR066","WTR029","WTR139","WTR097","WTR144","WTR100","WTR002","WTR076"
        },
        -- pack #4 in box #68
        [4] = {
            "WTR189","WTR210","WTR223","WTR183","WTR155","WTR172","WTR168","WTR056","WTR057","WTR033","WTR071","WTR109","WTR134","WTR107","WTR137","WTR113","WTR075"
        },
        -- pack #5 in box #68
        [5] = {
            "WTR220","WTR193","WTR213","WTR208","WTR152","WTR048","WTR130","WTR005","WTR026","WTR072","WTR035","WTR140","WTR109","WTR141","WTR105","WTR040","WTR114"
        },
        -- pack #6 in box #68
        [6] = {
            "WTR184","WTR202","WTR180","WTR206","WTR151","WTR089","WTR125","WTR109","WTR028","WTR065","WTR031","WTR063","WTR099","WTR146","WTR111","WTR040","WTR076"
        },
        -- pack #7 in box #68
        [7] = {
            "WTR211","WTR190","WTR219","WTR209","WTR154","WTR174","WTR055","WTR187","WTR059","WTR021","WTR061","WTR103","WTR138","WTR097","WTR146","WTR001","WTR077"
        },
        -- pack #8 in box #68
        [8] = {
            "WTR197","WTR204","WTR212","WTR219","WTR117","WTR053","WTR085","WTR070","WTR036","WTR068","WTR025","WTR145","WTR111","WTR145","WTR108","WTR040","WTR038"
        },
        -- pack #9 in box #68
        [9] = {
            "WTR207","WTR218","WTR205","WTR190","WTR155","WTR018","WTR046","WTR200","WTR066","WTR021","WTR073","WTR035","WTR140","WTR107","WTR134","WTR115","WTR225"
        },
        -- pack #10 in box #68
        [10] = {
            "WTR214","WTR183","WTR192","WTR196","WTR005","WTR087","WTR168","WTR149","WTR059","WTR030","WTR067","WTR101","WTR135","WTR111","WTR137","WTR038","WTR114"
        },
        -- pack #11 in box #68
        [11] = {
            "WTR176","WTR212","WTR179","WTR202","WTR153","WTR128","WTR006","WTR068","WTR059","WTR025","WTR074","WTR111","WTR133","WTR099","WTR144","WTR225","WTR040"
        },
        -- pack #12 in box #68
        [12] = {
            "WTR181","WTR216","WTR182","WTR182","WTR153","WTR127","WTR130","WTR120","WTR060","WTR031","WTR065","WTR022","WTR144","WTR101","WTR141","WTR113","WTR001"
        },
        -- pack #13 in box #68
        [13] = {
            "WTR200","WTR189","WTR223","WTR211","WTR153","WTR092","WTR160","WTR161","WTR071","WTR024","WTR057","WTR103","WTR143","WTR107","WTR146","WTR078","WTR115"
        },
        -- pack #14 in box #68
        [14] = {
            "WTR185","WTR202","WTR197","WTR197","WTR153","WTR049","WTR124","WTR132","WTR070","WTR036","WTR059","WTR031","WTR139","WTR104","WTR133","WTR001","WTR040"
        },
        -- pack #15 in box #68
        [15] = {
            "WTR222","WTR215","WTR209","WTR177","WTR152","WTR049","WTR082","WTR016","WTR031","WTR062","WTR025","WTR141","WTR099","WTR138","WTR111","WTR039","WTR001"
        },
        -- pack #16 in box #68
        [16] = {
            "WTR217","WTR186","WTR214","WTR223","WTR117","WTR053","WTR017","WTR055","WTR037","WTR065","WTR021","WTR064","WTR111","WTR141","WTR106","WTR225","WTR075"
        },
        -- pack #17 in box #68
        [17] = {
            "WTR188","WTR192","WTR198","WTR212","WTR156","WTR123","WTR008","WTR095","WTR022","WTR062","WTR027","WTR060","WTR104","WTR132","WTR097","WTR078","WTR115"
        },
        -- pack #18 in box #68
        [18] = {
            "WTR187","WTR198","WTR223","WTR192","WTR005","WTR019","WTR122","WTR036","WTR036","WTR070","WTR034","WTR060","WTR099","WTR138","WTR109","WTR039","WTR002"
        },
        -- pack #19 in box #68
        [19] = {
            "WTR185","WTR193","WTR204","WTR212","WTR151","WTR052","WTR094","WTR176","WTR031","WTR058","WTR022","WTR068","WTR109","WTR142","WTR104","WTR075","WTR001"
        },
        -- pack #20 in box #68
        [20] = {
            "WTR182","WTR187","WTR184","WTR210","WTR152","WTR175","WTR044","WTR210","WTR069","WTR025","WTR060","WTR026","WTR135","WTR104","WTR140","WTR113","WTR225"
        },
        -- pack #21 in box #68
        [21] = {
            "WTR191","WTR187","WTR217","WTR216","WTR117","WTR130","WTR053","WTR060","WTR067","WTR028","WTR058","WTR022","WTR146","WTR104","WTR136","WTR115","WTR078"
        },
        -- pack #22 in box #68
        [22] = {
            "WTR194","WTR187","WTR214","WTR218","WTR153","WTR088","WTR165","WTR217","WTR024","WTR072","WTR030","WTR143","WTR110","WTR143","WTR100","WTR225","WTR076"
        },
        -- pack #23 in box #68
        [23] = {
            "WTR191","WTR213","WTR223","WTR202","WTR154","WTR173","WTR167","WTR026","WTR028","WTR062","WTR030","WTR066","WTR096","WTR137","WTR110","WTR224"
        },
        -- pack #24 in box #68
        [24] = {
            "WTR205","WTR196","WTR182","WTR176","WTR156","WTR086","WTR166","WTR098","WTR063","WTR024","WTR064","WTR102","WTR141","WTR101","WTR146","WTR225","WTR077"
        },
    },
    -- box #69
    [69] = {
        -- pack #1 in box #69
        [1] = {
            "WTR182","WTR188","WTR208","WTR199","WTR156","WTR054","WTR016","WTR173","WTR034","WTR072","WTR033","WTR141","WTR099","WTR148","WTR112","WTR077","WTR039"
        },
        -- pack #2 in box #69
        [2] = {
            "WTR177","WTR220","WTR200","WTR181","WTR156","WTR173","WTR081","WTR163","WTR029","WTR070","WTR032","WTR145","WTR099","WTR136","WTR097","WTR076","WTR077"
        },
        -- pack #3 in box #69
        [3] = {
            "WTR197","WTR202","WTR190","WTR218","WTR156","WTR169","WTR129","WTR223","WTR072","WTR033","WTR072","WTR029","WTR138","WTR107","WTR135","WTR224"
        },
        -- pack #4 in box #69
        [4] = {
            "WTR216","WTR183","WTR217","WTR181","WTR152","WTR129","WTR121","WTR074","WTR032","WTR071","WTR021","WTR066","WTR103","WTR141","WTR097","WTR003","WTR114"
        },
        -- pack #5 in box #69
        [5] = {
            "WTR191","WTR214","WTR186","WTR186","WTR005","WTR051","WTR175","WTR223","WTR026","WTR058","WTR020","WTR134","WTR105","WTR144","WTR096","WTR001","WTR225"
        },
        -- pack #6 in box #69
        [6] = {
            "WTR201","WTR196","WTR181","WTR182","WTR157","WTR093","WTR011","WTR033","WTR028","WTR061","WTR034","WTR134","WTR109","WTR146","WTR106","WTR114","WTR077"
        },
        -- pack #7 in box #69
        [7] = {
            "WTR181","WTR219","WTR185","WTR223","WTR158","WTR170","WTR053","WTR184","WTR073","WTR028","WTR057","WTR097","WTR140","WTR108","WTR149","WTR115","WTR001"
        },
        -- pack #8 in box #69
        [8] = {
            "WTR185","WTR204","WTR198","WTR210","WTR156","WTR091","WTR087","WTR033","WTR037","WTR071","WTR035","WTR062","WTR104","WTR148","WTR110","WTR114","WTR113"
        },
        -- pack #9 in box #69
        [9] = {
            "WTR200","WTR195","WTR178","WTR197","WTR153","WTR014","WTR018","WTR148","WTR027","WTR066","WTR026","WTR141","WTR106","WTR136","WTR098","WTR003","WTR077"
        },
        -- pack #10 in box #69
        [10] = {
            "WTR185","WTR204","WTR208","WTR213","WTR151","WTR013","WTR088","WTR020","WTR028","WTR059","WTR032","WTR057","WTR105","WTR132","WTR112","WTR078","WTR114"
        },
        -- pack #11 in box #69
        [11] = {
            "WTR195","WTR220","WTR212","WTR212","WTR156","WTR092","WTR015","WTR125","WTR059","WTR027","WTR073","WTR100","WTR143","WTR102","WTR140","WTR039","WTR115"
        },
        -- pack #12 in box #69
        [12] = {
            "WTR184","WTR185","WTR194","WTR179","WTR005","WTR093","WTR090","WTR192","WTR068","WTR037","WTR069","WTR108","WTR138","WTR112","WTR135","WTR115","WTR038"
        },
        -- pack #13 in box #69
        [13] = {
            "WTR177","WTR177","WTR176","WTR180","WTR155","WTR123","WTR049","WTR215","WTR033","WTR064","WTR034","WTR069","WTR100","WTR139","WTR111","WTR078","WTR039"
        },
        -- pack #14 in box #69
        [14] = {
            "WTR221","WTR198","WTR216","WTR200","WTR153","WTR175","WTR045","WTR220","WTR057","WTR024","WTR069","WTR104","WTR147","WTR110","WTR135","WTR038","WTR040"
        },
        -- pack #15 in box #69
        [15] = {
            "WTR197","WTR218","WTR192","WTR188","WTR156","WTR054","WTR012","WTR058","WTR068","WTR030","WTR063","WTR034","WTR142","WTR102","WTR132","WTR078","WTR115"
        },
        -- pack #16 in box #69
        [16] = {
            "WTR176","WTR208","WTR176","WTR205","WTR117","WTR125","WTR161","WTR220","WTR064","WTR027","WTR071","WTR025","WTR144","WTR098","WTR149","WTR225","WTR040"
        },
        -- pack #17 in box #69
        [17] = {
            "WTR190","WTR182","WTR185","WTR212","WTR155","WTR175","WTR009","WTR055","WTR030","WTR060","WTR036","WTR057","WTR106","WTR141","WTR112","WTR040","WTR076"
        },
        -- pack #18 in box #69
        [18] = {
            "WTR183","WTR193","WTR208","WTR217","WTR005","WTR175","WTR083","WTR194","WTR061","WTR025","WTR061","WTR109","WTR135","WTR104","WTR145","WTR038","WTR076"
        },
        -- pack #19 in box #69
        [19] = {
            "WTR206","WTR217","WTR176","WTR219","WTR155","WTR170","WTR119","WTR147","WTR063","WTR029","WTR060","WTR033","WTR134","WTR110","WTR141","WTR078","WTR002"
        },
        -- pack #20 in box #69
        [20] = {
            "WTR189","WTR181","WTR220","WTR193","WTR080","WTR123","WTR171","WTR027","WTR057","WTR035","WTR058","WTR110","WTR148","WTR107","WTR139","WTR001","WTR225"
        },
        -- pack #21 in box #69
        [21] = {
            "WTR186","WTR214","WTR221","WTR188","WTR155","WTR173","WTR087","WTR136","WTR029","WTR060","WTR037","WTR148","WTR104","WTR148","WTR108","WTR038","WTR002"
        },
        -- pack #22 in box #69
        [22] = {
            "WTR194","WTR213","WTR185","WTR218","WTR005","WTR013","WTR055","WTR098","WTR072","WTR024","WTR067","WTR030","WTR149","WTR111","WTR143","WTR075","WTR113"
        },
        -- pack #23 in box #69
        [23] = {
            "WTR210","WTR197","WTR190","WTR186","WTR151","WTR126","WTR018","WTR161","WTR074","WTR023","WTR072","WTR033","WTR140","WTR102","WTR146","WTR224"
        },
        -- pack #24 in box #69
        [24] = {
            "WTR203","WTR208","WTR203","WTR184","WTR154","WTR169","WTR162","WTR066","WTR020","WTR058","WTR021","WTR061","WTR107","WTR133","WTR106","WTR001","WTR225"
        },
    },
    -- box #70
    [70] = {
        -- pack #1 in box #70
        [1] = {
            "WTR217","WTR188","WTR196","WTR205","WTR153","WTR090","WTR123","WTR010","WTR027","WTR058","WTR034","WTR146","WTR108","WTR138","WTR106","WTR001","WTR039"
        },
        -- pack #2 in box #70
        [2] = {
            "WTR180","WTR185","WTR202","WTR220","WTR080","WTR171","WTR172","WTR108","WTR027","WTR064","WTR031","WTR070","WTR102","WTR137","WTR107","WTR225","WTR078"
        },
        -- pack #3 in box #70
        [3] = {
            "WTR219","WTR180","WTR190","WTR194","WTR117","WTR054","WTR169","WTR010","WTR026","WTR072","WTR035","WTR142","WTR101","WTR132","WTR097","WTR078","WTR038"
        },
        -- pack #4 in box #70
        [4] = {
            "WTR182","WTR208","WTR193","WTR212","WTR158","WTR053","WTR123","WTR174","WTR058","WTR021","WTR073","WTR026","WTR143","WTR096","WTR143","WTR002","WTR114"
        },
        -- pack #5 in box #70
        [5] = {
            "WTR212","WTR179","WTR211","WTR188","WTR117","WTR169","WTR007","WTR085","WTR020","WTR067","WTR030","WTR071","WTR103","WTR142","WTR096","WTR078","WTR001"
        },
        -- pack #6 in box #70
        [6] = {
            "WTR189","WTR185","WTR205","WTR186","WTR153","WTR130","WTR017","WTR182","WTR062","WTR029","WTR064","WTR030","WTR146","WTR096","WTR144","WTR225","WTR078"
        },
        -- pack #7 in box #70
        [7] = {
            "WTR177","WTR222","WTR215","WTR176","WTR153","WTR050","WTR014","WTR204","WTR071","WTR037","WTR070","WTR095","WTR143","WTR103","WTR138","WTR113","WTR038"
        },
        -- pack #8 in box #70
        [8] = {
            "WTR177","WTR200","WTR184","WTR197","WTR154","WTR011","WTR056","WTR017","WTR067","WTR020","WTR062","WTR102","WTR142","WTR099","WTR146","WTR114","WTR003"
        },
        -- pack #9 in box #70
        [9] = {
            "WTR223","WTR195","WTR221","WTR216","WTR080","WTR127","WTR016","WTR219","WTR026","WTR062","WTR024","WTR074","WTR105","WTR144","WTR106","WTR224"
        },
        -- pack #10 in box #70
        [10] = {
            "WTR207","WTR206","WTR185","WTR213","WTR117","WTR090","WTR091","WTR222","WTR057","WTR025","WTR062","WTR106","WTR147","WTR108","WTR140","WTR077","WTR001"
        },
        -- pack #11 in box #70
        [11] = {
            "WTR199","WTR192","WTR201","WTR218","WTR152","WTR052","WTR164","WTR062","WTR028","WTR064","WTR031","WTR132","WTR105","WTR135","WTR101","WTR002","WTR078"
        },
        -- pack #12 in box #70
        [12] = {
            "WTR179","WTR189","WTR178","WTR186","WTR155","WTR167","WTR052","WTR134","WTR072","WTR026","WTR063","WTR108","WTR147","WTR095","WTR144","WTR075","WTR225"
        },
        -- pack #13 in box #70
        [13] = {
            "WTR219","WTR185","WTR177","WTR187","WTR042","WTR014","WTR165","WTR200","WTR022","WTR072","WTR021","WTR066","WTR103","WTR145","WTR099","WTR002","WTR115"
        },
        -- pack #14 in box #70
        [14] = {
            "WTR197","WTR223","WTR216","WTR203","WTR156","WTR016","WTR175","WTR210","WTR034","WTR066","WTR024","WTR140","WTR099","WTR136","WTR097","WTR075","WTR078"
        },
        -- pack #15 in box #70
        [15] = {
            "WTR188","WTR208","WTR205","WTR216","WTR080","WTR014","WTR050","WTR118","WTR022","WTR064","WTR028","WTR057","WTR098","WTR133","WTR097","WTR075","WTR076"
        },
        -- pack #16 in box #70
        [16] = {
            "WTR218","WTR176","WTR188","WTR194","WTR156","WTR055","WTR043","WTR070","WTR067","WTR030","WTR067","WTR030","WTR142","WTR106","WTR142","WTR001","WTR075"
        },
        -- pack #17 in box #70
        [17] = {
            "WTR177","WTR183","WTR203","WTR180","WTR152","WTR018","WTR006","WTR178","WTR034","WTR073","WTR020","WTR071","WTR101","WTR145","WTR111","WTR077","WTR115"
        },
        -- pack #18 in box #70
        [18] = {
            "WTR210","WTR181","WTR215","WTR217","WTR154","WTR175","WTR090","WTR065","WTR068","WTR032","WTR072","WTR036","WTR146","WTR110","WTR135","WTR113","WTR002"
        },
        -- pack #19 in box #70
        [19] = {
            "WTR184","WTR190","WTR191","WTR194","WTR157","WTR011","WTR086","WTR106","WTR027","WTR062","WTR032","WTR132","WTR110","WTR135","WTR095","WTR076","WTR002"
        },
        -- pack #20 in box #70
        [20] = {
            "WTR199","WTR182","WTR183","WTR191","WTR158","WTR051","WTR018","WTR199","WTR058","WTR026","WTR062","WTR027","WTR139","WTR099","WTR145","WTR002","WTR225"
        },
        -- pack #21 in box #70
        [21] = {
            "WTR192","WTR204","WTR212","WTR189","WTR080","WTR174","WTR015","WTR166","WTR068","WTR029","WTR073","WTR037","WTR147","WTR100","WTR144","WTR224"
        },
        -- pack #22 in box #70
        [22] = {
            "WTR190","WTR216","WTR189","WTR191","WTR158","WTR012","WTR169","WTR192","WTR023","WTR057","WTR024","WTR146","WTR097","WTR139","WTR100","WTR040","WTR075"
        },
        -- pack #23 in box #70
        [23] = {
            "WTR185","WTR208","WTR206","WTR213","WTR156","WTR087","WTR012","WTR212","WTR063","WTR021","WTR064","WTR108","WTR136","WTR110","WTR146","WTR225","WTR077"
        },
        -- pack #24 in box #70
        [24] = {
            "WTR195","WTR211","WTR201","WTR197","WTR005","WTR055","WTR051","WTR207","WTR074","WTR021","WTR067","WTR101","WTR140","WTR102","WTR147","WTR040","WTR114"
        },
    },
    -- box #71
    [71] = {
        -- pack #1 in box #71
        [1] = {
            "WTR208","WTR176","WTR191","WTR203","WTR080","WTR165","WTR019","WTR168","WTR021","WTR058","WTR033","WTR142","WTR096","WTR142","WTR112","WTR113","WTR076"
        },
        -- pack #2 in box #71
        [2] = {
            "WTR192","WTR193","WTR190","WTR210","WTR157","WTR130","WTR169","WTR072","WTR032","WTR071","WTR022","WTR060","WTR101","WTR146","WTR096","WTR040","WTR038"
        },
        -- pack #3 in box #71
        [3] = {
            "WTR185","WTR192","WTR186","WTR212","WTR154","WTR174","WTR016","WTR207","WTR060","WTR029","WTR067","WTR027","WTR141","WTR108","WTR137","WTR225","WTR003"
        },
        -- pack #4 in box #71
        [4] = {
            "WTR206","WTR213","WTR212","WTR191","WTR157","WTR171","WTR053","WTR099","WTR032","WTR072","WTR031","WTR065","WTR109","WTR137","WTR107","WTR003","WTR078"
        },
        -- pack #5 in box #71
        [5] = {
            "WTR209","WTR201","WTR202","WTR203","WTR158","WTR055","WTR174","WTR037","WTR066","WTR026","WTR068","WTR100","WTR138","WTR099","WTR134","WTR001","WTR115"
        },
        -- pack #6 in box #71
        [6] = {
            "WTR193","WTR188","WTR215","WTR200","WTR156","WTR094","WTR052","WTR111","WTR034","WTR062","WTR031","WTR145","WTR099","WTR145","WTR097","WTR040","WTR113"
        },
        -- pack #7 in box #71
        [7] = {
            "WTR217","WTR202","WTR208","WTR215","WTR153","WTR129","WTR175","WTR125","WTR060","WTR028","WTR064","WTR024","WTR139","WTR100","WTR140","WTR225","WTR075"
        },
        -- pack #8 in box #71
        [8] = {
            "WTR188","WTR193","WTR209","WTR205","WTR080","WTR088","WTR161","WTR156","WTR032","WTR060","WTR027","WTR148","WTR098","WTR146","WTR099","WTR040","WTR075"
        },
        -- pack #9 in box #71
        [9] = {
            "WTR184","WTR221","WTR188","WTR209","WTR157","WTR127","WTR163","WTR212","WTR060","WTR024","WTR067","WTR112","WTR147","WTR112","WTR145","WTR038","WTR078"
        },
        -- pack #10 in box #71
        [10] = {
            "WTR186","WTR199","WTR182","WTR180","WTR042","WTR169","WTR081","WTR179","WTR037","WTR068","WTR031","WTR063","WTR109","WTR135","WTR109","WTR114","WTR115"
        },
        -- pack #11 in box #71
        [11] = {
            "WTR177","WTR221","WTR192","WTR207","WTR151","WTR131","WTR164","WTR211","WTR065","WTR022","WTR061","WTR101","WTR142","WTR102","WTR142","WTR114","WTR038"
        },
        -- pack #12 in box #71
        [12] = {
            "WTR206","WTR205","WTR186","WTR217","WTR154","WTR173","WTR171","WTR017","WTR030","WTR063","WTR026","WTR142","WTR098","WTR148","WTR106","WTR115","WTR001"
        },
        -- pack #13 in box #71
        [13] = {
            "WTR189","WTR188","WTR212","WTR189","WTR153","WTR087","WTR128","WTR177","WTR060","WTR023","WTR061","WTR109","WTR134","WTR110","WTR133","WTR077","WTR076"
        },
        -- pack #14 in box #71
        [14] = {
            "WTR206","WTR223","WTR215","WTR187","WTR117","WTR124","WTR019","WTR218","WTR024","WTR072","WTR034","WTR060","WTR104","WTR142","WTR112","WTR076","WTR038"
        },
        -- pack #15 in box #71
        [15] = {
            "WTR195","WTR201","WTR220","WTR220","WTR156","WTR091","WTR087","WTR069","WTR032","WTR068","WTR034","WTR065","WTR097","WTR147","WTR110","WTR001","WTR038"
        },
        -- pack #16 in box #71
        [16] = {
            "WTR211","WTR212","WTR216","WTR179","WTR153","WTR130","WTR094","WTR139","WTR059","WTR030","WTR071","WTR030","WTR135","WTR103","WTR143","WTR115","WTR078"
        },
        -- pack #17 in box #71
        [17] = {
            "WTR187","WTR221","WTR210","WTR205","WTR005","WTR086","WTR018","WTR194","WTR033","WTR067","WTR024","WTR067","WTR105","WTR133","WTR108","WTR224"
        },
        -- pack #18 in box #71
        [18] = {
            "WTR214","WTR219","WTR179","WTR198","WTR153","WTR087","WTR089","WTR205","WTR036","WTR066","WTR032","WTR135","WTR106","WTR144","WTR097","WTR075","WTR001"
        },
        -- pack #19 in box #71
        [19] = {
            "WTR202","WTR183","WTR192","WTR214","WTR153","WTR049","WTR091","WTR103","WTR068","WTR023","WTR062","WTR104","WTR143","WTR100","WTR139","WTR040","WTR077"
        },
        -- pack #20 in box #71
        [20] = {
            "WTR187","WTR181","WTR208","WTR219","WTR158","WTR131","WTR019","WTR059","WTR024","WTR058","WTR029","WTR143","WTR106","WTR145","WTR105","WTR039","WTR002"
        },
        -- pack #21 in box #71
        [21] = {
            "WTR223","WTR182","WTR202","WTR180","WTR151","WTR018","WTR086","WTR109","WTR071","WTR024","WTR062","WTR032","WTR149","WTR102","WTR146","WTR039","WTR113"
        },
        -- pack #22 in box #71
        [22] = {
            "WTR193","WTR194","WTR206","WTR203","WTR080","WTR012","WTR051","WTR215","WTR059","WTR035","WTR074","WTR033","WTR143","WTR108","WTR137","WTR001","WTR002"
        },
        -- pack #23 in box #71
        [23] = {
            "WTR217","WTR215","WTR197","WTR204","WTR158","WTR166","WTR169","WTR137","WTR059","WTR029","WTR058","WTR106","WTR146","WTR097","WTR134","WTR114","WTR076"
        },
        -- pack #24 in box #71
        [24] = {
            "WTR221","WTR212","WTR219","WTR217","WTR155","WTR016","WTR011","WTR205","WTR062","WTR032","WTR074","WTR023","WTR146","WTR099","WTR144","WTR224"
        },
    },
    -- box #72
    [72] = {
        -- pack #1 in box #72
        [1] = {
            "WTR194","WTR203","WTR197","WTR198","WTR080","WTR019","WTR169","WTR030","WTR067","WTR027","WTR059","WTR033","WTR137","WTR111","WTR144","WTR001","WTR076"
        },
        -- pack #2 in box #72
        [2] = {
            "WTR195","WTR190","WTR209","WTR216","WTR117","WTR094","WTR047","WTR088","WTR033","WTR058","WTR022","WTR069","WTR106","WTR141","WTR106","WTR003","WTR114"
        },
        -- pack #3 in box #72
        [3] = {
            "WTR219","WTR204","WTR209","WTR193","WTR117","WTR124","WTR011","WTR149","WTR035","WTR068","WTR032","WTR065","WTR096","WTR135","WTR109","WTR113","WTR038"
        },
        -- pack #4 in box #72
        [4] = {
            "WTR178","WTR181","WTR216","WTR198","WTR156","WTR129","WTR011","WTR037","WTR059","WTR028","WTR061","WTR024","WTR135","WTR109","WTR147","WTR075","WTR078"
        },
        -- pack #5 in box #72
        [5] = {
            "WTR196","WTR223","WTR219","WTR214","WTR154","WTR054","WTR125","WTR197","WTR070","WTR037","WTR057","WTR037","WTR147","WTR105","WTR145","WTR039","WTR003"
        },
        -- pack #6 in box #72
        [6] = {
            "WTR195","WTR205","WTR191","WTR187","WTR080","WTR123","WTR127","WTR070","WTR074","WTR032","WTR059","WTR022","WTR140","WTR112","WTR147","WTR114","WTR225"
        },
        -- pack #7 in box #72
        [7] = {
            "WTR186","WTR194","WTR195","WTR185","WTR151","WTR125","WTR006","WTR067","WTR074","WTR021","WTR064","WTR022","WTR132","WTR102","WTR137","WTR114","WTR039"
        },
        -- pack #8 in box #72
        [8] = {
            "WTR205","WTR186","WTR183","WTR188","WTR158","WTR171","WTR053","WTR051","WTR026","WTR068","WTR033","WTR067","WTR102","WTR140","WTR110","WTR114","WTR078"
        },
        -- pack #9 in box #72
        [9] = {
            "WTR206","WTR196","WTR211","WTR187","WTR080","WTR131","WTR089","WTR181","WTR060","WTR024","WTR062","WTR108","WTR134","WTR095","WTR140","WTR040","WTR038"
        },
        -- pack #10 in box #72
        [10] = {
            "WTR195","WTR182","WTR187","WTR179","WTR158","WTR013","WTR125","WTR048","WTR025","WTR061","WTR034","WTR139","WTR108","WTR139","WTR101","WTR225","WTR114"
        },
        -- pack #11 in box #72
        [11] = {
            "WTR210","WTR207","WTR186","WTR215","WTR117","WTR173","WTR046","WTR187","WTR060","WTR023","WTR069","WTR101","WTR148","WTR104","WTR147","WTR113","WTR114"
        },
        -- pack #12 in box #72
        [12] = {
            "WTR205","WTR187","WTR198","WTR197","WTR157","WTR123","WTR169","WTR065","WTR034","WTR059","WTR035","WTR074","WTR103","WTR138","WTR102","WTR114","WTR075"
        },
        -- pack #13 in box #72
        [13] = {
            "WTR196","WTR215","WTR197","WTR187","WTR156","WTR050","WTR173","WTR137","WTR024","WTR063","WTR025","WTR060","WTR105","WTR140","WTR095","WTR114","WTR076"
        },
        -- pack #14 in box #72
        [14] = {
            "WTR213","WTR210","WTR201","WTR177","WTR151","WTR175","WTR054","WTR057","WTR032","WTR067","WTR021","WTR148","WTR106","WTR147","WTR112","WTR039","WTR040"
        },
        -- pack #15 in box #72
        [15] = {
            "WTR205","WTR217","WTR216","WTR176","WTR157","WTR017","WTR084","WTR136","WTR068","WTR026","WTR059","WTR100","WTR149","WTR104","WTR133","WTR002","WTR114"
        },
        -- pack #16 in box #72
        [16] = {
            "WTR217","WTR214","WTR209","WTR193","WTR156","WTR090","WTR126","WTR063","WTR061","WTR026","WTR059","WTR035","WTR146","WTR108","WTR148","WTR039","WTR114"
        },
        -- pack #17 in box #72
        [17] = {
            "WTR211","WTR221","WTR205","WTR205","WTR156","WTR048","WTR131","WTR046","WTR026","WTR073","WTR028","WTR137","WTR106","WTR142","WTR102","WTR075","WTR113"
        },
        -- pack #18 in box #72
        [18] = {
            "WTR201","WTR181","WTR209","WTR208","WTR005","WTR086","WTR085","WTR074","WTR021","WTR067","WTR021","WTR066","WTR098","WTR142","WTR102","WTR002","WTR225"
        },
        -- pack #19 in box #72
        [19] = {
            "WTR179","WTR199","WTR206","WTR183","WTR157","WTR016","WTR014","WTR135","WTR020","WTR071","WTR030","WTR133","WTR100","WTR143","WTR105","WTR001","WTR077"
        },
        -- pack #20 in box #72
        [20] = {
            "WTR208","WTR218","WTR221","WTR188","WTR156","WTR015","WTR007","WTR141","WTR033","WTR067","WTR027","WTR147","WTR097","WTR146","WTR098","WTR003","WTR114"
        },
        -- pack #21 in box #72
        [21] = {
            "WTR210","WTR186","WTR176","WTR202","WTR151","WTR017","WTR162","WTR036","WTR059","WTR023","WTR059","WTR109","WTR142","WTR106","WTR146","WTR076","WTR002"
        },
        -- pack #22 in box #72
        [22] = {
            "WTR180","WTR204","WTR199","WTR218","WTR157","WTR051","WTR013","WTR031","WTR063","WTR026","WTR062","WTR099","WTR141","WTR098","WTR149","WTR078","WTR003"
        },
        -- pack #23 in box #72
        [23] = {
            "WTR206","WTR191","WTR197","WTR214","WTR042","WTR174","WTR008","WTR067","WTR069","WTR029","WTR064","WTR100","WTR134","WTR111","WTR144","WTR114","WTR002"
        },
        -- pack #24 in box #72
        [24] = {
            "WTR218","WTR188","WTR217","WTR216","WTR154","WTR169","WTR051","WTR099","WTR023","WTR073","WTR021","WTR141","WTR103","WTR135","WTR100","WTR040","WTR114"
        },
    },
    -- box #73
    [73] = {
        -- pack #1 in box #73
        [1] = {
            "WTR220","WTR204","WTR200","WTR220","WTR080","WTR093","WTR085","WTR195","WTR073","WTR020","WTR060","WTR102","WTR139","WTR102","WTR138","WTR224"
        },
        -- pack #2 in box #73
        [2] = {
            "WTR195","WTR202","WTR213","WTR194","WTR117","WTR126","WTR174","WTR110","WTR064","WTR026","WTR060","WTR034","WTR135","WTR112","WTR149","WTR225","WTR075"
        },
        -- pack #3 in box #73
        [3] = {
            "WTR221","WTR180","WTR220","WTR185","WTR152","WTR171","WTR012","WTR067","WTR034","WTR064","WTR027","WTR068","WTR106","WTR137","WTR104","WTR040","WTR115"
        },
        -- pack #4 in box #73
        [4] = {
            "WTR178","WTR185","WTR204","WTR190","WTR042","WTR131","WTR047","WTR199","WTR025","WTR073","WTR022","WTR061","WTR097","WTR142","WTR099","WTR039","WTR001"
        },
        -- pack #5 in box #73
        [5] = {
            "WTR194","WTR209","WTR202","WTR198","WTR156","WTR019","WTR172","WTR136","WTR031","WTR059","WTR028","WTR148","WTR102","WTR146","WTR106","WTR114","WTR038"
        },
        -- pack #6 in box #73
        [6] = {
            "WTR210","WTR187","WTR199","WTR213","WTR151","WTR011","WTR048","WTR194","WTR034","WTR070","WTR036","WTR139","WTR100","WTR140","WTR099","WTR002","WTR114"
        },
        -- pack #7 in box #73
        [7] = {
            "WTR190","WTR215","WTR177","WTR203","WTR152","WTR012","WTR081","WTR071","WTR063","WTR024","WTR061","WTR099","WTR135","WTR095","WTR146","WTR225","WTR076"
        },
        -- pack #8 in box #73
        [8] = {
            "WTR206","WTR219","WTR217","WTR188","WTR154","WTR164","WTR007","WTR217","WTR029","WTR065","WTR037","WTR141","WTR101","WTR135","WTR102","WTR225","WTR115"
        },
        -- pack #9 in box #73
        [9] = {
            "WTR195","WTR177","WTR191","WTR202","WTR158","WTR049","WTR165","WTR129","WTR072","WTR023","WTR059","WTR104","WTR136","WTR095","WTR137","WTR002","WTR113"
        },
        -- pack #10 in box #73
        [10] = {
            "WTR205","WTR197","WTR187","WTR176","WTR155","WTR050","WTR170","WTR099","WTR065","WTR027","WTR061","WTR111","WTR143","WTR100","WTR142","WTR040","WTR003"
        },
        -- pack #11 in box #73
        [11] = {
            "WTR188","WTR189","WTR191","WTR189","WTR151","WTR019","WTR170","WTR107","WTR028","WTR058","WTR025","WTR139","WTR100","WTR143","WTR106","WTR040","WTR038"
        },
        -- pack #12 in box #73
        [12] = {
            "WTR179","WTR217","WTR221","WTR199","WTR080","WTR050","WTR128","WTR043","WTR070","WTR027","WTR068","WTR035","WTR147","WTR102","WTR133","WTR114","WTR225"
        },
        -- pack #13 in box #73
        [13] = {
            "WTR177","WTR191","WTR213","WTR213","WTR117","WTR089","WTR048","WTR106","WTR060","WTR036","WTR057","WTR028","WTR134","WTR099","WTR146","WTR075","WTR077"
        },
        -- pack #14 in box #73
        [14] = {
            "WTR176","WTR192","WTR185","WTR200","WTR155","WTR091","WTR047","WTR211","WTR058","WTR027","WTR067","WTR096","WTR138","WTR095","WTR134","WTR040","WTR225"
        },
        -- pack #15 in box #73
        [15] = {
            "WTR198","WTR213","WTR208","WTR216","WTR152","WTR165","WTR055","WTR021","WTR068","WTR022","WTR061","WTR029","WTR132","WTR104","WTR135","WTR076","WTR002"
        },
        -- pack #16 in box #73
        [16] = {
            "WTR176","WTR213","WTR203","WTR190","WTR152","WTR170","WTR089","WTR208","WTR029","WTR060","WTR027","WTR060","WTR108","WTR149","WTR103","WTR078","WTR225"
        },
        -- pack #17 in box #73
        [17] = {
            "WTR218","WTR210","WTR206","WTR207","WTR154","WTR170","WTR054","WTR100","WTR034","WTR071","WTR032","WTR071","WTR112","WTR138","WTR101","WTR038","WTR039"
        },
        -- pack #18 in box #73
        [18] = {
            "WTR208","WTR190","WTR199","WTR189","WTR153","WTR089","WTR081","WTR117","WTR068","WTR023","WTR060","WTR037","WTR134","WTR110","WTR135","WTR003","WTR040"
        },
        -- pack #19 in box #73
        [19] = {
            "WTR217","WTR189","WTR196","WTR195","WTR157","WTR049","WTR092","WTR053","WTR024","WTR066","WTR031","WTR143","WTR107","WTR141","WTR110","WTR224"
        },
        -- pack #20 in box #73
        [20] = {
            "WTR201","WTR194","WTR210","WTR214","WTR152","WTR173","WTR009","WTR185","WTR027","WTR070","WTR023","WTR137","WTR100","WTR146","WTR111","WTR040","WTR039"
        },
        -- pack #21 in box #73
        [21] = {
            "WTR177","WTR204","WTR216","WTR215","WTR152","WTR017","WTR168","WTR098","WTR029","WTR065","WTR024","WTR062","WTR110","WTR134","WTR099","WTR002","WTR040"
        },
        -- pack #22 in box #73
        [22] = {
            "WTR195","WTR201","WTR177","WTR189","WTR155","WTR053","WTR052","WTR154","WTR036","WTR061","WTR023","WTR071","WTR099","WTR136","WTR108","WTR003","WTR077"
        },
        -- pack #23 in box #73
        [23] = {
            "WTR222","WTR209","WTR212","WTR203","WTR155","WTR014","WTR094","WTR050","WTR070","WTR036","WTR074","WTR106","WTR136","WTR105","WTR147","WTR002","WTR038"
        },
        -- pack #24 in box #73
        [24] = {
            "WTR200","WTR176","WTR219","WTR193","WTR042","WTR088","WTR163","WTR035","WTR073","WTR036","WTR073","WTR031","WTR136","WTR107","WTR134","WTR038","WTR040"
        },
    },
    -- box #74
    [74] = {
        -- pack #1 in box #74
        [1] = {
            "WTR212","WTR182","WTR194","WTR191","WTR080","WTR090","WTR046","WTR029","WTR074","WTR036","WTR066","WTR105","WTR146","WTR107","WTR144","WTR001","WTR114"
        },
        -- pack #2 in box #74
        [2] = {
            "WTR223","WTR212","WTR184","WTR215","WTR042","WTR168","WTR160","WTR104","WTR036","WTR070","WTR037","WTR137","WTR095","WTR136","WTR111","WTR077","WTR113"
        },
        -- pack #3 in box #74
        [3] = {
            "WTR218","WTR176","WTR216","WTR200","WTR117","WTR171","WTR119","WTR100","WTR061","WTR035","WTR066","WTR098","WTR145","WTR097","WTR147","WTR076","WTR077"
        },
        -- pack #4 in box #74
        [4] = {
            "WTR215","WTR177","WTR180","WTR191","WTR152","WTR131","WTR012","WTR208","WTR034","WTR071","WTR025","WTR138","WTR101","WTR142","WTR101","WTR113","WTR078"
        },
        -- pack #5 in box #74
        [5] = {
            "WTR214","WTR186","WTR208","WTR182","WTR117","WTR017","WTR169","WTR197","WTR065","WTR021","WTR071","WTR035","WTR139","WTR111","WTR149","WTR077","WTR114"
        },
        -- pack #6 in box #74
        [6] = {
            "WTR208","WTR204","WTR183","WTR209","WTR117","WTR089","WTR085","WTR020","WTR066","WTR030","WTR064","WTR037","WTR134","WTR105","WTR133","WTR224"
        },
        -- pack #7 in box #74
        [7] = {
            "WTR208","WTR209","WTR208","WTR183","WTR080","WTR169","WTR124","WTR185","WTR022","WTR061","WTR023","WTR069","WTR101","WTR139","WTR095","WTR115","WTR113"
        },
        -- pack #8 in box #74
        [8] = {
            "WTR197","WTR194","WTR179","WTR211","WTR153","WTR167","WTR049","WTR031","WTR028","WTR063","WTR020","WTR070","WTR110","WTR142","WTR107","WTR077","WTR225"
        },
        -- pack #9 in box #74
        [9] = {
            "WTR216","WTR194","WTR178","WTR193","WTR155","WTR017","WTR166","WTR221","WTR022","WTR070","WTR028","WTR145","WTR112","WTR141","WTR097","WTR225","WTR115"
        },
        -- pack #10 in box #74
        [10] = {
            "WTR213","WTR184","WTR223","WTR220","WTR005","WTR011","WTR018","WTR061","WTR065","WTR024","WTR062","WTR025","WTR143","WTR107","WTR144","WTR003","WTR040"
        },
        -- pack #11 in box #74
        [11] = {
            "WTR193","WTR221","WTR211","WTR179","WTR156","WTR173","WTR055","WTR098","WTR028","WTR066","WTR032","WTR145","WTR096","WTR132","WTR099","WTR001","WTR075"
        },
        -- pack #12 in box #74
        [12] = {
            "WTR216","WTR184","WTR197","WTR181","WTR155","WTR092","WTR164","WTR032","WTR028","WTR065","WTR030","WTR057","WTR111","WTR139","WTR111","WTR077","WTR076"
        },
        -- pack #13 in box #74
        [13] = {
            "WTR198","WTR214","WTR184","WTR180","WTR155","WTR048","WTR172","WTR128","WTR035","WTR073","WTR026","WTR062","WTR112","WTR146","WTR110","WTR038","WTR225"
        },
        -- pack #14 in box #74
        [14] = {
            "WTR215","WTR216","WTR194","WTR185","WTR158","WTR094","WTR122","WTR080","WTR070","WTR033","WTR072","WTR029","WTR132","WTR111","WTR134","WTR001","WTR039"
        },
        -- pack #15 in box #74
        [15] = {
            "WTR208","WTR215","WTR181","WTR202","WTR156","WTR168","WTR130","WTR019","WTR058","WTR033","WTR072","WTR023","WTR147","WTR112","WTR139","WTR038","WTR115"
        },
        -- pack #16 in box #74
        [16] = {
            "WTR211","WTR213","WTR182","WTR206","WTR158","WTR125","WTR017","WTR214","WTR069","WTR031","WTR072","WTR102","WTR142","WTR101","WTR139","WTR114","WTR077"
        },
        -- pack #17 in box #74
        [17] = {
            "WTR190","WTR212","WTR200","WTR223","WTR158","WTR088","WTR093","WTR145","WTR074","WTR032","WTR058","WTR037","WTR133","WTR103","WTR133","WTR002","WTR001"
        },
        -- pack #18 in box #74
        [18] = {
            "WTR207","WTR202","WTR180","WTR181","WTR157","WTR089","WTR122","WTR037","WTR034","WTR065","WTR020","WTR072","WTR097","WTR144","WTR111","WTR075","WTR076"
        },
        -- pack #19 in box #74
        [19] = {
            "WTR194","WTR180","WTR183","WTR201","WTR151","WTR125","WTR119","WTR203","WTR036","WTR061","WTR025","WTR148","WTR102","WTR140","WTR102","WTR040","WTR001"
        },
        -- pack #20 in box #74
        [20] = {
            "WTR190","WTR214","WTR222","WTR190","WTR158","WTR018","WTR091","WTR079","WTR068","WTR020","WTR072","WTR101","WTR132","WTR108","WTR147","WTR078","WTR115"
        },
        -- pack #21 in box #74
        [21] = {
            "WTR187","WTR201","WTR181","WTR182","WTR117","WTR014","WTR019","WTR052","WTR066","WTR033","WTR057","WTR101","WTR139","WTR101","WTR139","WTR076","WTR075"
        },
        -- pack #22 in box #74
        [22] = {
            "WTR195","WTR197","WTR217","WTR199","WTR117","WTR170","WTR055","WTR027","WTR034","WTR065","WTR020","WTR142","WTR098","WTR133","WTR105","WTR075","WTR225"
        },
        -- pack #23 in box #74
        [23] = {
            "WTR195","WTR197","WTR200","WTR215","WTR154","WTR048","WTR007","WTR068","WTR062","WTR036","WTR070","WTR101","WTR138","WTR098","WTR139","WTR075","WTR076"
        },
        -- pack #24 in box #74
        [24] = {
            "WTR220","WTR203","WTR192","WTR193","WTR158","WTR019","WTR163","WTR112","WTR031","WTR067","WTR023","WTR057","WTR104","WTR148","WTR095","WTR225","WTR077"
        },
    },
    -- box #75
    [75] = {
        -- pack #1 in box #75
        [1] = {
            "WTR208","WTR215","WTR204","WTR194","WTR080","WTR129","WTR172","WTR103","WTR063","WTR033","WTR068","WTR028","WTR134","WTR106","WTR135","WTR038","WTR076"
        },
        -- pack #2 in box #75
        [2] = {
            "WTR186","WTR179","WTR195","WTR218","WTR042","WTR124","WTR014","WTR137","WTR028","WTR072","WTR026","WTR057","WTR107","WTR145","WTR096","WTR001","WTR039"
        },
        -- pack #3 in box #75
        [3] = {
            "WTR218","WTR214","WTR222","WTR207","WTR080","WTR094","WTR085","WTR143","WTR069","WTR032","WTR058","WTR030","WTR148","WTR095","WTR149","WTR040","WTR038"
        },
        -- pack #4 in box #75
        [4] = {
            "WTR195","WTR176","WTR178","WTR195","WTR155","WTR018","WTR160","WTR104","WTR070","WTR032","WTR058","WTR106","WTR147","WTR095","WTR142","WTR039","WTR078"
        },
        -- pack #5 in box #75
        [5] = {
            "WTR221","WTR201","WTR197","WTR198","WTR155","WTR124","WTR169","WTR126","WTR025","WTR067","WTR035","WTR074","WTR111","WTR135","WTR100","WTR038","WTR076"
        },
        -- pack #6 in box #75
        [6] = {
            "WTR188","WTR201","WTR218","WTR199","WTR117","WTR173","WTR128","WTR132","WTR025","WTR063","WTR036","WTR059","WTR098","WTR133","WTR111","WTR075","WTR078"
        },
        -- pack #7 in box #75
        [7] = {
            "WTR178","WTR184","WTR187","WTR218","WTR153","WTR123","WTR120","WTR009","WTR057","WTR029","WTR073","WTR105","WTR149","WTR105","WTR141","WTR038","WTR001"
        },
        -- pack #8 in box #75
        [8] = {
            "WTR217","WTR184","WTR197","WTR194","WTR153","WTR165","WTR124","WTR122","WTR070","WTR035","WTR057","WTR107","WTR147","WTR104","WTR147","WTR040","WTR003"
        },
        -- pack #9 in box #75
        [9] = {
            "WTR214","WTR176","WTR205","WTR205","WTR117","WTR174","WTR161","WTR188","WTR057","WTR025","WTR064","WTR030","WTR145","WTR104","WTR148","WTR225","WTR115"
        },
        -- pack #10 in box #75
        [10] = {
            "WTR218","WTR196","WTR217","WTR191","WTR157","WTR056","WTR172","WTR103","WTR022","WTR060","WTR025","WTR061","WTR095","WTR138","WTR101","WTR038","WTR001"
        },
        -- pack #11 in box #75
        [11] = {
            "WTR179","WTR208","WTR218","WTR214","WTR153","WTR014","WTR123","WTR188","WTR069","WTR029","WTR064","WTR096","WTR136","WTR103","WTR142","WTR114","WTR038"
        },
        -- pack #12 in box #75
        [12] = {
            "WTR201","WTR199","WTR219","WTR207","WTR080","WTR049","WTR164","WTR105","WTR023","WTR062","WTR029","WTR134","WTR103","WTR134","WTR104","WTR225","WTR003"
        },
        -- pack #13 in box #75
        [13] = {
            "WTR196","WTR210","WTR217","WTR190","WTR154","WTR166","WTR092","WTR026","WTR024","WTR067","WTR027","WTR137","WTR108","WTR140","WTR106","WTR225","WTR077"
        },
        -- pack #14 in box #75
        [14] = {
            "WTR211","WTR218","WTR222","WTR211","WTR042","WTR019","WTR159","WTR020","WTR034","WTR064","WTR037","WTR134","WTR104","WTR142","WTR095","WTR001","WTR078"
        },
        -- pack #15 in box #75
        [15] = {
            "WTR212","WTR197","WTR203","WTR217","WTR152","WTR052","WTR054","WTR105","WTR058","WTR025","WTR060","WTR097","WTR135","WTR109","WTR132","WTR113","WTR002"
        },
        -- pack #16 in box #75
        [16] = {
            "WTR199","WTR200","WTR212","WTR210","WTR157","WTR052","WTR175","WTR133","WTR064","WTR037","WTR059","WTR020","WTR141","WTR099","WTR133","WTR113","WTR075"
        },
        -- pack #17 in box #75
        [17] = {
            "WTR202","WTR219","WTR191","WTR214","WTR151","WTR017","WTR090","WTR123","WTR034","WTR061","WTR020","WTR135","WTR112","WTR134","WTR096","WTR003","WTR040"
        },
        -- pack #18 in box #75
        [18] = {
            "WTR204","WTR208","WTR223","WTR183","WTR158","WTR172","WTR012","WTR026","WTR063","WTR030","WTR061","WTR020","WTR134","WTR098","WTR135","WTR040","WTR225"
        },
        -- pack #19 in box #75
        [19] = {
            "WTR177","WTR187","WTR200","WTR186","WTR153","WTR165","WTR172","WTR132","WTR028","WTR068","WTR029","WTR141","WTR106","WTR132","WTR111","WTR038","WTR075"
        },
        -- pack #20 in box #75
        [20] = {
            "WTR207","WTR178","WTR201","WTR179","WTR155","WTR125","WTR019","WTR204","WTR069","WTR020","WTR059","WTR110","WTR149","WTR096","WTR138","WTR115","WTR040"
        },
        -- pack #21 in box #75
        [21] = {
            "WTR221","WTR207","WTR185","WTR202","WTR005","WTR016","WTR173","WTR024","WTR033","WTR070","WTR031","WTR074","WTR109","WTR141","WTR107","WTR003","WTR115"
        },
        -- pack #22 in box #75
        [22] = {
            "WTR196","WTR219","WTR188","WTR223","WTR005","WTR167","WTR170","WTR022","WTR070","WTR028","WTR063","WTR030","WTR132","WTR109","WTR149","WTR224"
        },
        -- pack #23 in box #75
        [23] = {
            "WTR223","WTR219","WTR218","WTR208","WTR005","WTR048","WTR088","WTR108","WTR030","WTR065","WTR024","WTR145","WTR099","WTR144","WTR110","WTR001","WTR002"
        },
        -- pack #24 in box #75
        [24] = {
            "WTR207","WTR177","WTR180","WTR186","WTR156","WTR049","WTR130","WTR015","WTR028","WTR070","WTR028","WTR062","WTR104","WTR144","WTR095","WTR114","WTR003"
        },
    },
    -- box #76
    [76] = {
        -- pack #1 in box #76
        [1] = {
            "WTR220","WTR215","WTR189","WTR201","WTR152","WTR012","WTR087","WTR021","WTR033","WTR072","WTR036","WTR059","WTR112","WTR141","WTR105","WTR001","WTR077"
        },
        -- pack #2 in box #76
        [2] = {
            "WTR220","WTR187","WTR180","WTR191","WTR005","WTR131","WTR094","WTR051","WTR064","WTR037","WTR072","WTR026","WTR133","WTR106","WTR141","WTR001","WTR076"
        },
        -- pack #3 in box #76
        [3] = {
            "WTR198","WTR181","WTR196","WTR189","WTR154","WTR013","WTR170","WTR032","WTR072","WTR023","WTR067","WTR095","WTR133","WTR108","WTR140","WTR075","WTR003"
        },
        -- pack #4 in box #76
        [4] = {
            "WTR178","WTR189","WTR204","WTR178","WTR117","WTR050","WTR092","WTR030","WTR037","WTR066","WTR026","WTR059","WTR112","WTR148","WTR107","WTR076","WTR113"
        },
        -- pack #5 in box #76
        [5] = {
            "WTR210","WTR192","WTR217","WTR209","WTR157","WTR129","WTR014","WTR097","WTR064","WTR025","WTR065","WTR102","WTR136","WTR098","WTR135","WTR225","WTR039"
        },
        -- pack #6 in box #76
        [6] = {
            "WTR215","WTR218","WTR201","WTR195","WTR117","WTR048","WTR164","WTR198","WTR065","WTR032","WTR061","WTR095","WTR136","WTR108","WTR134","WTR039","WTR001"
        },
        -- pack #7 in box #76
        [7] = {
            "WTR210","WTR195","WTR217","WTR216","WTR156","WTR126","WTR009","WTR206","WTR058","WTR026","WTR074","WTR036","WTR135","WTR101","WTR140","WTR224"
        },
        -- pack #8 in box #76
        [8] = {
            "WTR204","WTR199","WTR202","WTR208","WTR153","WTR092","WTR127","WTR106","WTR032","WTR059","WTR035","WTR134","WTR100","WTR142","WTR112","WTR224"
        },
        -- pack #9 in box #76
        [9] = {
            "WTR181","WTR207","WTR214","WTR204","WTR042","WTR168","WTR173","WTR184","WTR036","WTR074","WTR020","WTR059","WTR103","WTR145","WTR108","WTR040","WTR078"
        },
        -- pack #10 in box #76
        [10] = {
            "WTR196","WTR187","WTR181","WTR222","WTR155","WTR127","WTR170","WTR141","WTR034","WTR071","WTR036","WTR142","WTR112","WTR141","WTR098","WTR114","WTR225"
        },
        -- pack #11 in box #76
        [11] = {
            "WTR206","WTR204","WTR214","WTR187","WTR152","WTR091","WTR175","WTR025","WTR022","WTR070","WTR036","WTR147","WTR099","WTR136","WTR109","WTR002","WTR113"
        },
        -- pack #12 in box #76
        [12] = {
            "WTR218","WTR194","WTR204","WTR223","WTR157","WTR094","WTR045","WTR127","WTR021","WTR074","WTR036","WTR057","WTR097","WTR137","WTR112","WTR225","WTR077"
        },
        -- pack #13 in box #76
        [13] = {
            "WTR197","WTR223","WTR221","WTR195","WTR080","WTR017","WTR049","WTR213","WTR069","WTR037","WTR074","WTR026","WTR138","WTR104","WTR149","WTR075","WTR038"
        },
        -- pack #14 in box #76
        [14] = {
            "WTR180","WTR189","WTR193","WTR204","WTR042","WTR012","WTR160","WTR207","WTR062","WTR037","WTR062","WTR032","WTR143","WTR103","WTR136","WTR003","WTR078"
        },
        -- pack #15 in box #76
        [15] = {
            "WTR215","WTR211","WTR205","WTR207","WTR005","WTR125","WTR131","WTR058","WTR036","WTR062","WTR021","WTR136","WTR097","WTR148","WTR099","WTR225","WTR113"
        },
        -- pack #16 in box #76
        [16] = {
            "WTR208","WTR190","WTR210","WTR191","WTR080","WTR092","WTR009","WTR186","WTR028","WTR063","WTR023","WTR071","WTR102","WTR148","WTR109","WTR077","WTR078"
        },
        -- pack #17 in box #76
        [17] = {
            "WTR198","WTR186","WTR194","WTR209","WTR153","WTR012","WTR013","WTR123","WTR025","WTR062","WTR021","WTR061","WTR110","WTR138","WTR097","WTR075","WTR003"
        },
        -- pack #18 in box #76
        [18] = {
            "WTR179","WTR206","WTR211","WTR187","WTR155","WTR126","WTR130","WTR091","WTR066","WTR020","WTR061","WTR036","WTR146","WTR109","WTR137","WTR001","WTR115"
        },
        -- pack #19 in box #76
        [19] = {
            "WTR219","WTR176","WTR198","WTR184","WTR005","WTR092","WTR160","WTR219","WTR064","WTR021","WTR068","WTR103","WTR132","WTR110","WTR142","WTR039","WTR001"
        },
        -- pack #20 in box #76
        [20] = {
            "WTR214","WTR182","WTR196","WTR216","WTR157","WTR051","WTR015","WTR206","WTR022","WTR057","WTR034","WTR144","WTR097","WTR140","WTR108","WTR075","WTR076"
        },
        -- pack #21 in box #76
        [21] = {
            "WTR217","WTR200","WTR179","WTR199","WTR157","WTR169","WTR018","WTR009","WTR066","WTR021","WTR072","WTR107","WTR144","WTR105","WTR139","WTR076","WTR002"
        },
        -- pack #22 in box #76
        [22] = {
            "WTR200","WTR200","WTR218","WTR179","WTR158","WTR052","WTR055","WTR133","WTR025","WTR068","WTR021","WTR137","WTR107","WTR147","WTR105","WTR078","WTR038"
        },
        -- pack #23 in box #76
        [23] = {
            "WTR202","WTR177","WTR181","WTR188","WTR080","WTR014","WTR010","WTR213","WTR068","WTR026","WTR073","WTR020","WTR139","WTR100","WTR139","WTR224"
        },
        -- pack #24 in box #76
        [24] = {
            "WTR210","WTR212","WTR209","WTR220","WTR157","WTR131","WTR012","WTR185","WTR061","WTR034","WTR062","WTR105","WTR137","WTR111","WTR143","WTR003","WTR113"
        },
    },
    -- box #77
    [77] = {
        -- pack #1 in box #77
        [1] = {
            "WTR196","WTR179","WTR193","WTR197","WTR157","WTR093","WTR128","WTR189","WTR066","WTR036","WTR070","WTR030","WTR142","WTR108","WTR147","WTR224"
        },
        -- pack #2 in box #77
        [2] = {
            "WTR180","WTR209","WTR185","WTR187","WTR152","WTR168","WTR091","WTR096","WTR059","WTR031","WTR070","WTR112","WTR144","WTR102","WTR138","WTR077","WTR225"
        },
        -- pack #3 in box #77
        [3] = {
            "WTR203","WTR203","WTR206","WTR217","WTR152","WTR130","WTR085","WTR138","WTR068","WTR037","WTR066","WTR026","WTR135","WTR111","WTR144","WTR077","WTR114"
        },
        -- pack #4 in box #77
        [4] = {
            "WTR220","WTR182","WTR195","WTR202","WTR151","WTR123","WTR088","WTR152","WTR025","WTR061","WTR029","WTR148","WTR096","WTR137","WTR095","WTR075","WTR115"
        },
        -- pack #5 in box #77
        [5] = {
            "WTR180","WTR190","WTR180","WTR199","WTR153","WTR128","WTR014","WTR109","WTR060","WTR029","WTR065","WTR021","WTR149","WTR100","WTR139","WTR078","WTR114"
        },
        -- pack #6 in box #77
        [6] = {
            "WTR204","WTR180","WTR183","WTR183","WTR157","WTR091","WTR016","WTR087","WTR027","WTR062","WTR027","WTR145","WTR096","WTR138","WTR102","WTR039","WTR003"
        },
        -- pack #7 in box #77
        [7] = {
            "WTR223","WTR195","WTR190","WTR183","WTR158","WTR166","WTR167","WTR073","WTR033","WTR067","WTR036","WTR134","WTR105","WTR140","WTR102","WTR002","WTR003"
        },
        -- pack #8 in box #77
        [8] = {
            "WTR221","WTR182","WTR188","WTR216","WTR005","WTR019","WTR167","WTR047","WTR070","WTR030","WTR059","WTR030","WTR146","WTR097","WTR140","WTR001","WTR039"
        },
        -- pack #9 in box #77
        [9] = {
            "WTR180","WTR206","WTR198","WTR186","WTR151","WTR090","WTR051","WTR099","WTR020","WTR068","WTR037","WTR067","WTR112","WTR144","WTR107","WTR039","WTR038"
        },
        -- pack #10 in box #77
        [10] = {
            "WTR176","WTR177","WTR185","WTR178","WTR117","WTR018","WTR126","WTR177","WTR023","WTR061","WTR028","WTR057","WTR111","WTR144","WTR096","WTR225","WTR040"
        },
        -- pack #11 in box #77
        [11] = {
            "WTR183","WTR195","WTR222","WTR180","WTR153","WTR016","WTR054","WTR206","WTR070","WTR024","WTR074","WTR095","WTR133","WTR112","WTR145","WTR003","WTR077"
        },
        -- pack #12 in box #77
        [12] = {
            "WTR217","WTR182","WTR215","WTR223","WTR080","WTR167","WTR083","WTR027","WTR066","WTR032","WTR070","WTR033","WTR143","WTR096","WTR132","WTR114","WTR002"
        },
        -- pack #13 in box #77
        [13] = {
            "WTR202","WTR183","WTR179","WTR198","WTR042","WTR166","WTR017","WTR095","WTR021","WTR071","WTR032","WTR057","WTR096","WTR146","WTR098","WTR001","WTR077"
        },
        -- pack #14 in box #77
        [14] = {
            "WTR186","WTR216","WTR221","WTR221","WTR152","WTR094","WTR083","WTR093","WTR064","WTR033","WTR064","WTR112","WTR146","WTR100","WTR135","WTR076","WTR040"
        },
        -- pack #15 in box #77
        [15] = {
            "WTR188","WTR216","WTR222","WTR211","WTR152","WTR164","WTR175","WTR178","WTR024","WTR073","WTR023","WTR132","WTR097","WTR141","WTR112","WTR077","WTR040"
        },
        -- pack #16 in box #77
        [16] = {
            "WTR220","WTR217","WTR208","WTR219","WTR005","WTR087","WTR163","WTR016","WTR058","WTR031","WTR070","WTR096","WTR134","WTR106","WTR142","WTR113","WTR114"
        },
        -- pack #17 in box #77
        [17] = {
            "WTR185","WTR196","WTR197","WTR192","WTR157","WTR053","WTR015","WTR029","WTR033","WTR059","WTR026","WTR061","WTR104","WTR142","WTR108","WTR001","WTR114"
        },
        -- pack #18 in box #77
        [18] = {
            "WTR201","WTR197","WTR194","WTR194","WTR151","WTR015","WTR092","WTR094","WTR034","WTR060","WTR032","WTR061","WTR095","WTR149","WTR102","WTR114","WTR076"
        },
        -- pack #19 in box #77
        [19] = {
            "WTR200","WTR204","WTR221","WTR205","WTR154","WTR126","WTR091","WTR146","WTR062","WTR035","WTR059","WTR032","WTR146","WTR096","WTR147","WTR224"
        },
        -- pack #20 in box #77
        [20] = {
            "WTR176","WTR187","WTR176","WTR178","WTR117","WTR123","WTR118","WTR170","WTR058","WTR025","WTR071","WTR102","WTR142","WTR100","WTR137","WTR114","WTR113"
        },
        -- pack #21 in box #77
        [21] = {
            "WTR179","WTR213","WTR181","WTR194","WTR005","WTR050","WTR168","WTR220","WTR024","WTR061","WTR026","WTR072","WTR110","WTR144","WTR107","WTR040","WTR038"
        },
        -- pack #22 in box #77
        [22] = {
            "WTR207","WTR185","WTR207","WTR213","WTR156","WTR164","WTR019","WTR034","WTR037","WTR069","WTR033","WTR141","WTR099","WTR148","WTR103","WTR225","WTR039"
        },
        -- pack #23 in box #77
        [23] = {
            "WTR221","WTR177","WTR223","WTR180","WTR151","WTR128","WTR168","WTR182","WTR021","WTR062","WTR023","WTR134","WTR103","WTR140","WTR096","WTR078","WTR003"
        },
        -- pack #24 in box #77
        [24] = {
            "WTR210","WTR212","WTR178","WTR190","WTR158","WTR091","WTR127","WTR132","WTR069","WTR032","WTR071","WTR102","WTR147","WTR111","WTR145","WTR002","WTR114"
        },
    },
    -- box #78
    [78] = {
        -- pack #1 in box #78
        [1] = {
            "WTR193","WTR203","WTR220","WTR201","WTR157","WTR124","WTR083","WTR218","WTR060","WTR031","WTR058","WTR096","WTR147","WTR104","WTR140","WTR039","WTR114"
        },
        -- pack #2 in box #78
        [2] = {
            "WTR193","WTR212","WTR220","WTR196","WTR157","WTR092","WTR092","WTR106","WTR060","WTR032","WTR064","WTR110","WTR141","WTR097","WTR142","WTR115","WTR038"
        },
        -- pack #3 in box #78
        [3] = {
            "WTR198","WTR221","WTR178","WTR194","WTR117","WTR015","WTR127","WTR135","WTR028","WTR057","WTR023","WTR070","WTR100","WTR148","WTR096","WTR039","WTR078"
        },
        -- pack #4 in box #78
        [4] = {
            "WTR217","WTR214","WTR185","WTR203","WTR042","WTR092","WTR129","WTR196","WTR033","WTR066","WTR035","WTR068","WTR099","WTR138","WTR103","WTR225","WTR115"
        },
        -- pack #5 in box #78
        [5] = {
            "WTR198","WTR187","WTR220","WTR208","WTR153","WTR054","WTR169","WTR024","WTR024","WTR070","WTR022","WTR074","WTR112","WTR135","WTR095","WTR114","WTR002"
        },
        -- pack #6 in box #78
        [6] = {
            "WTR189","WTR213","WTR206","WTR182","WTR157","WTR128","WTR048","WTR138","WTR028","WTR063","WTR035","WTR133","WTR105","WTR144","WTR100","WTR040","WTR003"
        },
        -- pack #7 in box #78
        [7] = {
            "WTR215","WTR176","WTR188","WTR200","WTR158","WTR094","WTR048","WTR036","WTR028","WTR063","WTR035","WTR070","WTR111","WTR133","WTR098","WTR040","WTR113"
        },
        -- pack #8 in box #78
        [8] = {
            "WTR188","WTR218","WTR203","WTR184","WTR153","WTR172","WTR122","WTR140","WTR029","WTR067","WTR037","WTR148","WTR097","WTR148","WTR098","WTR113","WTR002"
        },
        -- pack #9 in box #78
        [9] = {
            "WTR184","WTR189","WTR205","WTR177","WTR117","WTR089","WTR128","WTR209","WTR033","WTR070","WTR023","WTR141","WTR110","WTR132","WTR110","WTR224"
        },
        -- pack #10 in box #78
        [10] = {
            "WTR181","WTR219","WTR192","WTR207","WTR151","WTR130","WTR130","WTR013","WTR068","WTR037","WTR066","WTR103","WTR140","WTR107","WTR138","WTR115","WTR002"
        },
        -- pack #11 in box #78
        [11] = {
            "WTR191","WTR193","WTR206","WTR216","WTR154","WTR172","WTR091","WTR011","WTR025","WTR070","WTR024","WTR069","WTR110","WTR132","WTR103","WTR078","WTR225"
        },
        -- pack #12 in box #78
        [12] = {
            "WTR193","WTR179","WTR188","WTR198","WTR005","WTR124","WTR050","WTR130","WTR059","WTR034","WTR073","WTR034","WTR141","WTR110","WTR140","WTR075","WTR001"
        },
        -- pack #13 in box #78
        [13] = {
            "WTR186","WTR202","WTR200","WTR182","WTR158","WTR089","WTR173","WTR151","WTR058","WTR034","WTR073","WTR107","WTR136","WTR100","WTR133","WTR038","WTR075"
        },
        -- pack #14 in box #78
        [14] = {
            "WTR209","WTR184","WTR219","WTR219","WTR152","WTR092","WTR131","WTR062","WTR061","WTR026","WTR067","WTR028","WTR148","WTR103","WTR144","WTR224"
        },
        -- pack #15 in box #78
        [15] = {
            "WTR183","WTR213","WTR199","WTR212","WTR151","WTR017","WTR045","WTR200","WTR061","WTR033","WTR068","WTR031","WTR145","WTR107","WTR138","WTR039","WTR114"
        },
        -- pack #16 in box #78
        [16] = {
            "WTR183","WTR205","WTR217","WTR206","WTR080","WTR125","WTR019","WTR147","WTR069","WTR030","WTR071","WTR031","WTR145","WTR099","WTR138","WTR003","WTR114"
        },
        -- pack #17 in box #78
        [17] = {
            "WTR204","WTR191","WTR207","WTR178","WTR152","WTR048","WTR122","WTR208","WTR058","WTR028","WTR058","WTR098","WTR133","WTR101","WTR149","WTR002","WTR115"
        },
        -- pack #18 in box #78
        [18] = {
            "WTR204","WTR206","WTR209","WTR187","WTR158","WTR128","WTR174","WTR131","WTR067","WTR034","WTR064","WTR020","WTR143","WTR109","WTR148","WTR002","WTR113"
        },
        -- pack #19 in box #78
        [19] = {
            "WTR222","WTR184","WTR192","WTR219","WTR005","WTR051","WTR012","WTR157","WTR031","WTR070","WTR027","WTR138","WTR108","WTR143","WTR100","WTR224"
        },
        -- pack #20 in box #78
        [20] = {
            "WTR190","WTR184","WTR176","WTR190","WTR080","WTR055","WTR011","WTR216","WTR037","WTR059","WTR020","WTR142","WTR105","WTR132","WTR099","WTR003","WTR002"
        },
        -- pack #21 in box #78
        [21] = {
            "WTR192","WTR222","WTR210","WTR183","WTR152","WTR015","WTR123","WTR098","WTR074","WTR034","WTR060","WTR037","WTR137","WTR112","WTR149","WTR114","WTR075"
        },
        -- pack #22 in box #78
        [22] = {
            "WTR199","WTR197","WTR221","WTR213","WTR080","WTR170","WTR049","WTR117","WTR068","WTR037","WTR072","WTR112","WTR137","WTR101","WTR139","WTR115","WTR113"
        },
        -- pack #23 in box #78
        [23] = {
            "WTR211","WTR177","WTR194","WTR211","WTR080","WTR131","WTR055","WTR035","WTR037","WTR072","WTR025","WTR060","WTR101","WTR142","WTR103","WTR115","WTR003"
        },
        -- pack #24 in box #78
        [24] = {
            "WTR195","WTR194","WTR211","WTR176","WTR080","WTR086","WTR126","WTR201","WTR032","WTR072","WTR021","WTR142","WTR102","WTR148","WTR102","WTR002","WTR075"
        },
    },
    -- box #79
    [79] = {
        -- pack #1 in box #79
        [1] = {
            "WTR176","WTR212","WTR211","WTR187","WTR080","WTR172","WTR166","WTR222","WTR069","WTR030","WTR071","WTR096","WTR147","WTR096","WTR143","WTR038","WTR001"
        },
        -- pack #2 in box #79
        [2] = {
            "WTR196","WTR190","WTR201","WTR217","WTR005","WTR011","WTR168","WTR087","WTR036","WTR071","WTR035","WTR058","WTR097","WTR141","WTR105","WTR001","WTR075"
        },
        -- pack #3 in box #79
        [3] = {
            "WTR211","WTR184","WTR202","WTR191","WTR042","WTR123","WTR125","WTR218","WTR021","WTR067","WTR036","WTR068","WTR100","WTR136","WTR110","WTR225","WTR077"
        },
        -- pack #4 in box #79
        [4] = {
            "WTR213","WTR196","WTR185","WTR194","WTR117","WTR125","WTR130","WTR184","WTR026","WTR069","WTR024","WTR062","WTR097","WTR139","WTR102","WTR002","WTR075"
        },
        -- pack #5 in box #79
        [5] = {
            "WTR203","WTR222","WTR180","WTR215","WTR154","WTR128","WTR045","WTR176","WTR033","WTR066","WTR036","WTR142","WTR110","WTR143","WTR095","WTR039","WTR003"
        },
        -- pack #6 in box #79
        [6] = {
            "WTR179","WTR176","WTR209","WTR202","WTR117","WTR124","WTR121","WTR201","WTR034","WTR071","WTR035","WTR072","WTR111","WTR143","WTR109","WTR224"
        },
        -- pack #7 in box #79
        [7] = {
            "WTR189","WTR183","WTR202","WTR218","WTR117","WTR169","WTR162","WTR152","WTR024","WTR071","WTR037","WTR147","WTR112","WTR136","WTR098","WTR225","WTR002"
        },
        -- pack #8 in box #79
        [8] = {
            "WTR198","WTR204","WTR199","WTR187","WTR151","WTR131","WTR050","WTR177","WTR068","WTR030","WTR073","WTR028","WTR142","WTR099","WTR134","WTR115","WTR225"
        },
        -- pack #9 in box #79
        [9] = {
            "WTR209","WTR195","WTR186","WTR215","WTR155","WTR088","WTR053","WTR090","WTR060","WTR034","WTR062","WTR105","WTR132","WTR105","WTR148","WTR002","WTR113"
        },
        -- pack #10 in box #79
        [10] = {
            "WTR196","WTR183","WTR194","WTR199","WTR151","WTR130","WTR043","WTR155","WTR063","WTR027","WTR074","WTR031","WTR145","WTR100","WTR142","WTR078","WTR075"
        },
        -- pack #11 in box #79
        [11] = {
            "WTR197","WTR176","WTR219","WTR207","WTR155","WTR092","WTR010","WTR193","WTR059","WTR037","WTR064","WTR024","WTR147","WTR103","WTR142","WTR038","WTR113"
        },
        -- pack #12 in box #79
        [12] = {
            "WTR188","WTR195","WTR194","WTR210","WTR155","WTR050","WTR017","WTR186","WTR070","WTR031","WTR071","WTR023","WTR148","WTR101","WTR140","WTR075","WTR077"
        },
        -- pack #13 in box #79
        [13] = {
            "WTR220","WTR210","WTR191","WTR223","WTR155","WTR055","WTR172","WTR069","WTR032","WTR064","WTR024","WTR071","WTR096","WTR135","WTR096","WTR076","WTR001"
        },
        -- pack #14 in box #79
        [14] = {
            "WTR189","WTR210","WTR199","WTR221","WTR151","WTR130","WTR047","WTR198","WTR028","WTR061","WTR035","WTR133","WTR108","WTR137","WTR102","WTR115","WTR040"
        },
        -- pack #15 in box #79
        [15] = {
            "WTR183","WTR216","WTR207","WTR181","WTR155","WTR016","WTR094","WTR183","WTR068","WTR037","WTR074","WTR102","WTR134","WTR101","WTR145","WTR003","WTR225"
        },
        -- pack #16 in box #79
        [16] = {
            "WTR180","WTR218","WTR222","WTR211","WTR152","WTR012","WTR015","WTR122","WTR062","WTR028","WTR062","WTR030","WTR144","WTR100","WTR137","WTR038","WTR114"
        },
        -- pack #17 in box #79
        [17] = {
            "WTR197","WTR222","WTR178","WTR218","WTR152","WTR053","WTR124","WTR142","WTR063","WTR030","WTR058","WTR033","WTR139","WTR105","WTR141","WTR002","WTR113"
        },
        -- pack #18 in box #79
        [18] = {
            "WTR182","WTR211","WTR205","WTR194","WTR042","WTR129","WTR127","WTR201","WTR066","WTR035","WTR067","WTR108","WTR140","WTR111","WTR141","WTR115","WTR076"
        },
        -- pack #19 in box #79
        [19] = {
            "WTR213","WTR214","WTR211","WTR205","WTR042","WTR094","WTR173","WTR183","WTR020","WTR061","WTR020","WTR143","WTR100","WTR146","WTR097","WTR001","WTR076"
        },
        -- pack #20 in box #79
        [20] = {
            "WTR216","WTR209","WTR213","WTR196","WTR152","WTR171","WTR160","WTR145","WTR023","WTR063","WTR030","WTR139","WTR104","WTR146","WTR097","WTR078","WTR038"
        },
        -- pack #21 in box #79
        [21] = {
            "WTR196","WTR207","WTR189","WTR211","WTR156","WTR092","WTR056","WTR025","WTR030","WTR069","WTR023","WTR134","WTR098","WTR137","WTR107","WTR115","WTR038"
        },
        -- pack #22 in box #79
        [22] = {
            "WTR184","WTR193","WTR184","WTR200","WTR155","WTR166","WTR056","WTR111","WTR073","WTR028","WTR074","WTR102","WTR142","WTR106","WTR146","WTR077","WTR115"
        },
        -- pack #23 in box #79
        [23] = {
            "WTR182","WTR223","WTR216","WTR193","WTR155","WTR129","WTR055","WTR045","WTR020","WTR070","WTR035","WTR065","WTR108","WTR139","WTR095","WTR038","WTR075"
        },
        -- pack #24 in box #79
        [24] = {
            "WTR195","WTR202","WTR202","WTR213","WTR080","WTR015","WTR094","WTR148","WTR057","WTR035","WTR064","WTR098","WTR149","WTR109","WTR147","WTR077","WTR002"
        },
    },
    -- box #80
    [80] = {
        -- pack #1 in box #80
        [1] = {
            "WTR178","WTR222","WTR195","WTR196","WTR155","WTR018","WTR126","WTR140","WTR073","WTR025","WTR063","WTR103","WTR134","WTR108","WTR149","WTR076","WTR040"
        },
        -- pack #2 in box #80
        [2] = {
            "WTR207","WTR196","WTR223","WTR200","WTR080","WTR125","WTR052","WTR104","WTR071","WTR031","WTR070","WTR026","WTR144","WTR109","WTR140","WTR038","WTR077"
        },
        -- pack #3 in box #80
        [3] = {
            "WTR182","WTR188","WTR208","WTR182","WTR042","WTR014","WTR124","WTR170","WTR074","WTR037","WTR067","WTR099","WTR143","WTR099","WTR139","WTR078","WTR114"
        },
        -- pack #4 in box #80
        [4] = {
            "WTR177","WTR219","WTR204","WTR215","WTR151","WTR164","WTR168","WTR202","WTR027","WTR065","WTR030","WTR149","WTR096","WTR134","WTR101","WTR039","WTR078"
        },
        -- pack #5 in box #80
        [5] = {
            "WTR203","WTR193","WTR189","WTR206","WTR152","WTR086","WTR129","WTR167","WTR030","WTR060","WTR031","WTR137","WTR102","WTR141","WTR109","WTR077","WTR003"
        },
        -- pack #6 in box #80
        [6] = {
            "WTR200","WTR215","WTR181","WTR180","WTR080","WTR016","WTR049","WTR155","WTR071","WTR030","WTR061","WTR111","WTR149","WTR107","WTR145","WTR113","WTR075"
        },
        -- pack #7 in box #80
        [7] = {
            "WTR200","WTR210","WTR199","WTR181","WTR156","WTR018","WTR173","WTR072","WTR057","WTR024","WTR061","WTR037","WTR141","WTR111","WTR140","WTR225","WTR077"
        },
        -- pack #8 in box #80
        [8] = {
            "WTR183","WTR222","WTR190","WTR205","WTR151","WTR093","WTR018","WTR162","WTR022","WTR064","WTR032","WTR073","WTR112","WTR142","WTR108","WTR040","WTR076"
        },
        -- pack #9 in box #80
        [9] = {
            "WTR186","WTR190","WTR209","WTR198","WTR151","WTR128","WTR055","WTR079","WTR036","WTR064","WTR022","WTR145","WTR100","WTR143","WTR096","WTR115","WTR076"
        },
        -- pack #10 in box #80
        [10] = {
            "WTR196","WTR205","WTR202","WTR216","WTR151","WTR173","WTR128","WTR142","WTR032","WTR059","WTR024","WTR137","WTR106","WTR137","WTR099","WTR078","WTR003"
        },
        -- pack #11 in box #80
        [11] = {
            "WTR214","WTR183","WTR223","WTR184","WTR042","WTR053","WTR092","WTR090","WTR020","WTR069","WTR035","WTR068","WTR097","WTR132","WTR098","WTR115","WTR039"
        },
        -- pack #12 in box #80
        [12] = {
            "WTR222","WTR211","WTR205","WTR187","WTR153","WTR173","WTR011","WTR034","WTR037","WTR069","WTR032","WTR068","WTR097","WTR144","WTR101","WTR038","WTR076"
        },
        -- pack #13 in box #80
        [13] = {
            "WTR218","WTR193","WTR221","WTR204","WTR157","WTR016","WTR120","WTR218","WTR020","WTR071","WTR020","WTR146","WTR098","WTR142","WTR095","WTR115","WTR113"
        },
        -- pack #14 in box #80
        [14] = {
            "WTR209","WTR187","WTR204","WTR181","WTR152","WTR011","WTR126","WTR210","WTR070","WTR032","WTR059","WTR108","WTR142","WTR099","WTR147","WTR078","WTR040"
        },
        -- pack #15 in box #80
        [15] = {
            "WTR186","WTR183","WTR196","WTR207","WTR156","WTR053","WTR127","WTR167","WTR066","WTR036","WTR073","WTR026","WTR142","WTR102","WTR134","WTR078","WTR114"
        },
        -- pack #16 in box #80
        [16] = {
            "WTR218","WTR190","WTR199","WTR219","WTR080","WTR172","WTR166","WTR086","WTR024","WTR066","WTR021","WTR136","WTR098","WTR137","WTR106","WTR002","WTR040"
        },
        -- pack #17 in box #80
        [17] = {
            "WTR212","WTR204","WTR215","WTR218","WTR154","WTR164","WTR049","WTR015","WTR031","WTR067","WTR028","WTR069","WTR096","WTR149","WTR098","WTR038","WTR078"
        },
        -- pack #18 in box #80
        [18] = {
            "WTR191","WTR188","WTR194","WTR190","WTR155","WTR165","WTR043","WTR032","WTR062","WTR022","WTR058","WTR029","WTR147","WTR101","WTR149","WTR038","WTR040"
        },
        -- pack #19 in box #80
        [19] = {
            "WTR194","WTR212","WTR197","WTR200","WTR151","WTR126","WTR013","WTR141","WTR022","WTR059","WTR020","WTR058","WTR111","WTR141","WTR100","WTR114","WTR076"
        },
        -- pack #20 in box #80
        [20] = {
            "WTR186","WTR205","WTR209","WTR186","WTR157","WTR091","WTR166","WTR180","WTR062","WTR025","WTR064","WTR107","WTR148","WTR099","WTR135","WTR003","WTR077"
        },
        -- pack #21 in box #80
        [21] = {
            "WTR182","WTR196","WTR186","WTR213","WTR117","WTR013","WTR090","WTR210","WTR073","WTR037","WTR061","WTR103","WTR136","WTR108","WTR142","WTR076","WTR225"
        },
        -- pack #22 in box #80
        [22] = {
            "WTR189","WTR222","WTR207","WTR194","WTR156","WTR168","WTR044","WTR028","WTR031","WTR071","WTR035","WTR060","WTR110","WTR147","WTR104","WTR113","WTR076"
        },
        -- pack #23 in box #80
        [23] = {
            "WTR211","WTR203","WTR211","WTR208","WTR151","WTR124","WTR052","WTR018","WTR072","WTR026","WTR062","WTR029","WTR136","WTR110","WTR137","WTR115","WTR077"
        },
        -- pack #24 in box #80
        [24] = {
            "WTR202","WTR219","WTR206","WTR183","WTR157","WTR049","WTR174","WTR059","WTR062","WTR030","WTR059","WTR032","WTR143","WTR102","WTR144","WTR224"
        },
    },
}

arc_boxes = {
    -- box #1
    [1] = {
        -- pack #1 in box #1
        [1] = {
            "ARC198","ARC181","ARC198","ARC201","ARC015","ARC121","ARC173","ARC157","ARC023","ARC066","ARC023","ARC138","ARC098","ARC141","ARC107","ARC003","ARC002"
        },
        -- pack #2 in box #1
        [2] = {
            "ARC201","ARC202","ARC180","ARC199","ARC056","ARC046","ARC031","ARC155","ARC064","ARC032","ARC069","ARC111","ARC138","ARC109","ARC134","ARC115","ARC077"
        },
        -- pack #3 in box #1
        [3] = {
            "ARC199","ARC198","ARC202","ARC188","ARC058","ARC173","ARC135","ARC152","ARC023","ARC070","ARC026","ARC137","ARC099","ARC133","ARC111","ARC003","ARC076"
        },
        -- pack #4 in box #1
        [4] = {
            "ARC178","ARC190","ARC182","ARC193","ARC054","ARC127","ARC170","ARC151","ARC070","ARC028","ARC073","ARC100","ARC149","ARC099","ARC148","ARC077","ARC039"
        },
        -- pack #5 in box #1
        [5] = {
            "ARC180","ARC209","ARC184","ARC213","ARC131","ARC129","ARC147","ARC156","ARC060","ARC034","ARC071","ARC020","ARC133","ARC100","ARC132","ARC077","ARC076"
        },
        -- pack #6 in box #1
        [6] = {
            "ARC217","ARC194","ARC203","ARC212","ARC085","ARC169","ARC090","ARC155","ARC024","ARC074","ARC027","ARC071","ARC103","ARC135","ARC094","ARC039","ARC001"
        },
        -- pack #7 in box #1
        [7] = {
            "ARC210","ARC217","ARC202","ARC181","ARC130","ARC128","ARC031","ARC079","ARC070","ARC035","ARC063","ARC030","ARC145","ARC107","ARC134","ARC040","ARC075"
        },
        -- pack #8 in box #1
        [8] = {
            "ARC188","ARC186","ARC181","ARC179","ARC053","ARC045","ARC211","ARC005","ARC020","ARC072","ARC033","ARC067","ARC106","ARC145","ARC102","ARC002","ARC040"
        },
        -- pack #9 in box #1
        [9] = {
            "ARC203","ARC201","ARC178","ARC195","ARC170","ARC046","ARC199","ARC005","ARC062","ARC023","ARC074","ARC023","ARC142","ARC111","ARC147","ARC076","ARC077"
        },
        -- pack #10 in box #1
        [10] = {
            "ARC185","ARC207","ARC199","ARC192","ARC089","ARC121","ARC180","ARC079","ARC069","ARC020","ARC061","ARC030","ARC148","ARC098","ARC136","ARC002","ARC003"
        },
        -- pack #11 in box #1
        [11] = {
            "ARC214","ARC177","ARC214","ARC179","ARC129","ARC055","ARC154","ARC155","ARC064","ARC026","ARC068","ARC094","ARC143","ARC108","ARC147","ARC039","ARC001"
        },
        -- pack #12 in box #1
        [12] = {
            "ARC196","ARC186","ARC207","ARC183","ARC128","ARC086","ARC021","ARC157","ARC027","ARC063","ARC021","ARC066","ARC110","ARC139","ARC107","ARC075","ARC039"
        },
        -- pack #13 in box #1
        [13] = {
            "ARC213","ARC189","ARC193","ARC199","ARC167","ARC053","ARC042","ARC156","ARC074","ARC021","ARC068","ARC094","ARC146","ARC103","ARC137","ARC001","ARC114"
        },
        -- pack #14 in box #1
        [14] = {
            "ARC195","ARC188","ARC194","ARC188","ARC169","ARC046","ARC030","ARC152","ARC023","ARC066","ARC035","ARC145","ARC108","ARC144","ARC107","ARC112","ARC115"
        },
        -- pack #15 in box #1
        [15] = {
            "ARC195","ARC212","ARC197","ARC180","ARC126","ARC052","ARC192","ARC117","ARC066","ARC023","ARC067","ARC110","ARC148","ARC111","ARC148","ARC112","ARC113"
        },
        -- pack #16 in box #1
        [16] = {
            "ARC179","ARC205","ARC196","ARC211","ARC012","ARC167","ARC133","ARC152","ARC061","ARC021","ARC073","ARC033","ARC145","ARC109","ARC140","ARC115","ARC112"
        },
        -- pack #17 in box #1
        [17] = {
            "ARC193","ARC188","ARC187","ARC204","ARC169","ARC086","ARC196","ARC117","ARC022","ARC064","ARC025","ARC147","ARC111","ARC149","ARC106","ARC114","ARC039"
        },
        -- pack #18 in box #1
        [18] = {
            "ARC212","ARC187","ARC209","ARC189","ARC019","ARC017","ARC205","ARC155","ARC066","ARC031","ARC070","ARC021","ARC145","ARC104","ARC133","ARC039","ARC115"
        },
        -- pack #19 in box #1
        [19] = {
            "ARC189","ARC208","ARC203","ARC201","ARC165","ARC048","ARC100","ARC079","ARC033","ARC064","ARC034","ARC063","ARC094","ARC133","ARC096","ARC002","ARC003"
        },
        -- pack #20 in box #1
        [20] = {
            "ARC204","ARC177","ARC188","ARC202","ARC089","ARC161","ARC026","ARC155","ARC024","ARC065","ARC022","ARC145","ARC111","ARC134","ARC100","ARC218"
        },
        -- pack #21 in box #1
        [21] = {
            "ARC177","ARC186","ARC184","ARC198","ARC058","ARC081","ARC022","ARC117","ARC028","ARC063","ARC024","ARC139","ARC099","ARC135","ARC109","ARC002","ARC076"
        },
        -- pack #22 in box #1
        [22] = {
            "ARC197","ARC195","ARC202","ARC211","ARC056","ARC084","ARC211","ARC152","ARC025","ARC062","ARC028","ARC066","ARC094","ARC136","ARC109","ARC038","ARC114"
        },
        -- pack #23 in box #1
        [23] = {
            "ARC212","ARC204","ARC210","ARC215","ARC131","ARC013","ARC104","ARC079","ARC037","ARC062","ARC027","ARC065","ARC094","ARC149","ARC110","ARC114","ARC075"
        },
        -- pack #24 in box #1
        [24] = {
            "ARC203","ARC189","ARC192","ARC213","ARC131","ARC170","ARC131","ARC152","ARC072","ARC020","ARC069","ARC094","ARC142","ARC101","ARC142","ARC039","ARC038"
        },
    },
    -- box #2
    [2] = {
        -- pack #1 in box #2
        [1] = {
            "ARC188","ARC209","ARC201","ARC186","ARC127","ARC092","ARC096","ARC151","ARC030","ARC073","ARC024","ARC135","ARC103","ARC140","ARC103","ARC038","ARC075"
        },
        -- pack #2 in box #2
        [2] = {
            "ARC185","ARC197","ARC188","ARC205","ARC015","ARC090","ARC034","ARC157","ARC023","ARC067","ARC028","ARC070","ARC099","ARC137","ARC095","ARC218"
        },
        -- pack #3 in box #2
        [3] = {
            "ARC195","ARC179","ARC211","ARC200","ARC014","ARC010","ARC066","ARC042","ARC069","ARC034","ARC068","ARC103","ARC145","ARC104","ARC133","ARC076","ARC002"
        },
        -- pack #4 in box #2
        [4] = {
            "ARC217","ARC192","ARC207","ARC178","ARC129","ARC126","ARC091","ARC155","ARC068","ARC025","ARC070","ARC022","ARC149","ARC105","ARC142","ARC218"
        },
        -- pack #5 in box #2
        [5] = {
            "ARC181","ARC183","ARC180","ARC208","ARC129","ARC167","ARC026","ARC153","ARC060","ARC026","ARC070","ARC110","ARC138","ARC097","ARC146","ARC076","ARC038"
        },
        -- pack #6 in box #2
        [6] = {
            "ARC197","ARC197","ARC210","ARC183","ARC170","ARC011","ARC070","ARC151","ARC027","ARC071","ARC035","ARC142","ARC102","ARC143","ARC102","ARC076","ARC115"
        },
        -- pack #7 in box #2
        [7] = {
            "ARC213","ARC180","ARC191","ARC205","ARC015","ARC092","ARC098","ARC117","ARC032","ARC069","ARC021","ARC074","ARC103","ARC148","ARC111","ARC001","ARC040"
        },
        -- pack #8 in box #2
        [8] = {
            "ARC183","ARC183","ARC209","ARC196","ARC127","ARC045","ARC096","ARC155","ARC074","ARC025","ARC069","ARC031","ARC141","ARC102","ARC133","ARC113","ARC003"
        },
        -- pack #9 in box #2
        [9] = {
            "ARC184","ARC200","ARC179","ARC185","ARC017","ARC089","ARC098","ARC151","ARC033","ARC072","ARC029","ARC148","ARC111","ARC134","ARC099","ARC003","ARC040"
        },
        -- pack #10 in box #2
        [10] = {
            "ARC208","ARC207","ARC217","ARC207","ARC131","ARC017","ARC105","ARC154","ARC069","ARC020","ARC071","ARC031","ARC133","ARC105","ARC134","ARC113","ARC003"
        },
        -- pack #11 in box #2
        [11] = {
            "ARC199","ARC190","ARC184","ARC197","ARC059","ARC172","ARC087","ARC152","ARC068","ARC032","ARC065","ARC111","ARC141","ARC099","ARC146","ARC114","ARC038"
        },
        -- pack #12 in box #2
        [12] = {
            "ARC201","ARC178","ARC186","ARC186","ARC088","ARC011","ARC096","ARC117","ARC032","ARC063","ARC021","ARC141","ARC107","ARC145","ARC107","ARC115","ARC112"
        },
        -- pack #13 in box #2
        [13] = {
            "ARC215","ARC191","ARC178","ARC203","ARC017","ARC159","ARC049","ARC151","ARC061","ARC024","ARC061","ARC030","ARC138","ARC108","ARC149","ARC077","ARC002"
        },
        -- pack #14 in box #2
        [14] = {
            "ARC204","ARC192","ARC212","ARC187","ARC127","ARC044","ARC056","ARC158","ARC067","ARC034","ARC066","ARC031","ARC149","ARC109","ARC145","ARC002","ARC039"
        },
        -- pack #15 in box #2
        [15] = {
            "ARC188","ARC194","ARC190","ARC199","ARC123","ARC012","ARC210","ARC005","ARC064","ARC034","ARC066","ARC106","ARC132","ARC110","ARC145","ARC075","ARC077"
        },
        -- pack #16 in box #2
        [16] = {
            "ARC200","ARC209","ARC198","ARC185","ARC013","ARC128","ARC149","ARC079","ARC035","ARC066","ARC029","ARC067","ARC095","ARC132","ARC095","ARC115","ARC002"
        },
        -- pack #17 in box #2
        [17] = {
            "ARC207","ARC194","ARC203","ARC210","ARC126","ARC057","ARC071","ARC157","ARC060","ARC025","ARC069","ARC020","ARC134","ARC096","ARC148","ARC003","ARC002"
        },
        -- pack #18 in box #2
        [18] = {
            "ARC183","ARC209","ARC196","ARC214","ARC088","ARC118","ARC124","ARC005","ARC074","ARC024","ARC060","ARC110","ARC138","ARC106","ARC141","ARC077","ARC076"
        },
        -- pack #19 in box #2
        [19] = {
            "ARC206","ARC191","ARC214","ARC184","ARC091","ARC124","ARC185","ARC042","ARC033","ARC061","ARC025","ARC142","ARC108","ARC143","ARC102","ARC040","ARC075"
        },
        -- pack #20 in box #2
        [20] = {
            "ARC210","ARC189","ARC193","ARC198","ARC016","ARC056","ARC069","ARC152","ARC023","ARC060","ARC023","ARC061","ARC110","ARC133","ARC108","ARC038","ARC115"
        },
        -- pack #21 in box #2
        [21] = {
            "ARC198","ARC190","ARC193","ARC185","ARC090","ARC081","ARC192","ARC153","ARC065","ARC022","ARC064","ARC110","ARC140","ARC096","ARC138","ARC003","ARC039"
        },
        -- pack #22 in box #2
        [22] = {
            "ARC213","ARC181","ARC200","ARC189","ARC055","ARC168","ARC000","ARC079","ARC036","ARC070","ARC036","ARC061","ARC111","ARC135","ARC107","ARC038","ARC112"
        },
        -- pack #23 in box #2
        [23] = {
            "ARC190","ARC181","ARC217","ARC189","ARC089","ARC085","ARC099","ARC152","ARC036","ARC065","ARC023","ARC142","ARC102","ARC140","ARC098","ARC002","ARC038"
        },
        -- pack #24 in box #2
        [24] = {
            "ARC196","ARC212","ARC191","ARC212","ARC048","ARC174","ARC009","ARC005","ARC025","ARC073","ARC025","ARC066","ARC100","ARC135","ARC099","ARC001","ARC002"
        },
    },
    -- box #3
    [3] = {
        -- pack #1 in box #3
        [1] = {
            "ARC187","ARC206","ARC216","ARC177","ARC018","ARC018","ARC106","ARC155","ARC074","ARC025","ARC068","ARC094","ARC140","ARC110","ARC139","ARC003","ARC075"
        },
        -- pack #2 in box #3
        [2] = {
            "ARC181","ARC213","ARC204","ARC177","ARC170","ARC160","ARC028","ARC157","ARC068","ARC035","ARC069","ARC102","ARC142","ARC110","ARC133","ARC001","ARC002"
        },
        -- pack #3 in box #3
        [3] = {
            "ARC198","ARC187","ARC204","ARC212","ARC130","ARC091","ARC101","ARC157","ARC037","ARC072","ARC036","ARC135","ARC103","ARC132","ARC105","ARC003","ARC076"
        },
        -- pack #4 in box #3
        [4] = {
            "ARC208","ARC205","ARC199","ARC193","ARC167","ARC049","ARC059","ARC156","ARC034","ARC068","ARC024","ARC070","ARC100","ARC133","ARC094","ARC075","ARC114"
        },
        -- pack #5 in box #3
        [5] = {
            "ARC215","ARC182","ARC178","ARC215","ARC164","ARC055","ARC050","ARC152","ARC036","ARC067","ARC034","ARC068","ARC097","ARC138","ARC101","ARC001","ARC115"
        },
        -- pack #6 in box #3
        [6] = {
            "ARC217","ARC184","ARC179","ARC217","ARC011","ARC016","ARC093","ARC157","ARC069","ARC023","ARC061","ARC099","ARC141","ARC110","ARC139","ARC218"
        },
        -- pack #7 in box #3
        [7] = {
            "ARC213","ARC180","ARC208","ARC192","ARC059","ARC161","ARC020","ARC042","ARC031","ARC066","ARC020","ARC135","ARC106","ARC136","ARC107","ARC003","ARC077"
        },
        -- pack #8 in box #3
        [8] = {
            "ARC207","ARC176","ARC198","ARC198","ARC017","ARC055","ARC058","ARC042","ARC065","ARC025","ARC062","ARC030","ARC144","ARC094","ARC143","ARC113","ARC076"
        },
        -- pack #9 in box #3
        [9] = {
            "ARC216","ARC180","ARC176","ARC210","ARC168","ARC163","ARC151","ARC155","ARC074","ARC020","ARC068","ARC027","ARC143","ARC098","ARC140","ARC038","ARC115"
        },
        -- pack #10 in box #3
        [10] = {
            "ARC189","ARC209","ARC205","ARC197","ARC051","ARC166","ARC140","ARC151","ARC070","ARC020","ARC072","ARC107","ARC146","ARC102","ARC141","ARC002","ARC001"
        },
        -- pack #11 in box #3
        [11] = {
            "ARC190","ARC198","ARC183","ARC188","ARC130","ARC084","ARC203","ARC154","ARC037","ARC070","ARC031","ARC148","ARC098","ARC132","ARC094","ARC076","ARC115"
        },
        -- pack #12 in box #3
        [12] = {
            "ARC201","ARC216","ARC204","ARC210","ARC092","ARC051","ARC184","ARC151","ARC022","ARC069","ARC029","ARC069","ARC102","ARC135","ARC106","ARC114","ARC077"
        },
        -- pack #13 in box #3
        [13] = {
            "ARC207","ARC196","ARC193","ARC206","ARC086","ARC014","ARC017","ARC155","ARC060","ARC028","ARC065","ARC031","ARC141","ARC107","ARC136","ARC218"
        },
        -- pack #14 in box #3
        [14] = {
            "ARC209","ARC215","ARC210","ARC207","ARC175","ARC016","ARC025","ARC079","ARC037","ARC061","ARC036","ARC132","ARC103","ARC134","ARC097","ARC039","ARC003"
        },
        -- pack #15 in box #3
        [15] = {
            "ARC195","ARC178","ARC210","ARC202","ARC165","ARC092","ARC180","ARC042","ARC064","ARC026","ARC070","ARC036","ARC144","ARC110","ARC149","ARC040","ARC002"
        },
        -- pack #16 in box #3
        [16] = {
            "ARC179","ARC196","ARC212","ARC200","ARC015","ARC163","ARC024","ARC155","ARC029","ARC063","ARC026","ARC067","ARC096","ARC145","ARC110","ARC038","ARC075"
        },
        -- pack #17 in box #3
        [17] = {
            "ARC182","ARC199","ARC189","ARC180","ARC013","ARC118","ARC202","ARC156","ARC067","ARC029","ARC071","ARC033","ARC142","ARC099","ARC145","ARC112","ARC003"
        },
        -- pack #18 in box #3
        [18] = {
            "ARC195","ARC211","ARC191","ARC205","ARC058","ARC121","ARC022","ARC156","ARC062","ARC023","ARC063","ARC034","ARC144","ARC102","ARC135","ARC039","ARC040"
        },
        -- pack #19 in box #3
        [19] = {
            "ARC206","ARC207","ARC176","ARC195","ARC165","ARC043","ARC047","ARC156","ARC030","ARC064","ARC029","ARC071","ARC108","ARC134","ARC101","ARC002","ARC076"
        },
        -- pack #20 in box #3
        [20] = {
            "ARC183","ARC207","ARC196","ARC193","ARC054","ARC010","ARC120","ARC154","ARC071","ARC024","ARC060","ARC103","ARC142","ARC111","ARC142","ARC075","ARC113"
        },
        -- pack #21 in box #3
        [21] = {
            "ARC186","ARC202","ARC200","ARC202","ARC166","ARC006","ARC042","ARC042","ARC033","ARC060","ARC024","ARC145","ARC102","ARC147","ARC099","ARC002","ARC114"
        },
        -- pack #22 in box #3
        [22] = {
            "ARC207","ARC206","ARC205","ARC193","ARC089","ARC128","ARC213","ARC079","ARC035","ARC063","ARC021","ARC134","ARC109","ARC149","ARC099","ARC115","ARC039"
        },
        -- pack #23 in box #3
        [23] = {
            "ARC200","ARC179","ARC208","ARC186","ARC171","ARC014","ARC133","ARC152","ARC073","ARC035","ARC071","ARC101","ARC133","ARC103","ARC144","ARC218"
        },
        -- pack #24 in box #3
        [24] = {
            "ARC208","ARC203","ARC192","ARC177","ARC014","ARC089","ARC004","ARC156","ARC037","ARC066","ARC030","ARC071","ARC099","ARC147","ARC107","ARC040","ARC002"
        },
    },
    -- box #4
    [4] = {
        -- pack #1 in box #4
        [1] = {
            "ARC181","ARC181","ARC178","ARC215","ARC093","ARC164","ARC120","ARC154","ARC066","ARC037","ARC068","ARC108","ARC141","ARC108","ARC134","ARC001","ARC003"
        },
        -- pack #2 in box #4
        [2] = {
            "ARC176","ARC202","ARC213","ARC209","ARC019","ARC015","ARC099","ARC154","ARC031","ARC067","ARC027","ARC073","ARC100","ARC145","ARC103","ARC075","ARC112"
        },
        -- pack #3 in box #4
        [3] = {
            "ARC187","ARC203","ARC189","ARC205","ARC058","ARC012","ARC005","ARC042","ARC065","ARC036","ARC066","ARC098","ARC139","ARC100","ARC147","ARC114","ARC039"
        },
        -- pack #4 in box #4
        [4] = {
            "ARC211","ARC206","ARC185","ARC192","ARC168","ARC045","ARC177","ARC042","ARC024","ARC063","ARC025","ARC073","ARC097","ARC144","ARC098","ARC113","ARC076"
        },
        -- pack #5 in box #4
        [5] = {
            "ARC204","ARC198","ARC200","ARC209","ARC085","ARC007","ARC102","ARC151","ARC025","ARC071","ARC024","ARC139","ARC111","ARC145","ARC111","ARC076","ARC112"
        },
        -- pack #6 in box #4
        [6] = {
            "ARC213","ARC209","ARC177","ARC191","ARC172","ARC051","ARC097","ARC156","ARC073","ARC027","ARC069","ARC101","ARC146","ARC110","ARC137","ARC218"
        },
        -- pack #7 in box #4
        [7] = {
            "ARC203","ARC211","ARC179","ARC182","ARC127","ARC056","ARC212","ARC156","ARC035","ARC074","ARC037","ARC136","ARC096","ARC139","ARC097","ARC115","ARC040"
        },
        -- pack #8 in box #4
        [8] = {
            "ARC179","ARC186","ARC215","ARC176","ARC055","ARC049","ARC055","ARC154","ARC069","ARC034","ARC072","ARC025","ARC137","ARC102","ARC139","ARC002","ARC001"
        },
        -- pack #9 in box #4
        [9] = {
            "ARC188","ARC199","ARC194","ARC186","ARC016","ARC009","ARC111","ARC157","ARC071","ARC037","ARC067","ARC109","ARC139","ARC105","ARC142","ARC112","ARC075"
        },
        -- pack #10 in box #4
        [10] = {
            "ARC196","ARC177","ARC213","ARC212","ARC057","ARC091","ARC187","ARC156","ARC033","ARC071","ARC029","ARC065","ARC110","ARC142","ARC096","ARC113","ARC001"
        },
        -- pack #11 in box #4
        [11] = {
            "ARC192","ARC205","ARC210","ARC177","ARC173","ARC168","ARC104","ARC042","ARC027","ARC060","ARC025","ARC074","ARC098","ARC132","ARC111","ARC113","ARC115"
        },
        -- pack #12 in box #4
        [12] = {
            "ARC190","ARC202","ARC181","ARC211","ARC057","ARC051","ARC031","ARC155","ARC068","ARC034","ARC067","ARC029","ARC144","ARC103","ARC147","ARC040","ARC114"
        },
        -- pack #13 in box #4
        [13] = {
            "ARC203","ARC192","ARC177","ARC210","ARC166","ARC091","ARC103","ARC158","ARC066","ARC032","ARC068","ARC096","ARC141","ARC108","ARC133","ARC038","ARC076"
        },
        -- pack #14 in box #4
        [14] = {
            "ARC203","ARC214","ARC203","ARC210","ARC130","ARC171","ARC072","ARC157","ARC021","ARC060","ARC032","ARC142","ARC108","ARC149","ARC097","ARC039","ARC077"
        },
        -- pack #15 in box #4
        [15] = {
            "ARC215","ARC194","ARC206","ARC206","ARC125","ARC120","ARC117","ARC153","ARC066","ARC029","ARC071","ARC035","ARC135","ARC094","ARC132","ARC001","ARC038"
        },
        -- pack #16 in box #4
        [16] = {
            "ARC179","ARC183","ARC200","ARC206","ARC016","ARC059","ARC144","ARC042","ARC067","ARC034","ARC069","ARC033","ARC144","ARC106","ARC141","ARC076","ARC002"
        },
        -- pack #17 in box #4
        [17] = {
            "ARC211","ARC205","ARC195","ARC197","ARC012","ARC045","ARC021","ARC151","ARC064","ARC022","ARC065","ARC028","ARC140","ARC104","ARC144","ARC076","ARC040"
        },
        -- pack #18 in box #4
        [18] = {
            "ARC215","ARC189","ARC185","ARC217","ARC175","ARC010","ARC030","ARC154","ARC071","ARC020","ARC066","ARC033","ARC136","ARC111","ARC134","ARC218"
        },
        -- pack #19 in box #4
        [19] = {
            "ARC176","ARC178","ARC202","ARC205","ARC127","ARC160","ARC194","ARC158","ARC067","ARC031","ARC072","ARC110","ARC136","ARC108","ARC146","ARC038","ARC039"
        },
        -- pack #20 in box #4
        [20] = {
            "ARC199","ARC199","ARC210","ARC209","ARC055","ARC082","ARC045","ARC158","ARC026","ARC071","ARC032","ARC133","ARC094","ARC144","ARC096","ARC001","ARC112"
        },
        -- pack #21 in box #4
        [21] = {
            "ARC210","ARC208","ARC217","ARC182","ARC019","ARC172","ARC192","ARC155","ARC022","ARC072","ARC029","ARC064","ARC110","ARC143","ARC097","ARC039","ARC040"
        },
        -- pack #22 in box #4
        [22] = {
            "ARC191","ARC178","ARC198","ARC197","ARC058","ARC054","ARC135","ARC158","ARC029","ARC072","ARC029","ARC139","ARC111","ARC146","ARC102","ARC001","ARC039"
        },
        -- pack #23 in box #4
        [23] = {
            "ARC202","ARC186","ARC193","ARC216","ARC014","ARC093","ARC212","ARC042","ARC027","ARC068","ARC033","ARC068","ARC097","ARC145","ARC105","ARC114","ARC077"
        },
        -- pack #24 in box #4
        [24] = {
            "ARC194","ARC200","ARC200","ARC182","ARC088","ARC048","ARC070","ARC117","ARC037","ARC074","ARC027","ARC148","ARC101","ARC136","ARC106","ARC002","ARC001"
        },
    },
    -- box #5
    [5] = {
        -- pack #1 in box #5
        [1] = {
            "ARC203","ARC183","ARC176","ARC186","ARC171","ARC084","ARC073","ARC156","ARC025","ARC065","ARC034","ARC065","ARC099","ARC136","ARC110","ARC039","ARC113"
        },
        -- pack #2 in box #5
        [2] = {
            "ARC212","ARC180","ARC205","ARC183","ARC170","ARC019","ARC069","ARC155","ARC061","ARC023","ARC065","ARC097","ARC136","ARC100","ARC141","ARC001","ARC114"
        },
        -- pack #3 in box #5
        [3] = {
            "ARC194","ARC179","ARC180","ARC203","ARC123","ARC056","ARC074","ARC155","ARC071","ARC021","ARC068","ARC028","ARC139","ARC095","ARC146","ARC002","ARC040"
        },
        -- pack #4 in box #5
        [4] = {
            "ARC180","ARC214","ARC203","ARC195","ARC124","ARC087","ARC196","ARC155","ARC020","ARC067","ARC029","ARC137","ARC096","ARC149","ARC101","ARC113","ARC002"
        },
        -- pack #5 in box #5
        [5] = {
            "ARC211","ARC203","ARC177","ARC215","ARC126","ARC057","ARC069","ARC157","ARC033","ARC067","ARC022","ARC147","ARC102","ARC142","ARC100","ARC114","ARC112"
        },
        -- pack #6 in box #5
        [6] = {
            "ARC184","ARC182","ARC201","ARC193","ARC019","ARC007","ARC125","ARC155","ARC023","ARC068","ARC024","ARC072","ARC104","ARC146","ARC106","ARC077","ARC076"
        },
        -- pack #7 in box #5
        [7] = {
            "ARC177","ARC188","ARC208","ARC213","ARC168","ARC129","ARC119","ARC005","ARC062","ARC023","ARC060","ARC027","ARC146","ARC107","ARC148","ARC039","ARC076"
        },
        -- pack #8 in box #5
        [8] = {
            "ARC199","ARC191","ARC195","ARC189","ARC172","ARC091","ARC155","ARC151","ARC024","ARC073","ARC035","ARC072","ARC103","ARC136","ARC100","ARC038","ARC115"
        },
        -- pack #9 in box #5
        [9] = {
            "ARC180","ARC196","ARC187","ARC190","ARC011","ARC166","ARC021","ARC153","ARC069","ARC030","ARC069","ARC027","ARC135","ARC104","ARC148","ARC115","ARC077"
        },
        -- pack #10 in box #5
        [10] = {
            "ARC202","ARC205","ARC217","ARC215","ARC174","ARC007","ARC098","ARC152","ARC071","ARC029","ARC071","ARC096","ARC141","ARC098","ARC138","ARC001","ARC112"
        },
        -- pack #11 in box #5
        [11] = {
            "ARC212","ARC197","ARC215","ARC205","ARC131","ARC012","ARC201","ARC154","ARC067","ARC034","ARC066","ARC097","ARC142","ARC108","ARC138","ARC076","ARC002"
        },
        -- pack #12 in box #5
        [12] = {
            "ARC185","ARC176","ARC205","ARC197","ARC126","ARC050","ARC191","ARC154","ARC029","ARC067","ARC033","ARC062","ARC100","ARC132","ARC104","ARC075","ARC003"
        },
        -- pack #13 in box #5
        [13] = {
            "ARC188","ARC202","ARC178","ARC200","ARC173","ARC163","ARC205","ARC079","ARC033","ARC067","ARC035","ARC135","ARC109","ARC146","ARC096","ARC040","ARC039"
        },
        -- pack #14 in box #5
        [14] = {
            "ARC208","ARC183","ARC193","ARC197","ARC167","ARC050","ARC064","ARC152","ARC030","ARC067","ARC036","ARC136","ARC097","ARC133","ARC101","ARC114","ARC002"
        },
        -- pack #15 in box #5
        [15] = {
            "ARC208","ARC200","ARC197","ARC210","ARC057","ARC058","ARC142","ARC042","ARC037","ARC068","ARC024","ARC136","ARC099","ARC135","ARC104","ARC040","ARC001"
        },
        -- pack #16 in box #5
        [16] = {
            "ARC199","ARC209","ARC212","ARC213","ARC093","ARC172","ARC088","ARC042","ARC068","ARC031","ARC072","ARC105","ARC139","ARC109","ARC133","ARC113","ARC039"
        },
        -- pack #17 in box #5
        [17] = {
            "ARC203","ARC195","ARC195","ARC189","ARC050","ARC016","ARC140","ARC042","ARC067","ARC035","ARC067","ARC034","ARC144","ARC105","ARC137","ARC114","ARC075"
        },
        -- pack #18 in box #5
        [18] = {
            "ARC189","ARC198","ARC184","ARC207","ARC090","ARC057","ARC192","ARC157","ARC061","ARC028","ARC066","ARC028","ARC140","ARC102","ARC149","ARC075","ARC115"
        },
        -- pack #19 in box #5
        [19] = {
            "ARC212","ARC183","ARC194","ARC188","ARC057","ARC165","ARC217","ARC157","ARC068","ARC021","ARC066","ARC106","ARC140","ARC102","ARC144","ARC077","ARC113"
        },
        -- pack #20 in box #5
        [20] = {
            "ARC212","ARC193","ARC193","ARC201","ARC093","ARC129","ARC211","ARC117","ARC022","ARC073","ARC036","ARC140","ARC097","ARC137","ARC108","ARC113","ARC039"
        },
        -- pack #21 in box #5
        [21] = {
            "ARC185","ARC193","ARC209","ARC198","ARC170","ARC010","ARC096","ARC005","ARC061","ARC030","ARC064","ARC025","ARC142","ARC111","ARC149","ARC003","ARC002"
        },
        -- pack #22 in box #5
        [22] = {
            "ARC179","ARC198","ARC188","ARC203","ARC011","ARC055","ARC009","ARC153","ARC029","ARC068","ARC034","ARC074","ARC109","ARC147","ARC100","ARC218"
        },
        -- pack #23 in box #5
        [23] = {
            "ARC211","ARC200","ARC191","ARC189","ARC085","ARC127","ARC057","ARC156","ARC070","ARC024","ARC073","ARC111","ARC135","ARC108","ARC135","ARC115","ARC001"
        },
        -- pack #24 in box #5
        [24] = {
            "ARC205","ARC184","ARC190","ARC192","ARC090","ARC059","ARC207","ARC158","ARC026","ARC073","ARC022","ARC071","ARC106","ARC141","ARC094","ARC218"
        },
    },
    -- box #6
    [6] = {
        -- pack #1 in box #6
        [1] = {
            "ARC183","ARC181","ARC204","ARC190","ARC174","ARC049","ARC200","ARC079","ARC072","ARC034","ARC060","ARC107","ARC143","ARC096","ARC137","ARC114","ARC002"
        },
        -- pack #2 in box #6
        [2] = {
            "ARC207","ARC217","ARC211","ARC202","ARC092","ARC086","ARC216","ARC154","ARC069","ARC036","ARC067","ARC028","ARC142","ARC101","ARC143","ARC113","ARC075"
        },
        -- pack #3 in box #6
        [3] = {
            "ARC200","ARC198","ARC176","ARC196","ARC011","ARC162","ARC132","ARC151","ARC070","ARC037","ARC069","ARC100","ARC145","ARC108","ARC134","ARC002","ARC039"
        },
        -- pack #4 in box #6
        [4] = {
            "ARC188","ARC191","ARC198","ARC188","ARC050","ARC168","ARC154","ARC117","ARC032","ARC062","ARC024","ARC143","ARC104","ARC144","ARC094","ARC075","ARC113"
        },
        -- pack #5 in box #6
        [5] = {
            "ARC215","ARC187","ARC200","ARC196","ARC050","ARC086","ARC176","ARC117","ARC069","ARC025","ARC061","ARC101","ARC134","ARC096","ARC135","ARC112","ARC002"
        },
        -- pack #6 in box #6
        [6] = {
            "ARC190","ARC206","ARC217","ARC207","ARC012","ARC013","ARC188","ARC155","ARC021","ARC067","ARC036","ARC133","ARC110","ARC135","ARC103","ARC112","ARC076"
        },
        -- pack #7 in box #6
        [7] = {
            "ARC199","ARC178","ARC186","ARC200","ARC129","ARC164","ARC195","ARC005","ARC064","ARC020","ARC073","ARC028","ARC140","ARC106","ARC135","ARC077","ARC113"
        },
        -- pack #8 in box #6
        [8] = {
            "ARC209","ARC183","ARC197","ARC211","ARC090","ARC163","ARC204","ARC154","ARC072","ARC027","ARC065","ARC099","ARC133","ARC094","ARC144","ARC112","ARC001"
        },
        -- pack #9 in box #6
        [9] = {
            "ARC182","ARC204","ARC176","ARC178","ARC087","ARC175","ARC056","ARC155","ARC037","ARC070","ARC027","ARC073","ARC107","ARC146","ARC111","ARC001","ARC113"
        },
        -- pack #10 in box #6
        [10] = {
            "ARC214","ARC207","ARC216","ARC176","ARC092","ARC008","ARC137","ARC156","ARC027","ARC069","ARC032","ARC064","ARC096","ARC133","ARC108","ARC077","ARC075"
        },
        -- pack #11 in box #6
        [11] = {
            "ARC216","ARC198","ARC197","ARC214","ARC125","ARC052","ARC034","ARC005","ARC022","ARC064","ARC033","ARC060","ARC102","ARC142","ARC097","ARC115","ARC038"
        },
        -- pack #12 in box #6
        [12] = {
            "ARC192","ARC187","ARC182","ARC198","ARC128","ARC159","ARC161","ARC158","ARC063","ARC022","ARC074","ARC027","ARC148","ARC098","ARC146","ARC075","ARC115"
        },
        -- pack #13 in box #6
        [13] = {
            "ARC178","ARC196","ARC215","ARC216","ARC092","ARC088","ARC191","ARC157","ARC074","ARC034","ARC060","ARC034","ARC136","ARC094","ARC149","ARC003","ARC038"
        },
        -- pack #14 in box #6
        [14] = {
            "ARC195","ARC183","ARC193","ARC203","ARC127","ARC120","ARC049","ARC154","ARC022","ARC060","ARC023","ARC072","ARC096","ARC140","ARC105","ARC039","ARC002"
        },
        -- pack #15 in box #6
        [15] = {
            "ARC210","ARC200","ARC176","ARC188","ARC092","ARC015","ARC172","ARC005","ARC070","ARC021","ARC060","ARC029","ARC149","ARC099","ARC139","ARC075","ARC039"
        },
        -- pack #16 in box #6
        [16] = {
            "ARC195","ARC190","ARC207","ARC202","ARC125","ARC126","ARC012","ARC155","ARC026","ARC067","ARC029","ARC147","ARC103","ARC146","ARC106","ARC001","ARC115"
        },
        -- pack #17 in box #6
        [17] = {
            "ARC203","ARC182","ARC207","ARC184","ARC086","ARC052","ARC194","ARC157","ARC026","ARC072","ARC032","ARC146","ARC099","ARC148","ARC095","ARC002","ARC001"
        },
        -- pack #18 in box #6
        [18] = {
            "ARC210","ARC191","ARC216","ARC176","ARC169","ARC048","ARC197","ARC155","ARC024","ARC070","ARC031","ARC136","ARC103","ARC143","ARC102","ARC075","ARC038"
        },
        -- pack #19 in box #6
        [19] = {
            "ARC208","ARC180","ARC214","ARC184","ARC169","ARC124","ARC154","ARC154","ARC063","ARC036","ARC062","ARC098","ARC133","ARC094","ARC136","ARC075","ARC001"
        },
        -- pack #20 in box #6
        [20] = {
            "ARC204","ARC177","ARC206","ARC204","ARC056","ARC163","ARC204","ARC079","ARC024","ARC061","ARC026","ARC070","ARC100","ARC138","ARC099","ARC114","ARC040"
        },
        -- pack #21 in box #6
        [21] = {
            "ARC178","ARC193","ARC213","ARC187","ARC173","ARC174","ARC217","ARC155","ARC021","ARC065","ARC036","ARC060","ARC098","ARC139","ARC102","ARC076","ARC003"
        },
        -- pack #22 in box #6
        [22] = {
            "ARC213","ARC205","ARC212","ARC210","ARC056","ARC173","ARC100","ARC156","ARC066","ARC022","ARC062","ARC025","ARC137","ARC102","ARC136","ARC003","ARC040"
        },
        -- pack #23 in box #6
        [23] = {
            "ARC196","ARC189","ARC204","ARC201","ARC123","ARC123","ARC204","ARC157","ARC064","ARC027","ARC071","ARC110","ARC139","ARC106","ARC132","ARC077","ARC040"
        },
        -- pack #24 in box #6
        [24] = {
            "ARC177","ARC211","ARC212","ARC201","ARC165","ARC082","ARC095","ARC153","ARC024","ARC071","ARC022","ARC144","ARC111","ARC145","ARC104","ARC040","ARC002"
        },
    },
    -- box #7
    [7] = {
        -- pack #1 in box #7
        [1] = {
            "ARC200","ARC192","ARC202","ARC210","ARC172","ARC118","ARC106","ARC154","ARC035","ARC064","ARC022","ARC133","ARC096","ARC141","ARC107","ARC077","ARC113"
        },
        -- pack #2 in box #7
        [2] = {
            "ARC204","ARC177","ARC196","ARC177","ARC093","ARC122","ARC205","ARC155","ARC064","ARC032","ARC068","ARC094","ARC132","ARC096","ARC134","ARC218"
        },
        -- pack #3 in box #7
        [3] = {
            "ARC214","ARC211","ARC216","ARC189","ARC057","ARC088","ARC138","ARC152","ARC029","ARC064","ARC021","ARC070","ARC111","ARC149","ARC103","ARC075","ARC001"
        },
        -- pack #4 in box #7
        [4] = {
            "ARC188","ARC193","ARC191","ARC201","ARC167","ARC167","ARC188","ARC079","ARC061","ARC026","ARC068","ARC106","ARC143","ARC104","ARC149","ARC002","ARC039"
        },
        -- pack #5 in box #7
        [5] = {
            "ARC202","ARC202","ARC197","ARC183","ARC128","ARC018","ARC200","ARC005","ARC074","ARC032","ARC068","ARC110","ARC140","ARC095","ARC137","ARC218"
        },
        -- pack #6 in box #7
        [6] = {
            "ARC183","ARC195","ARC199","ARC208","ARC169","ARC089","ARC109","ARC005","ARC032","ARC073","ARC036","ARC138","ARC096","ARC139","ARC110","ARC218"
        },
        -- pack #7 in box #7
        [7] = {
            "ARC202","ARC188","ARC212","ARC199","ARC056","ARC055","ARC095","ARC158","ARC021","ARC065","ARC035","ARC061","ARC098","ARC138","ARC100","ARC001","ARC112"
        },
        -- pack #8 in box #7
        [8] = {
            "ARC189","ARC209","ARC180","ARC206","ARC173","ARC051","ARC020","ARC151","ARC020","ARC072","ARC026","ARC136","ARC102","ARC141","ARC098","ARC040","ARC075"
        },
        -- pack #9 in box #7
        [9] = {
            "ARC183","ARC207","ARC189","ARC203","ARC166","ARC167","ARC198","ARC079","ARC060","ARC023","ARC062","ARC035","ARC143","ARC094","ARC137","ARC113","ARC002"
        },
        -- pack #10 in box #7
        [10] = {
            "ARC183","ARC197","ARC196","ARC188","ARC014","ARC163","ARC068","ARC117","ARC073","ARC036","ARC062","ARC109","ARC137","ARC108","ARC135","ARC040","ARC076"
        },
        -- pack #11 in box #7
        [11] = {
            "ARC190","ARC210","ARC213","ARC177","ARC168","ARC086","ARC169","ARC117","ARC070","ARC033","ARC070","ARC036","ARC132","ARC101","ARC142","ARC114","ARC003"
        },
        -- pack #12 in box #7
        [12] = {
            "ARC178","ARC215","ARC204","ARC188","ARC169","ARC172","ARC200","ARC152","ARC028","ARC067","ARC021","ARC144","ARC106","ARC142","ARC111","ARC001","ARC002"
        },
        -- pack #13 in box #7
        [13] = {
            "ARC192","ARC216","ARC204","ARC182","ARC129","ARC123","ARC105","ARC156","ARC020","ARC061","ARC037","ARC065","ARC098","ARC141","ARC095","ARC003","ARC038"
        },
        -- pack #14 in box #7
        [14] = {
            "ARC181","ARC215","ARC177","ARC179","ARC175","ARC092","ARC050","ARC042","ARC029","ARC072","ARC026","ARC062","ARC108","ARC142","ARC104","ARC001","ARC077"
        },
        -- pack #15 in box #7
        [15] = {
            "ARC186","ARC207","ARC206","ARC190","ARC091","ARC130","ARC062","ARC158","ARC061","ARC024","ARC060","ARC029","ARC133","ARC107","ARC149","ARC114","ARC115"
        },
        -- pack #16 in box #7
        [16] = {
            "ARC208","ARC199","ARC209","ARC192","ARC167","ARC129","ARC166","ARC158","ARC067","ARC021","ARC062","ARC094","ARC143","ARC106","ARC144","ARC076","ARC112"
        },
        -- pack #17 in box #7
        [17] = {
            "ARC187","ARC208","ARC199","ARC200","ARC164","ARC130","ARC140","ARC158","ARC072","ARC021","ARC072","ARC022","ARC149","ARC109","ARC144","ARC075","ARC112"
        },
        -- pack #18 in box #7
        [18] = {
            "ARC179","ARC207","ARC198","ARC197","ARC053","ARC168","ARC206","ARC152","ARC021","ARC065","ARC023","ARC147","ARC104","ARC135","ARC109","ARC076","ARC114"
        },
        -- pack #19 in box #7
        [19] = {
            "ARC213","ARC201","ARC201","ARC212","ARC124","ARC123","ARC146","ARC079","ARC033","ARC068","ARC027","ARC069","ARC110","ARC139","ARC095","ARC112","ARC077"
        },
        -- pack #20 in box #7
        [20] = {
            "ARC200","ARC213","ARC178","ARC202","ARC128","ARC119","ARC143","ARC157","ARC022","ARC060","ARC021","ARC068","ARC109","ARC138","ARC099","ARC218"
        },
        -- pack #21 in box #7
        [21] = {
            "ARC191","ARC196","ARC185","ARC185","ARC019","ARC162","ARC095","ARC042","ARC069","ARC034","ARC064","ARC034","ARC139","ARC098","ARC133","ARC038","ARC003"
        },
        -- pack #22 in box #7
        [22] = {
            "ARC217","ARC185","ARC194","ARC201","ARC059","ARC091","ARC029","ARC157","ARC029","ARC067","ARC034","ARC133","ARC095","ARC148","ARC098","ARC001","ARC115"
        },
        -- pack #23 in box #7
        [23] = {
            "ARC205","ARC179","ARC189","ARC205","ARC091","ARC130","ARC210","ARC151","ARC067","ARC032","ARC061","ARC029","ARC147","ARC097","ARC144","ARC112","ARC114"
        },
        -- pack #24 in box #7
        [24] = {
            "ARC189","ARC213","ARC205","ARC195","ARC057","ARC131","ARC092","ARC153","ARC074","ARC034","ARC064","ARC102","ARC140","ARC103","ARC137","ARC039","ARC001"
        },
    },
    -- box #8
    [8] = {
        -- pack #1 in box #8
        [1] = {
            "ARC195","ARC185","ARC211","ARC206","ARC017","ARC016","ARC158","ARC153","ARC035","ARC063","ARC035","ARC061","ARC094","ARC136","ARC094","ARC038","ARC114"
        },
        -- pack #2 in box #8
        [2] = {
            "ARC210","ARC213","ARC186","ARC199","ARC017","ARC121","ARC099","ARC156","ARC020","ARC063","ARC032","ARC063","ARC096","ARC141","ARC109","ARC114","ARC075"
        },
        -- pack #3 in box #8
        [3] = {
            "ARC205","ARC185","ARC180","ARC193","ARC170","ARC127","ARC111","ARC042","ARC020","ARC069","ARC025","ARC142","ARC095","ARC134","ARC104","ARC112","ARC039"
        },
        -- pack #4 in box #8
        [4] = {
            "ARC182","ARC201","ARC213","ARC214","ARC052","ARC126","ARC187","ARC153","ARC068","ARC022","ARC072","ARC105","ARC133","ARC105","ARC142","ARC075","ARC076"
        },
        -- pack #5 in box #8
        [5] = {
            "ARC209","ARC191","ARC179","ARC201","ARC054","ARC124","ARC049","ARC157","ARC066","ARC021","ARC062","ARC020","ARC141","ARC107","ARC138","ARC003","ARC114"
        },
        -- pack #6 in box #8
        [6] = {
            "ARC216","ARC187","ARC217","ARC188","ARC166","ARC126","ARC023","ARC117","ARC067","ARC032","ARC067","ARC095","ARC142","ARC108","ARC144","ARC038","ARC076"
        },
        -- pack #7 in box #8
        [7] = {
            "ARC179","ARC198","ARC195","ARC177","ARC049","ARC053","ARC064","ARC154","ARC020","ARC072","ARC026","ARC136","ARC094","ARC134","ARC098","ARC039","ARC002"
        },
        -- pack #8 in box #8
        [8] = {
            "ARC211","ARC177","ARC198","ARC188","ARC166","ARC051","ARC145","ARC117","ARC071","ARC027","ARC069","ARC026","ARC138","ARC094","ARC141","ARC040","ARC114"
        },
        -- pack #9 in box #8
        [9] = {
            "ARC198","ARC205","ARC182","ARC178","ARC054","ARC058","ARC045","ARC042","ARC034","ARC060","ARC036","ARC061","ARC104","ARC136","ARC111","ARC077","ARC115"
        },
        -- pack #10 in box #8
        [10] = {
            "ARC202","ARC196","ARC204","ARC177","ARC131","ARC166","ARC020","ARC155","ARC061","ARC035","ARC070","ARC033","ARC134","ARC095","ARC134","ARC040","ARC075"
        },
        -- pack #11 in box #8
        [11] = {
            "ARC187","ARC211","ARC200","ARC182","ARC050","ARC164","ARC169","ARC157","ARC022","ARC070","ARC036","ARC147","ARC106","ARC147","ARC105","ARC218"
        },
        -- pack #12 in box #8
        [12] = {
            "ARC197","ARC178","ARC200","ARC179","ARC059","ARC081","ARC013","ARC005","ARC063","ARC037","ARC068","ARC029","ARC139","ARC100","ARC132","ARC003","ARC115"
        },
        -- pack #13 in box #8
        [13] = {
            "ARC211","ARC189","ARC193","ARC185","ARC166","ARC083","ARC132","ARC156","ARC020","ARC069","ARC020","ARC136","ARC109","ARC147","ARC098","ARC001","ARC040"
        },
        -- pack #14 in box #8
        [14] = {
            "ARC200","ARC190","ARC187","ARC209","ARC054","ARC120","ARC100","ARC151","ARC070","ARC026","ARC069","ARC101","ARC139","ARC110","ARC143","ARC001","ARC038"
        },
        -- pack #15 in box #8
        [15] = {
            "ARC176","ARC200","ARC203","ARC208","ARC129","ARC011","ARC178","ARC005","ARC024","ARC074","ARC032","ARC148","ARC107","ARC147","ARC097","ARC040","ARC003"
        },
        -- pack #16 in box #8
        [16] = {
            "ARC187","ARC193","ARC179","ARC200","ARC057","ARC089","ARC186","ARC079","ARC070","ARC027","ARC069","ARC035","ARC138","ARC108","ARC141","ARC113","ARC003"
        },
        -- pack #17 in box #8
        [17] = {
            "ARC212","ARC202","ARC196","ARC193","ARC050","ARC086","ARC144","ARC157","ARC066","ARC028","ARC064","ARC098","ARC135","ARC106","ARC139","ARC218"
        },
        -- pack #18 in box #8
        [18] = {
            "ARC190","ARC197","ARC214","ARC185","ARC019","ARC130","ARC052","ARC117","ARC074","ARC020","ARC060","ARC025","ARC146","ARC097","ARC145","ARC112","ARC003"
        },
        -- pack #19 in box #8
        [19] = {
            "ARC201","ARC208","ARC178","ARC210","ARC167","ARC163","ARC132","ARC117","ARC027","ARC060","ARC025","ARC062","ARC097","ARC132","ARC100","ARC039","ARC075"
        },
        -- pack #20 in box #8
        [20] = {
            "ARC192","ARC194","ARC184","ARC185","ARC050","ARC047","ARC095","ARC156","ARC072","ARC020","ARC062","ARC110","ARC145","ARC097","ARC141","ARC077","ARC001"
        },
        -- pack #21 in box #8
        [21] = {
            "ARC208","ARC193","ARC208","ARC188","ARC049","ARC119","ARC127","ARC079","ARC029","ARC063","ARC030","ARC133","ARC100","ARC143","ARC099","ARC002","ARC038"
        },
        -- pack #22 in box #8
        [22] = {
            "ARC204","ARC191","ARC216","ARC207","ARC048","ARC129","ARC108","ARC157","ARC066","ARC028","ARC069","ARC099","ARC132","ARC101","ARC144","ARC114","ARC003"
        },
        -- pack #23 in box #8
        [23] = {
            "ARC213","ARC207","ARC187","ARC209","ARC089","ARC167","ARC207","ARC158","ARC029","ARC061","ARC035","ARC074","ARC103","ARC140","ARC107","ARC001","ARC003"
        },
        -- pack #24 in box #8
        [24] = {
            "ARC186","ARC217","ARC201","ARC192","ARC168","ARC019","ARC110","ARC042","ARC023","ARC073","ARC026","ARC073","ARC094","ARC148","ARC106","ARC002","ARC003"
        },
    },
    -- box #9
    [9] = {
        -- pack #1 in box #9
        [1] = {
            "ARC186","ARC202","ARC216","ARC195","ARC091","ARC161","ARC013","ARC151","ARC073","ARC024","ARC071","ARC094","ARC134","ARC109","ARC147","ARC115","ARC003"
        },
        -- pack #2 in box #9
        [2] = {
            "ARC214","ARC182","ARC203","ARC188","ARC175","ARC126","ARC101","ARC005","ARC067","ARC026","ARC067","ARC036","ARC143","ARC104","ARC147","ARC003","ARC038"
        },
        -- pack #3 in box #9
        [3] = {
            "ARC197","ARC178","ARC188","ARC208","ARC127","ARC014","ARC144","ARC151","ARC067","ARC035","ARC070","ARC023","ARC145","ARC107","ARC148","ARC040","ARC115"
        },
        -- pack #4 in box #9
        [4] = {
            "ARC188","ARC216","ARC183","ARC186","ARC050","ARC008","ARC126","ARC152","ARC035","ARC064","ARC025","ARC149","ARC101","ARC137","ARC102","ARC075","ARC076"
        },
        -- pack #5 in box #9
        [5] = {
            "ARC191","ARC199","ARC190","ARC200","ARC088","ARC019","ARC069","ARC158","ARC029","ARC060","ARC021","ARC134","ARC103","ARC135","ARC096","ARC003","ARC077"
        },
        -- pack #6 in box #9
        [6] = {
            "ARC178","ARC184","ARC191","ARC186","ARC057","ARC119","ARC020","ARC156","ARC030","ARC065","ARC032","ARC070","ARC101","ARC141","ARC104","ARC075","ARC002"
        },
        -- pack #7 in box #9
        [7] = {
            "ARC186","ARC207","ARC217","ARC196","ARC127","ARC018","ARC185","ARC156","ARC022","ARC068","ARC020","ARC139","ARC101","ARC148","ARC107","ARC003","ARC112"
        },
        -- pack #8 in box #9
        [8] = {
            "ARC194","ARC213","ARC211","ARC176","ARC050","ARC090","ARC206","ARC152","ARC037","ARC060","ARC036","ARC132","ARC103","ARC133","ARC102","ARC039","ARC077"
        },
        -- pack #9 in box #9
        [9] = {
            "ARC177","ARC180","ARC192","ARC189","ARC164","ARC171","ARC212","ARC005","ARC024","ARC073","ARC027","ARC062","ARC099","ARC137","ARC111","ARC040","ARC076"
        },
        -- pack #10 in box #9
        [10] = {
            "ARC188","ARC217","ARC198","ARC184","ARC011","ARC014","ARC108","ARC151","ARC030","ARC060","ARC036","ARC065","ARC101","ARC139","ARC105","ARC040","ARC075"
        },
        -- pack #11 in box #9
        [11] = {
            "ARC181","ARC182","ARC206","ARC182","ARC171","ARC015","ARC110","ARC154","ARC033","ARC073","ARC025","ARC060","ARC102","ARC140","ARC104","ARC077","ARC002"
        },
        -- pack #12 in box #9
        [12] = {
            "ARC188","ARC209","ARC188","ARC198","ARC090","ARC125","ARC072","ARC157","ARC063","ARC021","ARC065","ARC110","ARC143","ARC097","ARC136","ARC077","ARC114"
        },
        -- pack #13 in box #9
        [13] = {
            "ARC194","ARC188","ARC190","ARC216","ARC123","ARC087","ARC025","ARC152","ARC065","ARC028","ARC061","ARC023","ARC139","ARC110","ARC143","ARC218"
        },
        -- pack #14 in box #9
        [14] = {
            "ARC215","ARC214","ARC216","ARC179","ARC053","ARC171","ARC036","ARC117","ARC021","ARC066","ARC023","ARC147","ARC095","ARC143","ARC105","ARC218"
        },
        -- pack #15 in box #9
        [15] = {
            "ARC184","ARC185","ARC186","ARC190","ARC091","ARC053","ARC189","ARC152","ARC034","ARC061","ARC020","ARC071","ARC109","ARC142","ARC101","ARC114","ARC003"
        },
        -- pack #16 in box #9
        [16] = {
            "ARC182","ARC184","ARC180","ARC192","ARC017","ARC013","ARC085","ARC156","ARC066","ARC026","ARC074","ARC102","ARC141","ARC109","ARC132","ARC113","ARC040"
        },
        -- pack #17 in box #9
        [17] = {
            "ARC186","ARC194","ARC187","ARC217","ARC093","ARC126","ARC187","ARC156","ARC031","ARC072","ARC030","ARC067","ARC106","ARC145","ARC095","ARC115","ARC076"
        },
        -- pack #18 in box #9
        [18] = {
            "ARC179","ARC187","ARC194","ARC180","ARC093","ARC120","ARC183","ARC154","ARC061","ARC029","ARC072","ARC036","ARC147","ARC108","ARC133","ARC076","ARC112"
        },
        -- pack #19 in box #9
        [19] = {
            "ARC199","ARC204","ARC213","ARC179","ARC049","ARC046","ARC184","ARC154","ARC025","ARC066","ARC036","ARC148","ARC099","ARC144","ARC105","ARC003","ARC001"
        },
        -- pack #20 in box #9
        [20] = {
            "ARC198","ARC180","ARC204","ARC182","ARC126","ARC088","ARC149","ARC155","ARC060","ARC037","ARC060","ARC104","ARC135","ARC098","ARC137","ARC115","ARC001"
        },
        -- pack #21 in box #9
        [21] = {
            "ARC208","ARC214","ARC186","ARC199","ARC171","ARC090","ARC190","ARC156","ARC073","ARC020","ARC073","ARC096","ARC134","ARC107","ARC138","ARC115","ARC001"
        },
        -- pack #22 in box #9
        [22] = {
            "ARC199","ARC183","ARC177","ARC177","ARC054","ARC087","ARC158","ARC155","ARC061","ARC032","ARC070","ARC031","ARC142","ARC098","ARC141","ARC003","ARC112"
        },
        -- pack #23 in box #9
        [23] = {
            "ARC210","ARC214","ARC191","ARC210","ARC013","ARC050","ARC152","ARC156","ARC074","ARC037","ARC071","ARC028","ARC132","ARC110","ARC136","ARC114","ARC039"
        },
        -- pack #24 in box #9
        [24] = {
            "ARC198","ARC188","ARC216","ARC183","ARC018","ARC172","ARC178","ARC153","ARC069","ARC030","ARC072","ARC095","ARC135","ARC100","ARC142","ARC002","ARC112"
        },
    },
    -- box #10
    [10] = {
        -- pack #1 in box #10
        [1] = {
            "ARC194","ARC182","ARC176","ARC190","ARC173","ARC055","ARC133","ARC151","ARC074","ARC020","ARC061","ARC110","ARC146","ARC108","ARC133","ARC113","ARC002"
        },
        -- pack #2 in box #10
        [2] = {
            "ARC180","ARC208","ARC200","ARC214","ARC171","ARC010","ARC032","ARC005","ARC071","ARC022","ARC061","ARC109","ARC144","ARC108","ARC145","ARC075","ARC115"
        },
        -- pack #3 in box #10
        [3] = {
            "ARC205","ARC196","ARC207","ARC216","ARC048","ARC088","ARC037","ARC157","ARC062","ARC035","ARC070","ARC100","ARC138","ARC102","ARC135","ARC076","ARC113"
        },
        -- pack #4 in box #10
        [4] = {
            "ARC200","ARC217","ARC203","ARC203","ARC088","ARC175","ARC179","ARC151","ARC027","ARC066","ARC025","ARC074","ARC097","ARC135","ARC101","ARC113","ARC076"
        },
        -- pack #5 in box #10
        [5] = {
            "ARC211","ARC203","ARC197","ARC213","ARC019","ARC082","ARC043","ARC079","ARC071","ARC036","ARC062","ARC031","ARC142","ARC099","ARC145","ARC001","ARC040"
        },
        -- pack #6 in box #10
        [6] = {
            "ARC196","ARC199","ARC203","ARC183","ARC171","ARC085","ARC061","ARC117","ARC064","ARC031","ARC070","ARC106","ARC144","ARC104","ARC141","ARC003","ARC077"
        },
        -- pack #7 in box #10
        [7] = {
            "ARC185","ARC203","ARC190","ARC205","ARC014","ARC125","ARC082","ARC117","ARC067","ARC023","ARC063","ARC035","ARC148","ARC104","ARC135","ARC039","ARC002"
        },
        -- pack #8 in box #10
        [8] = {
            "ARC199","ARC215","ARC207","ARC185","ARC171","ARC049","ARC142","ARC079","ARC020","ARC068","ARC027","ARC140","ARC102","ARC137","ARC102","ARC113","ARC001"
        },
        -- pack #9 in box #10
        [9] = {
            "ARC196","ARC215","ARC208","ARC181","ARC011","ARC080","ARC133","ARC152","ARC035","ARC069","ARC034","ARC135","ARC106","ARC147","ARC102","ARC113","ARC115"
        },
        -- pack #10 in box #10
        [10] = {
            "ARC211","ARC189","ARC203","ARC204","ARC058","ARC053","ARC132","ARC005","ARC069","ARC033","ARC063","ARC031","ARC145","ARC104","ARC136","ARC075","ARC003"
        },
        -- pack #11 in box #10
        [11] = {
            "ARC207","ARC212","ARC183","ARC200","ARC086","ARC085","ARC178","ARC042","ARC030","ARC061","ARC023","ARC064","ARC107","ARC149","ARC105","ARC218"
        },
        -- pack #12 in box #10
        [12] = {
            "ARC177","ARC180","ARC217","ARC212","ARC018","ARC165","ARC143","ARC153","ARC022","ARC065","ARC032","ARC063","ARC105","ARC146","ARC110","ARC040","ARC001"
        },
        -- pack #13 in box #10
        [13] = {
            "ARC200","ARC205","ARC196","ARC192","ARC168","ARC016","ARC072","ARC154","ARC035","ARC074","ARC033","ARC073","ARC110","ARC132","ARC096","ARC112","ARC075"
        },
        -- pack #14 in box #10
        [14] = {
            "ARC198","ARC177","ARC179","ARC181","ARC051","ARC057","ARC034","ARC158","ARC026","ARC062","ARC034","ARC074","ARC097","ARC140","ARC106","ARC115","ARC114"
        },
        -- pack #15 in box #10
        [15] = {
            "ARC187","ARC187","ARC209","ARC191","ARC130","ARC008","ARC177","ARC042","ARC021","ARC063","ARC026","ARC146","ARC098","ARC148","ARC096","ARC003","ARC113"
        },
        -- pack #16 in box #10
        [16] = {
            "ARC208","ARC206","ARC195","ARC188","ARC015","ARC119","ARC086","ARC005","ARC033","ARC073","ARC021","ARC132","ARC097","ARC148","ARC104","ARC113","ARC077"
        },
        -- pack #17 in box #10
        [17] = {
            "ARC203","ARC185","ARC196","ARC216","ARC051","ARC053","ARC190","ARC152","ARC028","ARC073","ARC021","ARC137","ARC110","ARC144","ARC109","ARC115","ARC040"
        },
        -- pack #18 in box #10
        [18] = {
            "ARC202","ARC191","ARC207","ARC190","ARC129","ARC052","ARC182","ARC154","ARC037","ARC069","ARC023","ARC073","ARC094","ARC145","ARC102","ARC114","ARC039"
        },
        -- pack #19 in box #10
        [19] = {
            "ARC186","ARC201","ARC216","ARC208","ARC087","ARC043","ARC065","ARC154","ARC061","ARC024","ARC070","ARC102","ARC141","ARC095","ARC135","ARC218"
        },
        -- pack #20 in box #10
        [20] = {
            "ARC213","ARC206","ARC194","ARC178","ARC127","ARC162","ARC071","ARC155","ARC073","ARC020","ARC063","ARC027","ARC136","ARC105","ARC137","ARC002","ARC075"
        },
        -- pack #21 in box #10
        [21] = {
            "ARC176","ARC209","ARC177","ARC204","ARC053","ARC171","ARC033","ARC156","ARC065","ARC021","ARC069","ARC103","ARC143","ARC102","ARC133","ARC075","ARC002"
        },
        -- pack #22 in box #10
        [22] = {
            "ARC184","ARC185","ARC197","ARC185","ARC128","ARC010","ARC011","ARC153","ARC073","ARC034","ARC074","ARC033","ARC147","ARC105","ARC148","ARC114","ARC075"
        },
        -- pack #23 in box #10
        [23] = {
            "ARC186","ARC190","ARC180","ARC189","ARC016","ARC010","ARC074","ARC079","ARC061","ARC020","ARC068","ARC021","ARC133","ARC098","ARC141","ARC040","ARC002"
        },
        -- pack #24 in box #10
        [24] = {
            "ARC191","ARC195","ARC210","ARC178","ARC018","ARC130","ARC005","ARC158","ARC028","ARC060","ARC028","ARC136","ARC096","ARC148","ARC098","ARC115","ARC075"
        },
    },
    -- box #11
    [11] = {
        -- pack #1 in box #11
        [1] = {
            "ARC213","ARC188","ARC178","ARC213","ARC093","ARC083","ARC174","ARC005","ARC021","ARC074","ARC031","ARC066","ARC101","ARC133","ARC107","ARC077","ARC002"
        },
        -- pack #2 in box #11
        [2] = {
            "ARC212","ARC202","ARC215","ARC186","ARC092","ARC129","ARC011","ARC156","ARC025","ARC063","ARC030","ARC140","ARC101","ARC142","ARC095","ARC075","ARC077"
        },
        -- pack #3 in box #11
        [3] = {
            "ARC188","ARC197","ARC185","ARC189","ARC019","ARC091","ARC166","ARC157","ARC062","ARC036","ARC061","ARC035","ARC144","ARC102","ARC143","ARC113","ARC077"
        },
        -- pack #4 in box #11
        [4] = {
            "ARC208","ARC193","ARC189","ARC187","ARC125","ARC059","ARC023","ARC153","ARC063","ARC034","ARC064","ARC105","ARC136","ARC103","ARC144","ARC001","ARC075"
        },
        -- pack #5 in box #11
        [5] = {
            "ARC211","ARC200","ARC202","ARC212","ARC123","ARC045","ARC211","ARC158","ARC065","ARC037","ARC070","ARC030","ARC138","ARC099","ARC138","ARC075","ARC113"
        },
        -- pack #6 in box #11
        [6] = {
            "ARC182","ARC209","ARC196","ARC193","ARC056","ARC046","ARC210","ARC005","ARC022","ARC066","ARC035","ARC134","ARC094","ARC145","ARC108","ARC040","ARC115"
        },
        -- pack #7 in box #11
        [7] = {
            "ARC181","ARC198","ARC198","ARC208","ARC051","ARC083","ARC104","ARC117","ARC068","ARC023","ARC069","ARC100","ARC143","ARC102","ARC143","ARC002","ARC077"
        },
        -- pack #8 in box #11
        [8] = {
            "ARC179","ARC181","ARC184","ARC192","ARC015","ARC009","ARC166","ARC158","ARC070","ARC028","ARC065","ARC109","ARC146","ARC099","ARC145","ARC076","ARC002"
        },
        -- pack #9 in box #11
        [9] = {
            "ARC211","ARC195","ARC179","ARC201","ARC175","ARC083","ARC035","ARC157","ARC064","ARC021","ARC061","ARC104","ARC143","ARC100","ARC142","ARC039","ARC114"
        },
        -- pack #10 in box #11
        [10] = {
            "ARC178","ARC215","ARC203","ARC195","ARC091","ARC010","ARC006","ARC152","ARC069","ARC031","ARC060","ARC020","ARC136","ARC102","ARC148","ARC112","ARC003"
        },
        -- pack #11 in box #11
        [11] = {
            "ARC182","ARC177","ARC193","ARC190","ARC171","ARC171","ARC024","ARC154","ARC021","ARC074","ARC024","ARC064","ARC109","ARC134","ARC096","ARC040","ARC001"
        },
        -- pack #12 in box #11
        [12] = {
            "ARC200","ARC202","ARC197","ARC176","ARC088","ARC047","ARC029","ARC155","ARC060","ARC034","ARC062","ARC022","ARC143","ARC106","ARC149","ARC113","ARC002"
        },
        -- pack #13 in box #11
        [13] = {
            "ARC217","ARC182","ARC206","ARC189","ARC173","ARC057","ARC187","ARC079","ARC066","ARC021","ARC072","ARC098","ARC140","ARC109","ARC133","ARC112","ARC040"
        },
        -- pack #14 in box #11
        [14] = {
            "ARC206","ARC188","ARC187","ARC199","ARC127","ARC058","ARC022","ARC005","ARC021","ARC060","ARC023","ARC071","ARC103","ARC147","ARC110","ARC001","ARC002"
        },
        -- pack #15 in box #11
        [15] = {
            "ARC192","ARC210","ARC193","ARC192","ARC091","ARC012","ARC036","ARC155","ARC029","ARC066","ARC028","ARC067","ARC106","ARC134","ARC100","ARC112","ARC115"
        },
        -- pack #16 in box #11
        [16] = {
            "ARC204","ARC213","ARC210","ARC201","ARC017","ARC087","ARC067","ARC079","ARC066","ARC032","ARC062","ARC030","ARC146","ARC110","ARC142","ARC114","ARC076"
        },
        -- pack #17 in box #11
        [17] = {
            "ARC186","ARC195","ARC178","ARC189","ARC125","ARC131","ARC208","ARC079","ARC037","ARC067","ARC036","ARC066","ARC096","ARC146","ARC111","ARC039","ARC075"
        },
        -- pack #18 in box #11
        [18] = {
            "ARC206","ARC202","ARC181","ARC196","ARC048","ARC122","ARC092","ARC079","ARC061","ARC034","ARC066","ARC095","ARC136","ARC110","ARC133","ARC001","ARC075"
        },
        -- pack #19 in box #11
        [19] = {
            "ARC191","ARC180","ARC204","ARC195","ARC017","ARC057","ARC013","ARC155","ARC035","ARC063","ARC028","ARC065","ARC094","ARC143","ARC095","ARC115","ARC001"
        },
        -- pack #20 in box #11
        [20] = {
            "ARC204","ARC202","ARC209","ARC198","ARC048","ARC017","ARC109","ARC079","ARC021","ARC073","ARC034","ARC139","ARC110","ARC145","ARC095","ARC115","ARC039"
        },
        -- pack #21 in box #11
        [21] = {
            "ARC193","ARC191","ARC190","ARC186","ARC090","ARC161","ARC056","ARC155","ARC028","ARC072","ARC031","ARC132","ARC105","ARC143","ARC094","ARC038","ARC077"
        },
        -- pack #22 in box #11
        [22] = {
            "ARC176","ARC189","ARC208","ARC188","ARC017","ARC120","ARC192","ARC079","ARC020","ARC060","ARC020","ARC146","ARC099","ARC139","ARC105","ARC114","ARC001"
        },
        -- pack #23 in box #11
        [23] = {
            "ARC199","ARC196","ARC191","ARC210","ARC049","ARC164","ARC145","ARC042","ARC022","ARC062","ARC024","ARC146","ARC097","ARC137","ARC111","ARC002","ARC039"
        },
        -- pack #24 in box #11
        [24] = {
            "ARC184","ARC193","ARC211","ARC192","ARC166","ARC054","ARC022","ARC005","ARC062","ARC030","ARC072","ARC026","ARC139","ARC104","ARC145","ARC040","ARC115"
        },
    },
    -- box #12
    [12] = {
        -- pack #1 in box #12
        [1] = {
            "ARC184","ARC217","ARC197","ARC177","ARC086","ARC163","ARC021","ARC151","ARC030","ARC067","ARC026","ARC133","ARC096","ARC137","ARC106","ARC040","ARC114"
        },
        -- pack #2 in box #12
        [2] = {
            "ARC198","ARC214","ARC216","ARC214","ARC087","ARC175","ARC007","ARC157","ARC074","ARC029","ARC064","ARC029","ARC138","ARC094","ARC144","ARC114","ARC001"
        },
        -- pack #3 in box #12
        [3] = {
            "ARC190","ARC194","ARC208","ARC190","ARC014","ARC019","ARC026","ARC079","ARC030","ARC071","ARC021","ARC065","ARC109","ARC149","ARC099","ARC002","ARC076"
        },
        -- pack #4 in box #12
        [4] = {
            "ARC194","ARC185","ARC213","ARC180","ARC093","ARC044","ARC105","ARC155","ARC066","ARC028","ARC063","ARC096","ARC138","ARC105","ARC142","ARC112","ARC038"
        },
        -- pack #5 in box #12
        [5] = {
            "ARC206","ARC215","ARC197","ARC212","ARC019","ARC092","ARC134","ARC156","ARC029","ARC064","ARC029","ARC148","ARC111","ARC142","ARC099","ARC112","ARC075"
        },
        -- pack #6 in box #12
        [6] = {
            "ARC212","ARC186","ARC204","ARC217","ARC053","ARC162","ARC139","ARC079","ARC037","ARC066","ARC036","ARC146","ARC111","ARC133","ARC102","ARC001","ARC114"
        },
        -- pack #7 in box #12
        [7] = {
            "ARC193","ARC213","ARC215","ARC180","ARC090","ARC126","ARC125","ARC152","ARC060","ARC027","ARC063","ARC108","ARC134","ARC102","ARC145","ARC040","ARC003"
        },
        -- pack #8 in box #12
        [8] = {
            "ARC214","ARC213","ARC208","ARC216","ARC165","ARC048","ARC176","ARC153","ARC026","ARC073","ARC032","ARC140","ARC098","ARC139","ARC103","ARC218"
        },
        -- pack #9 in box #12
        [9] = {
            "ARC209","ARC192","ARC205","ARC180","ARC054","ARC131","ARC201","ARC151","ARC063","ARC021","ARC068","ARC029","ARC139","ARC102","ARC148","ARC115","ARC040"
        },
        -- pack #10 in box #12
        [10] = {
            "ARC194","ARC194","ARC198","ARC177","ARC172","ARC017","ARC031","ARC151","ARC034","ARC067","ARC020","ARC065","ARC104","ARC149","ARC095","ARC003","ARC038"
        },
        -- pack #11 in box #12
        [11] = {
            "ARC201","ARC204","ARC202","ARC212","ARC055","ARC174","ARC133","ARC152","ARC067","ARC026","ARC074","ARC107","ARC141","ARC097","ARC135","ARC003","ARC038"
        },
        -- pack #12 in box #12
        [12] = {
            "ARC178","ARC185","ARC196","ARC191","ARC131","ARC126","ARC023","ARC117","ARC071","ARC026","ARC061","ARC020","ARC134","ARC107","ARC144","ARC076","ARC113"
        },
        -- pack #13 in box #12
        [13] = {
            "ARC182","ARC203","ARC216","ARC196","ARC174","ARC044","ARC201","ARC155","ARC074","ARC023","ARC068","ARC102","ARC134","ARC101","ARC146","ARC113","ARC115"
        },
        -- pack #14 in box #12
        [14] = {
            "ARC186","ARC187","ARC215","ARC192","ARC059","ARC162","ARC190","ARC079","ARC025","ARC061","ARC030","ARC065","ARC098","ARC143","ARC110","ARC038","ARC002"
        },
        -- pack #15 in box #12
        [15] = {
            "ARC201","ARC181","ARC180","ARC197","ARC057","ARC162","ARC167","ARC152","ARC026","ARC068","ARC034","ARC063","ARC108","ARC146","ARC110","ARC038","ARC113"
        },
        -- pack #16 in box #12
        [16] = {
            "ARC180","ARC193","ARC192","ARC188","ARC011","ARC126","ARC148","ARC157","ARC032","ARC070","ARC031","ARC068","ARC111","ARC135","ARC109","ARC076","ARC075"
        },
        -- pack #17 in box #12
        [17] = {
            "ARC207","ARC195","ARC181","ARC213","ARC051","ARC121","ARC147","ARC005","ARC061","ARC020","ARC061","ARC022","ARC148","ARC107","ARC138","ARC003","ARC040"
        },
        -- pack #18 in box #12
        [18] = {
            "ARC188","ARC188","ARC214","ARC179","ARC013","ARC017","ARC105","ARC005","ARC067","ARC021","ARC069","ARC029","ARC136","ARC107","ARC143","ARC039","ARC038"
        },
        -- pack #19 in box #12
        [19] = {
            "ARC208","ARC193","ARC184","ARC212","ARC169","ARC088","ARC035","ARC042","ARC070","ARC021","ARC066","ARC030","ARC144","ARC099","ARC139","ARC001","ARC076"
        },
        -- pack #20 in box #12
        [20] = {
            "ARC217","ARC191","ARC183","ARC215","ARC052","ARC170","ARC205","ARC156","ARC037","ARC072","ARC031","ARC146","ARC104","ARC134","ARC100","ARC115","ARC077"
        },
        -- pack #21 in box #12
        [21] = {
            "ARC209","ARC212","ARC214","ARC206","ARC091","ARC129","ARC163","ARC155","ARC027","ARC074","ARC025","ARC147","ARC096","ARC149","ARC108","ARC040","ARC113"
        },
        -- pack #22 in box #12
        [22] = {
            "ARC216","ARC205","ARC204","ARC209","ARC053","ARC093","ARC186","ARC156","ARC063","ARC033","ARC062","ARC109","ARC132","ARC108","ARC136","ARC002","ARC113"
        },
        -- pack #23 in box #12
        [23] = {
            "ARC199","ARC196","ARC202","ARC178","ARC088","ARC127","ARC207","ARC042","ARC034","ARC067","ARC027","ARC066","ARC099","ARC134","ARC101","ARC039","ARC112"
        },
        -- pack #24 in box #12
        [24] = {
            "ARC216","ARC193","ARC188","ARC210","ARC049","ARC082","ARC016","ARC157","ARC064","ARC026","ARC065","ARC096","ARC139","ARC111","ARC133","ARC113","ARC076"
        },
    },
    -- box #13
    [13] = {
        -- pack #1 in box #13
        [1] = {
            "ARC216","ARC185","ARC186","ARC194","ARC048","ARC090","ARC205","ARC042","ARC024","ARC063","ARC033","ARC132","ARC097","ARC140","ARC103","ARC075","ARC076"
        },
        -- pack #2 in box #13
        [2] = {
            "ARC191","ARC207","ARC216","ARC201","ARC059","ARC052","ARC116","ARC153","ARC071","ARC031","ARC072","ARC034","ARC134","ARC106","ARC148","ARC075","ARC077"
        },
        -- pack #3 in box #13
        [3] = {
            "ARC181","ARC210","ARC215","ARC217","ARC048","ARC124","ARC042","ARC156","ARC020","ARC065","ARC027","ARC068","ARC107","ARC144","ARC094","ARC003","ARC115"
        },
        -- pack #4 in box #13
        [4] = {
            "ARC181","ARC207","ARC193","ARC210","ARC057","ARC172","ARC071","ARC042","ARC023","ARC061","ARC026","ARC064","ARC101","ARC147","ARC109","ARC075","ARC002"
        },
        -- pack #5 in box #13
        [5] = {
            "ARC210","ARC216","ARC193","ARC192","ARC088","ARC160","ARC028","ARC156","ARC062","ARC030","ARC071","ARC109","ARC138","ARC098","ARC137","ARC113","ARC039"
        },
        -- pack #6 in box #13
        [6] = {
            "ARC212","ARC202","ARC177","ARC190","ARC089","ARC088","ARC098","ARC117","ARC071","ARC026","ARC061","ARC026","ARC133","ARC110","ARC141","ARC112","ARC075"
        },
        -- pack #7 in box #13
        [7] = {
            "ARC181","ARC210","ARC207","ARC192","ARC053","ARC008","ARC072","ARC157","ARC037","ARC064","ARC023","ARC141","ARC107","ARC149","ARC098","ARC113","ARC115"
        },
        -- pack #8 in box #13
        [8] = {
            "ARC192","ARC191","ARC186","ARC181","ARC092","ARC089","ARC117","ARC153","ARC063","ARC025","ARC070","ARC106","ARC146","ARC109","ARC146","ARC076","ARC038"
        },
        -- pack #9 in box #13
        [9] = {
            "ARC182","ARC208","ARC192","ARC194","ARC171","ARC083","ARC008","ARC152","ARC037","ARC066","ARC036","ARC074","ARC101","ARC140","ARC095","ARC112","ARC115"
        },
        -- pack #10 in box #13
        [10] = {
            "ARC206","ARC182","ARC196","ARC212","ARC174","ARC086","ARC025","ARC005","ARC035","ARC061","ARC031","ARC066","ARC095","ARC147","ARC098","ARC075","ARC112"
        },
        -- pack #11 in box #13
        [11] = {
            "ARC214","ARC206","ARC179","ARC180","ARC085","ARC120","ARC135","ARC042","ARC027","ARC069","ARC030","ARC143","ARC106","ARC147","ARC105","ARC075","ARC077"
        },
        -- pack #12 in box #13
        [12] = {
            "ARC184","ARC205","ARC203","ARC204","ARC059","ARC126","ARC072","ARC155","ARC068","ARC020","ARC065","ARC025","ARC133","ARC097","ARC141","ARC112","ARC003"
        },
        -- pack #13 in box #13
        [13] = {
            "ARC207","ARC183","ARC182","ARC204","ARC017","ARC092","ARC180","ARC152","ARC061","ARC029","ARC064","ARC106","ARC142","ARC102","ARC136","ARC075","ARC115"
        },
        -- pack #14 in box #13
        [14] = {
            "ARC194","ARC183","ARC202","ARC193","ARC128","ARC057","ARC014","ARC157","ARC070","ARC030","ARC074","ARC037","ARC137","ARC095","ARC142","ARC039","ARC112"
        },
        -- pack #15 in box #13
        [15] = {
            "ARC202","ARC177","ARC176","ARC197","ARC011","ARC011","ARC107","ARC151","ARC027","ARC060","ARC031","ARC060","ARC095","ARC141","ARC099","ARC077","ARC002"
        },
        -- pack #16 in box #13
        [16] = {
            "ARC214","ARC190","ARC182","ARC216","ARC125","ARC170","ARC165","ARC079","ARC067","ARC036","ARC065","ARC102","ARC144","ARC104","ARC142","ARC040","ARC077"
        },
        -- pack #17 in box #13
        [17] = {
            "ARC177","ARC189","ARC214","ARC217","ARC011","ARC054","ARC198","ARC117","ARC022","ARC060","ARC032","ARC146","ARC108","ARC144","ARC108","ARC038","ARC114"
        },
        -- pack #18 in box #13
        [18] = {
            "ARC178","ARC182","ARC198","ARC190","ARC016","ARC093","ARC084","ARC117","ARC022","ARC067","ARC020","ARC073","ARC095","ARC144","ARC110","ARC115","ARC077"
        },
        -- pack #19 in box #13
        [19] = {
            "ARC217","ARC194","ARC193","ARC213","ARC058","ARC012","ARC186","ARC157","ARC064","ARC024","ARC072","ARC027","ARC137","ARC107","ARC132","ARC115","ARC075"
        },
        -- pack #20 in box #13
        [20] = {
            "ARC198","ARC212","ARC211","ARC205","ARC131","ARC059","ARC142","ARC154","ARC068","ARC026","ARC069","ARC099","ARC136","ARC102","ARC143","ARC039","ARC075"
        },
        -- pack #21 in box #13
        [21] = {
            "ARC184","ARC189","ARC212","ARC199","ARC174","ARC051","ARC179","ARC154","ARC026","ARC063","ARC033","ARC138","ARC110","ARC140","ARC104","ARC115","ARC114"
        },
        -- pack #22 in box #13
        [22] = {
            "ARC195","ARC193","ARC180","ARC214","ARC052","ARC174","ARC029","ARC156","ARC021","ARC070","ARC027","ARC133","ARC106","ARC135","ARC111","ARC114","ARC038"
        },
        -- pack #23 in box #13
        [23] = {
            "ARC201","ARC186","ARC215","ARC176","ARC087","ARC122","ARC193","ARC152","ARC073","ARC034","ARC067","ARC094","ARC135","ARC105","ARC148","ARC115","ARC003"
        },
        -- pack #24 in box #13
        [24] = {
            "ARC196","ARC192","ARC210","ARC189","ARC174","ARC129","ARC178","ARC158","ARC060","ARC033","ARC071","ARC021","ARC136","ARC096","ARC138","ARC040","ARC001"
        },
    },
    -- box #14
    [14] = {
        -- pack #1 in box #14
        [1] = {
            "ARC194","ARC200","ARC184","ARC212","ARC059","ARC090","ARC217","ARC005","ARC066","ARC028","ARC070","ARC028","ARC147","ARC111","ARC141","ARC075","ARC002"
        },
        -- pack #2 in box #14
        [2] = {
            "ARC208","ARC206","ARC194","ARC177","ARC016","ARC013","ARC149","ARC156","ARC032","ARC074","ARC027","ARC062","ARC094","ARC138","ARC094","ARC218"
        },
        -- pack #3 in box #14
        [3] = {
            "ARC214","ARC205","ARC210","ARC185","ARC014","ARC087","ARC062","ARC157","ARC022","ARC073","ARC033","ARC062","ARC105","ARC146","ARC111","ARC115","ARC077"
        },
        -- pack #4 in box #14
        [4] = {
            "ARC193","ARC214","ARC191","ARC217","ARC090","ARC093","ARC214","ARC005","ARC064","ARC033","ARC063","ARC100","ARC145","ARC109","ARC148","ARC112","ARC115"
        },
        -- pack #5 in box #14
        [5] = {
            "ARC198","ARC182","ARC189","ARC203","ARC087","ARC044","ARC105","ARC157","ARC061","ARC031","ARC063","ARC110","ARC143","ARC109","ARC137","ARC218"
        },
        -- pack #6 in box #14
        [6] = {
            "ARC206","ARC204","ARC196","ARC212","ARC052","ARC123","ARC183","ARC005","ARC021","ARC065","ARC028","ARC133","ARC109","ARC132","ARC106","ARC002","ARC001"
        },
        -- pack #7 in box #14
        [7] = {
            "ARC207","ARC204","ARC179","ARC207","ARC170","ARC014","ARC134","ARC154","ARC061","ARC031","ARC067","ARC107","ARC134","ARC102","ARC145","ARC040","ARC002"
        },
        -- pack #8 in box #14
        [8] = {
            "ARC216","ARC210","ARC201","ARC180","ARC168","ARC088","ARC005","ARC152","ARC032","ARC061","ARC022","ARC066","ARC107","ARC148","ARC103","ARC040","ARC113"
        },
        -- pack #9 in box #14
        [9] = {
            "ARC187","ARC210","ARC210","ARC200","ARC174","ARC165","ARC095","ARC158","ARC031","ARC062","ARC027","ARC062","ARC108","ARC138","ARC099","ARC114","ARC003"
        },
        -- pack #10 in box #14
        [10] = {
            "ARC192","ARC180","ARC211","ARC198","ARC052","ARC175","ARC150","ARC151","ARC065","ARC037","ARC071","ARC036","ARC149","ARC094","ARC134","ARC001","ARC114"
        },
        -- pack #11 in box #14
        [11] = {
            "ARC196","ARC197","ARC215","ARC192","ARC131","ARC043","ARC193","ARC117","ARC021","ARC061","ARC025","ARC062","ARC098","ARC139","ARC101","ARC038","ARC076"
        },
        -- pack #12 in box #14
        [12] = {
            "ARC215","ARC213","ARC188","ARC196","ARC131","ARC174","ARC206","ARC152","ARC027","ARC070","ARC030","ARC061","ARC099","ARC132","ARC094","ARC003","ARC076"
        },
        -- pack #13 in box #14
        [13] = {
            "ARC186","ARC180","ARC191","ARC209","ARC051","ARC054","ARC139","ARC117","ARC036","ARC064","ARC035","ARC135","ARC102","ARC137","ARC100","ARC077","ARC113"
        },
        -- pack #14 in box #14
        [14] = {
            "ARC208","ARC198","ARC213","ARC186","ARC168","ARC127","ARC042","ARC005","ARC037","ARC072","ARC033","ARC146","ARC094","ARC135","ARC094","ARC076","ARC038"
        },
        -- pack #15 in box #14
        [15] = {
            "ARC181","ARC213","ARC210","ARC212","ARC128","ARC059","ARC028","ARC079","ARC073","ARC036","ARC062","ARC028","ARC132","ARC106","ARC139","ARC040","ARC001"
        },
        -- pack #16 in box #14
        [16] = {
            "ARC207","ARC196","ARC216","ARC176","ARC085","ARC124","ARC067","ARC152","ARC064","ARC035","ARC064","ARC103","ARC149","ARC100","ARC143","ARC076","ARC001"
        },
        -- pack #17 in box #14
        [17] = {
            "ARC197","ARC178","ARC209","ARC187","ARC123","ARC091","ARC140","ARC154","ARC071","ARC031","ARC065","ARC109","ARC140","ARC109","ARC139","ARC112","ARC001"
        },
        -- pack #18 in box #14
        [18] = {
            "ARC217","ARC191","ARC217","ARC193","ARC051","ARC161","ARC012","ARC079","ARC028","ARC064","ARC037","ARC147","ARC097","ARC134","ARC106","ARC002","ARC112"
        },
        -- pack #19 in box #14
        [19] = {
            "ARC187","ARC200","ARC213","ARC203","ARC017","ARC119","ARC159","ARC154","ARC063","ARC023","ARC073","ARC028","ARC147","ARC106","ARC141","ARC114","ARC112"
        },
        -- pack #20 in box #14
        [20] = {
            "ARC177","ARC176","ARC208","ARC207","ARC053","ARC014","ARC151","ARC005","ARC029","ARC069","ARC022","ARC144","ARC096","ARC133","ARC106","ARC075","ARC114"
        },
        -- pack #21 in box #14
        [21] = {
            "ARC206","ARC206","ARC181","ARC195","ARC123","ARC059","ARC147","ARC154","ARC068","ARC023","ARC072","ARC020","ARC145","ARC102","ARC143","ARC003","ARC076"
        },
        -- pack #22 in box #14
        [22] = {
            "ARC216","ARC176","ARC178","ARC195","ARC089","ARC161","ARC158","ARC155","ARC062","ARC036","ARC060","ARC100","ARC147","ARC100","ARC134","ARC218"
        },
        -- pack #23 in box #14
        [23] = {
            "ARC205","ARC183","ARC189","ARC186","ARC169","ARC049","ARC198","ARC151","ARC063","ARC032","ARC062","ARC020","ARC149","ARC096","ARC135","ARC040","ARC077"
        },
        -- pack #24 in box #14
        [24] = {
            "ARC195","ARC188","ARC180","ARC183","ARC090","ARC172","ARC199","ARC158","ARC031","ARC061","ARC032","ARC137","ARC101","ARC143","ARC097","ARC038","ARC112"
        },
    },
    -- box #15
    [15] = {
        -- pack #1 in box #15
        [1] = {
            "ARC200","ARC177","ARC197","ARC208","ARC050","ARC162","ARC217","ARC154","ARC029","ARC066","ARC037","ARC071","ARC103","ARC133","ARC100","ARC001","ARC076"
        },
        -- pack #2 in box #15
        [2] = {
            "ARC198","ARC197","ARC184","ARC210","ARC052","ARC169","ARC216","ARC117","ARC069","ARC026","ARC068","ARC100","ARC138","ARC101","ARC144","ARC039","ARC002"
        },
        -- pack #3 in box #15
        [3] = {
            "ARC206","ARC196","ARC215","ARC191","ARC124","ARC011","ARC011","ARC152","ARC023","ARC065","ARC024","ARC145","ARC094","ARC145","ARC096","ARC038","ARC003"
        },
        -- pack #4 in box #15
        [4] = {
            "ARC190","ARC189","ARC212","ARC194","ARC126","ARC052","ARC178","ARC153","ARC061","ARC035","ARC065","ARC034","ARC147","ARC098","ARC140","ARC114","ARC039"
        },
        -- pack #5 in box #15
        [5] = {
            "ARC206","ARC214","ARC211","ARC193","ARC164","ARC043","ARC104","ARC042","ARC030","ARC066","ARC036","ARC133","ARC104","ARC134","ARC111","ARC218"
        },
        -- pack #6 in box #15
        [6] = {
            "ARC203","ARC197","ARC201","ARC188","ARC055","ARC169","ARC099","ARC079","ARC026","ARC073","ARC034","ARC066","ARC095","ARC143","ARC100","ARC039","ARC076"
        },
        -- pack #7 in box #15
        [7] = {
            "ARC186","ARC212","ARC210","ARC184","ARC013","ARC057","ARC102","ARC042","ARC060","ARC029","ARC066","ARC094","ARC139","ARC102","ARC146","ARC002","ARC076"
        },
        -- pack #8 in box #15
        [8] = {
            "ARC176","ARC201","ARC194","ARC178","ARC172","ARC161","ARC170","ARC155","ARC032","ARC071","ARC030","ARC063","ARC102","ARC147","ARC097","ARC113","ARC115"
        },
        -- pack #9 in box #15
        [9] = {
            "ARC213","ARC211","ARC209","ARC202","ARC085","ARC046","ARC033","ARC079","ARC022","ARC066","ARC025","ARC134","ARC105","ARC135","ARC108","ARC218"
        },
        -- pack #10 in box #15
        [10] = {
            "ARC191","ARC208","ARC196","ARC210","ARC059","ARC043","ARC182","ARC117","ARC067","ARC022","ARC068","ARC107","ARC145","ARC106","ARC139","ARC003","ARC038"
        },
        -- pack #11 in box #15
        [11] = {
            "ARC211","ARC208","ARC199","ARC195","ARC129","ARC056","ARC152","ARC154","ARC037","ARC073","ARC032","ARC134","ARC103","ARC134","ARC106","ARC039","ARC077"
        },
        -- pack #12 in box #15
        [12] = {
            "ARC192","ARC187","ARC176","ARC202","ARC051","ARC052","ARC140","ARC005","ARC067","ARC025","ARC072","ARC031","ARC132","ARC097","ARC140","ARC113","ARC112"
        },
        -- pack #13 in box #15
        [13] = {
            "ARC203","ARC179","ARC216","ARC212","ARC086","ARC017","ARC059","ARC158","ARC072","ARC037","ARC067","ARC106","ARC137","ARC106","ARC133","ARC077","ARC112"
        },
        -- pack #14 in box #15
        [14] = {
            "ARC199","ARC205","ARC176","ARC179","ARC055","ARC053","ARC027","ARC042","ARC071","ARC033","ARC061","ARC033","ARC144","ARC111","ARC138","ARC113","ARC077"
        },
        -- pack #15 in box #15
        [15] = {
            "ARC215","ARC204","ARC176","ARC185","ARC171","ARC055","ARC097","ARC155","ARC033","ARC062","ARC023","ARC141","ARC100","ARC138","ARC103","ARC003","ARC115"
        },
        -- pack #16 in box #15
        [16] = {
            "ARC215","ARC209","ARC206","ARC195","ARC175","ARC015","ARC016","ARC154","ARC062","ARC035","ARC063","ARC029","ARC147","ARC098","ARC139","ARC039","ARC003"
        },
        -- pack #17 in box #15
        [17] = {
            "ARC180","ARC215","ARC213","ARC199","ARC016","ARC053","ARC125","ARC153","ARC029","ARC070","ARC020","ARC069","ARC097","ARC147","ARC107","ARC038","ARC114"
        },
        -- pack #18 in box #15
        [18] = {
            "ARC181","ARC189","ARC182","ARC210","ARC058","ARC165","ARC122","ARC153","ARC071","ARC037","ARC066","ARC110","ARC146","ARC107","ARC132","ARC113","ARC040"
        },
        -- pack #19 in box #15
        [19] = {
            "ARC216","ARC180","ARC184","ARC201","ARC125","ARC087","ARC171","ARC157","ARC065","ARC032","ARC069","ARC035","ARC139","ARC094","ARC145","ARC001","ARC077"
        },
        -- pack #20 in box #15
        [20] = {
            "ARC194","ARC199","ARC212","ARC216","ARC128","ARC092","ARC181","ARC153","ARC073","ARC024","ARC065","ARC107","ARC149","ARC106","ARC147","ARC113","ARC001"
        },
        -- pack #21 in box #15
        [21] = {
            "ARC211","ARC203","ARC196","ARC207","ARC053","ARC120","ARC146","ARC157","ARC023","ARC071","ARC022","ARC139","ARC098","ARC138","ARC108","ARC218"
        },
        -- pack #22 in box #15
        [22] = {
            "ARC215","ARC206","ARC210","ARC208","ARC089","ARC048","ARC146","ARC155","ARC027","ARC061","ARC023","ARC067","ARC106","ARC134","ARC108","ARC039","ARC001"
        },
        -- pack #23 in box #15
        [23] = {
            "ARC194","ARC180","ARC197","ARC210","ARC018","ARC052","ARC157","ARC153","ARC021","ARC065","ARC022","ARC063","ARC105","ARC141","ARC099","ARC218"
        },
        -- pack #24 in box #15
        [24] = {
            "ARC183","ARC204","ARC205","ARC195","ARC016","ARC165","ARC036","ARC042","ARC074","ARC030","ARC064","ARC021","ARC136","ARC109","ARC139","ARC038","ARC115"
        },
    },
    -- box #16
    [16] = {
        -- pack #1 in box #16
        [1] = {
            "ARC210","ARC206","ARC187","ARC187","ARC164","ARC056","ARC026","ARC153","ARC034","ARC063","ARC028","ARC132","ARC111","ARC137","ARC101","ARC003","ARC001"
        },
        -- pack #2 in box #16
        [2] = {
            "ARC211","ARC216","ARC196","ARC210","ARC088","ARC174","ARC065","ARC154","ARC021","ARC073","ARC031","ARC070","ARC094","ARC143","ARC099","ARC039","ARC001"
        },
        -- pack #3 in box #16
        [3] = {
            "ARC198","ARC217","ARC198","ARC193","ARC128","ARC088","ARC094","ARC117","ARC067","ARC035","ARC066","ARC099","ARC137","ARC106","ARC136","ARC114","ARC003"
        },
        -- pack #4 in box #16
        [4] = {
            "ARC181","ARC202","ARC180","ARC191","ARC048","ARC008","ARC150","ARC155","ARC030","ARC072","ARC022","ARC074","ARC111","ARC140","ARC097","ARC218"
        },
        -- pack #5 in box #16
        [5] = {
            "ARC189","ARC184","ARC212","ARC186","ARC090","ARC131","ARC193","ARC157","ARC068","ARC036","ARC067","ARC105","ARC146","ARC111","ARC141","ARC114","ARC002"
        },
        -- pack #6 in box #16
        [6] = {
            "ARC209","ARC185","ARC205","ARC206","ARC173","ARC059","ARC174","ARC079","ARC021","ARC061","ARC034","ARC062","ARC096","ARC137","ARC095","ARC002","ARC038"
        },
        -- pack #7 in box #16
        [7] = {
            "ARC181","ARC179","ARC208","ARC184","ARC012","ARC169","ARC087","ARC156","ARC023","ARC062","ARC033","ARC071","ARC106","ARC144","ARC102","ARC112","ARC001"
        },
        -- pack #8 in box #16
        [8] = {
            "ARC206","ARC184","ARC217","ARC181","ARC127","ARC018","ARC185","ARC079","ARC064","ARC020","ARC065","ARC030","ARC139","ARC102","ARC148","ARC003","ARC075"
        },
        -- pack #9 in box #16
        [9] = {
            "ARC211","ARC195","ARC191","ARC210","ARC015","ARC172","ARC061","ARC151","ARC061","ARC027","ARC074","ARC105","ARC143","ARC104","ARC143","ARC112","ARC076"
        },
        -- pack #10 in box #16
        [10] = {
            "ARC180","ARC210","ARC176","ARC207","ARC164","ARC013","ARC073","ARC158","ARC065","ARC024","ARC063","ARC026","ARC139","ARC094","ARC144","ARC114","ARC040"
        },
        -- pack #11 in box #16
        [11] = {
            "ARC213","ARC199","ARC194","ARC213","ARC015","ARC051","ARC144","ARC079","ARC061","ARC020","ARC061","ARC108","ARC140","ARC106","ARC137","ARC076","ARC039"
        },
        -- pack #12 in box #16
        [12] = {
            "ARC205","ARC176","ARC188","ARC213","ARC126","ARC018","ARC168","ARC117","ARC021","ARC063","ARC032","ARC142","ARC095","ARC141","ARC108","ARC076","ARC113"
        },
        -- pack #13 in box #16
        [13] = {
            "ARC208","ARC193","ARC215","ARC205","ARC087","ARC059","ARC073","ARC154","ARC074","ARC025","ARC069","ARC021","ARC138","ARC096","ARC140","ARC076","ARC040"
        },
        -- pack #14 in box #16
        [14] = {
            "ARC207","ARC185","ARC213","ARC208","ARC164","ARC053","ARC149","ARC042","ARC030","ARC070","ARC027","ARC135","ARC104","ARC132","ARC111","ARC114","ARC002"
        },
        -- pack #15 in box #16
        [15] = {
            "ARC214","ARC192","ARC217","ARC217","ARC019","ARC171","ARC216","ARC156","ARC070","ARC026","ARC070","ARC030","ARC138","ARC099","ARC148","ARC001","ARC077"
        },
        -- pack #16 in box #16
        [16] = {
            "ARC181","ARC197","ARC182","ARC192","ARC087","ARC045","ARC016","ARC155","ARC023","ARC071","ARC027","ARC142","ARC096","ARC144","ARC106","ARC113","ARC040"
        },
        -- pack #17 in box #16
        [17] = {
            "ARC176","ARC176","ARC185","ARC190","ARC049","ARC120","ARC021","ARC005","ARC032","ARC070","ARC036","ARC142","ARC110","ARC148","ARC099","ARC038","ARC113"
        },
        -- pack #18 in box #16
        [18] = {
            "ARC202","ARC193","ARC187","ARC199","ARC170","ARC093","ARC058","ARC117","ARC034","ARC066","ARC030","ARC149","ARC104","ARC135","ARC103","ARC075","ARC038"
        },
        -- pack #19 in box #16
        [19] = {
            "ARC192","ARC192","ARC206","ARC204","ARC056","ARC087","ARC217","ARC005","ARC069","ARC033","ARC073","ARC033","ARC141","ARC108","ARC145","ARC218"
        },
        -- pack #20 in box #16
        [20] = {
            "ARC176","ARC179","ARC207","ARC197","ARC049","ARC124","ARC048","ARC153","ARC063","ARC023","ARC068","ARC110","ARC146","ARC095","ARC133","ARC076","ARC075"
        },
        -- pack #21 in box #16
        [21] = {
            "ARC202","ARC195","ARC195","ARC177","ARC167","ARC091","ARC130","ARC156","ARC023","ARC062","ARC027","ARC066","ARC097","ARC132","ARC108","ARC002","ARC040"
        },
        -- pack #22 in box #16
        [22] = {
            "ARC185","ARC214","ARC209","ARC178","ARC169","ARC122","ARC034","ARC156","ARC060","ARC026","ARC068","ARC105","ARC142","ARC096","ARC143","ARC038","ARC002"
        },
        -- pack #23 in box #16
        [23] = {
            "ARC196","ARC215","ARC177","ARC198","ARC125","ARC173","ARC069","ARC154","ARC036","ARC063","ARC037","ARC071","ARC110","ARC149","ARC095","ARC001","ARC038"
        },
        -- pack #24 in box #16
        [24] = {
            "ARC215","ARC209","ARC206","ARC214","ARC017","ARC174","ARC147","ARC152","ARC064","ARC030","ARC073","ARC020","ARC133","ARC108","ARC144","ARC001","ARC115"
        },
    },
    -- box #17
    [17] = {
        -- pack #1 in box #17
        [1] = {
            "ARC194","ARC201","ARC205","ARC216","ARC170","ARC169","ARC071","ARC151","ARC023","ARC060","ARC025","ARC063","ARC104","ARC133","ARC106","ARC115","ARC002"
        },
        -- pack #2 in box #17
        [2] = {
            "ARC181","ARC191","ARC195","ARC183","ARC123","ARC161","ARC117","ARC005","ARC072","ARC020","ARC069","ARC028","ARC132","ARC097","ARC137","ARC038","ARC076"
        },
        -- pack #3 in box #17
        [3] = {
            "ARC190","ARC196","ARC204","ARC179","ARC123","ARC088","ARC184","ARC156","ARC033","ARC066","ARC035","ARC149","ARC094","ARC149","ARC109","ARC113","ARC003"
        },
        -- pack #4 in box #17
        [4] = {
            "ARC203","ARC203","ARC184","ARC206","ARC051","ARC059","ARC064","ARC155","ARC036","ARC068","ARC032","ARC144","ARC095","ARC148","ARC099","ARC113","ARC040"
        },
        -- pack #5 in box #17
        [5] = {
            "ARC213","ARC190","ARC213","ARC199","ARC052","ARC171","ARC107","ARC154","ARC062","ARC030","ARC067","ARC105","ARC144","ARC100","ARC132","ARC001","ARC076"
        },
        -- pack #6 in box #17
        [6] = {
            "ARC208","ARC207","ARC206","ARC215","ARC089","ARC093","ARC015","ARC151","ARC026","ARC067","ARC026","ARC147","ARC098","ARC149","ARC098","ARC218"
        },
        -- pack #7 in box #17
        [7] = {
            "ARC190","ARC201","ARC199","ARC184","ARC049","ARC048","ARC019","ARC042","ARC030","ARC062","ARC027","ARC133","ARC109","ARC139","ARC107","ARC114","ARC113"
        },
        -- pack #8 in box #17
        [8] = {
            "ARC198","ARC207","ARC194","ARC188","ARC127","ARC089","ARC202","ARC079","ARC033","ARC062","ARC033","ARC063","ARC100","ARC149","ARC101","ARC218"
        },
        -- pack #9 in box #17
        [9] = {
            "ARC187","ARC185","ARC179","ARC217","ARC172","ARC053","ARC023","ARC153","ARC063","ARC031","ARC068","ARC099","ARC143","ARC094","ARC147","ARC038","ARC112"
        },
        -- pack #10 in box #17
        [10] = {
            "ARC177","ARC186","ARC184","ARC177","ARC016","ARC043","ARC141","ARC117","ARC062","ARC021","ARC063","ARC095","ARC135","ARC110","ARC135","ARC075","ARC001"
        },
        -- pack #11 in box #17
        [11] = {
            "ARC185","ARC179","ARC217","ARC205","ARC019","ARC015","ARC215","ARC155","ARC027","ARC069","ARC031","ARC146","ARC098","ARC147","ARC095","ARC003","ARC113"
        },
        -- pack #12 in box #17
        [12] = {
            "ARC184","ARC212","ARC199","ARC207","ARC058","ARC081","ARC216","ARC153","ARC064","ARC025","ARC064","ARC099","ARC140","ARC110","ARC145","ARC114","ARC038"
        },
        -- pack #13 in box #17
        [13] = {
            "ARC217","ARC194","ARC216","ARC176","ARC050","ARC048","ARC139","ARC079","ARC029","ARC072","ARC026","ARC063","ARC105","ARC142","ARC109","ARC112","ARC115"
        },
        -- pack #14 in box #17
        [14] = {
            "ARC215","ARC206","ARC199","ARC202","ARC048","ARC043","ARC089","ARC117","ARC070","ARC035","ARC074","ARC110","ARC148","ARC097","ARC149","ARC076","ARC114"
        },
        -- pack #15 in box #17
        [15] = {
            "ARC214","ARC183","ARC210","ARC180","ARC091","ARC173","ARC062","ARC155","ARC036","ARC070","ARC035","ARC074","ARC111","ARC138","ARC107","ARC115","ARC003"
        },
        -- pack #16 in box #17
        [16] = {
            "ARC194","ARC196","ARC205","ARC205","ARC018","ARC130","ARC106","ARC151","ARC029","ARC060","ARC037","ARC148","ARC105","ARC148","ARC095","ARC001","ARC076"
        },
        -- pack #17 in box #17
        [17] = {
            "ARC177","ARC182","ARC192","ARC206","ARC128","ARC016","ARC105","ARC042","ARC074","ARC037","ARC074","ARC035","ARC134","ARC104","ARC149","ARC112","ARC002"
        },
        -- pack #18 in box #17
        [18] = {
            "ARC184","ARC216","ARC197","ARC182","ARC172","ARC016","ARC143","ARC153","ARC073","ARC032","ARC067","ARC037","ARC147","ARC107","ARC137","ARC114","ARC076"
        },
        -- pack #19 in box #17
        [19] = {
            "ARC205","ARC184","ARC179","ARC215","ARC085","ARC011","ARC185","ARC157","ARC062","ARC020","ARC068","ARC031","ARC148","ARC101","ARC134","ARC218"
        },
        -- pack #20 in box #17
        [20] = {
            "ARC209","ARC189","ARC186","ARC177","ARC085","ARC087","ARC194","ARC155","ARC032","ARC066","ARC035","ARC069","ARC105","ARC149","ARC098","ARC001","ARC002"
        },
        -- pack #21 in box #17
        [21] = {
            "ARC217","ARC206","ARC211","ARC190","ARC054","ARC088","ARC211","ARC155","ARC073","ARC021","ARC067","ARC024","ARC134","ARC104","ARC134","ARC038","ARC115"
        },
        -- pack #22 in box #17
        [22] = {
            "ARC217","ARC195","ARC176","ARC179","ARC016","ARC121","ARC037","ARC152","ARC021","ARC074","ARC027","ARC060","ARC111","ARC139","ARC105","ARC001","ARC112"
        },
        -- pack #23 in box #17
        [23] = {
            "ARC183","ARC211","ARC197","ARC210","ARC086","ARC080","ARC094","ARC156","ARC066","ARC032","ARC068","ARC096","ARC145","ARC111","ARC142","ARC114","ARC038"
        },
        -- pack #24 in box #17
        [24] = {
            "ARC214","ARC200","ARC191","ARC211","ARC175","ARC050","ARC139","ARC042","ARC067","ARC020","ARC070","ARC024","ARC148","ARC098","ARC141","ARC075","ARC114"
        },
    },
    -- box #18
    [18] = {
        -- pack #1 in box #18
        [1] = {
            "ARC191","ARC209","ARC204","ARC195","ARC169","ARC128","ARC111","ARC042","ARC063","ARC022","ARC063","ARC026","ARC144","ARC105","ARC144","ARC038","ARC076"
        },
        -- pack #2 in box #18
        [2] = {
            "ARC176","ARC214","ARC180","ARC193","ARC049","ARC019","ARC097","ARC151","ARC032","ARC072","ARC026","ARC138","ARC105","ARC134","ARC111","ARC115","ARC038"
        },
        -- pack #3 in box #18
        [3] = {
            "ARC177","ARC216","ARC184","ARC178","ARC018","ARC089","ARC048","ARC005","ARC070","ARC027","ARC065","ARC108","ARC136","ARC110","ARC132","ARC077","ARC038"
        },
        -- pack #4 in box #18
        [4] = {
            "ARC207","ARC209","ARC214","ARC217","ARC059","ARC053","ARC025","ARC005","ARC031","ARC071","ARC032","ARC074","ARC094","ARC133","ARC101","ARC077","ARC040"
        },
        -- pack #5 in box #18
        [5] = {
            "ARC185","ARC199","ARC204","ARC181","ARC090","ARC019","ARC004","ARC079","ARC074","ARC036","ARC071","ARC098","ARC144","ARC096","ARC139","ARC114","ARC077"
        },
        -- pack #6 in box #18
        [6] = {
            "ARC199","ARC179","ARC216","ARC191","ARC019","ARC119","ARC162","ARC156","ARC036","ARC065","ARC031","ARC063","ARC105","ARC146","ARC109","ARC113","ARC002"
        },
        -- pack #7 in box #18
        [7] = {
            "ARC187","ARC205","ARC183","ARC212","ARC093","ARC054","ARC091","ARC158","ARC071","ARC034","ARC064","ARC034","ARC138","ARC100","ARC135","ARC040","ARC001"
        },
        -- pack #8 in box #18
        [8] = {
            "ARC198","ARC206","ARC210","ARC190","ARC052","ARC012","ARC185","ARC079","ARC060","ARC030","ARC070","ARC036","ARC149","ARC099","ARC146","ARC039","ARC002"
        },
        -- pack #9 in box #18
        [9] = {
            "ARC194","ARC183","ARC183","ARC177","ARC014","ARC130","ARC107","ARC005","ARC065","ARC033","ARC064","ARC037","ARC133","ARC098","ARC147","ARC115","ARC003"
        },
        -- pack #10 in box #18
        [10] = {
            "ARC202","ARC195","ARC186","ARC192","ARC053","ARC013","ARC127","ARC153","ARC024","ARC064","ARC033","ARC065","ARC098","ARC149","ARC106","ARC038","ARC003"
        },
        -- pack #11 in box #18
        [11] = {
            "ARC178","ARC179","ARC209","ARC207","ARC054","ARC131","ARC144","ARC154","ARC035","ARC074","ARC031","ARC064","ARC097","ARC135","ARC107","ARC218"
        },
        -- pack #12 in box #18
        [12] = {
            "ARC216","ARC183","ARC204","ARC186","ARC173","ARC085","ARC102","ARC158","ARC061","ARC034","ARC060","ARC096","ARC137","ARC104","ARC137","ARC114","ARC003"
        },
        -- pack #13 in box #18
        [13] = {
            "ARC217","ARC193","ARC201","ARC205","ARC172","ARC008","ARC199","ARC153","ARC070","ARC020","ARC068","ARC026","ARC145","ARC098","ARC136","ARC038","ARC077"
        },
        -- pack #14 in box #18
        [14] = {
            "ARC207","ARC202","ARC186","ARC202","ARC173","ARC082","ARC090","ARC153","ARC037","ARC067","ARC027","ARC132","ARC108","ARC145","ARC108","ARC040","ARC076"
        },
        -- pack #15 in box #18
        [15] = {
            "ARC190","ARC200","ARC186","ARC178","ARC011","ARC165","ARC194","ARC152","ARC071","ARC026","ARC068","ARC097","ARC134","ARC101","ARC145","ARC113","ARC001"
        },
        -- pack #16 in box #18
        [16] = {
            "ARC214","ARC177","ARC185","ARC186","ARC123","ARC055","ARC188","ARC153","ARC026","ARC073","ARC031","ARC139","ARC101","ARC140","ARC103","ARC076","ARC001"
        },
        -- pack #17 in box #18
        [17] = {
            "ARC182","ARC183","ARC202","ARC216","ARC130","ARC056","ARC074","ARC117","ARC037","ARC074","ARC020","ARC060","ARC098","ARC138","ARC108","ARC001","ARC114"
        },
        -- pack #18 in box #18
        [18] = {
            "ARC190","ARC209","ARC182","ARC177","ARC051","ARC169","ARC191","ARC158","ARC061","ARC020","ARC069","ARC102","ARC135","ARC094","ARC143","ARC075","ARC039"
        },
        -- pack #19 in box #18
        [19] = {
            "ARC188","ARC180","ARC176","ARC212","ARC051","ARC056","ARC103","ARC158","ARC031","ARC069","ARC025","ARC070","ARC101","ARC133","ARC095","ARC076","ARC077"
        },
        -- pack #20 in box #18
        [20] = {
            "ARC181","ARC201","ARC181","ARC184","ARC091","ARC164","ARC132","ARC154","ARC064","ARC037","ARC066","ARC095","ARC147","ARC096","ARC142","ARC001","ARC003"
        },
        -- pack #21 in box #18
        [21] = {
            "ARC186","ARC210","ARC203","ARC202","ARC012","ARC131","ARC129","ARC151","ARC035","ARC072","ARC032","ARC134","ARC095","ARC136","ARC101","ARC039","ARC112"
        },
        -- pack #22 in box #18
        [22] = {
            "ARC188","ARC201","ARC216","ARC189","ARC174","ARC014","ARC215","ARC156","ARC074","ARC020","ARC066","ARC035","ARC139","ARC098","ARC136","ARC001","ARC003"
        },
        -- pack #23 in box #18
        [23] = {
            "ARC206","ARC217","ARC209","ARC192","ARC090","ARC055","ARC102","ARC042","ARC032","ARC072","ARC027","ARC141","ARC102","ARC148","ARC096","ARC076","ARC112"
        },
        -- pack #24 in box #18
        [24] = {
            "ARC213","ARC183","ARC211","ARC178","ARC168","ARC055","ARC152","ARC005","ARC022","ARC073","ARC037","ARC142","ARC096","ARC133","ARC096","ARC077","ARC039"
        },
    },
    -- box #19
    [19] = {
        -- pack #1 in box #19
        [1] = {
            "ARC215","ARC210","ARC194","ARC201","ARC131","ARC055","ARC194","ARC157","ARC037","ARC066","ARC031","ARC071","ARC104","ARC143","ARC111","ARC002","ARC077"
        },
        -- pack #2 in box #19
        [2] = {
            "ARC206","ARC198","ARC211","ARC192","ARC051","ARC165","ARC148","ARC158","ARC024","ARC068","ARC032","ARC066","ARC095","ARC141","ARC104","ARC218"
        },
        -- pack #3 in box #19
        [3] = {
            "ARC193","ARC208","ARC209","ARC209","ARC054","ARC119","ARC010","ARC153","ARC068","ARC027","ARC071","ARC021","ARC145","ARC103","ARC138","ARC002","ARC115"
        },
        -- pack #4 in box #19
        [4] = {
            "ARC187","ARC211","ARC199","ARC192","ARC088","ARC051","ARC068","ARC152","ARC071","ARC027","ARC062","ARC107","ARC134","ARC103","ARC148","ARC039","ARC001"
        },
        -- pack #5 in box #19
        [5] = {
            "ARC212","ARC183","ARC199","ARC206","ARC091","ARC013","ARC138","ARC154","ARC030","ARC074","ARC026","ARC063","ARC103","ARC145","ARC096","ARC075","ARC076"
        },
        -- pack #6 in box #19
        [6] = {
            "ARC199","ARC207","ARC182","ARC186","ARC011","ARC009","ARC072","ARC151","ARC023","ARC071","ARC035","ARC139","ARC103","ARC141","ARC096","ARC038","ARC115"
        },
        -- pack #7 in box #19
        [7] = {
            "ARC216","ARC192","ARC194","ARC206","ARC051","ARC167","ARC189","ARC158","ARC067","ARC037","ARC061","ARC106","ARC138","ARC110","ARC132","ARC040","ARC002"
        },
        -- pack #8 in box #19
        [8] = {
            "ARC180","ARC202","ARC198","ARC213","ARC092","ARC125","ARC073","ARC151","ARC071","ARC028","ARC071","ARC105","ARC148","ARC103","ARC144","ARC002","ARC039"
        },
        -- pack #9 in box #19
        [9] = {
            "ARC213","ARC200","ARC178","ARC177","ARC172","ARC173","ARC186","ARC157","ARC067","ARC032","ARC065","ARC036","ARC147","ARC098","ARC143","ARC112","ARC114"
        },
        -- pack #10 in box #19
        [10] = {
            "ARC202","ARC209","ARC187","ARC213","ARC013","ARC012","ARC036","ARC153","ARC070","ARC028","ARC065","ARC094","ARC134","ARC095","ARC149","ARC114","ARC077"
        },
        -- pack #11 in box #19
        [11] = {
            "ARC208","ARC202","ARC178","ARC181","ARC016","ARC124","ARC215","ARC154","ARC061","ARC030","ARC071","ARC102","ARC145","ARC109","ARC139","ARC001","ARC003"
        },
        -- pack #12 in box #19
        [12] = {
            "ARC188","ARC190","ARC192","ARC177","ARC017","ARC046","ARC178","ARC153","ARC024","ARC064","ARC030","ARC074","ARC094","ARC149","ARC094","ARC077","ARC001"
        },
        -- pack #13 in box #19
        [13] = {
            "ARC210","ARC200","ARC195","ARC192","ARC053","ARC048","ARC191","ARC152","ARC033","ARC068","ARC024","ARC146","ARC096","ARC149","ARC094","ARC113","ARC075"
        },
        -- pack #14 in box #19
        [14] = {
            "ARC216","ARC204","ARC184","ARC200","ARC088","ARC174","ARC106","ARC005","ARC064","ARC025","ARC070","ARC028","ARC144","ARC101","ARC137","ARC218"
        },
        -- pack #15 in box #19
        [15] = {
            "ARC177","ARC178","ARC201","ARC215","ARC171","ARC056","ARC173","ARC158","ARC034","ARC067","ARC033","ARC073","ARC110","ARC141","ARC107","ARC112","ARC075"
        },
        -- pack #16 in box #19
        [16] = {
            "ARC185","ARC182","ARC177","ARC215","ARC124","ARC164","ARC087","ARC155","ARC066","ARC026","ARC073","ARC030","ARC139","ARC111","ARC142","ARC113","ARC075"
        },
        -- pack #17 in box #19
        [17] = {
            "ARC214","ARC215","ARC196","ARC183","ARC171","ARC175","ARC177","ARC005","ARC031","ARC060","ARC024","ARC132","ARC109","ARC142","ARC101","ARC077","ARC039"
        },
        -- pack #18 in box #19
        [18] = {
            "ARC200","ARC187","ARC204","ARC197","ARC123","ARC128","ARC147","ARC156","ARC065","ARC025","ARC068","ARC102","ARC146","ARC110","ARC141","ARC218"
        },
        -- pack #19 in box #19
        [19] = {
            "ARC191","ARC205","ARC178","ARC185","ARC052","ARC121","ARC158","ARC156","ARC071","ARC027","ARC068","ARC026","ARC132","ARC100","ARC147","ARC077","ARC076"
        },
        -- pack #20 in box #19
        [20] = {
            "ARC195","ARC191","ARC216","ARC208","ARC056","ARC015","ARC054","ARC156","ARC025","ARC072","ARC026","ARC061","ARC106","ARC135","ARC105","ARC040","ARC077"
        },
        -- pack #21 in box #19
        [21] = {
            "ARC189","ARC182","ARC212","ARC194","ARC174","ARC162","ARC035","ARC079","ARC026","ARC068","ARC037","ARC135","ARC111","ARC136","ARC108","ARC218"
        },
        -- pack #22 in box #19
        [22] = {
            "ARC203","ARC201","ARC178","ARC198","ARC165","ARC125","ARC068","ARC151","ARC029","ARC063","ARC037","ARC136","ARC099","ARC145","ARC105","ARC038","ARC077"
        },
        -- pack #23 in box #19
        [23] = {
            "ARC188","ARC192","ARC188","ARC212","ARC089","ARC164","ARC122","ARC153","ARC034","ARC073","ARC033","ARC141","ARC109","ARC140","ARC100","ARC113","ARC114"
        },
        -- pack #24 in box #19
        [24] = {
            "ARC184","ARC180","ARC214","ARC194","ARC174","ARC019","ARC067","ARC156","ARC074","ARC028","ARC074","ARC024","ARC146","ARC095","ARC132","ARC112","ARC077"
        },
    },
    -- box #20
    [20] = {
        -- pack #1 in box #20
        [1] = {
            "ARC192","ARC177","ARC207","ARC205","ARC123","ARC052","ARC142","ARC151","ARC070","ARC021","ARC073","ARC100","ARC141","ARC108","ARC137","ARC038","ARC003"
        },
        -- pack #2 in box #20
        [2] = {
            "ARC212","ARC189","ARC217","ARC194","ARC166","ARC018","ARC067","ARC152","ARC037","ARC074","ARC033","ARC132","ARC111","ARC149","ARC095","ARC039","ARC077"
        },
        -- pack #3 in box #20
        [3] = {
            "ARC212","ARC215","ARC184","ARC182","ARC165","ARC174","ARC071","ARC158","ARC073","ARC031","ARC065","ARC099","ARC142","ARC111","ARC132","ARC076","ARC075"
        },
        -- pack #4 in box #20
        [4] = {
            "ARC206","ARC198","ARC180","ARC182","ARC131","ARC083","ARC214","ARC155","ARC037","ARC066","ARC024","ARC062","ARC098","ARC135","ARC107","ARC075","ARC115"
        },
        -- pack #5 in box #20
        [5] = {
            "ARC181","ARC210","ARC203","ARC194","ARC055","ARC163","ARC190","ARC154","ARC073","ARC034","ARC072","ARC025","ARC148","ARC094","ARC138","ARC115","ARC077"
        },
        -- pack #6 in box #20
        [6] = {
            "ARC187","ARC189","ARC205","ARC212","ARC167","ARC127","ARC019","ARC158","ARC032","ARC065","ARC036","ARC064","ARC103","ARC134","ARC099","ARC076","ARC040"
        },
        -- pack #7 in box #20
        [7] = {
            "ARC183","ARC184","ARC180","ARC191","ARC054","ARC052","ARC130","ARC005","ARC029","ARC069","ARC026","ARC063","ARC105","ARC132","ARC107","ARC001","ARC002"
        },
        -- pack #8 in box #20
        [8] = {
            "ARC181","ARC193","ARC182","ARC180","ARC054","ARC090","ARC033","ARC151","ARC031","ARC072","ARC022","ARC136","ARC102","ARC133","ARC096","ARC040","ARC113"
        },
        -- pack #9 in box #20
        [9] = {
            "ARC193","ARC199","ARC182","ARC187","ARC056","ARC129","ARC201","ARC156","ARC030","ARC068","ARC033","ARC067","ARC110","ARC144","ARC104","ARC113","ARC075"
        },
        -- pack #10 in box #20
        [10] = {
            "ARC177","ARC190","ARC193","ARC197","ARC050","ARC058","ARC110","ARC152","ARC027","ARC063","ARC034","ARC142","ARC098","ARC149","ARC109","ARC077","ARC115"
        },
        -- pack #11 in box #20
        [11] = {
            "ARC191","ARC207","ARC187","ARC185","ARC124","ARC127","ARC061","ARC152","ARC060","ARC028","ARC064","ARC102","ARC139","ARC108","ARC149","ARC112","ARC040"
        },
        -- pack #12 in box #20
        [12] = {
            "ARC191","ARC216","ARC210","ARC190","ARC013","ARC087","ARC129","ARC151","ARC032","ARC067","ARC028","ARC146","ARC095","ARC144","ARC095","ARC218"
        },
        -- pack #13 in box #20
        [13] = {
            "ARC204","ARC201","ARC209","ARC195","ARC057","ARC174","ARC026","ARC157","ARC022","ARC061","ARC023","ARC133","ARC107","ARC140","ARC108","ARC112","ARC114"
        },
        -- pack #14 in box #20
        [14] = {
            "ARC217","ARC184","ARC213","ARC201","ARC016","ARC084","ARC153","ARC079","ARC072","ARC024","ARC064","ARC027","ARC148","ARC108","ARC147","ARC076","ARC112"
        },
        -- pack #15 in box #20
        [15] = {
            "ARC205","ARC208","ARC216","ARC180","ARC049","ARC126","ARC060","ARC117","ARC067","ARC031","ARC066","ARC035","ARC138","ARC102","ARC144","ARC077","ARC039"
        },
        -- pack #16 in box #20
        [16] = {
            "ARC197","ARC178","ARC194","ARC188","ARC174","ARC128","ARC168","ARC156","ARC073","ARC029","ARC069","ARC033","ARC146","ARC103","ARC140","ARC003","ARC040"
        },
        -- pack #17 in box #20
        [17] = {
            "ARC203","ARC182","ARC197","ARC201","ARC086","ARC045","ARC209","ARC158","ARC065","ARC034","ARC064","ARC025","ARC141","ARC094","ARC149","ARC039","ARC040"
        },
        -- pack #18 in box #20
        [18] = {
            "ARC191","ARC202","ARC204","ARC206","ARC092","ARC057","ARC052","ARC151","ARC072","ARC035","ARC064","ARC100","ARC142","ARC109","ARC138","ARC115","ARC040"
        },
        -- pack #19 in box #20
        [19] = {
            "ARC217","ARC181","ARC203","ARC215","ARC014","ARC045","ARC196","ARC154","ARC025","ARC070","ARC032","ARC070","ARC096","ARC141","ARC102","ARC003","ARC113"
        },
        -- pack #20 in box #20
        [20] = {
            "ARC199","ARC182","ARC207","ARC204","ARC165","ARC018","ARC139","ARC079","ARC025","ARC074","ARC025","ARC136","ARC109","ARC133","ARC102","ARC002","ARC040"
        },
        -- pack #21 in box #20
        [21] = {
            "ARC203","ARC212","ARC207","ARC207","ARC124","ARC083","ARC210","ARC152","ARC072","ARC025","ARC073","ARC103","ARC146","ARC106","ARC149","ARC218"
        },
        -- pack #22 in box #20
        [22] = {
            "ARC206","ARC186","ARC213","ARC208","ARC173","ARC011","ARC031","ARC151","ARC023","ARC074","ARC023","ARC064","ARC097","ARC147","ARC111","ARC076","ARC077"
        },
        -- pack #23 in box #20
        [23] = {
            "ARC212","ARC209","ARC209","ARC185","ARC013","ARC088","ARC177","ARC079","ARC062","ARC028","ARC062","ARC026","ARC149","ARC103","ARC134","ARC002","ARC112"
        },
        -- pack #24 in box #20
        [24] = {
            "ARC211","ARC191","ARC213","ARC187","ARC053","ARC058","ARC207","ARC151","ARC071","ARC026","ARC064","ARC100","ARC143","ARC106","ARC140","ARC002","ARC115"
        },
    },
    -- box #21
    [21] = {
        -- pack #1 in box #21
        [1] = {
            "ARC217","ARC198","ARC215","ARC215","ARC091","ARC160","ARC073","ARC005","ARC074","ARC029","ARC071","ARC024","ARC139","ARC099","ARC132","ARC075","ARC003"
        },
        -- pack #2 in box #21
        [2] = {
            "ARC188","ARC190","ARC182","ARC189","ARC088","ARC050","ARC199","ARC117","ARC062","ARC026","ARC070","ARC035","ARC135","ARC096","ARC147","ARC077","ARC112"
        },
        -- pack #3 in box #21
        [3] = {
            "ARC202","ARC194","ARC209","ARC211","ARC126","ARC047","ARC060","ARC151","ARC033","ARC068","ARC022","ARC069","ARC105","ARC142","ARC094","ARC003","ARC076"
        },
        -- pack #4 in box #21
        [4] = {
            "ARC208","ARC194","ARC196","ARC199","ARC126","ARC012","ARC207","ARC154","ARC060","ARC025","ARC065","ARC034","ARC147","ARC094","ARC142","ARC077","ARC003"
        },
        -- pack #5 in box #21
        [5] = {
            "ARC177","ARC195","ARC200","ARC194","ARC169","ARC174","ARC145","ARC153","ARC037","ARC067","ARC029","ARC066","ARC106","ARC133","ARC102","ARC075","ARC115"
        },
        -- pack #6 in box #21
        [6] = {
            "ARC191","ARC212","ARC186","ARC195","ARC017","ARC167","ARC148","ARC153","ARC037","ARC062","ARC031","ARC072","ARC109","ARC133","ARC101","ARC114","ARC003"
        },
        -- pack #7 in box #21
        [7] = {
            "ARC203","ARC215","ARC197","ARC195","ARC049","ARC015","ARC054","ARC005","ARC061","ARC027","ARC072","ARC022","ARC142","ARC109","ARC143","ARC112","ARC077"
        },
        -- pack #8 in box #21
        [8] = {
            "ARC192","ARC214","ARC211","ARC203","ARC016","ARC050","ARC063","ARC154","ARC062","ARC033","ARC065","ARC022","ARC146","ARC108","ARC135","ARC114","ARC040"
        },
        -- pack #9 in box #21
        [9] = {
            "ARC217","ARC195","ARC215","ARC206","ARC018","ARC084","ARC142","ARC042","ARC073","ARC025","ARC073","ARC101","ARC138","ARC108","ARC149","ARC077","ARC040"
        },
        -- pack #10 in box #21
        [10] = {
            "ARC179","ARC213","ARC216","ARC207","ARC093","ARC013","ARC028","ARC117","ARC024","ARC065","ARC022","ARC145","ARC101","ARC134","ARC099","ARC039","ARC115"
        },
        -- pack #11 in box #21
        [11] = {
            "ARC183","ARC196","ARC202","ARC208","ARC085","ARC163","ARC070","ARC158","ARC064","ARC028","ARC060","ARC037","ARC149","ARC111","ARC143","ARC115","ARC075"
        },
        -- pack #12 in box #21
        [12] = {
            "ARC201","ARC187","ARC212","ARC187","ARC049","ARC006","ARC036","ARC154","ARC061","ARC024","ARC060","ARC108","ARC142","ARC100","ARC134","ARC002","ARC038"
        },
        -- pack #13 in box #21
        [13] = {
            "ARC195","ARC197","ARC203","ARC176","ARC012","ARC045","ARC024","ARC079","ARC023","ARC061","ARC033","ARC132","ARC095","ARC140","ARC110","ARC076","ARC075"
        },
        -- pack #14 in box #21
        [14] = {
            "ARC184","ARC210","ARC190","ARC180","ARC173","ARC057","ARC141","ARC158","ARC072","ARC033","ARC069","ARC104","ARC145","ARC096","ARC138","ARC038","ARC002"
        },
        -- pack #15 in box #21
        [15] = {
            "ARC176","ARC178","ARC206","ARC205","ARC014","ARC006","ARC155","ARC153","ARC065","ARC026","ARC064","ARC107","ARC139","ARC108","ARC148","ARC039","ARC003"
        },
        -- pack #16 in box #21
        [16] = {
            "ARC199","ARC213","ARC187","ARC210","ARC166","ARC165","ARC208","ARC042","ARC032","ARC073","ARC027","ARC137","ARC104","ARC136","ARC102","ARC076","ARC003"
        },
        -- pack #17 in box #21
        [17] = {
            "ARC207","ARC197","ARC181","ARC187","ARC124","ARC007","ARC079","ARC079","ARC034","ARC068","ARC037","ARC064","ARC099","ARC135","ARC109","ARC114","ARC077"
        },
        -- pack #18 in box #21
        [18] = {
            "ARC209","ARC216","ARC181","ARC201","ARC049","ARC085","ARC101","ARC154","ARC037","ARC070","ARC037","ARC060","ARC107","ARC146","ARC111","ARC040","ARC114"
        },
        -- pack #19 in box #21
        [19] = {
            "ARC191","ARC207","ARC206","ARC203","ARC088","ARC127","ARC214","ARC154","ARC036","ARC070","ARC021","ARC135","ARC102","ARC147","ARC095","ARC113","ARC115"
        },
        -- pack #20 in box #21
        [20] = {
            "ARC208","ARC179","ARC187","ARC194","ARC169","ARC093","ARC027","ARC155","ARC032","ARC073","ARC037","ARC140","ARC096","ARC146","ARC107","ARC003","ARC040"
        },
        -- pack #21 in box #21
        [21] = {
            "ARC178","ARC211","ARC213","ARC200","ARC167","ARC131","ARC101","ARC153","ARC062","ARC025","ARC063","ARC105","ARC144","ARC102","ARC149","ARC218"
        },
        -- pack #22 in box #21
        [22] = {
            "ARC180","ARC197","ARC185","ARC185","ARC016","ARC093","ARC063","ARC158","ARC021","ARC074","ARC021","ARC070","ARC097","ARC143","ARC094","ARC038","ARC003"
        },
        -- pack #23 in box #21
        [23] = {
            "ARC183","ARC186","ARC188","ARC214","ARC164","ARC126","ARC034","ARC156","ARC022","ARC063","ARC036","ARC135","ARC100","ARC135","ARC102","ARC075","ARC114"
        },
        -- pack #24 in box #21
        [24] = {
            "ARC187","ARC185","ARC197","ARC198","ARC048","ARC123","ARC032","ARC117","ARC067","ARC035","ARC072","ARC094","ARC149","ARC094","ARC133","ARC076","ARC039"
        },
    },
    -- box #22
    [22] = {
        -- pack #1 in box #22
        [1] = {
            "ARC178","ARC195","ARC212","ARC177","ARC128","ARC127","ARC202","ARC158","ARC036","ARC062","ARC033","ARC132","ARC107","ARC147","ARC106","ARC113","ARC075"
        },
        -- pack #2 in box #22
        [2] = {
            "ARC183","ARC191","ARC176","ARC187","ARC018","ARC166","ARC188","ARC117","ARC063","ARC032","ARC069","ARC097","ARC134","ARC110","ARC149","ARC040","ARC075"
        },
        -- pack #3 in box #22
        [3] = {
            "ARC202","ARC188","ARC208","ARC201","ARC170","ARC058","ARC103","ARC156","ARC074","ARC032","ARC060","ARC037","ARC135","ARC106","ARC149","ARC075","ARC039"
        },
        -- pack #4 in box #22
        [4] = {
            "ARC187","ARC209","ARC212","ARC216","ARC049","ARC009","ARC172","ARC005","ARC060","ARC024","ARC069","ARC104","ARC135","ARC097","ARC146","ARC001","ARC113"
        },
        -- pack #5 in box #22
        [5] = {
            "ARC206","ARC193","ARC209","ARC195","ARC126","ARC089","ARC012","ARC157","ARC065","ARC023","ARC067","ARC107","ARC141","ARC111","ARC138","ARC002","ARC112"
        },
        -- pack #6 in box #22
        [6] = {
            "ARC210","ARC211","ARC181","ARC191","ARC087","ARC008","ARC033","ARC079","ARC071","ARC020","ARC060","ARC020","ARC141","ARC107","ARC140","ARC038","ARC114"
        },
        -- pack #7 in box #22
        [7] = {
            "ARC177","ARC188","ARC183","ARC200","ARC015","ARC123","ARC123","ARC117","ARC026","ARC072","ARC030","ARC139","ARC099","ARC146","ARC104","ARC075","ARC038"
        },
        -- pack #8 in box #22
        [8] = {
            "ARC213","ARC183","ARC205","ARC207","ARC085","ARC010","ARC104","ARC154","ARC064","ARC023","ARC061","ARC095","ARC140","ARC105","ARC138","ARC040","ARC115"
        },
        -- pack #9 in box #22
        [9] = {
            "ARC192","ARC191","ARC204","ARC212","ARC017","ARC084","ARC118","ARC117","ARC035","ARC073","ARC028","ARC074","ARC095","ARC144","ARC096","ARC112","ARC001"
        },
        -- pack #10 in box #22
        [10] = {
            "ARC208","ARC206","ARC199","ARC198","ARC055","ARC175","ARC074","ARC042","ARC023","ARC070","ARC024","ARC066","ARC101","ARC132","ARC105","ARC114","ARC040"
        },
        -- pack #11 in box #22
        [11] = {
            "ARC182","ARC206","ARC197","ARC207","ARC128","ARC089","ARC167","ARC156","ARC020","ARC071","ARC026","ARC134","ARC104","ARC135","ARC096","ARC076","ARC114"
        },
        -- pack #12 in box #22
        [12] = {
            "ARC185","ARC178","ARC209","ARC207","ARC015","ARC129","ARC138","ARC157","ARC072","ARC023","ARC060","ARC026","ARC136","ARC108","ARC147","ARC114","ARC001"
        },
        -- pack #13 in box #22
        [13] = {
            "ARC207","ARC194","ARC181","ARC187","ARC169","ARC162","ARC090","ARC151","ARC066","ARC020","ARC072","ARC108","ARC143","ARC097","ARC145","ARC077","ARC076"
        },
        -- pack #14 in box #22
        [14] = {
            "ARC215","ARC202","ARC209","ARC195","ARC092","ARC093","ARC208","ARC154","ARC025","ARC069","ARC030","ARC071","ARC104","ARC137","ARC100","ARC115","ARC077"
        },
        -- pack #15 in box #22
        [15] = {
            "ARC189","ARC215","ARC197","ARC199","ARC123","ARC167","ARC192","ARC117","ARC071","ARC035","ARC065","ARC024","ARC136","ARC101","ARC148","ARC076","ARC114"
        },
        -- pack #16 in box #22
        [16] = {
            "ARC187","ARC212","ARC215","ARC194","ARC057","ARC085","ARC136","ARC157","ARC034","ARC068","ARC021","ARC135","ARC111","ARC140","ARC101","ARC003","ARC112"
        },
        -- pack #17 in box #22
        [17] = {
            "ARC217","ARC208","ARC217","ARC203","ARC173","ARC173","ARC210","ARC155","ARC069","ARC032","ARC061","ARC097","ARC132","ARC109","ARC140","ARC113","ARC112"
        },
        -- pack #18 in box #22
        [18] = {
            "ARC190","ARC193","ARC212","ARC178","ARC059","ARC008","ARC181","ARC151","ARC036","ARC062","ARC035","ARC071","ARC103","ARC137","ARC110","ARC077","ARC038"
        },
        -- pack #19 in box #22
        [19] = {
            "ARC204","ARC209","ARC212","ARC199","ARC170","ARC122","ARC138","ARC152","ARC026","ARC073","ARC020","ARC067","ARC110","ARC145","ARC102","ARC040","ARC038"
        },
        -- pack #20 in box #22
        [20] = {
            "ARC183","ARC192","ARC197","ARC185","ARC056","ARC009","ARC071","ARC158","ARC069","ARC020","ARC070","ARC028","ARC139","ARC105","ARC134","ARC075","ARC002"
        },
        -- pack #21 in box #22
        [21] = {
            "ARC207","ARC195","ARC196","ARC204","ARC174","ARC159","ARC138","ARC155","ARC032","ARC064","ARC035","ARC072","ARC097","ARC149","ARC101","ARC040","ARC001"
        },
        -- pack #22 in box #22
        [22] = {
            "ARC179","ARC205","ARC186","ARC183","ARC093","ARC059","ARC089","ARC151","ARC060","ARC021","ARC060","ARC028","ARC143","ARC096","ARC141","ARC002","ARC115"
        },
        -- pack #23 in box #22
        [23] = {
            "ARC205","ARC202","ARC202","ARC188","ARC175","ARC009","ARC181","ARC156","ARC026","ARC060","ARC031","ARC132","ARC105","ARC138","ARC097","ARC003","ARC075"
        },
        -- pack #24 in box #22
        [24] = {
            "ARC212","ARC183","ARC179","ARC206","ARC123","ARC170","ARC131","ARC005","ARC027","ARC064","ARC029","ARC145","ARC104","ARC137","ARC108","ARC112","ARC113"
        },
    },
    -- box #23
    [23] = {
        -- pack #1 in box #23
        [1] = {
            "ARC179","ARC184","ARC192","ARC188","ARC052","ARC131","ARC195","ARC158","ARC060","ARC026","ARC071","ARC027","ARC145","ARC106","ARC139","ARC075","ARC114"
        },
        -- pack #2 in box #23
        [2] = {
            "ARC179","ARC195","ARC202","ARC184","ARC167","ARC081","ARC098","ARC157","ARC063","ARC028","ARC065","ARC020","ARC138","ARC100","ARC132","ARC039","ARC003"
        },
        -- pack #3 in box #23
        [3] = {
            "ARC215","ARC199","ARC176","ARC204","ARC013","ARC011","ARC197","ARC154","ARC021","ARC068","ARC020","ARC069","ARC110","ARC139","ARC097","ARC038","ARC113"
        },
        -- pack #4 in box #23
        [4] = {
            "ARC176","ARC207","ARC207","ARC213","ARC170","ARC120","ARC057","ARC158","ARC063","ARC022","ARC071","ARC021","ARC137","ARC105","ARC136","ARC218"
        },
        -- pack #5 in box #23
        [5] = {
            "ARC216","ARC176","ARC200","ARC196","ARC086","ARC120","ARC065","ARC158","ARC030","ARC065","ARC030","ARC144","ARC095","ARC136","ARC096","ARC038","ARC040"
        },
        -- pack #6 in box #23
        [6] = {
            "ARC200","ARC181","ARC200","ARC181","ARC129","ARC058","ARC137","ARC152","ARC063","ARC023","ARC064","ARC020","ARC133","ARC108","ARC141","ARC112","ARC076"
        },
        -- pack #7 in box #23
        [7] = {
            "ARC204","ARC210","ARC176","ARC206","ARC172","ARC045","ARC151","ARC154","ARC028","ARC061","ARC030","ARC136","ARC101","ARC140","ARC102","ARC040","ARC038"
        },
        -- pack #8 in box #23
        [8] = {
            "ARC206","ARC200","ARC211","ARC189","ARC092","ARC050","ARC108","ARC158","ARC070","ARC033","ARC072","ARC107","ARC138","ARC103","ARC134","ARC113","ARC077"
        },
        -- pack #9 in box #23
        [9] = {
            "ARC194","ARC215","ARC216","ARC195","ARC092","ARC123","ARC111","ARC157","ARC065","ARC037","ARC074","ARC033","ARC134","ARC110","ARC134","ARC115","ARC040"
        },
        -- pack #10 in box #23
        [10] = {
            "ARC189","ARC196","ARC190","ARC214","ARC012","ARC089","ARC212","ARC152","ARC033","ARC063","ARC029","ARC072","ARC109","ARC149","ARC111","ARC114","ARC002"
        },
        -- pack #11 in box #23
        [11] = {
            "ARC182","ARC178","ARC213","ARC176","ARC011","ARC126","ARC213","ARC152","ARC070","ARC033","ARC063","ARC100","ARC147","ARC104","ARC141","ARC075","ARC115"
        },
        -- pack #12 in box #23
        [12] = {
            "ARC199","ARC178","ARC214","ARC213","ARC131","ARC015","ARC138","ARC151","ARC035","ARC060","ARC035","ARC062","ARC098","ARC146","ARC100","ARC077","ARC075"
        },
        -- pack #13 in box #23
        [13] = {
            "ARC180","ARC217","ARC212","ARC210","ARC086","ARC131","ARC203","ARC158","ARC074","ARC033","ARC071","ARC096","ARC135","ARC097","ARC140","ARC113","ARC038"
        },
        -- pack #14 in box #23
        [14] = {
            "ARC209","ARC202","ARC177","ARC201","ARC014","ARC166","ARC135","ARC117","ARC064","ARC026","ARC065","ARC105","ARC137","ARC100","ARC145","ARC003","ARC039"
        },
        -- pack #15 in box #23
        [15] = {
            "ARC185","ARC191","ARC194","ARC182","ARC175","ARC054","ARC083","ARC158","ARC021","ARC066","ARC024","ARC062","ARC105","ARC145","ARC099","ARC039","ARC112"
        },
        -- pack #16 in box #23
        [16] = {
            "ARC179","ARC179","ARC182","ARC214","ARC052","ARC131","ARC204","ARC153","ARC034","ARC072","ARC027","ARC146","ARC109","ARC149","ARC110","ARC002","ARC003"
        },
        -- pack #17 in box #23
        [17] = {
            "ARC184","ARC192","ARC182","ARC209","ARC166","ARC054","ARC128","ARC151","ARC074","ARC024","ARC072","ARC033","ARC142","ARC111","ARC148","ARC114","ARC112"
        },
        -- pack #18 in box #23
        [18] = {
            "ARC217","ARC204","ARC196","ARC212","ARC087","ARC170","ARC067","ARC005","ARC024","ARC062","ARC030","ARC067","ARC105","ARC148","ARC108","ARC113","ARC076"
        },
        -- pack #19 in box #23
        [19] = {
            "ARC186","ARC203","ARC177","ARC184","ARC089","ARC014","ARC132","ARC042","ARC030","ARC073","ARC030","ARC061","ARC106","ARC145","ARC104","ARC112","ARC002"
        },
        -- pack #20 in box #23
        [20] = {
            "ARC193","ARC188","ARC182","ARC202","ARC175","ARC058","ARC107","ARC079","ARC035","ARC062","ARC031","ARC137","ARC107","ARC144","ARC097","ARC040","ARC115"
        },
        -- pack #21 in box #23
        [21] = {
            "ARC192","ARC214","ARC197","ARC180","ARC059","ARC161","ARC085","ARC005","ARC074","ARC029","ARC066","ARC105","ARC148","ARC108","ARC149","ARC113","ARC115"
        },
        -- pack #22 in box #23
        [22] = {
            "ARC182","ARC211","ARC185","ARC196","ARC086","ARC130","ARC057","ARC151","ARC025","ARC067","ARC028","ARC137","ARC108","ARC147","ARC097","ARC113","ARC112"
        },
        -- pack #23 in box #23
        [23] = {
            "ARC194","ARC198","ARC205","ARC189","ARC015","ARC125","ARC146","ARC152","ARC027","ARC067","ARC034","ARC141","ARC107","ARC137","ARC109","ARC040","ARC113"
        },
        -- pack #24 in box #23
        [24] = {
            "ARC206","ARC199","ARC204","ARC200","ARC089","ARC012","ARC136","ARC151","ARC068","ARC035","ARC074","ARC110","ARC146","ARC107","ARC143","ARC113","ARC003"
        },
    },
    -- box #24
    [24] = {
        -- pack #1 in box #24
        [1] = {
            "ARC180","ARC197","ARC216","ARC208","ARC123","ARC085","ARC086","ARC042","ARC060","ARC024","ARC069","ARC107","ARC146","ARC101","ARC144","ARC001","ARC038"
        },
        -- pack #2 in box #24
        [2] = {
            "ARC206","ARC187","ARC191","ARC213","ARC054","ARC014","ARC141","ARC157","ARC032","ARC064","ARC037","ARC147","ARC098","ARC138","ARC111","ARC114","ARC077"
        },
        -- pack #3 in box #24
        [3] = {
            "ARC200","ARC202","ARC204","ARC208","ARC168","ARC165","ARC209","ARC005","ARC061","ARC033","ARC060","ARC104","ARC134","ARC095","ARC134","ARC038","ARC115"
        },
        -- pack #4 in box #24
        [4] = {
            "ARC209","ARC217","ARC194","ARC201","ARC056","ARC159","ARC062","ARC079","ARC071","ARC023","ARC067","ARC103","ARC136","ARC106","ARC139","ARC003","ARC038"
        },
        -- pack #5 in box #24
        [5] = {
            "ARC187","ARC184","ARC190","ARC188","ARC175","ARC168","ARC079","ARC153","ARC072","ARC027","ARC070","ARC025","ARC133","ARC097","ARC145","ARC115","ARC076"
        },
        -- pack #6 in box #24
        [6] = {
            "ARC215","ARC201","ARC194","ARC204","ARC014","ARC167","ARC141","ARC005","ARC023","ARC074","ARC023","ARC133","ARC107","ARC149","ARC108","ARC077","ARC002"
        },
        -- pack #7 in box #24
        [7] = {
            "ARC179","ARC185","ARC185","ARC216","ARC087","ARC044","ARC129","ARC079","ARC031","ARC074","ARC020","ARC140","ARC104","ARC133","ARC108","ARC039","ARC002"
        },
        -- pack #8 in box #24
        [8] = {
            "ARC193","ARC189","ARC216","ARC188","ARC129","ARC124","ARC102","ARC154","ARC035","ARC073","ARC036","ARC073","ARC096","ARC145","ARC111","ARC003","ARC113"
        },
        -- pack #9 in box #24
        [9] = {
            "ARC186","ARC200","ARC183","ARC197","ARC130","ARC006","ARC027","ARC117","ARC073","ARC024","ARC072","ARC104","ARC144","ARC103","ARC141","ARC039","ARC077"
        },
        -- pack #10 in box #24
        [10] = {
            "ARC194","ARC216","ARC179","ARC200","ARC088","ARC049","ARC209","ARC158","ARC068","ARC026","ARC069","ARC035","ARC132","ARC097","ARC142","ARC038","ARC077"
        },
        -- pack #11 in box #24
        [11] = {
            "ARC188","ARC184","ARC193","ARC191","ARC092","ARC019","ARC201","ARC042","ARC072","ARC034","ARC068","ARC104","ARC134","ARC103","ARC134","ARC218"
        },
        -- pack #12 in box #24
        [12] = {
            "ARC200","ARC185","ARC202","ARC203","ARC057","ARC050","ARC140","ARC158","ARC025","ARC066","ARC025","ARC072","ARC108","ARC139","ARC103","ARC075","ARC114"
        },
        -- pack #13 in box #24
        [13] = {
            "ARC186","ARC211","ARC177","ARC178","ARC090","ARC123","ARC189","ARC158","ARC035","ARC067","ARC031","ARC146","ARC107","ARC145","ARC110","ARC112","ARC039"
        },
        -- pack #14 in box #24
        [14] = {
            "ARC184","ARC208","ARC206","ARC205","ARC091","ARC170","ARC108","ARC156","ARC068","ARC021","ARC073","ARC027","ARC138","ARC102","ARC146","ARC114","ARC038"
        },
        -- pack #15 in box #24
        [15] = {
            "ARC181","ARC191","ARC196","ARC188","ARC166","ARC012","ARC051","ARC153","ARC032","ARC063","ARC032","ARC071","ARC099","ARC140","ARC100","ARC003","ARC113"
        },
        -- pack #16 in box #24
        [16] = {
            "ARC195","ARC195","ARC215","ARC184","ARC052","ARC166","ARC020","ARC042","ARC023","ARC060","ARC035","ARC137","ARC109","ARC133","ARC100","ARC040","ARC115"
        },
        -- pack #17 in box #24
        [17] = {
            "ARC216","ARC179","ARC212","ARC186","ARC131","ARC007","ARC099","ARC153","ARC022","ARC064","ARC034","ARC135","ARC096","ARC143","ARC099","ARC040","ARC003"
        },
        -- pack #18 in box #24
        [18] = {
            "ARC201","ARC213","ARC203","ARC204","ARC085","ARC088","ARC180","ARC158","ARC031","ARC060","ARC024","ARC062","ARC110","ARC149","ARC109","ARC075","ARC115"
        },
        -- pack #19 in box #24
        [19] = {
            "ARC177","ARC184","ARC208","ARC202","ARC012","ARC125","ARC088","ARC152","ARC034","ARC069","ARC027","ARC069","ARC096","ARC137","ARC108","ARC077","ARC002"
        },
        -- pack #20 in box #24
        [20] = {
            "ARC178","ARC208","ARC214","ARC214","ARC168","ARC044","ARC108","ARC153","ARC074","ARC036","ARC062","ARC033","ARC144","ARC099","ARC137","ARC076","ARC077"
        },
        -- pack #21 in box #24
        [21] = {
            "ARC202","ARC203","ARC202","ARC209","ARC130","ARC017","ARC008","ARC156","ARC028","ARC063","ARC024","ARC061","ARC099","ARC133","ARC094","ARC039","ARC077"
        },
        -- pack #22 in box #24
        [22] = {
            "ARC198","ARC188","ARC186","ARC204","ARC056","ARC085","ARC123","ARC152","ARC065","ARC029","ARC073","ARC098","ARC145","ARC101","ARC141","ARC115","ARC039"
        },
        -- pack #23 in box #24
        [23] = {
            "ARC181","ARC188","ARC182","ARC181","ARC092","ARC057","ARC154","ARC156","ARC073","ARC032","ARC068","ARC036","ARC148","ARC107","ARC145","ARC040","ARC112"
        },
        -- pack #24 in box #24
        [24] = {
            "ARC191","ARC197","ARC211","ARC189","ARC053","ARC091","ARC018","ARC151","ARC066","ARC025","ARC062","ARC024","ARC143","ARC103","ARC141","ARC115","ARC113"
        },
    },
    -- box #25
    [25] = {
        -- pack #1 in box #25
        [1] = {
            "ARC196","ARC207","ARC176","ARC188","ARC014","ARC171","ARC104","ARC157","ARC025","ARC064","ARC034","ARC139","ARC109","ARC142","ARC099","ARC039","ARC114"
        },
        -- pack #2 in box #25
        [2] = {
            "ARC189","ARC211","ARC177","ARC212","ARC050","ARC012","ARC160","ARC151","ARC021","ARC073","ARC036","ARC142","ARC105","ARC135","ARC096","ARC039","ARC112"
        },
        -- pack #3 in box #25
        [3] = {
            "ARC181","ARC189","ARC189","ARC210","ARC090","ARC169","ARC066","ARC117","ARC036","ARC060","ARC022","ARC068","ARC105","ARC148","ARC106","ARC001","ARC113"
        },
        -- pack #4 in box #25
        [4] = {
            "ARC195","ARC182","ARC205","ARC179","ARC175","ARC083","ARC194","ARC155","ARC020","ARC073","ARC025","ARC070","ARC104","ARC144","ARC098","ARC038","ARC113"
        },
        -- pack #5 in box #25
        [5] = {
            "ARC178","ARC188","ARC193","ARC183","ARC170","ARC086","ARC193","ARC154","ARC030","ARC063","ARC021","ARC147","ARC106","ARC135","ARC108","ARC039","ARC003"
        },
        -- pack #6 in box #25
        [6] = {
            "ARC181","ARC178","ARC214","ARC201","ARC174","ARC124","ARC146","ARC042","ARC027","ARC063","ARC033","ARC147","ARC107","ARC141","ARC104","ARC076","ARC040"
        },
        -- pack #7 in box #25
        [7] = {
            "ARC194","ARC182","ARC208","ARC212","ARC164","ARC015","ARC141","ARC157","ARC028","ARC072","ARC032","ARC147","ARC098","ARC145","ARC098","ARC114","ARC040"
        },
        -- pack #8 in box #25
        [8] = {
            "ARC204","ARC186","ARC210","ARC190","ARC085","ARC119","ARC209","ARC157","ARC067","ARC028","ARC069","ARC037","ARC148","ARC094","ARC143","ARC001","ARC077"
        },
        -- pack #9 in box #25
        [9] = {
            "ARC190","ARC217","ARC202","ARC204","ARC093","ARC131","ARC033","ARC153","ARC066","ARC031","ARC073","ARC103","ARC138","ARC104","ARC145","ARC039","ARC113"
        },
        -- pack #10 in box #25
        [10] = {
            "ARC189","ARC208","ARC209","ARC185","ARC011","ARC080","ARC214","ARC005","ARC066","ARC020","ARC060","ARC097","ARC135","ARC099","ARC135","ARC114","ARC038"
        },
        -- pack #11 in box #25
        [11] = {
            "ARC190","ARC184","ARC178","ARC195","ARC048","ARC053","ARC021","ARC152","ARC071","ARC035","ARC065","ARC030","ARC138","ARC104","ARC146","ARC001","ARC002"
        },
        -- pack #12 in box #25
        [12] = {
            "ARC209","ARC181","ARC188","ARC202","ARC125","ARC092","ARC174","ARC117","ARC063","ARC022","ARC062","ARC099","ARC138","ARC111","ARC133","ARC038","ARC001"
        },
        -- pack #13 in box #25
        [13] = {
            "ARC208","ARC190","ARC192","ARC181","ARC052","ARC089","ARC074","ARC152","ARC062","ARC034","ARC072","ARC034","ARC134","ARC098","ARC138","ARC115","ARC077"
        },
        -- pack #14 in box #25
        [14] = {
            "ARC204","ARC206","ARC186","ARC190","ARC051","ARC085","ARC185","ARC079","ARC035","ARC070","ARC036","ARC060","ARC111","ARC132","ARC110","ARC003","ARC075"
        },
        -- pack #15 in box #25
        [15] = {
            "ARC197","ARC181","ARC217","ARC211","ARC128","ARC124","ARC181","ARC158","ARC034","ARC070","ARC024","ARC132","ARC097","ARC144","ARC103","ARC077","ARC114"
        },
        -- pack #16 in box #25
        [16] = {
            "ARC182","ARC199","ARC185","ARC183","ARC127","ARC014","ARC116","ARC079","ARC037","ARC071","ARC021","ARC065","ARC108","ARC139","ARC110","ARC002","ARC003"
        },
        -- pack #17 in box #25
        [17] = {
            "ARC210","ARC196","ARC196","ARC193","ARC056","ARC007","ARC196","ARC042","ARC060","ARC027","ARC069","ARC034","ARC140","ARC094","ARC138","ARC003","ARC114"
        },
        -- pack #18 in box #25
        [18] = {
            "ARC178","ARC216","ARC190","ARC181","ARC174","ARC173","ARC083","ARC158","ARC067","ARC025","ARC061","ARC102","ARC143","ARC109","ARC137","ARC218"
        },
        -- pack #19 in box #25
        [19] = {
            "ARC207","ARC201","ARC202","ARC210","ARC123","ARC128","ARC064","ARC079","ARC020","ARC061","ARC034","ARC063","ARC105","ARC144","ARC105","ARC038","ARC113"
        },
        -- pack #20 in box #25
        [20] = {
            "ARC210","ARC176","ARC183","ARC185","ARC171","ARC170","ARC103","ARC042","ARC022","ARC069","ARC024","ARC062","ARC111","ARC142","ARC104","ARC115","ARC001"
        },
        -- pack #21 in box #25
        [21] = {
            "ARC188","ARC180","ARC192","ARC179","ARC055","ARC058","ARC176","ARC157","ARC066","ARC025","ARC073","ARC101","ARC136","ARC098","ARC133","ARC040","ARC113"
        },
        -- pack #22 in box #25
        [22] = {
            "ARC176","ARC189","ARC211","ARC213","ARC167","ARC128","ARC179","ARC151","ARC072","ARC035","ARC069","ARC036","ARC144","ARC099","ARC143","ARC039","ARC113"
        },
        -- pack #23 in box #25
        [23] = {
            "ARC197","ARC189","ARC205","ARC210","ARC053","ARC171","ARC196","ARC151","ARC065","ARC027","ARC062","ARC036","ARC148","ARC104","ARC140","ARC112","ARC040"
        },
        -- pack #24 in box #25
        [24] = {
            "ARC200","ARC214","ARC212","ARC203","ARC050","ARC118","ARC051","ARC117","ARC064","ARC021","ARC065","ARC106","ARC147","ARC095","ARC147","ARC003","ARC077"
        },
    },
    -- box #26
    [26] = {
        -- pack #1 in box #26
        [1] = {
            "ARC211","ARC195","ARC216","ARC206","ARC059","ARC174","ARC048","ARC155","ARC067","ARC037","ARC071","ARC094","ARC144","ARC110","ARC148","ARC115","ARC001"
        },
        -- pack #2 in box #26
        [2] = {
            "ARC214","ARC193","ARC200","ARC211","ARC129","ARC048","ARC206","ARC155","ARC071","ARC020","ARC063","ARC037","ARC147","ARC100","ARC132","ARC218"
        },
        -- pack #3 in box #26
        [3] = {
            "ARC205","ARC177","ARC208","ARC206","ARC123","ARC128","ARC032","ARC156","ARC060","ARC022","ARC074","ARC024","ARC145","ARC100","ARC136","ARC040","ARC115"
        },
        -- pack #4 in box #26
        [4] = {
            "ARC189","ARC180","ARC199","ARC190","ARC051","ARC165","ARC037","ARC117","ARC071","ARC029","ARC069","ARC101","ARC149","ARC095","ARC149","ARC075","ARC114"
        },
        -- pack #5 in box #26
        [5] = {
            "ARC189","ARC197","ARC211","ARC190","ARC126","ARC081","ARC047","ARC154","ARC033","ARC070","ARC034","ARC062","ARC097","ARC145","ARC105","ARC001","ARC114"
        },
        -- pack #6 in box #26
        [6] = {
            "ARC185","ARC186","ARC185","ARC178","ARC055","ARC055","ARC128","ARC042","ARC027","ARC073","ARC028","ARC133","ARC104","ARC137","ARC098","ARC002","ARC115"
        },
        -- pack #7 in box #26
        [7] = {
            "ARC207","ARC203","ARC201","ARC198","ARC166","ARC086","ARC022","ARC153","ARC065","ARC023","ARC061","ARC036","ARC143","ARC101","ARC149","ARC218"
        },
        -- pack #8 in box #26
        [8] = {
            "ARC214","ARC217","ARC217","ARC179","ARC058","ARC051","ARC153","ARC151","ARC027","ARC068","ARC037","ARC067","ARC104","ARC142","ARC098","ARC002","ARC114"
        },
        -- pack #9 in box #26
        [9] = {
            "ARC192","ARC217","ARC203","ARC198","ARC166","ARC175","ARC061","ARC158","ARC065","ARC028","ARC069","ARC105","ARC140","ARC098","ARC133","ARC038","ARC112"
        },
        -- pack #10 in box #26
        [10] = {
            "ARC209","ARC191","ARC198","ARC191","ARC092","ARC009","ARC098","ARC151","ARC031","ARC070","ARC022","ARC068","ARC110","ARC140","ARC101","ARC038","ARC077"
        },
        -- pack #11 in box #26
        [11] = {
            "ARC177","ARC192","ARC204","ARC214","ARC059","ARC123","ARC066","ARC155","ARC029","ARC071","ARC025","ARC143","ARC101","ARC145","ARC098","ARC115","ARC076"
        },
        -- pack #12 in box #26
        [12] = {
            "ARC184","ARC200","ARC181","ARC217","ARC055","ARC126","ARC020","ARC154","ARC068","ARC028","ARC072","ARC099","ARC148","ARC094","ARC136","ARC112","ARC003"
        },
        -- pack #13 in box #26
        [13] = {
            "ARC176","ARC197","ARC209","ARC193","ARC054","ARC089","ARC177","ARC158","ARC061","ARC022","ARC067","ARC036","ARC132","ARC105","ARC145","ARC076","ARC075"
        },
        -- pack #14 in box #26
        [14] = {
            "ARC207","ARC179","ARC207","ARC206","ARC055","ARC171","ARC147","ARC151","ARC032","ARC070","ARC026","ARC140","ARC098","ARC144","ARC107","ARC112","ARC001"
        },
        -- pack #15 in box #26
        [15] = {
            "ARC189","ARC176","ARC210","ARC179","ARC172","ARC019","ARC053","ARC155","ARC025","ARC063","ARC035","ARC146","ARC102","ARC148","ARC100","ARC038","ARC112"
        },
        -- pack #16 in box #26
        [16] = {
            "ARC213","ARC194","ARC187","ARC215","ARC125","ARC122","ARC032","ARC079","ARC036","ARC069","ARC034","ARC149","ARC096","ARC145","ARC099","ARC003","ARC002"
        },
        -- pack #17 in box #26
        [17] = {
            "ARC207","ARC191","ARC200","ARC176","ARC051","ARC013","ARC104","ARC156","ARC020","ARC066","ARC025","ARC143","ARC101","ARC133","ARC105","ARC038","ARC003"
        },
        -- pack #18 in box #26
        [18] = {
            "ARC182","ARC214","ARC182","ARC183","ARC058","ARC168","ARC204","ARC153","ARC037","ARC063","ARC037","ARC070","ARC095","ARC143","ARC101","ARC039","ARC001"
        },
        -- pack #19 in box #26
        [19] = {
            "ARC182","ARC178","ARC206","ARC199","ARC013","ARC165","ARC177","ARC042","ARC067","ARC020","ARC063","ARC030","ARC137","ARC096","ARC139","ARC115","ARC112"
        },
        -- pack #20 in box #26
        [20] = {
            "ARC190","ARC187","ARC191","ARC203","ARC174","ARC159","ARC032","ARC154","ARC036","ARC072","ARC024","ARC063","ARC099","ARC136","ARC094","ARC075","ARC115"
        },
        -- pack #21 in box #26
        [21] = {
            "ARC195","ARC214","ARC208","ARC190","ARC090","ARC169","ARC179","ARC152","ARC034","ARC072","ARC023","ARC065","ARC102","ARC143","ARC104","ARC040","ARC002"
        },
        -- pack #22 in box #26
        [22] = {
            "ARC179","ARC197","ARC202","ARC206","ARC167","ARC054","ARC184","ARC158","ARC068","ARC034","ARC064","ARC098","ARC133","ARC111","ARC148","ARC040","ARC115"
        },
        -- pack #23 in box #26
        [23] = {
            "ARC186","ARC210","ARC181","ARC189","ARC092","ARC014","ARC073","ARC153","ARC068","ARC031","ARC070","ARC098","ARC139","ARC111","ARC139","ARC077","ARC002"
        },
        -- pack #24 in box #26
        [24] = {
            "ARC196","ARC201","ARC194","ARC211","ARC170","ARC167","ARC214","ARC005","ARC074","ARC025","ARC069","ARC026","ARC149","ARC108","ARC149","ARC115","ARC075"
        },
    },
    -- box #27
    [27] = {
        -- pack #1 in box #27
        [1] = {
            "ARC188","ARC204","ARC185","ARC188","ARC048","ARC129","ARC121","ARC152","ARC072","ARC024","ARC061","ARC104","ARC145","ARC101","ARC138","ARC112","ARC039"
        },
        -- pack #2 in box #27
        [2] = {
            "ARC193","ARC217","ARC196","ARC186","ARC018","ARC084","ARC092","ARC157","ARC023","ARC072","ARC024","ARC136","ARC107","ARC134","ARC109","ARC038","ARC076"
        },
        -- pack #3 in box #27
        [3] = {
            "ARC204","ARC204","ARC204","ARC185","ARC130","ARC046","ARC110","ARC005","ARC072","ARC022","ARC060","ARC021","ARC142","ARC099","ARC136","ARC003","ARC113"
        },
        -- pack #4 in box #27
        [4] = {
            "ARC217","ARC184","ARC190","ARC205","ARC166","ARC121","ARC051","ARC117","ARC023","ARC062","ARC032","ARC071","ARC105","ARC147","ARC106","ARC039","ARC077"
        },
        -- pack #5 in box #27
        [5] = {
            "ARC211","ARC177","ARC201","ARC192","ARC125","ARC169","ARC066","ARC151","ARC031","ARC066","ARC029","ARC067","ARC101","ARC139","ARC098","ARC003","ARC112"
        },
        -- pack #6 in box #27
        [6] = {
            "ARC178","ARC197","ARC205","ARC177","ARC058","ARC012","ARC094","ARC153","ARC073","ARC026","ARC064","ARC095","ARC148","ARC102","ARC147","ARC076","ARC114"
        },
        -- pack #7 in box #27
        [7] = {
            "ARC217","ARC189","ARC199","ARC187","ARC175","ARC173","ARC195","ARC152","ARC037","ARC071","ARC032","ARC066","ARC094","ARC140","ARC100","ARC115","ARC040"
        },
        -- pack #8 in box #27
        [8] = {
            "ARC194","ARC206","ARC190","ARC213","ARC086","ARC129","ARC191","ARC005","ARC030","ARC060","ARC026","ARC147","ARC106","ARC138","ARC110","ARC040","ARC113"
        },
        -- pack #9 in box #27
        [9] = {
            "ARC180","ARC204","ARC186","ARC194","ARC129","ARC019","ARC189","ARC153","ARC070","ARC033","ARC074","ARC101","ARC135","ARC100","ARC138","ARC003","ARC002"
        },
        -- pack #10 in box #27
        [10] = {
            "ARC201","ARC190","ARC193","ARC217","ARC055","ARC088","ARC108","ARC005","ARC029","ARC064","ARC033","ARC146","ARC094","ARC141","ARC101","ARC002","ARC113"
        },
        -- pack #11 in box #27
        [11] = {
            "ARC178","ARC213","ARC191","ARC208","ARC013","ARC130","ARC146","ARC117","ARC064","ARC031","ARC071","ARC099","ARC143","ARC098","ARC132","ARC077","ARC003"
        },
        -- pack #12 in box #27
        [12] = {
            "ARC203","ARC213","ARC192","ARC200","ARC171","ARC009","ARC209","ARC157","ARC035","ARC074","ARC037","ARC071","ARC101","ARC149","ARC104","ARC002","ARC112"
        },
        -- pack #13 in box #27
        [13] = {
            "ARC195","ARC183","ARC205","ARC210","ARC091","ARC130","ARC027","ARC158","ARC066","ARC037","ARC066","ARC096","ARC139","ARC099","ARC142","ARC115","ARC114"
        },
        -- pack #14 in box #27
        [14] = {
            "ARC190","ARC196","ARC185","ARC186","ARC130","ARC122","ARC216","ARC158","ARC070","ARC029","ARC065","ARC030","ARC143","ARC103","ARC147","ARC003","ARC076"
        },
        -- pack #15 in box #27
        [15] = {
            "ARC216","ARC207","ARC186","ARC211","ARC090","ARC014","ARC041","ARC153","ARC073","ARC031","ARC072","ARC035","ARC140","ARC100","ARC137","ARC077","ARC114"
        },
        -- pack #16 in box #27
        [16] = {
            "ARC202","ARC177","ARC183","ARC212","ARC048","ARC053","ARC065","ARC157","ARC068","ARC032","ARC071","ARC028","ARC132","ARC103","ARC132","ARC218"
        },
        -- pack #17 in box #27
        [17] = {
            "ARC192","ARC197","ARC214","ARC217","ARC128","ARC048","ARC124","ARC153","ARC033","ARC064","ARC033","ARC132","ARC109","ARC132","ARC102","ARC218"
        },
        -- pack #18 in box #27
        [18] = {
            "ARC194","ARC201","ARC215","ARC201","ARC125","ARC086","ARC179","ARC155","ARC060","ARC032","ARC061","ARC110","ARC140","ARC099","ARC143","ARC218"
        },
        -- pack #19 in box #27
        [19] = {
            "ARC193","ARC191","ARC190","ARC179","ARC125","ARC171","ARC151","ARC153","ARC029","ARC064","ARC036","ARC069","ARC111","ARC144","ARC100","ARC112","ARC039"
        },
        -- pack #20 in box #27
        [20] = {
            "ARC185","ARC197","ARC212","ARC198","ARC168","ARC048","ARC175","ARC005","ARC036","ARC062","ARC025","ARC148","ARC094","ARC137","ARC102","ARC076","ARC113"
        },
        -- pack #21 in box #27
        [21] = {
            "ARC212","ARC215","ARC204","ARC203","ARC166","ARC091","ARC059","ARC153","ARC029","ARC062","ARC037","ARC139","ARC104","ARC132","ARC097","ARC075","ARC001"
        },
        -- pack #22 in box #27
        [22] = {
            "ARC191","ARC217","ARC215","ARC195","ARC089","ARC018","ARC065","ARC154","ARC028","ARC069","ARC020","ARC068","ARC099","ARC145","ARC101","ARC002","ARC038"
        },
        -- pack #23 in box #27
        [23] = {
            "ARC180","ARC204","ARC204","ARC198","ARC166","ARC159","ARC153","ARC117","ARC071","ARC024","ARC074","ARC022","ARC141","ARC101","ARC132","ARC002","ARC114"
        },
        -- pack #24 in box #27
        [24] = {
            "ARC181","ARC191","ARC212","ARC187","ARC018","ARC013","ARC107","ARC152","ARC073","ARC034","ARC073","ARC034","ARC146","ARC109","ARC140","ARC003","ARC076"
        },
    },
    -- box #28
    [28] = {
        -- pack #1 in box #28
        [1] = {
            "ARC200","ARC177","ARC197","ARC186","ARC129","ARC164","ARC030","ARC153","ARC029","ARC060","ARC035","ARC137","ARC109","ARC149","ARC097","ARC218"
        },
        -- pack #2 in box #28
        [2] = {
            "ARC187","ARC184","ARC186","ARC200","ARC089","ARC175","ARC093","ARC157","ARC065","ARC037","ARC065","ARC108","ARC147","ARC098","ARC148","ARC003","ARC076"
        },
        -- pack #3 in box #28
        [3] = {
            "ARC211","ARC201","ARC184","ARC189","ARC167","ARC127","ARC063","ARC158","ARC027","ARC072","ARC021","ARC069","ARC103","ARC139","ARC102","ARC038","ARC003"
        },
        -- pack #4 in box #28
        [4] = {
            "ARC188","ARC215","ARC188","ARC206","ARC092","ARC016","ARC201","ARC151","ARC026","ARC069","ARC026","ARC146","ARC098","ARC135","ARC099","ARC002","ARC076"
        },
        -- pack #5 in box #28
        [5] = {
            "ARC180","ARC212","ARC211","ARC205","ARC130","ARC160","ARC117","ARC153","ARC025","ARC063","ARC036","ARC067","ARC104","ARC133","ARC111","ARC115","ARC002"
        },
        -- pack #6 in box #28
        [6] = {
            "ARC183","ARC205","ARC207","ARC193","ARC019","ARC082","ARC124","ARC153","ARC030","ARC073","ARC021","ARC064","ARC095","ARC149","ARC100","ARC114","ARC112"
        },
        -- pack #7 in box #28
        [7] = {
            "ARC206","ARC204","ARC177","ARC185","ARC059","ARC017","ARC106","ARC153","ARC065","ARC022","ARC065","ARC032","ARC145","ARC099","ARC136","ARC114","ARC003"
        },
        -- pack #8 in box #28
        [8] = {
            "ARC178","ARC204","ARC191","ARC213","ARC171","ARC049","ARC200","ARC151","ARC073","ARC033","ARC072","ARC094","ARC148","ARC099","ARC145","ARC040","ARC113"
        },
        -- pack #9 in box #28
        [9] = {
            "ARC202","ARC200","ARC203","ARC181","ARC056","ARC007","ARC145","ARC158","ARC071","ARC032","ARC073","ARC034","ARC149","ARC096","ARC148","ARC115","ARC113"
        },
        -- pack #10 in box #28
        [10] = {
            "ARC185","ARC184","ARC204","ARC188","ARC087","ARC172","ARC189","ARC157","ARC070","ARC031","ARC062","ARC025","ARC147","ARC108","ARC136","ARC001","ARC114"
        },
        -- pack #11 in box #28
        [11] = {
            "ARC202","ARC217","ARC201","ARC184","ARC056","ARC009","ARC067","ARC152","ARC031","ARC071","ARC037","ARC064","ARC108","ARC132","ARC103","ARC076","ARC001"
        },
        -- pack #12 in box #28
        [12] = {
            "ARC177","ARC215","ARC181","ARC206","ARC091","ARC118","ARC068","ARC152","ARC028","ARC061","ARC022","ARC066","ARC095","ARC146","ARC104","ARC040","ARC038"
        },
        -- pack #13 in box #28
        [13] = {
            "ARC186","ARC178","ARC183","ARC181","ARC168","ARC014","ARC028","ARC042","ARC036","ARC070","ARC026","ARC140","ARC100","ARC141","ARC108","ARC113","ARC040"
        },
        -- pack #14 in box #28
        [14] = {
            "ARC179","ARC191","ARC189","ARC212","ARC056","ARC016","ARC213","ARC079","ARC067","ARC031","ARC067","ARC027","ARC133","ARC097","ARC132","ARC075","ARC039"
        },
        -- pack #15 in box #28
        [15] = {
            "ARC205","ARC206","ARC191","ARC195","ARC165","ARC092","ARC171","ARC154","ARC072","ARC020","ARC060","ARC022","ARC143","ARC095","ARC148","ARC076","ARC112"
        },
        -- pack #16 in box #28
        [16] = {
            "ARC193","ARC192","ARC196","ARC181","ARC050","ARC089","ARC037","ARC079","ARC072","ARC032","ARC062","ARC101","ARC147","ARC095","ARC142","ARC038","ARC076"
        },
        -- pack #17 in box #28
        [17] = {
            "ARC214","ARC214","ARC216","ARC213","ARC014","ARC006","ARC137","ARC042","ARC035","ARC068","ARC028","ARC065","ARC103","ARC143","ARC109","ARC003","ARC039"
        },
        -- pack #18 in box #28
        [18] = {
            "ARC210","ARC209","ARC190","ARC194","ARC130","ARC119","ARC176","ARC156","ARC035","ARC060","ARC027","ARC148","ARC108","ARC132","ARC097","ARC076","ARC038"
        },
        -- pack #19 in box #28
        [19] = {
            "ARC191","ARC186","ARC178","ARC193","ARC170","ARC008","ARC156","ARC005","ARC022","ARC070","ARC033","ARC136","ARC100","ARC141","ARC111","ARC112","ARC003"
        },
        -- pack #20 in box #28
        [20] = {
            "ARC183","ARC215","ARC209","ARC212","ARC051","ARC170","ARC025","ARC156","ARC060","ARC027","ARC067","ARC022","ARC142","ARC101","ARC144","ARC003","ARC115"
        },
        -- pack #21 in box #28
        [21] = {
            "ARC183","ARC199","ARC212","ARC215","ARC051","ARC123","ARC208","ARC157","ARC027","ARC072","ARC031","ARC145","ARC111","ARC138","ARC100","ARC113","ARC076"
        },
        -- pack #22 in box #28
        [22] = {
            "ARC176","ARC178","ARC184","ARC202","ARC167","ARC175","ARC134","ARC042","ARC061","ARC028","ARC074","ARC097","ARC140","ARC104","ARC148","ARC113","ARC114"
        },
        -- pack #23 in box #28
        [23] = {
            "ARC180","ARC180","ARC192","ARC206","ARC168","ARC017","ARC139","ARC042","ARC069","ARC024","ARC073","ARC106","ARC141","ARC094","ARC133","ARC077","ARC076"
        },
        -- pack #24 in box #28
        [24] = {
            "ARC215","ARC202","ARC207","ARC177","ARC048","ARC087","ARC187","ARC154","ARC061","ARC037","ARC065","ARC101","ARC148","ARC111","ARC144","ARC001","ARC002"
        },
    },
    -- box #29
    [29] = {
        -- pack #1 in box #29
        [1] = {
            "ARC214","ARC176","ARC216","ARC179","ARC166","ARC125","ARC143","ARC079","ARC029","ARC067","ARC029","ARC069","ARC103","ARC142","ARC095","ARC040","ARC114"
        },
        -- pack #2 in box #29
        [2] = {
            "ARC211","ARC177","ARC180","ARC214","ARC131","ARC167","ARC109","ARC152","ARC067","ARC030","ARC069","ARC032","ARC142","ARC104","ARC141","ARC038","ARC115"
        },
        -- pack #3 in box #29
        [3] = {
            "ARC198","ARC212","ARC217","ARC184","ARC050","ARC016","ARC022","ARC117","ARC027","ARC073","ARC032","ARC137","ARC104","ARC144","ARC109","ARC038","ARC075"
        },
        -- pack #4 in box #29
        [4] = {
            "ARC188","ARC192","ARC184","ARC198","ARC125","ARC125","ARC119","ARC156","ARC028","ARC072","ARC032","ARC072","ARC111","ARC146","ARC111","ARC077","ARC003"
        },
        -- pack #5 in box #29
        [5] = {
            "ARC198","ARC211","ARC184","ARC202","ARC125","ARC166","ARC082","ARC158","ARC071","ARC024","ARC061","ARC094","ARC143","ARC101","ARC138","ARC002","ARC039"
        },
        -- pack #6 in box #29
        [6] = {
            "ARC178","ARC208","ARC195","ARC189","ARC087","ARC085","ARC137","ARC117","ARC062","ARC031","ARC068","ARC101","ARC146","ARC095","ARC138","ARC218"
        },
        -- pack #7 in box #29
        [7] = {
            "ARC209","ARC178","ARC194","ARC183","ARC055","ARC090","ARC046","ARC156","ARC021","ARC061","ARC026","ARC071","ARC099","ARC146","ARC097","ARC218"
        },
        -- pack #8 in box #29
        [8] = {
            "ARC213","ARC201","ARC204","ARC205","ARC050","ARC052","ARC126","ARC152","ARC023","ARC064","ARC032","ARC065","ARC109","ARC136","ARC094","ARC218"
        },
        -- pack #9 in box #29
        [9] = {
            "ARC200","ARC214","ARC205","ARC198","ARC087","ARC091","ARC068","ARC158","ARC027","ARC060","ARC037","ARC149","ARC105","ARC134","ARC110","ARC076","ARC075"
        },
        -- pack #10 in box #29
        [10] = {
            "ARC191","ARC192","ARC193","ARC185","ARC130","ARC085","ARC161","ARC154","ARC065","ARC028","ARC060","ARC109","ARC134","ARC094","ARC140","ARC077","ARC114"
        },
        -- pack #11 in box #29
        [11] = {
            "ARC208","ARC191","ARC180","ARC181","ARC053","ARC050","ARC173","ARC117","ARC068","ARC028","ARC067","ARC026","ARC132","ARC106","ARC144","ARC002","ARC112"
        },
        -- pack #12 in box #29
        [12] = {
            "ARC194","ARC177","ARC193","ARC199","ARC093","ARC169","ARC138","ARC117","ARC037","ARC071","ARC021","ARC139","ARC109","ARC146","ARC097","ARC077","ARC001"
        },
        -- pack #13 in box #29
        [13] = {
            "ARC207","ARC205","ARC214","ARC217","ARC128","ARC088","ARC198","ARC154","ARC025","ARC066","ARC025","ARC149","ARC099","ARC148","ARC107","ARC038","ARC003"
        },
        -- pack #14 in box #29
        [14] = {
            "ARC217","ARC201","ARC186","ARC201","ARC048","ARC164","ARC137","ARC158","ARC065","ARC023","ARC070","ARC029","ARC145","ARC109","ARC138","ARC003","ARC001"
        },
        -- pack #15 in box #29
        [15] = {
            "ARC181","ARC199","ARC210","ARC176","ARC087","ARC122","ARC071","ARC152","ARC072","ARC027","ARC063","ARC036","ARC138","ARC103","ARC139","ARC001","ARC115"
        },
        -- pack #16 in box #29
        [16] = {
            "ARC197","ARC207","ARC192","ARC205","ARC166","ARC166","ARC191","ARC005","ARC034","ARC071","ARC023","ARC073","ARC103","ARC143","ARC102","ARC001","ARC113"
        },
        -- pack #17 in box #29
        [17] = {
            "ARC186","ARC214","ARC179","ARC208","ARC086","ARC167","ARC053","ARC151","ARC064","ARC033","ARC064","ARC029","ARC137","ARC101","ARC142","ARC003","ARC113"
        },
        -- pack #18 in box #29
        [18] = {
            "ARC200","ARC209","ARC190","ARC217","ARC048","ARC011","ARC069","ARC158","ARC074","ARC025","ARC063","ARC102","ARC135","ARC107","ARC141","ARC075","ARC114"
        },
        -- pack #19 in box #29
        [19] = {
            "ARC190","ARC184","ARC211","ARC194","ARC172","ARC125","ARC030","ARC005","ARC066","ARC030","ARC071","ARC104","ARC134","ARC111","ARC147","ARC218"
        },
        -- pack #20 in box #29
        [20] = {
            "ARC217","ARC189","ARC202","ARC182","ARC164","ARC057","ARC097","ARC157","ARC025","ARC069","ARC033","ARC064","ARC105","ARC145","ARC099","ARC077","ARC001"
        },
        -- pack #21 in box #29
        [21] = {
            "ARC178","ARC207","ARC183","ARC206","ARC050","ARC019","ARC156","ARC079","ARC070","ARC022","ARC065","ARC025","ARC138","ARC102","ARC144","ARC218"
        },
        -- pack #22 in box #29
        [22] = {
            "ARC207","ARC213","ARC205","ARC199","ARC124","ARC084","ARC143","ARC157","ARC037","ARC060","ARC034","ARC142","ARC096","ARC136","ARC102","ARC003","ARC075"
        },
        -- pack #23 in box #29
        [23] = {
            "ARC190","ARC211","ARC183","ARC197","ARC091","ARC013","ARC018","ARC158","ARC037","ARC073","ARC020","ARC143","ARC106","ARC136","ARC101","ARC001","ARC002"
        },
        -- pack #24 in box #29
        [24] = {
            "ARC201","ARC189","ARC210","ARC177","ARC058","ARC172","ARC210","ARC152","ARC067","ARC025","ARC073","ARC108","ARC142","ARC096","ARC132","ARC040","ARC076"
        },
    },
    -- box #30
    [30] = {
        -- pack #1 in box #30
        [1] = {
            "ARC189","ARC204","ARC190","ARC176","ARC057","ARC164","ARC183","ARC158","ARC074","ARC024","ARC068","ARC096","ARC133","ARC106","ARC140","ARC218"
        },
        -- pack #2 in box #30
        [2] = {
            "ARC193","ARC180","ARC179","ARC213","ARC173","ARC168","ARC134","ARC005","ARC068","ARC027","ARC069","ARC107","ARC135","ARC102","ARC132","ARC038","ARC001"
        },
        -- pack #3 in box #30
        [3] = {
            "ARC178","ARC190","ARC186","ARC195","ARC127","ARC174","ARC184","ARC156","ARC061","ARC021","ARC063","ARC106","ARC143","ARC109","ARC144","ARC075","ARC003"
        },
        -- pack #4 in box #30
        [4] = {
            "ARC213","ARC195","ARC214","ARC181","ARC019","ARC171","ARC149","ARC154","ARC066","ARC030","ARC063","ARC031","ARC136","ARC105","ARC145","ARC112","ARC040"
        },
        -- pack #5 in box #30
        [5] = {
            "ARC185","ARC183","ARC183","ARC197","ARC013","ARC018","ARC036","ARC158","ARC069","ARC035","ARC074","ARC031","ARC145","ARC094","ARC140","ARC115","ARC076"
        },
        -- pack #6 in box #30
        [6] = {
            "ARC211","ARC202","ARC209","ARC203","ARC131","ARC124","ARC054","ARC154","ARC020","ARC067","ARC020","ARC139","ARC106","ARC133","ARC100","ARC076","ARC112"
        },
        -- pack #7 in box #30
        [7] = {
            "ARC187","ARC200","ARC205","ARC193","ARC057","ARC052","ARC081","ARC117","ARC026","ARC067","ARC036","ARC146","ARC101","ARC144","ARC096","ARC218"
        },
        -- pack #8 in box #30
        [8] = {
            "ARC200","ARC199","ARC185","ARC193","ARC017","ARC090","ARC213","ARC151","ARC026","ARC063","ARC029","ARC146","ARC101","ARC142","ARC102","ARC076","ARC112"
        },
        -- pack #9 in box #30
        [9] = {
            "ARC179","ARC197","ARC205","ARC205","ARC057","ARC172","ARC175","ARC151","ARC066","ARC030","ARC071","ARC111","ARC143","ARC101","ARC143","ARC002","ARC040"
        },
        -- pack #10 in box #30
        [10] = {
            "ARC201","ARC176","ARC192","ARC204","ARC088","ARC082","ARC033","ARC153","ARC030","ARC061","ARC030","ARC062","ARC100","ARC144","ARC108","ARC076","ARC075"
        },
        -- pack #11 in box #30
        [11] = {
            "ARC201","ARC195","ARC214","ARC197","ARC170","ARC164","ARC188","ARC152","ARC072","ARC030","ARC073","ARC026","ARC149","ARC104","ARC141","ARC076","ARC115"
        },
        -- pack #12 in box #30
        [12] = {
            "ARC206","ARC180","ARC192","ARC189","ARC165","ARC160","ARC203","ARC158","ARC073","ARC030","ARC062","ARC028","ARC146","ARC099","ARC147","ARC002","ARC075"
        },
        -- pack #13 in box #30
        [13] = {
            "ARC217","ARC209","ARC182","ARC186","ARC016","ARC169","ARC198","ARC079","ARC072","ARC033","ARC062","ARC023","ARC140","ARC100","ARC141","ARC114","ARC112"
        },
        -- pack #14 in box #30
        [14] = {
            "ARC188","ARC198","ARC193","ARC181","ARC168","ARC010","ARC055","ARC155","ARC033","ARC064","ARC027","ARC068","ARC109","ARC132","ARC097","ARC040","ARC039"
        },
        -- pack #15 in box #30
        [15] = {
            "ARC189","ARC189","ARC197","ARC193","ARC170","ARC018","ARC015","ARC079","ARC024","ARC071","ARC032","ARC062","ARC101","ARC139","ARC096","ARC113","ARC040"
        },
        -- pack #16 in box #30
        [16] = {
            "ARC185","ARC181","ARC214","ARC190","ARC015","ARC080","ARC164","ARC152","ARC023","ARC061","ARC022","ARC064","ARC103","ARC139","ARC105","ARC112","ARC038"
        },
        -- pack #17 in box #30
        [17] = {
            "ARC200","ARC190","ARC190","ARC191","ARC018","ARC050","ARC109","ARC005","ARC033","ARC060","ARC025","ARC133","ARC096","ARC139","ARC103","ARC075","ARC039"
        },
        -- pack #18 in box #30
        [18] = {
            "ARC186","ARC185","ARC203","ARC189","ARC174","ARC159","ARC037","ARC157","ARC066","ARC021","ARC068","ARC099","ARC149","ARC099","ARC139","ARC077","ARC002"
        },
        -- pack #19 in box #30
        [19] = {
            "ARC180","ARC191","ARC183","ARC208","ARC054","ARC118","ARC062","ARC157","ARC063","ARC029","ARC069","ARC096","ARC137","ARC098","ARC134","ARC038","ARC039"
        },
        -- pack #20 in box #30
        [20] = {
            "ARC187","ARC196","ARC200","ARC186","ARC092","ARC048","ARC156","ARC154","ARC035","ARC072","ARC033","ARC134","ARC096","ARC148","ARC094","ARC001","ARC038"
        },
        -- pack #21 in box #30
        [21] = {
            "ARC200","ARC209","ARC182","ARC199","ARC057","ARC092","ARC149","ARC151","ARC037","ARC071","ARC031","ARC145","ARC101","ARC145","ARC097","ARC001","ARC076"
        },
        -- pack #22 in box #30
        [22] = {
            "ARC181","ARC203","ARC202","ARC184","ARC018","ARC092","ARC211","ARC157","ARC062","ARC030","ARC061","ARC031","ARC143","ARC110","ARC135","ARC075","ARC114"
        },
        -- pack #23 in box #30
        [23] = {
            "ARC206","ARC213","ARC213","ARC211","ARC173","ARC166","ARC065","ARC155","ARC030","ARC061","ARC033","ARC069","ARC101","ARC138","ARC101","ARC112","ARC040"
        },
        -- pack #24 in box #30
        [24] = {
            "ARC209","ARC182","ARC204","ARC193","ARC053","ARC047","ARC212","ARC151","ARC027","ARC066","ARC023","ARC061","ARC103","ARC140","ARC101","ARC002","ARC115"
        },
    },
    -- box #31
    [31] = {
        -- pack #1 in box #31
        [1] = {
            "ARC216","ARC200","ARC188","ARC187","ARC127","ARC172","ARC200","ARC157","ARC021","ARC060","ARC026","ARC062","ARC106","ARC146","ARC106","ARC077","ARC039"
        },
        -- pack #2 in box #31
        [2] = {
            "ARC184","ARC192","ARC207","ARC194","ARC058","ARC122","ARC127","ARC153","ARC070","ARC030","ARC064","ARC030","ARC149","ARC100","ARC140","ARC077","ARC039"
        },
        -- pack #3 in box #31
        [3] = {
            "ARC201","ARC199","ARC202","ARC176","ARC058","ARC130","ARC199","ARC042","ARC061","ARC030","ARC062","ARC111","ARC136","ARC110","ARC147","ARC114","ARC003"
        },
        -- pack #4 in box #31
        [4] = {
            "ARC209","ARC179","ARC189","ARC209","ARC019","ARC082","ARC096","ARC154","ARC028","ARC065","ARC034","ARC071","ARC097","ARC138","ARC099","ARC076","ARC112"
        },
        -- pack #5 in box #31
        [5] = {
            "ARC187","ARC213","ARC197","ARC185","ARC164","ARC127","ARC153","ARC157","ARC065","ARC029","ARC065","ARC104","ARC144","ARC108","ARC143","ARC077","ARC002"
        },
        -- pack #6 in box #31
        [6] = {
            "ARC207","ARC178","ARC186","ARC181","ARC015","ARC162","ARC184","ARC152","ARC029","ARC070","ARC029","ARC147","ARC104","ARC149","ARC095","ARC002","ARC039"
        },
        -- pack #7 in box #31
        [7] = {
            "ARC212","ARC197","ARC214","ARC183","ARC054","ARC056","ARC133","ARC042","ARC072","ARC029","ARC067","ARC028","ARC134","ARC103","ARC143","ARC077","ARC112"
        },
        -- pack #8 in box #31
        [8] = {
            "ARC181","ARC181","ARC181","ARC184","ARC124","ARC011","ARC096","ARC155","ARC030","ARC063","ARC028","ARC063","ARC110","ARC142","ARC095","ARC218"
        },
        -- pack #9 in box #31
        [9] = {
            "ARC201","ARC201","ARC199","ARC194","ARC012","ARC171","ARC099","ARC157","ARC064","ARC023","ARC064","ARC023","ARC148","ARC103","ARC140","ARC076","ARC002"
        },
        -- pack #10 in box #31
        [10] = {
            "ARC189","ARC206","ARC196","ARC199","ARC171","ARC168","ARC197","ARC079","ARC024","ARC066","ARC020","ARC139","ARC097","ARC139","ARC107","ARC113","ARC075"
        },
        -- pack #11 in box #31
        [11] = {
            "ARC192","ARC207","ARC186","ARC181","ARC129","ARC047","ARC024","ARC005","ARC073","ARC030","ARC074","ARC095","ARC139","ARC095","ARC144","ARC001","ARC077"
        },
        -- pack #12 in box #31
        [12] = {
            "ARC216","ARC190","ARC204","ARC195","ARC093","ARC175","ARC215","ARC117","ARC063","ARC024","ARC060","ARC098","ARC145","ARC108","ARC149","ARC040","ARC112"
        },
        -- pack #13 in box #31
        [13] = {
            "ARC213","ARC179","ARC215","ARC189","ARC048","ARC123","ARC069","ARC154","ARC069","ARC025","ARC063","ARC029","ARC146","ARC101","ARC146","ARC075","ARC076"
        },
        -- pack #14 in box #31
        [14] = {
            "ARC201","ARC181","ARC195","ARC188","ARC086","ARC016","ARC072","ARC155","ARC063","ARC021","ARC073","ARC096","ARC132","ARC107","ARC145","ARC114","ARC075"
        },
        -- pack #15 in box #31
        [15] = {
            "ARC199","ARC208","ARC217","ARC192","ARC090","ARC173","ARC135","ARC156","ARC064","ARC023","ARC064","ARC033","ARC147","ARC097","ARC132","ARC115","ARC075"
        },
        -- pack #16 in box #31
        [16] = {
            "ARC184","ARC205","ARC191","ARC199","ARC171","ARC170","ARC058","ARC042","ARC036","ARC061","ARC035","ARC133","ARC105","ARC144","ARC107","ARC040","ARC077"
        },
        -- pack #17 in box #31
        [17] = {
            "ARC205","ARC184","ARC205","ARC179","ARC127","ARC120","ARC165","ARC154","ARC062","ARC021","ARC073","ARC107","ARC134","ARC104","ARC147","ARC038","ARC075"
        },
        -- pack #18 in box #31
        [18] = {
            "ARC204","ARC199","ARC211","ARC185","ARC123","ARC056","ARC194","ARC158","ARC072","ARC036","ARC068","ARC026","ARC142","ARC104","ARC132","ARC075","ARC077"
        },
        -- pack #19 in box #31
        [19] = {
            "ARC209","ARC182","ARC184","ARC182","ARC093","ARC047","ARC080","ARC151","ARC032","ARC069","ARC024","ARC068","ARC097","ARC132","ARC102","ARC077","ARC114"
        },
        -- pack #20 in box #31
        [20] = {
            "ARC184","ARC211","ARC176","ARC217","ARC011","ARC085","ARC100","ARC154","ARC022","ARC066","ARC027","ARC074","ARC097","ARC144","ARC111","ARC112","ARC077"
        },
        -- pack #21 in box #31
        [21] = {
            "ARC211","ARC176","ARC188","ARC179","ARC054","ARC089","ARC164","ARC117","ARC032","ARC071","ARC035","ARC060","ARC108","ARC140","ARC104","ARC115","ARC113"
        },
        -- pack #22 in box #31
        [22] = {
            "ARC182","ARC176","ARC176","ARC183","ARC172","ARC092","ARC135","ARC079","ARC030","ARC068","ARC025","ARC141","ARC104","ARC145","ARC106","ARC115","ARC003"
        },
        -- pack #23 in box #31
        [23] = {
            "ARC184","ARC196","ARC214","ARC215","ARC057","ARC124","ARC102","ARC005","ARC027","ARC071","ARC034","ARC140","ARC111","ARC142","ARC099","ARC112","ARC077"
        },
        -- pack #24 in box #31
        [24] = {
            "ARC213","ARC198","ARC194","ARC199","ARC124","ARC050","ARC100","ARC158","ARC024","ARC064","ARC031","ARC147","ARC098","ARC143","ARC103","ARC115","ARC112"
        },
    },
    -- box #32
    [32] = {
        -- pack #1 in box #32
        [1] = {
            "ARC212","ARC210","ARC206","ARC194","ARC169","ARC172","ARC180","ARC117","ARC024","ARC072","ARC024","ARC137","ARC109","ARC142","ARC095","ARC077","ARC114"
        },
        -- pack #2 in box #32
        [2] = {
            "ARC184","ARC190","ARC216","ARC216","ARC166","ARC118","ARC192","ARC151","ARC023","ARC067","ARC037","ARC070","ARC106","ARC135","ARC094","ARC114","ARC002"
        },
        -- pack #3 in box #32
        [3] = {
            "ARC206","ARC214","ARC203","ARC189","ARC125","ARC052","ARC037","ARC155","ARC033","ARC067","ARC033","ARC141","ARC110","ARC144","ARC107","ARC075","ARC077"
        },
        -- pack #4 in box #32
        [4] = {
            "ARC205","ARC196","ARC200","ARC192","ARC012","ARC058","ARC186","ARC117","ARC029","ARC065","ARC029","ARC074","ARC100","ARC141","ARC095","ARC001","ARC114"
        },
        -- pack #5 in box #32
        [5] = {
            "ARC193","ARC211","ARC217","ARC179","ARC059","ARC163","ARC176","ARC156","ARC027","ARC065","ARC022","ARC144","ARC105","ARC138","ARC098","ARC002","ARC076"
        },
        -- pack #6 in box #32
        [6] = {
            "ARC201","ARC213","ARC205","ARC184","ARC087","ARC119","ARC023","ARC079","ARC024","ARC071","ARC036","ARC146","ARC098","ARC142","ARC104","ARC003","ARC114"
        },
        -- pack #7 in box #32
        [7] = {
            "ARC193","ARC200","ARC195","ARC184","ARC164","ARC017","ARC052","ARC117","ARC070","ARC028","ARC061","ARC104","ARC148","ARC105","ARC148","ARC218"
        },
        -- pack #8 in box #32
        [8] = {
            "ARC203","ARC185","ARC186","ARC210","ARC093","ARC166","ARC111","ARC152","ARC061","ARC030","ARC072","ARC104","ARC141","ARC107","ARC139","ARC113","ARC038"
        },
        -- pack #9 in box #32
        [9] = {
            "ARC180","ARC178","ARC181","ARC208","ARC088","ARC081","ARC181","ARC158","ARC022","ARC066","ARC029","ARC063","ARC094","ARC144","ARC111","ARC076","ARC003"
        },
        -- pack #10 in box #32
        [10] = {
            "ARC189","ARC176","ARC197","ARC177","ARC055","ARC007","ARC197","ARC156","ARC067","ARC037","ARC064","ARC032","ARC140","ARC105","ARC146","ARC076","ARC039"
        },
        -- pack #11 in box #32
        [11] = {
            "ARC205","ARC194","ARC176","ARC192","ARC164","ARC056","ARC014","ARC117","ARC070","ARC021","ARC064","ARC032","ARC140","ARC107","ARC146","ARC002","ARC039"
        },
        -- pack #12 in box #32
        [12] = {
            "ARC187","ARC196","ARC192","ARC197","ARC089","ARC159","ARC143","ARC042","ARC030","ARC074","ARC020","ARC066","ARC100","ARC142","ARC100","ARC003","ARC001"
        },
        -- pack #13 in box #32
        [13] = {
            "ARC216","ARC179","ARC180","ARC178","ARC049","ARC017","ARC128","ARC079","ARC066","ARC021","ARC062","ARC029","ARC136","ARC098","ARC134","ARC114","ARC001"
        },
        -- pack #14 in box #32
        [14] = {
            "ARC178","ARC200","ARC199","ARC179","ARC058","ARC125","ARC195","ARC154","ARC034","ARC070","ARC021","ARC061","ARC109","ARC132","ARC099","ARC039","ARC115"
        },
        -- pack #15 in box #32
        [15] = {
            "ARC217","ARC180","ARC215","ARC211","ARC169","ARC093","ARC197","ARC005","ARC023","ARC062","ARC037","ARC138","ARC094","ARC147","ARC100","ARC001","ARC040"
        },
        -- pack #16 in box #32
        [16] = {
            "ARC201","ARC210","ARC217","ARC187","ARC013","ARC092","ARC074","ARC151","ARC022","ARC067","ARC024","ARC148","ARC106","ARC132","ARC109","ARC039","ARC038"
        },
        -- pack #17 in box #32
        [17] = {
            "ARC196","ARC216","ARC215","ARC208","ARC049","ARC123","ARC149","ARC117","ARC074","ARC024","ARC064","ARC028","ARC148","ARC099","ARC139","ARC001","ARC076"
        },
        -- pack #18 in box #32
        [18] = {
            "ARC187","ARC187","ARC196","ARC199","ARC125","ARC019","ARC169","ARC155","ARC067","ARC030","ARC072","ARC100","ARC141","ARC109","ARC142","ARC038","ARC003"
        },
        -- pack #19 in box #32
        [19] = {
            "ARC177","ARC208","ARC198","ARC192","ARC124","ARC173","ARC101","ARC153","ARC022","ARC071","ARC033","ARC061","ARC095","ARC145","ARC103","ARC003","ARC114"
        },
        -- pack #20 in box #32
        [20] = {
            "ARC186","ARC210","ARC208","ARC199","ARC093","ARC058","ARC017","ARC156","ARC062","ARC021","ARC063","ARC037","ARC135","ARC111","ARC134","ARC002","ARC115"
        },
        -- pack #21 in box #32
        [21] = {
            "ARC179","ARC180","ARC189","ARC183","ARC126","ARC054","ARC062","ARC005","ARC072","ARC021","ARC060","ARC102","ARC148","ARC095","ARC140","ARC114","ARC038"
        },
        -- pack #22 in box #32
        [22] = {
            "ARC180","ARC210","ARC177","ARC190","ARC124","ARC086","ARC193","ARC154","ARC072","ARC036","ARC066","ARC036","ARC140","ARC105","ARC142","ARC115","ARC003"
        },
        -- pack #23 in box #32
        [23] = {
            "ARC198","ARC190","ARC178","ARC199","ARC174","ARC011","ARC180","ARC153","ARC069","ARC023","ARC062","ARC104","ARC137","ARC098","ARC135","ARC039","ARC114"
        },
        -- pack #24 in box #32
        [24] = {
            "ARC210","ARC217","ARC207","ARC178","ARC086","ARC168","ARC060","ARC156","ARC060","ARC036","ARC072","ARC098","ARC138","ARC106","ARC140","ARC076","ARC113"
        },
    },
    -- box #33
    [33] = {
        -- pack #1 in box #33
        [1] = {
            "ARC188","ARC179","ARC192","ARC216","ARC015","ARC047","ARC163","ARC151","ARC030","ARC072","ARC023","ARC071","ARC108","ARC143","ARC098","ARC075","ARC040"
        },
        -- pack #2 in box #33
        [2] = {
            "ARC176","ARC208","ARC209","ARC193","ARC126","ARC049","ARC134","ARC042","ARC073","ARC024","ARC066","ARC105","ARC137","ARC109","ARC141","ARC075","ARC001"
        },
        -- pack #3 in box #33
        [3] = {
            "ARC202","ARC181","ARC181","ARC216","ARC018","ARC019","ARC165","ARC152","ARC024","ARC060","ARC031","ARC073","ARC104","ARC146","ARC096","ARC218"
        },
        -- pack #4 in box #33
        [4] = {
            "ARC214","ARC211","ARC215","ARC215","ARC016","ARC047","ARC110","ARC153","ARC028","ARC070","ARC020","ARC146","ARC096","ARC144","ARC095","ARC076","ARC001"
        },
        -- pack #5 in box #33
        [5] = {
            "ARC182","ARC194","ARC180","ARC187","ARC164","ARC130","ARC197","ARC156","ARC066","ARC030","ARC068","ARC111","ARC132","ARC110","ARC141","ARC077","ARC038"
        },
        -- pack #6 in box #33
        [6] = {
            "ARC216","ARC197","ARC187","ARC212","ARC130","ARC175","ARC157","ARC117","ARC062","ARC028","ARC061","ARC022","ARC142","ARC095","ARC138","ARC113","ARC003"
        },
        -- pack #7 in box #33
        [7] = {
            "ARC181","ARC183","ARC193","ARC185","ARC056","ARC128","ARC029","ARC155","ARC074","ARC025","ARC071","ARC107","ARC134","ARC102","ARC135","ARC112","ARC003"
        },
        -- pack #8 in box #33
        [8] = {
            "ARC197","ARC198","ARC216","ARC181","ARC049","ARC091","ARC036","ARC155","ARC034","ARC073","ARC036","ARC135","ARC103","ARC134","ARC103","ARC075","ARC113"
        },
        -- pack #9 in box #33
        [9] = {
            "ARC191","ARC215","ARC214","ARC181","ARC127","ARC058","ARC068","ARC005","ARC031","ARC063","ARC032","ARC137","ARC102","ARC138","ARC100","ARC113","ARC038"
        },
        -- pack #10 in box #33
        [10] = {
            "ARC190","ARC185","ARC208","ARC189","ARC131","ARC050","ARC136","ARC117","ARC036","ARC060","ARC034","ARC060","ARC095","ARC148","ARC096","ARC077","ARC075"
        },
        -- pack #11 in box #33
        [11] = {
            "ARC208","ARC216","ARC206","ARC206","ARC130","ARC085","ARC193","ARC152","ARC069","ARC035","ARC072","ARC094","ARC148","ARC102","ARC136","ARC112","ARC076"
        },
        -- pack #12 in box #33
        [12] = {
            "ARC215","ARC190","ARC183","ARC216","ARC125","ARC011","ARC034","ARC117","ARC066","ARC028","ARC063","ARC023","ARC138","ARC106","ARC143","ARC114","ARC113"
        },
        -- pack #13 in box #33
        [13] = {
            "ARC217","ARC185","ARC195","ARC205","ARC173","ARC165","ARC005","ARC158","ARC020","ARC060","ARC028","ARC146","ARC098","ARC135","ARC109","ARC218"
        },
        -- pack #14 in box #33
        [14] = {
            "ARC214","ARC185","ARC182","ARC180","ARC050","ARC045","ARC041","ARC152","ARC037","ARC072","ARC037","ARC067","ARC105","ARC143","ARC109","ARC112","ARC038"
        },
        -- pack #15 in box #33
        [15] = {
            "ARC193","ARC194","ARC190","ARC192","ARC087","ARC043","ARC103","ARC117","ARC068","ARC028","ARC064","ARC027","ARC134","ARC111","ARC149","ARC039","ARC075"
        },
        -- pack #16 in box #33
        [16] = {
            "ARC190","ARC185","ARC197","ARC198","ARC165","ARC127","ARC191","ARC158","ARC068","ARC028","ARC069","ARC099","ARC138","ARC098","ARC139","ARC038","ARC002"
        },
        -- pack #17 in box #33
        [17] = {
            "ARC193","ARC213","ARC217","ARC195","ARC013","ARC054","ARC177","ARC079","ARC068","ARC035","ARC062","ARC034","ARC133","ARC109","ARC137","ARC075","ARC077"
        },
        -- pack #18 in box #33
        [18] = {
            "ARC176","ARC215","ARC195","ARC183","ARC011","ARC051","ARC215","ARC079","ARC070","ARC022","ARC062","ARC022","ARC147","ARC096","ARC141","ARC038","ARC114"
        },
        -- pack #19 in box #33
        [19] = {
            "ARC196","ARC201","ARC198","ARC196","ARC058","ARC130","ARC179","ARC155","ARC069","ARC031","ARC069","ARC098","ARC141","ARC106","ARC141","ARC218"
        },
        -- pack #20 in box #33
        [20] = {
            "ARC211","ARC187","ARC179","ARC194","ARC175","ARC014","ARC148","ARC153","ARC030","ARC074","ARC036","ARC073","ARC098","ARC145","ARC110","ARC112","ARC003"
        },
        -- pack #21 in box #33
        [21] = {
            "ARC194","ARC181","ARC205","ARC212","ARC086","ARC175","ARC210","ARC042","ARC031","ARC067","ARC020","ARC066","ARC096","ARC140","ARC104","ARC076","ARC112"
        },
        -- pack #22 in box #33
        [22] = {
            "ARC199","ARC200","ARC195","ARC203","ARC086","ARC166","ARC176","ARC079","ARC020","ARC070","ARC027","ARC138","ARC100","ARC147","ARC105","ARC077","ARC113"
        },
        -- pack #23 in box #33
        [23] = {
            "ARC185","ARC204","ARC203","ARC201","ARC167","ARC091","ARC060","ARC156","ARC032","ARC068","ARC036","ARC132","ARC100","ARC146","ARC104","ARC114","ARC115"
        },
        -- pack #24 in box #33
        [24] = {
            "ARC190","ARC204","ARC198","ARC216","ARC172","ARC173","ARC046","ARC157","ARC073","ARC020","ARC068","ARC027","ARC139","ARC096","ARC143","ARC113","ARC077"
        },
    },
    -- box #34
    [34] = {
        -- pack #1 in box #34
        [1] = {
            "ARC187","ARC184","ARC192","ARC185","ARC085","ARC167","ARC215","ARC117","ARC070","ARC032","ARC061","ARC020","ARC137","ARC103","ARC134","ARC038","ARC075"
        },
        -- pack #2 in box #34
        [2] = {
            "ARC184","ARC178","ARC188","ARC198","ARC091","ARC083","ARC130","ARC151","ARC021","ARC071","ARC021","ARC071","ARC103","ARC141","ARC107","ARC077","ARC112"
        },
        -- pack #3 in box #34
        [3] = {
            "ARC177","ARC178","ARC185","ARC209","ARC164","ARC160","ARC025","ARC005","ARC072","ARC020","ARC072","ARC033","ARC142","ARC102","ARC146","ARC040","ARC001"
        },
        -- pack #4 in box #34
        [4] = {
            "ARC192","ARC205","ARC209","ARC195","ARC014","ARC087","ARC207","ARC155","ARC074","ARC030","ARC070","ARC097","ARC137","ARC094","ARC137","ARC218"
        },
        -- pack #5 in box #34
        [5] = {
            "ARC203","ARC217","ARC207","ARC216","ARC054","ARC093","ARC066","ARC117","ARC031","ARC062","ARC028","ARC065","ARC097","ARC140","ARC110","ARC002","ARC003"
        },
        -- pack #6 in box #34
        [6] = {
            "ARC187","ARC192","ARC211","ARC198","ARC165","ARC081","ARC162","ARC151","ARC021","ARC065","ARC030","ARC069","ARC095","ARC137","ARC106","ARC218"
        },
        -- pack #7 in box #34
        [7] = {
            "ARC212","ARC178","ARC194","ARC180","ARC173","ARC055","ARC034","ARC153","ARC032","ARC066","ARC022","ARC065","ARC097","ARC149","ARC107","ARC114","ARC113"
        },
        -- pack #8 in box #34
        [8] = {
            "ARC211","ARC215","ARC200","ARC182","ARC011","ARC125","ARC024","ARC042","ARC030","ARC063","ARC030","ARC146","ARC095","ARC138","ARC098","ARC003","ARC038"
        },
        -- pack #9 in box #34
        [9] = {
            "ARC196","ARC195","ARC176","ARC177","ARC012","ARC168","ARC202","ARC151","ARC066","ARC024","ARC066","ARC108","ARC146","ARC103","ARC148","ARC038","ARC040"
        },
        -- pack #10 in box #34
        [10] = {
            "ARC211","ARC187","ARC203","ARC214","ARC175","ARC119","ARC132","ARC042","ARC068","ARC024","ARC062","ARC031","ARC139","ARC094","ARC148","ARC115","ARC075"
        },
        -- pack #11 in box #34
        [11] = {
            "ARC195","ARC195","ARC211","ARC211","ARC165","ARC128","ARC060","ARC156","ARC035","ARC062","ARC021","ARC140","ARC110","ARC140","ARC100","ARC112","ARC115"
        },
        -- pack #12 in box #34
        [12] = {
            "ARC217","ARC195","ARC181","ARC180","ARC126","ARC169","ARC103","ARC079","ARC062","ARC028","ARC068","ARC022","ARC148","ARC109","ARC142","ARC076","ARC039"
        },
        -- pack #13 in box #34
        [13] = {
            "ARC187","ARC190","ARC184","ARC183","ARC059","ARC059","ARC064","ARC151","ARC072","ARC028","ARC069","ARC109","ARC136","ARC109","ARC140","ARC218"
        },
        -- pack #14 in box #34
        [14] = {
            "ARC182","ARC201","ARC203","ARC210","ARC016","ARC053","ARC066","ARC154","ARC025","ARC072","ARC032","ARC065","ARC096","ARC148","ARC104","ARC039","ARC115"
        },
        -- pack #15 in box #34
        [15] = {
            "ARC187","ARC209","ARC176","ARC196","ARC059","ARC167","ARC203","ARC153","ARC065","ARC020","ARC074","ARC103","ARC137","ARC106","ARC136","ARC001","ARC114"
        },
        -- pack #16 in box #34
        [16] = {
            "ARC207","ARC182","ARC217","ARC201","ARC090","ARC087","ARC183","ARC157","ARC029","ARC074","ARC031","ARC143","ARC107","ARC138","ARC105","ARC218"
        },
        -- pack #17 in box #34
        [17] = {
            "ARC183","ARC186","ARC215","ARC193","ARC087","ARC053","ARC027","ARC005","ARC068","ARC035","ARC072","ARC034","ARC144","ARC096","ARC132","ARC113","ARC075"
        },
        -- pack #18 in box #34
        [18] = {
            "ARC189","ARC216","ARC213","ARC178","ARC167","ARC125","ARC029","ARC157","ARC067","ARC029","ARC061","ARC099","ARC138","ARC098","ARC138","ARC113","ARC003"
        },
        -- pack #19 in box #34
        [19] = {
            "ARC203","ARC191","ARC182","ARC203","ARC130","ARC013","ARC175","ARC154","ARC070","ARC022","ARC071","ARC102","ARC132","ARC100","ARC139","ARC113","ARC038"
        },
        -- pack #20 in box #34
        [20] = {
            "ARC201","ARC200","ARC212","ARC203","ARC014","ARC170","ARC044","ARC152","ARC030","ARC074","ARC032","ARC148","ARC097","ARC140","ARC102","ARC077","ARC075"
        },
        -- pack #21 in box #34
        [21] = {
            "ARC177","ARC194","ARC201","ARC211","ARC128","ARC164","ARC031","ARC157","ARC029","ARC065","ARC025","ARC135","ARC097","ARC132","ARC105","ARC112","ARC040"
        },
        -- pack #22 in box #34
        [22] = {
            "ARC197","ARC211","ARC180","ARC194","ARC085","ARC006","ARC099","ARC155","ARC035","ARC060","ARC030","ARC063","ARC105","ARC147","ARC106","ARC076","ARC115"
        },
        -- pack #23 in box #34
        [23] = {
            "ARC203","ARC182","ARC206","ARC196","ARC164","ARC047","ARC202","ARC152","ARC020","ARC074","ARC022","ARC146","ARC095","ARC141","ARC096","ARC112","ARC001"
        },
        -- pack #24 in box #34
        [24] = {
            "ARC189","ARC199","ARC216","ARC197","ARC124","ARC091","ARC216","ARC155","ARC061","ARC032","ARC073","ARC030","ARC142","ARC103","ARC141","ARC076","ARC114"
        },
    },
    -- box #35
    [35] = {
        -- pack #1 in box #35
        [1] = {
            "ARC195","ARC202","ARC179","ARC215","ARC090","ARC050","ARC050","ARC154","ARC063","ARC024","ARC070","ARC110","ARC143","ARC103","ARC136","ARC115","ARC003"
        },
        -- pack #2 in box #35
        [2] = {
            "ARC207","ARC205","ARC196","ARC199","ARC124","ARC125","ARC208","ARC154","ARC031","ARC071","ARC033","ARC136","ARC106","ARC145","ARC107","ARC038","ARC076"
        },
        -- pack #3 in box #35
        [3] = {
            "ARC215","ARC187","ARC214","ARC201","ARC013","ARC015","ARC088","ARC079","ARC033","ARC070","ARC031","ARC063","ARC103","ARC140","ARC100","ARC003","ARC112"
        },
        -- pack #4 in box #35
        [4] = {
            "ARC185","ARC179","ARC191","ARC212","ARC091","ARC175","ARC134","ARC153","ARC060","ARC020","ARC065","ARC028","ARC148","ARC094","ARC144","ARC115","ARC114"
        },
        -- pack #5 in box #35
        [5] = {
            "ARC206","ARC207","ARC196","ARC178","ARC085","ARC011","ARC204","ARC157","ARC026","ARC073","ARC024","ARC070","ARC095","ARC140","ARC103","ARC038","ARC001"
        },
        -- pack #6 in box #35
        [6] = {
            "ARC185","ARC180","ARC183","ARC183","ARC049","ARC084","ARC094","ARC042","ARC033","ARC069","ARC025","ARC060","ARC095","ARC143","ARC099","ARC002","ARC001"
        },
        -- pack #7 in box #35
        [7] = {
            "ARC211","ARC201","ARC189","ARC214","ARC085","ARC050","ARC094","ARC155","ARC034","ARC070","ARC029","ARC139","ARC107","ARC147","ARC105","ARC002","ARC001"
        },
        -- pack #8 in box #35
        [8] = {
            "ARC185","ARC182","ARC185","ARC194","ARC018","ARC011","ARC217","ARC153","ARC067","ARC035","ARC064","ARC025","ARC141","ARC100","ARC133","ARC039","ARC113"
        },
        -- pack #9 in box #35
        [9] = {
            "ARC211","ARC193","ARC183","ARC210","ARC131","ARC049","ARC172","ARC151","ARC034","ARC069","ARC026","ARC140","ARC110","ARC138","ARC096","ARC039","ARC002"
        },
        -- pack #10 in box #35
        [10] = {
            "ARC209","ARC190","ARC208","ARC177","ARC018","ARC015","ARC203","ARC079","ARC065","ARC036","ARC074","ARC103","ARC134","ARC097","ARC132","ARC114","ARC077"
        },
        -- pack #11 in box #35
        [11] = {
            "ARC176","ARC186","ARC189","ARC198","ARC058","ARC175","ARC029","ARC152","ARC020","ARC063","ARC026","ARC135","ARC095","ARC133","ARC106","ARC115","ARC001"
        },
        -- pack #12 in box #35
        [12] = {
            "ARC182","ARC188","ARC211","ARC217","ARC085","ARC085","ARC209","ARC153","ARC062","ARC030","ARC068","ARC109","ARC135","ARC107","ARC137","ARC039","ARC003"
        },
        -- pack #13 in box #35
        [13] = {
            "ARC213","ARC188","ARC178","ARC180","ARC175","ARC051","ARC213","ARC153","ARC063","ARC023","ARC069","ARC023","ARC148","ARC108","ARC140","ARC077","ARC114"
        },
        -- pack #14 in box #35
        [14] = {
            "ARC192","ARC191","ARC212","ARC179","ARC173","ARC018","ARC063","ARC156","ARC067","ARC029","ARC074","ARC110","ARC139","ARC097","ARC148","ARC001","ARC076"
        },
        -- pack #15 in box #35
        [15] = {
            "ARC200","ARC189","ARC188","ARC194","ARC018","ARC056","ARC078","ARC117","ARC062","ARC023","ARC062","ARC031","ARC132","ARC104","ARC133","ARC218"
        },
        -- pack #16 in box #35
        [16] = {
            "ARC187","ARC214","ARC215","ARC179","ARC174","ARC131","ARC213","ARC151","ARC023","ARC069","ARC035","ARC139","ARC108","ARC139","ARC105","ARC112","ARC040"
        },
        -- pack #17 in box #35
        [17] = {
            "ARC200","ARC179","ARC186","ARC199","ARC086","ARC170","ARC098","ARC042","ARC033","ARC069","ARC028","ARC065","ARC101","ARC145","ARC100","ARC040","ARC112"
        },
        -- pack #18 in box #35
        [18] = {
            "ARC211","ARC184","ARC181","ARC210","ARC129","ARC160","ARC182","ARC152","ARC071","ARC036","ARC060","ARC110","ARC145","ARC109","ARC140","ARC115","ARC039"
        },
        -- pack #19 in box #35
        [19] = {
            "ARC196","ARC183","ARC193","ARC211","ARC011","ARC051","ARC126","ARC152","ARC027","ARC064","ARC022","ARC072","ARC104","ARC139","ARC109","ARC113","ARC039"
        },
        -- pack #20 in box #35
        [20] = {
            "ARC176","ARC183","ARC179","ARC208","ARC015","ARC080","ARC137","ARC157","ARC028","ARC060","ARC036","ARC069","ARC110","ARC141","ARC098","ARC038","ARC112"
        },
        -- pack #21 in box #35
        [21] = {
            "ARC206","ARC198","ARC187","ARC198","ARC088","ARC166","ARC143","ARC155","ARC024","ARC067","ARC025","ARC137","ARC107","ARC133","ARC109","ARC077","ARC076"
        },
        -- pack #22 in box #35
        [22] = {
            "ARC204","ARC192","ARC212","ARC200","ARC128","ARC090","ARC155","ARC158","ARC071","ARC034","ARC074","ARC035","ARC137","ARC095","ARC132","ARC077","ARC075"
        },
        -- pack #23 in box #35
        [23] = {
            "ARC196","ARC182","ARC205","ARC179","ARC125","ARC047","ARC215","ARC157","ARC066","ARC034","ARC065","ARC110","ARC144","ARC095","ARC140","ARC112","ARC039"
        },
        -- pack #24 in box #35
        [24] = {
            "ARC216","ARC206","ARC209","ARC188","ARC165","ARC093","ARC093","ARC153","ARC068","ARC025","ARC072","ARC037","ARC135","ARC104","ARC145","ARC077","ARC038"
        },
    },
    -- box #36
    [36] = {
        -- pack #1 in box #36
        [1] = {
            "ARC184","ARC215","ARC199","ARC181","ARC165","ARC059","ARC207","ARC079","ARC032","ARC063","ARC020","ARC137","ARC095","ARC133","ARC109","ARC002","ARC040"
        },
        -- pack #2 in box #36
        [2] = {
            "ARC182","ARC177","ARC205","ARC208","ARC052","ARC057","ARC031","ARC158","ARC073","ARC021","ARC069","ARC111","ARC133","ARC095","ARC141","ARC039","ARC112"
        },
        -- pack #3 in box #36
        [3] = {
            "ARC176","ARC213","ARC194","ARC181","ARC172","ARC093","ARC187","ARC151","ARC026","ARC063","ARC028","ARC137","ARC105","ARC136","ARC107","ARC039","ARC076"
        },
        -- pack #4 in box #36
        [4] = {
            "ARC205","ARC201","ARC201","ARC181","ARC089","ARC087","ARC095","ARC005","ARC068","ARC021","ARC061","ARC100","ARC146","ARC105","ARC135","ARC003","ARC075"
        },
        -- pack #5 in box #36
        [5] = {
            "ARC178","ARC177","ARC203","ARC199","ARC174","ARC051","ARC196","ARC156","ARC073","ARC028","ARC063","ARC023","ARC144","ARC096","ARC142","ARC039","ARC038"
        },
        -- pack #6 in box #36
        [6] = {
            "ARC191","ARC182","ARC196","ARC206","ARC089","ARC009","ARC101","ARC155","ARC063","ARC022","ARC062","ARC104","ARC138","ARC100","ARC134","ARC075","ARC002"
        },
        -- pack #7 in box #36
        [7] = {
            "ARC215","ARC214","ARC203","ARC182","ARC168","ARC013","ARC187","ARC151","ARC022","ARC073","ARC020","ARC061","ARC103","ARC132","ARC097","ARC002","ARC038"
        },
        -- pack #8 in box #36
        [8] = {
            "ARC204","ARC188","ARC197","ARC211","ARC128","ARC054","ARC171","ARC152","ARC028","ARC070","ARC032","ARC062","ARC097","ARC141","ARC110","ARC112","ARC002"
        },
        -- pack #9 in box #36
        [9] = {
            "ARC204","ARC183","ARC190","ARC202","ARC130","ARC010","ARC026","ARC156","ARC074","ARC034","ARC063","ARC100","ARC140","ARC107","ARC147","ARC075","ARC040"
        },
        -- pack #10 in box #36
        [10] = {
            "ARC178","ARC180","ARC217","ARC205","ARC013","ARC012","ARC053","ARC117","ARC060","ARC020","ARC074","ARC031","ARC143","ARC108","ARC146","ARC115","ARC075"
        },
        -- pack #11 in box #36
        [11] = {
            "ARC204","ARC176","ARC185","ARC195","ARC169","ARC171","ARC035","ARC156","ARC068","ARC029","ARC062","ARC029","ARC136","ARC099","ARC139","ARC112","ARC077"
        },
        -- pack #12 in box #36
        [12] = {
            "ARC207","ARC196","ARC203","ARC213","ARC165","ARC018","ARC170","ARC156","ARC022","ARC071","ARC024","ARC143","ARC107","ARC134","ARC111","ARC038","ARC002"
        },
        -- pack #13 in box #36
        [13] = {
            "ARC186","ARC197","ARC193","ARC176","ARC129","ARC165","ARC133","ARC156","ARC033","ARC066","ARC037","ARC060","ARC100","ARC132","ARC097","ARC039","ARC112"
        },
        -- pack #14 in box #36
        [14] = {
            "ARC188","ARC184","ARC178","ARC204","ARC173","ARC084","ARC148","ARC042","ARC060","ARC031","ARC070","ARC106","ARC136","ARC100","ARC136","ARC001","ARC039"
        },
        -- pack #15 in box #36
        [15] = {
            "ARC202","ARC203","ARC180","ARC198","ARC128","ARC129","ARC136","ARC154","ARC068","ARC021","ARC069","ARC034","ARC142","ARC103","ARC137","ARC115","ARC038"
        },
        -- pack #16 in box #36
        [16] = {
            "ARC199","ARC179","ARC198","ARC201","ARC086","ARC017","ARC078","ARC042","ARC060","ARC020","ARC068","ARC023","ARC143","ARC107","ARC148","ARC038","ARC115"
        },
        -- pack #17 in box #36
        [17] = {
            "ARC216","ARC210","ARC199","ARC181","ARC124","ARC006","ARC185","ARC153","ARC022","ARC067","ARC026","ARC060","ARC108","ARC133","ARC111","ARC039","ARC112"
        },
        -- pack #18 in box #36
        [18] = {
            "ARC204","ARC207","ARC184","ARC210","ARC167","ARC048","ARC030","ARC079","ARC036","ARC063","ARC022","ARC069","ARC100","ARC147","ARC104","ARC115","ARC076"
        },
        -- pack #19 in box #36
        [19] = {
            "ARC182","ARC201","ARC199","ARC201","ARC059","ARC173","ARC144","ARC042","ARC031","ARC070","ARC020","ARC138","ARC097","ARC132","ARC097","ARC076","ARC077"
        },
        -- pack #20 in box #36
        [20] = {
            "ARC198","ARC209","ARC189","ARC195","ARC056","ARC128","ARC205","ARC042","ARC036","ARC061","ARC025","ARC137","ARC098","ARC133","ARC111","ARC077","ARC040"
        },
        -- pack #21 in box #36
        [21] = {
            "ARC179","ARC182","ARC211","ARC208","ARC052","ARC166","ARC063","ARC151","ARC032","ARC073","ARC023","ARC134","ARC096","ARC132","ARC098","ARC001","ARC075"
        },
        -- pack #22 in box #36
        [22] = {
            "ARC197","ARC207","ARC217","ARC180","ARC168","ARC013","ARC131","ARC155","ARC064","ARC025","ARC063","ARC095","ARC135","ARC096","ARC147","ARC115","ARC076"
        },
        -- pack #23 in box #36
        [23] = {
            "ARC198","ARC205","ARC213","ARC182","ARC164","ARC164","ARC147","ARC153","ARC028","ARC074","ARC023","ARC065","ARC098","ARC143","ARC097","ARC112","ARC040"
        },
        -- pack #24 in box #36
        [24] = {
            "ARC181","ARC197","ARC187","ARC193","ARC015","ARC009","ARC079","ARC005","ARC069","ARC037","ARC063","ARC035","ARC142","ARC108","ARC149","ARC001","ARC112"
        },
    },
    -- box #37
    [37] = {
        -- pack #1 in box #37
        [1] = {
            "ARC191","ARC187","ARC213","ARC196","ARC167","ARC051","ARC201","ARC117","ARC021","ARC068","ARC034","ARC135","ARC100","ARC134","ARC109","ARC112","ARC076"
        },
        -- pack #2 in box #37
        [2] = {
            "ARC210","ARC187","ARC191","ARC185","ARC051","ARC054","ARC091","ARC154","ARC062","ARC032","ARC073","ARC025","ARC137","ARC108","ARC143","ARC075","ARC039"
        },
        -- pack #3 in box #37
        [3] = {
            "ARC186","ARC195","ARC186","ARC207","ARC054","ARC123","ARC168","ARC151","ARC036","ARC066","ARC031","ARC063","ARC094","ARC148","ARC096","ARC002","ARC112"
        },
        -- pack #4 in box #37
        [4] = {
            "ARC185","ARC198","ARC200","ARC182","ARC056","ARC121","ARC107","ARC152","ARC023","ARC073","ARC025","ARC135","ARC106","ARC137","ARC108","ARC113","ARC038"
        },
        -- pack #5 in box #37
        [5] = {
            "ARC193","ARC180","ARC216","ARC179","ARC016","ARC121","ARC217","ARC158","ARC029","ARC061","ARC028","ARC063","ARC103","ARC140","ARC104","ARC113","ARC076"
        },
        -- pack #6 in box #37
        [6] = {
            "ARC189","ARC195","ARC185","ARC200","ARC019","ARC125","ARC204","ARC158","ARC025","ARC068","ARC020","ARC062","ARC097","ARC135","ARC096","ARC077","ARC001"
        },
        -- pack #7 in box #37
        [7] = {
            "ARC197","ARC192","ARC199","ARC180","ARC011","ARC082","ARC146","ARC152","ARC031","ARC063","ARC037","ARC067","ARC107","ARC137","ARC111","ARC114","ARC039"
        },
        -- pack #8 in box #37
        [8] = {
            "ARC215","ARC194","ARC208","ARC184","ARC014","ARC058","ARC111","ARC117","ARC070","ARC030","ARC066","ARC101","ARC149","ARC095","ARC134","ARC040","ARC038"
        },
        -- pack #9 in box #37
        [9] = {
            "ARC206","ARC214","ARC216","ARC209","ARC086","ARC131","ARC145","ARC155","ARC072","ARC036","ARC060","ARC106","ARC144","ARC097","ARC147","ARC076","ARC001"
        },
        -- pack #10 in box #37
        [10] = {
            "ARC176","ARC179","ARC191","ARC190","ARC015","ARC080","ARC024","ARC151","ARC070","ARC037","ARC071","ARC031","ARC149","ARC105","ARC134","ARC001","ARC040"
        },
        -- pack #11 in box #37
        [11] = {
            "ARC181","ARC184","ARC176","ARC176","ARC085","ARC169","ARC105","ARC154","ARC065","ARC037","ARC069","ARC107","ARC137","ARC094","ARC142","ARC002","ARC115"
        },
        -- pack #12 in box #37
        [12] = {
            "ARC191","ARC213","ARC213","ARC209","ARC015","ARC015","ARC017","ARC117","ARC070","ARC028","ARC070","ARC036","ARC135","ARC094","ARC142","ARC115","ARC114"
        },
        -- pack #13 in box #37
        [13] = {
            "ARC180","ARC208","ARC199","ARC198","ARC124","ARC080","ARC086","ARC005","ARC070","ARC024","ARC061","ARC100","ARC138","ARC109","ARC138","ARC039","ARC001"
        },
        -- pack #14 in box #37
        [14] = {
            "ARC201","ARC214","ARC179","ARC209","ARC172","ARC090","ARC155","ARC042","ARC033","ARC060","ARC030","ARC146","ARC099","ARC144","ARC099","ARC077","ARC039"
        },
        -- pack #15 in box #37
        [15] = {
            "ARC192","ARC195","ARC204","ARC212","ARC088","ARC122","ARC136","ARC079","ARC073","ARC033","ARC061","ARC094","ARC135","ARC098","ARC145","ARC038","ARC001"
        },
        -- pack #16 in box #37
        [16] = {
            "ARC208","ARC186","ARC214","ARC176","ARC013","ARC087","ARC197","ARC158","ARC033","ARC064","ARC029","ARC066","ARC106","ARC142","ARC110","ARC038","ARC003"
        },
        -- pack #17 in box #37
        [17] = {
            "ARC217","ARC207","ARC182","ARC204","ARC093","ARC127","ARC085","ARC153","ARC025","ARC073","ARC034","ARC135","ARC098","ARC141","ARC107","ARC075","ARC112"
        },
        -- pack #18 in box #37
        [18] = {
            "ARC216","ARC192","ARC216","ARC176","ARC012","ARC016","ARC018","ARC079","ARC060","ARC023","ARC069","ARC025","ARC133","ARC108","ARC134","ARC113","ARC115"
        },
        -- pack #19 in box #37
        [19] = {
            "ARC200","ARC213","ARC199","ARC184","ARC129","ARC164","ARC060","ARC155","ARC036","ARC064","ARC026","ARC135","ARC110","ARC149","ARC111","ARC115","ARC075"
        },
        -- pack #20 in box #37
        [20] = {
            "ARC177","ARC192","ARC185","ARC205","ARC017","ARC046","ARC183","ARC155","ARC035","ARC062","ARC029","ARC140","ARC103","ARC149","ARC097","ARC115","ARC076"
        },
        -- pack #21 in box #37
        [21] = {
            "ARC211","ARC212","ARC180","ARC209","ARC015","ARC018","ARC074","ARC158","ARC023","ARC066","ARC031","ARC062","ARC110","ARC141","ARC100","ARC077","ARC114"
        },
        -- pack #22 in box #37
        [22] = {
            "ARC203","ARC198","ARC187","ARC180","ARC013","ARC019","ARC033","ARC042","ARC066","ARC024","ARC071","ARC026","ARC144","ARC102","ARC145","ARC112","ARC113"
        },
        -- pack #23 in box #37
        [23] = {
            "ARC196","ARC193","ARC211","ARC192","ARC053","ARC046","ARC195","ARC079","ARC074","ARC024","ARC069","ARC022","ARC135","ARC105","ARC144","ARC076","ARC002"
        },
        -- pack #24 in box #37
        [24] = {
            "ARC214","ARC185","ARC183","ARC197","ARC057","ARC128","ARC061","ARC158","ARC062","ARC026","ARC071","ARC107","ARC138","ARC110","ARC133","ARC038","ARC039"
        },
    },
    -- box #38
    [38] = {
        -- pack #1 in box #38
        [1] = {
            "ARC194","ARC187","ARC193","ARC201","ARC168","ARC082","ARC014","ARC042","ARC062","ARC035","ARC067","ARC036","ARC136","ARC100","ARC149","ARC039","ARC113"
        },
        -- pack #2 in box #38
        [2] = {
            "ARC183","ARC198","ARC198","ARC217","ARC126","ARC090","ARC102","ARC152","ARC066","ARC036","ARC070","ARC104","ARC137","ARC095","ARC139","ARC003","ARC040"
        },
        -- pack #3 in box #38
        [3] = {
            "ARC214","ARC191","ARC206","ARC200","ARC012","ARC084","ARC055","ARC042","ARC065","ARC022","ARC072","ARC024","ARC140","ARC094","ARC147","ARC114","ARC077"
        },
        -- pack #4 in box #38
        [4] = {
            "ARC196","ARC190","ARC188","ARC207","ARC050","ARC044","ARC196","ARC155","ARC074","ARC027","ARC064","ARC101","ARC146","ARC106","ARC148","ARC115","ARC075"
        },
        -- pack #5 in box #38
        [5] = {
            "ARC205","ARC202","ARC209","ARC202","ARC017","ARC006","ARC062","ARC157","ARC035","ARC064","ARC034","ARC146","ARC109","ARC147","ARC108","ARC114","ARC001"
        },
        -- pack #6 in box #38
        [6] = {
            "ARC179","ARC216","ARC210","ARC210","ARC048","ARC008","ARC079","ARC117","ARC023","ARC074","ARC036","ARC066","ARC107","ARC136","ARC111","ARC112","ARC113"
        },
        -- pack #7 in box #38
        [7] = {
            "ARC188","ARC179","ARC204","ARC193","ARC055","ARC122","ARC027","ARC005","ARC026","ARC063","ARC024","ARC065","ARC106","ARC149","ARC096","ARC112","ARC001"
        },
        -- pack #8 in box #38
        [8] = {
            "ARC198","ARC177","ARC198","ARC216","ARC129","ARC086","ARC203","ARC154","ARC066","ARC032","ARC073","ARC098","ARC141","ARC107","ARC136","ARC075","ARC113"
        },
        -- pack #9 in box #38
        [9] = {
            "ARC200","ARC212","ARC182","ARC189","ARC165","ARC092","ARC193","ARC117","ARC068","ARC028","ARC064","ARC105","ARC132","ARC099","ARC132","ARC039","ARC002"
        },
        -- pack #10 in box #38
        [10] = {
            "ARC214","ARC196","ARC210","ARC201","ARC055","ARC054","ARC202","ARC156","ARC023","ARC064","ARC029","ARC065","ARC106","ARC136","ARC103","ARC113","ARC076"
        },
        -- pack #11 in box #38
        [11] = {
            "ARC210","ARC176","ARC193","ARC210","ARC127","ARC131","ARC068","ARC005","ARC074","ARC034","ARC072","ARC111","ARC133","ARC102","ARC136","ARC039","ARC113"
        },
        -- pack #12 in box #38
        [12] = {
            "ARC180","ARC182","ARC176","ARC204","ARC124","ARC127","ARC214","ARC158","ARC068","ARC036","ARC074","ARC023","ARC140","ARC097","ARC135","ARC039","ARC001"
        },
        -- pack #13 in box #38
        [13] = {
            "ARC209","ARC203","ARC196","ARC216","ARC049","ARC008","ARC195","ARC005","ARC035","ARC065","ARC035","ARC136","ARC097","ARC149","ARC100","ARC112","ARC075"
        },
        -- pack #14 in box #38
        [14] = {
            "ARC215","ARC176","ARC202","ARC215","ARC092","ARC162","ARC100","ARC157","ARC064","ARC027","ARC073","ARC023","ARC133","ARC099","ARC136","ARC002","ARC113"
        },
        -- pack #15 in box #38
        [15] = {
            "ARC180","ARC196","ARC214","ARC189","ARC170","ARC124","ARC107","ARC042","ARC022","ARC074","ARC032","ARC135","ARC097","ARC143","ARC111","ARC040","ARC001"
        },
        -- pack #16 in box #38
        [16] = {
            "ARC214","ARC216","ARC203","ARC183","ARC169","ARC129","ARC096","ARC158","ARC062","ARC033","ARC072","ARC108","ARC134","ARC095","ARC137","ARC001","ARC002"
        },
        -- pack #17 in box #38
        [17] = {
            "ARC204","ARC211","ARC182","ARC203","ARC014","ARC093","ARC015","ARC005","ARC028","ARC068","ARC035","ARC140","ARC104","ARC137","ARC103","ARC076","ARC040"
        },
        -- pack #18 in box #38
        [18] = {
            "ARC182","ARC177","ARC199","ARC191","ARC018","ARC049","ARC198","ARC154","ARC064","ARC025","ARC066","ARC028","ARC149","ARC099","ARC137","ARC003","ARC076"
        },
        -- pack #19 in box #38
        [19] = {
            "ARC198","ARC204","ARC184","ARC200","ARC170","ARC124","ARC200","ARC153","ARC025","ARC068","ARC031","ARC137","ARC105","ARC140","ARC103","ARC002","ARC001"
        },
        -- pack #20 in box #38
        [20] = {
            "ARC194","ARC185","ARC187","ARC200","ARC126","ARC123","ARC216","ARC117","ARC022","ARC061","ARC026","ARC137","ARC105","ARC137","ARC103","ARC114","ARC003"
        },
        -- pack #21 in box #38
        [21] = {
            "ARC217","ARC209","ARC184","ARC205","ARC167","ARC055","ARC029","ARC152","ARC028","ARC062","ARC027","ARC065","ARC102","ARC138","ARC105","ARC114","ARC075"
        },
        -- pack #22 in box #38
        [22] = {
            "ARC215","ARC177","ARC177","ARC196","ARC088","ARC044","ARC010","ARC156","ARC020","ARC072","ARC031","ARC067","ARC105","ARC139","ARC109","ARC077","ARC039"
        },
        -- pack #23 in box #38
        [23] = {
            "ARC212","ARC195","ARC214","ARC210","ARC012","ARC172","ARC037","ARC117","ARC074","ARC027","ARC073","ARC024","ARC136","ARC101","ARC147","ARC113","ARC038"
        },
        -- pack #24 in box #38
        [24] = {
            "ARC194","ARC179","ARC214","ARC176","ARC019","ARC168","ARC206","ARC154","ARC025","ARC069","ARC036","ARC074","ARC107","ARC146","ARC103","ARC114","ARC075"
        },
    },
    -- box #39
    [39] = {
        -- pack #1 in box #39
        [1] = {
            "ARC202","ARC177","ARC187","ARC203","ARC172","ARC052","ARC203","ARC005","ARC069","ARC022","ARC062","ARC028","ARC134","ARC103","ARC136","ARC113","ARC114"
        },
        -- pack #2 in box #39
        [2] = {
            "ARC185","ARC183","ARC217","ARC195","ARC171","ARC049","ARC070","ARC079","ARC061","ARC027","ARC074","ARC101","ARC148","ARC095","ARC134","ARC040","ARC114"
        },
        -- pack #3 in box #39
        [3] = {
            "ARC211","ARC192","ARC214","ARC184","ARC172","ARC121","ARC181","ARC153","ARC020","ARC062","ARC028","ARC068","ARC097","ARC142","ARC105","ARC218"
        },
        -- pack #4 in box #39
        [4] = {
            "ARC195","ARC180","ARC197","ARC186","ARC017","ARC056","ARC135","ARC079","ARC022","ARC072","ARC030","ARC074","ARC108","ARC134","ARC111","ARC114","ARC039"
        },
        -- pack #5 in box #39
        [5] = {
            "ARC209","ARC203","ARC176","ARC213","ARC013","ARC082","ARC089","ARC153","ARC062","ARC027","ARC063","ARC029","ARC137","ARC103","ARC146","ARC040","ARC115"
        },
        -- pack #6 in box #39
        [6] = {
            "ARC198","ARC197","ARC178","ARC187","ARC126","ARC049","ARC109","ARC151","ARC031","ARC062","ARC023","ARC136","ARC101","ARC143","ARC095","ARC003","ARC075"
        },
        -- pack #7 in box #39
        [7] = {
            "ARC179","ARC194","ARC211","ARC190","ARC171","ARC173","ARC213","ARC042","ARC069","ARC021","ARC061","ARC025","ARC149","ARC099","ARC132","ARC039","ARC001"
        },
        -- pack #8 in box #39
        [8] = {
            "ARC187","ARC208","ARC209","ARC187","ARC055","ARC056","ARC183","ARC156","ARC061","ARC035","ARC072","ARC033","ARC145","ARC101","ARC134","ARC076","ARC039"
        },
        -- pack #9 in box #39
        [9] = {
            "ARC217","ARC192","ARC196","ARC187","ARC130","ARC161","ARC157","ARC156","ARC034","ARC068","ARC036","ARC060","ARC110","ARC146","ARC108","ARC112","ARC113"
        },
        -- pack #10 in box #39
        [10] = {
            "ARC214","ARC191","ARC178","ARC194","ARC127","ARC161","ARC111","ARC079","ARC021","ARC071","ARC023","ARC149","ARC111","ARC148","ARC102","ARC076","ARC115"
        },
        -- pack #11 in box #39
        [11] = {
            "ARC212","ARC194","ARC204","ARC215","ARC014","ARC015","ARC095","ARC153","ARC028","ARC065","ARC024","ARC142","ARC109","ARC144","ARC094","ARC039","ARC038"
        },
        -- pack #12 in box #39
        [12] = {
            "ARC176","ARC199","ARC185","ARC200","ARC126","ARC083","ARC206","ARC152","ARC028","ARC074","ARC027","ARC148","ARC105","ARC144","ARC109","ARC002","ARC113"
        },
        -- pack #13 in box #39
        [13] = {
            "ARC198","ARC196","ARC213","ARC194","ARC087","ARC018","ARC136","ARC158","ARC063","ARC031","ARC068","ARC098","ARC138","ARC097","ARC133","ARC077","ARC115"
        },
        -- pack #14 in box #39
        [14] = {
            "ARC184","ARC180","ARC183","ARC197","ARC087","ARC016","ARC094","ARC079","ARC066","ARC020","ARC061","ARC110","ARC134","ARC101","ARC132","ARC114","ARC038"
        },
        -- pack #15 in box #39
        [15] = {
            "ARC206","ARC190","ARC178","ARC183","ARC018","ARC173","ARC024","ARC151","ARC037","ARC071","ARC037","ARC148","ARC097","ARC138","ARC103","ARC113","ARC115"
        },
        -- pack #16 in box #39
        [16] = {
            "ARC202","ARC186","ARC211","ARC180","ARC165","ARC090","ARC022","ARC157","ARC073","ARC035","ARC064","ARC037","ARC134","ARC097","ARC139","ARC039","ARC002"
        },
        -- pack #17 in box #39
        [17] = {
            "ARC209","ARC180","ARC206","ARC178","ARC123","ARC168","ARC134","ARC155","ARC060","ARC031","ARC072","ARC105","ARC132","ARC103","ARC133","ARC002","ARC112"
        },
        -- pack #18 in box #39
        [18] = {
            "ARC191","ARC214","ARC191","ARC202","ARC052","ARC049","ARC182","ARC155","ARC021","ARC072","ARC029","ARC070","ARC106","ARC137","ARC099","ARC077","ARC115"
        },
        -- pack #19 in box #39
        [19] = {
            "ARC176","ARC215","ARC183","ARC211","ARC129","ARC090","ARC179","ARC042","ARC022","ARC067","ARC027","ARC068","ARC095","ARC137","ARC095","ARC077","ARC113"
        },
        -- pack #20 in box #39
        [20] = {
            "ARC178","ARC182","ARC214","ARC180","ARC085","ARC170","ARC073","ARC157","ARC037","ARC066","ARC021","ARC060","ARC100","ARC147","ARC111","ARC077","ARC113"
        },
        -- pack #21 in box #39
        [21] = {
            "ARC203","ARC184","ARC215","ARC201","ARC164","ARC170","ARC152","ARC079","ARC061","ARC022","ARC060","ARC026","ARC136","ARC101","ARC146","ARC038","ARC077"
        },
        -- pack #22 in box #39
        [22] = {
            "ARC195","ARC181","ARC195","ARC187","ARC164","ARC086","ARC027","ARC042","ARC067","ARC035","ARC074","ARC111","ARC143","ARC111","ARC142","ARC040","ARC039"
        },
        -- pack #23 in box #39
        [23] = {
            "ARC217","ARC193","ARC179","ARC192","ARC019","ARC015","ARC109","ARC152","ARC034","ARC070","ARC022","ARC136","ARC095","ARC143","ARC106","ARC003","ARC040"
        },
        -- pack #24 in box #39
        [24] = {
            "ARC203","ARC200","ARC209","ARC190","ARC089","ARC057","ARC156","ARC152","ARC074","ARC034","ARC061","ARC101","ARC136","ARC099","ARC147","ARC040","ARC076"
        },
    },
    -- box #40
    [40] = {
        -- pack #1 in box #40
        [1] = {
            "ARC208","ARC176","ARC177","ARC176","ARC126","ARC130","ARC198","ARC155","ARC031","ARC065","ARC022","ARC065","ARC101","ARC148","ARC100","ARC115","ARC001"
        },
        -- pack #2 in box #40
        [2] = {
            "ARC186","ARC202","ARC184","ARC217","ARC053","ARC174","ARC136","ARC157","ARC033","ARC074","ARC031","ARC137","ARC102","ARC136","ARC107","ARC075","ARC113"
        },
        -- pack #3 in box #40
        [3] = {
            "ARC181","ARC176","ARC202","ARC206","ARC052","ARC047","ARC020","ARC117","ARC069","ARC029","ARC069","ARC108","ARC136","ARC101","ARC149","ARC075","ARC115"
        },
        -- pack #4 in box #40
        [4] = {
            "ARC179","ARC201","ARC191","ARC203","ARC048","ARC059","ARC019","ARC154","ARC032","ARC062","ARC033","ARC139","ARC101","ARC147","ARC101","ARC113","ARC039"
        },
        -- pack #5 in box #40
        [5] = {
            "ARC190","ARC205","ARC208","ARC212","ARC175","ARC086","ARC145","ARC005","ARC071","ARC037","ARC073","ARC034","ARC149","ARC098","ARC141","ARC112","ARC075"
        },
        -- pack #6 in box #40
        [6] = {
            "ARC185","ARC193","ARC202","ARC212","ARC012","ARC049","ARC190","ARC117","ARC023","ARC065","ARC029","ARC133","ARC097","ARC147","ARC101","ARC114","ARC075"
        },
        -- pack #7 in box #40
        [7] = {
            "ARC187","ARC200","ARC183","ARC201","ARC124","ARC080","ARC064","ARC042","ARC064","ARC026","ARC060","ARC103","ARC143","ARC106","ARC142","ARC040","ARC077"
        },
        -- pack #8 in box #40
        [8] = {
            "ARC205","ARC191","ARC197","ARC194","ARC169","ARC118","ARC121","ARC157","ARC023","ARC068","ARC029","ARC147","ARC105","ARC144","ARC110","ARC002","ARC114"
        },
        -- pack #9 in box #40
        [9] = {
            "ARC187","ARC201","ARC191","ARC188","ARC058","ARC046","ARC123","ARC156","ARC073","ARC032","ARC073","ARC095","ARC135","ARC110","ARC134","ARC112","ARC001"
        },
        -- pack #10 in box #40
        [10] = {
            "ARC190","ARC181","ARC207","ARC199","ARC124","ARC054","ARC164","ARC042","ARC067","ARC022","ARC061","ARC097","ARC138","ARC105","ARC138","ARC040","ARC112"
        },
        -- pack #11 in box #40
        [11] = {
            "ARC215","ARC186","ARC199","ARC196","ARC168","ARC017","ARC084","ARC157","ARC029","ARC069","ARC036","ARC070","ARC100","ARC134","ARC107","ARC039","ARC002"
        },
        -- pack #12 in box #40
        [12] = {
            "ARC192","ARC203","ARC209","ARC179","ARC012","ARC012","ARC097","ARC157","ARC066","ARC022","ARC067","ARC037","ARC144","ARC094","ARC133","ARC002","ARC003"
        },
        -- pack #13 in box #40
        [13] = {
            "ARC183","ARC195","ARC202","ARC213","ARC172","ARC058","ARC202","ARC042","ARC036","ARC067","ARC032","ARC074","ARC108","ARC138","ARC108","ARC077","ARC039"
        },
        -- pack #14 in box #40
        [14] = {
            "ARC178","ARC200","ARC207","ARC182","ARC173","ARC169","ARC142","ARC157","ARC064","ARC029","ARC070","ARC109","ARC132","ARC095","ARC140","ARC002","ARC075"
        },
        -- pack #15 in box #40
        [15] = {
            "ARC196","ARC190","ARC189","ARC187","ARC089","ARC165","ARC097","ARC117","ARC065","ARC026","ARC064","ARC028","ARC149","ARC101","ARC138","ARC003","ARC077"
        },
        -- pack #16 in box #40
        [16] = {
            "ARC176","ARC176","ARC191","ARC199","ARC012","ARC017","ARC199","ARC158","ARC025","ARC071","ARC024","ARC060","ARC108","ARC135","ARC105","ARC113","ARC039"
        },
        -- pack #17 in box #40
        [17] = {
            "ARC186","ARC183","ARC197","ARC208","ARC011","ARC083","ARC189","ARC005","ARC023","ARC064","ARC026","ARC141","ARC109","ARC138","ARC095","ARC040","ARC113"
        },
        -- pack #18 in box #40
        [18] = {
            "ARC203","ARC190","ARC177","ARC203","ARC165","ARC090","ARC206","ARC005","ARC074","ARC033","ARC071","ARC035","ARC137","ARC096","ARC141","ARC001","ARC038"
        },
        -- pack #19 in box #40
        [19] = {
            "ARC191","ARC214","ARC213","ARC208","ARC053","ARC166","ARC190","ARC042","ARC033","ARC065","ARC032","ARC060","ARC103","ARC146","ARC100","ARC115","ARC114"
        },
        -- pack #20 in box #40
        [20] = {
            "ARC186","ARC186","ARC208","ARC215","ARC131","ARC168","ARC189","ARC153","ARC032","ARC074","ARC032","ARC147","ARC096","ARC147","ARC109","ARC001","ARC113"
        },
        -- pack #21 in box #40
        [21] = {
            "ARC201","ARC215","ARC176","ARC196","ARC052","ARC128","ARC100","ARC042","ARC067","ARC022","ARC073","ARC027","ARC136","ARC098","ARC140","ARC218"
        },
        -- pack #22 in box #40
        [22] = {
            "ARC176","ARC205","ARC201","ARC176","ARC055","ARC059","ARC167","ARC005","ARC024","ARC066","ARC032","ARC068","ARC098","ARC144","ARC097","ARC112","ARC039"
        },
        -- pack #23 in box #40
        [23] = {
            "ARC189","ARC187","ARC177","ARC197","ARC016","ARC168","ARC157","ARC153","ARC070","ARC030","ARC064","ARC100","ARC136","ARC096","ARC142","ARC001","ARC077"
        },
        -- pack #24 in box #40
        [24] = {
            "ARC204","ARC200","ARC181","ARC214","ARC093","ARC016","ARC030","ARC153","ARC065","ARC026","ARC064","ARC026","ARC140","ARC103","ARC147","ARC001","ARC075"
        },
    },
    -- box #41
    [41] = {
        -- pack #1 in box #41
        [1] = {
            "ARC212","ARC177","ARC183","ARC184","ARC057","ARC093","ARC103","ARC158","ARC022","ARC066","ARC037","ARC068","ARC099","ARC144","ARC103","ARC077","ARC003"
        },
        -- pack #2 in box #41
        [2] = {
            "ARC184","ARC211","ARC189","ARC213","ARC052","ARC171","ARC193","ARC079","ARC061","ARC031","ARC067","ARC102","ARC140","ARC097","ARC139","ARC038","ARC076"
        },
        -- pack #3 in box #41
        [3] = {
            "ARC189","ARC213","ARC191","ARC192","ARC127","ARC172","ARC144","ARC153","ARC070","ARC028","ARC067","ARC097","ARC139","ARC096","ARC138","ARC113","ARC001"
        },
        -- pack #4 in box #41
        [4] = {
            "ARC204","ARC204","ARC217","ARC195","ARC085","ARC054","ARC032","ARC158","ARC071","ARC030","ARC071","ARC027","ARC144","ARC103","ARC132","ARC115","ARC077"
        },
        -- pack #5 in box #41
        [5] = {
            "ARC215","ARC196","ARC181","ARC178","ARC089","ARC007","ARC208","ARC155","ARC030","ARC071","ARC035","ARC148","ARC100","ARC134","ARC109","ARC002","ARC112"
        },
        -- pack #6 in box #41
        [6] = {
            "ARC192","ARC180","ARC210","ARC186","ARC088","ARC122","ARC100","ARC156","ARC061","ARC025","ARC074","ARC035","ARC143","ARC094","ARC132","ARC002","ARC039"
        },
        -- pack #7 in box #41
        [7] = {
            "ARC196","ARC189","ARC182","ARC177","ARC174","ARC019","ARC028","ARC155","ARC034","ARC062","ARC031","ARC068","ARC107","ARC133","ARC102","ARC002","ARC003"
        },
        -- pack #8 in box #41
        [8] = {
            "ARC208","ARC187","ARC203","ARC215","ARC165","ARC013","ARC202","ARC153","ARC071","ARC026","ARC074","ARC034","ARC138","ARC110","ARC137","ARC115","ARC038"
        },
        -- pack #9 in box #41
        [9] = {
            "ARC217","ARC188","ARC202","ARC177","ARC056","ARC045","ARC178","ARC152","ARC034","ARC071","ARC024","ARC143","ARC100","ARC141","ARC107","ARC038","ARC115"
        },
        -- pack #10 in box #41
        [10] = {
            "ARC200","ARC186","ARC185","ARC202","ARC088","ARC166","ARC078","ARC005","ARC031","ARC070","ARC030","ARC069","ARC101","ARC140","ARC099","ARC077","ARC114"
        },
        -- pack #11 in box #41
        [11] = {
            "ARC188","ARC208","ARC209","ARC203","ARC126","ARC014","ARC006","ARC152","ARC022","ARC072","ARC020","ARC148","ARC106","ARC139","ARC097","ARC002","ARC075"
        },
        -- pack #12 in box #41
        [12] = {
            "ARC181","ARC185","ARC193","ARC198","ARC174","ARC121","ARC191","ARC158","ARC072","ARC032","ARC067","ARC106","ARC136","ARC096","ARC143","ARC039","ARC003"
        },
        -- pack #13 in box #41
        [13] = {
            "ARC208","ARC188","ARC178","ARC197","ARC059","ARC127","ARC198","ARC155","ARC072","ARC020","ARC070","ARC095","ARC134","ARC104","ARC145","ARC115","ARC001"
        },
        -- pack #14 in box #41
        [14] = {
            "ARC189","ARC215","ARC181","ARC204","ARC124","ARC052","ARC020","ARC152","ARC072","ARC037","ARC061","ARC036","ARC134","ARC107","ARC146","ARC075","ARC040"
        },
        -- pack #15 in box #41
        [15] = {
            "ARC193","ARC189","ARC182","ARC217","ARC057","ARC173","ARC026","ARC153","ARC060","ARC027","ARC073","ARC107","ARC147","ARC096","ARC148","ARC001","ARC076"
        },
        -- pack #16 in box #41
        [16] = {
            "ARC189","ARC216","ARC183","ARC198","ARC059","ARC043","ARC189","ARC005","ARC030","ARC063","ARC020","ARC067","ARC096","ARC145","ARC107","ARC040","ARC114"
        },
        -- pack #17 in box #41
        [17] = {
            "ARC189","ARC201","ARC208","ARC180","ARC049","ARC118","ARC044","ARC042","ARC027","ARC062","ARC029","ARC136","ARC095","ARC141","ARC095","ARC075","ARC001"
        },
        -- pack #18 in box #41
        [18] = {
            "ARC205","ARC185","ARC192","ARC196","ARC167","ARC015","ARC168","ARC079","ARC062","ARC028","ARC062","ARC105","ARC146","ARC110","ARC139","ARC077","ARC075"
        },
        -- pack #19 in box #41
        [19] = {
            "ARC178","ARC181","ARC204","ARC210","ARC017","ARC159","ARC004","ARC079","ARC065","ARC027","ARC062","ARC021","ARC143","ARC094","ARC134","ARC077","ARC040"
        },
        -- pack #20 in box #41
        [20] = {
            "ARC192","ARC183","ARC186","ARC197","ARC169","ARC017","ARC201","ARC155","ARC035","ARC073","ARC026","ARC073","ARC105","ARC148","ARC094","ARC075","ARC112"
        },
        -- pack #21 in box #41
        [21] = {
            "ARC195","ARC191","ARC199","ARC201","ARC051","ARC045","ARC176","ARC153","ARC021","ARC063","ARC024","ARC132","ARC097","ARC144","ARC107","ARC040","ARC001"
        },
        -- pack #22 in box #41
        [22] = {
            "ARC201","ARC207","ARC209","ARC191","ARC127","ARC050","ARC167","ARC042","ARC025","ARC073","ARC021","ARC149","ARC103","ARC142","ARC111","ARC003","ARC001"
        },
        -- pack #23 in box #41
        [23] = {
            "ARC188","ARC208","ARC199","ARC217","ARC169","ARC121","ARC143","ARC156","ARC026","ARC066","ARC027","ARC073","ARC099","ARC136","ARC096","ARC038","ARC114"
        },
        -- pack #24 in box #41
        [24] = {
            "ARC185","ARC190","ARC202","ARC211","ARC091","ARC051","ARC031","ARC156","ARC063","ARC027","ARC063","ARC024","ARC133","ARC110","ARC139","ARC002","ARC040"
        },
    },
    -- box #42
    [42] = {
        -- pack #1 in box #42
        [1] = {
            "ARC201","ARC214","ARC201","ARC216","ARC058","ARC016","ARC212","ARC152","ARC068","ARC036","ARC060","ARC031","ARC140","ARC103","ARC136","ARC039","ARC001"
        },
        -- pack #2 in box #42
        [2] = {
            "ARC216","ARC188","ARC177","ARC201","ARC013","ARC007","ARC155","ARC156","ARC068","ARC021","ARC064","ARC032","ARC139","ARC103","ARC141","ARC218"
        },
        -- pack #3 in box #42
        [3] = {
            "ARC215","ARC211","ARC186","ARC187","ARC055","ARC018","ARC108","ARC152","ARC069","ARC021","ARC074","ARC037","ARC146","ARC096","ARC143","ARC039","ARC001"
        },
        -- pack #4 in box #42
        [4] = {
            "ARC199","ARC217","ARC179","ARC193","ARC091","ARC050","ARC184","ARC154","ARC062","ARC024","ARC063","ARC031","ARC148","ARC103","ARC132","ARC218"
        },
        -- pack #5 in box #42
        [5] = {
            "ARC207","ARC190","ARC178","ARC199","ARC087","ARC046","ARC020","ARC155","ARC066","ARC028","ARC072","ARC023","ARC149","ARC111","ARC133","ARC076","ARC113"
        },
        -- pack #6 in box #42
        [6] = {
            "ARC187","ARC197","ARC197","ARC182","ARC013","ARC127","ARC099","ARC117","ARC024","ARC068","ARC028","ARC066","ARC109","ARC148","ARC110","ARC114","ARC115"
        },
        -- pack #7 in box #42
        [7] = {
            "ARC180","ARC196","ARC198","ARC187","ARC059","ARC015","ARC030","ARC152","ARC022","ARC074","ARC034","ARC148","ARC103","ARC143","ARC102","ARC039","ARC040"
        },
        -- pack #8 in box #42
        [8] = {
            "ARC198","ARC193","ARC217","ARC205","ARC092","ARC169","ARC182","ARC079","ARC031","ARC067","ARC030","ARC133","ARC108","ARC138","ARC104","ARC218"
        },
        -- pack #9 in box #42
        [9] = {
            "ARC204","ARC189","ARC179","ARC211","ARC123","ARC162","ARC191","ARC079","ARC037","ARC072","ARC037","ARC144","ARC096","ARC137","ARC103","ARC075","ARC039"
        },
        -- pack #10 in box #42
        [10] = {
            "ARC201","ARC183","ARC202","ARC196","ARC127","ARC015","ARC106","ARC152","ARC060","ARC024","ARC064","ARC094","ARC133","ARC106","ARC144","ARC076","ARC040"
        },
        -- pack #11 in box #42
        [11] = {
            "ARC211","ARC209","ARC180","ARC190","ARC048","ARC046","ARC099","ARC152","ARC073","ARC033","ARC071","ARC110","ARC140","ARC098","ARC141","ARC112","ARC077"
        },
        -- pack #12 in box #42
        [12] = {
            "ARC217","ARC200","ARC177","ARC207","ARC016","ARC059","ARC011","ARC151","ARC026","ARC074","ARC036","ARC068","ARC104","ARC133","ARC102","ARC077","ARC038"
        },
        -- pack #13 in box #42
        [13] = {
            "ARC195","ARC182","ARC204","ARC208","ARC052","ARC167","ARC027","ARC005","ARC067","ARC025","ARC067","ARC033","ARC143","ARC104","ARC138","ARC001","ARC114"
        },
        -- pack #14 in box #42
        [14] = {
            "ARC188","ARC204","ARC206","ARC186","ARC090","ARC008","ARC004","ARC156","ARC037","ARC063","ARC033","ARC148","ARC109","ARC133","ARC095","ARC114","ARC002"
        },
        -- pack #15 in box #42
        [15] = {
            "ARC217","ARC204","ARC198","ARC198","ARC174","ARC084","ARC182","ARC153","ARC064","ARC026","ARC062","ARC098","ARC134","ARC111","ARC145","ARC001","ARC115"
        },
        -- pack #16 in box #42
        [16] = {
            "ARC198","ARC211","ARC202","ARC214","ARC058","ARC163","ARC145","ARC152","ARC031","ARC069","ARC028","ARC134","ARC096","ARC135","ARC095","ARC077","ARC113"
        },
        -- pack #17 in box #42
        [17] = {
            "ARC202","ARC198","ARC178","ARC210","ARC089","ARC093","ARC090","ARC158","ARC068","ARC030","ARC069","ARC103","ARC146","ARC098","ARC149","ARC003","ARC112"
        },
        -- pack #18 in box #42
        [18] = {
            "ARC211","ARC206","ARC212","ARC186","ARC090","ARC173","ARC191","ARC117","ARC035","ARC064","ARC029","ARC074","ARC107","ARC142","ARC099","ARC077","ARC112"
        },
        -- pack #19 in box #42
        [19] = {
            "ARC209","ARC217","ARC210","ARC177","ARC172","ARC124","ARC117","ARC157","ARC021","ARC072","ARC025","ARC143","ARC105","ARC141","ARC099","ARC075","ARC112"
        },
        -- pack #20 in box #42
        [20] = {
            "ARC217","ARC202","ARC212","ARC177","ARC053","ARC082","ARC132","ARC042","ARC024","ARC062","ARC032","ARC064","ARC110","ARC140","ARC107","ARC003","ARC112"
        },
        -- pack #21 in box #42
        [21] = {
            "ARC208","ARC189","ARC216","ARC197","ARC051","ARC018","ARC147","ARC005","ARC065","ARC020","ARC065","ARC110","ARC135","ARC107","ARC137","ARC040","ARC002"
        },
        -- pack #22 in box #42
        [22] = {
            "ARC182","ARC194","ARC208","ARC203","ARC057","ARC130","ARC139","ARC158","ARC035","ARC061","ARC030","ARC061","ARC109","ARC136","ARC105","ARC115","ARC039"
        },
        -- pack #23 in box #42
        [23] = {
            "ARC215","ARC200","ARC194","ARC178","ARC129","ARC174","ARC138","ARC154","ARC068","ARC034","ARC069","ARC108","ARC145","ARC109","ARC133","ARC075","ARC040"
        },
        -- pack #24 in box #42
        [24] = {
            "ARC181","ARC184","ARC182","ARC188","ARC048","ARC089","ARC214","ARC154","ARC033","ARC060","ARC021","ARC073","ARC108","ARC132","ARC111","ARC218"
        },
    },
    -- box #43
    [43] = {
        -- pack #1 in box #43
        [1] = {
            "ARC203","ARC193","ARC199","ARC208","ARC093","ARC130","ARC216","ARC152","ARC030","ARC069","ARC030","ARC137","ARC103","ARC134","ARC098","ARC002","ARC040"
        },
        -- pack #2 in box #43
        [2] = {
            "ARC214","ARC191","ARC200","ARC180","ARC125","ARC126","ARC206","ARC079","ARC065","ARC024","ARC061","ARC033","ARC137","ARC109","ARC143","ARC112","ARC040"
        },
        -- pack #3 in box #43
        [3] = {
            "ARC215","ARC214","ARC211","ARC190","ARC126","ARC051","ARC105","ARC117","ARC023","ARC068","ARC034","ARC060","ARC107","ARC146","ARC105","ARC002","ARC112"
        },
        -- pack #4 in box #43
        [4] = {
            "ARC193","ARC180","ARC176","ARC197","ARC093","ARC058","ARC178","ARC155","ARC028","ARC072","ARC020","ARC069","ARC098","ARC134","ARC096","ARC039","ARC038"
        },
        -- pack #5 in box #43
        [5] = {
            "ARC206","ARC192","ARC181","ARC195","ARC057","ARC124","ARC136","ARC158","ARC066","ARC037","ARC071","ARC031","ARC143","ARC100","ARC139","ARC113","ARC075"
        },
        -- pack #6 in box #43
        [6] = {
            "ARC188","ARC179","ARC208","ARC217","ARC131","ARC013","ARC174","ARC155","ARC069","ARC024","ARC064","ARC102","ARC139","ARC096","ARC142","ARC112","ARC039"
        },
        -- pack #7 in box #43
        [7] = {
            "ARC215","ARC207","ARC186","ARC203","ARC058","ARC164","ARC190","ARC155","ARC033","ARC061","ARC028","ARC147","ARC095","ARC134","ARC103","ARC040","ARC038"
        },
        -- pack #8 in box #43
        [8] = {
            "ARC195","ARC178","ARC200","ARC217","ARC170","ARC010","ARC202","ARC005","ARC071","ARC029","ARC071","ARC024","ARC139","ARC100","ARC142","ARC076","ARC114"
        },
        -- pack #9 in box #43
        [9] = {
            "ARC182","ARC206","ARC179","ARC202","ARC130","ARC049","ARC153","ARC153","ARC064","ARC024","ARC070","ARC106","ARC142","ARC105","ARC143","ARC001","ARC076"
        },
        -- pack #10 in box #43
        [10] = {
            "ARC182","ARC197","ARC195","ARC213","ARC057","ARC170","ARC068","ARC157","ARC035","ARC064","ARC027","ARC065","ARC097","ARC140","ARC098","ARC076","ARC114"
        },
        -- pack #11 in box #43
        [11] = {
            "ARC188","ARC190","ARC194","ARC210","ARC056","ARC047","ARC124","ARC156","ARC072","ARC024","ARC074","ARC031","ARC139","ARC111","ARC140","ARC040","ARC039"
        },
        -- pack #12 in box #43
        [12] = {
            "ARC178","ARC203","ARC190","ARC211","ARC051","ARC173","ARC012","ARC005","ARC066","ARC025","ARC073","ARC111","ARC138","ARC101","ARC149","ARC076","ARC115"
        },
        -- pack #13 in box #43
        [13] = {
            "ARC209","ARC196","ARC184","ARC210","ARC124","ARC086","ARC070","ARC117","ARC060","ARC022","ARC067","ARC025","ARC148","ARC100","ARC143","ARC114","ARC002"
        },
        -- pack #14 in box #43
        [14] = {
            "ARC189","ARC179","ARC182","ARC210","ARC128","ARC161","ARC068","ARC079","ARC023","ARC072","ARC022","ARC061","ARC107","ARC149","ARC101","ARC003","ARC114"
        },
        -- pack #15 in box #43
        [15] = {
            "ARC181","ARC200","ARC180","ARC178","ARC055","ARC167","ARC102","ARC155","ARC020","ARC071","ARC033","ARC067","ARC107","ARC138","ARC095","ARC112","ARC003"
        },
        -- pack #16 in box #43
        [16] = {
            "ARC189","ARC185","ARC179","ARC210","ARC123","ARC044","ARC132","ARC154","ARC061","ARC037","ARC070","ARC028","ARC133","ARC100","ARC135","ARC003","ARC113"
        },
        -- pack #17 in box #43
        [17] = {
            "ARC195","ARC213","ARC212","ARC209","ARC171","ARC120","ARC192","ARC155","ARC064","ARC020","ARC071","ARC095","ARC143","ARC096","ARC146","ARC002","ARC003"
        },
        -- pack #18 in box #43
        [18] = {
            "ARC188","ARC214","ARC187","ARC187","ARC123","ARC084","ARC027","ARC157","ARC027","ARC065","ARC026","ARC136","ARC094","ARC136","ARC101","ARC115","ARC003"
        },
        -- pack #19 in box #43
        [19] = {
            "ARC196","ARC192","ARC179","ARC182","ARC050","ARC052","ARC074","ARC117","ARC064","ARC026","ARC063","ARC111","ARC140","ARC101","ARC134","ARC002","ARC001"
        },
        -- pack #20 in box #43
        [20] = {
            "ARC194","ARC191","ARC188","ARC178","ARC171","ARC010","ARC051","ARC151","ARC068","ARC023","ARC060","ARC096","ARC138","ARC108","ARC148","ARC113","ARC075"
        },
        -- pack #21 in box #43
        [21] = {
            "ARC186","ARC209","ARC210","ARC184","ARC166","ARC124","ARC149","ARC005","ARC026","ARC069","ARC034","ARC134","ARC095","ARC138","ARC101","ARC218"
        },
        -- pack #22 in box #43
        [22] = {
            "ARC200","ARC208","ARC188","ARC176","ARC011","ARC172","ARC083","ARC158","ARC029","ARC067","ARC021","ARC071","ARC096","ARC137","ARC105","ARC112","ARC003"
        },
        -- pack #23 in box #43
        [23] = {
            "ARC201","ARC201","ARC204","ARC204","ARC089","ARC122","ARC186","ARC156","ARC023","ARC061","ARC030","ARC149","ARC099","ARC137","ARC094","ARC040","ARC001"
        },
        -- pack #24 in box #43
        [24] = {
            "ARC176","ARC200","ARC194","ARC192","ARC164","ARC088","ARC101","ARC117","ARC026","ARC069","ARC035","ARC134","ARC099","ARC141","ARC097","ARC113","ARC038"
        },
    },
    -- box #44
    [44] = {
        -- pack #1 in box #44
        [1] = {
            "ARC216","ARC215","ARC186","ARC195","ARC056","ARC058","ARC156","ARC154","ARC069","ARC021","ARC061","ARC020","ARC142","ARC111","ARC142","ARC002","ARC113"
        },
        -- pack #2 in box #44
        [2] = {
            "ARC208","ARC203","ARC183","ARC184","ARC130","ARC126","ARC034","ARC042","ARC070","ARC021","ARC065","ARC031","ARC149","ARC108","ARC143","ARC077","ARC115"
        },
        -- pack #3 in box #44
        [3] = {
            "ARC200","ARC215","ARC208","ARC190","ARC011","ARC126","ARC176","ARC151","ARC066","ARC035","ARC061","ARC104","ARC135","ARC106","ARC139","ARC114","ARC003"
        },
        -- pack #4 in box #44
        [4] = {
            "ARC197","ARC193","ARC201","ARC189","ARC128","ARC118","ARC191","ARC151","ARC027","ARC065","ARC027","ARC144","ARC100","ARC135","ARC096","ARC112","ARC040"
        },
        -- pack #5 in box #44
        [5] = {
            "ARC192","ARC181","ARC181","ARC209","ARC173","ARC055","ARC050","ARC155","ARC026","ARC073","ARC024","ARC061","ARC104","ARC149","ARC103","ARC040","ARC113"
        },
        -- pack #6 in box #44
        [6] = {
            "ARC187","ARC194","ARC186","ARC201","ARC164","ARC174","ARC051","ARC042","ARC068","ARC035","ARC064","ARC111","ARC142","ARC111","ARC141","ARC003","ARC112"
        },
        -- pack #7 in box #44
        [7] = {
            "ARC179","ARC200","ARC215","ARC211","ARC053","ARC130","ARC041","ARC158","ARC067","ARC031","ARC074","ARC036","ARC133","ARC111","ARC136","ARC114","ARC112"
        },
        -- pack #8 in box #44
        [8] = {
            "ARC199","ARC198","ARC217","ARC198","ARC174","ARC172","ARC096","ARC156","ARC020","ARC071","ARC022","ARC068","ARC100","ARC135","ARC107","ARC113","ARC115"
        },
        -- pack #9 in box #44
        [9] = {
            "ARC195","ARC202","ARC208","ARC213","ARC055","ARC124","ARC204","ARC157","ARC068","ARC021","ARC067","ARC098","ARC147","ARC104","ARC142","ARC218"
        },
        -- pack #10 in box #44
        [10] = {
            "ARC176","ARC180","ARC193","ARC192","ARC058","ARC091","ARC096","ARC154","ARC026","ARC068","ARC033","ARC069","ARC109","ARC147","ARC098","ARC040","ARC114"
        },
        -- pack #11 in box #44
        [11] = {
            "ARC189","ARC187","ARC193","ARC181","ARC090","ARC052","ARC193","ARC157","ARC074","ARC033","ARC072","ARC109","ARC138","ARC094","ARC148","ARC038","ARC077"
        },
        -- pack #12 in box #44
        [12] = {
            "ARC195","ARC184","ARC207","ARC217","ARC014","ARC128","ARC148","ARC151","ARC031","ARC065","ARC021","ARC132","ARC101","ARC140","ARC109","ARC114","ARC115"
        },
        -- pack #13 in box #44
        [13] = {
            "ARC208","ARC187","ARC207","ARC198","ARC053","ARC131","ARC086","ARC079","ARC033","ARC064","ARC031","ARC137","ARC107","ARC144","ARC111","ARC001","ARC038"
        },
        -- pack #14 in box #44
        [14] = {
            "ARC187","ARC186","ARC205","ARC203","ARC057","ARC086","ARC056","ARC151","ARC020","ARC073","ARC026","ARC142","ARC095","ARC138","ARC103","ARC077","ARC040"
        },
        -- pack #15 in box #44
        [15] = {
            "ARC196","ARC184","ARC182","ARC187","ARC017","ARC018","ARC164","ARC005","ARC065","ARC032","ARC074","ARC110","ARC141","ARC107","ARC134","ARC001","ARC040"
        },
        -- pack #16 in box #44
        [16] = {
            "ARC196","ARC214","ARC207","ARC177","ARC018","ARC045","ARC081","ARC117","ARC033","ARC067","ARC028","ARC136","ARC101","ARC147","ARC099","ARC077","ARC038"
        },
        -- pack #17 in box #44
        [17] = {
            "ARC194","ARC191","ARC194","ARC204","ARC088","ARC091","ARC143","ARC155","ARC033","ARC071","ARC024","ARC138","ARC107","ARC139","ARC099","ARC113","ARC040"
        },
        -- pack #18 in box #44
        [18] = {
            "ARC206","ARC208","ARC187","ARC202","ARC057","ARC174","ARC191","ARC005","ARC032","ARC068","ARC023","ARC073","ARC096","ARC149","ARC104","ARC039","ARC076"
        },
        -- pack #19 in box #44
        [19] = {
            "ARC198","ARC213","ARC185","ARC215","ARC124","ARC168","ARC179","ARC042","ARC030","ARC067","ARC035","ARC067","ARC104","ARC143","ARC108","ARC076","ARC113"
        },
        -- pack #20 in box #44
        [20] = {
            "ARC186","ARC189","ARC195","ARC216","ARC092","ARC048","ARC217","ARC079","ARC037","ARC071","ARC022","ARC063","ARC101","ARC142","ARC105","ARC115","ARC003"
        },
        -- pack #21 in box #44
        [21] = {
            "ARC208","ARC181","ARC203","ARC178","ARC056","ARC093","ARC055","ARC156","ARC064","ARC024","ARC067","ARC020","ARC136","ARC099","ARC146","ARC040","ARC039"
        },
        -- pack #22 in box #44
        [22] = {
            "ARC205","ARC184","ARC177","ARC205","ARC011","ARC009","ARC215","ARC005","ARC074","ARC027","ARC071","ARC023","ARC149","ARC098","ARC145","ARC002","ARC039"
        },
        -- pack #23 in box #44
        [23] = {
            "ARC190","ARC182","ARC213","ARC185","ARC172","ARC165","ARC202","ARC158","ARC065","ARC021","ARC065","ARC030","ARC135","ARC098","ARC133","ARC075","ARC038"
        },
        -- pack #24 in box #44
        [24] = {
            "ARC184","ARC206","ARC211","ARC199","ARC126","ARC059","ARC206","ARC152","ARC067","ARC030","ARC066","ARC110","ARC149","ARC096","ARC136","ARC002","ARC075"
        },
    },
    -- box #45
    [45] = {
        -- pack #1 in box #45
        [1] = {
            "ARC190","ARC210","ARC187","ARC199","ARC052","ARC009","ARC185","ARC155","ARC071","ARC022","ARC071","ARC031","ARC139","ARC107","ARC140","ARC003","ARC040"
        },
        -- pack #2 in box #45
        [2] = {
            "ARC212","ARC205","ARC189","ARC206","ARC085","ARC054","ARC064","ARC155","ARC022","ARC073","ARC022","ARC063","ARC095","ARC147","ARC098","ARC115","ARC113"
        },
        -- pack #3 in box #45
        [3] = {
            "ARC217","ARC176","ARC196","ARC177","ARC012","ARC047","ARC060","ARC117","ARC072","ARC026","ARC062","ARC035","ARC146","ARC109","ARC141","ARC003","ARC115"
        },
        -- pack #4 in box #45
        [4] = {
            "ARC212","ARC216","ARC204","ARC196","ARC130","ARC089","ARC197","ARC155","ARC036","ARC065","ARC029","ARC060","ARC111","ARC134","ARC102","ARC040","ARC112"
        },
        -- pack #5 in box #45
        [5] = {
            "ARC181","ARC205","ARC216","ARC179","ARC055","ARC049","ARC141","ARC152","ARC027","ARC072","ARC021","ARC137","ARC103","ARC144","ARC095","ARC001","ARC003"
        },
        -- pack #6 in box #45
        [6] = {
            "ARC207","ARC185","ARC206","ARC178","ARC018","ARC051","ARC151","ARC005","ARC023","ARC073","ARC036","ARC132","ARC096","ARC133","ARC111","ARC001","ARC114"
        },
        -- pack #7 in box #45
        [7] = {
            "ARC215","ARC185","ARC176","ARC209","ARC168","ARC017","ARC037","ARC157","ARC023","ARC070","ARC029","ARC074","ARC111","ARC148","ARC100","ARC218"
        },
        -- pack #8 in box #45
        [8] = {
            "ARC209","ARC202","ARC192","ARC194","ARC130","ARC044","ARC204","ARC042","ARC023","ARC071","ARC035","ARC137","ARC105","ARC134","ARC110","ARC113","ARC076"
        },
        -- pack #9 in box #45
        [9] = {
            "ARC190","ARC193","ARC190","ARC213","ARC125","ARC087","ARC185","ARC117","ARC035","ARC067","ARC024","ARC142","ARC099","ARC134","ARC103","ARC039","ARC076"
        },
        -- pack #10 in box #45
        [10] = {
            "ARC193","ARC216","ARC204","ARC206","ARC174","ARC173","ARC097","ARC117","ARC068","ARC035","ARC068","ARC107","ARC135","ARC098","ARC147","ARC077","ARC039"
        },
        -- pack #11 in box #45
        [11] = {
            "ARC203","ARC194","ARC205","ARC193","ARC164","ARC083","ARC032","ARC157","ARC062","ARC023","ARC065","ARC106","ARC133","ARC098","ARC139","ARC001","ARC112"
        },
        -- pack #12 in box #45
        [12] = {
            "ARC178","ARC214","ARC217","ARC185","ARC170","ARC047","ARC203","ARC151","ARC063","ARC027","ARC065","ARC021","ARC142","ARC106","ARC146","ARC075","ARC115"
        },
        -- pack #13 in box #45
        [13] = {
            "ARC207","ARC204","ARC184","ARC214","ARC174","ARC043","ARC096","ARC042","ARC030","ARC070","ARC021","ARC061","ARC099","ARC139","ARC108","ARC112","ARC075"
        },
        -- pack #14 in box #45
        [14] = {
            "ARC202","ARC185","ARC196","ARC176","ARC017","ARC123","ARC194","ARC042","ARC064","ARC031","ARC062","ARC096","ARC135","ARC104","ARC147","ARC113","ARC002"
        },
        -- pack #15 in box #45
        [15] = {
            "ARC179","ARC207","ARC181","ARC202","ARC017","ARC080","ARC201","ARC154","ARC065","ARC036","ARC066","ARC105","ARC135","ARC111","ARC133","ARC040","ARC077"
        },
        -- pack #16 in box #45
        [16] = {
            "ARC176","ARC202","ARC187","ARC178","ARC012","ARC048","ARC192","ARC158","ARC025","ARC074","ARC025","ARC135","ARC109","ARC139","ARC108","ARC113","ARC115"
        },
        -- pack #17 in box #45
        [17] = {
            "ARC208","ARC192","ARC201","ARC180","ARC124","ARC123","ARC172","ARC152","ARC022","ARC070","ARC036","ARC068","ARC100","ARC147","ARC095","ARC115","ARC001"
        },
        -- pack #18 in box #45
        [18] = {
            "ARC193","ARC180","ARC215","ARC190","ARC124","ARC014","ARC048","ARC154","ARC021","ARC071","ARC034","ARC135","ARC107","ARC147","ARC096","ARC001","ARC113"
        },
        -- pack #19 in box #45
        [19] = {
            "ARC179","ARC182","ARC208","ARC176","ARC169","ARC011","ARC206","ARC152","ARC062","ARC020","ARC068","ARC022","ARC141","ARC099","ARC144","ARC076","ARC114"
        },
        -- pack #20 in box #45
        [20] = {
            "ARC186","ARC185","ARC208","ARC214","ARC125","ARC048","ARC146","ARC155","ARC071","ARC029","ARC067","ARC030","ARC144","ARC108","ARC148","ARC040","ARC003"
        },
        -- pack #21 in box #45
        [21] = {
            "ARC192","ARC185","ARC215","ARC207","ARC126","ARC164","ARC020","ARC117","ARC060","ARC033","ARC068","ARC111","ARC132","ARC097","ARC139","ARC038","ARC002"
        },
        -- pack #22 in box #45
        [22] = {
            "ARC198","ARC197","ARC202","ARC196","ARC086","ARC126","ARC155","ARC117","ARC072","ARC031","ARC073","ARC100","ARC141","ARC097","ARC141","ARC218"
        },
        -- pack #23 in box #45
        [23] = {
            "ARC199","ARC182","ARC213","ARC185","ARC054","ARC175","ARC134","ARC005","ARC074","ARC037","ARC074","ARC025","ARC132","ARC103","ARC141","ARC218"
        },
        -- pack #24 in box #45
        [24] = {
            "ARC202","ARC180","ARC199","ARC179","ARC172","ARC085","ARC072","ARC157","ARC021","ARC074","ARC021","ARC074","ARC110","ARC134","ARC095","ARC114","ARC003"
        },
    },
    -- box #46
    [46] = {
        -- pack #1 in box #46
        [1] = {
            "ARC189","ARC191","ARC189","ARC195","ARC092","ARC013","ARC053","ARC079","ARC032","ARC060","ARC030","ARC145","ARC098","ARC136","ARC106","ARC112","ARC039"
        },
        -- pack #2 in box #46
        [2] = {
            "ARC202","ARC198","ARC179","ARC181","ARC089","ARC051","ARC137","ARC151","ARC025","ARC065","ARC028","ARC149","ARC108","ARC140","ARC101","ARC076","ARC113"
        },
        -- pack #3 in box #46
        [3] = {
            "ARC177","ARC207","ARC197","ARC201","ARC049","ARC127","ARC092","ARC153","ARC037","ARC070","ARC025","ARC148","ARC103","ARC139","ARC098","ARC218"
        },
        -- pack #4 in box #46
        [4] = {
            "ARC206","ARC181","ARC195","ARC190","ARC055","ARC126","ARC033","ARC117","ARC025","ARC062","ARC032","ARC074","ARC110","ARC132","ARC098","ARC038","ARC114"
        },
        -- pack #5 in box #46
        [5] = {
            "ARC199","ARC192","ARC182","ARC216","ARC167","ARC017","ARC010","ARC158","ARC062","ARC025","ARC063","ARC025","ARC147","ARC094","ARC132","ARC076","ARC003"
        },
        -- pack #6 in box #46
        [6] = {
            "ARC185","ARC217","ARC214","ARC214","ARC050","ARC171","ARC107","ARC157","ARC022","ARC063","ARC034","ARC135","ARC110","ARC137","ARC096","ARC115","ARC002"
        },
        -- pack #7 in box #46
        [7] = {
            "ARC176","ARC210","ARC185","ARC177","ARC015","ARC127","ARC045","ARC042","ARC022","ARC066","ARC029","ARC141","ARC097","ARC132","ARC110","ARC115","ARC112"
        },
        -- pack #8 in box #46
        [8] = {
            "ARC184","ARC207","ARC182","ARC182","ARC052","ARC166","ARC179","ARC153","ARC071","ARC035","ARC062","ARC109","ARC147","ARC105","ARC138","ARC003","ARC112"
        },
        -- pack #9 in box #46
        [9] = {
            "ARC212","ARC204","ARC185","ARC201","ARC130","ARC089","ARC209","ARC156","ARC071","ARC024","ARC071","ARC029","ARC148","ARC096","ARC140","ARC113","ARC002"
        },
        -- pack #10 in box #46
        [10] = {
            "ARC211","ARC179","ARC216","ARC217","ARC088","ARC015","ARC100","ARC156","ARC070","ARC035","ARC074","ARC105","ARC135","ARC099","ARC148","ARC077","ARC003"
        },
        -- pack #11 in box #46
        [11] = {
            "ARC185","ARC209","ARC208","ARC184","ARC089","ARC127","ARC215","ARC005","ARC068","ARC037","ARC063","ARC102","ARC132","ARC108","ARC142","ARC218"
        },
        -- pack #12 in box #46
        [12] = {
            "ARC217","ARC184","ARC201","ARC214","ARC017","ARC120","ARC028","ARC157","ARC027","ARC068","ARC031","ARC060","ARC094","ARC143","ARC098","ARC075","ARC002"
        },
        -- pack #13 in box #46
        [13] = {
            "ARC204","ARC208","ARC194","ARC178","ARC086","ARC159","ARC211","ARC151","ARC062","ARC021","ARC072","ARC021","ARC140","ARC103","ARC139","ARC040","ARC115"
        },
        -- pack #14 in box #46
        [14] = {
            "ARC212","ARC186","ARC206","ARC197","ARC168","ARC131","ARC180","ARC042","ARC068","ARC024","ARC071","ARC110","ARC139","ARC106","ARC147","ARC075","ARC076"
        },
        -- pack #15 in box #46
        [15] = {
            "ARC207","ARC183","ARC183","ARC176","ARC085","ARC014","ARC201","ARC005","ARC071","ARC021","ARC069","ARC025","ARC134","ARC104","ARC138","ARC002","ARC075"
        },
        -- pack #16 in box #46
        [16] = {
            "ARC209","ARC192","ARC205","ARC202","ARC128","ARC016","ARC128","ARC151","ARC025","ARC060","ARC030","ARC132","ARC094","ARC144","ARC108","ARC114","ARC040"
        },
        -- pack #17 in box #46
        [17] = {
            "ARC192","ARC204","ARC180","ARC202","ARC052","ARC008","ARC079","ARC152","ARC032","ARC063","ARC034","ARC060","ARC094","ARC146","ARC095","ARC001","ARC003"
        },
        -- pack #18 in box #46
        [18] = {
            "ARC210","ARC208","ARC197","ARC207","ARC090","ARC012","ARC111","ARC152","ARC033","ARC064","ARC024","ARC061","ARC108","ARC143","ARC104","ARC112","ARC075"
        },
        -- pack #19 in box #46
        [19] = {
            "ARC198","ARC213","ARC211","ARC201","ARC059","ARC126","ARC095","ARC117","ARC065","ARC024","ARC073","ARC101","ARC147","ARC095","ARC142","ARC001","ARC076"
        },
        -- pack #20 in box #46
        [20] = {
            "ARC186","ARC213","ARC192","ARC178","ARC050","ARC090","ARC021","ARC153","ARC034","ARC073","ARC033","ARC065","ARC105","ARC141","ARC110","ARC218"
        },
        -- pack #21 in box #46
        [21] = {
            "ARC180","ARC179","ARC203","ARC180","ARC165","ARC120","ARC190","ARC158","ARC061","ARC022","ARC074","ARC109","ARC134","ARC107","ARC139","ARC002","ARC038"
        },
        -- pack #22 in box #46
        [22] = {
            "ARC191","ARC207","ARC191","ARC200","ARC091","ARC127","ARC171","ARC117","ARC063","ARC033","ARC066","ARC033","ARC133","ARC108","ARC142","ARC115","ARC040"
        },
        -- pack #23 in box #46
        [23] = {
            "ARC188","ARC194","ARC215","ARC200","ARC124","ARC090","ARC178","ARC157","ARC027","ARC060","ARC024","ARC069","ARC103","ARC135","ARC111","ARC002","ARC077"
        },
        -- pack #24 in box #46
        [24] = {
            "ARC185","ARC180","ARC178","ARC206","ARC088","ARC166","ARC150","ARC156","ARC068","ARC032","ARC073","ARC035","ARC143","ARC106","ARC138","ARC039","ARC040"
        },
    },
    -- box #47
    [47] = {
        -- pack #1 in box #47
        [1] = {
            "ARC209","ARC212","ARC213","ARC204","ARC088","ARC054","ARC195","ARC152","ARC065","ARC024","ARC074","ARC094","ARC140","ARC097","ARC135","ARC076","ARC001"
        },
        -- pack #2 in box #47
        [2] = {
            "ARC179","ARC181","ARC204","ARC217","ARC054","ARC051","ARC184","ARC042","ARC073","ARC035","ARC073","ARC030","ARC147","ARC101","ARC140","ARC001","ARC003"
        },
        -- pack #3 in box #47
        [3] = {
            "ARC212","ARC216","ARC216","ARC192","ARC018","ARC055","ARC178","ARC042","ARC072","ARC033","ARC060","ARC100","ARC142","ARC102","ARC138","ARC040","ARC114"
        },
        -- pack #4 in box #47
        [4] = {
            "ARC181","ARC203","ARC189","ARC186","ARC167","ARC053","ARC122","ARC152","ARC022","ARC073","ARC023","ARC073","ARC110","ARC142","ARC107","ARC003","ARC077"
        },
        -- pack #5 in box #47
        [5] = {
            "ARC198","ARC211","ARC199","ARC189","ARC059","ARC131","ARC054","ARC079","ARC029","ARC068","ARC029","ARC137","ARC096","ARC134","ARC105","ARC112","ARC039"
        },
        -- pack #6 in box #47
        [6] = {
            "ARC177","ARC183","ARC212","ARC198","ARC050","ARC129","ARC066","ARC152","ARC021","ARC066","ARC020","ARC068","ARC108","ARC146","ARC099","ARC218"
        },
        -- pack #7 in box #47
        [7] = {
            "ARC199","ARC190","ARC182","ARC182","ARC173","ARC163","ARC097","ARC156","ARC074","ARC027","ARC074","ARC099","ARC132","ARC109","ARC133","ARC114","ARC002"
        },
        -- pack #8 in box #47
        [8] = {
            "ARC207","ARC217","ARC201","ARC205","ARC087","ARC050","ARC179","ARC005","ARC071","ARC034","ARC074","ARC022","ARC142","ARC098","ARC144","ARC112","ARC002"
        },
        -- pack #9 in box #47
        [9] = {
            "ARC187","ARC216","ARC184","ARC187","ARC057","ARC119","ARC193","ARC152","ARC036","ARC071","ARC036","ARC065","ARC094","ARC137","ARC104","ARC003","ARC112"
        },
        -- pack #10 in box #47
        [10] = {
            "ARC194","ARC193","ARC178","ARC187","ARC049","ARC124","ARC137","ARC151","ARC063","ARC034","ARC067","ARC102","ARC138","ARC100","ARC147","ARC114","ARC001"
        },
        -- pack #11 in box #47
        [11] = {
            "ARC177","ARC216","ARC187","ARC214","ARC093","ARC017","ARC139","ARC156","ARC036","ARC070","ARC022","ARC149","ARC103","ARC133","ARC106","ARC077","ARC039"
        },
        -- pack #12 in box #47
        [12] = {
            "ARC208","ARC207","ARC204","ARC185","ARC125","ARC019","ARC032","ARC153","ARC032","ARC062","ARC036","ARC146","ARC094","ARC144","ARC111","ARC075","ARC001"
        },
        -- pack #13 in box #47
        [13] = {
            "ARC186","ARC193","ARC188","ARC192","ARC165","ARC081","ARC105","ARC157","ARC031","ARC068","ARC026","ARC144","ARC098","ARC146","ARC098","ARC113","ARC114"
        },
        -- pack #14 in box #47
        [14] = {
            "ARC209","ARC194","ARC198","ARC185","ARC055","ARC052","ARC160","ARC151","ARC022","ARC060","ARC021","ARC066","ARC095","ARC148","ARC100","ARC038","ARC115"
        },
        -- pack #15 in box #47
        [15] = {
            "ARC196","ARC199","ARC193","ARC201","ARC172","ARC089","ARC195","ARC153","ARC066","ARC031","ARC062","ARC036","ARC133","ARC096","ARC139","ARC115","ARC038"
        },
        -- pack #16 in box #47
        [16] = {
            "ARC195","ARC208","ARC194","ARC214","ARC129","ARC121","ARC021","ARC154","ARC021","ARC072","ARC026","ARC136","ARC103","ARC135","ARC102","ARC075","ARC076"
        },
        -- pack #17 in box #47
        [17] = {
            "ARC214","ARC211","ARC181","ARC195","ARC014","ARC168","ARC031","ARC079","ARC073","ARC026","ARC069","ARC030","ARC142","ARC107","ARC145","ARC038","ARC001"
        },
        -- pack #18 in box #47
        [18] = {
            "ARC190","ARC212","ARC179","ARC190","ARC090","ARC123","ARC094","ARC158","ARC067","ARC037","ARC061","ARC106","ARC133","ARC094","ARC145","ARC039","ARC077"
        },
        -- pack #19 in box #47
        [19] = {
            "ARC187","ARC204","ARC206","ARC213","ARC165","ARC057","ARC069","ARC042","ARC030","ARC064","ARC023","ARC070","ARC109","ARC132","ARC096","ARC076","ARC114"
        },
        -- pack #20 in box #47
        [20] = {
            "ARC186","ARC203","ARC182","ARC184","ARC125","ARC009","ARC023","ARC152","ARC066","ARC036","ARC071","ARC025","ARC133","ARC095","ARC134","ARC001","ARC039"
        },
        -- pack #21 in box #47
        [21] = {
            "ARC191","ARC181","ARC198","ARC211","ARC125","ARC126","ARC180","ARC042","ARC037","ARC067","ARC037","ARC065","ARC105","ARC140","ARC105","ARC218"
        },
        -- pack #22 in box #47
        [22] = {
            "ARC180","ARC179","ARC194","ARC184","ARC056","ARC130","ARC217","ARC155","ARC029","ARC065","ARC037","ARC145","ARC111","ARC134","ARC095","ARC115","ARC113"
        },
        -- pack #23 in box #47
        [23] = {
            "ARC200","ARC216","ARC216","ARC204","ARC056","ARC086","ARC166","ARC155","ARC063","ARC022","ARC071","ARC109","ARC144","ARC099","ARC143","ARC112","ARC038"
        },
        -- pack #24 in box #47
        [24] = {
            "ARC181","ARC208","ARC187","ARC217","ARC086","ARC012","ARC216","ARC155","ARC066","ARC022","ARC063","ARC023","ARC147","ARC105","ARC134","ARC001","ARC075"
        },
    },
    -- box #48
    [48] = {
        -- pack #1 in box #48
        [1] = {
            "ARC195","ARC196","ARC209","ARC214","ARC168","ARC058","ARC094","ARC079","ARC067","ARC033","ARC060","ARC102","ARC132","ARC097","ARC138","ARC040","ARC075"
        },
        -- pack #2 in box #48
        [2] = {
            "ARC196","ARC184","ARC186","ARC208","ARC011","ARC171","ARC199","ARC153","ARC063","ARC034","ARC073","ARC107","ARC140","ARC103","ARC133","ARC077","ARC114"
        },
        -- pack #3 in box #48
        [3] = {
            "ARC199","ARC186","ARC189","ARC192","ARC172","ARC010","ARC032","ARC151","ARC070","ARC021","ARC074","ARC109","ARC145","ARC100","ARC142","ARC112","ARC076"
        },
        -- pack #4 in box #48
        [4] = {
            "ARC190","ARC179","ARC181","ARC216","ARC052","ARC172","ARC094","ARC079","ARC032","ARC061","ARC035","ARC066","ARC096","ARC139","ARC100","ARC040","ARC077"
        },
        -- pack #5 in box #48
        [5] = {
            "ARC184","ARC181","ARC190","ARC204","ARC130","ARC053","ARC061","ARC155","ARC032","ARC074","ARC022","ARC064","ARC102","ARC137","ARC111","ARC038","ARC003"
        },
        -- pack #6 in box #48
        [6] = {
            "ARC215","ARC215","ARC201","ARC206","ARC018","ARC128","ARC021","ARC155","ARC037","ARC063","ARC033","ARC133","ARC104","ARC135","ARC094","ARC076","ARC001"
        },
        -- pack #7 in box #48
        [7] = {
            "ARC184","ARC191","ARC205","ARC199","ARC057","ARC047","ARC063","ARC158","ARC031","ARC070","ARC020","ARC148","ARC098","ARC134","ARC111","ARC038","ARC075"
        },
        -- pack #8 in box #48
        [8] = {
            "ARC180","ARC193","ARC182","ARC184","ARC168","ARC014","ARC080","ARC155","ARC022","ARC071","ARC036","ARC062","ARC111","ARC140","ARC109","ARC003","ARC040"
        },
        -- pack #9 in box #48
        [9] = {
            "ARC214","ARC176","ARC179","ARC185","ARC048","ARC058","ARC217","ARC079","ARC068","ARC033","ARC074","ARC096","ARC134","ARC094","ARC142","ARC113","ARC115"
        },
        -- pack #10 in box #48
        [10] = {
            "ARC208","ARC211","ARC176","ARC206","ARC089","ARC173","ARC198","ARC005","ARC074","ARC036","ARC069","ARC096","ARC139","ARC107","ARC138","ARC077","ARC038"
        },
        -- pack #11 in box #48
        [11] = {
            "ARC216","ARC204","ARC183","ARC200","ARC090","ARC050","ARC067","ARC042","ARC026","ARC061","ARC035","ARC133","ARC099","ARC138","ARC102","ARC001","ARC114"
        },
        -- pack #12 in box #48
        [12] = {
            "ARC184","ARC188","ARC188","ARC179","ARC174","ARC009","ARC154","ARC158","ARC069","ARC036","ARC068","ARC025","ARC143","ARC095","ARC137","ARC001","ARC115"
        },
        -- pack #13 in box #48
        [13] = {
            "ARC200","ARC205","ARC199","ARC195","ARC053","ARC159","ARC049","ARC158","ARC023","ARC064","ARC028","ARC063","ARC107","ARC148","ARC104","ARC113","ARC001"
        },
        -- pack #14 in box #48
        [14] = {
            "ARC194","ARC182","ARC211","ARC186","ARC014","ARC175","ARC133","ARC155","ARC035","ARC074","ARC023","ARC137","ARC104","ARC145","ARC110","ARC075","ARC112"
        },
        -- pack #15 in box #48
        [15] = {
            "ARC179","ARC205","ARC210","ARC207","ARC053","ARC010","ARC140","ARC005","ARC063","ARC026","ARC071","ARC036","ARC139","ARC095","ARC140","ARC001","ARC112"
        },
        -- pack #16 in box #48
        [16] = {
            "ARC204","ARC195","ARC178","ARC186","ARC169","ARC058","ARC207","ARC157","ARC028","ARC073","ARC033","ARC066","ARC104","ARC133","ARC094","ARC218"
        },
        -- pack #17 in box #48
        [17] = {
            "ARC194","ARC188","ARC195","ARC201","ARC092","ARC054","ARC030","ARC005","ARC032","ARC067","ARC022","ARC141","ARC101","ARC136","ARC109","ARC077","ARC075"
        },
        -- pack #18 in box #48
        [18] = {
            "ARC197","ARC205","ARC212","ARC205","ARC048","ARC175","ARC121","ARC005","ARC064","ARC022","ARC062","ARC029","ARC146","ARC106","ARC134","ARC114","ARC040"
        },
        -- pack #19 in box #48
        [19] = {
            "ARC196","ARC209","ARC192","ARC206","ARC016","ARC081","ARC043","ARC158","ARC069","ARC020","ARC064","ARC036","ARC132","ARC097","ARC141","ARC002","ARC076"
        },
        -- pack #20 in box #48
        [20] = {
            "ARC182","ARC181","ARC177","ARC208","ARC091","ARC018","ARC191","ARC158","ARC060","ARC032","ARC064","ARC026","ARC132","ARC095","ARC137","ARC075","ARC115"
        },
        -- pack #21 in box #48
        [21] = {
            "ARC197","ARC215","ARC194","ARC207","ARC174","ARC123","ARC021","ARC153","ARC026","ARC071","ARC027","ARC142","ARC111","ARC141","ARC105","ARC001","ARC003"
        },
        -- pack #22 in box #48
        [22] = {
            "ARC177","ARC194","ARC199","ARC177","ARC051","ARC013","ARC034","ARC005","ARC024","ARC068","ARC027","ARC063","ARC104","ARC148","ARC098","ARC039","ARC113"
        },
        -- pack #23 in box #48
        [23] = {
            "ARC194","ARC212","ARC179","ARC199","ARC018","ARC092","ARC170","ARC156","ARC061","ARC026","ARC060","ARC032","ARC149","ARC110","ARC136","ARC003","ARC115"
        },
        -- pack #24 in box #48
        [24] = {
            "ARC177","ARC183","ARC215","ARC191","ARC129","ARC086","ARC037","ARC042","ARC062","ARC029","ARC060","ARC108","ARC138","ARC111","ARC137","ARC039","ARC002"
        },
    },
    -- box #49
    [49] = {
        -- pack #1 in box #49
        [1] = {
            "ARC200","ARC190","ARC216","ARC182","ARC048","ARC129","ARC141","ARC155","ARC023","ARC063","ARC034","ARC137","ARC102","ARC146","ARC109","ARC039","ARC112"
        },
        -- pack #2 in box #49
        [2] = {
            "ARC176","ARC203","ARC176","ARC205","ARC170","ARC051","ARC157","ARC154","ARC062","ARC036","ARC066","ARC100","ARC141","ARC111","ARC147","ARC077","ARC002"
        },
        -- pack #3 in box #49
        [3] = {
            "ARC204","ARC207","ARC191","ARC199","ARC091","ARC172","ARC165","ARC154","ARC066","ARC020","ARC067","ARC103","ARC144","ARC098","ARC138","ARC113","ARC112"
        },
        -- pack #4 in box #49
        [4] = {
            "ARC197","ARC217","ARC215","ARC192","ARC170","ARC018","ARC183","ARC117","ARC027","ARC061","ARC032","ARC070","ARC105","ARC136","ARC103","ARC218"
        },
        -- pack #5 in box #49
        [5] = {
            "ARC214","ARC183","ARC210","ARC185","ARC085","ARC130","ARC211","ARC155","ARC066","ARC025","ARC069","ARC027","ARC145","ARC099","ARC142","ARC003","ARC114"
        },
        -- pack #6 in box #49
        [6] = {
            "ARC184","ARC217","ARC213","ARC204","ARC019","ARC008","ARC051","ARC153","ARC068","ARC037","ARC064","ARC025","ARC135","ARC101","ARC147","ARC113","ARC039"
        },
        -- pack #7 in box #49
        [7] = {
            "ARC209","ARC184","ARC178","ARC176","ARC057","ARC056","ARC111","ARC157","ARC060","ARC021","ARC074","ARC100","ARC142","ARC111","ARC134","ARC076","ARC112"
        },
        -- pack #8 in box #49
        [8] = {
            "ARC205","ARC177","ARC179","ARC189","ARC093","ARC087","ARC175","ARC158","ARC060","ARC033","ARC067","ARC096","ARC134","ARC095","ARC143","ARC115","ARC114"
        },
        -- pack #9 in box #49
        [9] = {
            "ARC209","ARC214","ARC197","ARC193","ARC174","ARC088","ARC082","ARC153","ARC020","ARC065","ARC026","ARC138","ARC103","ARC134","ARC097","ARC114","ARC003"
        },
        -- pack #10 in box #49
        [10] = {
            "ARC190","ARC192","ARC212","ARC179","ARC131","ARC174","ARC022","ARC158","ARC024","ARC070","ARC028","ARC071","ARC107","ARC134","ARC108","ARC002","ARC001"
        },
        -- pack #11 in box #49
        [11] = {
            "ARC195","ARC198","ARC205","ARC178","ARC166","ARC088","ARC109","ARC117","ARC023","ARC069","ARC022","ARC143","ARC098","ARC142","ARC110","ARC039","ARC040"
        },
        -- pack #12 in box #49
        [12] = {
            "ARC182","ARC216","ARC202","ARC193","ARC086","ARC091","ARC179","ARC152","ARC067","ARC027","ARC066","ARC101","ARC148","ARC095","ARC133","ARC113","ARC112"
        },
        -- pack #13 in box #49
        [13] = {
            "ARC193","ARC209","ARC182","ARC177","ARC054","ARC055","ARC182","ARC155","ARC065","ARC022","ARC062","ARC029","ARC140","ARC102","ARC138","ARC075","ARC115"
        },
        -- pack #14 in box #49
        [14] = {
            "ARC178","ARC184","ARC196","ARC200","ARC051","ARC054","ARC216","ARC156","ARC022","ARC069","ARC021","ARC141","ARC098","ARC139","ARC103","ARC218"
        },
        -- pack #15 in box #49
        [15] = {
            "ARC200","ARC209","ARC177","ARC196","ARC131","ARC166","ARC023","ARC079","ARC032","ARC066","ARC020","ARC065","ARC100","ARC144","ARC095","ARC077","ARC076"
        },
        -- pack #16 in box #49
        [16] = {
            "ARC202","ARC180","ARC197","ARC181","ARC093","ARC160","ARC028","ARC117","ARC065","ARC025","ARC073","ARC028","ARC142","ARC097","ARC146","ARC002","ARC075"
        },
        -- pack #17 in box #49
        [17] = {
            "ARC185","ARC199","ARC179","ARC210","ARC127","ARC009","ARC196","ARC157","ARC028","ARC065","ARC033","ARC069","ARC094","ARC139","ARC107","ARC002","ARC112"
        },
        -- pack #18 in box #49
        [18] = {
            "ARC188","ARC185","ARC197","ARC178","ARC053","ARC088","ARC144","ARC154","ARC068","ARC027","ARC063","ARC025","ARC148","ARC098","ARC137","ARC113","ARC039"
        },
        -- pack #19 in box #49
        [19] = {
            "ARC176","ARC191","ARC190","ARC206","ARC058","ARC128","ARC169","ARC158","ARC020","ARC064","ARC022","ARC144","ARC097","ARC141","ARC108","ARC114","ARC075"
        },
        -- pack #20 in box #49
        [20] = {
            "ARC190","ARC206","ARC181","ARC205","ARC055","ARC085","ARC067","ARC079","ARC029","ARC062","ARC033","ARC065","ARC103","ARC145","ARC102","ARC115","ARC077"
        },
        -- pack #21 in box #49
        [21] = {
            "ARC179","ARC190","ARC181","ARC185","ARC054","ARC173","ARC033","ARC151","ARC035","ARC070","ARC036","ARC135","ARC100","ARC143","ARC095","ARC003","ARC075"
        },
        -- pack #22 in box #49
        [22] = {
            "ARC181","ARC181","ARC214","ARC179","ARC128","ARC088","ARC070","ARC117","ARC069","ARC028","ARC062","ARC110","ARC136","ARC095","ARC139","ARC114","ARC112"
        },
        -- pack #23 in box #49
        [23] = {
            "ARC181","ARC209","ARC211","ARC184","ARC013","ARC017","ARC062","ARC155","ARC062","ARC022","ARC070","ARC028","ARC142","ARC108","ARC148","ARC039","ARC003"
        },
        -- pack #24 in box #49
        [24] = {
            "ARC187","ARC208","ARC216","ARC197","ARC050","ARC085","ARC211","ARC079","ARC032","ARC074","ARC034","ARC064","ARC100","ARC142","ARC109","ARC114","ARC003"
        },
    },
    -- box #50
    [50] = {
        -- pack #1 in box #50
        [1] = {
            "ARC185","ARC215","ARC207","ARC210","ARC087","ARC175","ARC107","ARC156","ARC030","ARC074","ARC036","ARC133","ARC105","ARC141","ARC096","ARC075","ARC114"
        },
        -- pack #2 in box #50
        [2] = {
            "ARC204","ARC216","ARC212","ARC195","ARC173","ARC054","ARC181","ARC155","ARC025","ARC072","ARC030","ARC141","ARC104","ARC137","ARC111","ARC076","ARC001"
        },
        -- pack #3 in box #50
        [3] = {
            "ARC178","ARC185","ARC178","ARC176","ARC012","ARC018","ARC123","ARC157","ARC025","ARC063","ARC032","ARC068","ARC104","ARC139","ARC107","ARC001","ARC040"
        },
        -- pack #4 in box #50
        [4] = {
            "ARC202","ARC181","ARC193","ARC176","ARC019","ARC090","ARC182","ARC157","ARC074","ARC032","ARC066","ARC099","ARC142","ARC098","ARC140","ARC114","ARC003"
        },
        -- pack #5 in box #50
        [5] = {
            "ARC192","ARC189","ARC214","ARC208","ARC088","ARC012","ARC108","ARC151","ARC023","ARC063","ARC031","ARC147","ARC111","ARC136","ARC096","ARC040","ARC038"
        },
        -- pack #6 in box #50
        [6] = {
            "ARC203","ARC189","ARC193","ARC202","ARC167","ARC019","ARC123","ARC155","ARC066","ARC025","ARC072","ARC032","ARC140","ARC095","ARC137","ARC040","ARC039"
        },
        -- pack #7 in box #50
        [7] = {
            "ARC188","ARC214","ARC188","ARC210","ARC172","ARC093","ARC050","ARC152","ARC073","ARC031","ARC071","ARC108","ARC139","ARC109","ARC135","ARC076","ARC114"
        },
        -- pack #8 in box #50
        [8] = {
            "ARC192","ARC211","ARC183","ARC205","ARC169","ARC090","ARC069","ARC155","ARC030","ARC069","ARC033","ARC145","ARC103","ARC134","ARC110","ARC115","ARC076"
        },
        -- pack #9 in box #50
        [9] = {
            "ARC176","ARC197","ARC202","ARC191","ARC175","ARC058","ARC214","ARC154","ARC067","ARC026","ARC070","ARC110","ARC148","ARC106","ARC146","ARC114","ARC115"
        },
        -- pack #10 in box #50
        [10] = {
            "ARC176","ARC209","ARC183","ARC192","ARC014","ARC174","ARC063","ARC005","ARC060","ARC029","ARC073","ARC021","ARC140","ARC110","ARC136","ARC076","ARC038"
        },
        -- pack #11 in box #50
        [11] = {
            "ARC217","ARC179","ARC188","ARC194","ARC165","ARC125","ARC103","ARC155","ARC073","ARC025","ARC063","ARC105","ARC147","ARC106","ARC142","ARC114","ARC075"
        },
        -- pack #12 in box #50
        [12] = {
            "ARC182","ARC193","ARC182","ARC216","ARC128","ARC169","ARC058","ARC154","ARC025","ARC062","ARC024","ARC062","ARC097","ARC142","ARC102","ARC076","ARC002"
        },
        -- pack #13 in box #50
        [13] = {
            "ARC200","ARC186","ARC201","ARC181","ARC048","ARC015","ARC181","ARC079","ARC064","ARC024","ARC063","ARC095","ARC145","ARC103","ARC133","ARC077","ARC112"
        },
        -- pack #14 in box #50
        [14] = {
            "ARC179","ARC195","ARC185","ARC193","ARC166","ARC168","ARC184","ARC079","ARC064","ARC021","ARC066","ARC032","ARC149","ARC104","ARC140","ARC040","ARC075"
        },
        -- pack #15 in box #50
        [15] = {
            "ARC188","ARC217","ARC182","ARC195","ARC175","ARC089","ARC203","ARC005","ARC034","ARC060","ARC031","ARC149","ARC100","ARC137","ARC096","ARC218"
        },
        -- pack #16 in box #50
        [16] = {
            "ARC196","ARC196","ARC191","ARC186","ARC164","ARC012","ARC197","ARC155","ARC029","ARC067","ARC020","ARC133","ARC109","ARC140","ARC104","ARC113","ARC075"
        },
        -- pack #17 in box #50
        [17] = {
            "ARC181","ARC178","ARC196","ARC191","ARC172","ARC013","ARC217","ARC155","ARC030","ARC074","ARC022","ARC063","ARC094","ARC132","ARC097","ARC076","ARC039"
        },
        -- pack #18 in box #50
        [18] = {
            "ARC206","ARC184","ARC210","ARC195","ARC129","ARC082","ARC020","ARC155","ARC028","ARC073","ARC030","ARC074","ARC101","ARC149","ARC097","ARC040","ARC112"
        },
        -- pack #19 in box #50
        [19] = {
            "ARC200","ARC215","ARC217","ARC180","ARC056","ARC087","ARC111","ARC153","ARC066","ARC030","ARC067","ARC109","ARC135","ARC108","ARC144","ARC003","ARC040"
        },
        -- pack #20 in box #50
        [20] = {
            "ARC183","ARC190","ARC211","ARC178","ARC015","ARC013","ARC053","ARC152","ARC068","ARC027","ARC072","ARC037","ARC147","ARC095","ARC132","ARC114","ARC075"
        },
        -- pack #21 in box #50
        [21] = {
            "ARC194","ARC215","ARC198","ARC183","ARC167","ARC166","ARC104","ARC157","ARC036","ARC070","ARC024","ARC067","ARC111","ARC148","ARC109","ARC003","ARC113"
        },
        -- pack #22 in box #50
        [22] = {
            "ARC199","ARC187","ARC208","ARC209","ARC127","ARC056","ARC101","ARC151","ARC068","ARC022","ARC069","ARC026","ARC138","ARC096","ARC138","ARC114","ARC002"
        },
        -- pack #23 in box #50
        [23] = {
            "ARC180","ARC217","ARC178","ARC187","ARC054","ARC012","ARC119","ARC158","ARC069","ARC034","ARC065","ARC036","ARC133","ARC103","ARC132","ARC077","ARC114"
        },
        -- pack #24 in box #50
        [24] = {
            "ARC179","ARC204","ARC177","ARC190","ARC015","ARC082","ARC182","ARC153","ARC029","ARC062","ARC037","ARC063","ARC102","ARC133","ARC109","ARC001","ARC077"
        },
    },
    -- box #51
    [51] = {
        -- pack #1 in box #51
        [1] = {
            "ARC212","ARC208","ARC213","ARC213","ARC048","ARC058","ARC151","ARC005","ARC022","ARC073","ARC032","ARC132","ARC110","ARC145","ARC096","ARC076","ARC040"
        },
        -- pack #2 in box #51
        [2] = {
            "ARC215","ARC203","ARC194","ARC208","ARC173","ARC012","ARC175","ARC158","ARC023","ARC065","ARC024","ARC135","ARC110","ARC147","ARC098","ARC113","ARC112"
        },
        -- pack #3 in box #51
        [3] = {
            "ARC212","ARC217","ARC196","ARC209","ARC170","ARC168","ARC183","ARC153","ARC022","ARC072","ARC020","ARC133","ARC111","ARC139","ARC098","ARC112","ARC003"
        },
        -- pack #4 in box #51
        [4] = {
            "ARC180","ARC184","ARC193","ARC182","ARC019","ARC059","ARC143","ARC079","ARC062","ARC020","ARC062","ARC106","ARC136","ARC107","ARC142","ARC075","ARC001"
        },
        -- pack #5 in box #51
        [5] = {
            "ARC196","ARC180","ARC192","ARC206","ARC050","ARC175","ARC066","ARC079","ARC028","ARC063","ARC021","ARC134","ARC099","ARC140","ARC111","ARC112","ARC076"
        },
        -- pack #6 in box #51
        [6] = {
            "ARC212","ARC191","ARC203","ARC196","ARC055","ARC120","ARC103","ARC117","ARC037","ARC073","ARC035","ARC064","ARC108","ARC139","ARC097","ARC112","ARC076"
        },
        -- pack #7 in box #51
        [7] = {
            "ARC213","ARC201","ARC191","ARC206","ARC125","ARC056","ARC198","ARC152","ARC074","ARC023","ARC070","ARC028","ARC138","ARC111","ARC145","ARC003","ARC038"
        },
        -- pack #8 in box #51
        [8] = {
            "ARC192","ARC195","ARC191","ARC207","ARC053","ARC015","ARC210","ARC155","ARC068","ARC022","ARC064","ARC026","ARC138","ARC106","ARC144","ARC076","ARC114"
        },
        -- pack #9 in box #51
        [9] = {
            "ARC180","ARC203","ARC185","ARC206","ARC174","ARC122","ARC134","ARC117","ARC064","ARC021","ARC073","ARC109","ARC148","ARC097","ARC147","ARC001","ARC112"
        },
        -- pack #10 in box #51
        [10] = {
            "ARC206","ARC178","ARC176","ARC188","ARC093","ARC127","ARC089","ARC156","ARC068","ARC022","ARC074","ARC031","ARC134","ARC094","ARC132","ARC001","ARC003"
        },
        -- pack #11 in box #51
        [11] = {
            "ARC203","ARC181","ARC194","ARC193","ARC016","ARC123","ARC020","ARC158","ARC069","ARC025","ARC073","ARC099","ARC135","ARC106","ARC137","ARC114","ARC112"
        },
        -- pack #12 in box #51
        [12] = {
            "ARC188","ARC185","ARC207","ARC183","ARC166","ARC019","ARC149","ARC042","ARC027","ARC070","ARC023","ARC060","ARC109","ARC149","ARC096","ARC039","ARC114"
        },
        -- pack #13 in box #51
        [13] = {
            "ARC179","ARC207","ARC207","ARC183","ARC131","ARC131","ARC212","ARC151","ARC032","ARC070","ARC031","ARC065","ARC094","ARC134","ARC100","ARC112","ARC001"
        },
        -- pack #14 in box #51
        [14] = {
            "ARC206","ARC177","ARC190","ARC196","ARC011","ARC044","ARC093","ARC005","ARC032","ARC071","ARC035","ARC145","ARC098","ARC134","ARC111","ARC003","ARC040"
        },
        -- pack #15 in box #51
        [15] = {
            "ARC192","ARC193","ARC195","ARC182","ARC126","ARC057","ARC158","ARC154","ARC061","ARC036","ARC065","ARC109","ARC137","ARC105","ARC142","ARC003","ARC039"
        },
        -- pack #16 in box #51
        [16] = {
            "ARC212","ARC214","ARC204","ARC196","ARC171","ARC047","ARC021","ARC005","ARC069","ARC021","ARC063","ARC030","ARC133","ARC101","ARC136","ARC038","ARC003"
        },
        -- pack #17 in box #51
        [17] = {
            "ARC182","ARC176","ARC208","ARC209","ARC123","ARC170","ARC056","ARC154","ARC029","ARC061","ARC026","ARC133","ARC110","ARC132","ARC104","ARC003","ARC002"
        },
        -- pack #18 in box #51
        [18] = {
            "ARC196","ARC207","ARC181","ARC181","ARC129","ARC119","ARC091","ARC151","ARC066","ARC023","ARC072","ARC022","ARC138","ARC111","ARC145","ARC040","ARC075"
        },
        -- pack #19 in box #51
        [19] = {
            "ARC176","ARC201","ARC176","ARC216","ARC168","ARC054","ARC107","ARC152","ARC021","ARC064","ARC023","ARC070","ARC096","ARC149","ARC103","ARC003","ARC002"
        },
        -- pack #20 in box #51
        [20] = {
            "ARC209","ARC203","ARC190","ARC183","ARC014","ARC123","ARC022","ARC157","ARC067","ARC023","ARC071","ARC102","ARC137","ARC111","ARC138","ARC112","ARC113"
        },
        -- pack #21 in box #51
        [21] = {
            "ARC176","ARC192","ARC180","ARC181","ARC085","ARC125","ARC169","ARC152","ARC071","ARC029","ARC066","ARC096","ARC149","ARC098","ARC135","ARC039","ARC002"
        },
        -- pack #22 in box #51
        [22] = {
            "ARC204","ARC181","ARC206","ARC213","ARC016","ARC162","ARC109","ARC158","ARC028","ARC073","ARC031","ARC065","ARC107","ARC141","ARC103","ARC112","ARC075"
        },
        -- pack #23 in box #51
        [23] = {
            "ARC195","ARC213","ARC213","ARC192","ARC175","ARC055","ARC198","ARC154","ARC022","ARC062","ARC028","ARC072","ARC100","ARC140","ARC107","ARC040","ARC039"
        },
        -- pack #24 in box #51
        [24] = {
            "ARC214","ARC207","ARC196","ARC191","ARC166","ARC085","ARC052","ARC154","ARC060","ARC024","ARC071","ARC022","ARC144","ARC095","ARC141","ARC038","ARC001"
        },
    },
    -- box #52
    [52] = {
        -- pack #1 in box #52
        [1] = {
            "ARC201","ARC181","ARC197","ARC202","ARC086","ARC174","ARC201","ARC151","ARC069","ARC030","ARC068","ARC110","ARC132","ARC109","ARC138","ARC218"
        },
        -- pack #2 in box #52
        [2] = {
            "ARC198","ARC209","ARC200","ARC212","ARC015","ARC169","ARC190","ARC151","ARC063","ARC034","ARC064","ARC096","ARC146","ARC098","ARC147","ARC218"
        },
        -- pack #3 in box #52
        [3] = {
            "ARC202","ARC178","ARC181","ARC187","ARC130","ARC171","ARC208","ARC154","ARC034","ARC072","ARC036","ARC132","ARC110","ARC149","ARC099","ARC115","ARC003"
        },
        -- pack #4 in box #52
        [4] = {
            "ARC201","ARC183","ARC194","ARC183","ARC011","ARC163","ARC199","ARC042","ARC033","ARC062","ARC028","ARC148","ARC099","ARC145","ARC094","ARC040","ARC114"
        },
        -- pack #5 in box #52
        [5] = {
            "ARC190","ARC208","ARC179","ARC180","ARC172","ARC161","ARC136","ARC079","ARC026","ARC065","ARC025","ARC068","ARC096","ARC137","ARC097","ARC218"
        },
        -- pack #6 in box #52
        [6] = {
            "ARC183","ARC200","ARC194","ARC178","ARC018","ARC126","ARC108","ARC152","ARC070","ARC025","ARC064","ARC098","ARC136","ARC099","ARC145","ARC001","ARC113"
        },
        -- pack #7 in box #52
        [7] = {
            "ARC187","ARC178","ARC192","ARC202","ARC092","ARC172","ARC019","ARC153","ARC060","ARC032","ARC065","ARC099","ARC148","ARC098","ARC136","ARC114","ARC115"
        },
        -- pack #8 in box #52
        [8] = {
            "ARC197","ARC207","ARC207","ARC201","ARC050","ARC086","ARC023","ARC157","ARC074","ARC028","ARC073","ARC102","ARC133","ARC109","ARC149","ARC001","ARC075"
        },
        -- pack #9 in box #52
        [9] = {
            "ARC180","ARC195","ARC189","ARC209","ARC173","ARC171","ARC085","ARC079","ARC023","ARC062","ARC026","ARC072","ARC106","ARC142","ARC107","ARC112","ARC002"
        },
        -- pack #10 in box #52
        [10] = {
            "ARC177","ARC179","ARC211","ARC211","ARC015","ARC121","ARC140","ARC153","ARC063","ARC028","ARC061","ARC024","ARC147","ARC102","ARC141","ARC039","ARC003"
        },
        -- pack #11 in box #52
        [11] = {
            "ARC178","ARC200","ARC211","ARC181","ARC128","ARC049","ARC061","ARC158","ARC025","ARC073","ARC021","ARC069","ARC100","ARC133","ARC110","ARC040","ARC038"
        },
        -- pack #12 in box #52
        [12] = {
            "ARC206","ARC210","ARC195","ARC178","ARC175","ARC167","ARC132","ARC154","ARC034","ARC063","ARC025","ARC063","ARC099","ARC132","ARC105","ARC115","ARC002"
        },
        -- pack #13 in box #52
        [13] = {
            "ARC211","ARC216","ARC214","ARC215","ARC165","ARC048","ARC109","ARC153","ARC027","ARC071","ARC031","ARC147","ARC109","ARC140","ARC097","ARC077","ARC002"
        },
        -- pack #14 in box #52
        [14] = {
            "ARC185","ARC202","ARC210","ARC213","ARC170","ARC045","ARC147","ARC042","ARC060","ARC035","ARC067","ARC023","ARC139","ARC102","ARC143","ARC002","ARC114"
        },
        -- pack #15 in box #52
        [15] = {
            "ARC197","ARC214","ARC179","ARC210","ARC090","ARC124","ARC073","ARC154","ARC070","ARC035","ARC066","ARC111","ARC146","ARC105","ARC144","ARC115","ARC039"
        },
        -- pack #16 in box #52
        [16] = {
            "ARC217","ARC184","ARC191","ARC182","ARC173","ARC012","ARC054","ARC117","ARC026","ARC070","ARC034","ARC074","ARC096","ARC132","ARC104","ARC003","ARC075"
        },
        -- pack #17 in box #52
        [17] = {
            "ARC183","ARC193","ARC177","ARC184","ARC170","ARC081","ARC188","ARC155","ARC027","ARC064","ARC033","ARC071","ARC094","ARC144","ARC100","ARC039","ARC112"
        },
        -- pack #18 in box #52
        [18] = {
            "ARC184","ARC199","ARC216","ARC198","ARC052","ARC055","ARC088","ARC156","ARC066","ARC036","ARC065","ARC024","ARC138","ARC107","ARC144","ARC001","ARC003"
        },
        -- pack #19 in box #52
        [19] = {
            "ARC191","ARC188","ARC216","ARC207","ARC166","ARC130","ARC134","ARC158","ARC034","ARC067","ARC023","ARC135","ARC104","ARC149","ARC098","ARC001","ARC003"
        },
        -- pack #20 in box #52
        [20] = {
            "ARC202","ARC181","ARC213","ARC205","ARC123","ARC047","ARC128","ARC154","ARC065","ARC029","ARC063","ARC023","ARC134","ARC099","ARC132","ARC114","ARC039"
        },
        -- pack #21 in box #52
        [21] = {
            "ARC204","ARC201","ARC191","ARC185","ARC016","ARC019","ARC110","ARC158","ARC026","ARC061","ARC030","ARC148","ARC097","ARC145","ARC094","ARC002","ARC075"
        },
        -- pack #22 in box #52
        [22] = {
            "ARC202","ARC204","ARC211","ARC182","ARC166","ARC172","ARC136","ARC117","ARC063","ARC035","ARC067","ARC023","ARC144","ARC094","ARC132","ARC040","ARC112"
        },
        -- pack #23 in box #52
        [23] = {
            "ARC182","ARC211","ARC200","ARC187","ARC124","ARC170","ARC197","ARC151","ARC033","ARC065","ARC030","ARC149","ARC094","ARC137","ARC096","ARC003","ARC001"
        },
        -- pack #24 in box #52
        [24] = {
            "ARC203","ARC196","ARC197","ARC205","ARC049","ARC122","ARC177","ARC042","ARC063","ARC031","ARC067","ARC031","ARC142","ARC105","ARC143","ARC076","ARC001"
        },
    },
    -- box #53
    [53] = {
        -- pack #1 in box #53
        [1] = {
            "ARC202","ARC214","ARC205","ARC216","ARC012","ARC130","ARC208","ARC157","ARC062","ARC027","ARC061","ARC107","ARC145","ARC099","ARC135","ARC077","ARC003"
        },
        -- pack #2 in box #53
        [2] = {
            "ARC206","ARC205","ARC194","ARC215","ARC127","ARC057","ARC035","ARC117","ARC066","ARC035","ARC067","ARC032","ARC144","ARC109","ARC142","ARC114","ARC076"
        },
        -- pack #3 in box #53
        [3] = {
            "ARC176","ARC184","ARC187","ARC192","ARC127","ARC082","ARC158","ARC151","ARC020","ARC060","ARC025","ARC066","ARC100","ARC148","ARC103","ARC002","ARC075"
        },
        -- pack #4 in box #53
        [4] = {
            "ARC202","ARC176","ARC205","ARC213","ARC123","ARC131","ARC029","ARC156","ARC034","ARC070","ARC029","ARC070","ARC101","ARC149","ARC102","ARC075","ARC077"
        },
        -- pack #5 in box #53
        [5] = {
            "ARC198","ARC191","ARC179","ARC206","ARC125","ARC088","ARC213","ARC151","ARC069","ARC029","ARC061","ARC028","ARC146","ARC098","ARC132","ARC038","ARC040"
        },
        -- pack #6 in box #53
        [6] = {
            "ARC184","ARC184","ARC214","ARC182","ARC011","ARC052","ARC025","ARC079","ARC069","ARC021","ARC068","ARC030","ARC144","ARC094","ARC148","ARC040","ARC001"
        },
        -- pack #7 in box #53
        [7] = {
            "ARC192","ARC215","ARC208","ARC203","ARC087","ARC058","ARC191","ARC117","ARC021","ARC073","ARC026","ARC138","ARC100","ARC145","ARC102","ARC115","ARC112"
        },
        -- pack #8 in box #53
        [8] = {
            "ARC178","ARC184","ARC177","ARC201","ARC016","ARC120","ARC107","ARC079","ARC020","ARC060","ARC030","ARC063","ARC100","ARC136","ARC102","ARC039","ARC113"
        },
        -- pack #9 in box #53
        [9] = {
            "ARC193","ARC211","ARC216","ARC208","ARC085","ARC055","ARC037","ARC151","ARC023","ARC073","ARC026","ARC064","ARC108","ARC147","ARC100","ARC003","ARC077"
        },
        -- pack #10 in box #53
        [10] = {
            "ARC177","ARC207","ARC213","ARC196","ARC085","ARC093","ARC066","ARC042","ARC029","ARC065","ARC029","ARC063","ARC094","ARC140","ARC097","ARC077","ARC076"
        },
        -- pack #11 in box #53
        [11] = {
            "ARC208","ARC214","ARC206","ARC191","ARC164","ARC048","ARC207","ARC154","ARC070","ARC025","ARC072","ARC020","ARC149","ARC098","ARC145","ARC038","ARC001"
        },
        -- pack #12 in box #53
        [12] = {
            "ARC213","ARC198","ARC215","ARC204","ARC058","ARC050","ARC203","ARC005","ARC064","ARC024","ARC063","ARC108","ARC139","ARC097","ARC144","ARC114","ARC039"
        },
        -- pack #13 in box #53
        [13] = {
            "ARC200","ARC180","ARC187","ARC182","ARC018","ARC047","ARC127","ARC151","ARC035","ARC064","ARC037","ARC141","ARC098","ARC136","ARC107","ARC040","ARC114"
        },
        -- pack #14 in box #53
        [14] = {
            "ARC184","ARC194","ARC186","ARC211","ARC091","ARC168","ARC152","ARC042","ARC029","ARC065","ARC032","ARC143","ARC099","ARC147","ARC100","ARC075","ARC002"
        },
        -- pack #15 in box #53
        [15] = {
            "ARC201","ARC203","ARC178","ARC189","ARC018","ARC120","ARC144","ARC156","ARC061","ARC037","ARC069","ARC110","ARC137","ARC108","ARC149","ARC003","ARC076"
        },
        -- pack #16 in box #53
        [16] = {
            "ARC213","ARC180","ARC177","ARC176","ARC055","ARC055","ARC196","ARC157","ARC029","ARC065","ARC033","ARC065","ARC110","ARC140","ARC107","ARC115","ARC113"
        },
        -- pack #17 in box #53
        [17] = {
            "ARC212","ARC212","ARC204","ARC204","ARC123","ARC168","ARC056","ARC005","ARC025","ARC068","ARC023","ARC139","ARC100","ARC137","ARC096","ARC002","ARC076"
        },
        -- pack #18 in box #53
        [18] = {
            "ARC215","ARC192","ARC203","ARC183","ARC019","ARC128","ARC192","ARC157","ARC022","ARC061","ARC021","ARC147","ARC100","ARC134","ARC109","ARC077","ARC002"
        },
        -- pack #19 in box #53
        [19] = {
            "ARC184","ARC196","ARC197","ARC209","ARC092","ARC120","ARC149","ARC154","ARC067","ARC026","ARC074","ARC025","ARC133","ARC102","ARC146","ARC040","ARC112"
        },
        -- pack #20 in box #53
        [20] = {
            "ARC205","ARC181","ARC211","ARC200","ARC127","ARC013","ARC063","ARC117","ARC026","ARC069","ARC027","ARC136","ARC095","ARC140","ARC098","ARC076","ARC003"
        },
        -- pack #21 in box #53
        [21] = {
            "ARC191","ARC202","ARC188","ARC199","ARC057","ARC014","ARC107","ARC154","ARC060","ARC028","ARC066","ARC100","ARC149","ARC095","ARC141","ARC001","ARC114"
        },
        -- pack #22 in box #53
        [22] = {
            "ARC177","ARC216","ARC208","ARC192","ARC052","ARC166","ARC183","ARC042","ARC060","ARC024","ARC065","ARC023","ARC141","ARC105","ARC145","ARC114","ARC002"
        },
        -- pack #23 in box #53
        [23] = {
            "ARC217","ARC184","ARC183","ARC211","ARC172","ARC119","ARC073","ARC156","ARC068","ARC030","ARC062","ARC109","ARC145","ARC094","ARC135","ARC038","ARC114"
        },
        -- pack #24 in box #53
        [24] = {
            "ARC206","ARC200","ARC202","ARC216","ARC014","ARC087","ARC106","ARC005","ARC068","ARC034","ARC073","ARC107","ARC142","ARC110","ARC143","ARC039","ARC003"
        },
    },
    -- box #54
    [54] = {
        -- pack #1 in box #54
        [1] = {
            "ARC182","ARC210","ARC191","ARC216","ARC168","ARC167","ARC197","ARC117","ARC020","ARC067","ARC030","ARC063","ARC097","ARC143","ARC109","ARC040","ARC112"
        },
        -- pack #2 in box #54
        [2] = {
            "ARC187","ARC206","ARC189","ARC179","ARC016","ARC054","ARC183","ARC079","ARC066","ARC032","ARC069","ARC030","ARC148","ARC111","ARC139","ARC077","ARC075"
        },
        -- pack #3 in box #54
        [3] = {
            "ARC185","ARC176","ARC199","ARC178","ARC088","ARC008","ARC181","ARC156","ARC027","ARC062","ARC032","ARC069","ARC109","ARC139","ARC108","ARC114","ARC112"
        },
        -- pack #4 in box #54
        [4] = {
            "ARC203","ARC194","ARC191","ARC209","ARC052","ARC164","ARC019","ARC117","ARC074","ARC031","ARC068","ARC024","ARC140","ARC100","ARC132","ARC001","ARC114"
        },
        -- pack #5 in box #54
        [5] = {
            "ARC185","ARC209","ARC193","ARC189","ARC088","ARC010","ARC216","ARC151","ARC033","ARC066","ARC027","ARC073","ARC095","ARC142","ARC101","ARC112","ARC039"
        },
        -- pack #6 in box #54
        [6] = {
            "ARC214","ARC189","ARC197","ARC189","ARC051","ARC166","ARC047","ARC157","ARC034","ARC065","ARC035","ARC064","ARC108","ARC136","ARC110","ARC003","ARC040"
        },
        -- pack #7 in box #54
        [7] = {
            "ARC211","ARC203","ARC191","ARC196","ARC086","ARC160","ARC126","ARC042","ARC073","ARC034","ARC069","ARC108","ARC146","ARC107","ARC138","ARC113","ARC039"
        },
        -- pack #8 in box #54
        [8] = {
            "ARC208","ARC193","ARC200","ARC217","ARC086","ARC166","ARC108","ARC154","ARC026","ARC061","ARC024","ARC142","ARC094","ARC141","ARC108","ARC112","ARC115"
        },
        -- pack #9 in box #54
        [9] = {
            "ARC216","ARC183","ARC214","ARC202","ARC125","ARC053","ARC064","ARC157","ARC060","ARC024","ARC060","ARC025","ARC142","ARC102","ARC133","ARC115","ARC040"
        },
        -- pack #10 in box #54
        [10] = {
            "ARC180","ARC216","ARC212","ARC205","ARC056","ARC126","ARC146","ARC157","ARC027","ARC070","ARC026","ARC146","ARC106","ARC134","ARC101","ARC002","ARC077"
        },
        -- pack #11 in box #54
        [11] = {
            "ARC178","ARC189","ARC188","ARC187","ARC089","ARC125","ARC195","ARC154","ARC027","ARC065","ARC032","ARC142","ARC096","ARC145","ARC094","ARC075","ARC077"
        },
        -- pack #12 in box #54
        [12] = {
            "ARC183","ARC208","ARC178","ARC182","ARC013","ARC084","ARC200","ARC042","ARC071","ARC026","ARC066","ARC024","ARC135","ARC101","ARC149","ARC076","ARC003"
        },
        -- pack #13 in box #54
        [13] = {
            "ARC186","ARC217","ARC186","ARC213","ARC093","ARC161","ARC097","ARC079","ARC030","ARC068","ARC029","ARC134","ARC103","ARC133","ARC101","ARC040","ARC003"
        },
        -- pack #14 in box #54
        [14] = {
            "ARC183","ARC186","ARC198","ARC193","ARC129","ARC011","ARC047","ARC151","ARC035","ARC073","ARC036","ARC148","ARC098","ARC140","ARC109","ARC039","ARC038"
        },
        -- pack #15 in box #54
        [15] = {
            "ARC189","ARC215","ARC214","ARC207","ARC017","ARC012","ARC074","ARC117","ARC063","ARC028","ARC063","ARC110","ARC145","ARC106","ARC132","ARC075","ARC001"
        },
        -- pack #16 in box #54
        [16] = {
            "ARC204","ARC196","ARC201","ARC210","ARC086","ARC091","ARC161","ARC151","ARC066","ARC032","ARC071","ARC106","ARC140","ARC095","ARC132","ARC113","ARC076"
        },
        -- pack #17 in box #54
        [17] = {
            "ARC199","ARC191","ARC201","ARC190","ARC127","ARC057","ARC069","ARC042","ARC064","ARC027","ARC068","ARC107","ARC144","ARC102","ARC145","ARC002","ARC115"
        },
        -- pack #18 in box #54
        [18] = {
            "ARC187","ARC203","ARC217","ARC193","ARC164","ARC018","ARC059","ARC151","ARC026","ARC068","ARC029","ARC141","ARC100","ARC144","ARC095","ARC218"
        },
        -- pack #19 in box #54
        [19] = {
            "ARC210","ARC205","ARC210","ARC204","ARC125","ARC126","ARC037","ARC158","ARC068","ARC032","ARC074","ARC111","ARC140","ARC094","ARC136","ARC003","ARC115"
        },
        -- pack #20 in box #54
        [20] = {
            "ARC178","ARC206","ARC213","ARC216","ARC125","ARC049","ARC117","ARC154","ARC026","ARC060","ARC034","ARC066","ARC094","ARC140","ARC094","ARC039","ARC003"
        },
        -- pack #21 in box #54
        [21] = {
            "ARC188","ARC216","ARC197","ARC215","ARC127","ARC119","ARC195","ARC152","ARC068","ARC025","ARC069","ARC111","ARC148","ARC110","ARC142","ARC038","ARC001"
        },
        -- pack #22 in box #54
        [22] = {
            "ARC201","ARC214","ARC208","ARC185","ARC167","ARC131","ARC010","ARC153","ARC025","ARC074","ARC021","ARC065","ARC101","ARC147","ARC109","ARC038","ARC114"
        },
        -- pack #23 in box #54
        [23] = {
            "ARC217","ARC208","ARC212","ARC209","ARC055","ARC131","ARC101","ARC005","ARC061","ARC023","ARC074","ARC033","ARC133","ARC096","ARC132","ARC039","ARC003"
        },
        -- pack #24 in box #54
        [24] = {
            "ARC208","ARC181","ARC177","ARC216","ARC127","ARC016","ARC117","ARC157","ARC073","ARC022","ARC067","ARC034","ARC134","ARC106","ARC149","ARC001","ARC003"
        },
    },
    -- box #55
    [55] = {
        -- pack #1 in box #55
        [1] = {
            "ARC193","ARC181","ARC208","ARC210","ARC168","ARC131","ARC135","ARC151","ARC026","ARC072","ARC035","ARC139","ARC107","ARC142","ARC109","ARC003","ARC112"
        },
        -- pack #2 in box #55
        [2] = {
            "ARC182","ARC208","ARC197","ARC192","ARC175","ARC091","ARC116","ARC154","ARC034","ARC060","ARC028","ARC072","ARC111","ARC149","ARC106","ARC001","ARC112"
        },
        -- pack #3 in box #55
        [3] = {
            "ARC199","ARC190","ARC194","ARC211","ARC172","ARC125","ARC005","ARC155","ARC070","ARC031","ARC069","ARC030","ARC139","ARC098","ARC143","ARC112","ARC002"
        },
        -- pack #4 in box #55
        [4] = {
            "ARC180","ARC211","ARC186","ARC207","ARC085","ARC086","ARC116","ARC151","ARC069","ARC034","ARC062","ARC097","ARC138","ARC099","ARC134","ARC076","ARC114"
        },
        -- pack #5 in box #55
        [5] = {
            "ARC202","ARC189","ARC216","ARC192","ARC171","ARC089","ARC106","ARC157","ARC061","ARC020","ARC069","ARC108","ARC138","ARC101","ARC142","ARC114","ARC113"
        },
        -- pack #6 in box #55
        [6] = {
            "ARC180","ARC202","ARC191","ARC193","ARC129","ARC011","ARC153","ARC153","ARC069","ARC026","ARC062","ARC028","ARC142","ARC110","ARC134","ARC077","ARC112"
        },
        -- pack #7 in box #55
        [7] = {
            "ARC190","ARC190","ARC204","ARC207","ARC058","ARC159","ARC210","ARC153","ARC064","ARC023","ARC073","ARC111","ARC142","ARC097","ARC144","ARC003","ARC040"
        },
        -- pack #8 in box #55
        [8] = {
            "ARC203","ARC211","ARC176","ARC184","ARC124","ARC091","ARC064","ARC156","ARC025","ARC066","ARC036","ARC147","ARC109","ARC139","ARC097","ARC040","ARC001"
        },
        -- pack #9 in box #55
        [9] = {
            "ARC206","ARC202","ARC209","ARC206","ARC018","ARC129","ARC106","ARC158","ARC060","ARC021","ARC061","ARC107","ARC149","ARC098","ARC149","ARC038","ARC076"
        },
        -- pack #10 in box #55
        [10] = {
            "ARC217","ARC178","ARC211","ARC188","ARC087","ARC123","ARC180","ARC079","ARC029","ARC063","ARC028","ARC063","ARC095","ARC148","ARC099","ARC115","ARC002"
        },
        -- pack #11 in box #55
        [11] = {
            "ARC192","ARC191","ARC201","ARC177","ARC168","ARC084","ARC070","ARC005","ARC060","ARC020","ARC073","ARC020","ARC136","ARC109","ARC134","ARC038","ARC112"
        },
        -- pack #12 in box #55
        [12] = {
            "ARC197","ARC189","ARC183","ARC182","ARC171","ARC124","ARC095","ARC158","ARC023","ARC066","ARC031","ARC065","ARC103","ARC146","ARC108","ARC112","ARC115"
        },
        -- pack #13 in box #55
        [13] = {
            "ARC215","ARC178","ARC216","ARC182","ARC055","ARC014","ARC105","ARC154","ARC020","ARC063","ARC021","ARC067","ARC108","ARC133","ARC095","ARC039","ARC112"
        },
        -- pack #14 in box #55
        [14] = {
            "ARC190","ARC213","ARC212","ARC207","ARC054","ARC092","ARC215","ARC117","ARC066","ARC036","ARC061","ARC028","ARC144","ARC109","ARC144","ARC112","ARC075"
        },
        -- pack #15 in box #55
        [15] = {
            "ARC191","ARC197","ARC217","ARC213","ARC126","ARC009","ARC104","ARC005","ARC071","ARC037","ARC067","ARC104","ARC142","ARC111","ARC133","ARC075","ARC040"
        },
        -- pack #16 in box #55
        [16] = {
            "ARC199","ARC190","ARC184","ARC187","ARC018","ARC123","ARC110","ARC156","ARC025","ARC066","ARC033","ARC069","ARC094","ARC143","ARC101","ARC115","ARC039"
        },
        -- pack #17 in box #55
        [17] = {
            "ARC187","ARC195","ARC211","ARC215","ARC016","ARC169","ARC013","ARC151","ARC034","ARC061","ARC033","ARC066","ARC107","ARC138","ARC097","ARC114","ARC076"
        },
        -- pack #18 in box #55
        [18] = {
            "ARC178","ARC182","ARC184","ARC176","ARC019","ARC008","ARC026","ARC151","ARC071","ARC027","ARC064","ARC109","ARC143","ARC097","ARC145","ARC112","ARC113"
        },
        -- pack #19 in box #55
        [19] = {
            "ARC202","ARC199","ARC177","ARC207","ARC165","ARC082","ARC211","ARC151","ARC024","ARC065","ARC029","ARC136","ARC110","ARC133","ARC102","ARC038","ARC077"
        },
        -- pack #20 in box #55
        [20] = {
            "ARC196","ARC188","ARC190","ARC199","ARC019","ARC164","ARC187","ARC117","ARC027","ARC074","ARC020","ARC139","ARC108","ARC139","ARC102","ARC114","ARC115"
        },
        -- pack #21 in box #55
        [21] = {
            "ARC214","ARC184","ARC202","ARC196","ARC012","ARC162","ARC065","ARC152","ARC028","ARC073","ARC034","ARC140","ARC100","ARC132","ARC106","ARC077","ARC115"
        },
        -- pack #22 in box #55
        [22] = {
            "ARC176","ARC196","ARC176","ARC189","ARC014","ARC053","ARC096","ARC005","ARC063","ARC029","ARC060","ARC023","ARC132","ARC101","ARC144","ARC003","ARC077"
        },
        -- pack #23 in box #55
        [23] = {
            "ARC211","ARC187","ARC177","ARC200","ARC049","ARC050","ARC059","ARC156","ARC073","ARC024","ARC060","ARC031","ARC144","ARC110","ARC146","ARC115","ARC003"
        },
        -- pack #24 in box #55
        [24] = {
            "ARC181","ARC183","ARC208","ARC200","ARC014","ARC127","ARC209","ARC152","ARC034","ARC066","ARC035","ARC136","ARC106","ARC143","ARC107","ARC113","ARC002"
        },
    },
    -- box #56
    [56] = {
        -- pack #1 in box #56
        [1] = {
            "ARC187","ARC212","ARC187","ARC194","ARC050","ARC017","ARC148","ARC154","ARC030","ARC062","ARC031","ARC067","ARC104","ARC137","ARC111","ARC112","ARC003"
        },
        -- pack #2 in box #56
        [2] = {
            "ARC201","ARC179","ARC195","ARC178","ARC015","ARC089","ARC136","ARC117","ARC068","ARC036","ARC062","ARC037","ARC141","ARC099","ARC146","ARC115","ARC003"
        },
        -- pack #3 in box #56
        [3] = {
            "ARC179","ARC178","ARC204","ARC176","ARC128","ARC043","ARC204","ARC156","ARC068","ARC030","ARC061","ARC035","ARC132","ARC099","ARC149","ARC001","ARC075"
        },
        -- pack #4 in box #56
        [4] = {
            "ARC209","ARC201","ARC190","ARC207","ARC058","ARC048","ARC170","ARC042","ARC030","ARC074","ARC025","ARC145","ARC103","ARC136","ARC096","ARC039","ARC002"
        },
        -- pack #5 in box #56
        [5] = {
            "ARC176","ARC179","ARC196","ARC195","ARC170","ARC049","ARC152","ARC157","ARC034","ARC061","ARC027","ARC072","ARC106","ARC140","ARC107","ARC076","ARC112"
        },
        -- pack #6 in box #56
        [6] = {
            "ARC205","ARC186","ARC212","ARC197","ARC054","ARC172","ARC101","ARC154","ARC065","ARC031","ARC073","ARC105","ARC135","ARC108","ARC135","ARC075","ARC001"
        },
        -- pack #7 in box #56
        [7] = {
            "ARC211","ARC187","ARC192","ARC208","ARC170","ARC123","ARC126","ARC157","ARC062","ARC037","ARC070","ARC028","ARC143","ARC111","ARC143","ARC038","ARC114"
        },
        -- pack #8 in box #56
        [8] = {
            "ARC203","ARC217","ARC198","ARC178","ARC012","ARC089","ARC129","ARC152","ARC070","ARC025","ARC071","ARC099","ARC145","ARC103","ARC145","ARC115","ARC112"
        },
        -- pack #9 in box #56
        [9] = {
            "ARC207","ARC186","ARC199","ARC203","ARC016","ARC010","ARC097","ARC158","ARC032","ARC072","ARC023","ARC074","ARC107","ARC137","ARC094","ARC113","ARC001"
        },
        -- pack #10 in box #56
        [10] = {
            "ARC187","ARC182","ARC212","ARC216","ARC050","ARC016","ARC214","ARC158","ARC023","ARC066","ARC030","ARC146","ARC101","ARC136","ARC101","ARC113","ARC115"
        },
        -- pack #11 in box #56
        [11] = {
            "ARC217","ARC200","ARC185","ARC180","ARC085","ARC048","ARC211","ARC153","ARC063","ARC028","ARC067","ARC032","ARC146","ARC096","ARC132","ARC076","ARC077"
        },
        -- pack #12 in box #56
        [12] = {
            "ARC204","ARC187","ARC199","ARC180","ARC167","ARC085","ARC173","ARC153","ARC031","ARC060","ARC029","ARC074","ARC106","ARC145","ARC097","ARC040","ARC113"
        },
        -- pack #13 in box #56
        [13] = {
            "ARC217","ARC182","ARC217","ARC197","ARC090","ARC165","ARC202","ARC155","ARC060","ARC032","ARC071","ARC103","ARC143","ARC108","ARC148","ARC115","ARC112"
        },
        -- pack #14 in box #56
        [14] = {
            "ARC209","ARC180","ARC216","ARC191","ARC059","ARC019","ARC067","ARC158","ARC029","ARC061","ARC037","ARC061","ARC102","ARC135","ARC108","ARC039","ARC112"
        },
        -- pack #15 in box #56
        [15] = {
            "ARC207","ARC188","ARC185","ARC183","ARC018","ARC083","ARC074","ARC155","ARC036","ARC068","ARC035","ARC142","ARC110","ARC146","ARC105","ARC115","ARC002"
        },
        -- pack #16 in box #56
        [16] = {
            "ARC177","ARC195","ARC206","ARC185","ARC131","ARC086","ARC123","ARC154","ARC027","ARC064","ARC032","ARC073","ARC105","ARC145","ARC107","ARC075","ARC113"
        },
        -- pack #17 in box #56
        [17] = {
            "ARC191","ARC193","ARC200","ARC198","ARC059","ARC010","ARC147","ARC155","ARC070","ARC030","ARC062","ARC102","ARC139","ARC096","ARC148","ARC113","ARC002"
        },
        -- pack #18 in box #56
        [18] = {
            "ARC176","ARC209","ARC216","ARC213","ARC127","ARC161","ARC036","ARC117","ARC036","ARC071","ARC032","ARC137","ARC096","ARC143","ARC101","ARC038","ARC112"
        },
        -- pack #19 in box #56
        [19] = {
            "ARC176","ARC200","ARC183","ARC176","ARC169","ARC085","ARC145","ARC152","ARC064","ARC021","ARC062","ARC021","ARC138","ARC108","ARC145","ARC038","ARC040"
        },
        -- pack #20 in box #56
        [20] = {
            "ARC193","ARC201","ARC200","ARC194","ARC012","ARC164","ARC145","ARC153","ARC021","ARC072","ARC026","ARC142","ARC107","ARC133","ARC108","ARC112","ARC001"
        },
        -- pack #21 in box #56
        [21] = {
            "ARC203","ARC189","ARC200","ARC200","ARC049","ARC175","ARC074","ARC079","ARC071","ARC025","ARC061","ARC099","ARC135","ARC094","ARC136","ARC075","ARC001"
        },
        -- pack #22 in box #56
        [22] = {
            "ARC198","ARC212","ARC200","ARC215","ARC124","ARC164","ARC042","ARC151","ARC060","ARC036","ARC062","ARC021","ARC138","ARC106","ARC132","ARC114","ARC077"
        },
        -- pack #23 in box #56
        [23] = {
            "ARC183","ARC192","ARC198","ARC216","ARC059","ARC165","ARC206","ARC153","ARC074","ARC033","ARC065","ARC108","ARC146","ARC102","ARC140","ARC114","ARC001"
        },
        -- pack #24 in box #56
        [24] = {
            "ARC194","ARC213","ARC202","ARC183","ARC088","ARC010","ARC193","ARC153","ARC020","ARC071","ARC031","ARC140","ARC098","ARC139","ARC097","ARC077","ARC039"
        },
    },
    -- box #57
    [57] = {
        -- pack #1 in box #57
        [1] = {
            "ARC211","ARC194","ARC203","ARC177","ARC087","ARC161","ARC142","ARC042","ARC033","ARC064","ARC036","ARC071","ARC100","ARC138","ARC101","ARC038","ARC112"
        },
        -- pack #2 in box #57
        [2] = {
            "ARC183","ARC191","ARC183","ARC207","ARC164","ARC160","ARC101","ARC158","ARC071","ARC036","ARC061","ARC033","ARC149","ARC099","ARC140","ARC113","ARC076"
        },
        -- pack #3 in box #57
        [3] = {
            "ARC197","ARC202","ARC190","ARC189","ARC048","ARC012","ARC020","ARC151","ARC035","ARC060","ARC035","ARC072","ARC109","ARC132","ARC101","ARC115","ARC003"
        },
        -- pack #4 in box #57
        [4] = {
            "ARC214","ARC185","ARC200","ARC209","ARC086","ARC131","ARC005","ARC005","ARC061","ARC032","ARC060","ARC034","ARC135","ARC095","ARC140","ARC112","ARC040"
        },
        -- pack #5 in box #57
        [5] = {
            "ARC180","ARC214","ARC210","ARC189","ARC056","ARC170","ARC093","ARC153","ARC035","ARC061","ARC027","ARC139","ARC100","ARC136","ARC111","ARC115","ARC002"
        },
        -- pack #6 in box #57
        [6] = {
            "ARC182","ARC180","ARC216","ARC197","ARC173","ARC162","ARC096","ARC153","ARC024","ARC072","ARC032","ARC148","ARC100","ARC145","ARC105","ARC038","ARC113"
        },
        -- pack #7 in box #57
        [7] = {
            "ARC217","ARC215","ARC193","ARC178","ARC164","ARC085","ARC022","ARC157","ARC035","ARC061","ARC035","ARC063","ARC102","ARC148","ARC100","ARC218"
        },
        -- pack #8 in box #57
        [8] = {
            "ARC199","ARC206","ARC184","ARC206","ARC129","ARC051","ARC199","ARC157","ARC067","ARC020","ARC067","ARC029","ARC133","ARC095","ARC143","ARC003","ARC114"
        },
        -- pack #9 in box #57
        [9] = {
            "ARC215","ARC194","ARC188","ARC197","ARC169","ARC049","ARC148","ARC157","ARC074","ARC020","ARC068","ARC096","ARC142","ARC097","ARC146","ARC002","ARC115"
        },
        -- pack #10 in box #57
        [10] = {
            "ARC207","ARC207","ARC195","ARC203","ARC173","ARC093","ARC190","ARC117","ARC028","ARC068","ARC022","ARC144","ARC098","ARC134","ARC107","ARC002","ARC038"
        },
        -- pack #11 in box #57
        [11] = {
            "ARC212","ARC210","ARC178","ARC193","ARC053","ARC123","ARC074","ARC155","ARC065","ARC022","ARC061","ARC101","ARC145","ARC096","ARC142","ARC077","ARC002"
        },
        -- pack #12 in box #57
        [12] = {
            "ARC212","ARC214","ARC188","ARC209","ARC130","ARC121","ARC086","ARC154","ARC060","ARC026","ARC063","ARC036","ARC149","ARC107","ARC141","ARC112","ARC113"
        },
        -- pack #13 in box #57
        [13] = {
            "ARC198","ARC208","ARC214","ARC194","ARC167","ARC008","ARC109","ARC117","ARC070","ARC028","ARC074","ARC097","ARC134","ARC105","ARC146","ARC002","ARC112"
        },
        -- pack #14 in box #57
        [14] = {
            "ARC205","ARC191","ARC196","ARC183","ARC048","ARC092","ARC177","ARC153","ARC063","ARC028","ARC073","ARC097","ARC132","ARC103","ARC139","ARC218"
        },
        -- pack #15 in box #57
        [15] = {
            "ARC183","ARC183","ARC192","ARC203","ARC017","ARC044","ARC165","ARC156","ARC062","ARC027","ARC064","ARC100","ARC144","ARC098","ARC139","ARC040","ARC113"
        },
        -- pack #16 in box #57
        [16] = {
            "ARC206","ARC186","ARC185","ARC202","ARC013","ARC015","ARC052","ARC155","ARC064","ARC035","ARC064","ARC099","ARC137","ARC108","ARC145","ARC114","ARC001"
        },
        -- pack #17 in box #57
        [17] = {
            "ARC210","ARC191","ARC209","ARC214","ARC165","ARC011","ARC007","ARC005","ARC030","ARC072","ARC034","ARC132","ARC108","ARC144","ARC102","ARC001","ARC003"
        },
        -- pack #18 in box #57
        [18] = {
            "ARC213","ARC202","ARC207","ARC194","ARC167","ARC012","ARC207","ARC153","ARC034","ARC068","ARC031","ARC142","ARC100","ARC144","ARC101","ARC218"
        },
        -- pack #19 in box #57
        [19] = {
            "ARC183","ARC176","ARC212","ARC201","ARC088","ARC171","ARC108","ARC156","ARC020","ARC068","ARC035","ARC145","ARC098","ARC144","ARC107","ARC039","ARC038"
        },
        -- pack #20 in box #57
        [20] = {
            "ARC195","ARC210","ARC176","ARC202","ARC085","ARC055","ARC208","ARC117","ARC031","ARC068","ARC028","ARC060","ARC095","ARC149","ARC095","ARC115","ARC112"
        },
        -- pack #21 in box #57
        [21] = {
            "ARC177","ARC197","ARC202","ARC212","ARC090","ARC007","ARC196","ARC155","ARC032","ARC071","ARC020","ARC069","ARC108","ARC136","ARC111","ARC002","ARC076"
        },
        -- pack #22 in box #57
        [22] = {
            "ARC205","ARC181","ARC180","ARC176","ARC090","ARC125","ARC158","ARC155","ARC072","ARC034","ARC074","ARC030","ARC136","ARC102","ARC145","ARC040","ARC077"
        },
        -- pack #23 in box #57
        [23] = {
            "ARC197","ARC185","ARC187","ARC181","ARC090","ARC170","ARC094","ARC079","ARC062","ARC030","ARC062","ARC037","ARC141","ARC099","ARC142","ARC218"
        },
        -- pack #24 in box #57
        [24] = {
            "ARC192","ARC197","ARC208","ARC186","ARC166","ARC085","ARC067","ARC155","ARC020","ARC072","ARC021","ARC064","ARC105","ARC149","ARC101","ARC075","ARC003"
        },
    },
    -- box #58
    [58] = {
        -- pack #1 in box #58
        [1] = {
            "ARC199","ARC194","ARC193","ARC179","ARC058","ARC164","ARC150","ARC117","ARC060","ARC031","ARC072","ARC110","ARC133","ARC108","ARC133","ARC039","ARC003"
        },
        -- pack #2 in box #58
        [2] = {
            "ARC214","ARC182","ARC202","ARC192","ARC048","ARC082","ARC156","ARC158","ARC066","ARC030","ARC072","ARC098","ARC149","ARC095","ARC132","ARC112","ARC076"
        },
        -- pack #3 in box #58
        [3] = {
            "ARC186","ARC190","ARC193","ARC210","ARC087","ARC059","ARC085","ARC079","ARC070","ARC020","ARC064","ARC024","ARC146","ARC094","ARC148","ARC113","ARC112"
        },
        -- pack #4 in box #58
        [4] = {
            "ARC214","ARC177","ARC182","ARC197","ARC054","ARC016","ARC037","ARC005","ARC021","ARC071","ARC027","ARC139","ARC110","ARC140","ARC106","ARC040","ARC038"
        },
        -- pack #5 in box #58
        [5] = {
            "ARC176","ARC217","ARC194","ARC213","ARC170","ARC088","ARC068","ARC157","ARC068","ARC025","ARC064","ARC030","ARC144","ARC108","ARC138","ARC040","ARC075"
        },
        -- pack #6 in box #58
        [6] = {
            "ARC215","ARC190","ARC209","ARC210","ARC175","ARC086","ARC101","ARC042","ARC037","ARC073","ARC026","ARC066","ARC097","ARC135","ARC111","ARC113","ARC039"
        },
        -- pack #7 in box #58
        [7] = {
            "ARC183","ARC213","ARC216","ARC178","ARC057","ARC122","ARC143","ARC079","ARC021","ARC062","ARC032","ARC071","ARC101","ARC148","ARC101","ARC075","ARC001"
        },
        -- pack #8 in box #58
        [8] = {
            "ARC213","ARC200","ARC215","ARC214","ARC130","ARC160","ARC176","ARC151","ARC032","ARC061","ARC036","ARC070","ARC094","ARC149","ARC096","ARC115","ARC076"
        },
        -- pack #9 in box #58
        [9] = {
            "ARC190","ARC205","ARC202","ARC177","ARC165","ARC168","ARC181","ARC158","ARC035","ARC060","ARC022","ARC138","ARC110","ARC138","ARC103","ARC075","ARC039"
        },
        -- pack #10 in box #58
        [10] = {
            "ARC207","ARC208","ARC179","ARC216","ARC092","ARC048","ARC209","ARC152","ARC037","ARC065","ARC032","ARC135","ARC105","ARC143","ARC095","ARC038","ARC112"
        },
        -- pack #11 in box #58
        [11] = {
            "ARC206","ARC193","ARC194","ARC188","ARC129","ARC093","ARC027","ARC153","ARC063","ARC030","ARC069","ARC110","ARC148","ARC107","ARC147","ARC075","ARC003"
        },
        -- pack #12 in box #58
        [12] = {
            "ARC205","ARC201","ARC211","ARC203","ARC092","ARC050","ARC176","ARC153","ARC036","ARC065","ARC028","ARC064","ARC095","ARC135","ARC096","ARC075","ARC039"
        },
        -- pack #13 in box #58
        [13] = {
            "ARC201","ARC217","ARC206","ARC191","ARC014","ARC128","ARC131","ARC158","ARC031","ARC070","ARC037","ARC143","ARC099","ARC136","ARC109","ARC076","ARC040"
        },
        -- pack #14 in box #58
        [14] = {
            "ARC191","ARC180","ARC189","ARC211","ARC017","ARC087","ARC104","ARC079","ARC067","ARC037","ARC064","ARC023","ARC135","ARC102","ARC147","ARC075","ARC002"
        },
        -- pack #15 in box #58
        [15] = {
            "ARC190","ARC179","ARC195","ARC191","ARC019","ARC051","ARC107","ARC152","ARC031","ARC061","ARC032","ARC072","ARC095","ARC134","ARC096","ARC112","ARC077"
        },
        -- pack #16 in box #58
        [16] = {
            "ARC196","ARC184","ARC192","ARC215","ARC091","ARC016","ARC102","ARC156","ARC066","ARC037","ARC063","ARC036","ARC138","ARC096","ARC137","ARC114","ARC001"
        },
        -- pack #17 in box #58
        [17] = {
            "ARC197","ARC203","ARC204","ARC212","ARC130","ARC127","ARC199","ARC152","ARC068","ARC024","ARC073","ARC028","ARC149","ARC097","ARC147","ARC113","ARC115"
        },
        -- pack #18 in box #58
        [18] = {
            "ARC177","ARC186","ARC193","ARC185","ARC130","ARC127","ARC213","ARC156","ARC072","ARC023","ARC074","ARC109","ARC144","ARC094","ARC136","ARC038","ARC001"
        },
        -- pack #19 in box #58
        [19] = {
            "ARC187","ARC204","ARC196","ARC206","ARC174","ARC019","ARC105","ARC042","ARC074","ARC033","ARC065","ARC030","ARC137","ARC106","ARC145","ARC002","ARC075"
        },
        -- pack #20 in box #58
        [20] = {
            "ARC217","ARC193","ARC213","ARC177","ARC016","ARC091","ARC068","ARC154","ARC029","ARC067","ARC023","ARC140","ARC111","ARC135","ARC109","ARC076","ARC038"
        },
        -- pack #21 in box #58
        [21] = {
            "ARC176","ARC194","ARC184","ARC197","ARC173","ARC175","ARC100","ARC042","ARC036","ARC066","ARC035","ARC136","ARC103","ARC135","ARC111","ARC114","ARC039"
        },
        -- pack #22 in box #58
        [22] = {
            "ARC190","ARC217","ARC210","ARC214","ARC087","ARC129","ARC145","ARC156","ARC037","ARC062","ARC026","ARC074","ARC102","ARC138","ARC098","ARC040","ARC115"
        },
        -- pack #23 in box #58
        [23] = {
            "ARC201","ARC213","ARC189","ARC181","ARC056","ARC129","ARC131","ARC154","ARC068","ARC021","ARC062","ARC106","ARC132","ARC109","ARC137","ARC075","ARC076"
        },
        -- pack #24 in box #58
        [24] = {
            "ARC200","ARC212","ARC216","ARC186","ARC090","ARC167","ARC060","ARC117","ARC072","ARC032","ARC066","ARC109","ARC148","ARC096","ARC142","ARC002","ARC115"
        },
    },
    -- box #59
    [59] = {
        -- pack #1 in box #59
        [1] = {
            "ARC207","ARC210","ARC180","ARC188","ARC174","ARC049","ARC199","ARC154","ARC027","ARC069","ARC031","ARC063","ARC111","ARC144","ARC094","ARC218"
        },
        -- pack #2 in box #59
        [2] = {
            "ARC198","ARC176","ARC216","ARC211","ARC014","ARC167","ARC148","ARC005","ARC033","ARC065","ARC026","ARC143","ARC109","ARC137","ARC106","ARC038","ARC040"
        },
        -- pack #3 in box #59
        [3] = {
            "ARC183","ARC184","ARC205","ARC216","ARC166","ARC057","ARC152","ARC151","ARC036","ARC065","ARC027","ARC067","ARC102","ARC133","ARC110","ARC076","ARC001"
        },
        -- pack #4 in box #59
        [4] = {
            "ARC208","ARC201","ARC196","ARC185","ARC092","ARC043","ARC164","ARC157","ARC032","ARC072","ARC021","ARC074","ARC102","ARC143","ARC094","ARC002","ARC115"
        },
        -- pack #5 in box #59
        [5] = {
            "ARC187","ARC177","ARC209","ARC177","ARC167","ARC017","ARC096","ARC156","ARC074","ARC029","ARC074","ARC032","ARC149","ARC109","ARC147","ARC077","ARC002"
        },
        -- pack #6 in box #59
        [6] = {
            "ARC194","ARC195","ARC217","ARC186","ARC058","ARC011","ARC071","ARC156","ARC070","ARC030","ARC062","ARC024","ARC135","ARC105","ARC146","ARC038","ARC114"
        },
        -- pack #7 in box #59
        [7] = {
            "ARC205","ARC187","ARC205","ARC205","ARC164","ARC052","ARC176","ARC153","ARC035","ARC061","ARC024","ARC132","ARC094","ARC137","ARC095","ARC040","ARC077"
        },
        -- pack #8 in box #59
        [8] = {
            "ARC192","ARC187","ARC207","ARC190","ARC054","ARC056","ARC017","ARC079","ARC070","ARC023","ARC073","ARC028","ARC147","ARC096","ARC141","ARC003","ARC112"
        },
        -- pack #9 in box #59
        [9] = {
            "ARC199","ARC194","ARC187","ARC192","ARC093","ARC013","ARC097","ARC155","ARC067","ARC031","ARC060","ARC103","ARC146","ARC109","ARC149","ARC114","ARC077"
        },
        -- pack #10 in box #59
        [10] = {
            "ARC184","ARC203","ARC207","ARC200","ARC093","ARC085","ARC135","ARC155","ARC063","ARC030","ARC067","ARC102","ARC137","ARC106","ARC148","ARC218"
        },
        -- pack #11 in box #59
        [11] = {
            "ARC209","ARC205","ARC186","ARC178","ARC123","ARC089","ARC067","ARC152","ARC066","ARC036","ARC064","ARC036","ARC149","ARC105","ARC136","ARC112","ARC040"
        },
        -- pack #12 in box #59
        [12] = {
            "ARC185","ARC205","ARC177","ARC217","ARC124","ARC045","ARC130","ARC158","ARC026","ARC067","ARC032","ARC142","ARC108","ARC138","ARC108","ARC001","ARC039"
        },
        -- pack #13 in box #59
        [13] = {
            "ARC184","ARC204","ARC201","ARC189","ARC019","ARC170","ARC024","ARC157","ARC036","ARC070","ARC030","ARC147","ARC101","ARC140","ARC094","ARC001","ARC115"
        },
        -- pack #14 in box #59
        [14] = {
            "ARC188","ARC204","ARC214","ARC176","ARC051","ARC165","ARC059","ARC079","ARC021","ARC069","ARC031","ARC072","ARC101","ARC148","ARC097","ARC038","ARC076"
        },
        -- pack #15 in box #59
        [15] = {
            "ARC178","ARC201","ARC183","ARC201","ARC014","ARC081","ARC177","ARC152","ARC031","ARC069","ARC035","ARC066","ARC097","ARC138","ARC100","ARC115","ARC076"
        },
        -- pack #16 in box #59
        [16] = {
            "ARC188","ARC179","ARC192","ARC186","ARC085","ARC162","ARC199","ARC042","ARC020","ARC065","ARC028","ARC136","ARC108","ARC149","ARC108","ARC038","ARC113"
        },
        -- pack #17 in box #59
        [17] = {
            "ARC198","ARC187","ARC208","ARC179","ARC168","ARC058","ARC110","ARC042","ARC060","ARC020","ARC068","ARC037","ARC136","ARC104","ARC136","ARC218"
        },
        -- pack #18 in box #59
        [18] = {
            "ARC185","ARC200","ARC196","ARC184","ARC049","ARC045","ARC183","ARC151","ARC070","ARC022","ARC061","ARC102","ARC135","ARC101","ARC148","ARC039","ARC115"
        },
        -- pack #19 in box #59
        [19] = {
            "ARC187","ARC208","ARC205","ARC194","ARC012","ARC085","ARC121","ARC079","ARC073","ARC022","ARC060","ARC099","ARC145","ARC103","ARC135","ARC003","ARC075"
        },
        -- pack #20 in box #59
        [20] = {
            "ARC210","ARC203","ARC216","ARC210","ARC090","ARC165","ARC090","ARC042","ARC061","ARC022","ARC074","ARC036","ARC132","ARC107","ARC144","ARC076","ARC001"
        },
        -- pack #21 in box #59
        [21] = {
            "ARC206","ARC195","ARC192","ARC214","ARC128","ARC090","ARC205","ARC158","ARC069","ARC030","ARC067","ARC097","ARC139","ARC101","ARC148","ARC112","ARC113"
        },
        -- pack #22 in box #59
        [22] = {
            "ARC180","ARC206","ARC187","ARC211","ARC018","ARC120","ARC029","ARC079","ARC073","ARC035","ARC072","ARC097","ARC148","ARC107","ARC142","ARC114","ARC002"
        },
        -- pack #23 in box #59
        [23] = {
            "ARC189","ARC210","ARC209","ARC215","ARC059","ARC008","ARC189","ARC156","ARC037","ARC072","ARC037","ARC061","ARC108","ARC147","ARC102","ARC077","ARC040"
        },
        -- pack #24 in box #59
        [24] = {
            "ARC206","ARC217","ARC204","ARC211","ARC088","ARC120","ARC023","ARC155","ARC034","ARC064","ARC027","ARC145","ARC100","ARC145","ARC101","ARC113","ARC075"
        },
    },
    -- box #60
    [60] = {
        -- pack #1 in box #60
        [1] = {
            "ARC200","ARC193","ARC177","ARC194","ARC088","ARC172","ARC071","ARC152","ARC074","ARC032","ARC066","ARC098","ARC140","ARC099","ARC148","ARC001","ARC039"
        },
        -- pack #2 in box #60
        [2] = {
            "ARC215","ARC212","ARC210","ARC207","ARC013","ARC123","ARC203","ARC155","ARC073","ARC023","ARC060","ARC030","ARC146","ARC111","ARC140","ARC114","ARC076"
        },
        -- pack #3 in box #60
        [3] = {
            "ARC197","ARC213","ARC177","ARC202","ARC014","ARC084","ARC069","ARC152","ARC029","ARC067","ARC025","ARC134","ARC107","ARC140","ARC100","ARC002","ARC075"
        },
        -- pack #4 in box #60
        [4] = {
            "ARC215","ARC189","ARC213","ARC188","ARC123","ARC048","ARC029","ARC157","ARC028","ARC070","ARC025","ARC067","ARC097","ARC132","ARC103","ARC003","ARC115"
        },
        -- pack #5 in box #60
        [5] = {
            "ARC201","ARC213","ARC216","ARC189","ARC171","ARC053","ARC142","ARC117","ARC066","ARC025","ARC073","ARC105","ARC146","ARC097","ARC140","ARC040","ARC077"
        },
        -- pack #6 in box #60
        [6] = {
            "ARC193","ARC205","ARC205","ARC184","ARC012","ARC058","ARC069","ARC156","ARC032","ARC061","ARC029","ARC065","ARC101","ARC147","ARC102","ARC039","ARC002"
        },
        -- pack #7 in box #60
        [7] = {
            "ARC213","ARC182","ARC199","ARC206","ARC175","ARC050","ARC182","ARC151","ARC034","ARC063","ARC025","ARC144","ARC107","ARC146","ARC102","ARC115","ARC002"
        },
        -- pack #8 in box #60
        [8] = {
            "ARC195","ARC207","ARC189","ARC215","ARC093","ARC014","ARC008","ARC079","ARC069","ARC022","ARC072","ARC105","ARC144","ARC107","ARC138","ARC113","ARC075"
        },
        -- pack #9 in box #60
        [9] = {
            "ARC185","ARC179","ARC183","ARC199","ARC088","ARC129","ARC194","ARC156","ARC027","ARC066","ARC027","ARC133","ARC103","ARC142","ARC103","ARC218"
        },
        -- pack #10 in box #60
        [10] = {
            "ARC200","ARC193","ARC205","ARC186","ARC125","ARC006","ARC146","ARC151","ARC024","ARC070","ARC024","ARC141","ARC104","ARC136","ARC097","ARC003","ARC077"
        },
        -- pack #11 in box #60
        [11] = {
            "ARC180","ARC209","ARC186","ARC198","ARC124","ARC128","ARC201","ARC005","ARC071","ARC029","ARC062","ARC034","ARC149","ARC099","ARC142","ARC113","ARC039"
        },
        -- pack #12 in box #60
        [12] = {
            "ARC178","ARC209","ARC196","ARC217","ARC126","ARC092","ARC142","ARC158","ARC036","ARC070","ARC036","ARC062","ARC095","ARC138","ARC106","ARC115","ARC112"
        },
        -- pack #13 in box #60
        [13] = {
            "ARC176","ARC211","ARC180","ARC195","ARC086","ARC086","ARC120","ARC079","ARC030","ARC060","ARC033","ARC070","ARC097","ARC132","ARC103","ARC001","ARC115"
        },
        -- pack #14 in box #60
        [14] = {
            "ARC199","ARC206","ARC186","ARC192","ARC175","ARC057","ARC205","ARC153","ARC063","ARC028","ARC072","ARC037","ARC134","ARC107","ARC137","ARC075","ARC077"
        },
        -- pack #15 in box #60
        [15] = {
            "ARC203","ARC177","ARC215","ARC210","ARC165","ARC120","ARC087","ARC042","ARC034","ARC067","ARC032","ARC061","ARC095","ARC135","ARC109","ARC218"
        },
        -- pack #16 in box #60
        [16] = {
            "ARC187","ARC201","ARC183","ARC176","ARC174","ARC129","ARC139","ARC154","ARC036","ARC067","ARC035","ARC067","ARC102","ARC137","ARC096","ARC115","ARC002"
        },
        -- pack #17 in box #60
        [17] = {
            "ARC197","ARC213","ARC217","ARC179","ARC091","ARC093","ARC132","ARC153","ARC063","ARC023","ARC073","ARC030","ARC136","ARC110","ARC140","ARC115","ARC113"
        },
        -- pack #18 in box #60
        [18] = {
            "ARC202","ARC190","ARC202","ARC183","ARC089","ARC169","ARC206","ARC155","ARC072","ARC031","ARC069","ARC030","ARC135","ARC099","ARC149","ARC112","ARC115"
        },
        -- pack #19 in box #60
        [19] = {
            "ARC215","ARC202","ARC197","ARC186","ARC019","ARC160","ARC060","ARC152","ARC023","ARC063","ARC029","ARC138","ARC097","ARC137","ARC097","ARC112","ARC077"
        },
        -- pack #20 in box #60
        [20] = {
            "ARC183","ARC215","ARC198","ARC204","ARC051","ARC018","ARC058","ARC153","ARC071","ARC027","ARC060","ARC096","ARC142","ARC094","ARC138","ARC077","ARC001"
        },
        -- pack #21 in box #60
        [21] = {
            "ARC210","ARC199","ARC200","ARC183","ARC089","ARC167","ARC091","ARC154","ARC064","ARC022","ARC062","ARC103","ARC144","ARC099","ARC144","ARC038","ARC002"
        },
        -- pack #22 in box #60
        [22] = {
            "ARC189","ARC188","ARC179","ARC181","ARC087","ARC080","ARC154","ARC153","ARC073","ARC025","ARC069","ARC104","ARC138","ARC108","ARC141","ARC075","ARC040"
        },
        -- pack #23 in box #60
        [23] = {
            "ARC176","ARC178","ARC197","ARC203","ARC167","ARC167","ARC182","ARC156","ARC061","ARC027","ARC066","ARC036","ARC140","ARC106","ARC142","ARC114","ARC003"
        },
        -- pack #24 in box #60
        [24] = {
            "ARC180","ARC208","ARC210","ARC198","ARC092","ARC088","ARC135","ARC153","ARC031","ARC063","ARC037","ARC143","ARC106","ARC141","ARC101","ARC077","ARC003"
        },
    },
    -- box #61
    [61] = {
        -- pack #1 in box #61
        [1] = {
            "ARC183","ARC200","ARC190","ARC212","ARC013","ARC164","ARC137","ARC151","ARC030","ARC061","ARC032","ARC141","ARC097","ARC132","ARC097","ARC115","ARC077"
        },
        -- pack #2 in box #61
        [2] = {
            "ARC191","ARC201","ARC182","ARC215","ARC131","ARC122","ARC143","ARC042","ARC061","ARC021","ARC073","ARC106","ARC137","ARC104","ARC134","ARC113","ARC115"
        },
        -- pack #3 in box #61
        [3] = {
            "ARC196","ARC176","ARC198","ARC216","ARC171","ARC044","ARC105","ARC153","ARC066","ARC035","ARC063","ARC034","ARC138","ARC104","ARC132","ARC077","ARC114"
        },
        -- pack #4 in box #61
        [4] = {
            "ARC176","ARC200","ARC181","ARC178","ARC174","ARC093","ARC110","ARC042","ARC073","ARC022","ARC063","ARC101","ARC137","ARC104","ARC142","ARC040","ARC002"
        },
        -- pack #5 in box #61
        [5] = {
            "ARC191","ARC215","ARC180","ARC205","ARC018","ARC057","ARC147","ARC151","ARC028","ARC062","ARC035","ARC061","ARC105","ARC141","ARC106","ARC218"
        },
        -- pack #6 in box #61
        [6] = {
            "ARC217","ARC200","ARC210","ARC205","ARC049","ARC092","ARC171","ARC153","ARC072","ARC021","ARC068","ARC023","ARC143","ARC095","ARC141","ARC001","ARC077"
        },
        -- pack #7 in box #61
        [7] = {
            "ARC199","ARC206","ARC189","ARC215","ARC018","ARC045","ARC185","ARC079","ARC029","ARC073","ARC021","ARC066","ARC111","ARC149","ARC100","ARC218"
        },
        -- pack #8 in box #61
        [8] = {
            "ARC190","ARC197","ARC180","ARC206","ARC124","ARC018","ARC192","ARC158","ARC021","ARC071","ARC032","ARC144","ARC103","ARC145","ARC104","ARC114","ARC115"
        },
        -- pack #9 in box #61
        [9] = {
            "ARC200","ARC194","ARC195","ARC194","ARC167","ARC165","ARC033","ARC155","ARC031","ARC068","ARC021","ARC070","ARC105","ARC145","ARC106","ARC038","ARC076"
        },
        -- pack #10 in box #61
        [10] = {
            "ARC206","ARC215","ARC180","ARC177","ARC128","ARC169","ARC171","ARC158","ARC062","ARC023","ARC070","ARC032","ARC136","ARC101","ARC143","ARC076","ARC077"
        },
        -- pack #11 in box #61
        [11] = {
            "ARC205","ARC186","ARC187","ARC210","ARC126","ARC171","ARC141","ARC157","ARC071","ARC031","ARC069","ARC022","ARC136","ARC106","ARC148","ARC039","ARC077"
        },
        -- pack #12 in box #61
        [12] = {
            "ARC215","ARC186","ARC179","ARC213","ARC085","ARC126","ARC201","ARC154","ARC060","ARC024","ARC073","ARC109","ARC145","ARC104","ARC137","ARC113","ARC114"
        },
        -- pack #13 in box #61
        [13] = {
            "ARC211","ARC214","ARC183","ARC184","ARC011","ARC015","ARC125","ARC117","ARC020","ARC074","ARC027","ARC060","ARC106","ARC137","ARC095","ARC076","ARC001"
        },
        -- pack #14 in box #61
        [14] = {
            "ARC177","ARC192","ARC205","ARC194","ARC091","ARC016","ARC016","ARC153","ARC027","ARC068","ARC025","ARC138","ARC102","ARC134","ARC110","ARC038","ARC075"
        },
        -- pack #15 in box #61
        [15] = {
            "ARC211","ARC193","ARC178","ARC204","ARC092","ARC119","ARC024","ARC151","ARC021","ARC064","ARC022","ARC065","ARC098","ARC133","ARC103","ARC001","ARC002"
        },
        -- pack #16 in box #61
        [16] = {
            "ARC197","ARC204","ARC179","ARC176","ARC012","ARC174","ARC057","ARC157","ARC071","ARC026","ARC074","ARC109","ARC145","ARC104","ARC138","ARC113","ARC075"
        },
        -- pack #17 in box #61
        [17] = {
            "ARC207","ARC205","ARC193","ARC191","ARC128","ARC051","ARC000","ARC152","ARC033","ARC064","ARC027","ARC149","ARC099","ARC141","ARC098","ARC003","ARC040"
        },
        -- pack #18 in box #61
        [18] = {
            "ARC182","ARC183","ARC216","ARC201","ARC129","ARC130","ARC190","ARC042","ARC029","ARC074","ARC020","ARC143","ARC111","ARC135","ARC104","ARC039","ARC114"
        },
        -- pack #19 in box #61
        [19] = {
            "ARC194","ARC202","ARC201","ARC184","ARC086","ARC170","ARC102","ARC158","ARC064","ARC027","ARC068","ARC034","ARC137","ARC095","ARC141","ARC076","ARC039"
        },
        -- pack #20 in box #61
        [20] = {
            "ARC215","ARC179","ARC203","ARC180","ARC050","ARC163","ARC064","ARC151","ARC068","ARC025","ARC065","ARC106","ARC132","ARC110","ARC147","ARC075","ARC040"
        },
        -- pack #21 in box #61
        [21] = {
            "ARC182","ARC210","ARC203","ARC213","ARC014","ARC043","ARC186","ARC152","ARC032","ARC070","ARC031","ARC069","ARC110","ARC140","ARC094","ARC039","ARC076"
        },
        -- pack #22 in box #61
        [22] = {
            "ARC196","ARC216","ARC200","ARC204","ARC048","ARC090","ARC186","ARC158","ARC031","ARC067","ARC028","ARC145","ARC100","ARC135","ARC110","ARC115","ARC039"
        },
        -- pack #23 in box #61
        [23] = {
            "ARC202","ARC177","ARC210","ARC182","ARC052","ARC172","ARC103","ARC079","ARC070","ARC035","ARC071","ARC095","ARC140","ARC102","ARC134","ARC001","ARC075"
        },
        -- pack #24 in box #61
        [24] = {
            "ARC201","ARC183","ARC199","ARC198","ARC011","ARC044","ARC035","ARC079","ARC073","ARC031","ARC067","ARC024","ARC135","ARC095","ARC135","ARC039","ARC003"
        },
    },
    -- box #62
    [62] = {
        -- pack #1 in box #62
        [1] = {
            "ARC212","ARC176","ARC177","ARC202","ARC127","ARC123","ARC119","ARC151","ARC070","ARC022","ARC065","ARC030","ARC136","ARC098","ARC144","ARC114","ARC038"
        },
        -- pack #2 in box #62
        [2] = {
            "ARC211","ARC199","ARC210","ARC204","ARC015","ARC084","ARC020","ARC151","ARC061","ARC027","ARC074","ARC027","ARC145","ARC106","ARC135","ARC112","ARC115"
        },
        -- pack #3 in box #62
        [3] = {
            "ARC198","ARC179","ARC198","ARC210","ARC164","ARC127","ARC196","ARC154","ARC036","ARC070","ARC023","ARC144","ARC107","ARC135","ARC106","ARC077","ARC038"
        },
        -- pack #4 in box #62
        [4] = {
            "ARC202","ARC217","ARC207","ARC211","ARC164","ARC093","ARC100","ARC005","ARC031","ARC073","ARC036","ARC146","ARC096","ARC132","ARC105","ARC114","ARC113"
        },
        -- pack #5 in box #62
        [5] = {
            "ARC182","ARC193","ARC209","ARC203","ARC059","ARC053","ARC072","ARC151","ARC025","ARC066","ARC024","ARC063","ARC107","ARC149","ARC108","ARC001","ARC075"
        },
        -- pack #6 in box #62
        [6] = {
            "ARC177","ARC196","ARC202","ARC200","ARC087","ARC012","ARC100","ARC154","ARC069","ARC021","ARC067","ARC104","ARC146","ARC104","ARC139","ARC113","ARC115"
        },
        -- pack #7 in box #62
        [7] = {
            "ARC193","ARC207","ARC192","ARC206","ARC172","ARC087","ARC046","ARC152","ARC068","ARC028","ARC069","ARC101","ARC141","ARC104","ARC135","ARC115","ARC114"
        },
        -- pack #8 in box #62
        [8] = {
            "ARC205","ARC205","ARC208","ARC195","ARC017","ARC126","ARC086","ARC156","ARC037","ARC060","ARC029","ARC137","ARC104","ARC148","ARC096","ARC075","ARC039"
        },
        -- pack #9 in box #62
        [9] = {
            "ARC188","ARC186","ARC210","ARC185","ARC131","ARC169","ARC025","ARC151","ARC074","ARC037","ARC070","ARC100","ARC137","ARC099","ARC132","ARC075","ARC003"
        },
        -- pack #10 in box #62
        [10] = {
            "ARC189","ARC191","ARC212","ARC183","ARC015","ARC080","ARC145","ARC157","ARC035","ARC062","ARC034","ARC072","ARC094","ARC139","ARC094","ARC003","ARC001"
        },
        -- pack #11 in box #62
        [11] = {
            "ARC212","ARC194","ARC209","ARC176","ARC085","ARC083","ARC214","ARC157","ARC064","ARC037","ARC061","ARC021","ARC145","ARC107","ARC145","ARC003","ARC115"
        },
        -- pack #12 in box #62
        [12] = {
            "ARC198","ARC179","ARC212","ARC208","ARC171","ARC084","ARC031","ARC154","ARC024","ARC060","ARC024","ARC136","ARC100","ARC139","ARC097","ARC002","ARC001"
        },
        -- pack #13 in box #62
        [13] = {
            "ARC214","ARC183","ARC194","ARC196","ARC131","ARC010","ARC149","ARC158","ARC030","ARC071","ARC031","ARC068","ARC104","ARC144","ARC101","ARC076","ARC003"
        },
        -- pack #14 in box #62
        [14] = {
            "ARC190","ARC207","ARC201","ARC210","ARC015","ARC056","ARC154","ARC079","ARC030","ARC063","ARC037","ARC138","ARC111","ARC136","ARC095","ARC003","ARC114"
        },
        -- pack #15 in box #62
        [15] = {
            "ARC205","ARC199","ARC200","ARC212","ARC049","ARC172","ARC181","ARC158","ARC071","ARC026","ARC072","ARC037","ARC136","ARC096","ARC146","ARC115","ARC113"
        },
        -- pack #16 in box #62
        [16] = {
            "ARC215","ARC211","ARC195","ARC200","ARC172","ARC017","ARC073","ARC154","ARC030","ARC074","ARC023","ARC138","ARC110","ARC137","ARC100","ARC038","ARC112"
        },
        -- pack #17 in box #62
        [17] = {
            "ARC190","ARC210","ARC195","ARC193","ARC012","ARC170","ARC103","ARC152","ARC068","ARC028","ARC063","ARC108","ARC149","ARC102","ARC134","ARC112","ARC001"
        },
        -- pack #18 in box #62
        [18] = {
            "ARC207","ARC189","ARC216","ARC193","ARC051","ARC053","ARC103","ARC158","ARC032","ARC063","ARC023","ARC066","ARC096","ARC147","ARC096","ARC115","ARC075"
        },
        -- pack #19 in box #62
        [19] = {
            "ARC181","ARC186","ARC205","ARC201","ARC167","ARC088","ARC106","ARC152","ARC025","ARC071","ARC030","ARC065","ARC096","ARC133","ARC102","ARC218"
        },
        -- pack #20 in box #62
        [20] = {
            "ARC179","ARC194","ARC199","ARC204","ARC019","ARC053","ARC155","ARC005","ARC065","ARC024","ARC068","ARC023","ARC140","ARC108","ARC144","ARC077","ARC113"
        },
        -- pack #21 in box #62
        [21] = {
            "ARC194","ARC188","ARC187","ARC178","ARC164","ARC162","ARC074","ARC153","ARC071","ARC034","ARC067","ARC103","ARC147","ARC103","ARC136","ARC039","ARC115"
        },
        -- pack #22 in box #62
        [22] = {
            "ARC189","ARC213","ARC191","ARC210","ARC093","ARC049","ARC066","ARC005","ARC063","ARC037","ARC063","ARC037","ARC141","ARC108","ARC133","ARC075","ARC112"
        },
        -- pack #23 in box #62
        [23] = {
            "ARC209","ARC207","ARC191","ARC212","ARC175","ARC090","ARC079","ARC117","ARC074","ARC030","ARC072","ARC108","ARC143","ARC111","ARC144","ARC039","ARC075"
        },
        -- pack #24 in box #62
        [24] = {
            "ARC216","ARC177","ARC202","ARC209","ARC057","ARC045","ARC084","ARC151","ARC023","ARC065","ARC036","ARC066","ARC102","ARC135","ARC108","ARC115","ARC075"
        },
    },
    -- box #63
    [63] = {
        -- pack #1 in box #63
        [1] = {
            "ARC193","ARC205","ARC192","ARC177","ARC018","ARC057","ARC124","ARC117","ARC035","ARC064","ARC031","ARC074","ARC104","ARC141","ARC109","ARC077","ARC040"
        },
        -- pack #2 in box #63
        [2] = {
            "ARC183","ARC192","ARC206","ARC188","ARC088","ARC084","ARC213","ARC157","ARC035","ARC064","ARC037","ARC061","ARC104","ARC139","ARC108","ARC115","ARC113"
        },
        -- pack #3 in box #63
        [3] = {
            "ARC203","ARC183","ARC192","ARC213","ARC165","ARC119","ARC096","ARC157","ARC064","ARC022","ARC074","ARC094","ARC138","ARC095","ARC147","ARC001","ARC002"
        },
        -- pack #4 in box #63
        [4] = {
            "ARC183","ARC210","ARC214","ARC184","ARC164","ARC043","ARC035","ARC152","ARC062","ARC035","ARC070","ARC098","ARC140","ARC099","ARC138","ARC038","ARC077"
        },
        -- pack #5 in box #63
        [5] = {
            "ARC187","ARC211","ARC214","ARC176","ARC168","ARC160","ARC028","ARC151","ARC022","ARC066","ARC022","ARC147","ARC106","ARC132","ARC109","ARC112","ARC113"
        },
        -- pack #6 in box #63
        [6] = {
            "ARC176","ARC216","ARC208","ARC187","ARC086","ARC163","ARC190","ARC153","ARC070","ARC029","ARC070","ARC022","ARC144","ARC106","ARC133","ARC076","ARC115"
        },
        -- pack #7 in box #63
        [7] = {
            "ARC186","ARC199","ARC196","ARC179","ARC173","ARC058","ARC173","ARC157","ARC023","ARC068","ARC028","ARC133","ARC100","ARC148","ARC103","ARC077","ARC038"
        },
        -- pack #8 in box #63
        [8] = {
            "ARC206","ARC180","ARC188","ARC210","ARC011","ARC053","ARC204","ARC153","ARC036","ARC070","ARC024","ARC072","ARC095","ARC134","ARC105","ARC112","ARC003"
        },
        -- pack #9 in box #63
        [9] = {
            "ARC181","ARC217","ARC184","ARC195","ARC049","ARC125","ARC194","ARC151","ARC031","ARC066","ARC027","ARC138","ARC103","ARC137","ARC104","ARC040","ARC075"
        },
        -- pack #10 in box #63
        [10] = {
            "ARC198","ARC197","ARC187","ARC191","ARC128","ARC046","ARC084","ARC079","ARC070","ARC024","ARC069","ARC102","ARC149","ARC096","ARC146","ARC038","ARC115"
        },
        -- pack #11 in box #63
        [11] = {
            "ARC211","ARC209","ARC199","ARC188","ARC019","ARC170","ARC027","ARC042","ARC033","ARC064","ARC026","ARC141","ARC095","ARC145","ARC106","ARC218"
        },
        -- pack #12 in box #63
        [12] = {
            "ARC178","ARC178","ARC200","ARC203","ARC052","ARC165","ARC135","ARC157","ARC032","ARC064","ARC037","ARC067","ARC096","ARC132","ARC105","ARC039","ARC114"
        },
        -- pack #13 in box #63
        [13] = {
            "ARC203","ARC190","ARC193","ARC179","ARC057","ARC059","ARC033","ARC154","ARC061","ARC037","ARC066","ARC034","ARC142","ARC098","ARC143","ARC218"
        },
        -- pack #14 in box #63
        [14] = {
            "ARC181","ARC210","ARC215","ARC181","ARC093","ARC165","ARC172","ARC117","ARC033","ARC063","ARC037","ARC070","ARC102","ARC132","ARC106","ARC002","ARC039"
        },
        -- pack #15 in box #63
        [15] = {
            "ARC200","ARC184","ARC210","ARC202","ARC173","ARC047","ARC111","ARC117","ARC027","ARC064","ARC026","ARC060","ARC099","ARC147","ARC101","ARC002","ARC113"
        },
        -- pack #16 in box #63
        [16] = {
            "ARC211","ARC205","ARC214","ARC187","ARC087","ARC057","ARC015","ARC158","ARC037","ARC066","ARC029","ARC133","ARC104","ARC146","ARC108","ARC039","ARC038"
        },
        -- pack #17 in box #63
        [17] = {
            "ARC177","ARC202","ARC184","ARC198","ARC050","ARC052","ARC092","ARC005","ARC065","ARC022","ARC062","ARC098","ARC147","ARC100","ARC149","ARC001","ARC115"
        },
        -- pack #18 in box #63
        [18] = {
            "ARC197","ARC211","ARC186","ARC208","ARC169","ARC007","ARC079","ARC156","ARC066","ARC028","ARC062","ARC106","ARC133","ARC106","ARC135","ARC003","ARC077"
        },
        -- pack #19 in box #63
        [19] = {
            "ARC176","ARC213","ARC206","ARC214","ARC055","ARC175","ARC200","ARC156","ARC074","ARC024","ARC063","ARC024","ARC143","ARC097","ARC139","ARC039","ARC003"
        },
        -- pack #20 in box #63
        [20] = {
            "ARC184","ARC209","ARC201","ARC203","ARC013","ARC059","ARC057","ARC155","ARC060","ARC020","ARC060","ARC103","ARC140","ARC098","ARC135","ARC112","ARC001"
        },
        -- pack #21 in box #63
        [21] = {
            "ARC205","ARC191","ARC190","ARC184","ARC085","ARC008","ARC111","ARC158","ARC027","ARC069","ARC031","ARC147","ARC100","ARC149","ARC097","ARC113","ARC002"
        },
        -- pack #22 in box #63
        [22] = {
            "ARC206","ARC183","ARC215","ARC190","ARC092","ARC051","ARC173","ARC117","ARC064","ARC028","ARC073","ARC022","ARC136","ARC094","ARC137","ARC114","ARC115"
        },
        -- pack #23 in box #63
        [23] = {
            "ARC207","ARC189","ARC184","ARC214","ARC059","ARC017","ARC041","ARC005","ARC062","ARC029","ARC074","ARC028","ARC146","ARC095","ARC136","ARC076","ARC003"
        },
        -- pack #24 in box #63
        [24] = {
            "ARC215","ARC177","ARC181","ARC180","ARC013","ARC091","ARC176","ARC155","ARC065","ARC020","ARC070","ARC030","ARC149","ARC102","ARC132","ARC113","ARC038"
        },
    },
    -- box #64
    [64] = {
        -- pack #1 in box #64
        [1] = {
            "ARC197","ARC185","ARC198","ARC176","ARC092","ARC091","ARC141","ARC152","ARC026","ARC060","ARC020","ARC063","ARC105","ARC142","ARC098","ARC038","ARC114"
        },
        -- pack #2 in box #64
        [2] = {
            "ARC209","ARC214","ARC217","ARC209","ARC056","ARC080","ARC098","ARC152","ARC026","ARC064","ARC020","ARC072","ARC108","ARC144","ARC106","ARC001","ARC075"
        },
        -- pack #3 in box #64
        [3] = {
            "ARC200","ARC197","ARC176","ARC200","ARC174","ARC082","ARC014","ARC155","ARC060","ARC025","ARC061","ARC105","ARC136","ARC098","ARC145","ARC002","ARC076"
        },
        -- pack #4 in box #64
        [4] = {
            "ARC177","ARC179","ARC181","ARC186","ARC011","ARC055","ARC109","ARC152","ARC036","ARC061","ARC023","ARC140","ARC110","ARC147","ARC110","ARC077","ARC075"
        },
        -- pack #5 in box #64
        [5] = {
            "ARC210","ARC187","ARC201","ARC177","ARC124","ARC130","ARC025","ARC157","ARC070","ARC024","ARC063","ARC030","ARC140","ARC100","ARC149","ARC075","ARC001"
        },
        -- pack #6 in box #64
        [6] = {
            "ARC210","ARC198","ARC213","ARC202","ARC048","ARC086","ARC214","ARC117","ARC033","ARC073","ARC020","ARC069","ARC102","ARC147","ARC103","ARC076","ARC002"
        },
        -- pack #7 in box #64
        [7] = {
            "ARC189","ARC189","ARC189","ARC179","ARC048","ARC091","ARC095","ARC079","ARC067","ARC024","ARC074","ARC096","ARC133","ARC102","ARC135","ARC040","ARC075"
        },
        -- pack #8 in box #64
        [8] = {
            "ARC198","ARC183","ARC179","ARC217","ARC011","ARC088","ARC166","ARC158","ARC072","ARC026","ARC065","ARC109","ARC133","ARC099","ARC139","ARC002","ARC113"
        },
        -- pack #9 in box #64
        [9] = {
            "ARC205","ARC192","ARC195","ARC199","ARC091","ARC089","ARC214","ARC042","ARC023","ARC068","ARC033","ARC138","ARC099","ARC133","ARC111","ARC001","ARC112"
        },
        -- pack #10 in box #64
        [10] = {
            "ARC198","ARC195","ARC215","ARC201","ARC054","ARC175","ARC030","ARC152","ARC026","ARC063","ARC021","ARC149","ARC105","ARC145","ARC096","ARC001","ARC112"
        },
        -- pack #11 in box #64
        [11] = {
            "ARC191","ARC190","ARC182","ARC186","ARC019","ARC052","ARC127","ARC151","ARC037","ARC070","ARC036","ARC142","ARC098","ARC135","ARC110","ARC003","ARC077"
        },
        -- pack #12 in box #64
        [12] = {
            "ARC191","ARC188","ARC184","ARC182","ARC016","ARC049","ARC205","ARC155","ARC072","ARC031","ARC070","ARC096","ARC145","ARC107","ARC132","ARC038","ARC075"
        },
        -- pack #13 in box #64
        [13] = {
            "ARC192","ARC187","ARC207","ARC183","ARC131","ARC092","ARC024","ARC152","ARC062","ARC036","ARC064","ARC109","ARC147","ARC102","ARC146","ARC115","ARC075"
        },
        -- pack #14 in box #64
        [14] = {
            "ARC186","ARC193","ARC188","ARC195","ARC131","ARC175","ARC136","ARC005","ARC034","ARC063","ARC022","ARC138","ARC111","ARC141","ARC099","ARC038","ARC115"
        },
        -- pack #15 in box #64
        [15] = {
            "ARC202","ARC192","ARC200","ARC182","ARC053","ARC012","ARC146","ARC155","ARC072","ARC021","ARC073","ARC102","ARC146","ARC094","ARC138","ARC002","ARC112"
        },
        -- pack #16 in box #64
        [16] = {
            "ARC204","ARC186","ARC197","ARC176","ARC167","ARC049","ARC071","ARC005","ARC070","ARC037","ARC065","ARC027","ARC133","ARC104","ARC133","ARC003","ARC112"
        },
        -- pack #17 in box #64
        [17] = {
            "ARC211","ARC203","ARC208","ARC188","ARC086","ARC058","ARC037","ARC079","ARC070","ARC020","ARC065","ARC028","ARC135","ARC108","ARC143","ARC039","ARC075"
        },
        -- pack #18 in box #64
        [18] = {
            "ARC198","ARC195","ARC204","ARC189","ARC126","ARC093","ARC177","ARC079","ARC064","ARC030","ARC074","ARC037","ARC148","ARC102","ARC147","ARC040","ARC112"
        },
        -- pack #19 in box #64
        [19] = {
            "ARC199","ARC188","ARC200","ARC205","ARC172","ARC014","ARC028","ARC152","ARC025","ARC060","ARC037","ARC062","ARC104","ARC144","ARC104","ARC113","ARC039"
        },
        -- pack #20 in box #64
        [20] = {
            "ARC212","ARC201","ARC188","ARC217","ARC012","ARC050","ARC009","ARC151","ARC032","ARC062","ARC024","ARC135","ARC095","ARC134","ARC095","ARC077","ARC075"
        },
        -- pack #21 in box #64
        [21] = {
            "ARC212","ARC181","ARC176","ARC206","ARC017","ARC165","ARC172","ARC152","ARC064","ARC020","ARC065","ARC037","ARC147","ARC097","ARC146","ARC113","ARC040"
        },
        -- pack #22 in box #64
        [22] = {
            "ARC186","ARC182","ARC194","ARC188","ARC165","ARC059","ARC187","ARC154","ARC020","ARC062","ARC029","ARC072","ARC108","ARC142","ARC106","ARC003","ARC112"
        },
        -- pack #23 in box #64
        [23] = {
            "ARC203","ARC178","ARC203","ARC187","ARC089","ARC162","ARC032","ARC079","ARC062","ARC034","ARC061","ARC021","ARC140","ARC111","ARC143","ARC218"
        },
        -- pack #24 in box #64
        [24] = {
            "ARC190","ARC195","ARC216","ARC211","ARC123","ARC174","ARC012","ARC153","ARC021","ARC072","ARC022","ARC069","ARC095","ARC137","ARC111","ARC077","ARC113"
        },
    },
    -- box #65
    [65] = {
        -- pack #1 in box #65
        [1] = {
            "ARC206","ARC209","ARC196","ARC197","ARC013","ARC092","ARC129","ARC156","ARC021","ARC060","ARC020","ARC142","ARC108","ARC143","ARC096","ARC038","ARC077"
        },
        -- pack #2 in box #65
        [2] = {
            "ARC202","ARC214","ARC208","ARC207","ARC165","ARC128","ARC036","ARC156","ARC037","ARC064","ARC037","ARC132","ARC104","ARC142","ARC099","ARC077","ARC039"
        },
        -- pack #3 in box #65
        [3] = {
            "ARC191","ARC202","ARC176","ARC204","ARC175","ARC128","ARC024","ARC158","ARC023","ARC065","ARC032","ARC072","ARC109","ARC135","ARC110","ARC040","ARC114"
        },
        -- pack #4 in box #65
        [4] = {
            "ARC214","ARC200","ARC197","ARC176","ARC172","ARC173","ARC099","ARC079","ARC066","ARC029","ARC063","ARC020","ARC132","ARC110","ARC143","ARC003","ARC038"
        },
        -- pack #5 in box #65
        [5] = {
            "ARC214","ARC180","ARC205","ARC188","ARC015","ARC166","ARC143","ARC117","ARC073","ARC026","ARC064","ARC102","ARC146","ARC098","ARC137","ARC040","ARC113"
        },
        -- pack #6 in box #65
        [6] = {
            "ARC197","ARC194","ARC182","ARC213","ARC167","ARC047","ARC058","ARC156","ARC022","ARC061","ARC033","ARC064","ARC098","ARC134","ARC099","ARC001","ARC114"
        },
        -- pack #7 in box #65
        [7] = {
            "ARC178","ARC186","ARC194","ARC199","ARC169","ARC124","ARC063","ARC153","ARC067","ARC034","ARC062","ARC032","ARC144","ARC101","ARC132","ARC077","ARC040"
        },
        -- pack #8 in box #65
        [8] = {
            "ARC180","ARC189","ARC206","ARC195","ARC091","ARC163","ARC210","ARC156","ARC066","ARC032","ARC064","ARC107","ARC142","ARC107","ARC147","ARC115","ARC040"
        },
        -- pack #9 in box #65
        [9] = {
            "ARC200","ARC212","ARC201","ARC198","ARC016","ARC086","ARC194","ARC079","ARC065","ARC036","ARC073","ARC094","ARC132","ARC099","ARC137","ARC115","ARC002"
        },
        -- pack #10 in box #65
        [10] = {
            "ARC191","ARC190","ARC192","ARC191","ARC015","ARC122","ARC189","ARC154","ARC022","ARC065","ARC034","ARC074","ARC100","ARC145","ARC111","ARC040","ARC002"
        },
        -- pack #11 in box #65
        [11] = {
            "ARC187","ARC217","ARC177","ARC198","ARC128","ARC082","ARC184","ARC079","ARC020","ARC072","ARC024","ARC134","ARC101","ARC138","ARC097","ARC114","ARC115"
        },
        -- pack #12 in box #65
        [12] = {
            "ARC176","ARC209","ARC188","ARC194","ARC169","ARC018","ARC013","ARC151","ARC068","ARC036","ARC065","ARC027","ARC139","ARC102","ARC136","ARC039","ARC075"
        },
        -- pack #13 in box #65
        [13] = {
            "ARC181","ARC212","ARC191","ARC190","ARC016","ARC092","ARC137","ARC005","ARC030","ARC067","ARC034","ARC138","ARC106","ARC143","ARC094","ARC218"
        },
        -- pack #14 in box #65
        [14] = {
            "ARC217","ARC203","ARC199","ARC209","ARC173","ARC093","ARC110","ARC117","ARC070","ARC032","ARC071","ARC037","ARC138","ARC101","ARC146","ARC039","ARC077"
        },
        -- pack #15 in box #65
        [15] = {
            "ARC191","ARC203","ARC197","ARC186","ARC011","ARC011","ARC089","ARC154","ARC022","ARC069","ARC026","ARC068","ARC099","ARC141","ARC101","ARC038","ARC002"
        },
        -- pack #16 in box #65
        [16] = {
            "ARC184","ARC178","ARC217","ARC186","ARC090","ARC056","ARC210","ARC152","ARC025","ARC071","ARC028","ARC143","ARC110","ARC134","ARC102","ARC075","ARC112"
        },
        -- pack #17 in box #65
        [17] = {
            "ARC189","ARC192","ARC194","ARC186","ARC164","ARC056","ARC149","ARC156","ARC031","ARC072","ARC020","ARC147","ARC094","ARC139","ARC102","ARC003","ARC038"
        },
        -- pack #18 in box #65
        [18] = {
            "ARC197","ARC182","ARC184","ARC176","ARC054","ARC118","ARC065","ARC151","ARC065","ARC027","ARC065","ARC025","ARC145","ARC098","ARC138","ARC038","ARC076"
        },
        -- pack #19 in box #65
        [19] = {
            "ARC212","ARC195","ARC193","ARC184","ARC012","ARC169","ARC140","ARC156","ARC072","ARC035","ARC069","ARC101","ARC137","ARC105","ARC135","ARC038","ARC075"
        },
        -- pack #20 in box #65
        [20] = {
            "ARC217","ARC192","ARC176","ARC176","ARC171","ARC163","ARC169","ARC154","ARC023","ARC064","ARC029","ARC067","ARC107","ARC137","ARC101","ARC076","ARC113"
        },
        -- pack #21 in box #65
        [21] = {
            "ARC213","ARC176","ARC213","ARC187","ARC168","ARC165","ARC036","ARC158","ARC069","ARC028","ARC069","ARC105","ARC141","ARC109","ARC132","ARC114","ARC113"
        },
        -- pack #22 in box #65
        [22] = {
            "ARC198","ARC193","ARC207","ARC187","ARC085","ARC175","ARC186","ARC042","ARC023","ARC068","ARC035","ARC069","ARC110","ARC139","ARC099","ARC002","ARC040"
        },
        -- pack #23 in box #65
        [23] = {
            "ARC178","ARC215","ARC204","ARC179","ARC056","ARC174","ARC117","ARC158","ARC071","ARC024","ARC067","ARC024","ARC136","ARC101","ARC134","ARC003","ARC114"
        },
        -- pack #24 in box #65
        [24] = {
            "ARC193","ARC179","ARC214","ARC188","ARC166","ARC057","ARC067","ARC005","ARC070","ARC034","ARC069","ARC099","ARC149","ARC103","ARC149","ARC038","ARC113"
        },
    },
    -- box #66
    [66] = {
        -- pack #1 in box #66
        [1] = {
            "ARC177","ARC189","ARC217","ARC197","ARC175","ARC059","ARC073","ARC154","ARC070","ARC021","ARC061","ARC036","ARC137","ARC100","ARC133","ARC077","ARC003"
        },
        -- pack #2 in box #66
        [2] = {
            "ARC197","ARC190","ARC199","ARC209","ARC131","ARC054","ARC055","ARC042","ARC064","ARC031","ARC063","ARC022","ARC136","ARC098","ARC140","ARC001","ARC077"
        },
        -- pack #3 in box #66
        [3] = {
            "ARC213","ARC209","ARC205","ARC183","ARC126","ARC171","ARC192","ARC151","ARC028","ARC072","ARC036","ARC069","ARC095","ARC141","ARC111","ARC218"
        },
        -- pack #4 in box #66
        [4] = {
            "ARC217","ARC199","ARC196","ARC197","ARC166","ARC090","ARC109","ARC117","ARC029","ARC067","ARC034","ARC068","ARC098","ARC136","ARC100","ARC114","ARC003"
        },
        -- pack #5 in box #66
        [5] = {
            "ARC199","ARC211","ARC206","ARC196","ARC017","ARC044","ARC195","ARC153","ARC026","ARC071","ARC037","ARC136","ARC103","ARC142","ARC108","ARC077","ARC038"
        },
        -- pack #6 in box #66
        [6] = {
            "ARC200","ARC203","ARC177","ARC212","ARC170","ARC121","ARC167","ARC151","ARC025","ARC060","ARC031","ARC135","ARC101","ARC142","ARC094","ARC001","ARC115"
        },
        -- pack #7 in box #66
        [7] = {
            "ARC201","ARC179","ARC190","ARC210","ARC126","ARC018","ARC021","ARC005","ARC073","ARC033","ARC073","ARC028","ARC147","ARC100","ARC137","ARC077","ARC040"
        },
        -- pack #8 in box #66
        [8] = {
            "ARC180","ARC179","ARC197","ARC190","ARC013","ARC125","ARC050","ARC156","ARC063","ARC036","ARC066","ARC105","ARC147","ARC104","ARC148","ARC218"
        },
        -- pack #9 in box #66
        [9] = {
            "ARC199","ARC184","ARC198","ARC185","ARC091","ARC011","ARC209","ARC157","ARC036","ARC063","ARC020","ARC145","ARC101","ARC135","ARC097","ARC076","ARC114"
        },
        -- pack #10 in box #66
        [10] = {
            "ARC203","ARC209","ARC191","ARC208","ARC013","ARC169","ARC217","ARC153","ARC070","ARC021","ARC072","ARC106","ARC146","ARC105","ARC149","ARC075","ARC076"
        },
        -- pack #11 in box #66
        [11] = {
            "ARC187","ARC209","ARC186","ARC195","ARC052","ARC085","ARC109","ARC117","ARC034","ARC064","ARC028","ARC070","ARC100","ARC149","ARC111","ARC076","ARC115"
        },
        -- pack #12 in box #66
        [12] = {
            "ARC188","ARC181","ARC201","ARC195","ARC093","ARC017","ARC209","ARC152","ARC036","ARC064","ARC029","ARC072","ARC106","ARC137","ARC103","ARC001","ARC113"
        },
        -- pack #13 in box #66
        [13] = {
            "ARC176","ARC184","ARC201","ARC176","ARC051","ARC016","ARC021","ARC042","ARC036","ARC063","ARC029","ARC145","ARC094","ARC140","ARC099","ARC039","ARC001"
        },
        -- pack #14 in box #66
        [14] = {
            "ARC200","ARC185","ARC188","ARC195","ARC018","ARC086","ARC111","ARC117","ARC029","ARC067","ARC020","ARC066","ARC105","ARC143","ARC098","ARC076","ARC038"
        },
        -- pack #15 in box #66
        [15] = {
            "ARC217","ARC204","ARC217","ARC194","ARC171","ARC088","ARC165","ARC156","ARC073","ARC026","ARC070","ARC020","ARC147","ARC110","ARC136","ARC002","ARC039"
        },
        -- pack #16 in box #66
        [16] = {
            "ARC193","ARC180","ARC201","ARC183","ARC173","ARC080","ARC149","ARC154","ARC025","ARC065","ARC036","ARC145","ARC106","ARC135","ARC103","ARC113","ARC002"
        },
        -- pack #17 in box #66
        [17] = {
            "ARC190","ARC191","ARC205","ARC199","ARC129","ARC057","ARC134","ARC157","ARC037","ARC068","ARC029","ARC062","ARC097","ARC147","ARC109","ARC218"
        },
        -- pack #18 in box #66
        [18] = {
            "ARC215","ARC199","ARC214","ARC180","ARC090","ARC015","ARC216","ARC079","ARC060","ARC033","ARC073","ARC108","ARC144","ARC106","ARC143","ARC114","ARC077"
        },
        -- pack #19 in box #66
        [19] = {
            "ARC207","ARC199","ARC201","ARC176","ARC166","ARC019","ARC030","ARC155","ARC071","ARC028","ARC074","ARC095","ARC139","ARC107","ARC143","ARC112","ARC038"
        },
        -- pack #20 in box #66
        [20] = {
            "ARC191","ARC179","ARC207","ARC193","ARC018","ARC164","ARC100","ARC154","ARC070","ARC034","ARC074","ARC101","ARC144","ARC106","ARC142","ARC076","ARC002"
        },
        -- pack #21 in box #66
        [21] = {
            "ARC199","ARC215","ARC203","ARC180","ARC015","ARC128","ARC025","ARC042","ARC066","ARC025","ARC069","ARC026","ARC142","ARC106","ARC144","ARC114","ARC038"
        },
        -- pack #22 in box #66
        [22] = {
            "ARC187","ARC191","ARC181","ARC206","ARC059","ARC047","ARC017","ARC005","ARC065","ARC030","ARC070","ARC031","ARC138","ARC106","ARC146","ARC112","ARC038"
        },
        -- pack #23 in box #66
        [23] = {
            "ARC176","ARC213","ARC190","ARC208","ARC019","ARC086","ARC035","ARC005","ARC060","ARC033","ARC072","ARC094","ARC135","ARC106","ARC146","ARC040","ARC114"
        },
        -- pack #24 in box #66
        [24] = {
            "ARC182","ARC217","ARC190","ARC191","ARC055","ARC015","ARC102","ARC157","ARC034","ARC065","ARC026","ARC143","ARC101","ARC136","ARC094","ARC115","ARC114"
        },
    },
    -- box #67
    [67] = {
        -- pack #1 in box #67
        [1] = {
            "ARC201","ARC206","ARC180","ARC180","ARC123","ARC048","ARC212","ARC079","ARC029","ARC071","ARC029","ARC067","ARC108","ARC134","ARC106","ARC077","ARC001"
        },
        -- pack #2 in box #67
        [2] = {
            "ARC180","ARC192","ARC179","ARC206","ARC123","ARC014","ARC164","ARC155","ARC068","ARC020","ARC069","ARC021","ARC132","ARC102","ARC137","ARC113","ARC115"
        },
        -- pack #3 in box #67
        [3] = {
            "ARC198","ARC194","ARC188","ARC194","ARC053","ARC166","ARC066","ARC156","ARC037","ARC062","ARC022","ARC138","ARC100","ARC145","ARC100","ARC039","ARC077"
        },
        -- pack #4 in box #67
        [4] = {
            "ARC185","ARC203","ARC190","ARC188","ARC093","ARC059","ARC130","ARC158","ARC035","ARC072","ARC022","ARC146","ARC095","ARC143","ARC096","ARC001","ARC039"
        },
        -- pack #5 in box #67
        [5] = {
            "ARC197","ARC205","ARC216","ARC188","ARC012","ARC053","ARC188","ARC154","ARC071","ARC027","ARC069","ARC023","ARC137","ARC107","ARC136","ARC077","ARC001"
        },
        -- pack #6 in box #67
        [6] = {
            "ARC211","ARC181","ARC180","ARC210","ARC130","ARC093","ARC082","ARC153","ARC067","ARC020","ARC071","ARC107","ARC144","ARC109","ARC133","ARC113","ARC002"
        },
        -- pack #7 in box #67
        [7] = {
            "ARC191","ARC205","ARC176","ARC189","ARC056","ARC053","ARC163","ARC153","ARC062","ARC031","ARC074","ARC101","ARC136","ARC106","ARC143","ARC112","ARC076"
        },
        -- pack #8 in box #67
        [8] = {
            "ARC182","ARC185","ARC203","ARC182","ARC173","ARC007","ARC188","ARC153","ARC024","ARC061","ARC033","ARC138","ARC097","ARC138","ARC102","ARC076","ARC038"
        },
        -- pack #9 in box #67
        [9] = {
            "ARC194","ARC179","ARC204","ARC197","ARC129","ARC006","ARC014","ARC158","ARC062","ARC032","ARC071","ARC099","ARC147","ARC104","ARC137","ARC112","ARC076"
        },
        -- pack #10 in box #67
        [10] = {
            "ARC180","ARC209","ARC204","ARC184","ARC013","ARC056","ARC185","ARC117","ARC037","ARC074","ARC033","ARC069","ARC105","ARC141","ARC103","ARC113","ARC076"
        },
        -- pack #11 in box #67
        [11] = {
            "ARC190","ARC214","ARC202","ARC210","ARC087","ARC050","ARC036","ARC155","ARC029","ARC074","ARC024","ARC141","ARC106","ARC149","ARC104","ARC076","ARC001"
        },
        -- pack #12 in box #67
        [12] = {
            "ARC213","ARC212","ARC179","ARC198","ARC018","ARC019","ARC027","ARC117","ARC065","ARC025","ARC068","ARC031","ARC145","ARC095","ARC133","ARC077","ARC003"
        },
        -- pack #13 in box #67
        [13] = {
            "ARC177","ARC191","ARC178","ARC182","ARC089","ARC008","ARC142","ARC158","ARC024","ARC064","ARC020","ARC138","ARC106","ARC133","ARC098","ARC039","ARC114"
        },
        -- pack #14 in box #67
        [14] = {
            "ARC210","ARC212","ARC191","ARC201","ARC127","ARC163","ARC024","ARC079","ARC069","ARC026","ARC072","ARC097","ARC133","ARC109","ARC144","ARC076","ARC001"
        },
        -- pack #15 in box #67
        [15] = {
            "ARC193","ARC186","ARC181","ARC188","ARC053","ARC126","ARC148","ARC117","ARC025","ARC072","ARC023","ARC135","ARC105","ARC141","ARC099","ARC114","ARC075"
        },
        -- pack #16 in box #67
        [16] = {
            "ARC196","ARC205","ARC217","ARC180","ARC168","ARC164","ARC178","ARC079","ARC066","ARC028","ARC062","ARC103","ARC138","ARC103","ARC141","ARC039","ARC114"
        },
        -- pack #17 in box #67
        [17] = {
            "ARC201","ARC185","ARC188","ARC176","ARC089","ARC170","ARC094","ARC151","ARC066","ARC030","ARC071","ARC021","ARC135","ARC104","ARC148","ARC218"
        },
        -- pack #18 in box #67
        [18] = {
            "ARC210","ARC185","ARC194","ARC215","ARC169","ARC044","ARC105","ARC079","ARC026","ARC074","ARC024","ARC063","ARC099","ARC134","ARC107","ARC038","ARC077"
        },
        -- pack #19 in box #67
        [19] = {
            "ARC178","ARC179","ARC214","ARC189","ARC052","ARC081","ARC088","ARC042","ARC073","ARC027","ARC060","ARC023","ARC146","ARC097","ARC140","ARC114","ARC001"
        },
        -- pack #20 in box #67
        [20] = {
            "ARC214","ARC195","ARC206","ARC187","ARC125","ARC058","ARC142","ARC151","ARC031","ARC072","ARC036","ARC066","ARC095","ARC139","ARC111","ARC115","ARC113"
        },
        -- pack #21 in box #67
        [21] = {
            "ARC183","ARC202","ARC177","ARC196","ARC013","ARC046","ARC054","ARC155","ARC025","ARC074","ARC029","ARC067","ARC105","ARC148","ARC111","ARC040","ARC002"
        },
        -- pack #22 in box #67
        [22] = {
            "ARC189","ARC206","ARC196","ARC184","ARC164","ARC130","ARC162","ARC156","ARC036","ARC071","ARC027","ARC062","ARC098","ARC143","ARC102","ARC112","ARC002"
        },
        -- pack #23 in box #67
        [23] = {
            "ARC182","ARC210","ARC186","ARC200","ARC058","ARC131","ARC140","ARC042","ARC069","ARC021","ARC064","ARC109","ARC147","ARC107","ARC148","ARC113","ARC039"
        },
        -- pack #24 in box #67
        [24] = {
            "ARC207","ARC181","ARC178","ARC195","ARC086","ARC121","ARC025","ARC154","ARC067","ARC027","ARC060","ARC020","ARC143","ARC105","ARC147","ARC002","ARC076"
        },
    },
    -- box #68
    [68] = {
        -- pack #1 in box #68
        [1] = {
            "ARC204","ARC180","ARC193","ARC201","ARC051","ARC054","ARC018","ARC152","ARC072","ARC028","ARC062","ARC020","ARC147","ARC094","ARC135","ARC112","ARC002"
        },
        -- pack #2 in box #68
        [2] = {
            "ARC210","ARC195","ARC178","ARC185","ARC058","ARC046","ARC168","ARC151","ARC037","ARC067","ARC025","ARC144","ARC105","ARC147","ARC105","ARC002","ARC076"
        },
        -- pack #3 in box #68
        [3] = {
            "ARC183","ARC215","ARC191","ARC178","ARC124","ARC015","ARC102","ARC117","ARC029","ARC072","ARC037","ARC062","ARC100","ARC137","ARC101","ARC001","ARC115"
        },
        -- pack #4 in box #68
        [4] = {
            "ARC193","ARC216","ARC200","ARC190","ARC059","ARC011","ARC210","ARC042","ARC030","ARC069","ARC031","ARC066","ARC104","ARC146","ARC106","ARC112","ARC115"
        },
        -- pack #5 in box #68
        [5] = {
            "ARC197","ARC178","ARC205","ARC203","ARC164","ARC087","ARC064","ARC158","ARC033","ARC067","ARC026","ARC132","ARC111","ARC132","ARC110","ARC003","ARC075"
        },
        -- pack #6 in box #68
        [6] = {
            "ARC213","ARC202","ARC207","ARC192","ARC053","ARC169","ARC061","ARC158","ARC062","ARC029","ARC060","ARC030","ARC132","ARC110","ARC134","ARC114","ARC003"
        },
        -- pack #7 in box #68
        [7] = {
            "ARC180","ARC207","ARC186","ARC199","ARC088","ARC083","ARC072","ARC154","ARC068","ARC022","ARC072","ARC104","ARC134","ARC110","ARC148","ARC039","ARC001"
        },
        -- pack #8 in box #68
        [8] = {
            "ARC196","ARC193","ARC203","ARC204","ARC123","ARC167","ARC073","ARC042","ARC020","ARC060","ARC024","ARC142","ARC106","ARC146","ARC098","ARC039","ARC077"
        },
        -- pack #9 in box #68
        [9] = {
            "ARC204","ARC186","ARC198","ARC203","ARC016","ARC011","ARC188","ARC079","ARC029","ARC060","ARC034","ARC060","ARC100","ARC135","ARC109","ARC112","ARC001"
        },
        -- pack #10 in box #68
        [10] = {
            "ARC205","ARC203","ARC193","ARC187","ARC052","ARC059","ARC188","ARC158","ARC026","ARC070","ARC026","ARC066","ARC102","ARC142","ARC102","ARC040","ARC039"
        },
        -- pack #11 in box #68
        [11] = {
            "ARC193","ARC204","ARC198","ARC182","ARC124","ARC059","ARC157","ARC042","ARC066","ARC023","ARC070","ARC097","ARC146","ARC104","ARC140","ARC038","ARC003"
        },
        -- pack #12 in box #68
        [12] = {
            "ARC183","ARC209","ARC195","ARC184","ARC128","ARC175","ARC195","ARC152","ARC032","ARC074","ARC027","ARC148","ARC101","ARC137","ARC104","ARC112","ARC077"
        },
        -- pack #13 in box #68
        [13] = {
            "ARC200","ARC208","ARC190","ARC189","ARC087","ARC050","ARC098","ARC042","ARC065","ARC035","ARC064","ARC024","ARC140","ARC110","ARC145","ARC038","ARC003"
        },
        -- pack #14 in box #68
        [14] = {
            "ARC196","ARC199","ARC187","ARC204","ARC050","ARC119","ARC061","ARC157","ARC069","ARC020","ARC070","ARC109","ARC144","ARC095","ARC149","ARC112","ARC075"
        },
        -- pack #15 in box #68
        [15] = {
            "ARC214","ARC185","ARC191","ARC182","ARC050","ARC018","ARC151","ARC154","ARC026","ARC071","ARC035","ARC146","ARC107","ARC139","ARC100","ARC075","ARC076"
        },
        -- pack #16 in box #68
        [16] = {
            "ARC214","ARC201","ARC195","ARC201","ARC131","ARC175","ARC202","ARC152","ARC061","ARC029","ARC071","ARC097","ARC140","ARC110","ARC142","ARC001","ARC040"
        },
        -- pack #17 in box #68
        [17] = {
            "ARC176","ARC213","ARC197","ARC208","ARC059","ARC169","ARC069","ARC154","ARC070","ARC037","ARC065","ARC036","ARC140","ARC102","ARC134","ARC039","ARC001"
        },
        -- pack #18 in box #68
        [18] = {
            "ARC215","ARC215","ARC188","ARC206","ARC059","ARC016","ARC053","ARC005","ARC062","ARC031","ARC064","ARC020","ARC136","ARC097","ARC137","ARC003","ARC076"
        },
        -- pack #19 in box #68
        [19] = {
            "ARC205","ARC198","ARC177","ARC188","ARC129","ARC166","ARC207","ARC152","ARC062","ARC031","ARC068","ARC027","ARC140","ARC094","ARC149","ARC114","ARC040"
        },
        -- pack #20 in box #68
        [20] = {
            "ARC186","ARC212","ARC207","ARC187","ARC049","ARC052","ARC012","ARC117","ARC035","ARC068","ARC029","ARC067","ARC098","ARC146","ARC109","ARC038","ARC039"
        },
        -- pack #21 in box #68
        [21] = {
            "ARC180","ARC186","ARC213","ARC206","ARC055","ARC173","ARC062","ARC151","ARC034","ARC067","ARC028","ARC145","ARC095","ARC148","ARC100","ARC218"
        },
        -- pack #22 in box #68
        [22] = {
            "ARC185","ARC208","ARC182","ARC200","ARC012","ARC121","ARC159","ARC156","ARC065","ARC037","ARC069","ARC101","ARC134","ARC105","ARC136","ARC076","ARC113"
        },
        -- pack #23 in box #68
        [23] = {
            "ARC177","ARC192","ARC211","ARC190","ARC127","ARC119","ARC138","ARC117","ARC028","ARC068","ARC021","ARC074","ARC101","ARC144","ARC094","ARC112","ARC076"
        },
        -- pack #24 in box #68
        [24] = {
            "ARC209","ARC189","ARC183","ARC183","ARC011","ARC011","ARC183","ARC153","ARC070","ARC020","ARC066","ARC097","ARC135","ARC105","ARC134","ARC115","ARC114"
        },
    },
    -- box #69
    [69] = {
        -- pack #1 in box #69
        [1] = {
            "ARC181","ARC180","ARC188","ARC216","ARC171","ARC019","ARC097","ARC152","ARC031","ARC065","ARC027","ARC061","ARC109","ARC144","ARC106","ARC076","ARC115"
        },
        -- pack #2 in box #69
        [2] = {
            "ARC211","ARC191","ARC217","ARC176","ARC014","ARC129","ARC083","ARC005","ARC067","ARC024","ARC074","ARC036","ARC146","ARC107","ARC147","ARC077","ARC001"
        },
        -- pack #3 in box #69
        [3] = {
            "ARC183","ARC190","ARC189","ARC183","ARC170","ARC129","ARC098","ARC005","ARC020","ARC066","ARC024","ARC067","ARC105","ARC148","ARC096","ARC002","ARC003"
        },
        -- pack #4 in box #69
        [4] = {
            "ARC197","ARC188","ARC190","ARC193","ARC057","ARC014","ARC011","ARC157","ARC070","ARC029","ARC066","ARC098","ARC132","ARC105","ARC143","ARC112","ARC040"
        },
        -- pack #5 in box #69
        [5] = {
            "ARC200","ARC181","ARC196","ARC196","ARC049","ARC046","ARC062","ARC154","ARC063","ARC033","ARC066","ARC020","ARC136","ARC102","ARC149","ARC075","ARC038"
        },
        -- pack #6 in box #69
        [6] = {
            "ARC198","ARC179","ARC181","ARC180","ARC172","ARC170","ARC065","ARC153","ARC027","ARC073","ARC022","ARC149","ARC107","ARC136","ARC098","ARC075","ARC077"
        },
        -- pack #7 in box #69
        [7] = {
            "ARC192","ARC196","ARC197","ARC203","ARC171","ARC171","ARC060","ARC158","ARC021","ARC063","ARC037","ARC073","ARC103","ARC148","ARC108","ARC003","ARC114"
        },
        -- pack #8 in box #69
        [8] = {
            "ARC186","ARC202","ARC193","ARC200","ARC048","ARC093","ARC060","ARC151","ARC033","ARC068","ARC024","ARC136","ARC096","ARC136","ARC104","ARC002","ARC115"
        },
        -- pack #9 in box #69
        [9] = {
            "ARC206","ARC188","ARC217","ARC176","ARC050","ARC169","ARC197","ARC042","ARC026","ARC061","ARC037","ARC137","ARC108","ARC141","ARC094","ARC076","ARC002"
        },
        -- pack #10 in box #69
        [10] = {
            "ARC197","ARC194","ARC199","ARC178","ARC059","ARC014","ARC194","ARC151","ARC029","ARC060","ARC031","ARC149","ARC106","ARC144","ARC102","ARC003","ARC039"
        },
        -- pack #11 in box #69
        [11] = {
            "ARC181","ARC215","ARC180","ARC215","ARC131","ARC012","ARC079","ARC153","ARC037","ARC060","ARC030","ARC145","ARC104","ARC146","ARC101","ARC002","ARC040"
        },
        -- pack #12 in box #69
        [12] = {
            "ARC201","ARC208","ARC181","ARC181","ARC087","ARC172","ARC168","ARC117","ARC032","ARC064","ARC032","ARC067","ARC102","ARC141","ARC109","ARC218"
        },
        -- pack #13 in box #69
        [13] = {
            "ARC217","ARC190","ARC209","ARC194","ARC086","ARC127","ARC193","ARC152","ARC062","ARC028","ARC061","ARC102","ARC135","ARC103","ARC134","ARC003","ARC039"
        },
        -- pack #14 in box #69
        [14] = {
            "ARC209","ARC181","ARC196","ARC198","ARC166","ARC014","ARC152","ARC155","ARC020","ARC061","ARC024","ARC064","ARC104","ARC144","ARC101","ARC115","ARC077"
        },
        -- pack #15 in box #69
        [15] = {
            "ARC194","ARC182","ARC212","ARC179","ARC088","ARC091","ARC106","ARC154","ARC071","ARC024","ARC071","ARC094","ARC147","ARC107","ARC132","ARC038","ARC114"
        },
        -- pack #16 in box #69
        [16] = {
            "ARC210","ARC210","ARC184","ARC191","ARC093","ARC159","ARC132","ARC079","ARC024","ARC067","ARC032","ARC141","ARC102","ARC137","ARC098","ARC040","ARC075"
        },
        -- pack #17 in box #69
        [17] = {
            "ARC188","ARC189","ARC217","ARC205","ARC050","ARC124","ARC180","ARC153","ARC073","ARC025","ARC064","ARC027","ARC146","ARC102","ARC146","ARC115","ARC113"
        },
        -- pack #18 in box #69
        [18] = {
            "ARC193","ARC177","ARC216","ARC192","ARC058","ARC013","ARC063","ARC157","ARC060","ARC037","ARC069","ARC036","ARC136","ARC097","ARC142","ARC218"
        },
        -- pack #19 in box #69
        [19] = {
            "ARC217","ARC183","ARC195","ARC178","ARC175","ARC173","ARC070","ARC157","ARC067","ARC028","ARC062","ARC033","ARC132","ARC105","ARC132","ARC038","ARC112"
        },
        -- pack #20 in box #69
        [20] = {
            "ARC198","ARC202","ARC189","ARC178","ARC087","ARC051","ARC190","ARC156","ARC073","ARC027","ARC060","ARC095","ARC133","ARC101","ARC132","ARC115","ARC112"
        },
        -- pack #21 in box #69
        [21] = {
            "ARC181","ARC190","ARC215","ARC179","ARC169","ARC082","ARC138","ARC042","ARC070","ARC029","ARC074","ARC035","ARC146","ARC107","ARC145","ARC039","ARC001"
        },
        -- pack #22 in box #69
        [22] = {
            "ARC178","ARC177","ARC201","ARC209","ARC048","ARC171","ARC030","ARC157","ARC072","ARC021","ARC073","ARC109","ARC144","ARC098","ARC145","ARC040","ARC002"
        },
        -- pack #23 in box #69
        [23] = {
            "ARC209","ARC212","ARC189","ARC216","ARC019","ARC085","ARC189","ARC157","ARC063","ARC030","ARC063","ARC105","ARC139","ARC102","ARC139","ARC038","ARC039"
        },
        -- pack #24 in box #69
        [24] = {
            "ARC211","ARC198","ARC186","ARC203","ARC123","ARC013","ARC064","ARC151","ARC027","ARC067","ARC035","ARC061","ARC105","ARC138","ARC097","ARC113","ARC039"
        },
    },
    -- box #70
    [70] = {
        -- pack #1 in box #70
        [1] = {
            "ARC196","ARC178","ARC200","ARC177","ARC173","ARC122","ARC198","ARC153","ARC069","ARC034","ARC074","ARC097","ARC141","ARC099","ARC139","ARC003","ARC002"
        },
        -- pack #2 in box #70
        [2] = {
            "ARC190","ARC216","ARC179","ARC189","ARC126","ARC092","ARC187","ARC158","ARC027","ARC060","ARC029","ARC061","ARC108","ARC147","ARC099","ARC001","ARC114"
        },
        -- pack #3 in box #70
        [3] = {
            "ARC188","ARC193","ARC202","ARC215","ARC170","ARC017","ARC144","ARC079","ARC071","ARC028","ARC074","ARC031","ARC139","ARC111","ARC143","ARC112","ARC002"
        },
        -- pack #4 in box #70
        [4] = {
            "ARC206","ARC202","ARC195","ARC201","ARC016","ARC018","ARC181","ARC005","ARC026","ARC067","ARC037","ARC140","ARC111","ARC149","ARC104","ARC114","ARC040"
        },
        -- pack #5 in box #70
        [5] = {
            "ARC177","ARC205","ARC176","ARC191","ARC055","ARC007","ARC167","ARC154","ARC035","ARC073","ARC023","ARC071","ARC096","ARC141","ARC110","ARC076","ARC038"
        },
        -- pack #6 in box #70
        [6] = {
            "ARC196","ARC199","ARC176","ARC189","ARC123","ARC175","ARC157","ARC154","ARC033","ARC061","ARC026","ARC139","ARC104","ARC132","ARC097","ARC039","ARC040"
        },
        -- pack #7 in box #70
        [7] = {
            "ARC213","ARC204","ARC207","ARC201","ARC054","ARC159","ARC022","ARC155","ARC062","ARC033","ARC064","ARC104","ARC139","ARC097","ARC148","ARC112","ARC075"
        },
        -- pack #8 in box #70
        [8] = {
            "ARC198","ARC205","ARC195","ARC178","ARC019","ARC125","ARC023","ARC157","ARC034","ARC071","ARC035","ARC067","ARC111","ARC135","ARC103","ARC075","ARC077"
        },
        -- pack #9 in box #70
        [9] = {
            "ARC188","ARC195","ARC190","ARC194","ARC164","ARC017","ARC124","ARC152","ARC061","ARC031","ARC062","ARC033","ARC143","ARC100","ARC144","ARC003","ARC075"
        },
        -- pack #10 in box #70
        [10] = {
            "ARC192","ARC206","ARC184","ARC188","ARC169","ARC017","ARC184","ARC005","ARC066","ARC034","ARC073","ARC107","ARC143","ARC102","ARC143","ARC076","ARC039"
        },
        -- pack #11 in box #70
        [11] = {
            "ARC190","ARC186","ARC210","ARC216","ARC166","ARC087","ARC033","ARC042","ARC073","ARC032","ARC066","ARC098","ARC144","ARC105","ARC139","ARC001","ARC115"
        },
        -- pack #12 in box #70
        [12] = {
            "ARC211","ARC203","ARC179","ARC194","ARC016","ARC168","ARC192","ARC152","ARC021","ARC072","ARC030","ARC143","ARC104","ARC135","ARC101","ARC218"
        },
        -- pack #13 in box #70
        [13] = {
            "ARC196","ARC205","ARC186","ARC188","ARC092","ARC051","ARC214","ARC117","ARC069","ARC024","ARC064","ARC100","ARC135","ARC105","ARC144","ARC002","ARC001"
        },
        -- pack #14 in box #70
        [14] = {
            "ARC198","ARC215","ARC207","ARC199","ARC017","ARC089","ARC104","ARC158","ARC024","ARC069","ARC035","ARC063","ARC102","ARC136","ARC099","ARC040","ARC112"
        },
        -- pack #15 in box #70
        [15] = {
            "ARC189","ARC182","ARC188","ARC211","ARC016","ARC167","ARC170","ARC079","ARC034","ARC074","ARC021","ARC137","ARC095","ARC141","ARC105","ARC075","ARC076"
        },
        -- pack #16 in box #70
        [16] = {
            "ARC201","ARC198","ARC204","ARC199","ARC130","ARC125","ARC139","ARC005","ARC062","ARC028","ARC070","ARC034","ARC144","ARC097","ARC148","ARC112","ARC076"
        },
        -- pack #17 in box #70
        [17] = {
            "ARC200","ARC214","ARC192","ARC194","ARC052","ARC165","ARC147","ARC157","ARC071","ARC037","ARC070","ARC035","ARC141","ARC104","ARC148","ARC003","ARC114"
        },
        -- pack #18 in box #70
        [18] = {
            "ARC203","ARC204","ARC203","ARC200","ARC054","ARC118","ARC032","ARC079","ARC036","ARC074","ARC026","ARC141","ARC109","ARC133","ARC107","ARC077","ARC038"
        },
        -- pack #19 in box #70
        [19] = {
            "ARC197","ARC189","ARC178","ARC199","ARC053","ARC161","ARC024","ARC117","ARC073","ARC020","ARC064","ARC022","ARC144","ARC105","ARC146","ARC075","ARC112"
        },
        -- pack #20 in box #70
        [20] = {
            "ARC216","ARC183","ARC210","ARC208","ARC092","ARC167","ARC049","ARC042","ARC065","ARC028","ARC068","ARC034","ARC141","ARC100","ARC149","ARC112","ARC114"
        },
        -- pack #21 in box #70
        [21] = {
            "ARC184","ARC213","ARC215","ARC199","ARC166","ARC131","ARC062","ARC042","ARC022","ARC072","ARC030","ARC062","ARC105","ARC148","ARC110","ARC112","ARC003"
        },
        -- pack #22 in box #70
        [22] = {
            "ARC183","ARC191","ARC204","ARC195","ARC174","ARC010","ARC129","ARC155","ARC027","ARC074","ARC034","ARC135","ARC111","ARC138","ARC104","ARC113","ARC040"
        },
        -- pack #23 in box #70
        [23] = {
            "ARC209","ARC181","ARC190","ARC217","ARC129","ARC118","ARC122","ARC158","ARC072","ARC022","ARC074","ARC094","ARC143","ARC098","ARC132","ARC075","ARC002"
        },
        -- pack #24 in box #70
        [24] = {
            "ARC211","ARC212","ARC197","ARC187","ARC126","ARC091","ARC099","ARC151","ARC023","ARC061","ARC033","ARC069","ARC100","ARC133","ARC096","ARC002","ARC114"
        },
    },
    -- box #71
    [71] = {
        -- pack #1 in box #71
        [1] = {
            "ARC177","ARC193","ARC193","ARC180","ARC085","ARC162","ARC144","ARC042","ARC027","ARC069","ARC033","ARC136","ARC107","ARC141","ARC105","ARC040","ARC039"
        },
        -- pack #2 in box #71
        [2] = {
            "ARC198","ARC203","ARC187","ARC181","ARC091","ARC168","ARC078","ARC157","ARC035","ARC065","ARC020","ARC133","ARC099","ARC142","ARC106","ARC039","ARC002"
        },
        -- pack #3 in box #71
        [3] = {
            "ARC212","ARC208","ARC185","ARC206","ARC015","ARC163","ARC193","ARC155","ARC025","ARC067","ARC020","ARC062","ARC100","ARC139","ARC102","ARC218"
        },
        -- pack #4 in box #71
        [4] = {
            "ARC198","ARC201","ARC180","ARC198","ARC172","ARC083","ARC104","ARC152","ARC037","ARC063","ARC022","ARC060","ARC095","ARC143","ARC108","ARC112","ARC040"
        },
        -- pack #5 in box #71
        [5] = {
            "ARC207","ARC208","ARC214","ARC191","ARC091","ARC048","ARC023","ARC042","ARC033","ARC061","ARC037","ARC074","ARC099","ARC144","ARC098","ARC002","ARC076"
        },
        -- pack #6 in box #71
        [6] = {
            "ARC203","ARC190","ARC217","ARC185","ARC131","ARC162","ARC029","ARC157","ARC027","ARC068","ARC025","ARC074","ARC106","ARC141","ARC095","ARC039","ARC040"
        },
        -- pack #7 in box #71
        [7] = {
            "ARC192","ARC199","ARC204","ARC206","ARC124","ARC057","ARC177","ARC117","ARC060","ARC028","ARC064","ARC105","ARC146","ARC107","ARC133","ARC039","ARC001"
        },
        -- pack #8 in box #71
        [8] = {
            "ARC181","ARC184","ARC204","ARC216","ARC170","ARC014","ARC028","ARC156","ARC022","ARC071","ARC021","ARC135","ARC100","ARC140","ARC111","ARC218"
        },
        -- pack #9 in box #71
        [9] = {
            "ARC198","ARC178","ARC177","ARC205","ARC091","ARC019","ARC208","ARC157","ARC065","ARC029","ARC073","ARC035","ARC135","ARC097","ARC132","ARC112","ARC077"
        },
        -- pack #10 in box #71
        [10] = {
            "ARC187","ARC196","ARC191","ARC189","ARC171","ARC162","ARC144","ARC156","ARC068","ARC027","ARC069","ARC035","ARC132","ARC108","ARC144","ARC076","ARC040"
        },
        -- pack #11 in box #71
        [11] = {
            "ARC210","ARC214","ARC206","ARC209","ARC168","ARC085","ARC069","ARC151","ARC022","ARC070","ARC037","ARC148","ARC094","ARC144","ARC108","ARC218"
        },
        -- pack #12 in box #71
        [12] = {
            "ARC184","ARC187","ARC183","ARC212","ARC013","ARC125","ARC005","ARC153","ARC030","ARC074","ARC022","ARC145","ARC108","ARC146","ARC105","ARC113","ARC076"
        },
        -- pack #13 in box #71
        [13] = {
            "ARC207","ARC180","ARC208","ARC196","ARC012","ARC166","ARC022","ARC157","ARC069","ARC036","ARC066","ARC095","ARC149","ARC103","ARC139","ARC001","ARC039"
        },
        -- pack #14 in box #71
        [14] = {
            "ARC192","ARC213","ARC212","ARC213","ARC088","ARC084","ARC198","ARC153","ARC070","ARC026","ARC063","ARC023","ARC132","ARC099","ARC148","ARC038","ARC039"
        },
        -- pack #15 in box #71
        [15] = {
            "ARC179","ARC186","ARC184","ARC200","ARC175","ARC090","ARC073","ARC005","ARC070","ARC033","ARC072","ARC033","ARC148","ARC095","ARC137","ARC218"
        },
        -- pack #16 in box #71
        [16] = {
            "ARC212","ARC212","ARC189","ARC205","ARC167","ARC167","ARC070","ARC042","ARC065","ARC023","ARC065","ARC031","ARC137","ARC098","ARC146","ARC113","ARC076"
        },
        -- pack #17 in box #71
        [17] = {
            "ARC189","ARC205","ARC204","ARC211","ARC129","ARC161","ARC036","ARC117","ARC034","ARC071","ARC026","ARC072","ARC095","ARC147","ARC101","ARC038","ARC113"
        },
        -- pack #18 in box #71
        [18] = {
            "ARC185","ARC185","ARC198","ARC212","ARC129","ARC165","ARC106","ARC156","ARC071","ARC024","ARC072","ARC110","ARC136","ARC094","ARC136","ARC115","ARC075"
        },
        -- pack #19 in box #71
        [19] = {
            "ARC208","ARC203","ARC179","ARC191","ARC171","ARC009","ARC186","ARC079","ARC061","ARC028","ARC073","ARC100","ARC132","ARC105","ARC145","ARC001","ARC114"
        },
        -- pack #20 in box #71
        [20] = {
            "ARC186","ARC204","ARC186","ARC208","ARC169","ARC124","ARC131","ARC152","ARC020","ARC063","ARC028","ARC145","ARC100","ARC136","ARC111","ARC076","ARC038"
        },
        -- pack #21 in box #71
        [21] = {
            "ARC209","ARC217","ARC183","ARC179","ARC052","ARC007","ARC029","ARC157","ARC036","ARC068","ARC023","ARC074","ARC106","ARC146","ARC108","ARC218"
        },
        -- pack #22 in box #71
        [22] = {
            "ARC193","ARC184","ARC202","ARC202","ARC168","ARC048","ARC211","ARC117","ARC060","ARC034","ARC067","ARC032","ARC139","ARC099","ARC138","ARC038","ARC040"
        },
        -- pack #23 in box #71
        [23] = {
            "ARC198","ARC182","ARC189","ARC213","ARC051","ARC052","ARC061","ARC117","ARC071","ARC034","ARC068","ARC107","ARC137","ARC106","ARC143","ARC218"
        },
        -- pack #24 in box #71
        [24] = {
            "ARC208","ARC188","ARC207","ARC177","ARC091","ARC080","ARC072","ARC117","ARC067","ARC037","ARC071","ARC108","ARC142","ARC099","ARC142","ARC077","ARC039"
        },
    },
    -- box #72
    [72] = {
        -- pack #1 in box #72
        [1] = {
            "ARC183","ARC217","ARC177","ARC214","ARC129","ARC050","ARC034","ARC156","ARC070","ARC035","ARC073","ARC026","ARC144","ARC096","ARC148","ARC001","ARC002"
        },
        -- pack #2 in box #72
        [2] = {
            "ARC198","ARC214","ARC214","ARC190","ARC089","ARC162","ARC125","ARC117","ARC032","ARC070","ARC020","ARC147","ARC095","ARC138","ARC099","ARC113","ARC077"
        },
        -- pack #3 in box #72
        [3] = {
            "ARC192","ARC208","ARC207","ARC188","ARC172","ARC010","ARC104","ARC079","ARC023","ARC065","ARC025","ARC132","ARC108","ARC134","ARC096","ARC218"
        },
        -- pack #4 in box #72
        [4] = {
            "ARC199","ARC215","ARC212","ARC188","ARC171","ARC165","ARC140","ARC158","ARC073","ARC026","ARC061","ARC099","ARC146","ARC101","ARC143","ARC039","ARC077"
        },
        -- pack #5 in box #72
        [5] = {
            "ARC178","ARC188","ARC183","ARC193","ARC171","ARC130","ARC030","ARC158","ARC062","ARC020","ARC062","ARC111","ARC149","ARC101","ARC139","ARC113","ARC077"
        },
        -- pack #6 in box #72
        [6] = {
            "ARC181","ARC182","ARC198","ARC197","ARC169","ARC167","ARC133","ARC005","ARC069","ARC035","ARC068","ARC024","ARC149","ARC103","ARC148","ARC038","ARC040"
        },
        -- pack #7 in box #72
        [7] = {
            "ARC190","ARC188","ARC181","ARC211","ARC017","ARC092","ARC205","ARC117","ARC033","ARC062","ARC025","ARC133","ARC100","ARC138","ARC109","ARC218"
        },
        -- pack #8 in box #72
        [8] = {
            "ARC182","ARC217","ARC210","ARC204","ARC127","ARC051","ARC110","ARC042","ARC021","ARC062","ARC036","ARC061","ARC095","ARC146","ARC109","ARC113","ARC040"
        },
        -- pack #9 in box #72
        [9] = {
            "ARC195","ARC211","ARC215","ARC194","ARC167","ARC083","ARC120","ARC158","ARC024","ARC065","ARC034","ARC074","ARC108","ARC145","ARC109","ARC113","ARC077"
        },
        -- pack #10 in box #72
        [10] = {
            "ARC200","ARC217","ARC196","ARC207","ARC168","ARC083","ARC153","ARC005","ARC033","ARC061","ARC035","ARC067","ARC107","ARC134","ARC104","ARC112","ARC077"
        },
        -- pack #11 in box #72
        [11] = {
            "ARC177","ARC210","ARC197","ARC213","ARC165","ARC171","ARC203","ARC155","ARC021","ARC063","ARC024","ARC133","ARC105","ARC140","ARC109","ARC218"
        },
        -- pack #12 in box #72
        [12] = {
            "ARC200","ARC180","ARC197","ARC208","ARC086","ARC080","ARC098","ARC117","ARC028","ARC072","ARC034","ARC073","ARC096","ARC137","ARC110","ARC040","ARC075"
        },
        -- pack #13 in box #72
        [13] = {
            "ARC196","ARC179","ARC204","ARC215","ARC089","ARC173","ARC048","ARC156","ARC022","ARC065","ARC028","ARC063","ARC094","ARC149","ARC097","ARC039","ARC003"
        },
        -- pack #14 in box #72
        [14] = {
            "ARC214","ARC203","ARC205","ARC201","ARC059","ARC013","ARC042","ARC117","ARC024","ARC063","ARC023","ARC061","ARC106","ARC140","ARC108","ARC112","ARC115"
        },
        -- pack #15 in box #72
        [15] = {
            "ARC212","ARC212","ARC196","ARC203","ARC091","ARC081","ARC127","ARC156","ARC031","ARC068","ARC035","ARC146","ARC109","ARC141","ARC102","ARC115","ARC040"
        },
        -- pack #16 in box #72
        [16] = {
            "ARC207","ARC192","ARC210","ARC176","ARC015","ARC161","ARC065","ARC158","ARC066","ARC033","ARC064","ARC034","ARC145","ARC101","ARC136","ARC113","ARC038"
        },
        -- pack #17 in box #72
        [17] = {
            "ARC210","ARC199","ARC213","ARC216","ARC166","ARC171","ARC031","ARC158","ARC060","ARC031","ARC068","ARC094","ARC141","ARC098","ARC132","ARC114","ARC077"
        },
        -- pack #18 in box #72
        [18] = {
            "ARC180","ARC214","ARC208","ARC205","ARC051","ARC054","ARC027","ARC151","ARC064","ARC026","ARC072","ARC110","ARC143","ARC094","ARC139","ARC003","ARC076"
        },
        -- pack #19 in box #72
        [19] = {
            "ARC176","ARC195","ARC198","ARC188","ARC173","ARC083","ARC064","ARC158","ARC066","ARC026","ARC064","ARC025","ARC136","ARC099","ARC140","ARC075","ARC114"
        },
        -- pack #20 in box #72
        [20] = {
            "ARC213","ARC198","ARC185","ARC203","ARC056","ARC055","ARC042","ARC152","ARC032","ARC062","ARC028","ARC137","ARC105","ARC147","ARC101","ARC038","ARC115"
        },
        -- pack #21 in box #72
        [21] = {
            "ARC194","ARC178","ARC193","ARC185","ARC011","ARC165","ARC213","ARC151","ARC067","ARC026","ARC066","ARC034","ARC142","ARC110","ARC147","ARC040","ARC114"
        },
        -- pack #22 in box #72
        [22] = {
            "ARC195","ARC195","ARC181","ARC186","ARC013","ARC013","ARC035","ARC151","ARC069","ARC033","ARC067","ARC109","ARC141","ARC104","ARC139","ARC076","ARC039"
        },
        -- pack #23 in box #72
        [23] = {
            "ARC187","ARC183","ARC177","ARC213","ARC165","ARC086","ARC016","ARC156","ARC068","ARC025","ARC072","ARC032","ARC148","ARC103","ARC148","ARC002","ARC075"
        },
        -- pack #24 in box #72
        [24] = {
            "ARC193","ARC178","ARC206","ARC194","ARC168","ARC167","ARC196","ARC152","ARC071","ARC036","ARC063","ARC110","ARC148","ARC094","ARC149","ARC075","ARC001"
        },
    },
    -- box #73
    [73] = {
        -- pack #1 in box #73
        [1] = {
            "ARC199","ARC201","ARC186","ARC216","ARC125","ARC130","ARC046","ARC152","ARC072","ARC023","ARC068","ARC022","ARC146","ARC099","ARC132","ARC002","ARC039"
        },
        -- pack #2 in box #73
        [2] = {
            "ARC178","ARC198","ARC185","ARC203","ARC087","ARC121","ARC142","ARC151","ARC028","ARC066","ARC033","ARC149","ARC102","ARC135","ARC107","ARC115","ARC001"
        },
        -- pack #3 in box #73
        [3] = {
            "ARC211","ARC196","ARC197","ARC205","ARC051","ARC011","ARC216","ARC152","ARC031","ARC061","ARC021","ARC067","ARC108","ARC138","ARC101","ARC040","ARC038"
        },
        -- pack #4 in box #73
        [4] = {
            "ARC199","ARC185","ARC192","ARC205","ARC175","ARC019","ARC019","ARC042","ARC035","ARC066","ARC035","ARC141","ARC109","ARC135","ARC108","ARC039","ARC112"
        },
        -- pack #5 in box #73
        [5] = {
            "ARC187","ARC203","ARC191","ARC180","ARC089","ARC006","ARC100","ARC153","ARC029","ARC070","ARC032","ARC063","ARC095","ARC147","ARC108","ARC038","ARC112"
        },
        -- pack #6 in box #73
        [6] = {
            "ARC176","ARC209","ARC208","ARC176","ARC011","ARC087","ARC095","ARC154","ARC020","ARC060","ARC027","ARC138","ARC101","ARC146","ARC104","ARC218"
        },
        -- pack #7 in box #73
        [7] = {
            "ARC195","ARC182","ARC210","ARC208","ARC015","ARC057","ARC072","ARC157","ARC066","ARC036","ARC070","ARC098","ARC134","ARC102","ARC143","ARC002","ARC040"
        },
        -- pack #8 in box #73
        [8] = {
            "ARC188","ARC203","ARC184","ARC209","ARC125","ARC121","ARC125","ARC154","ARC064","ARC036","ARC066","ARC030","ARC136","ARC108","ARC134","ARC113","ARC001"
        },
        -- pack #9 in box #73
        [9] = {
            "ARC185","ARC192","ARC209","ARC204","ARC015","ARC056","ARC209","ARC042","ARC033","ARC062","ARC031","ARC063","ARC105","ARC149","ARC111","ARC003","ARC038"
        },
        -- pack #10 in box #73
        [10] = {
            "ARC207","ARC197","ARC211","ARC197","ARC014","ARC045","ARC212","ARC153","ARC070","ARC020","ARC066","ARC105","ARC147","ARC095","ARC145","ARC218"
        },
        -- pack #11 in box #73
        [11] = {
            "ARC184","ARC212","ARC215","ARC177","ARC018","ARC125","ARC217","ARC152","ARC020","ARC073","ARC020","ARC138","ARC111","ARC141","ARC102","ARC039","ARC112"
        },
        -- pack #12 in box #73
        [12] = {
            "ARC194","ARC182","ARC204","ARC182","ARC169","ARC043","ARC185","ARC153","ARC074","ARC029","ARC063","ARC027","ARC148","ARC105","ARC147","ARC075","ARC038"
        },
        -- pack #13 in box #73
        [13] = {
            "ARC187","ARC215","ARC193","ARC187","ARC131","ARC090","ARC177","ARC155","ARC068","ARC024","ARC070","ARC029","ARC136","ARC098","ARC138","ARC038","ARC112"
        },
        -- pack #14 in box #73
        [14] = {
            "ARC211","ARC199","ARC198","ARC180","ARC093","ARC164","ARC042","ARC042","ARC074","ARC025","ARC072","ARC027","ARC133","ARC106","ARC136","ARC039","ARC113"
        },
        -- pack #15 in box #73
        [15] = {
            "ARC199","ARC199","ARC210","ARC189","ARC169","ARC088","ARC180","ARC042","ARC072","ARC027","ARC066","ARC036","ARC137","ARC111","ARC141","ARC113","ARC075"
        },
        -- pack #16 in box #73
        [16] = {
            "ARC180","ARC209","ARC195","ARC194","ARC054","ARC006","ARC049","ARC005","ARC027","ARC073","ARC023","ARC061","ARC096","ARC132","ARC109","ARC077","ARC040"
        },
        -- pack #17 in box #73
        [17] = {
            "ARC179","ARC207","ARC181","ARC195","ARC173","ARC043","ARC193","ARC005","ARC071","ARC036","ARC061","ARC106","ARC139","ARC111","ARC146","ARC040","ARC003"
        },
        -- pack #18 in box #73
        [18] = {
            "ARC177","ARC180","ARC209","ARC195","ARC048","ARC087","ARC185","ARC157","ARC071","ARC028","ARC073","ARC097","ARC139","ARC098","ARC141","ARC002","ARC077"
        },
        -- pack #19 in box #73
        [19] = {
            "ARC214","ARC182","ARC180","ARC216","ARC125","ARC128","ARC104","ARC156","ARC029","ARC073","ARC024","ARC149","ARC104","ARC140","ARC097","ARC113","ARC002"
        },
        -- pack #20 in box #73
        [20] = {
            "ARC202","ARC214","ARC206","ARC201","ARC017","ARC166","ARC187","ARC042","ARC071","ARC022","ARC061","ARC099","ARC140","ARC103","ARC141","ARC003","ARC002"
        },
        -- pack #21 in box #73
        [21] = {
            "ARC214","ARC208","ARC184","ARC186","ARC048","ARC046","ARC209","ARC117","ARC035","ARC065","ARC029","ARC133","ARC103","ARC149","ARC106","ARC075","ARC114"
        },
        -- pack #22 in box #73
        [22] = {
            "ARC189","ARC212","ARC196","ARC212","ARC054","ARC128","ARC015","ARC154","ARC032","ARC062","ARC032","ARC060","ARC110","ARC133","ARC094","ARC003","ARC001"
        },
        -- pack #23 in box #73
        [23] = {
            "ARC208","ARC194","ARC193","ARC191","ARC012","ARC119","ARC196","ARC079","ARC072","ARC021","ARC063","ARC098","ARC149","ARC097","ARC149","ARC075","ARC001"
        },
        -- pack #24 in box #73
        [24] = {
            "ARC187","ARC211","ARC208","ARC196","ARC131","ARC122","ARC200","ARC079","ARC033","ARC072","ARC024","ARC069","ARC107","ARC148","ARC103","ARC077","ARC038"
        },
    },
    -- box #74
    [74] = {
        -- pack #1 in box #74
        [1] = {
            "ARC187","ARC215","ARC217","ARC214","ARC171","ARC161","ARC018","ARC152","ARC066","ARC028","ARC067","ARC110","ARC148","ARC107","ARC133","ARC001","ARC115"
        },
        -- pack #2 in box #74
        [2] = {
            "ARC177","ARC200","ARC205","ARC178","ARC015","ARC089","ARC036","ARC157","ARC029","ARC068","ARC024","ARC072","ARC103","ARC137","ARC100","ARC218"
        },
        -- pack #3 in box #74
        [3] = {
            "ARC199","ARC186","ARC195","ARC210","ARC175","ARC174","ARC074","ARC005","ARC066","ARC034","ARC061","ARC023","ARC141","ARC105","ARC134","ARC218"
        },
        -- pack #4 in box #74
        [4] = {
            "ARC217","ARC199","ARC197","ARC193","ARC128","ARC006","ARC071","ARC156","ARC073","ARC030","ARC071","ARC029","ARC147","ARC094","ARC145","ARC076","ARC113"
        },
        -- pack #5 in box #74
        [5] = {
            "ARC194","ARC192","ARC185","ARC212","ARC019","ARC131","ARC128","ARC155","ARC033","ARC062","ARC028","ARC141","ARC105","ARC133","ARC098","ARC040","ARC002"
        },
        -- pack #6 in box #74
        [6] = {
            "ARC210","ARC196","ARC183","ARC183","ARC126","ARC163","ARC155","ARC152","ARC060","ARC027","ARC062","ARC037","ARC148","ARC094","ARC137","ARC077","ARC114"
        },
        -- pack #7 in box #74
        [7] = {
            "ARC190","ARC210","ARC181","ARC180","ARC054","ARC091","ARC088","ARC156","ARC021","ARC065","ARC036","ARC074","ARC096","ARC135","ARC094","ARC075","ARC039"
        },
        -- pack #8 in box #74
        [8] = {
            "ARC217","ARC185","ARC195","ARC214","ARC054","ARC129","ARC009","ARC153","ARC027","ARC070","ARC036","ARC140","ARC102","ARC148","ARC111","ARC113","ARC003"
        },
        -- pack #9 in box #74
        [9] = {
            "ARC214","ARC180","ARC184","ARC190","ARC050","ARC009","ARC146","ARC156","ARC020","ARC060","ARC026","ARC070","ARC109","ARC145","ARC110","ARC218"
        },
        -- pack #10 in box #74
        [10] = {
            "ARC211","ARC206","ARC202","ARC202","ARC091","ARC049","ARC178","ARC157","ARC027","ARC061","ARC029","ARC067","ARC108","ARC144","ARC110","ARC002","ARC040"
        },
        -- pack #11 in box #74
        [11] = {
            "ARC191","ARC177","ARC188","ARC204","ARC167","ARC054","ARC184","ARC154","ARC026","ARC066","ARC037","ARC069","ARC100","ARC136","ARC101","ARC114","ARC001"
        },
        -- pack #12 in box #74
        [12] = {
            "ARC197","ARC180","ARC192","ARC184","ARC055","ARC173","ARC194","ARC079","ARC061","ARC026","ARC061","ARC098","ARC144","ARC106","ARC133","ARC075","ARC038"
        },
        -- pack #13 in box #74
        [13] = {
            "ARC187","ARC203","ARC189","ARC183","ARC126","ARC174","ARC026","ARC157","ARC025","ARC074","ARC033","ARC133","ARC095","ARC143","ARC103","ARC040","ARC112"
        },
        -- pack #14 in box #74
        [14] = {
            "ARC213","ARC211","ARC190","ARC214","ARC170","ARC172","ARC065","ARC158","ARC068","ARC023","ARC065","ARC097","ARC138","ARC107","ARC149","ARC001","ARC115"
        },
        -- pack #15 in box #74
        [15] = {
            "ARC185","ARC216","ARC181","ARC180","ARC126","ARC171","ARC137","ARC153","ARC025","ARC060","ARC024","ARC139","ARC108","ARC142","ARC096","ARC075","ARC001"
        },
        -- pack #16 in box #74
        [16] = {
            "ARC217","ARC187","ARC194","ARC188","ARC054","ARC053","ARC189","ARC079","ARC065","ARC023","ARC067","ARC104","ARC139","ARC097","ARC137","ARC003","ARC075"
        },
        -- pack #17 in box #74
        [17] = {
            "ARC193","ARC199","ARC209","ARC212","ARC053","ARC119","ARC008","ARC042","ARC073","ARC023","ARC073","ARC036","ARC141","ARC094","ARC139","ARC038","ARC115"
        },
        -- pack #18 in box #74
        [18] = {
            "ARC211","ARC191","ARC215","ARC213","ARC093","ARC166","ARC087","ARC005","ARC068","ARC029","ARC068","ARC102","ARC134","ARC111","ARC132","ARC076","ARC002"
        },
        -- pack #19 in box #74
        [19] = {
            "ARC209","ARC197","ARC198","ARC203","ARC057","ARC019","ARC194","ARC152","ARC036","ARC063","ARC033","ARC140","ARC099","ARC147","ARC110","ARC040","ARC002"
        },
        -- pack #20 in box #74
        [20] = {
            "ARC213","ARC187","ARC214","ARC197","ARC017","ARC129","ARC092","ARC079","ARC069","ARC035","ARC068","ARC101","ARC139","ARC110","ARC148","ARC114","ARC039"
        },
        -- pack #21 in box #74
        [21] = {
            "ARC199","ARC213","ARC212","ARC184","ARC175","ARC087","ARC099","ARC156","ARC071","ARC026","ARC072","ARC027","ARC138","ARC100","ARC140","ARC076","ARC001"
        },
        -- pack #22 in box #74
        [22] = {
            "ARC207","ARC189","ARC202","ARC216","ARC049","ARC083","ARC068","ARC155","ARC074","ARC023","ARC072","ARC022","ARC134","ARC110","ARC135","ARC115","ARC112"
        },
        -- pack #23 in box #74
        [23] = {
            "ARC199","ARC189","ARC186","ARC216","ARC052","ARC012","ARC071","ARC154","ARC023","ARC065","ARC027","ARC069","ARC095","ARC148","ARC100","ARC076","ARC002"
        },
        -- pack #24 in box #74
        [24] = {
            "ARC206","ARC185","ARC212","ARC192","ARC051","ARC082","ARC189","ARC155","ARC030","ARC067","ARC021","ARC139","ARC097","ARC146","ARC095","ARC114","ARC039"
        },
    },
    -- box #75
    [75] = {
        -- pack #1 in box #75
        [1] = {
            "ARC181","ARC209","ARC198","ARC182","ARC170","ARC164","ARC026","ARC156","ARC063","ARC034","ARC066","ARC033","ARC146","ARC099","ARC140","ARC038","ARC040"
        },
        -- pack #2 in box #75
        [2] = {
            "ARC212","ARC182","ARC207","ARC204","ARC058","ARC131","ARC145","ARC156","ARC073","ARC024","ARC064","ARC110","ARC137","ARC099","ARC137","ARC077","ARC038"
        },
        -- pack #3 in box #75
        [3] = {
            "ARC211","ARC211","ARC201","ARC217","ARC051","ARC161","ARC072","ARC152","ARC034","ARC071","ARC034","ARC068","ARC095","ARC135","ARC104","ARC001","ARC040"
        },
        -- pack #4 in box #75
        [4] = {
            "ARC201","ARC188","ARC194","ARC193","ARC128","ARC087","ARC093","ARC005","ARC071","ARC037","ARC067","ARC106","ARC136","ARC104","ARC139","ARC076","ARC112"
        },
        -- pack #5 in box #75
        [5] = {
            "ARC213","ARC211","ARC179","ARC212","ARC058","ARC130","ARC185","ARC152","ARC034","ARC074","ARC025","ARC071","ARC101","ARC148","ARC108","ARC076","ARC038"
        },
        -- pack #6 in box #75
        [6] = {
            "ARC216","ARC190","ARC179","ARC215","ARC126","ARC130","ARC138","ARC155","ARC037","ARC065","ARC033","ARC061","ARC095","ARC133","ARC104","ARC038","ARC113"
        },
        -- pack #7 in box #75
        [7] = {
            "ARC211","ARC179","ARC182","ARC211","ARC052","ARC164","ARC135","ARC151","ARC070","ARC027","ARC060","ARC025","ARC133","ARC104","ARC144","ARC077","ARC038"
        },
        -- pack #8 in box #75
        [8] = {
            "ARC212","ARC183","ARC200","ARC189","ARC170","ARC122","ARC136","ARC156","ARC037","ARC071","ARC031","ARC062","ARC095","ARC137","ARC099","ARC077","ARC113"
        },
        -- pack #9 in box #75
        [9] = {
            "ARC212","ARC197","ARC214","ARC185","ARC058","ARC168","ARC095","ARC042","ARC074","ARC030","ARC073","ARC026","ARC149","ARC110","ARC149","ARC114","ARC002"
        },
        -- pack #10 in box #75
        [10] = {
            "ARC177","ARC187","ARC214","ARC209","ARC166","ARC122","ARC213","ARC156","ARC070","ARC035","ARC060","ARC103","ARC140","ARC099","ARC141","ARC115","ARC039"
        },
        -- pack #11 in box #75
        [11] = {
            "ARC213","ARC216","ARC187","ARC192","ARC057","ARC124","ARC175","ARC079","ARC063","ARC027","ARC072","ARC102","ARC145","ARC105","ARC136","ARC218"
        },
        -- pack #12 in box #75
        [12] = {
            "ARC187","ARC181","ARC189","ARC189","ARC085","ARC081","ARC200","ARC158","ARC064","ARC030","ARC070","ARC031","ARC133","ARC110","ARC147","ARC114","ARC077"
        },
        -- pack #13 in box #75
        [13] = {
            "ARC215","ARC188","ARC178","ARC181","ARC011","ARC050","ARC195","ARC079","ARC062","ARC025","ARC060","ARC020","ARC143","ARC094","ARC138","ARC114","ARC001"
        },
        -- pack #14 in box #75
        [14] = {
            "ARC203","ARC186","ARC194","ARC205","ARC019","ARC159","ARC095","ARC157","ARC031","ARC070","ARC029","ARC132","ARC102","ARC140","ARC099","ARC075","ARC038"
        },
        -- pack #15 in box #75
        [15] = {
            "ARC215","ARC209","ARC202","ARC187","ARC130","ARC052","ARC206","ARC005","ARC023","ARC069","ARC037","ARC142","ARC103","ARC139","ARC111","ARC075","ARC002"
        },
        -- pack #16 in box #75
        [16] = {
            "ARC197","ARC213","ARC190","ARC180","ARC171","ARC046","ARC063","ARC154","ARC033","ARC071","ARC026","ARC140","ARC111","ARC133","ARC106","ARC001","ARC076"
        },
        -- pack #17 in box #75
        [17] = {
            "ARC206","ARC202","ARC176","ARC196","ARC017","ARC053","ARC154","ARC154","ARC028","ARC074","ARC034","ARC073","ARC101","ARC142","ARC101","ARC113","ARC077"
        },
        -- pack #18 in box #75
        [18] = {
            "ARC212","ARC194","ARC198","ARC208","ARC014","ARC015","ARC015","ARC042","ARC070","ARC033","ARC064","ARC097","ARC146","ARC108","ARC148","ARC075","ARC040"
        },
        -- pack #19 in box #75
        [19] = {
            "ARC188","ARC210","ARC185","ARC189","ARC059","ARC164","ARC156","ARC154","ARC036","ARC063","ARC028","ARC141","ARC096","ARC142","ARC106","ARC003","ARC075"
        },
        -- pack #20 in box #75
        [20] = {
            "ARC180","ARC201","ARC195","ARC196","ARC050","ARC059","ARC177","ARC157","ARC023","ARC060","ARC022","ARC070","ARC096","ARC140","ARC106","ARC040","ARC113"
        },
        -- pack #21 in box #75
        [21] = {
            "ARC191","ARC185","ARC198","ARC191","ARC087","ARC160","ARC147","ARC079","ARC068","ARC032","ARC068","ARC032","ARC141","ARC103","ARC141","ARC039","ARC001"
        },
        -- pack #22 in box #75
        [22] = {
            "ARC215","ARC176","ARC216","ARC182","ARC048","ARC092","ARC101","ARC154","ARC031","ARC069","ARC031","ARC139","ARC097","ARC149","ARC104","ARC077","ARC076"
        },
        -- pack #23 in box #75
        [23] = {
            "ARC187","ARC192","ARC204","ARC183","ARC164","ARC123","ARC133","ARC157","ARC065","ARC025","ARC062","ARC094","ARC149","ARC097","ARC137","ARC076","ARC113"
        },
        -- pack #24 in box #75
        [24] = {
            "ARC214","ARC181","ARC206","ARC198","ARC087","ARC118","ARC212","ARC153","ARC023","ARC063","ARC035","ARC135","ARC108","ARC147","ARC100","ARC076","ARC113"
        },
    },
    -- box #76
    [76] = {
        -- pack #1 in box #76
        [1] = {
            "ARC186","ARC185","ARC216","ARC199","ARC056","ARC124","ARC198","ARC158","ARC070","ARC037","ARC060","ARC103","ARC141","ARC105","ARC148","ARC002","ARC038"
        },
        -- pack #2 in box #76
        [2] = {
            "ARC215","ARC213","ARC184","ARC201","ARC059","ARC085","ARC187","ARC158","ARC030","ARC061","ARC031","ARC146","ARC105","ARC134","ARC094","ARC112","ARC076"
        },
        -- pack #3 in box #76
        [3] = {
            "ARC200","ARC213","ARC185","ARC210","ARC168","ARC050","ARC026","ARC079","ARC030","ARC069","ARC029","ARC144","ARC106","ARC143","ARC100","ARC077","ARC075"
        },
        -- pack #4 in box #76
        [4] = {
            "ARC181","ARC206","ARC216","ARC204","ARC090","ARC047","ARC035","ARC005","ARC074","ARC020","ARC063","ARC022","ARC139","ARC109","ARC144","ARC113","ARC115"
        },
        -- pack #5 in box #76
        [5] = {
            "ARC198","ARC177","ARC187","ARC182","ARC128","ARC054","ARC095","ARC117","ARC033","ARC065","ARC031","ARC135","ARC110","ARC135","ARC100","ARC002","ARC075"
        },
        -- pack #6 in box #76
        [6] = {
            "ARC176","ARC194","ARC207","ARC215","ARC049","ARC014","ARC180","ARC154","ARC032","ARC072","ARC025","ARC137","ARC107","ARC145","ARC097","ARC112","ARC075"
        },
        -- pack #7 in box #76
        [7] = {
            "ARC200","ARC179","ARC217","ARC212","ARC170","ARC016","ARC108","ARC005","ARC062","ARC020","ARC070","ARC099","ARC143","ARC095","ARC143","ARC076","ARC075"
        },
        -- pack #8 in box #76
        [8] = {
            "ARC212","ARC193","ARC199","ARC183","ARC174","ARC126","ARC070","ARC157","ARC061","ARC032","ARC074","ARC028","ARC134","ARC095","ARC146","ARC218"
        },
        -- pack #9 in box #76
        [9] = {
            "ARC199","ARC177","ARC180","ARC200","ARC166","ARC052","ARC174","ARC155","ARC073","ARC025","ARC060","ARC035","ARC142","ARC110","ARC143","ARC038","ARC001"
        },
        -- pack #10 in box #76
        [10] = {
            "ARC196","ARC216","ARC186","ARC185","ARC127","ARC080","ARC099","ARC042","ARC034","ARC066","ARC030","ARC064","ARC094","ARC134","ARC094","ARC039","ARC112"
        },
        -- pack #11 in box #76
        [11] = {
            "ARC190","ARC189","ARC198","ARC185","ARC016","ARC046","ARC072","ARC079","ARC030","ARC061","ARC028","ARC062","ARC104","ARC132","ARC096","ARC115","ARC003"
        },
        -- pack #12 in box #76
        [12] = {
            "ARC203","ARC191","ARC215","ARC216","ARC089","ARC015","ARC097","ARC154","ARC071","ARC031","ARC067","ARC023","ARC140","ARC108","ARC133","ARC115","ARC039"
        },
        -- pack #13 in box #76
        [13] = {
            "ARC176","ARC189","ARC180","ARC185","ARC165","ARC083","ARC204","ARC154","ARC026","ARC064","ARC025","ARC066","ARC096","ARC135","ARC109","ARC218"
        },
        -- pack #14 in box #76
        [14] = {
            "ARC196","ARC192","ARC215","ARC195","ARC017","ARC127","ARC017","ARC157","ARC068","ARC027","ARC069","ARC100","ARC140","ARC101","ARC138","ARC077","ARC114"
        },
        -- pack #15 in box #76
        [15] = {
            "ARC184","ARC200","ARC186","ARC196","ARC171","ARC016","ARC207","ARC151","ARC073","ARC020","ARC064","ARC110","ARC147","ARC100","ARC137","ARC076","ARC003"
        },
        -- pack #16 in box #76
        [16] = {
            "ARC179","ARC217","ARC196","ARC188","ARC130","ARC056","ARC073","ARC042","ARC065","ARC034","ARC068","ARC105","ARC140","ARC105","ARC137","ARC001","ARC002"
        },
        -- pack #17 in box #76
        [17] = {
            "ARC201","ARC214","ARC210","ARC196","ARC054","ARC125","ARC062","ARC155","ARC022","ARC069","ARC028","ARC070","ARC099","ARC136","ARC100","ARC002","ARC115"
        },
        -- pack #18 in box #76
        [18] = {
            "ARC182","ARC180","ARC177","ARC182","ARC056","ARC059","ARC145","ARC005","ARC067","ARC026","ARC069","ARC109","ARC145","ARC094","ARC140","ARC077","ARC039"
        },
        -- pack #19 in box #76
        [19] = {
            "ARC213","ARC205","ARC191","ARC191","ARC126","ARC016","ARC207","ARC154","ARC026","ARC066","ARC021","ARC134","ARC105","ARC145","ARC099","ARC114","ARC002"
        },
        -- pack #20 in box #76
        [20] = {
            "ARC200","ARC213","ARC209","ARC182","ARC175","ARC087","ARC030","ARC005","ARC061","ARC035","ARC065","ARC032","ARC145","ARC106","ARC145","ARC114","ARC075"
        },
        -- pack #21 in box #76
        [21] = {
            "ARC207","ARC204","ARC186","ARC205","ARC019","ARC009","ARC133","ARC157","ARC033","ARC061","ARC034","ARC063","ARC100","ARC141","ARC101","ARC115","ARC112"
        },
        -- pack #22 in box #76
        [22] = {
            "ARC206","ARC181","ARC209","ARC194","ARC092","ARC124","ARC062","ARC152","ARC022","ARC073","ARC022","ARC070","ARC110","ARC135","ARC101","ARC039","ARC115"
        },
        -- pack #23 in box #76
        [23] = {
            "ARC199","ARC185","ARC185","ARC193","ARC086","ARC045","ARC118","ARC153","ARC067","ARC033","ARC061","ARC021","ARC134","ARC099","ARC142","ARC077","ARC112"
        },
        -- pack #24 in box #76
        [24] = {
            "ARC202","ARC213","ARC214","ARC213","ARC013","ARC121","ARC139","ARC153","ARC028","ARC063","ARC032","ARC148","ARC103","ARC143","ARC110","ARC003","ARC113"
        },
    },
    -- box #77
    [77] = {
        -- pack #1 in box #77
        [1] = {
            "ARC206","ARC203","ARC180","ARC217","ARC055","ARC016","ARC166","ARC154","ARC060","ARC032","ARC060","ARC109","ARC149","ARC110","ARC140","ARC002","ARC040"
        },
        -- pack #2 in box #77
        [2] = {
            "ARC210","ARC207","ARC186","ARC211","ARC051","ARC170","ARC188","ARC005","ARC072","ARC033","ARC061","ARC111","ARC135","ARC111","ARC143","ARC076","ARC077"
        },
        -- pack #3 in box #77
        [3] = {
            "ARC197","ARC203","ARC177","ARC197","ARC128","ARC055","ARC199","ARC153","ARC024","ARC072","ARC035","ARC146","ARC106","ARC136","ARC111","ARC114","ARC077"
        },
        -- pack #4 in box #77
        [4] = {
            "ARC183","ARC194","ARC215","ARC210","ARC174","ARC007","ARC140","ARC153","ARC060","ARC035","ARC060","ARC107","ARC147","ARC105","ARC147","ARC002","ARC114"
        },
        -- pack #5 in box #77
        [5] = {
            "ARC212","ARC183","ARC192","ARC176","ARC085","ARC173","ARC048","ARC151","ARC070","ARC025","ARC062","ARC099","ARC138","ARC109","ARC139","ARC002","ARC003"
        },
        -- pack #6 in box #77
        [6] = {
            "ARC194","ARC198","ARC190","ARC216","ARC125","ARC006","ARC066","ARC153","ARC074","ARC028","ARC064","ARC029","ARC135","ARC110","ARC134","ARC113","ARC002"
        },
        -- pack #7 in box #77
        [7] = {
            "ARC216","ARC201","ARC213","ARC203","ARC011","ARC128","ARC098","ARC155","ARC073","ARC035","ARC060","ARC103","ARC148","ARC104","ARC146","ARC001","ARC112"
        },
        -- pack #8 in box #77
        [8] = {
            "ARC204","ARC187","ARC187","ARC209","ARC055","ARC083","ARC099","ARC154","ARC023","ARC071","ARC028","ARC143","ARC096","ARC147","ARC101","ARC040","ARC112"
        },
        -- pack #9 in box #77
        [9] = {
            "ARC183","ARC212","ARC205","ARC195","ARC092","ARC170","ARC184","ARC155","ARC072","ARC034","ARC074","ARC029","ARC132","ARC106","ARC142","ARC038","ARC112"
        },
        -- pack #10 in box #77
        [10] = {
            "ARC206","ARC213","ARC212","ARC185","ARC092","ARC090","ARC052","ARC156","ARC023","ARC062","ARC029","ARC063","ARC110","ARC147","ARC100","ARC112","ARC114"
        },
        -- pack #11 in box #77
        [11] = {
            "ARC192","ARC209","ARC215","ARC192","ARC086","ARC057","ARC161","ARC042","ARC029","ARC065","ARC021","ARC062","ARC097","ARC145","ARC103","ARC002","ARC113"
        },
        -- pack #12 in box #77
        [12] = {
            "ARC195","ARC183","ARC210","ARC202","ARC173","ARC055","ARC005","ARC153","ARC023","ARC064","ARC021","ARC144","ARC110","ARC149","ARC095","ARC003","ARC002"
        },
        -- pack #13 in box #77
        [13] = {
            "ARC211","ARC203","ARC200","ARC208","ARC169","ARC168","ARC102","ARC158","ARC035","ARC064","ARC021","ARC133","ARC102","ARC144","ARC105","ARC001","ARC112"
        },
        -- pack #14 in box #77
        [14] = {
            "ARC212","ARC184","ARC196","ARC177","ARC125","ARC173","ARC207","ARC156","ARC034","ARC067","ARC027","ARC061","ARC104","ARC144","ARC097","ARC038","ARC040"
        },
        -- pack #15 in box #77
        [15] = {
            "ARC192","ARC207","ARC194","ARC212","ARC093","ARC088","ARC156","ARC157","ARC060","ARC029","ARC064","ARC032","ARC139","ARC104","ARC136","ARC003","ARC112"
        },
        -- pack #16 in box #77
        [16] = {
            "ARC200","ARC214","ARC217","ARC195","ARC170","ARC087","ARC014","ARC079","ARC021","ARC072","ARC036","ARC067","ARC106","ARC134","ARC098","ARC113","ARC112"
        },
        -- pack #17 in box #77
        [17] = {
            "ARC206","ARC183","ARC213","ARC195","ARC089","ARC048","ARC036","ARC153","ARC036","ARC062","ARC029","ARC060","ARC096","ARC132","ARC100","ARC113","ARC114"
        },
        -- pack #18 in box #77
        [18] = {
            "ARC191","ARC178","ARC197","ARC177","ARC086","ARC118","ARC055","ARC155","ARC068","ARC028","ARC066","ARC027","ARC149","ARC109","ARC142","ARC075","ARC114"
        },
        -- pack #19 in box #77
        [19] = {
            "ARC185","ARC193","ARC212","ARC206","ARC058","ARC011","ARC126","ARC079","ARC035","ARC060","ARC024","ARC138","ARC104","ARC140","ARC106","ARC077","ARC003"
        },
        -- pack #20 in box #77
        [20] = {
            "ARC182","ARC179","ARC209","ARC177","ARC129","ARC125","ARC090","ARC153","ARC031","ARC064","ARC022","ARC064","ARC099","ARC138","ARC098","ARC114","ARC077"
        },
        -- pack #21 in box #77
        [21] = {
            "ARC201","ARC185","ARC202","ARC211","ARC165","ARC009","ARC089","ARC151","ARC070","ARC036","ARC061","ARC020","ARC136","ARC104","ARC135","ARC075","ARC115"
        },
        -- pack #22 in box #77
        [22] = {
            "ARC179","ARC214","ARC188","ARC211","ARC014","ARC016","ARC018","ARC079","ARC071","ARC023","ARC062","ARC104","ARC140","ARC103","ARC148","ARC076","ARC077"
        },
        -- pack #23 in box #77
        [23] = {
            "ARC211","ARC217","ARC217","ARC180","ARC050","ARC124","ARC091","ARC005","ARC061","ARC024","ARC072","ARC026","ARC139","ARC101","ARC142","ARC039","ARC112"
        },
        -- pack #24 in box #77
        [24] = {
            "ARC194","ARC209","ARC178","ARC213","ARC129","ARC160","ARC108","ARC157","ARC028","ARC071","ARC030","ARC136","ARC096","ARC138","ARC103","ARC039","ARC113"
        },
    },
    -- box #78
    [78] = {
        -- pack #1 in box #78
        [1] = {
            "ARC194","ARC209","ARC182","ARC195","ARC167","ARC011","ARC105","ARC042","ARC066","ARC033","ARC063","ARC032","ARC147","ARC103","ARC148","ARC076","ARC112"
        },
        -- pack #2 in box #78
        [2] = {
            "ARC196","ARC199","ARC206","ARC192","ARC172","ARC008","ARC033","ARC156","ARC022","ARC060","ARC026","ARC072","ARC095","ARC145","ARC111","ARC075","ARC002"
        },
        -- pack #3 in box #78
        [3] = {
            "ARC188","ARC178","ARC204","ARC180","ARC056","ARC082","ARC206","ARC158","ARC069","ARC031","ARC071","ARC031","ARC145","ARC096","ARC146","ARC115","ARC077"
        },
        -- pack #4 in box #78
        [4] = {
            "ARC194","ARC208","ARC214","ARC207","ARC092","ARC169","ARC068","ARC005","ARC069","ARC031","ARC064","ARC104","ARC141","ARC094","ARC138","ARC040","ARC115"
        },
        -- pack #5 in box #78
        [5] = {
            "ARC187","ARC215","ARC195","ARC200","ARC015","ARC055","ARC138","ARC042","ARC031","ARC061","ARC020","ARC133","ARC104","ARC144","ARC099","ARC113","ARC077"
        },
        -- pack #6 in box #78
        [6] = {
            "ARC178","ARC190","ARC186","ARC217","ARC169","ARC053","ARC158","ARC117","ARC066","ARC023","ARC071","ARC097","ARC148","ARC097","ARC132","ARC039","ARC002"
        },
        -- pack #7 in box #78
        [7] = {
            "ARC213","ARC181","ARC197","ARC191","ARC014","ARC119","ARC133","ARC154","ARC037","ARC072","ARC034","ARC133","ARC103","ARC148","ARC111","ARC077","ARC076"
        },
        -- pack #8 in box #78
        [8] = {
            "ARC191","ARC179","ARC209","ARC203","ARC091","ARC129","ARC085","ARC005","ARC025","ARC072","ARC027","ARC067","ARC109","ARC143","ARC096","ARC113","ARC075"
        },
        -- pack #9 in box #78
        [9] = {
            "ARC198","ARC205","ARC184","ARC205","ARC087","ARC090","ARC153","ARC042","ARC060","ARC030","ARC067","ARC100","ARC132","ARC111","ARC138","ARC077","ARC075"
        },
        -- pack #10 in box #78
        [10] = {
            "ARC215","ARC206","ARC196","ARC211","ARC013","ARC169","ARC013","ARC079","ARC020","ARC068","ARC020","ARC070","ARC096","ARC140","ARC100","ARC001","ARC002"
        },
        -- pack #11 in box #78
        [11] = {
            "ARC180","ARC206","ARC216","ARC212","ARC051","ARC056","ARC157","ARC156","ARC065","ARC024","ARC069","ARC033","ARC140","ARC109","ARC146","ARC038","ARC077"
        },
        -- pack #12 in box #78
        [12] = {
            "ARC202","ARC195","ARC205","ARC193","ARC050","ARC052","ARC031","ARC117","ARC020","ARC061","ARC029","ARC145","ARC094","ARC133","ARC102","ARC038","ARC002"
        },
        -- pack #13 in box #78
        [13] = {
            "ARC207","ARC210","ARC200","ARC213","ARC172","ARC172","ARC067","ARC153","ARC061","ARC036","ARC064","ARC102","ARC144","ARC111","ARC141","ARC038","ARC001"
        },
        -- pack #14 in box #78
        [14] = {
            "ARC183","ARC186","ARC194","ARC205","ARC123","ARC174","ARC174","ARC079","ARC035","ARC072","ARC035","ARC147","ARC097","ARC143","ARC102","ARC039","ARC002"
        },
        -- pack #15 in box #78
        [15] = {
            "ARC190","ARC211","ARC193","ARC199","ARC166","ARC091","ARC215","ARC155","ARC069","ARC021","ARC067","ARC095","ARC135","ARC105","ARC134","ARC115","ARC040"
        },
        -- pack #16 in box #78
        [16] = {
            "ARC186","ARC211","ARC207","ARC206","ARC164","ARC054","ARC110","ARC158","ARC025","ARC063","ARC028","ARC144","ARC106","ARC142","ARC097","ARC040","ARC112"
        },
        -- pack #17 in box #78
        [17] = {
            "ARC216","ARC177","ARC176","ARC206","ARC173","ARC019","ARC212","ARC156","ARC073","ARC035","ARC072","ARC021","ARC136","ARC100","ARC141","ARC039","ARC076"
        },
        -- pack #18 in box #78
        [18] = {
            "ARC197","ARC191","ARC198","ARC211","ARC131","ARC171","ARC094","ARC158","ARC021","ARC068","ARC031","ARC064","ARC107","ARC141","ARC105","ARC114","ARC003"
        },
        -- pack #19 in box #78
        [19] = {
            "ARC204","ARC194","ARC192","ARC176","ARC128","ARC174","ARC094","ARC154","ARC022","ARC060","ARC024","ARC072","ARC105","ARC141","ARC106","ARC002","ARC001"
        },
        -- pack #20 in box #78
        [20] = {
            "ARC186","ARC195","ARC189","ARC200","ARC168","ARC092","ARC192","ARC156","ARC023","ARC068","ARC034","ARC146","ARC110","ARC147","ARC105","ARC077","ARC115"
        },
        -- pack #21 in box #78
        [21] = {
            "ARC199","ARC202","ARC202","ARC186","ARC088","ARC174","ARC026","ARC156","ARC065","ARC021","ARC064","ARC020","ARC144","ARC101","ARC139","ARC114","ARC039"
        },
        -- pack #22 in box #78
        [22] = {
            "ARC216","ARC191","ARC200","ARC203","ARC124","ARC011","ARC103","ARC153","ARC060","ARC032","ARC067","ARC105","ARC137","ARC094","ARC133","ARC112","ARC113"
        },
        -- pack #23 in box #78
        [23] = {
            "ARC195","ARC199","ARC189","ARC207","ARC126","ARC128","ARC098","ARC117","ARC074","ARC030","ARC072","ARC030","ARC145","ARC098","ARC137","ARC040","ARC001"
        },
        -- pack #24 in box #78
        [24] = {
            "ARC201","ARC195","ARC182","ARC179","ARC049","ARC090","ARC011","ARC156","ARC037","ARC063","ARC025","ARC071","ARC109","ARC149","ARC099","ARC112","ARC038"
        },
    },
    -- box #79
    [79] = {
        -- pack #1 in box #79
        [1] = {
            "ARC208","ARC178","ARC191","ARC178","ARC049","ARC129","ARC016","ARC158","ARC066","ARC029","ARC069","ARC101","ARC144","ARC111","ARC143","ARC002","ARC076"
        },
        -- pack #2 in box #79
        [2] = {
            "ARC179","ARC205","ARC211","ARC201","ARC125","ARC008","ARC070","ARC042","ARC067","ARC033","ARC072","ARC107","ARC139","ARC101","ARC141","ARC002","ARC112"
        },
        -- pack #3 in box #79
        [3] = {
            "ARC194","ARC196","ARC204","ARC201","ARC012","ARC018","ARC061","ARC155","ARC069","ARC032","ARC072","ARC022","ARC134","ARC097","ARC141","ARC114","ARC112"
        },
        -- pack #4 in box #79
        [4] = {
            "ARC207","ARC208","ARC212","ARC207","ARC165","ARC092","ARC057","ARC155","ARC033","ARC060","ARC024","ARC066","ARC102","ARC145","ARC098","ARC040","ARC075"
        },
        -- pack #5 in box #79
        [5] = {
            "ARC203","ARC210","ARC188","ARC204","ARC130","ARC127","ARC098","ARC157","ARC037","ARC069","ARC034","ARC062","ARC097","ARC132","ARC104","ARC218"
        },
        -- pack #6 in box #79
        [6] = {
            "ARC188","ARC192","ARC215","ARC186","ARC056","ARC046","ARC183","ARC005","ARC031","ARC069","ARC037","ARC134","ARC094","ARC143","ARC104","ARC218"
        },
        -- pack #7 in box #79
        [7] = {
            "ARC192","ARC190","ARC180","ARC207","ARC015","ARC084","ARC181","ARC005","ARC069","ARC023","ARC069","ARC033","ARC133","ARC111","ARC134","ARC001","ARC077"
        },
        -- pack #8 in box #79
        [8] = {
            "ARC182","ARC202","ARC183","ARC185","ARC014","ARC049","ARC186","ARC158","ARC034","ARC070","ARC036","ARC145","ARC111","ARC132","ARC098","ARC003","ARC001"
        },
        -- pack #9 in box #79
        [9] = {
            "ARC216","ARC187","ARC187","ARC212","ARC123","ARC052","ARC204","ARC005","ARC020","ARC073","ARC032","ARC066","ARC103","ARC135","ARC107","ARC077","ARC113"
        },
        -- pack #10 in box #79
        [10] = {
            "ARC181","ARC187","ARC183","ARC193","ARC052","ARC131","ARC186","ARC154","ARC026","ARC071","ARC036","ARC145","ARC110","ARC147","ARC104","ARC001","ARC077"
        },
        -- pack #11 in box #79
        [11] = {
            "ARC184","ARC198","ARC214","ARC203","ARC085","ARC009","ARC211","ARC157","ARC072","ARC027","ARC061","ARC037","ARC133","ARC102","ARC140","ARC075","ARC039"
        },
        -- pack #12 in box #79
        [12] = {
            "ARC197","ARC185","ARC176","ARC217","ARC168","ARC120","ARC179","ARC153","ARC021","ARC066","ARC031","ARC061","ARC103","ARC147","ARC108","ARC218"
        },
        -- pack #13 in box #79
        [13] = {
            "ARC190","ARC197","ARC199","ARC189","ARC049","ARC125","ARC180","ARC005","ARC025","ARC071","ARC036","ARC148","ARC111","ARC146","ARC103","ARC003","ARC002"
        },
        -- pack #14 in box #79
        [14] = {
            "ARC205","ARC210","ARC197","ARC201","ARC128","ARC055","ARC187","ARC157","ARC071","ARC037","ARC069","ARC033","ARC138","ARC104","ARC143","ARC040","ARC077"
        },
        -- pack #15 in box #79
        [15] = {
            "ARC210","ARC208","ARC216","ARC208","ARC011","ARC017","ARC208","ARC042","ARC064","ARC032","ARC067","ARC023","ARC141","ARC108","ARC134","ARC003","ARC075"
        },
        -- pack #16 in box #79
        [16] = {
            "ARC185","ARC188","ARC213","ARC189","ARC053","ARC168","ARC034","ARC117","ARC073","ARC020","ARC060","ARC107","ARC147","ARC098","ARC134","ARC218"
        },
        -- pack #17 in box #79
        [17] = {
            "ARC177","ARC193","ARC206","ARC216","ARC127","ARC161","ARC141","ARC151","ARC025","ARC071","ARC034","ARC144","ARC097","ARC140","ARC104","ARC002","ARC077"
        },
        -- pack #18 in box #79
        [18] = {
            "ARC177","ARC190","ARC204","ARC208","ARC013","ARC045","ARC146","ARC151","ARC067","ARC035","ARC060","ARC109","ARC139","ARC110","ARC143","ARC075","ARC114"
        },
        -- pack #19 in box #79
        [19] = {
            "ARC179","ARC200","ARC202","ARC203","ARC017","ARC092","ARC066","ARC042","ARC073","ARC035","ARC072","ARC094","ARC137","ARC104","ARC137","ARC218"
        },
        -- pack #20 in box #79
        [20] = {
            "ARC216","ARC197","ARC184","ARC177","ARC127","ARC173","ARC162","ARC117","ARC072","ARC023","ARC061","ARC021","ARC145","ARC099","ARC139","ARC075","ARC115"
        },
        -- pack #21 in box #79
        [21] = {
            "ARC197","ARC203","ARC213","ARC203","ARC053","ARC048","ARC029","ARC155","ARC069","ARC027","ARC061","ARC094","ARC149","ARC103","ARC144","ARC039","ARC002"
        },
        -- pack #22 in box #79
        [22] = {
            "ARC193","ARC178","ARC196","ARC209","ARC174","ARC128","ARC212","ARC005","ARC028","ARC060","ARC033","ARC149","ARC107","ARC134","ARC109","ARC075","ARC076"
        },
        -- pack #23 in box #79
        [23] = {
            "ARC214","ARC212","ARC190","ARC202","ARC090","ARC046","ARC205","ARC156","ARC032","ARC067","ARC027","ARC061","ARC094","ARC142","ARC100","ARC115","ARC077"
        },
        -- pack #24 in box #79
        [24] = {
            "ARC189","ARC188","ARC195","ARC182","ARC017","ARC056","ARC163","ARC005","ARC033","ARC073","ARC022","ARC069","ARC096","ARC137","ARC099","ARC002","ARC001"
        },
    },
    -- box #80
    [80] = {
        -- pack #1 in box #80
        [1] = {
            "ARC193","ARC213","ARC181","ARC179","ARC124","ARC056","ARC025","ARC117","ARC020","ARC067","ARC025","ARC064","ARC107","ARC143","ARC094","ARC113","ARC075"
        },
        -- pack #2 in box #80
        [2] = {
            "ARC196","ARC213","ARC205","ARC210","ARC049","ARC089","ARC205","ARC153","ARC068","ARC036","ARC063","ARC094","ARC133","ARC097","ARC148","ARC001","ARC114"
        },
        -- pack #3 in box #80
        [3] = {
            "ARC199","ARC201","ARC195","ARC181","ARC053","ARC051","ARC187","ARC151","ARC037","ARC074","ARC035","ARC135","ARC101","ARC147","ARC100","ARC003","ARC115"
        },
        -- pack #4 in box #80
        [4] = {
            "ARC184","ARC179","ARC186","ARC212","ARC124","ARC013","ARC138","ARC155","ARC061","ARC021","ARC074","ARC036","ARC137","ARC107","ARC149","ARC039","ARC003"
        },
        -- pack #5 in box #80
        [5] = {
            "ARC189","ARC200","ARC191","ARC202","ARC016","ARC049","ARC179","ARC157","ARC064","ARC030","ARC062","ARC032","ARC146","ARC108","ARC136","ARC002","ARC038"
        },
        -- pack #6 in box #80
        [6] = {
            "ARC199","ARC178","ARC215","ARC207","ARC019","ARC059","ARC031","ARC042","ARC032","ARC062","ARC029","ARC147","ARC098","ARC134","ARC094","ARC114","ARC112"
        },
        -- pack #7 in box #80
        [7] = {
            "ARC206","ARC204","ARC182","ARC190","ARC130","ARC058","ARC148","ARC154","ARC062","ARC037","ARC065","ARC022","ARC136","ARC098","ARC143","ARC002","ARC039"
        },
        -- pack #8 in box #80
        [8] = {
            "ARC190","ARC177","ARC184","ARC180","ARC053","ARC088","ARC025","ARC151","ARC073","ARC034","ARC062","ARC100","ARC146","ARC099","ARC142","ARC112","ARC039"
        },
        -- pack #9 in box #80
        [9] = {
            "ARC189","ARC195","ARC214","ARC200","ARC130","ARC006","ARC060","ARC117","ARC025","ARC070","ARC020","ARC134","ARC111","ARC138","ARC097","ARC113","ARC076"
        },
        -- pack #10 in box #80
        [10] = {
            "ARC207","ARC192","ARC183","ARC205","ARC051","ARC015","ARC087","ARC005","ARC073","ARC028","ARC068","ARC024","ARC135","ARC105","ARC134","ARC002","ARC039"
        },
        -- pack #11 in box #80
        [11] = {
            "ARC196","ARC177","ARC203","ARC191","ARC131","ARC118","ARC146","ARC157","ARC073","ARC026","ARC074","ARC110","ARC141","ARC096","ARC139","ARC115","ARC075"
        },
        -- pack #12 in box #80
        [12] = {
            "ARC196","ARC186","ARC216","ARC184","ARC165","ARC089","ARC130","ARC117","ARC060","ARC035","ARC066","ARC106","ARC134","ARC108","ARC146","ARC003","ARC075"
        },
        -- pack #13 in box #80
        [13] = {
            "ARC211","ARC198","ARC205","ARC210","ARC131","ARC168","ARC149","ARC042","ARC068","ARC030","ARC065","ARC108","ARC134","ARC095","ARC146","ARC115","ARC001"
        },
        -- pack #14 in box #80
        [14] = {
            "ARC198","ARC196","ARC203","ARC216","ARC089","ARC170","ARC176","ARC005","ARC029","ARC070","ARC037","ARC143","ARC096","ARC140","ARC104","ARC075","ARC076"
        },
        -- pack #15 in box #80
        [15] = {
            "ARC212","ARC205","ARC184","ARC201","ARC058","ARC163","ARC045","ARC042","ARC069","ARC026","ARC066","ARC023","ARC143","ARC101","ARC142","ARC115","ARC001"
        },
        -- pack #16 in box #80
        [16] = {
            "ARC192","ARC178","ARC208","ARC212","ARC049","ARC090","ARC151","ARC152","ARC062","ARC022","ARC065","ARC033","ARC149","ARC104","ARC146","ARC076","ARC075"
        },
        -- pack #17 in box #80
        [17] = {
            "ARC185","ARC198","ARC188","ARC200","ARC123","ARC006","ARC208","ARC117","ARC033","ARC065","ARC033","ARC066","ARC098","ARC148","ARC099","ARC218"
        },
        -- pack #18 in box #80
        [18] = {
            "ARC209","ARC204","ARC178","ARC181","ARC090","ARC159","ARC213","ARC152","ARC037","ARC064","ARC022","ARC066","ARC101","ARC133","ARC106","ARC075","ARC040"
        },
        -- pack #19 in box #80
        [19] = {
            "ARC199","ARC210","ARC182","ARC211","ARC055","ARC049","ARC203","ARC156","ARC023","ARC065","ARC034","ARC061","ARC101","ARC146","ARC103","ARC076","ARC001"
        },
        -- pack #20 in box #80
        [20] = {
            "ARC213","ARC196","ARC206","ARC181","ARC053","ARC129","ARC034","ARC152","ARC023","ARC073","ARC034","ARC071","ARC108","ARC147","ARC103","ARC076","ARC039"
        },
        -- pack #21 in box #80
        [21] = {
            "ARC198","ARC186","ARC184","ARC214","ARC058","ARC084","ARC065","ARC079","ARC029","ARC072","ARC026","ARC138","ARC094","ARC141","ARC099","ARC040","ARC039"
        },
        -- pack #22 in box #80
        [22] = {
            "ARC201","ARC196","ARC202","ARC206","ARC089","ARC123","ARC063","ARC151","ARC026","ARC069","ARC028","ARC069","ARC097","ARC134","ARC095","ARC115","ARC077"
        },
        -- pack #23 in box #80
        [23] = {
            "ARC210","ARC207","ARC201","ARC185","ARC012","ARC081","ARC215","ARC153","ARC065","ARC025","ARC062","ARC111","ARC133","ARC107","ARC137","ARC112","ARC075"
        },
        -- pack #24 in box #80
        [24] = {
            "ARC214","ARC192","ARC188","ARC185","ARC093","ARC168","ARC196","ARC156","ARC034","ARC070","ARC025","ARC136","ARC108","ARC146","ARC103","ARC040","ARC113"
        },
    },
}