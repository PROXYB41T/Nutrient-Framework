local NutritionController = {}

function NutritionController:initializeTables(player)
    local playerData = player:getModData()
    playerData.nutrientList = self.tableHandler.NutrientList or {}
    playerData.nutrientListInit = true
    playerData.dailyIntake = {}
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        playerData.dailyIntake[nutrient] = 0
    end
end

function NutritionController:InitializePPNFTraitsData(player)
    local playerData = player:getModData()
    
    playerData.BlindnessActive = false
    playerData.NightBlindnessActive = false
    playerData.brainFog = false
    
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    
    playerData.previousStress = stats:getStress()
    playerData.previousPanic = stats:getPanic()
    playerData.previousFatigue = stats:getFatigue()
    playerData.previousHunger = stats:getHunger()
    playerData.previousThirst = stats:getThirst()
    playerData.previousUnhappiness = stats:getUnhappiness()
    playerData.previousBoredom = stats:getBoredom()
    playerData.previousEndurance = stats:getEndurance()
    playerData.previousTemperature = bodyDamage:getTemperature()
    playerData.previousInfectionChance = stats:getInfectionChance()
    playerData.stressDifference = 0
    playerData.panicDifference = 0
    playerData.fatigueDifference = 0
    playerData.hungerDifference = 0
    playerData.thirstDifference = 0
    playerData.unhappinessDifference = 0
    playerData.boredomDifference = 0
    playerData.enduranceDifference = 0
    playerData.temperatureDifference = 0
    playerData.infectionChanceDifference = 0
    playerData.grantedSufficiencyDays = playerData.grantedSufficiencyDays or {}
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        playerData.grantedSufficiencyDays[nutrient] = 365
    end
end

function NutritionController:InitializeNutrientStats(player)
    local playerData = player:getModData()
    playerData.nutrients = {}
    
    for nutrient, initValue in pairs(self.tableHandler.NutrientList) do
        playerData.nutrients[nutrient] = initValue
    end
    
    playerData.intakeHistory = {}
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        playerData.intakeHistory[nutrient] = {}
        local sufficiencyThreshold = self.tableHandler.sufficiencyThresholds[nutrient]
        for i = 1, 365 do
            table.insert(playerData.intakeHistory[nutrient], sufficiencyThreshold)
        end
    end
    
    playerData.nutrientStages = {}
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        playerData.nutrientStages[nutrient] = {
            deficiency = 0,
            sufficiency = 0
        }
    end
end

function NutritionController:InitializeInjuryCache(player)
    local playerData = player:getModData()
    
    -- Initialize injury cache variables
    playerData.DecayFromInjury = 0
    playerData.DecayFromAttack = 0
end

function NutritionController:Initialize(player, tableHandler)
    self.tableHandler = tableHandler
    self:initializeTables(player)
    self:InitializeNutrientStats(player)
    self:InitializePPNFTraitsData(player)
    self:InitializeInjuryCache(player)
end

function NutritionController:Update(player, deltaTime)
    self:DecayNutrient(player, deltaTime)
end

function NutritionController:DecayFromInjury(player)
    local baseDecay = self.tableHandler.baseDecay
    local playerData = player:getModData()
    
    local allInjuries = playerData.injuryCache or {}
    local aggregatedInjuryDecay = {}

    for _, injury in ipairs(allInjuries) do
        local decayMap = self.tableHandler.InjuryDecayMap[injury.type]
        if decayMap then
            for nutrient, multiplier in pairs(decayMap) do
                aggregatedInjuryDecay[nutrient] = (aggregatedInjuryDecay[nutrient] or 0) + baseDecay * multiplier
            end
        end
    end
    
    return aggregatedInjuryDecay
end

function NutritionController:OnPlayerUpdate(player)
    local currentTime = getTimestamp()
    local playerData = player:getModData()
    if playerData.lastInjuryCheck == nil then
        playerData.lastInjuryCheck = 0
    end
    if currentTime - playerData.lastInjuryCheck > 5000 then -- 5 seconds
        local bodyDamage = player:getBodyDamage()
        local overallHealth = bodyDamage:getOverallBodyHealth()
        local hasInjuries = overallHealth < 100 or bodyDamage:getNumPartsBleeding() > 0
        if hasInjuries and not playerData.hasActiveInjuries then
            playerData.injuryCache = self:InjuryCollector(player)
            playerData.hasActiveInjuries = true
            playerData.injuryCacheTime = currentTime
        elseif not hasInjuries and playerData.hasActiveInjuries then
            playerData.injuryCache = {}
            playerData.hasActiveInjuries = false
        end
        playerData.lastInjuryCheck = currentTime
    end
