LoadScript("code-prisoners")
LoadScript("code-vector2-math")

local player = {}
local gameModes = {
  title = 0,
  survive = 1,
  saveEveryone = 2,
}
local currentGameMode = gameModes.title

local controls = {
  titleScreen = { "A: Save Everyone B: Survival" },
  surviveScreen = { "A: Shiv left B: Shiv Right", "Start: Quit" },
  saveEveryoneScreen = { "Click at a point to disperse", "prisoners Start: Quit" },
}

--[[
  The Init() method is part of the game's lifecycle and called a game starts.
  We are going to use this method to configure background color,
  ScreenBufferChip and draw a text box.
]]--
function Init()
end

--[[
  The Update() method is part of the game's life cycle. The engine calls
  Update() on every frame before the Draw() method. It accepts one argument,
  timeDelta, which is the difference in milliseconds since the last frame.
]]--
function Update(timeDelta)

  ChangeGameModes()
  UpdatePrisoners(timeDelta)

end

--[[
  The Draw() method is part of the game's life cycle. It is called after
  Update() and is where all of our draw calls should go. We'll be using this
  to render sprites to the display.
]]--
function Draw()

  -- We can use the RedrawDisplay() method to clear the screen and redraw
  -- the tilemap in a single call.
  RedrawDisplay()

  DrawPrisoners()

  DrawControls()

end

function ChangeGameModes()

  if (currentGameMode == gameModes.title) then

    if (Button(Buttons.A, InputState.Down)) then
      SetGameMode(gameModes.saveEveryone)
    elseif (Button(Buttons.B, InputState.Down)) then
      SetGameMode(gameModes.survive)
    end

  else

    if (Button(Buttons.Start, InputState.Down)) then
      SetGameMode(gameModes.title)
    else
      if (currentGameMode == gameModes.saveEveryone) then

        if (CountDeadPrisoners() >= 3) then
          SetGameMode(gameModes.title)
        end
    
      elseif (currentGameMode == gameModes.survive) then
    
        if (player ~= nil and (player.dead or (CountLivePrisoners() == 1 and player.dead ~= true))) then
          SetGameMode(gameModes.title)
        end

      end 
    end
  end

end

function SetGameMode(gameMode)

  if (gameMode == gameModes.title) then

    currentGameMode = gameModes.title
    RemoveAllPrisoners()

  elseif (gameMode == gameModes.survive) then

    currentGameMode = gameModes.survive
    distancingTool = false
    SpawnPrisonersRandomly(10, Vector2Difference(Display(true), NewPoint(32, 32)), NewPoint(16, 16))
    player = SpawnPrisoner(32, 32, true)    

  elseif (gameMode == gameModes.saveEveryone) then

    currentGameMode = gameModes.saveEveryone
    distancingTool = true
    SpawnPrisonersRandomly(10, Vector2Difference(Display(true), NewPoint(32, 32)), NewPoint(16, 16))  

  end
  
end

function SpawnPrisonersRandomly(count, size, offset)

  for i = 1, count do
    local randomX = math.random(size.x) + offset.x
    local randomY = math.random(size.y) + offset.y
    SpawnPrisoner(randomX, randomY, false)
  end

end

function DrawControls()

  local controlsText = controls.titleScreen
  if (currentGameMode == gameModes.survive) then
    controlsText = controls.surviveScreen
  elseif (currentGameMode == gameModes.saveEveryone) then
    controlsText = controls.saveEveryoneScreen
  end

  for i=1, #controlsText do
    DrawText(controlsText[i], 0, (i - 1) * 8, DrawMode.Sprite, "large", 15)
  end

end