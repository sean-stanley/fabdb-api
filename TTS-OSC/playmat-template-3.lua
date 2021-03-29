
local mat_index = -1

local left_col_x_off = 1.47
local left_col2_x_off = 1.05
local right_col_x_off = -left_col_x_off
local right_col2_x_off = -left_col2_x_off

local left_mid_col_x_off = 0.425
local right_mid_col_x_off = -left_mid_col_x_off

local top_row_z_off = -0.44
local middle_row_z_off = 0.125
local bottom_row_z_off = 0.685

function onLoad()
  local mat_url = self.getCustomObject().image
  mat_index = Global.call("oscGetIndexForURL", { url = mat_url })
  -- Delay setting so the UI is created.
  Wait.frames(function() self.UI.setAttribute("mat_index", "text", tostring(mat_index)) end, 1)

  self.setSnapPoints({
    -- hero card
    { position = {0,0,middle_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- weapon left card
    { position = {left_mid_col_x_off,0,middle_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- weapon right card
    { position = {right_mid_col_x_off,0,middle_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- hero card
    { position = {0,0,bottom_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },

    -- helm card
    { position = {left_col_x_off,0,top_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- chest card
    { position = {left_col_x_off,0,middle_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- arms card
    { position = {left_col2_x_off,0,middle_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- boots card
    { position = {left_col_x_off,0,bottom_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },

    -- graveyard
    { position = {right_col_x_off,0,top_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- deck
    { position = {right_col_x_off,0,middle_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
    -- banished
    { position = {right_col_x_off,0,bottom_row_z_off},
      rotation = {0,0,0},
      rotation_snap = true },
  })
end

function onFixedUpdate()
  if self.interactable then
    self.UI.show("panel")
  else
    self.UI.hide("panel")
  end
end

function updateMatIndex(inc)
  local max_index = Global.call("oscGetNumberOfPlaymatImages", {})
  mat_index = math.max(1, math.min(mat_index + inc, max_index))

  self.UI.setAttribute("mat_index", "text", tostring(mat_index))
  local mat_url = Global.call("oscGetImageURL", { index = mat_index })
  updateCurrentMatUrl(mat_url)
end

function onSelectPreviousMat()
  updateMatIndex(-1)
end

function onSelectNextMat()
  updateMatIndex(1)
end

function onIndexChanged(player, value)
  local new_index = tonumber(value)
  if new_index != nil then
    local max_index = Global.call("oscGetNumberOfPlaymatImages", {})
    mat_index = math.max(1, math.min(new_index, max_index))

    local mat_url = Global.call("oscGetImageURL", { index = mat_index })
    updateCurrentMatUrl(mat_url)
  end
end

function updateCurrentMatUrl(url)
  if url != nil then
    self.setCustomObject({
      image = url
    })
    local new_mat = self.reload()
    Global.call("oscRegisterNewMat", { mat = new_mat })
  end
end

function onPitchPressed(player)
  local deck_ray = self.positionToWorld({x=right_col_x_off, y=5, z=middle_row_z_off})
  local pitch_ray = self.positionToWorld({x=right_col2_x_off, y=5, z=middle_row_z_off})
  local ray_dir = {x=0, y=-1, z=0}
  local card_size = {x=3.5, y=2, z=5}

  -- This can be a card or a deck, it doesn't matter for our purposes.
  local deck = nil
  local deck_pick = Physics.cast({
    origin = deck_ray,
    direction = ray_dir,
  })
  for _, hit in pairs(deck_pick) do
    if hit.hit_object.tag == "Card" or hit.hit_object.tag == "Deck" then
      deck = hit.hit_object
      break
    end
  end

  -- This can be a set of cards or a deck, it doesn't matter.
  local pitch_cards = {}
  local pitch_pick = Physics.cast({
    origin = pitch_ray,
    direction = ray_dir,
    type = 3,   -- box selection
    size = card_size
  })

  --[[

  Story Time:

  TTS has a lot of trouble with ordering loose cards. There is the ability to perform physics casting,
  however, the order may not actually be the order you intended. Also, functionality like `group()` are
  all based on the same building blocks: they are unreliable.

  As such, this API ensures that only a single deck is found in the pitch area. This can be sorted using
  the "Search" functionality. Then, pressing "End Turn" will put the pitch deck properly at the bottom of
  your deck.

  ]]

  for _, hit in pairs(pitch_pick) do
    if hit.hit_object.tag == "Card" or hit.hit_object.tag == "Deck" then
      table.insert(pitch_cards, hit.hit_object)
    end
  end

  -- Nothing to do if there are no pitch cards!
  if #pitch_cards == 0 then
    return
  end

  if #pitch_cards > 1 then
    broadcastToColor("Please order your pitch area into a deck first to ensure the order is what you intend.", player.color)
    return
  end

  -- If the player doesn't have a deck, then the pitch deck is the new deck. Hopefully they kill their opponent
  -- quickly!
  if deck == nil then
    local pitch_deck = pitch_cards[1]

    local deck_pos = self.positionToWorld({x=right_col_x_off, y=1.5, z=middle_row_z_off})
    local deck_rot = pitch_deck.getRotation()
    deck_rot.z = 180

    pitch_deck.setPositionSmooth(deck_pos, false, false)
    pitch_deck.setRotationSmooth(deck_rot, false, false)
  else
    -- TTS will combine a single card into a deck... so, if your deck has only one card, but your pitch is a deck,
    -- TTS combines this incorrectly. Thus, we need to use the physics engine to actually stack our cards...
    local deck_pos = self.positionToWorld({x=right_col_x_off, y=2, z=middle_row_z_off})
    deck.setPositionSmooth(deck_pos, false, false)
    deck.lock()

    Wait.time(function()
      local pitch_deck = pitch_cards[1]
      local deck_pos = self.positionToWorld({x=right_col_x_off, y=1.15, z=middle_row_z_off})
      local deck_rot = deck.getRotation()
      pitch_deck.setPositionSmooth(deck_pos, false, false)
      pitch_deck.setRotationSmooth(deck_rot, false, false)

      Wait.time(function()
        deck.unlock()
      end, 1.25)
    end, 0.5)
  end

end