end

function NutritionController:InjuryCollector(player)
    local playerData = player:getModData()
    
    if playerData.hasActiveInjuries and playerData.injuryCache then
        return playerData.injuryCache
    end
    
    local allInjuries = {}
    local bodyDamage = player:getBodyDamage()
    local bodyParts = bodyDamage:getBodyParts()
    
    for i = 1, bodyParts:size() do
        local bodyPart = bodyParts:get(i - 1)
        if bodyPart then
            self:InjuryCounter(bodyPart, allInjuries)
        end
    end
    
    return allInjuries
end

function NutritionController:InjuryCounter(bodyPart, allInjuries)
    if bodyPart:scratched() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Scratch"})
    end
    if bodyPart:isCut() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Laceration"})
    end
    if bodyPart:bitten() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Bitten"})
    end
    if bodyPart:isBurnt() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Burn"})
    end
    if bodyPart:bleeding() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Bleeding"})
    end
    if bodyPart:deepWounded() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "DeepWound"})
    end
    if bodyPart:haveBullet() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Bullet"})
    end
    if bodyPart:haveGlass() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Glass"})
    end
    if bodyPart:stitched() then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Stitched"})
    end
    if bodyPart:getWoundInfectionLevel() > 0 then
        table.insert(allInjuries, {location = bodyPart:getType(), type = "Infection"})
    end
end

function NutritionController:DecayFromActivity(player)
    local activityMultiplier = self:GetActivityTable(player)
    local activityDecay = {}

    for activity, nutrientMap in pairs(self.tableHandler.ActivityNutrientDecayMap) do
        for nutrient, baseAmount in pairs(nutrientMap) do
            activityDecay[nutrient] = (activityDecay[nutrient] or 0) + baseAmount * activityMultiplier
        end
    end

    local temperatureCategory = self:GetTemperatureCategory(player)
    if temperatureCategory ~= "Normal" then
        local tempMultiplier = self:TemperatureMultiplier(player)
        local tempNutrientMap = self.tableHandler.TemperatureNutrientDecayMap[temperatureCategory]
        for nutrient, baseAmount in pairs(tempNutrientMap) do
            activityDecay[nutrient] = (activityDecay[nutrient] or 0) + baseAmount * tempMultiplier
        end
    end

    return activityDecay
end

function NutritionController:GetTemperatureCategory(player)
    local bodyDamage = player:getBodyDamage()
    local temp = bodyDamage:getTemperature()
    
    if temp >= 37.5 then 
        return "TooHot"
    elseif temp <= 35 then
        return "TooCold"
    elseif temp >= 36.5 and temp < 37.5 then 
        return "Hot"
    elseif temp >= 35 and temp < 36.5 then
        return "Cold"
    end
    
    return "Normal"
end

function NutritionController:TemperatureMultiplier(player)
    local temperatureCategory = self:GetTemperatureCategory(player)
    local tempMultiplier = 1.0
    if temperatureCategory == "TooHot" or temperatureCategory == "TooCold" then
        tempMultiplier = 2.0
    elseif temperatureCategory == "Hot" or temperatureCategory == "Cold" then
        tempMultiplier = 1.5
    end
    return tempMultiplier
end

function NutritionController:GetActivityTable(player)
    local totalMultiplier = 1.0

    -- Primary
    local primaryMult = self:GetPrimaryActivity(player)
    totalMultiplier = totalMultiplier * primaryMult

    -- Secondary
    local secondaryMult = self:GetSecondaryActivity(player)
    totalMultiplier = totalMultiplier * secondaryMult

    -- Tertiary (single combined multiplier)
    local tertiaryMult = self:GetTertiaryActivities(player)
    totalMultiplier = totalMultiplier * tertiaryMult

    return totalMultiplier
