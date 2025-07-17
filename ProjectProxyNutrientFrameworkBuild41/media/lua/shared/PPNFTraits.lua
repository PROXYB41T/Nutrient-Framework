local PPNFTraits = {}

function PPNFTraits:getTableHandler()
    return _G.TableHandler or nil
end

function PPNFTraits:Update(player, deltaTime)
    local playerData = player:getModData()
    if not self.tableHandlerDone then
        self.tableHandler = self:getTableHandler()
        self.tableHandlerDone = true
    elseif self.tableHandler then
        self:HasBlindness(player)
        self:HasNightBlindness(player)
        self:HasScurvy(player, deltaTime)
        self:HasMuscleCramps(player, deltaTime)
        self:HasHeartArrythmias(player, deltaTime)
        if not playerData.illnessCheck and playerData.nutrientList then
            self:HasCrohnsDisease(player, deltaTime)
            self:HasPancreatitis(player, deltaTime)
            self:HasCirrhosis(player, deltaTime)
            self:HasHyperthyroidism(player, deltaTime)
            self:HasHypothyroidism(player, deltaTime)
            self:HasPhenylketonuria(player, deltaTime)
            self:HasTropicalSprue(player, deltaTime)
            self:HasChronicKidneyDisease(player, deltaTime)
            self:HasHemochromatosis(player, deltaTime)
            playerData.illnessCheck = true
        end
    end
end

function PPNFTraits:RegisterCustomTraits()
    local allTraits = {
        {
            name = "Blindness",
            displayName = getText("UI_trait_Blindness"),
            cost = -8,
            description = getText("UI_trait_BlindnessDesc")
        },
        {
            name = "CrohnsDisease", 
            displayName = getText("UI_trait_CrohnsDisease"),
            cost = -6,
            description = getText("UI_trait_CrohnsDiseaseDesc")
        },
        {
            name = "Pancreatitis",
            displayName = getText("UI_trait_Pancreatitis"), 
            cost = -4,
            description = getText("UI_trait_PancreatitisDesc")
        },
        {
            name = "Cirrhosis",
            displayName = getText("UI_trait_Cirrhosis"),
            cost = -6,
            description = getText("UI_trait_CirrhosisDesc")
        },
        {
            name = "Hyperthyroidism",
            displayName = getText("UI_trait_Hyperthyroidism"),
            cost = -3,
            description = getText("UI_trait_HyperthyroidismDesc")
        },
        {
            name = "Hypothyroidism",
            displayName = getText("UI_trait_Hypothyroidism"),
            cost = -4,
            description = getText("UI_trait_HypothyroidismDesc")
        },
        {
            name = "Phenylketonuria",
            displayName = getText("UI_trait_Phenylketonuria"),
            cost = -4,
            description = getText("UI_trait_PhenylketonuriaDesc")
        },
        {
            name = "TropicalSprue",
            displayName = getText("UI_trait_TropicalSprue"),
            cost = -5,
            description = getText("UI_trait_TropicalSprueDesc")
        },
        {
            name = "ChronicKidneyDisease",
            displayName = getText("UI_trait_ChronicKidneyDisease"),
            cost = -6,
            description = getText("UI_trait_ChronicKidneyDiseaseDesc")
        },
        {
            name = "Hemochromatosis",
            displayName = getText("UI_trait_Hemochromatosis"), 
            cost = -5,
            description = getText("UI_trait_HemochromatosisDesc")
        },
        {
            name = "Scurvy",
            displayName = getText("DynamicScurvy"),
            cost = -2,
            description = getText("UI_trait_DynamicScurvyDesc")
        },
        {
            name = "MuscleCramps",
            displayName = getText("DynamicMuscleCramps"),
            cost = -1,
            description = getText("UI_trait_DynamicMuscleCrampsDesc")
        },
        {
            name = "HeartArrythmias",
            displayName = getText("DynamicHeartArrythmias"),
            cost = -3,
            description = getText("UI_trait_DynamicHeartArrythmiasDesc")
        },
        {
            name = "NightBlindness",
            displayName = getText("DynamicNightBlindness"),
            cost = -2,
            description = getText("UI_trait_DynamicNightBlindnessDesc")
        },
        {
            name = "Vegetarian",
            displayName = getText("UI_trait_Vegetarian"),
            cost = -1,
            description = getText("UI_trait_VegetarianDesc")
        },
        {
            name = "Vegan",
            displayName = getText("UI_trait_Vegan"),
            cost = -2,
            description = getText("UI_trait_VeganDesc")
        },
        {
            name = "Pescatarian",
            displayName = getText("UI_trait_Pescatarian"),
            cost = 0,
            description = getText("UI_trait_PescatarianDesc")
        },
        {
            name = "Kosher",
            displayName = getText("UI_trait_Kosher"),
            cost = -1,
            description = getText("UI_trait_KosherDesc")
        }
    }

    for _, trait in ipairs(allTraits) do
        TraitFactory.addTrait(
            trait.name,
            trait.displayName,
            trait.cost,
            trait.description,
            false, -- profession
            false  -- recipe
        )
    end
