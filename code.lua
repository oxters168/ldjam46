LoadScript("code-prisoners")
LoadScript("code-vector2-math")

local prisoner = nil

--[[
  The Init() method is part of the game's lifecycle and called a game starts.
  We are going to use this method to configure background color,
  ScreenBufferChip and draw a text box.
]]--
function Init()

  SpawnPrisonersRandomly(10, Vector2Difference(Display(true), NewPoint(32, 32)), NewPoint(16, 16))
  SpawnPrisoner(32, 32, true)

end

--[[
  The Update() method is part of the game's life cycle. The engine calls
  Update() on every frame before the Draw() method. It accepts one argument,
  timeDelta, which is the difference in milliseconds since the last frame.
]]--
function Update(timeDelta)

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

end

function SpawnPrisonersRandomly(count, size, offset)

  for i = 1, count do
    local randomX = math.random(size.x) + offset.x
    local randomY = math.random(size.y) + offset.y
    SpawnPrisoner(randomX, randomY, false)
  end

end