end

function NutritionController:GetCurrentTimedAction(player)
    if ISTimedActionQueue and ISTimedActionQueue.getTimedActionQueue then
        local actionQueue = ISTimedActionQueue.getTimedActionQueue(player)
        if actionQueue and actionQueue.queue and actionQueue.queue[1] then
            return actionQueue.queue[1]
        end
    end
    return nil
end

function NutritionController:GetPrimaryActivity(player)
    if player:isSprinting() then 
        return 2.5 
    elseif player:IsRunning() then 
        return 1.8 
    elseif player:isClimbing() then 
        return 2.2 
    elseif player:isDriving() then
        return 1.05
    elseif player:isSneaking() then 
        return 1.6 
    elseif player:isSeatedInVehicle() then 
        return 1.0 
    elseif player:isPlayerMoving() then
        return 1.3
    else
        -- Check for sleep state through timed actions
        local currentAction = self:GetCurrentTimedAction(player)
        if currentAction and currentAction.Type and string.find(currentAction.Type, "Sleep") then
            return 0.4
        end
        
        return 1.0
    end
end

function NutritionController:GetSecondaryActivity(player)
    if player:isAiming() then 
        return 1.3 
    end
    
    local currentAction = self:GetCurrentTimedAction(player)
    if not currentAction or not currentAction.Type then
        return 1.0
    end
    
    local actionType = currentAction.Type
    
    -- EATING & DRINKING (using correct action names)
    if string.find(actionType, "ISEatFoodAction") then
        return 1.1
    elseif string.find(actionType, "ISDrinkAction") then
        return 1.05
    
    -- READING (using correct action names)
    elseif string.find(actionType, "ISReadABook") or string.find(actionType, "ISReadMagazine") then
        return 1.05
    
    -- MEDICAL (using correct action names)
    elseif string.find(actionType, "ISApplyBandage") or string.find(actionType, "ISBandage") then
        return 1.25
    elseif string.find(actionType, "ISTakePill") or string.find(actionType, "ISDisinfect") then
        return 1.15
    
    -- CRAFTING & BUILDING (using correct action names)
    elseif string.find(actionType, "ISCraftAction") then
        return 1.4
    elseif string.find(actionType, "ISBuildAction") or string.find(actionType, "ISBarricadeAction") then
        return 1.6
    
    -- WEAPONS & EQUIPMENT (using correct action names)
    elseif string.find(actionType, "ISEquipWeaponAction") or string.find(actionType, "ISUnequipAction") then
        return 1.2
    elseif string.find(actionType, "ISReloadWeaponAction") or string.find(actionType, "ISRackFirearm") then
        return 1.25
    
    -- REPAIR & MAINTENANCE (using correct action names)
    elseif string.find(actionType, "ISRepairAction") or string.find(actionType, "ISFixGenerator") then
        return 1.35
    
    -- CLEANING (using correct action names)
    elseif string.find(actionType, "ISWashClothing") or string.find(actionType, "ISCleanBlood") then
        return 1.2
    
    -- GATHERING (using correct action names)
    elseif string.find(actionType, "ISSearchAction") or string.find(actionType, "ISForageAction") then
        return 1.3
    elseif string.find(actionType, "ISFishingAction") then
        return 1.1
    
    -- VEHICLES (using correct action names)
    elseif string.find(actionType, "ISEnterVehicle") or string.find(actionType, "ISExitVehicle") then
        return 1.2
    
    -- ADDITIONAL COMMON ACTIONS (based on documented action types)
    elseif string.find(actionType, "ISLockDoor") or string.find(actionType, "ISOpenCloseCurtain") then
        return 1.05
    elseif string.find(actionType, "ISInventoryTransferAction") or string.find(actionType, "ISDropItemAction") then
        return 1.02
    elseif string.find(actionType, "ISSawAction") or string.find(actionType, "ISHammering") then
        return 1.5
    elseif string.find(actionType, "ISDigAction") or string.find(actionType, "ISPlowAction") then
        return 1.8
    elseif string.find(actionType, "ISStartFireAction") or string.find(actionType, "ISAddFuelAction") then
        return 1.3
    end
    
    return 1.0
end