end

function PPNFTraits:HasBlindness(player)
    local modData = player:getModData()
    local hasBlindness = player:HasTrait("Blindness")
    
    if not hasBlindness then
        if modData.BlindnessActive then
            player:setHaloColor(0, 0, 0, 0)
            player:setHaloRadius(10)
            modData.BlindnessActive = false
        end
        return false
    end

    if not modData.BlindnessActive then
        player:setHaloColor(0, 0, 0, 0.95)
        player:setHaloRadius(25)
        modData.BlindnessActive = true
    end
    
    return true
end

function PPNFTraits:HasNightBlindness(player)
    local modData = player:getModData()

    if not player:HasTrait("NightBlindness") then
        if modData.NightBlindnessActive then
            player:setHaloColor(0, 0, 0, 0)
            player:setHaloRadius(10)
            modData.NightBlindnessActive = false
        end
        return false
    end

    local square = player:getCurrentSquare()
    if not square then return false end
    
    local lightLevel = square:getLightLevel(player:getPlayerNum())
    local alpha = 1 - math.min(1, math.max(0, lightLevel))
    local radius = 1 + math.floor((1 - math.min(1, math.max(0, lightLevel))) * 9)

    player:setHaloColor(0, 0, 0, alpha)
    player:setHaloRadius(radius)
    modData.NightBlindnessActive = true
    return true
end

