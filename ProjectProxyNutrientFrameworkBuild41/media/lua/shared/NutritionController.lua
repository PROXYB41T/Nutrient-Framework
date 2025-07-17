local NutritionController = {}

function NutritionController:getTableHandler()
    return _G.TableHandler or nil
end

function NutritionController:initializeTables(player)
    local playerData = player:getModData()
    playerData.nutrientList = self.tableHandler.NutrientList or {}
    playerData.nutrientListInit = true
    NutritionController.dailyIntake = {}
    NutritionController.deficiencyStatus = {}
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        NutritionController.dailyIntake[nutrient] = 0
        NutritionController.deficiencyStatus[nutrient] = false
    end
end

function NutritionController:InitializeNutrientStreaks(player)
    local playerNutrients = player:getModData()
    
    playerNutrients.sufficiencyStreak = playerNutrients.sufficiencyStreak or {}
    playerNutrients.grantedSufficiencyDays = playerNutrients.grantedSufficiencyDays or {}
    
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        playerNutrients.sufficiencyStreak[nutrient] = 365
        playerNutrients.grantedSufficiencyDays[nutrient] = 365
    end
end

function NutritionController:InitializeNutrientStats(player)
    local playerData = player:getModData()
    
    if not playerData.nutrients then
        playerData.nutrients = {}
        
        for nutrient, initValue in pairs(self.tableHandler.NutrientList) do
            playerData.nutrients[nutrient] = initValue
        end
        
        playerData.intakeHistory = {}
        playerData.deficiencyStreak = {}
        playerData.avg7Days = {}
        playerData.avg30Days = {}
        
        for nutrient, _ in pairs(self.tableHandler.NutrientList) do
            playerData.intakeHistory[nutrient] = {}
            local sufficiencyThreshold = self.tableHandler.sufficiencyThresholds[nutrient]
            
            for i = 1, 365 do
                table.insert(playerData.intakeHistory[nutrient], sufficiencyThreshold)
            end
        end
    end
end

function NutritionController:Update(player, deltaTime)
    local playerData = player:getModData()
    if not playerData.tableHandlerDone then
        self.tableHandler = self:getTableHandler()
        if playerData.tableHandler then
            if not playerData.initializationDone then
                self:initializeTables()
                self:InitializeNutrientStats(player)
                self:InitializeNutrientStreaks(player)
                playerData.initializationDone = true
            end
        end
        playerData.tableHandlerDone = true
    elseif playerData.tableHandlerDone then
        self:DecayNutrient(player, deltaTime)
    end
end

function NutritionController:DecayFromInjury(player)
    local baseDecay = self.tableHandler.baseDecay
    local allInjuries = self:InjuryCollector(player)
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

function NutritionController:InjuryCollector(player)
    local allInjuries = {}
    local bodyDamage = player:getBodyDamage()
    local overallHealth = bodyDamage:getOverallBodyHealth()
    
    if overallHealth < 100 then
        local partIndex = 0
        while true do
            local bodyPartType = BodyPartType.FromIndex(partIndex)
            if not bodyPartType then 
                break 
            end
            
            local bodyPart = bodyDamage:getBodyPart(bodyPartType)
            if bodyPart then
                self:InjuryCounter(bodyPart, allInjuries)
            end
            
            partIndex = partIndex + 1
            
            if partIndex > 100 then
                break
            end
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
    -- PRIMARY ACTIVITIES: Core movement/locomotion (mutually exclusive)
    
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
    -- SECONDARY ACTIVITIES: Actions you can perform while doing primary activities
    
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
    local partIndex = 0
    while true do
        local bodyPartType = BodyPartType.FromIndex(partIndex)
        if not bodyPartType then 
            break 
        end
        
        local bodyPart = bodyDamage:getBodyPart(bodyPartType)
        if bodyPart:getFractureTime() > 0 then
            return true
        end
        
        partIndex = partIndex + 1
        if partIndex > 100 then
            break
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
    
    if player:isInfected() then
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
    local allInjuries = self:InjuryCollector(player)
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
        totalInjurySeverity = totalInjurySeverity + (injurySeverityWeights[injury.type])
    end
    local attackMultiplier = 1.0 + painLevel + totalInjurySeverity
    _G.SweatController:AddSweatFromStrain(player, attackMultiplier)
    return attackMultiplier
end

