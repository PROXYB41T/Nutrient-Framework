local PPNFNutritionGetters = {}

function PPNFNutritionGetters:TablehandlerINIT(player)
    local playerData = player:getModData()
    if playerData.initializationDone and not playerData.gettersDone then
        playerData.gettersDone = true
        self.tableHandler = _G.TableHandler
    end
end


function PPNFNutritionGetters:getPlayerNutrients(player)
    local playerData = player:getModData()
    local nutrients = {}
    
    for _, nutrient in ipairs(self.tableHandler.displayOrder) do
        local key = nutrient.key
        local dailyRequirement = playerData.nutrientList[key] or 0
        local currentConsumption = playerData.nutrients[key] or 0

        nutrients[#nutrients + 1] = {
            key = key,
            nutrientLabel = nutrient.label,
            current = currentConsumption,
            required = dailyRequirement,
            percentage = (currentConsumption / dailyRequirement) * 100
        }
    end
    
    return nutrients
end

function Food:getCals()
    local baseValue = self:getCalories()
    if baseValue and baseValue > 0 then
        return baseValue
    else
        local script = self:getScriptItem()
        return script:getProperty("Cals") or 0
    end
end

function Food:getFats()
    local baseValue = self:getLipids()
    if baseValue and baseValue > 0 then
        return baseValue
    else
        local script = self:getScriptItem()
        return script:getProperty("Fats") or 0
    end
end

function Food:getCarbs()
    local baseValue = self:getCarbohydrates()
    if baseValue and baseValue > 0 then
        return baseValue
    else
        local script = self:getScriptItem()
        return script:getProperty("Carbs") or 0
    end
end

function Food:getProteinPlus()
    local baseValue = self:getProteins()
    if baseValue and baseValue > 0 then
        return baseValue
    else
        local script = self:getScriptItem()
        return script:getProperty("ProteinPlus") or 0
    end
end

function Food:getCholesterol()
    local script = self:getScriptItem()
    return script:getProperty("Cholesterol") or 0
end

function Food:getSodium()
    local script = self:getScriptItem()
    return script:getProperty("Sodium") or 0
end

function Food:getMagnesium()
    local script = self:getScriptItem()
    return script:getProperty("Magnesium") or 0
end

function Food:getPotassium()
    local script = self:getScriptItem()
    return script:getProperty("Potassium") or 0
end

function Food:getVitaminA()
    local script = self:getScriptItem()
    return script:getProperty("VitaminA") or 0
end

function Food:getVitaminD()
    local script = self:getScriptItem()
    return script:getProperty("VitaminD") or 0
end

function Food:getVitaminE()
    local script = self:getScriptItem()
    return script:getProperty("VitaminE") or 0
end

function Food:getVitaminK()
    local script = self:getScriptItem()
    return script:getProperty("VitaminK") or 0
end

function Food:getVitaminC()
    local script = self:getScriptItem()
    return script:getProperty("VitaminC") or 0
end

function Food:getVitaminB1()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB1") or 0
end

function Food:getVitaminB2()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB2") or 0
end

function Food:getVitaminB3()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB3") or 0
end

function Food:getVitaminB5()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB5") or 0
end

function Food:getVitaminB6()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB6") or 0
end

function Food:getVitaminB9()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB9") or 0
end

function Food:getVitaminB12()
    local script = self:getScriptItem()
    return script:getProperty("VitaminB12") or 0
end

function Food:getCalcium()
    local script = self:getScriptItem()
    return script:getProperty("Calcium") or 0
end

function Food:getPhosphorus()
    local script = self:getScriptItem()
    return script:getProperty("Phosphorus") or 0
end

function Food:getIron()
    local script = self:getScriptItem()
    return script:getProperty("Iron") or 0
end

function Food:getZinc()
    local script = self:getScriptItem()
    return script:getProperty("Zinc") or 0
end

return PPNFNutritionGetters