LoadScript("code-sprites-directory")
LoadScript("code-vector2-math")
LoadScript("code-math-helpers")

local activePrisoners = {}
local prisonerAnimStates = {
    idle = {
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle1,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
        prisonerIdle2,
    },
    walkLeft = {
        prisonerWalkLeft1,
        prisonerWalkLeft2,
    },
    walkRight = {
        prisonerWalkRight1,
        prisonerWalkRight2,
    },
    walkStr = {
        prisonerWalkStr1,
        prisonerWalkStr2,
    },
}

function SpawnPrisoner(x, y)
    
    local prisonerData = {
        uid = tostring(os.time()),
        pos = NewPoint(x, y),
        rect = NewRect(0, 0, 8, 8),
        currentAnimState = prisonerAnimStates.idle,
        currentAnimFrame = 1,
        timePassedSinceLastFrame = 0,
        remove = false,
        currentDirection = WorldAxis2DNone(),
        currentSpeed = 0,
        maxSpeed = 0.2,
        input = { x = 0, y = 0, },
        lastRandomInputSet = 0,
        randomInputTime = 2,
    }
    table.insert(activePrisoners, prisonerData)

    return prisonerData

end

function GetInputVector()

    local inputVector = { x = 0, y = 0, }

    -- Get input from buttons
    if (Button(Buttons.Left, InputState.Down) == true) then
        inputVector = Vector2Sum(inputVector, WorldAxis2DLeft())
    end
    if (Button(Buttons.Right, InputState.Down) == true) then
        inputVector = Vector2Sum(inputVector, WorldAxis2DRight())
    end

    if (Button(Buttons.Up, InputState.Down) == true) then
        inputVector = Vector2Sum(inputVector, WorldAxis2DUp())
    end
    if (Button(Buttons.Down, InputState.Down) == true) then
        inputVector = Vector2Sum(inputVector, WorldAxis2DDown())
    end

    return inputVector

end

function MovePrisoner(prisoner, timeDelta)

    --currentPrisoner.input = GetInputVector()
    prisoner.lastRandomInputSet = prisoner.lastRandomInputSet + timeDelta / 1000
    if (prisoner.lastRandomInputSet >= prisoner.randomInputTime) then
        prisoner.lastRandomInputSet = 0
        prisoner.input = GetRandomInput()
    end
    DrawText(Vector2ToString(prisoner.input), 0, 0, DrawMode.Sprite, "large", 4)

end
function GetRandomInput()

    local randomInput = WorldAxis2DNone()
    local stopChance = math.random()
    if (stopChance >= 0.5) then
        randomInput.x = SetDecimalPlaces((math.random() * 2) - 1, 1)
        randomInput.y = SetDecimalPlaces((math.random() * 2) - 1, 1)
    end
    return randomInput

end

function UpdatePrisoners(timeDelta)

    for i = 1, #activePrisoners do
        local currentPrisoner = activePrisoners[i]
        if (currentPrisoner ~= nil and currentPrisoner.remove ~= true) then

            MovePrisoner(currentPrisoner, timeDelta)

            -- Set direction and speed based on input
            local fixedInput = Vector2SquareInputToCircle(currentPrisoner.input)
            currentPrisoner.currentDirection = Vector2Normalize(fixedInput)
            currentPrisoner.currentSpeed = currentPrisoner.maxSpeed * Vector2Magnitude(fixedInput)

            -- Move self based on direction and speed
            local velocity = Vector2Multiply(currentPrisoner.currentDirection, currentPrisoner.currentSpeed)
            velocity.y = velocity.y * -1
            currentPrisoner.pos = Vector2Sum(currentPrisoner.pos, velocity)
            
            -- Set animation state based on direction and speed
            if (currentPrisoner.currentSpeed > 0) then
                if (currentPrisoner.currentDirection.x > 0) then
                    currentPrisoner.currentAnimState = prisonerAnimStates.walkRight
                elseif (currentPrisoner.currentDirection.x < 0) then
                    currentPrisoner.currentAnimState = prisonerAnimStates.walkLeft
                else
                    currentPrisoner.currentAnimState = prisonerAnimStates.walkStr
                end
            else
                currentPrisoner.currentAnimState = prisonerAnimStates.idle
            end

            -- Update animation frame
            SetAnimationFrameIndex(currentPrisoner, timeDelta)
        end
    end
    
end

function SetAnimationFrameIndex(prisoner, timeDelta)

    local secondsPerFrame = 1 / framesPerSecond
    prisoner.timePassedSinceLastFrame = prisoner.timePassedSinceLastFrame + (timeDelta / 1000)
    local framesToPass = math.floor(prisoner.timePassedSinceLastFrame / secondsPerFrame)

    if (framesToPass > 0) then
        local totalFrames = #prisoner.currentAnimState
        --DrawText("t " .. totalFrames .. framesToPass, 0, 0, DrawMode.Sprite, "large", 4)
        prisoner.currentAnimFrame = ((prisoner.currentAnimFrame + framesToPass - 1) % totalFrames) + 1
        prisoner.timePassedSinceLastFrame = 0
    end
end

function DrawPrisoners()
    local stillActivePrisoners = {}
    for i = 1, #activePrisoners do
        local currentPrisoner = activePrisoners[i]
        if (currentPrisoner ~= nil and currentPrisoner.remove ~= true) then
            table.insert(stillActivePrisoners, currentPrisoner)

            local frames = currentPrisoner.currentAnimState
            local spriteData = frames[currentPrisoner.currentAnimFrame]
            if (spriteData ~= nil) then
                DrawSprites(spriteData.spriteIDs, currentPrisoner.pos.x, currentPrisoner.pos.y, spriteData.width)
            end
        end
    end
    activePrisoners = stillActivePrisoners
end