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
    shivLeft = {
        prisonerShivLeft1,
        prisonerShivLeft2,
    },
    shivRight = {
        prisonerShivRight1,
        prisonerShivRight2,
    },
    death = {
        prisonerDeath1,
        prisonerDeath2,
        prisonerDeath3,
        prisonerDeath4,
    }
}

function SpawnPrisoner(x, y, takesInput)
    
    local prisonerData = {
        uid = tostring(os.time()),
        pos = NewPoint(x, y),
        size = { x = 8, y = 8, },
        --rect = NewRect(0, 0, 8, 8),
        currentAnimState = prisonerAnimStates.idle,
        currentAnimFrame = 1,
        timePassedSinceLastFrame = 0,
        remove = false,
        currentDirection = WorldAxis2DNone(),
        isShivvingLeft = false,
        isShivvingRight = false,
        currentSpeed = 0,
        maxSpeed = 0.33,
        inputDirection = WorldAxis2DNone(),
        inputA = false,
        inputB = false,
        lastRandomInputSet = 0,
        randomInputTime = 2,
        controlledByPlayer = takesInput or false,
        dead = false,
        doneDead = false,
        totalTimeDead = 0,
        attacking = false,
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

function GetPrisonerInput(prisoner, timeDelta)

    -- Reset button values
    prisoner.inputA = false
    prisoner.inputB = false

    if (prisoner.controlledByPlayer == true) then
        prisoner.inputDirection = GetInputVector()
        prisoner.inputA = Button(Buttons.A, InputState.Down)
        prisoner.inputB = Button(Buttons.B, InputState.Down)
    else

        -- If random action interval has passed then do a possibly different random action
        prisoner.lastRandomInputSet = prisoner.lastRandomInputSet + timeDelta / 1000
        if (prisoner.lastRandomInputSet >= prisoner.randomInputTime) then

            prisoner.lastRandomInputSet = 0

            local attackChance = math.random()
            if (attackChance <= 0.4) then
                -- Set to attacking
                prisoner.attacking = true
            else
                -- Set to not attacking
                prisoner.attacking = false
                prisoner.inputDirection = GetRandomInput()
            end

        end

        -- Do attacking logic
        if (prisoner.attacking) then
            local closestPrisoner = GetClosestPrisoner(prisoner)
            if (closestPrisoner ~= nil) then
                local prisonerDirection = Vector2Difference(closestPrisoner.pos, prisoner.pos)
                local prisonerDistance = Vector2Magnitude(prisonerDirection)
                prisonerDirection = Vector2Normalize(prisonerDirection)

                if (prisonerDistance < prisoner.size.x) then
                    prisoner.inputDirection = WorldAxis2DNone()
                    if (prisonerDirection.x < 0) then
                        prisoner.inputA = true
                    else
                        prisoner.inputB = true
                    end
                else
                    prisoner.inputDirection = { x = prisonerDirection.x, y = -prisonerDirection.y, }
                end
            end
        end
    end
    --DrawText(Vector2ToString(prisoner.inputDirection), 0, 0, DrawMode.Sprite, "large", 4)

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
function GetClosestPrisoner(relativeTo)

    local closestPrisoner
    local smallestDistance = 100000
    for i = 1, #activePrisoners do
        local currentPrisoner = activePrisoners[i]
        if (currentPrisoner ~= relativeTo and currentPrisoner.dead ~= true) then
            local currentDistance = Vector2Distance(relativeTo.pos, currentPrisoner.pos)
            if (currentDistance < smallestDistance) then
                smallestDistance = currentDistance
                closestPrisoner = currentPrisoner
            end
        end
    end
    return closestPrisoner

end

function CheckDeathTime(prisoner, timeDelta)

    if (prisoner.dead) then
        prisoner.totalTimeDead = prisoner.totalTimeDead + (timeDelta / 1000)
        local secondsPerFrame = 1 / framesPerSecond
        local deathAnimationTime = #prisonerAnimStates.death * secondsPerFrame
        if (prisoner.totalTimeDead >= deathAnimationTime) then
            prisoner.doneDead = true
            prisoner.currentAnimFrame = #prisonerAnimStates.death
        end
    end

end

function UpdatePrisoners(timeDelta)

    --DrawText(Vector2Distance({ x = 0, y = 0, }, { x = 1, y = 2, }), 0, 0, DrawMode.Sprite, "large", 4)
    for i = 1, #activePrisoners do
        local currentPrisoner = activePrisoners[i]

        if (currentPrisoner ~= nil and currentPrisoner.remove ~= true) then

            CheckDeathTime(currentPrisoner, timeDelta)

            if (currentPrisoner.dead ~= true) then

                GetPrisonerInput(currentPrisoner, timeDelta)

                -- Set direction and speed based on input
                local fixedInput = Vector2SquareInputToCircle(currentPrisoner.inputDirection)
                --local fixedInput = currentPrisoner.inputDirection
                currentPrisoner.currentDirection = Vector2Normalize(fixedInput)
                currentPrisoner.currentSpeed = currentPrisoner.maxSpeed * Vector2Magnitude(fixedInput)

                -- Move self based on direction and speed
                local velocity = Vector2Multiply(currentPrisoner.currentDirection, currentPrisoner.currentSpeed)
                velocity.y = velocity.y * -1
                currentPrisoner.pos = Vector2Sum(currentPrisoner.pos, velocity)
                
                -- Set is shivving
                currentPrisoner.isShivvingLeft = false
                currentPrisoner.isShivvingRight = false
                if (currentPrisoner.currentSpeed == 0) then
                    if (currentPrisoner.inputA == true) then
                        currentPrisoner.isShivvingLeft = true
                    elseif (currentPrisoner.inputB == true) then
                        currentPrisoner.isShivvingRight = true
                    end
                end

                -- Kill nearby prisoners if shivving
                if (currentPrisoner.isShivvingLeft or currentPrisoner.isShivvingRight) then
                    for j = 1, #activePrisoners do
                        local otherPrisoner = activePrisoners[j]
                        if (otherPrisoner ~= nil and otherPrisoner ~= currentPrisoner) then
                            if (Vector2Distance(currentPrisoner.pos, otherPrisoner.pos) < currentPrisoner.size.x) then
                                local direction = otherPrisoner.pos.x - currentPrisoner.pos.x
                                if ((currentPrisoner.isShivvingLeft and direction < 0) or (currentPrisoner.isShivvingRight and direction > 0)) then
                                    --DrawText("Kill!", 0, 0, DrawMode.Sprite, "large", 4)
                                    if (otherPrisoner.dead ~= true) then
                                        otherPrisoner.dead = true
                                        otherPrisoner.currentAnimFrame = 1
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Set animation state based on direction and speed
            SetPrisonerAnimationState(currentPrisoner)

            -- Update animation frame
            SetPrisonerAnimationFrameIndex(currentPrisoner, timeDelta)
        end
    end
    
end

-- Not actually necessary
function GetCenter(prisoner)

    local halfSize = Vector2Divide(prisoner.size, 2)
    return Vector2Sum(prisoner.pos, halfSize)

end

function SetPrisonerAnimationState(prisoner)

    if (prisoner.dead) then
        prisoner.currentAnimState = prisonerAnimStates.death
    elseif (prisoner.currentSpeed > 0) then
        if (prisoner.currentDirection.x > 0) then
            prisoner.currentAnimState = prisonerAnimStates.walkRight
        elseif (prisoner.currentDirection.x < 0) then
            prisoner.currentAnimState = prisonerAnimStates.walkLeft
        else
            prisoner.currentAnimState = prisonerAnimStates.walkStr
        end
    else
        if (prisoner.isShivvingLeft == true) then
            prisoner.currentAnimState = prisonerAnimStates.shivLeft
        elseif (prisoner.isShivvingRight == true) then
            prisoner.currentAnimState = prisonerAnimStates.shivRight
        else
            prisoner.currentAnimState = prisonerAnimStates.idle
        end
    end

end

function SetPrisonerAnimationFrameIndex(prisoner, timeDelta)

    if (prisoner.doneDead ~= true) then

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