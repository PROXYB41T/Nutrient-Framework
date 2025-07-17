local MainController = {}

_G.MainController = MainController
local TableHandler = require("TableHandler")
_G.TableHandler = TableHandler
local NutritionController = require("NutritionController")
_G.NutritionController = NutritionController
local SweatController = require("SweatController")
_G.SweatController = SweatController
local PPNFTraits = require("PPNFTraits")
_G.PPNFTraits = PPNFTraits

Events.OnPlayerUpdate.Add(MainController.PlayerUpdate)
Events.OnCreatePlayer.Add(MainController.PlayerInitialization)
Events.OnEat.Add(MainController.FoodConsumption)
Events.EveryDays.Add(MainController.DailyReset)
Events.OnCharacterDeath.Add(MainController.Cleanup)
Events.OnRecipeCrafted.Add(MainController.RecipeCrafting)
Events.LevelPerk.Add(MainController.SkillLevelGain)

function MainController:RecipeCrafting(result, ingredients, player)
    NutritionController:ResetRecipeIngredients(result, ingredients, player)
end

function MainController:SkillLevelGain(player, foodItem, perk)
    NutritionController:SkillLevelGain(player, foodItem, perk)
end

function MainController:PlayerUpdate(player)
    local deltaTime = getGameTime():getMultiplier()
    
    SweatController:Update(player, deltaTime)
    NutritionController:Update(player, deltaTime)
end

function MainController:FoodConsumption(player, item)
    NutritionController:OnConsume(player, item)
end

function MainController:ScheduleDailyReset(player)
    NutritionController:NutrientReset(player)
    PPNFTraits:UpdateTraitDay(player)
end

function MainController:RecipeCrafting(result, ingredients, player)
    NutritionController:ResetRecipeIngredients(result, ingredients, player)
end

function MainController:SchedulePlayerCleanup(player)
    NutritionController:PlayerDeath(player)
end

_G.MainController = MainController

return MainController
