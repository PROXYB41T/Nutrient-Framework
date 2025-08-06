local PPNFTraits = {}
print("DEBUG: PPNFTraits.lua loaded")

function PPNFTraits:Initialize(player, tableHandler, deltaTime)
    print("DEBUG: Initialize called. tableHandler:", tableHandler, "self.tableHandler:", self.tableHandler, "player:", player, "deltaTime:", deltaTime)
    self.tableHandler = tableHandler
    
    if self.tableHandler then
        self:HasBlindness(player)
        self:HasNightBlindness(player)
        self:HasScurvy(player, deltaTime)
        self:HasMuscleCramps(player, deltaTime)
        self:HasHeartArrythmias(player, deltaTime)
        self:HasCrohnsDisease(player, deltaTime)
        self:HasPancreatitis(player, deltaTime)
        self:HasCirrhosis(player, deltaTime)
        self:HasHyperthyroidism(player, deltaTime)
        self:HasHypothyroidism(player, deltaTime)
        self:HasPhenylketonuria(player, deltaTime)
        self:HasTropicalSprue(player, deltaTime)
        self:HasChronicKidneyDisease(player, deltaTime)
        self:HasHemochromatosis(player, deltaTime)
        self:HasEpilepsy(player, deltaTime)
end

function PPNFTraits:Update(player, deltaTime)
    print("DEBUG: Update called. player:", player, "deltaTime:", deltaTime)
    self:HasMuscleCramps(player, deltaTime)
    self:HasHeartArrythmias(player, deltaTime)
    self:HasEpilepsy(player, deltaTime)
end

function PPNFTraits:HasBlindness(player)
    print("DEBUG: HasBlindness called. player:", player)
    local playerData = player:getModData()
    local hasBlindness = player:HasTrait("Blindness")
    
    if not hasBlindness then
        if playerData.BlindnessActive then
            -- Clear blindness effect
            playerData.BlindnessActive = false
        end
        return false
    end

    if not playerData.BlindnessActive then
        player:setHaloNote("Vision severely impaired", 0, 0, 0, 300)
        playerData.BlindnessActive = true
    end
    
    return true
end

function PPNFTraits:HasNightBlindness(player)
    print("DEBUG: HasNightBlindness called. player:", player)
    local playerData = player:getModData()

    if not player:HasTrait("NightBlindness") then
        if playerData.NightBlindnessActive then
            -- Clear night blindness effect
            playerData.NightBlindnessActive = false
        end
        return false
    end

    local square = player:getCurrentSquare()
    if not square then return false end
    
    local lightLevel = square:getLightLevel(player:getPlayerNum())
    
    if lightLevel < 0.5 and not playerData.NightBlindnessActive then
        player:setHaloNote("Difficulty seeing in darkness", 100, 100, 100, 200)
        playerData.NightBlindnessActive = true
    elseif lightLevel >= 0.5 and playerData.NightBlindnessActive then
        playerData.NightBlindnessActive = false
    end
    
    return true
end

function PPNFTraits:StatSaver(player)
    print("DEBUG: StatSaver called. player:", player)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not playerData.previousStress then
        playerData.previousStress = stats:getStress()
    end
    if not playerData.previousPanic then
        playerData.previousPanic = stats:getPanic()
    end
    if not playerData.previousFatigue then
        playerData.previousFatigue = stats:getFatigue()
    end
    if not playerData.previousHunger then
        playerData.previousHunger = stats:getHunger()
    end
    if not playerData.previousThirst then
        playerData.previousThirst = stats:getThirst()
    end
    if not playerData.previousUnhappiness then
        playerData.previousUnhappiness = stats:getUnhappiness()
    end
    if not playerData.previousBoredom then
        playerData.previousBoredom = stats:getBoredom()
    end
    if not playerData.previousEndurance then
        playerData.previousEndurance = stats:getEndurance()
    end
    if not playerData.previousTemperature then
        playerData.previousTemperature = player:getBodyDamage():getTemperature()
    end
    if not playerData.previousInfectionChance then
        playerData.previousInfectionChance = stats:getInfectionChance()
    end

    local currentStress = stats:getStress()
    local difference = currentStress - playerData.previousStress

    playerData.previousStress = currentStress
end

function PPNFTraits:StatDifferenceCalculator(player, deltaTime)
    print("DEBUG: StatDifferenceCalculator called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    -- Save previous stats
    self:StatSaver(player)

    local currentStress = stats:getStress()
    local currentPanic = stats:getPanic()
    local currentFatigue = stats:getFatigue()
    local currentHunger = stats:getHunger()
    local currentThirst = stats:getThirst()
    local currentUnhappiness = stats:getUnhappiness()
    local currentBoredom = stats:getBoredom()
    local currentEndurance = stats:getEndurance()
    local currentTemperature = player:getBodyDamage():getTemperature()
    local currentInfectionChance = stats:getInfectionChance()

    playerData.stressDifference = currentStress - playerData.previousStress
    playerData.panicDifference = currentPanic - playerData.previousPanic
    playerData.fatigueDifference = currentFatigue - playerData.previousFatigue
    playerData.hungerDifference = currentHunger - playerData.previousHunger
    playerData.thirstDifference = currentThirst - playerData.previousThirst
    playerData.unhappinessDifference = currentUnhappiness - playerData.previousUnhappiness
    playerData.boredomDifference = currentBoredom - playerData.previousBoredom
    playerData.enduranceDifference = currentEndurance - playerData.previousEndurance
    playerData.temperatureDifference = currentTemperature - playerData.previousTemperature
    playerData.infectionChanceDifference = currentInfectionChance - playerData.previousInfectionChance

    playerData.previousStress = currentStress
    playerData.previousPanic = currentPanic
    playerData.previousFatigue = currentFatigue
    playerData.previousHunger = currentHunger
    playerData.previousThirst = currentThirst
    playerData.previousUnhappiness = currentUnhappiness
    playerData.previousBoredom = currentBoredom
    playerData.previousEndurance = currentEndurance
    playerData.previousTemperature = currentTemperature
    playerData.previousInfectionChance = currentInfectionChance
end

function PPNFTraits:HasCrohnsDisease(player, deltaTime)
    print("DEBUG: HasCrohnsDisease called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not player:HasTrait("CrohnsDisease") then
        return false
    end

    playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.15
    playerData.nutrientList.VitaminB12 = playerData.nutrientList.VitaminB12 * 1.15
    playerData.nutrientList.VitaminB2 = playerData.nutrientList.VitaminB2 * 1.15
    playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.15
    
    if playerData.hungerDifference > 0 then
        stats:setHunger(stats:getHunger() + (playerData.hungerDifference * 1.25))
    end
    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.15))
    end
    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.15))
    end
    playerData.brainFog = true
