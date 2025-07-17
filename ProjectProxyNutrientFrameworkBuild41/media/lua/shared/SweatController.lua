local SweatController = {}

function SweatController:Update(player, deltaTime)
    self:SweatInterceptor(player)
    self:sweatAccumulated(player, deltaTime)
end

function SweatController:sweatLevelFinder(player, sweatGain)
    local playerData = player:getModData()
    playerData.SweatLevel = math.max(0, math.min(100, (playerData.SweatLevel or 0) + sweatGain))
end

function SweatController:sweatAccumulated(player, deltaTime)
    local playerData = player:getModData()
    local sweatGain = self:sweatActivityMultiplier(player) * deltaTime
    playerData.SweatAccumulated = (playerData.SweatAccumulated or 0) + sweatGain
end

function SweatController:sweatPainMultiplier(player)
    local stats = player:getStats()
    local painLevel = stats:getPain() or 0
    local painMultiplier = 1 + (painLevel / 100)
    return painMultiplier
end

function SweatController:sweatyCalculator(player, deltaTime)
    local sweatMultiplier = self:sweatActivityMultiplier(player)
    local sweatDecay = self:DecaySweatLevel(player, deltaTime)
    local baseSweat = 1
    local sweatGain = ((baseSweat * sweatMultiplier) - sweatDecay) * deltaTime
    self:sweatLevelFinder(player, sweatGain)
    return sweatGain
end

function SweatController:GetActivityTable(player)
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

    local tempMultiplier = self:TemperatureMultiplier(player)
    totalMultiplier = totalMultiplier * tempMultiplier

    return totalMultiplier
end

function SweatController:GetCurrentTimedAction(player)
    if ISTimedActionQueue and ISTimedActionQueue.getTimedActionQueue then
        local actionQueue = ISTimedActionQueue.getTimedActionQueue(player)
        if actionQueue and actionQueue.queue and actionQueue.queue[1] then
            return actionQueue.queue[1]
        end
    end
    return nil
end

function SweatController:GetPrimaryActivity(player)
    -- PRIMARY ACTIVITIES: Core movement/locomotion (mutually exclusive)
    
    if player:isSprinting() then 
        return 2.0 
    elseif player:IsRunning() then 
        return 1.5 
    elseif player:isClimbing() then 
        return 2.5 
    elseif player:isDriving() then
        return 1.1
    elseif player:isSneaking() then 
        return 1.5 
    elseif player:isSeatedInVehicle() then 
        return 1.0 
    elseif player:isPlayerMoving() then
        return 1.25
    else
        local currentAction = self:GetCurrentTimedAction(player)
        if currentAction and currentAction.Type and string.find(currentAction.Type, "Sleep") then
            return 0.5
        end
        return 1.0
    end
end

function SweatController:GetSecondaryActivity(player)
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

function SweatController:anyPartBroken(player)
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

function SweatController:GetTertiaryActivities(player)
    local multiplier = 1.0
    local isCarryingHeavyLoad = self:IsCarryingHeavyLoad(player)
    
    if RainManager.isRaining() and player:isOutside() then
        multiplier = multiplier * 1.1
    end
    
    if player:isOnFire() then
        multiplier = multiplier * 2.0
    end
    
    local bodyDamage = player:getBodyDamage()
    if bodyDamage:getNumPartsBleeding() > 0 then
        multiplier = multiplier * 1.3
    end
    
    if self:anyPartBroken(player) then
        multiplier = multiplier * 1.5
    end
    
    if player:isInfected() then
        multiplier = multiplier * 1.5
    end 
    multiplier = multiplier * isCarryingHeavyLoad
    
    return multiplier
end

function SweatController:sweatActivityMultiplier(player)
    local activityMultiplier = self:GetActivityTable(player)
    local thermalMultiplier = self:TemperatureMultiplier(player)
    local painMultiplier = self:sweatPainMultiplier(player)
    local sweatMultiplier = activityMultiplier * thermalMultiplier * painMultiplier

    return sweatMultiplier    
end

function SweatController:GetTemperatureCategory(player)
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

function SweatController:TemperatureMultiplier(player)
    local temperatureCategory = self:GetTemperatureCategory(player)
    local tempMultiplier = 1.0
    if temperatureCategory == "TooHot" or temperatureCategory == "TooCold" then
        tempMultiplier = 2.0
    elseif temperatureCategory == "Hot" or temperatureCategory == "Cold" then
        tempMultiplier = 1.5
    end
    return tempMultiplier
end

function SweatController:DecaySweatLevel(player, deltaTime)
    local playerData = player:getModData()
    local activityMultiplier = self:sweatActivityMultiplier(player)
    local traitModifier = 0
    local baseDecay = 1.0
    local decayPenalty = (activityMultiplier) + (traitModifier)
    local decayRate = (baseDecay * (1 - activityMultiplier) * (1 + traitModifier))
    decayRate = math.max(0, decayRate) 
    return decayRate
end

function SweatController:ResetSweatAccumulated(player)
    local playerData = player:getModData()
    playerData.SweatAccumulated = 0
end

function SweatController:IsCarryingHeavyLoad(player)    
    local maxWeight = player:getMaxWeight()
    local currentWeight = player:getInventoryWeight()
    local weightRatio = currentWeight / maxWeight
    local multiplier = 1.0
        
    if weightRatio > 1.0 then
        multiplier = multiplier * 1.6 
    elseif weightRatio > 0.8 then
        multiplier = multiplier * 1.25
    end    
    return multiplier
end

function SweatController:SweatInterceptor(player)

end

_G.SweatController = SweatController
return SweatController