function NutritionController:NutrientReset(player)
    local playerNutrients = player:getModData()
    
    -- Initialize intake history if it doesn't exist
    playerNutrients.intakeHistory = playerNutrients.intakeHistory or {}
    playerNutrients.grantedSufficiencyDays = playerNutrients.grantedSufficiencyDays or {}
    
    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        local dailyIntake = NutritionController.dailyIntake[nutrient] or 0
        
        playerNutrients.intakeHistory[nutrient] = playerNutrients.intakeHistory[nutrient] or {}
        
        table.insert(playerNutrients.intakeHistory[nutrient], 1, dailyIntake)
        
        if #playerNutrients.intakeHistory[nutrient] > 730 then
            table.remove(playerNutrients.intakeHistory[nutrient], 731)
        end
        
        playerNutrients.grantedSufficiencyDays[nutrient] = playerNutrients.grantedSufficiencyDays[nutrient] or 0
        if playerNutrients.grantedSufficiencyDays[nutrient] > 0 then
            playerNutrients.grantedSufficiencyDays[nutrient] = playerNutrients.grantedSufficiencyDays[nutrient] - 1
        end
        
        NutritionController.dailyIntake[nutrient] = 0
    end
    
    self:UpdatePlayerStages(player)
    _G.SweatController:ResetSweatAccumulated(player)
    _G.PPNFTraits:TraitUpdateDay(player)

end

function NutritionController:DecayNutrient(player, deltaTime)
    local modData = player:getModData()
    deltaTime = deltaTime
    local injuryDecay = self:DecayFromInjury(player)
    local activityDecay = self:DecayFromActivity(player)
    local sweatDecay = self:DecayFromSweat(player, deltaTime)
    local attackMultiplier = self:DecayFromAttack(player)
    local sunNutrients = self:NutrientFromSun(player, deltaTime)

    local decayMultiplier = traitMultiplier * attackMultiplier * deltaTime 

    for nutrient, _ in pairs(self.tableHandler.NutrientList) do
        local absorptionMultiplier = self:GetTotalAbsorptionMultiplier(player, nutrient)

        local decay = ((injuryDecay[nutrient] or 0)
                   + (activityDecay[nutrient] or 0)
                   + (sweatDecay[nutrient] or 0))
                   * ((traitMultiplier or 0)
                   + (attackMultiplier or 0))

        local gain = sunNutrients[nutrient] or 0

        gain = gain * absorptionMultiplier
        decay = decay * decayMultiplier

        local netChange = gain - decay
        NutritionController.dailyIntake[nutrient] = NutritionController.dailyIntake[nutrient] + netChange
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
        NutritionController.dailyIntake[nutrient] = (NutritionController.dailyIntake[nutrient] or 0) + adjustedAmount
    end
    if _G.PPNFTraits then
        _G.PPNFTraits:ToxicityChecker(player)
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
    
    local sunlightStrength = self:GetSunlightStrength(player)
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

function NutritionController:CalculateStageMultiplier(days, stages)
    local total = 0
    local remaining = days
    for _, stage in ipairs(stages) do
        local stageDays = math.min(stage.days, remaining)
        if stageDays > 0 then
            total = total + (stage.value / stage.days) * stageDays
            remaining = remaining - stageDays
        end
        if remaining <= 0 then break end
    end
    return 1 - total
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

    for affectingNutrient, stages in pairs(self.tableHandler.deficiencyAbsorptionMultipliers) do
        local stage, _ = self:GetDeficiencyStage(player, affectingNutrient)
        if stage > 0 then
            local stageName = "stage" .. tostring(stage)
            local stageTable = stages[stageName]
            if stageTable and stageTable[nutrient] then
                multiplier = multiplier * (1 - stageTable[nutrient])
            end
        end
    end

    for affectingNutrient, stages in pairs(self.tableHandler.sufficiencyAbsorptionMultipliers) do
        local stage, _ = self:GetSufficiencyStage(player, affectingNutrient)
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

function NutritionController:CalculateSufficiencyStageMultiplier(days, stages)
    local total = 0
    local remaining = days
    for _, stage in ipairs(stages) do
        local stageDays = math.min(stage.days, remaining)
        if stageDays > 0 then
            total = total + (stage.value / stage.days) * stageDays
            remaining = remaining - stageDays
        end
        if remaining <= 0 then break end
    end
    return 1 + total
end

function NutritionController:GetSufficiencyStage(player, nutrient)
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