function NutritionController:IsCarryingHeavyLoad(player)
    local maxWeight = player:getMaxWeight()
    local currentWeight = player:getInventoryWeight()
    local weightRatio = currentWeight / maxWeight
    local multiplier = 1.0
    
    if weightRatio > 1.0 then
        multiplier = multiplier * 1.8
    elseif weightRatio > 0.8 then
        multiplier = multiplier * 1.3
    end
    
    return multiplier
end

function NutritionController:anyPartBroken(player)
    local bodyDamage = player:getBodyDamage()
    local bodyParts = bodyDamage:getBodyParts()
    
    for i = 1, bodyParts:size() do
        local bodyPart = bodyParts:get(i - 1)
        if bodyPart and bodyPart:getFractureTime() > 0 then
            return true
        end
    end
    
    return false
end

function NutritionController:GetTertiaryActivities(player)
    local multipliers = 1.0
    local isCarryingHeavyLoad = self:IsCarryingHeavyLoad(player)

    if RainManager.isRaining() and player:isOutside() then
        multipliers = multipliers * 1.1
    end
    
    if player:isOnFire() then
        multipliers = multipliers * 3.0
    end
    
    local bodyDamage = player:getBodyDamage()
    if bodyDamage:getNumPartsBleeding() > 0 then
        multipliers = multipliers * 1.3
    end
    
    if self:anyPartBroken(player) then
        multipliers = multipliers * 1.5
    end
    
    if player:getBodyDamage():IsInfected() then
        multipliers = multipliers * 1.5
    end 
    multipliers = multipliers * isCarryingHeavyLoad
    
    return multipliers
end

function NutritionController:DecayFromSweat(player, deltaTime)
    local sweatUnits = SweatController:sweatyCalculator(player, deltaTime or 1)
    local sweatDecay = {}

    -- Initialize all nutrients to 0
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        sweatDecay[nutrient] = 0
    end

    -- Apply sweat-specific nutrient losses
    sweatDecay.Sodium = sweatUnits * 1.5
    sweatDecay.Potassium = sweatUnits * 3.0
    sweatDecay.Magnesium = sweatUnits * 0.42

    return sweatDecay
end

function NutritionController:DecayFromAttack(player)
    local bodyDamage = player:getBodyDamage()
    local painLevel = 0
    local stats = player:getStats()
    painLevel = (stats:getPain() or 0) / 100
    
    -- Use cached injuries instead of calling InjuryCollector
    local playerData = player:getModData()
    local allInjuries = playerData.injuryCache or {}
    
    local injurySeverityWeights = {
        Scratch   = 0.1,
        Cut       = 0.15,
        Bitten    = 0.25,
        Burn      = 0.2,
        Bleeding  = 0.1,
        DeepWound = 0.15,
        Glass     = 0.1,
        Bullet    = 0.18,
        Stitched  = 0.05,
    }
    local totalInjurySeverity = 0
    for _, injury in ipairs(allInjuries) do
        totalInjurySeverity = totalInjurySeverity + (injurySeverityWeights[injury.type] or 0)
    end
    local attackMultiplier = 1.0 + painLevel + totalInjurySeverity
    return attackMultiplier
end

function NutritionController:NutrientReset(player)
    local playerData = player:getModData()
    
    -- Initialize intake history if it doesn't exist
    playerData.intakeHistory = playerData.intakeHistory or {}
    playerData.grantedSufficiencyDays = playerData.grantedSufficiencyDays or {}
    
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        local dailyIntake = playerData.dailyIntake[nutrient] or 0

        playerData.intakeHistory[nutrient] = playerData.intakeHistory[nutrient] or {}

        table.insert(playerData.intakeHistory[nutrient], 1, dailyIntake)

        if #playerData.intakeHistory[nutrient] > 730 then
            table.remove(playerData.intakeHistory[nutrient], 731)
        end

        playerData.grantedSufficiencyDays[nutrient] = playerData.grantedSufficiencyDays[nutrient] or 0
        if playerData.grantedSufficiencyDays[nutrient] > 0 then
            playerData.grantedSufficiencyDays[nutrient] = playerData.grantedSufficiencyDays[nutrient] - 1
        end

        playerData.dailyIntake[nutrient] = 0
    end
    
    self:UpdatePlayerStages(player)
    playerData.SweatAccumulated = 0
