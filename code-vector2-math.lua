function WorldAxis2DUp()
    
    return { x = 0, y = 1, }

end
function WorldAxis2DDown()

    return { x = 0, y = -1, }

end
function WorldAxis2DLeft()

    return { x = -1, y = 0, }

end
function WorldAxis2DRight()

    return { x = 1, y = 0, }

end
function WorldAxis2DNone()

    return { x = 0, y = 0, }

end

function Vector2Sum(lhs, rhs)

    local sum = { x = lhs.x + rhs.x, y = lhs.y + rhs.y, }
    return sum

end

function Vector2Difference(lhs, rhs)

    local difference = { x = lhs.x - rhs.x, y = lhs.y - rhs.y, }
    return difference

end

function Vector2Multiply(lhs, scalar)

    local product = { x = lhs.x * scalar, y = lhs.y * scalar, }
    return product

end

function Vector2Divide(lhs, scalar)

    local quotient = { x = lhs.x / scalar, y = lhs.y / scalar, }
    return quotient

end

function Vector2Magnitude(vector)

    local magnitude = math.sqrt(vector.x * vector.x + vector.y * vector.y)
    return magnitude
    
end

function Vector2Clamp(vector, minClampValues, maxClampValues)

    local clamped = { x = math.min(math.max(vector.x, minClampValues.x), maxClampValues.x), y = math.min(math.max(vector.y, minClampValues.y), maxClampValues.y), }
    return clamped

end

function Vector2Normalize(vector)
    
    local magnitude = Vector2Magnitude(vector)
    local normalized = { x = 0, y = 0, }
    if (magnitude > 0) then
        normalized.x = vector.x / magnitude
        normalized.y = vector.y / magnitude
    end
    return normalized

end

function Vector2Distance(lhs, rhs)

    local difference = Vector2Difference(rhs, lhs)
    return Vector2Magnitude(difference)

end

--- Turns a vector whose x and y range are -1 to 1 to be circular rather than square
function Vector2SquareInputToCircle(vector)

    local circle = { x = vector.x * math.sqrt(1 - vector.y * vector.y * 0.5), y = vector.y * math.sqrt(1 - vector.x * vector.x * 0.5), }
    return circle
    
end

--- Turns vector to string
function Vector2ToString(vector)

    return "x " .. vector.x .. " y " .. vector.y

end