end

function PPNFTraits:HasPancreatitis(player, deltaTime)
    print("DEBUG: HasPancreatitis called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not player:HasTrait("Pancreatitis") then
        return false
    end

    playerData.nutrientList.Lipids = playerData.nutrientList.Lipids * 1.15
    playerData.nutrientList.VitaminK = playerData.nutrientList.VitaminK * 1.15
    playerData.nutrientList.Cholesterol = playerData.nutrientList.Cholesterol * 1.15
    playerData.nutrientList.Protein = playerData.nutrientList.Protein * 1.15
    playerData.nutrientList.VitaminA = playerData.nutrientList.VitaminA * 1.15
    playerData.nutrientList.VitaminD = playerData.nutrientList.VitaminD * 1.15
    
    if playerData.hungerDifference > 0 then
        stats:setHunger(stats:getHunger() + (playerData.hungerDifference * 1.25))
    end
    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.15))
    end
    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.15))
    end
end

function PPNFTraits:HasCirrhosis(player, deltaTime)
    print("DEBUG: HasCirrhosis called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    
    if not player:HasTrait("Cirrhosis") then
        return false
    end

    playerData.nutrientList.VitaminA = playerData.nutrientList.VitaminA * 1.20
    playerData.nutrientList.VitaminD = playerData.nutrientList.VitaminD * 1.20
    playerData.nutrientList.VitaminE = playerData.nutrientList.VitaminE * 1.20
    playerData.nutrientList.VitaminK = playerData.nutrientList.VitaminK * 1.20
    playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.20
    playerData.nutrientList.VitaminB12 = playerData.nutrientList.VitaminB12 * 1.20
    playerData.nutrientList.VitaminB9 = playerData.nutrientList.VitaminB9 * 1.20

    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.3))
    end
    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.2))
    end
    playerData.brainFog = true

end

function PPNFTraits:HasHyperthyroidism(player, deltaTime)
    print("DEBUG: HasHyperthyroidism called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()
    
    if not player:HasTrait("Hyperthyroidism") then
        return false
    end
    
    playerData.nutrientList.Cals = playerData.nutrientList.Cals * 1.25
    if playerData.hungerDifference > 0 then
        stats:setHunger(stats:getHunger() + (playerData.hungerDifference * 1.5))
    end
    if playerData.temperatureDifference > 0 then
        bodyDamage:setTemperature(bodyDamage:getTemperature() + (playerData.temperatureDifference * 1.2))
    elseif playerData.temperatureDifference < 0 then
        bodyDamage:setTemperature(bodyDamage:getTemperature() + (playerData.temperatureDifference * 0.8))
    end
    if playerData.fatigueDifference > 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.fatigueDifference * 1.15))
    end
    if playerData.thirstDifference > 0 then
        stats:setThirst(stats:getThirst() + (playerData.thirstDifference * 1.5))
    end
    if playerData.stressDifference > 0 then
        stats:setStress(stats:getStress() + (playerData.stressDifference * 1.25))
    end
    if playerData.panicDifference > 0 then
        stats:setPanic(stats:getPanic() + (playerData.panicDifference * 1.25))
    end
    playerData.brainFog = true
end

function PPNFTraits:HasHypothyroidism(player, deltaTime)
    print("DEBUG: HasHypothyroidism called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    if not player:HasTrait("Hypothyroidism") then
        return false
    end

    playerData.nutrientList.Cals = playerData.nutrientList.Cals * 0.75

    if playerData.temperatureDifference > 0 then
        bodyDamage:setTemperature(bodyDamage:getTemperature() + (playerData.temperatureDifference * 0.8))
    elseif playerData.temperatureDifference < 0 then
        bodyDamage:setTemperature(bodyDamage:getTemperature() + (playerData.temperatureDifference * 1.2))
    end
    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.25))
    end
    if playerData.hungerDifference > 0 then
        stats:setHunger(stats:getHunger() + (playerData.hungerDifference * 1.25))
    end
    if playerData.thirstDifference > 0 then
        stats:setThirst(stats:getThirst() + (playerData.thirstDifference * 1.25))
    end
    if playerData.unhappinessDifference > 0 then
        stats:setUnhappyness(stats:getUnhappiness() + (playerData.unhappinessDifference * 1.25))
    end
    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.15))
    end

    playerData.brainFog = true
end

function PPNFTraits:HasPhenylketonuria(player, deltaTime)
    print("DEBUG: HasPhenylketonuria called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()

    if not player:HasTrait("Phenylketonuria") then
        return false
    end

    player:HasTrait("Seizures")
    player:HasTrait("AllThumbs")
    playerData.nutrientList.Cals = playerData.nutrientList.Cals * 0.75

    if playerData.unhappinessDifference > 0 then
        stats:setUnhappyness(stats:getUnhappiness() + (playerData.unhappinessDifference * 1.25))
    end
    if playerData.stressDifference > 0 then
        stats:setStress(stats:getStress() + (playerData.stressDifference * 1.25))
    end
    if playerData.panicDifference > 0 then
        stats:setPanic(stats:getPanic() + (playerData.panicDifference * 1.25))
    end
    playerData.brainFog = true

end

function PPNFTraits:HasTropicalSprue(player, deltaTime)
    print("DEBUG: HasTropicalSprue called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    local currentTime = getGameTime():getWorldAgeSeconds()
    
    if not player:HasTrait("TropicalSprue") then
        -- Clear timer data if trait is removed
        playerData.tropicalSprueStartTime = nil
        return false
    end

    -- Initialize start time when trait is first acquired
    if not playerData.tropicalSprueStartTime then
        playerData.tropicalSprueStartTime = currentTime
    end

    -- Check if 14 days have passed (14 * 24 * 60 * 60 = 1,209,600 seconds)
    local fourteenDaysInSeconds = 14 * 24 * 60 * 60
    if currentTime >= (playerData.tropicalSprueStartTime + fourteenDaysInSeconds) then
        -- Remove the trait after 14 days
        player:getTraits():remove("TropicalSprue")
        playerData.tropicalSprueStartTime = nil
        return false
    end

    playerData.nutrientList.VitaminB9 = playerData.nutrientList.VitaminB9 * 1.5
    playerData.nutrientList.VitaminB12 = playerData.nutrientList.VitaminB12 * 1.5
    playerData.nutrientList.VitaminA = playerData.nutrientList.VitaminA * 1.5
    playerData.nutrientList.VitaminD = playerData.nutrientList.VitaminD * 1.5
    playerData.nutrientList.VitaminE = playerData.nutrientList.VitaminE * 1.5
    playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.5
    playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.5

    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.25))
    end
    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.15))
    end
    if playerData.hungerDifference > 0 then
        stats:setHunger(stats:getHunger() + (playerData.hungerDifference * 1.2))
    end
    if playerData.thirstDifference > 0 then
        stats:setThirst(stats:getThirst() + (playerData.thirstDifference * 1.2))
    end
    playerData.brainFog = true