end

function NutritionController:DecayNutrient(player, deltaTime)
    local playerData = player:getModData()
    local injuryDecay = self:DecayFromInjury(player)
    local activityDecay = self:DecayFromActivity(player)
    local sweatDecay = self:DecayFromSweat(player, deltaTime)
    local attackMultiplier = self:DecayFromAttack(player)
    local sunNutrients = self:NutrientFromSun(player, deltaTime)

    local decayMultiplier = 1.0 * attackMultiplier * deltaTime 

    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        local absorptionMultiplier = self:GetTotalAbsorptionMultiplier(player, nutrient)

        local decay = ((injuryDecay[nutrient] or 0)
                   + (activityDecay[nutrient] or 0)
                   + (sweatDecay[nutrient] or 0))
                   * attackMultiplier

        local gain = sunNutrients[nutrient] or 0

        gain = gain * absorptionMultiplier
        decay = decay * decayMultiplier

        local netChange = gain - decay
        playerData.dailyIntake[nutrient] = (playerData.dailyIntake[nutrient] or 0) + netChange
    end
end

function NutritionController:OnConsume(player, foodItem)
    local nutrientsTable = {}

    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        local nutrientGiven = 0

        if foodItem.nutrients and foodItem.nutrients[nutrient] ~= nil then
            nutrientGiven = foodItem.nutrients[nutrient]
        end

        nutrientsTable[nutrient] = nutrientGiven
    end

    local playerData = player:getModData()
    
    playerData.nutrients = playerData.nutrients or {}
    for nutrient, amount in pairs(nutrientsTable) do
        local absorptionMultiplier = self:GetTotalAbsorptionMultiplier(player, nutrient)
        local adjustedAmount = amount * absorptionMultiplier
        playerData.nutrients[nutrient] = math.max(0, (playerData.nutrients[nutrient] or 0) + adjustedAmount)
        playerData.dailyIntake[nutrient] = (playerData.dailyIntake[nutrient] or 0) + adjustedAmount
    end
    return nutrientsTable
end

function NutritionController:GetSunlightStrength(player)
    local climateInstance = _G.ClimateManager.getInstance()
    if climateInstance and player:isOutside() then
        local baseSunlight = climateInstance:getDayLightStrength() or 0
        local cloudIntensity = climateInstance:getCloudIntensity() or 0
        local precipIntensity = climateInstance:getPrecipitationIntensity() or 0
        local playerSquare = player:getCurrentSquare()
        local lightLevel = playerSquare:getLightLevel(player:getPlayerNum())
                
        local cloudReduction = cloudIntensity * 0.7
        local precipReduction = precipIntensity * 0.3
            

        local adjustedSunlight = baseSunlight * (1 - cloudReduction - precipReduction) * lightLevel
        return math.max(0, adjustedSunlight)
    end    
end

function NutritionController:NutrientFromSun(player, deltaTime) 
    local sunNutrients = {}
    local sunlightStrength = self:GetSunlightStrength(player) or 0
    local vitaminDRate = 0.01
    local vitaminDGain = vitaminDRate * sunlightStrength * deltaTime
    
    sunNutrients.VitaminD = vitaminDGain
    
    return sunNutrients
end

function NutritionController:UpdatePlayerStages(player)
    local playerData = player:getModData()
    playerData.nutrientStages = playerData.nutrientStages or {}
    
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        local deficiencyStage, _ = self:GetDeficiencyStage(player, nutrient)
        local sufficiencyStage, _ = self:GetSufficiencyStage(player, nutrient)
        
        playerData.nutrientStages[nutrient] = {
            deficiency = deficiencyStage,
            sufficiency = sufficiencyStage
        }
    end
end

