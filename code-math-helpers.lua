--- Adjusts the given value's decimal places to be a specific amount
function SetDecimalPlaces(decimalValue, decimalPlaces)

    local adjustedValue = decimalValue
    for i = 1, decimalPlaces do
        adjustedValue = adjustedValue * 10
    end
    adjustedValue = ToInteger(adjustedValue)
    for i = 1, decimalPlaces do
        adjustedValue = adjustedValue / 10
    end
    return adjustedValue

end

function ToInteger(decimalValue)

    local outputValue = math.floor(math.abs(decimalValue))
    if (decimalValue < 0) then
        outputValue = outputValue * -1
    end
    return outputValue

end