end

function PPNFTraits:HasChronicKidneyDisease(player, deltaTime)
    print("DEBUG: HasChronicKidneyDisease called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    
    if not player:HasTrait("ChronicKidneyDisease") then
        return false
    end

    playerData.nutrientList.Potassium = playerData.nutrientList.Potassium * 1.3
    playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.4
    playerData.nutrientList.Phosphorus = playerData.nutrientList.Phosphorus * 1.4
    playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.4
    
    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.3))
    end
    stats:setInfectionChance(stats:getInfectionChance() * 1.3)
    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.2))
    end
    playerData.brainFog = true
end

function PPNFTraits:HasHemochromatosis(player, deltaTime)
    print("DEBUG: HasHemochromatosis called. player:", player, "deltaTime:", deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not player:HasTrait("Hemochromatosis") then
        return false
    end

    playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.6
    playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.2
    playerData.nutrientList.VitaminC = playerData.nutrientList.VitaminC * 1.3
    
    if playerData.fatigueDifference > 0 then
        stats:setFatigue(stats:getFatigue() + (playerData.fatigueDifference * 1.3))
    end
    stats:setInfectionChance(stats:getInfectionChance() * 1.25)
    if playerData.enduranceDifference < 0 then
        stats:setEndurance(stats:getEndurance() + (playerData.enduranceDifference * 1.15))
    end
end

function PPNFTraits:CheckDietaryRestriction(player, food)
    print("DEBUG: CheckDietaryRestriction called. player:", player, "food:", food)
    local playerData = player:getModData()
    local stats = player:getStats()
    
    -- Get food type and check for diet violations
    local foodType = food:getFullType()
    local itemName = food:getDisplayName()
    
    -- Define food categories for dietary restrictions
    local isMeat = food:hasTag("Meat") or food:hasTag("Dead Animal") or 
                   string.find(string.lower(itemName), "meat") or
                   string.find(string.lower(itemName), "beef") or
                   string.find(string.lower(itemName), "chicken") or
                   string.find(string.lower(itemName), "pork") or
                   string.find(string.lower(itemName), "ham") or
                   string.find(string.lower(itemName), "bacon") or
                   string.find(string.lower(itemName), "sausage")
    
    local isSeafood = food:hasTag("Fish") or food:hasTag("Seafood") or
                      string.find(string.lower(itemName), "fish") or
                      string.find(string.lower(itemName), "salmon") or
                      string.find(string.lower(itemName), "tuna")
    
    local isDairy = food:hasTag("Dairy") or
                    string.find(string.lower(itemName), "milk") or
                    string.find(string.lower(itemName), "cheese") or
                    string.find(string.lower(itemName), "butter") or
                    string.find(string.lower(itemName), "cream") or
                    string.find(string.lower(itemName), "yogurt")
    
    local isEgg = food:hasTag("Egg") or
                  string.find(string.lower(itemName), "egg")
    
    -- Apply dietary restriction effects
    if player:HasTrait("Vegan") then
        if isMeat or isSeafood or isDairy or isEgg then
            stats:setStress(stats:getStress() + 0.3)
            stats:setSadness(stats:getSadness() + 0.2)
            stats:setNausea(stats:getNausea() + 0.1)
            player:Say("Ugh, I ate something I shouldn't have...")
        end
    elseif player:HasTrait("Vegetarian") then
        if isMeat or isSeafood then
            stats:setStress(stats:getStress() + 0.2)
            stats:setSadness(stats:getSadness() + 0.15)
            player:Say("I shouldn't have eaten that meat...")
        end
    elseif player:HasTrait("Pescatarian") then
        if isMeat then -- Allow seafood but not meat
            stats:setStress(stats:getStress() + 0.2)
            stats:setSadness(stats:getSadness() + 0.15)
            player:Say("I only eat fish, not meat...")
        end
    end

    if player:HasTrait("Kosher") then
        -- Simplified kosher check - no pork, no shellfish, no mixing meat/dairy
        local isPork = string.find(string.lower(itemName), "pork") or
                       string.find(string.lower(itemName), "ham") or
                       string.find(string.lower(itemName), "bacon")
        
        if isPork then
            stats:setStress(stats:getStress() + 0.2)
            stats:setSadness(stats:getSadness() + 0.15)
            player:Say("That wasn't kosher...")
        end
    end
end

function PPNFTraits:ResetDailyEffects(player)
    print("DEBUG: ResetDailyEffects called. player:", player)
    local playerData = player:getModData()
    
    -- Reset brain fog flag daily - will be recalculated by medical conditions
    playerData.brainFog = false
end

function PPNFTraits:UpdateTraitDay(player)
    print("DEBUG: UpdateTraitDay called. player:", player)
    self:ResetDailyEffects(player)
    self:TraitStateChanger(player)
end

function PPNFTraits:TraitStateChanger(player)
    print("DEBUG: TraitStateChanger called. player:", player)
    self:MentalTraits(player)
    self:HeartTraits(player)
    self:BoneTraits(player)
    self:SkinTraits(player)
    self:HealingTraits(player)
    self:ImmuneTraits(player)
    self:MuscleTraits(player)
    self:ScurvyTraits(player)
end

function PPNFTraits:MentalTraits(player)
    print("DEBUG: MentalTraits called. player:", player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local MentalNutrients = {
        "VitaminB1", 
        "VitaminB6", 
        "VitaminB9", 
        "VitaminB12", 
        "Magnesium", 
        "Zinc", 
        "Iron", 
        "VitaminD", 
        "VitaminC", 
        "VitaminE", 
        "Protein", 
        "Lipids", 
        "Carbohydrates"
        }

    for _, nutrient in ipairs(MentalNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 52 then
        player:getTraits():add("Graceful")
    elseif averageStage >= 39 and averageStage < 52 then
        player:getTraits():add("Dextrous")
        player:getTraits():remove("Graceful")
    elseif averageStage >= 26 and averageStage < 39 then
        player:getTraits():add("FastLearner")
        player:getTraits():remove("Dextrous")
    elseif averageStage >= 13 and averageStage < 26 then
        player:getTraits():add("Organized")
        player:getTraits():remove("FastLearner")
    elseif averageStage < 13 and averageStage >= 0 then
        player:getTraits():remove("Organized")
    elseif averageStage >= -13 and averageStage < 0 then
        player:getTraits():remove("Disorganized")
    elseif averageStage <= -13 and averageStage > -26 then
        player:getTraits():add("Disorganized")
        player:getTraits():remove("SlowLearner")
    elseif averageStage <= -26 and averageStage > -39 then
        player:getTraits():add("SlowLearner")
        player:getTraits():remove("Allthumbs")
    elseif averageStage <= -39 and averageStage > -52 then
        player:getTraits():add("Allthumbs")
        player:getTraits():remove("Clumsy")
    elseif averageStage <= -52 and averageStage > -65 then
        player:getTraits():add("Clumsy")
        player:getTraits():remove("Epilepsy")
    elseif averageStage <= -65 then
        player:getTraits():add("Epilepsy")
    end
end

function PPNFTraits:HeartTraits(player)
    print("DEBUG: HeartTraits called. player:", player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local HeartNutrients = {"Potassium", "Magnesium", "VitaminB1", "VitaminB6", "VitaminE"}

    for _, nutrient in ipairs(HeartNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end

    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 15 then
        player:getTraits():add("MarathonRunner")
    elseif averageStage >= 5 and averageStage < 15 then
        player:getTraits():add("Runner")
        player:getTraits():remove("MarathonRunner")
    elseif averageStage < 5 and averageStage >= 0 then
        player:getTraits():remove("Runner")
    elseif averageStage >= -5 and averageStage < 0 then
        player:getTraits():remove("Snorer")
    elseif averageStage <= -5 and averageStage > -15 then
        player:getTraits():add("Snorer")
        player:getTraits():remove("HeartArrythmias")
    elseif averageStage <= -15 then
        player:getTraits():add("HeartArrythmias")
    end
end

function PPNFTraits:EyesTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local EyeNutrients = {"VitaminA", "Zinc", "VitaminB2", "VitaminE"}

    for _, nutrient in ipairs(EyeNutrients) do
        local deficiencyStage = playerData.nutrientStages and playerData.nutrientStages[nutrient] and playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages and playerData.nutrientStages[nutrient] and playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 16 then
        player:getTraits():add("NightWalker")
    elseif averageStage >= 12 and averageStage < 16 then
        player:getTraits():add("CatsEyes")
        player:getTraits():remove("NightWalker")
    elseif averageStage >= 8 and averageStage < 12 then
        player:getTraits():add("EagleEyed")
        player:getTraits():remove("CatsEyes")
    elseif averageStage < 8 and averageStage >= 0 then
        player:getTraits():remove("EagleEyed")
    elseif averageStage >= -12 and averageStage < 0 then
        player:getTraits():remove("NightBlindness")
    elseif averageStage <= -12 and averageStage > -20 then
        player:getTraits():add("NightBlindness")
        player:getTraits():remove("Blindness")
    elseif averageStage <= -20 then
        player:getTraits():add("Blindness")
    end
end

function PPNFTraits:BoneTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local BoneNutrients = {"VitaminC", "VitaminD", "Calcium", "Phosphorus", "Magnesium", "Zinc"}
    
    for _, nutrient in ipairs(BoneNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 18 then
        player:getTraits():add("Hardy")
    elseif averageStage >= 6 and averageStage < 18 then
        player:getTraits():add("Strong")
        player:getTraits():remove("Hardy")
    elseif averageStage < 6 and averageStage >= 0 then
        player:getTraits():remove("Strong")
    elseif averageStage >= -6 and averageStage < 0 then
        player:getTraits():remove("Weak")
    elseif averageStage <= -6 and averageStage > -12 then
        player:getTraits():add("Weak")
        player:getTraits():remove("NoodleLegs")
    elseif averageStage <= -12 and averageStage > -18 then
        player:getTraits():add("NoodleLegs")
        player:getTraits():remove("SoreLegsTrait")
    elseif averageStage <= -18 then
        player:getTraits():add("SoreLegsTrait")
    end
end

function PPNFTraits:SkinTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local HealingNutrients = {"VitaminC", "Protein", "VitaminB2", "VitaminB6", "VitaminB5", "VitaminB12", "VitaminE"}
    
    for _, nutrient in ipairs(HealingNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end 
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 14 then
        player:getTraits():add("FastHealer")
    elseif averageStage >= 7 and averageStage < 14 then
        player:getTraits():add("ThickSkinned")
        player:getTraits():remove("FastHealer")
    elseif averageStage < 7 and averageStage >= 0 then
        player:getTraits():remove("ThickSkinned")
    elseif averageStage >= -7 and averageStage < 0 then
        player:getTraits():remove("ThinSkinned")
    elseif averageStage <= -7 and averageStage > -14 then
        player:getTraits():add("ThinSkinned")
        player:getTraits():remove("SlowHealer")
    elseif averageStage <= -14 then
        player:getTraits():add("SlowHealer")
    end
end

function PPNFTraits:HealingTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local ClottingNutrients = {"Iron", "VitaminB12", "VitaminB9", "VitaminB6", "VitaminC"}
    
    for _, nutrient in ipairs(ClottingNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 15 then
        player:getTraits():add("Resilient")
    elseif averageStage >= 10 and averageStage < 15 then
        player:getTraits():add("ThickBlood")
        player:getTraits():remove("Resilient")
    elseif averageStage < 10 and averageStage >= 0 then
        player:getTraits():remove("ThickBlood")
    elseif averageStage >= -10 and averageStage < 0 then
        player:getTraits():remove("ThinBlood")
    elseif averageStage <= -10 and averageStage > -15 then
        player:getTraits():add("ThinBlood")
        player:getTraits():remove("Anemic")
    elseif averageStage <= -15 then
        player:getTraits():add("Anemic")
    end
end

function PPNFTraits:ImmuneTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local ImmunityNutrients = {"VitaminA", "VitaminC", "VitaminD", "VitaminE", "VitaminB6", "VitaminB12"}
    
    for _, nutrient in ipairs(ImmunityNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 18 then
        player:getTraits():add("SuperImmune")
    elseif averageStage >= 12 and averageStage < 18 then
        player:getTraits():add("IronGut")
        player:getTraits():remove("SuperImmune")
    elseif averageStage < 12 and averageStage >= 0 then
        player:getTraits():remove("IronGut")
    elseif averageStage >= -12 and averageStage < 0 then
        player:getTraits():remove("WeakStomach")
    elseif averageStage <= -12 and averageStage > -18 then
        player:getTraits():add("WeakStomach")
        player:getTraits():remove("Immunocompromised")
    elseif averageStage <= -18 then
        player:getTraits():add("Immunocompromised")
    end
end

function PPNFTraits:MuscleTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()
    local MuscleNutrients = {"Potassium", "Magnesium", "Sodium", "VitaminB1", "VitaminB6", "VitaminB12", "VitaminD"}

    for _, nutrient in ipairs(MuscleNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = playerData.nutrientStages[nutrient].sufficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
        totalSufficiencyStage = totalSufficiencyStage + sufficiencyStage
    end
    
    local averageStage = totalSufficiencyStage - totalDeficiencyStage

    if averageStage >= 18 then
        player:getTraits():add("Stout")
    elseif averageStage >= 12 and averageStage < 18 then
        player:getTraits():add("Strongback")
        player:getTraits():remove("Stout")
    elseif averageStage < 12 and averageStage >= 0 then
        player:getTraits():remove("Strongback")
    elseif averageStage >= -12 and averageStage < 0 then
        player:getTraits():remove("WeakBack")
    elseif averageStage <= -12 and averageStage > -18 then
        player:getTraits():add("WeakBack")
        player:getTraits():remove("MuscleCramps")
    elseif averageStage <= -18 and averageStage > -24 then
        player:getTraits():add("MuscleCramps")
        player:getTraits():remove("Epilepsy")
    elseif averageStage <= -24 then
        player:getTraits():add("Epilepsy")
    end
end

function PPNFTraits:ScurvyTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local playerData = player:getModData()

    local ScurvyNutrients = {"VitaminC"}

    for _, nutrient in ipairs(ScurvyNutrients) do
        local deficiencyStage = playerData.nutrientStages[nutrient].deficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
    end
    
    if totalDeficiencyStage >= 3 then
        player:getTraits():add("Scurvy")
    elseif totalDeficiencyStage < 3 then
        player:getTraits():remove("Scurvy")
    end
end

function PPNFTraits:HasMuscleCramps(player, deltaTime)
    local playerData = player:getModData()
    local currentTime = getGameTime():getWorldAgeSeconds() 

    playerData.MuscleCrampEndTime = playerData.MuscleCrampEndTime or 0
    playerData.NextMuscleCrampTime = playerData.NextMuscleCrampTime or 0

    if player:HasTrait("MuscleCramps") then
        if playerData.MuscleCrampEndTime > 0 and currentTime >= playerData.MuscleCrampEndTime then
            playerData.MuscleCrampPart = nil
            playerData.MuscleCrampTime = nil
            playerData.MuscleCrampEndTime = 0
            playerData.NextMuscleCrampTime = currentTime + ZombRand(1, 181) 
        end

        if (not playerData.MuscleCrampPart or playerData.MuscleCrampEndTime == 0) and currentTime >= (playerData.NextMuscleCrampTime or 0) then
            local bodyDamage = player:getBodyDamage()
            if bodyDamage then
                local partIndex = ZombRand(BodyPartType.ToIndex(BodyPartType.MAX))
                local part = bodyDamage:getBodyPart(BodyPartType.FromIndex(partIndex))
                if part then
                    local painAmount = ZombRand(10, 25)
                    player:Say("Ouch! My " .. part:getType():toString() .. " is cramping!")
                    part:setPain(part:getPain() + painAmount)
                    self:GetQueuedActionName(player)
                    self:CheckQueuedActionPenalty(player)

                    playerData.MuscleCrampPart = partIndex
                    playerData.MuscleCrampTime = currentTime
                    playerData.MuscleCrampEndTime = currentTime + ZombRand(30, 91)
                end
            end
        end
    else
        playerData.MuscleCrampPart = nil
        playerData.MuscleCrampTime = nil
        playerData.MuscleCrampEndTime = 0
        playerData.NextMuscleCrampTime = 0
    end
end

function PPNFTraits:GetQueuedActionName(player)
    local queue = ISTimedActionQueue.getTimedActionQueue(player)
    if queue and #queue.queue > 0 then
        local action = queue.queue[1] 
        if action and action.Type then
            return action.Type 
        end
    end
    return nil
end

function PPNFTraits:CheckQueuedActionPenalty(player)
    print("DEBUG: line 881: self.tableHandler is", self.tableHandler)
    local penalty = 0.5
    local crampIndex = player:getModData().MuscleCrampPart
    if not crampIndex then return end
    local crampName = BodyPartType.FromIndex(crampIndex):toString()

    local actionName = self:GetQueuedActionName(player)
    if actionName and self.tableHandler.ActionBodyPartMap[actionName] then
        for _, part in ipairs(self.tableHandler.ActionBodyPartMap[actionName]) do
            if part == crampName then
                if self.maxTime and penalty then
                    self.maxTime = self.maxTime / penalty
                end
                return true
            end
        end
    end
end

function PPNFTraits:HasHeartArrythmias(player, deltaTime)
    local playerData = player:getModData()
    local currentTime = getGameTime():getWorldAgeSeconds()

    playerData.ArrythmiaActive = playerData.ArrythmiaActive or false
    playerData.ArrythmiaDarknessStart = playerData.ArrythmiaDarknessStart or 0
    playerData.ArrythmiaDarknessEnd = playerData.ArrythmiaDarknessEnd or 0
    playerData.ArrythmiaFadeStart = playerData.ArrythmiaFadeStart or 0
    playerData.ArrythmiaMessageShown = playerData.ArrythmiaMessageShown or false
    playerData.NextArrythmiaTime = playerData.NextArrythmiaTime or 0

    if player:HasTrait("HeartArrythmias") then
        if not playerData.ArrythmiaActive and currentTime >= (playerData.NextArrythmiaTime or 0) then
            playerData.ArrythmiaActive = true
            playerData.ArrythmiaDarknessStart = currentTime
            playerData.ArrythmiaDarknessEnd = 0
            playerData.ArrythmiaFadeStart = 0
            playerData.ArrythmiaMessageShown = false
        end

        if playerData.ArrythmiaActive and playerData.ArrythmiaDarknessEnd == 0 then
            player:setHaloNote("Heart palpitations affecting vision", 0, 0, 0, 120)
            if not playerData.ArrythmiaMessageShown then
                player:Say("I think I need to sit down")
                playerData.ArrythmiaMessageShown = true
            end
            if player:isSitOnGround() or player:isSeatedInVehicle() then
                playerData.ArrythmiaDarknessEnd = currentTime + 60
                playerData.ArrythmiaFadeStart = currentTime
            end
        end

        if playerData.ArrythmiaActive and playerData.ArrythmiaDarknessEnd > 0 then
            local fadeProgress = math.min(1, (currentTime - playerData.ArrythmiaFadeStart) / 60)
            local intensity = math.max(0, 0.95 - fadeProgress * 0.95)
            if intensity > 0 then
                player:setHaloNote("Heart palpitations fading", 0, 0, 0, 60)
            end
            if currentTime >= playerData.ArrythmiaDarknessEnd then
                playerData.ArrythmiaActive = false
                playerData.ArrythmiaDarknessStart = 0
                playerData.ArrythmiaDarknessEnd = 0
                playerData.ArrythmiaFadeStart = 0
                playerData.ArrythmiaMessageShown = false
                playerData.NextArrythmiaTime = currentTime + ZombRand(1, 1441)
            end
        end
    else
        playerData.ArrythmiaActive = false
        playerData.ArrythmiaDarknessStart = 0
        playerData.ArrythmiaDarknessEnd = 0
        playerData.ArrythmiaFadeStart = 0
        playerData.ArrythmiaMessageShown = false
        playerData.NextArrythmiaTime = 0
    end
    playerData.brainFog = true
end

function PPNFTraits:HasScurvy(player)
    local playerData = player:getModData()
    local hadScurvy = playerData.hadScurvy or false
    local hasScurvy = player:HasTrait("Scurvy")
    
    if hasScurvy then
        self:StopWoundsHealing(player)
        self:RandomPains(player)
        self:RandomBoneBreaks(player)
        playerData.hadScurvy = true
    else
        if hadScurvy then
            self:ResetWoundsHealing(player)
        end
        playerData.hadScurvy = false
    end
end

function PPNFTraits:ResetWoundsHealing(player)
    local bodyDamage = player:getBodyDamage()
    if bodyDamage then
        for i = 0, BodyPartType.ToIndex(BodyPartType.MAX) - 1 do
            local part = bodyDamage:getBodyPart(BodyPartType.FromIndex(i))
            if part then
                part:setHealingRate(1)
            end
        end
    end
end

function PPNFTraits:StopWoundsHealing(player)
    local bodyDamage = player:getBodyDamage()
    if bodyDamage then
        for i = 0, BodyPartType.ToIndex(BodyPartType.MAX) - 1 do
            local part = bodyDamage:getBodyPart(BodyPartType.FromIndex(i))
            if part and (part:isCut() or part:isScratched() or part:isBitten() or part:isDeepWounded()) then
                part:setHealingRate(0)
            end
        end
    end
end

function PPNFTraits:RandomPains(player)
    local bodyDamage = player:getBodyDamage()
    if bodyDamage then
        local part = bodyDamage:getBodyPart(BodyPartType.FromIndex(ZombRand(BodyPartType.ToIndex(BodyPartType.MAX))))
        if part then
            part:setPain(part:getPain() + ZombRand(5, 30))
        end
    end
end

function PPNFTraits:RandomBoneBreaks(player)
    if player:isPerformingAnAction() then
        local bodyDamage = player:getBodyDamage()
        if bodyDamage then
            local partIndex = ZombRand(BodyPartType.ToIndex(BodyPartType.MAX))
            local part = bodyDamage:getBodyPart(BodyPartType.FromIndex(partIndex))
            if part and not part:isFracture() then
                if ZombRand(1, 100) <= 15 then
                    part:setFractureTime(ZombRand(10, 30)) -- Random fracture duration in days
                    part:setFracture(true)
                end
            end
        end
    end
end

function PPNFTraits:OnPancreatitisEat(player)
    local playerData = player:getModData()
    if player:HasTrait("Pancreatitis") then
        playerData.PancreatitisEatNauseaTime = getGameTime():getWorldAgeSeconds() + 15
        playerData.PancreatitisEatNauseaEnd = nil
    end
end

function PPNFTraits:HasEpilepsy(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    local currentTime = getGameTime():getWorldAgeSeconds()
    
    if not player:HasTrait("Epilepsy") then
        return false
    end

    -- Initialize seizure data
    playerData.seizureStage = playerData.seizureStage or 0
    playerData.seizureStartTime = playerData.seizureStartTime or 0
    
    -- Calculate seizure interval based on comorbid conditions
    local baseSeizureInterval = ZombRand(600, 1800) -- 4-12 in-game hours (10-30 real minutes)
    local seizureMultiplier = 1.0
    
    -- Check for conditions that increase seizure frequency (decrease interval by 20%)
    if player:HasTrait("Hyperthyroidism") or player:HasTrait("TropicalSprue") or player:HasTrait("Hemochromatosis") then
        seizureMultiplier = 0.8 -- 20% decrease in time between seizures
    end
    
    playerData.nextSeizureTime = playerData.nextSeizureTime or (currentTime + math.floor(baseSeizureInterval * seizureMultiplier))
    playerData.auraMessageShown = playerData.auraMessageShown or false
    playerData.secondSeizureChance = playerData.secondSeizureChance or false
    playerData.seizureCollapseTriggered = playerData.seizureCollapseTriggered or false
    playerData.wasInjuredInFall = playerData.wasInjuredInFall or false

    -- Check if it's time for a seizure
    if playerData.seizureStage == 0 and currentTime >= playerData.nextSeizureTime then
        playerData.seizureStage = 1 -- Start aura phase
        playerData.seizureStartTime = currentTime
        playerData.auraMessageShown = false
    end

    -- Stage 1: Aura phase - rapid degradation of panic, stress, unhappiness
    if playerData.seizureStage == 1 then
        -- Rapidly decrease panic, stress, and unhappiness
        if stats:getPanic() > 0 then
            stats:setPanic(math.max(0, stats:getPanic() - (deltaTime * 8)))
        end
        if stats:getStress() > 0 then
            stats:setStress(math.max(0, stats:getStress() - (deltaTime * 6)))
        end
        if stats:getUnhappiness() > 0 then
            stats:setUnhappyness(math.max(0, stats:getUnhappiness() - (deltaTime * 4)))
        end

        -- Show aura message when stats hit zero
        if not playerData.auraMessageShown and stats:getPanic() == 0 and stats:getStress() == 0 and stats:getUnhappiness() == 0 then
            local auraMessages = {
                "Why does the sky feel... louder than usual?",
                "Is the floor... breathing? Nah, probably just stress.",
                "Who turned up the tinnitus?",
                "Either you're having a moment... or the apocalypse just got surround sound.",
                "Mmm... burnt wires and regret. Love that smell.",
                "Everything's a little... to the left now, huh?",
                "Déjà vu? Jamais vu? Vu vu zela?",
                "Okay, no one panic—but the shadows just blinked.",
                "I feel a sudden, inexplicable urge to lie down... on the floor... twitching.",
                "My brain just sent a group text to the rest of my body. And it autocorrected 'Help' to 'Party Time.'"
            }
            player:Say(auraMessages[ZombRand(1, #auraMessages + 1)])
            playerData.auraMessageShown = true
            playerData.seizureStartTime = currentTime -- Reset timer for 15 second delay
            playerData.seizureStage = 2 -- Move to pre-seizure delay
        end
    end

    -- Stage 2: 15 second delay before seizure
    if playerData.seizureStage == 2 then
        if currentTime >= (playerData.seizureStartTime + 15) then
            playerData.seizureStage = 3 -- Start actual seizure
            playerData.seizureStartTime = currentTime
        end
    end

    -- Stage 3: Active seizure
    if playerData.seizureStage == 3 then
        local seizureDuration = 30 + ZombRand(0, 61) -- 30-90 seconds
        local seizureProgress = currentTime - playerData.seizureStartTime

        if seizureProgress < seizureDuration then
            -- Visual effects during seizure
            local intensity = math.sin(seizureProgress * 8) * 0.3 + 0.3
            player:setHaloNote("Seizure in progress - visual disturbance", 255, 255, 255, 30)

            -- Force player to collapse with realistic fall animation
            if not playerData.seizureCollapseTriggered then
                -- Check if player is in a vulnerable position for injury
                local isVulnerable = not (player:isSitOnGround() or player:isSeatedInVehicle())
                
                -- Determine fall direction based on movement
                local fallDirection = "right" -- default
                
                if player:isPlayerMoving() or player:IsRunning() or player:isSprinting() then
                    -- Player is moving - use movement direction for fall
                    local forwardDir = player:getForwardDirection()
                    if forwardDir then
                        local angle = forwardDir:getDirection()
                        -- Convert angle to fall direction (simplified)
                        fallDirection = (angle > 0 and angle < math.pi) and "left" or "right"
                    end
                else
                    -- Player is stationary - random fall direction
                    fallDirection = ZombRand(2) == 0 and "left" or "right"
                end
                
                -- Create dramatic seizure collapse animation
                player:setBumpFallType("FallForward")
                player:setBumpType(fallDirection)
                player:setBumpDone(false)
                player:setBumpFall(true)
                player:reportEvent("wasBumped")
                
                -- Apply fall injuries if player was standing/moving
                if isVulnerable then
                    self:ApplySeizureFallInjuries(player)
                    playerData.wasInjuredInFall = true
                else
                    playerData.wasInjuredInFall = false
                end
                
                -- Set to lying position instead of sitting (more realistic for seizures)
                player:SetVariable("damnPosition", "lying")
                
                playerData.seizureCollapseTriggered = true
            end
            
            -- Prevent player from getting up during seizure
            if player:isSitOnGround() then
                player:SetVariable("damnPosition", "lying")
            end

            -- Damage over time during seizure
            if math.floor(seizureProgress) % 5 == 0 then -- Every 5 seconds
                local bodyDamage = player:getBodyDamage()
                if bodyDamage then
                    local partIndex = ZombRand(BodyPartType.ToIndex(BodyPartType.MAX))
                    local part = bodyDamage:getBodyPart(BodyPartType.FromIndex(partIndex))
                    if part then
                        part:setPain(part:getPain() + ZombRand(5, 15))
                    end
                end
            end
        else
            -- Seizure ends
            -- Reset lying position back to normal
            player:SetVariable("damnPosition", "standing")
            
            -- Post-seizure effects
            stats:setFatigue(math.min(1.0, stats:getFatigue() + 0.4))
            stats:setStress(math.min(1.0, stats:getStress() + 0.3))
            
            -- Check if player was injured during fall
            if playerData.wasInjuredInFall then
                player:Say("Ow... I think I hurt myself when I fell...")
            else
                player:Say("What... what happened?")
            end
            
            -- Schedule next seizure (4-12 in-game hours) with condition-based multiplier
            local baseSeizureInterval = ZombRand(600, 1800)
            local seizureMultiplier = 1.0
            
            -- Check for conditions that increase seizure frequency (decrease interval by 20%)
            if player:HasTrait("Hyperthyroidism") or player:HasTrait("TropicalSprue") or player:HasTrait("Hemochromatosis") then
                seizureMultiplier = 0.8 -- 20% decrease in time between seizures
            end
            
            playerData.nextSeizureTime = currentTime + math.floor(baseSeizureInterval * seizureMultiplier)
            
            -- Small chance of second seizure within 30 in-game minutes (also affected by conditions)
            if not playerData.secondSeizureChance and ZombRand(1, 100) <= 15 then
                local secondSeizureInterval = ZombRand(12, 75) -- 5-30 in-game minutes (12-75 real seconds)
                playerData.nextSeizureTime = currentTime + math.floor(secondSeizureInterval * seizureMultiplier)
                playerData.secondSeizureChance = true
            else
                playerData.secondSeizureChance = false
            end
            
            playerData.seizureStage = 0
            playerData.seizureStartTime = 0
            playerData.auraMessageShown = false
            playerData.seizureCollapseTriggered = false
            playerData.wasInjuredInFall = false
        end
    end
    playerData.brainFog = true
    return true
end

function PPNFTraits:ApplySeizureFallInjuries(player)
    local bodyDamage = player:getBodyDamage()
    if not bodyDamage then return end
    
    -- Check what the player is falling into to adjust injury chances
    local injuryMultiplier = self:CalculateFallInjuryMultiplier(player)
    
    -- Define injury chances and body parts most likely to be injured in a fall
    local fallInjuryChances = {
        -- Head injuries from hitting ground
        [BodyPartType.Head] = {chance = math.floor(12 * injuryMultiplier), types = {"scratch", "cut"}}, -- Was 25, now 12
        -- Hands/arms from trying to break fall
        [BodyPartType.Hand_L] = {chance = math.floor(17 * injuryMultiplier), types = {"scratch", "cut"}}, -- Was 35, now 17
        [BodyPartType.Hand_R] = {chance = math.floor(17 * injuryMultiplier), types = {"scratch", "cut"}}, -- Was 35, now 17
        [BodyPartType.ForeArm_L] = {chance = math.floor(15 * injuryMultiplier), types = {"scratch", "cut"}}, -- Was 30, now 15
        [BodyPartType.ForeArm_R] = {chance = math.floor(15 * injuryMultiplier), types = {"scratch", "cut"}}, -- Was 30, now 15
        -- Knees from hitting ground
        [BodyPartType.UpperLeg_L] = {chance = math.floor(10 * injuryMultiplier), types = {"scratch"}}, -- Was 20, now 10
        [BodyPartType.UpperLeg_R] = {chance = math.floor(10 * injuryMultiplier), types = {"scratch"}}, -- Was 20, now 10
        -- Torso if severe fall
        [BodyPartType.Torso_Upper] = {chance = math.floor(7 * injuryMultiplier), types = {"scratch", "cut"}}, -- Was 15, now 7
    }
    
    -- Apply injuries based on chance
    for bodyPartType, injuryData in pairs(fallInjuryChances) do
        if ZombRand(1, 101) <= injuryData.chance then
            local bodyPart = bodyDamage:getBodyPart(bodyPartType)
            if bodyPart then
                -- Select random injury type
                local injuryType = injuryData.types[ZombRand(1, #injuryData.types + 1)]
                
                if injuryType == "scratch" then
                    bodyPart:setScratched(true, true)
                    bodyPart:AddDamage(ZombRand(3, 8)) -- Light damage
                    bodyPart:setPain(bodyPart:getPain() + ZombRand(5, 15))
                elseif injuryType == "cut" then
                    bodyPart:setCut(true)
                    bodyPart:AddDamage(ZombRand(8, 15)) -- Moderate damage
                    bodyPart:setPain(bodyPart:getPain() + ZombRand(10, 25))
                    -- Small chance of bleeding
                    if ZombRand(1, 101) <= 30 then
                        bodyPart:setBleeding(true)
                    end
                end
            end
        end
    end
    
    -- Additional pain from impact (also affected by what they hit)
    local generalPain = math.floor(ZombRand(5, 20) * injuryMultiplier)
    local stats = player:getStats()
    stats:setPain(math.min(100, stats:getPain() + generalPain))
    
    -- Brief unconsciousness simulation with vision effect
    player:setHaloNote("Momentarily unconscious from fall", 0, 0, 0, 90)
end

function PPNFTraits:CalculateFallInjuryMultiplier(player)
    local playerSquare = player:getCurrentSquare()
    if not playerSquare then return 1.0 end -- Default multiplier if we can't get square
    
    local x = playerSquare:getX()
    local y = playerSquare:getY()
    local z = playerSquare:getZ()
    
    -- Check the current square and adjacent squares for objects
    local squaresToCheck = {
        playerSquare, -- Current square
        getCell():getGridSquare(x + 1, y, z), -- East
        getCell():getGridSquare(x - 1, y, z), -- West  
        getCell():getGridSquare(x, y + 1, z), -- South
        getCell():getGridSquare(x, y - 1, z), -- North
    }
    
    local bestMultiplier = 1.0 -- Default for empty floor
    local foundObjects = false
    
    for _, square in ipairs(squaresToCheck) do
        if square then
            local objects = square:getObjects()
            if objects and objects:size() > 0 then
                foundObjects = true
                for i = 0, objects:size() - 1 do
                    local obj = objects:get(i)
                    if obj and obj:getSprite() and obj:getSprite():getName() then
                        local spriteName = string.lower(obj:getSprite():getName())
                        
                        -- Very soft landing surfaces (least injury)
                        if string.find(spriteName, "bed") or 
                           string.find(spriteName, "mattress") or
                           string.find(spriteName, "pillow") then
                            bestMultiplier = math.min(bestMultiplier, 0.2) -- 80% less injury chance
                            
                        -- Soft seating (low injury)
                        elseif string.find(spriteName, "sofa") or 
                               string.find(spriteName, "couch") or
                               string.find(spriteName, "armchair") then
                            bestMultiplier = math.min(bestMultiplier, 0.4) -- 60% less injury chance
                            
                        -- Regular chairs (moderate protection)
                        elseif string.find(spriteName, "chair") or
                               string.find(spriteName, "stool") then
                            bestMultiplier = math.min(bestMultiplier, 0.7) -- 30% less injury chance
                            
                        -- Hard surfaces (increased injury)
                        elseif string.find(spriteName, "table") or
                               string.find(spriteName, "desk") or
                               string.find(spriteName, "counter") or
                               string.find(spriteName, "cabinet") or
                               string.find(spriteName, "dresser") or
                               string.find(spriteName, "shelf") then
                            bestMultiplier = math.max(bestMultiplier, 1.5) -- 50% more injury chance
                            
                        -- Very dangerous objects (high injury)
                        elseif string.find(spriteName, "glass") or
                               string.find(spriteName, "window") or
                               string.find(spriteName, "mirror") or
                               string.find(spriteName, "stove") or
                               string.find(spriteName, "oven") then
                            bestMultiplier = math.max(bestMultiplier, 1.8) -- 80% more injury chance
                        end
                    end
                end
            end
        end
    end
    
    -- If no harmful objects found, falling on relatively safe floor
    if not foundObjects then
        return 0.9 -- 10% less injury chance for open space
    end
    
    return bestMultiplier
end
end

function PPNFTraits:HasBrainFog(player, perk, amount)
    local playerData = player:getModData()
    if not playerData.brainFog then
        return
    end
    local reduction = amount * 0.5
    player:getXp():AddXP(perk, -reduction, false, false, false)
end

_G.PPNFTraits = PPNFTraits

return PPNFTraits