function NutritionController:GetDeficiencyStage(player, nutrient)
    local intakeHistory = player:getModData().intakeHistory or {}
    local history = intakeHistory[nutrient] or {}
    local stages = self.tableHandler.stages
    
    local playerData = player:getModData()
    local playerNutrientList = playerData.nutrientList or {}
    local deficiencyThreshold = (playerNutrientList[nutrient]) * (self.tableHandler.deficiencyThresholds[nutrient] or 1.0)

    for stageNum, stage in ipairs(stages) do
        local count = 0
        for i = 1, math.min(stage.window, #history) do
            if history[i] < deficiencyThreshold then
                count = count + 1
            end
        end
        if count >= stage.threshold then
            return 6 - stageNum, count 
        end
    end
    return 0, 0 
end

function NutritionController:GetTotalAbsorptionMultiplier(player, nutrient)
    local multiplier = 1
    local playerData = player:getModData()
    local stagesCache = playerData.nutrientStages or {}

    for affectingNutrient, stages in pairs(self.tableHandler.deficiencyAbsorptionMultipliers) do
        local stage = stagesCache[affectingNutrient] and stagesCache[affectingNutrient].deficiency or 0
        if stage > 0 then
            local stageName = "stage" .. tostring(stage)
            local stageTable = stages[stageName]
            if stageTable and stageTable[nutrient] then
                multiplier = multiplier * (1 - stageTable[nutrient])
            end
        end
    end

    for affectingNutrient, stages in pairs(self.tableHandler.sufficiencyAbsorptionMultipliers) do
        local stage = stagesCache[affectingNutrient] and stagesCache[affectingNutrient].sufficiency or 0
        if stage > 0 then
            local stageName = "stage" .. tostring(stage)
            local stageTable = stages[stageName]
            if stageTable and stageTable[nutrient] then
                multiplier = multiplier * stageTable[nutrient]
            end
        end
    end
    return multiplier
end

function NutritionController:GetSufficiencyStage(player, nutrient)
    print("DEBUG: GetSufficiencyStage called. self.tableHandler:", self.tableHandler, "player:", player, "nutrient:", nutrient)
    local intakeHistory = player:getModData().intakeHistory or {}
    local history = intakeHistory[nutrient] or {}
    local stages = self.tableHandler.stages

    local playerData = player:getModData()
    local playerNutrientList = playerData.nutrientList or {}
    local sufficiencyThreshold = (playerNutrientList[nutrient]) * (self.tableHandler.sufficiencyThresholds[nutrient] or 1.0)

    for stageNum, stage in ipairs(stages) do
        local count = 0
        for i = 1, math.min(stage.window, #history) do
            if history[i] >= sufficiencyThreshold then
                count = count + 1
            end
        end
        if count >= stage.threshold then
            return 6 - stageNum, count
        end
    end
    return 0, 0
end

function NutritionController:ResetRecipeIngredients(ingredients, result, player)
    print("DEBUG: ResetRecipeIngredients called. self.tableHandler:", self.tableHandler, "ingredients:", ingredients, "result:", result, "player:", player)
    local summedNutrients = {}
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        summedNutrients[nutrient] = 0
    end

    for i = 1, #ingredients do
        local item = ingredients[i]
        if item and item:isFood() then
            local foodNutrients = item.nutrients or (item.getNutrients and item:getNutrients()) or {}
            for nutrient, _ in pairs(self.tableHandler.NutrientList) do
                local value = foodNutrients[nutrient] or 0
                summedNutrients[nutrient] = summedNutrients[nutrient] + value
            end
        end
    end

    result.nutrients = result.nutrients or {}
    for nutrient, value in pairs(summedNutrients) do
        result.nutrients[nutrient] = value
    end
end

function NutritionController:GetFreshnessAdjustedNutrients(foodItem, baseNutrients)
    if not foodItem or not baseNutrients then
        return baseNutrients or {}
    end
    
    local age = foodItem:getAge()
    local offAge = foodItem:getOffAge()
    
    if not age or not offAge or offAge <= 0 then
        return baseNutrients
    end
    
    local freshnessMultiplier = 1.0
    
    if foodItem:isRotten() then
        freshnessMultiplier = 0.1 
    elseif foodItem:isFresh() then
        freshnessMultiplier = 1.0 
    else
        freshnessMultiplier = 0.5  
    end
    
    local adjustedNutrients = {}
    for nutrient, amount in pairs(baseNutrients) do
        adjustedNutrients[nutrient] = amount * freshnessMultiplier
    end
    
    return adjustedNutrients
end

return NutritionController





