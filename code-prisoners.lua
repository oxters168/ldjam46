LoadScript("code-sprites-directory")

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
}

function SpawnPrisoner(x, y)

    local prisonerData = {
        uid = tostring(os.time()),
        pos = NewPoint(x, y),
        rect = NewRect(0, 0, 8, 8),
        currentAnimState = "idle",
        currentAnimFrame = 1,
        timePassedSinceLastFrame = 0,
        remove = false,
    }
    table.insert(activePrisoners, prisonerData)

    return prisonerData

end

function UpdatePrisoners(timeDelta)

    for i = 1, #activePrisoners do
        local currentPrisoner = activePrisoners[i]
        if (currentPrisoner ~= nil and currentPrisoner.remove ~= true) then
            SetAnimationFrameIndex(currentPrisoner, timeDelta)
        end
    end
    
end

function SetAnimationFrameIndex(prisoner, timeDelta)

    local secondsPerFrame = 1 / framesPerSecond
    prisoner.timePassedSinceLastFrame = prisoner.timePassedSinceLastFrame + (timeDelta / 1000)
    local framesToPass = math.floor(prisoner.timePassedSinceLastFrame / secondsPerFrame)
    if (framesToPass > 0) then
        local totalFrames = #prisonerAnimStates[prisoner.currentAnimState]
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

            local frames = prisonerAnimStates[currentPrisoner.currentAnimState]
            local spriteData = frames[currentPrisoner.currentAnimFrame]
            if (spriteData ~= nil) then
                DrawSprites(spriteData.spriteIDs, currentPrisoner.pos.x, currentPrisoner.pos.y, spriteData.width)
            end
        end
    end
    activePrisoners = stillActivePrisoners
end