function PPNFTraits:HasCrohnsDisease(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not player:HasTrait("CrohnsDisease") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.15
        playerData.nutrientList.VitaminB12 = playerData.nutrientList.VitaminB12 * 1.15
        playerData.nutrientList.VitaminB2 = playerData.nutrientList.VitaminB2 * 1.15
        playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.15
    end
    
    stats:setHunger(stats:getHunger() + (deltaTime * 1.25))
    stats:setEndurance(stats:getEndurance() - (deltaTime * 1.15))
    stats:setFatigue(stats:getFatigue() + (deltaTime * 1.15))
end

function PPNFTraits:HasPancreatitis(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not player:HasTrait("Pancreatitis") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Fats = playerData.nutrientList.Fats * 1.15
        playerData.nutrientList.VitaminK = playerData.nutrientList.VitaminK * 1.15
        playerData.nutrientList.Cholesterol = playerData.nutrientList.Cholesterol * 1.15
        playerData.nutrientList.ProteinPlus = playerData.nutrientList.ProteinPlus * 1.15
        playerData.nutrientList.VitaminA = playerData.nutrientList.VitaminA * 1.15
        playerData.nutrientList.VitaminD = playerData.nutrientList.VitaminD * 1.15
    end
    
    stats:setHunger(stats:getHunger() + (deltaTime * 1.2))
    stats:setEndurance(stats:getEndurance() - (deltaTime * 1.1))
    stats:setFatigue(stats:getFatigue() + (deltaTime * 1.1))
end

function PPNFTraits:HasCirrhosis(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    
    if not player:HasTrait("Cirrhosis") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.VitaminA = playerData.nutrientList.VitaminA * 1.20
        playerData.nutrientList.VitaminD = playerData.nutrientList.VitaminD * 1.20
        playerData.nutrientList.VitaminE = playerData.nutrientList.VitaminE * 1.20
        playerData.nutrientList.VitaminK = playerData.nutrientList.VitaminK * 1.20
        playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.20
        playerData.nutrientList.VitaminB12 = playerData.nutrientList.VitaminB12 * 1.20
        playerData.nutrientList.VitaminB9 = playerData.nutrientList.VitaminB9 * 1.20
    end

    stats:setFatigue(stats:getFatigue() + (deltaTime * 1.3))
    stats:setEndurance(stats:getEndurance() - (deltaTime * 1.2))
end

function PPNFTraits:HasHyperthyroidism(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    if not player:HasTrait("Hyperthyroidism") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Cals = playerData.nutrientList.Cals * 1.25
    end
    
    stats:setHunger(stats:getHunger() + (deltaTime * 1.5))
    bodyDamage:setTemperature(bodyDamage:getTemperature() + 1.0)
    stats:setFatigue(stats:getFatigue() + (deltaTime * 0.2))
    stats:setStress(stats:getStress() + (deltaTime * 0.25))
    stats:setPanic(stats:getPanic() + (deltaTime * 0.25))
end

function PPNFTraits:HasHypothyroidism(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    local bodyDamage = player:getBodyDamage()

    if not player:HasTrait("Hypothyroidism") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Cals = playerData.nutrientList.Cals * 0.75
    end
    
    bodyDamage:setTemperature(bodyDamage:getTemperature() - 1.0)
    stats:setFatigue(stats:getFatigue() + (deltaTime * 0.25))
    stats:setHunger(stats:getHunger() - (deltaTime * 0.25))
    stats:setUnhappyness(stats:getUnhappiness() + (deltaTime * 1.25))
    stats:setEndurance(stats:getEndurance() - (deltaTime * 0.15))
end

function PPNFTraits:HasPhenylketonuria(player, deltaTime)
    local playerData = player:getModData()

    if not player:HasTrait("Phenylketonuria") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Cals = playerData.nutrientList.Cals * 0.75
    end
end

function PPNFTraits:HasTropicalSprue(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    
    if not player:HasTrait("TropicalSprue") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.VitaminB9 = playerData.nutrientList.VitaminB9 * 1.5
        playerData.nutrientList.VitaminB12 = playerData.nutrientList.VitaminB12 * 1.5
        playerData.nutrientList.VitaminA = playerData.nutrientList.VitaminA * 1.5
        playerData.nutrientList.VitaminD = playerData.nutrientList.VitaminD * 1.5
        playerData.nutrientList.VitaminE = playerData.nutrientList.VitaminE * 1.5
        playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.5
        playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.5
    end
    
    stats:setFatigue(stats:getFatigue() + (deltaTime * 1.25))
    stats:setEndurance(stats:getEndurance() - (deltaTime * 1.15))
    stats:setHunger(stats:getHunger() + (deltaTime * 1.2))
end

function PPNFTraits:HasChronicKidneyDisease(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()
    
    if not player:HasTrait("ChronicKidneyDisease") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Potassium = playerData.nutrientList.Potassium * 1.3
        playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.4
        playerData.nutrientList.Phosphorus = playerData.nutrientList.Phosphorus * 1.4
        playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.4
    end
    
    stats:setFatigue(stats:getFatigue() + (deltaTime * 1.3))
    stats:setInfectionChance(stats:getInfectionChance() * 1.3)
    stats:setEndurance(stats:getEndurance() - (deltaTime * 1.2))
end

function PPNFTraits:HasHemochromatosis(player, deltaTime)
    local playerData = player:getModData()
    local stats = player:getStats()

    if not player:HasTrait("Hemochromatosis") then
        return false
    end

    if playerData.nutrientList then
        playerData.nutrientList.Iron = playerData.nutrientList.Iron * 1.6
        playerData.nutrientList.Calcium = playerData.nutrientList.Calcium * 1.2
        playerData.nutrientList.VitaminC = playerData.nutrientList.VitaminC * 1.3
    end
    
    stats:setFatigue(stats:getFatigue() + (deltaTime * 1.3))
    stats:setInfectionChance(stats:getInfectionChance() * 1.25)
    stats:setEndurance(stats:getEndurance() - (deltaTime * 1.15))
end

function PPNFTraits:CheckDietaryRestriction(player, food)
    local modData = player:getModData()
    local traitData = modData.TraitData or {}
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
    if traitData.Vegan then
        if isMeat or isSeafood or isDairy or isEgg then
            stats:setStress(stats:getStress() + 0.3)
            stats:setSadness(stats:getSadness() + 0.2)
            stats:setNausea(stats:getNausea() + 0.1)
            player:Say("Ugh, I ate something I shouldn't have...")
        end
    elseif traitData.Vegetarian then
        if isMeat or isSeafood then
            stats:setStress(stats:getStress() + 0.2)
            stats:setSadness(stats:getSadness() + 0.15)
            player:Say("I shouldn't have eaten that meat...")
        end
    elseif traitData.Pescatarian then
        if isMeat then -- Allow seafood but not meat
            stats:setStress(stats:getStress() + 0.2)
            stats:setSadness(stats:getSadness() + 0.15)
            player:Say("I only eat fish, not meat...")
        end
    end
    
    if traitData.Kosher then
        -- Simplified kosher check - no pork, no shellfish, no mixing meat/dairy
        local isPork = string.find(string.lower(itemName), "pork") or
                       string.find(string.lower(itemName), "ham") or
                       string.find(string.lower(itemName), "bacon")
        
        if isPork then
            stats:setStress(stats:getStress() + 0.2)
            stats:setSadness(stats:getSadness() + 0.15)
            player:Say("That wasn't kosher...")
            print("PPNF: Kosher player violated diet with " .. itemName)
        end
    end
end

function PPNFTraits:UpdateTraitDay(player)
    self:TraitStateChanger(player)
end

function PPNFTraits:TraitStateChanger(player)
    self:MentalTraits(player)
    self:HeartTraits(player)
    self:NightEyesTraits(player)
    self:BoneTraits(player)
    self:SkinTraits(player)
    self:HealingTraits(player)
    self:ImmuneTraits(player)
    self:MuscleTraits(player)
    self:ScurvyTraits(player)
end

function PPNFTraits:MentalTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
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
        "ProteinPlus", 
        "Fats", 
        "Carbs"
        }

    for _, nutrient in ipairs(MentalNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    elseif averageStage <= -52 then
        player:getTraits():add("Clumsy")
    end
end

function PPNFTraits:HeartTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0
    local HeartNutrients = {"Potassium", "Magnesium", "VitaminB1", "VitaminB6", "VitaminE"}

    for _, nutrient in ipairs(HeartNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    local EyeNutrients = {"VitaminA", "Zinc", "VitaminB2", "VitaminE"}

    for _, nutrient in ipairs(EyeNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    local BoneNutrients = {"VitaminC", "VitaminD", "Calcium", "Phosphorus", "Magnesium", "Zinc"}
    
    for _, nutrient in ipairs(BoneNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    local HealingNutrients = {"VitaminC", "ProteinPlus", "VitaminB2", "VitaminB6", "VitaminB5", "VitaminB12", "VitaminE"}
    
    for _, nutrient in ipairs(HealingNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    local ClottingNutrients = {"Iron", "VitaminB12", "VitaminB9", "VitaminB6", "VitaminC"}
    
    for _, nutrient in ipairs(ClottingNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    local ImmunityNutrients = {"VitaminA", "VitaminC", "VitaminD", "VitaminE", "VitaminB6", "VitaminB12"}
    
    for _, nutrient in ipairs(ImmunityNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    local MuscleNutrients = {"Potassium", "Magnesium", "Sodium", "VitaminB1", "VitaminB6", "VitaminB12", "VitaminD"}

    for _, nutrient in ipairs(MuscleNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        local sufficiencyStage = self.tableHandler.nutrientStages[nutrient].sufficiency or 0
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
    elseif averageStage <= -18 then
        player:getTraits():add("MuscleCramps")
    end
end

function PPNFTraits:ScurvyTraits(player)
    local totalDeficiencyStage = 0
    local totalSufficiencyStage = 0

    local ScurvyNutrients = {"VitaminC"}

    for _, nutrient in ipairs(ScurvyNutrients) do
        local deficiencyStage = self.tableHandler.nutrientStages[nutrient].deficiency or 0
        totalDeficiencyStage = totalDeficiencyStage + deficiencyStage
    end
    
    if totalDeficiencyStage >= 3 then
        player:getTraits():add("Scurvy")
    elseif totalDeficiencyStage < 3 then
        player:getTraits():remove("Scurvy")
    end
end

function PPNFTraits:HasMuscleCramps(player, deltaTime)
    local modData = player:getModData()
    local currentTime = getGameTime():getWorldAgeSeconds() 

    modData.MuscleCrampEndTime = modData.MuscleCrampEndTime or 0
    modData.NextMuscleCrampTime = modData.NextMuscleCrampTime or 0

    if player:HasTrait("MuscleCramps") then
        if modData.MuscleCrampEndTime > 0 and currentTime >= modData.MuscleCrampEndTime then
            modData.MuscleCrampPart = nil
            modData.MuscleCrampTime = nil
            modData.MuscleCrampEndTime = 0
            modData.NextMuscleCrampTime = currentTime + ZombRand(1, 181) 
        end

        if (not modData.MuscleCrampPart or modData.MuscleCrampEndTime == 0) and currentTime >= (modData.NextMuscleCrampTime or 0) then
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

                    modData.MuscleCrampPart = partIndex
                    modData.MuscleCrampTime = currentTime
                    modData.MuscleCrampEndTime = currentTime + ZombRand(30, 91)
                end
            end
        end
    else
        modData.MuscleCrampPart = nil
        modData.MuscleCrampTime = nil
        modData.MuscleCrampEndTime = 0
        modData.NextMuscleCrampTime = 0
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
    local modData = player:getModData()
    local currentTime = getGameTime():getWorldAgeSeconds()

    modData.ArrythmiaActive = modData.ArrythmiaActive or false
    modData.ArrythmiaDarknessStart = modData.ArrythmiaDarknessStart or 0
    modData.ArrythmiaDarknessEnd = modData.ArrythmiaDarknessEnd or 0
    modData.ArrythmiaFadeStart = modData.ArrythmiaFadeStart or 0
    modData.ArrythmiaMessageShown = modData.ArrythmiaMessageShown or false
    modData.NextArrythmiaTime = modData.NextArrythmiaTime or 0

    if player:HasTrait("HeartArrythmias") then
        if not modData.ArrythmiaActive and currentTime >= (modData.NextArrythmiaTime or 0) then
            modData.ArrythmiaActive = true
            modData.ArrythmiaDarknessStart = currentTime
            modData.ArrythmiaDarknessEnd = 0 
            modData.ArrythmiaFadeStart = 0
            modData.ArrythmiaMessageShown = false
        end

        if modData.ArrythmiaActive and modData.ArrythmiaDarknessEnd == 0 then
            player:setHaloColor(0, 0, 0, 0.95)
            player:setHaloRadius(2)
            if not modData.ArrythmiaMessageShown then
                player:Say("I think I need to sit down")
                modData.ArrythmiaMessageShown = true
            end
            if player:isSitOnGround() or player:isSeatedInVehicle() then
                modData.ArrythmiaDarknessEnd = currentTime + 60 
                modData.ArrythmiaFadeStart = currentTime
            end
        end

        if modData.ArrythmiaActive and modData.ArrythmiaDarknessEnd > 0 then
            local fadeProgress = math.min(1, (currentTime - modData.ArrythmiaFadeStart) / 60)
            local radius = 2 + fadeProgress * 8 
            local alpha = 0.95 - fadeProgress * 0.95 
            player:setHaloColor(0, 0, 0, math.max(0, alpha))
            player:setHaloRadius(math.min(10, radius))
            if currentTime >= modData.ArrythmiaDarknessEnd then
                player:setHaloColor(0, 0, 0, 0)
                player:setHaloRadius(10)
                modData.ArrythmiaActive = false
                modData.ArrythmiaDarknessStart = 0
                modData.ArrythmiaDarknessEnd = 0
                modData.ArrythmiaFadeStart = 0
                modData.ArrythmiaMessageShown = false
                modData.NextArrythmiaTime = currentTime + ZombRand(1, 1441) 
            end
        end
    else
        player:setHaloColor(0, 0, 0, 0)
        player:setHaloRadius(10)
        modData.ArrythmiaActive = false
        modData.ArrythmiaDarknessStart = 0
        modData.ArrythmiaDarknessEnd = 0
        modData.ArrythmiaFadeStart = 0
        modData.ArrythmiaMessageShown = false
        modData.NextArrythmiaTime = 0
    end
end

function PPNFTraits:HasScurvy(player)
    local modData = player:getModData()
    local hadScurvy = modData.hadScurvy or false
    local hasScurvy = player:HasTrait("Scurvy")
    
    if hasScurvy then
        self:StopWoundsHealing(player)
        self:RandomPains(player)
        self:RandomBoneBreaks(player)
        modData.hadScurvy = true
    else
        if hadScurvy then
            self:ResetWoundsHealing(player)
        end
        modData.hadScurvy = false
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
    local modData = player:getModData()
    if player:HasTrait("Pancreatitis") then
        modData.PancreatitisEatNauseaTime = getGameTime():getWorldAgeSeconds() + 15
        modData.PancreatitisEatNauseaEnd = nil
    end
end

_G.PPNFTraits = PPNFTraits

return PPNFTraits
