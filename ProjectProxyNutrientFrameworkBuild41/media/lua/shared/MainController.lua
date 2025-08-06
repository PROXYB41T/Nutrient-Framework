
local MainController = {}

local NutritionController = nil
local SweatController = nil
local PPNFTraits = nil
local tableHandler = nil

function MainController:initTableHandler()
    if self.tableHandler then
        return
    end
    self.tableHandler = require("TableHandler")
    tableHandler = self.tableHandler
end

function MainController:registerTraits()
    TraitFactory.addTrait("Blindness", getText("UI_trait_Blindness"), -8, getText("UI_trait_BlindnessDesc"), false)
    TraitFactory.addTrait("CrohnsDisease", getText("UI_trait_CrohnsDisease"), -6, getText("UI_trait_CrohnsDiseaseDesc"), false)
    TraitFactory.addTrait("Pancreatitis", getText("UI_trait_Pancreatitis"), -4, getText("UI_trait_PancreatitisDesc"), false)
    TraitFactory.addTrait("Cirrhosis", getText("UI_trait_Cirrhosis"), -6, getText("UI_trait_CirrhosisDesc"), false)
    TraitFactory.addTrait("Hyperthyroidism", getText("UI_trait_Hyperthyroidism"), -3, getText("UI_trait_HyperthyroidismDesc"), false)
    TraitFactory.addTrait("Hypothyroidism", getText("UI_trait_Hypothyroidism"), -4, getText("UI_trait_HypothyroidismDesc"), false)
    TraitFactory.addTrait("Phenylketonuria", getText("UI_trait_Phenylketonuria"), -20, getText("UI_trait_PhenylketonuriaDesc"), false)
    TraitFactory.addTrait("TropicalSprue", getText("UI_trait_TropicalSprue"), -5, getText("UI_trait_TropicalSprueDesc"), false)
    TraitFactory.addTrait("ChronicKidneyDisease", getText("UI_trait_ChronicKidneyDisease"), -6, getText("UI_trait_ChronicKidneyDiseaseDesc"), false)
    TraitFactory.addTrait("Hemochromatosis", getText("UI_trait_Hemochromatosis"), -5, getText("UI_trait_HemochromatosisDesc"), false)
    TraitFactory.addTrait("Scurvy", getText("UI_trait_Scurvy"), -2, getText("UI_trait_ScurvyDesc"), false)
    TraitFactory.addTrait("MuscleCramps", getText("UI_trait_MuscleCramps"), -1, getText("UI_trait_MuscleCrampsDesc"), false)
    TraitFactory.addTrait("HeartArrythmias", getText("UI_trait_HeartArrythmias"), -3, getText("UI_trait_HeartArrythmiasDesc"), false)
    TraitFactory.addTrait("NightBlindness", getText("UI_trait_NightBlindness"), -2, getText("UI_trait_NightBlindnessDesc"), false)
    TraitFactory.addTrait("Vegetarian", getText("UI_trait_Vegetarian"), -4, getText("UI_trait_VegetarianDesc"), false)
    TraitFactory.addTrait("Vegan", getText("UI_trait_Vegan"), -4, getText("UI_trait_VeganDesc"), false)
    TraitFactory.addTrait("Pescatarian", getText("UI_trait_Pescatarian"), -4, getText("UI_trait_PescatarianDesc"), false)
    TraitFactory.addTrait("Kosher", getText("UI_trait_Kosher"), -4, getText("UI_trait_KosherDesc"), false)
end

function MainController:Update(player)
    local currentHour =getGameTime()
    local initDone = false
    if player and initDone then
            if not NutritionController then
                NutritionController = require("NutritionController")
            end
            if not PPNFTraits then
                PPNFTraits = require("PPNFTraits")
            end
        NutritionController:Initialize(player, tableHandler)
        PPNFTraits:Initialize(player, tableHandler, deltaTime)
        initDone = true
    elseif not player then
        return
    end
    if not SweatController then
        SweatController = require("SweatController")
    end
    local deltaTime = getGameTime():getMultiplier()
    SweatController:Update(player, deltaTime)
    NutritionController:Update(player, deltaTime)
    NutritionController:OnPlayerUpdate(player)
    PPNFTraits:Update(player, deltaTime)
    self:IsEating(player)
end

function MainController:onFoodConsumption(player, item)
    NutritionController:OnConsume(player, item)
    PPNFTraits:OnPancreatitisEat(player)
end

function MainController:onDailyReset()
    if not NutritionController then
        NutritionController = require("NutritionController")
    end
    if not PPNFTraits then
        PPNFTraits = require("PPNFTraits")
    end
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            NutritionController:NutrientReset(player)
            PPNFTraits:UpdateTraitDay(player)
        end
    end
end

function MainController:onRecipeCrafting(result, ingredients, player)
    NutritionController:ResetRecipeIngredients(result, ingredients, player)
end

-- NOTE: Brain fog XP reduction feature disabled - no official OnXPGain event exists
-- function MainController:onXPGain(player, perk, amount)
--     PPNFTraits:HasBrainFog(player, perk, amount)
-- end

function MainController:onCharacterDeath(player)
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player then
            local playerData = player:getModData()
            if playerData then
                for key, _ in pairs(playerData) do
                    playerData[key] = nil
                end
            end
        end
    end
end

function MainController:isEating(player)
    local queue = ISTimedActionQueue.getTimedActionQueue(player)
    local currentAction = queue and #queue.queue > 0 and queue.queue[1]
    local currentlyEating = currentAction and currentAction.Type == "ISEatFoodAction"
    local currentlyCrafting = currentAction and currentAction.Type == "ISCraftAction"
    local playerData = player:getModData()
    local wasEating = playerData.PPNFWasEating or false
    local wasCrafting = playerData.PPNFWasCrafting or false
    if wasEating and not currentlyEating then
        local lastEatenItem = playerData.PPNFLastEatenItem
        if lastEatenItem then
            NutritionController:OnConsume(player, lastEatenItem)
            PPNFTraits:OnPancreatitisEat(player)
        end
    end
    if wasCrafting and not currentlyCrafting then
        local lastCraftedRecipe = playerData.PPNFLastCraftedRecipe
        local lastCraftedItem = playerData.PPNFLastCraftedItem
        if lastCraftedRecipe and lastCraftedItem then
            local results = lastCraftedRecipe:getResult()
            if results and results:size() > 0 then
                local resultItem = results:get(0)
                if resultItem:getType() == "Food" then
                    MainController:onRecipeCrafting(lastCraftedRecipe, lastCraftedItem, player)
                end
            end
        end
    end
    playerData.PPNFWasEating = currentlyEating
    if currentlyEating then
        playerData.PPNFLastEatenItem = currentAction.item
    end
    playerData.PPNFWasCrafting = currentlyCrafting
    if currentlyCrafting then
        playerData.PPNFLastCraftedRecipe = currentAction.recipe
        playerData.PPNFLastCraftedItem = currentAction.item
    end
end

Events.OnGameBoot.Add(MainController:initTableHandler())
Events.OnCreateLivingCharacter.Add(MainController:registerTraits())
Events.EveryDays.Add(MainController:onDailyReset())
Events.OnCharacterDeath.Add(MainController:onCharacterDeath())
Events.OnPlayerUpdate.Add(MainController:Update())

return MainController
