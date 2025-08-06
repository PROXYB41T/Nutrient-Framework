-- PPNF Tooltip Handler
-- Provides custom food tooltips using PPNF nutrition data

require "PPNFNutritionGetters"

local PPNFTooltip = {}

function PPNFTooltip.customFoodTooltip(player, food, tooltip)
    playerData = player:getModData()
    
    -- Store the food item for the nutrition panel to use
    playerData.hoveredFoodItem = food
    
    local font = tooltip:getFont()
    local lineHeight = tooltip:getLineSpacing()
    local y = 5
    
    -- Draw item name first
    tooltip:DrawText(font, food:getName(), 5, y, 1, 1, 0.8, 1)
    y = y + lineHeight + 5
    
    -- Add base game food effects first (most important info)
    -- Hunger change
    local hungerChange = food:getHungerChange()
    if hungerChange ~= 0 then
        local hungerText = hungerChange > 0 and "+" .. hungerChange or tostring(hungerChange)
        tooltip:DrawText(font, "Hunger: " .. hungerText, 5, y, 0.7, 0.7, 0.7, 1)
        y = y + lineHeight
    end
    
    -- Thirst change
    local thirstChange = food:getThirstChange()
    if thirstChange ~= 0 then
        local thirstText = thirstChange > 0 and "+" .. thirstChange or tostring(thirstChange)
        tooltip:DrawText(font, "Thirst: " .. thirstText, 5, y, 0.7, 0.7, 0.7, 1)
        y = y + lineHeight
    end
    
    -- Unhappiness change
    local unhappyChange = food:getUnhappyChange()
    if unhappyChange ~= 0 then
        local unhappyText = unhappyChange > 0 and "+" .. unhappyChange or tostring(unhappyChange)
        tooltip:DrawText(font, "Unhappiness: " .. unhappyText, 5, y, 0.7, 0.7, 0.7, 1)
        y = y + lineHeight
    end
    
    -- Boredom change
    local boredomChange = food:getBoredomChange()
    if boredomChange ~= 0 then
        local boredomText = boredomChange > 0 and "+" .. boredomChange or tostring(boredomChange)
        tooltip:DrawText(font, "Boredom: " .. boredomText, 5, y, 0.7, 0.7, 0.7, 1)
        y = y + lineHeight
    end
    
    -- Weight
    local weight = food:getWeight()
    tooltip:DrawText(font, "Weight: " .. string.format("%.2f", weight), 5, y, 0.6, 0.6, 0.6, 1)
    y = y + lineHeight + 5
    if not playerData.nutritionPanelOpen then
    local player = getPlayer()
    local cookingLevel = player:getPerkLevel(Perks.Cooking)
    local hasNutritionist = player:HasTrait("Nutritionist")
    local nutrients = PPNFTooltip.getNutrientsForKnowledgeLevel(cookingLevel, hasNutritionist)
        for _, nutrient in ipairs(nutrients) do
            local value = nil
            
            if nutrient.getter == "getCals" then
                value = Food:getCals(food)
            elseif nutrient.getter == "getCarbs" then
                value = Food:getCarbs(food)
            elseif nutrient.getter == "getProteinPlus" then
                value = Food:getProteinPlus(food)
            elseif nutrient.getter == "getFats" then
                value = Food:getFats(food)
            elseif nutrient.getter == "getCholesterol" then
                value = Food:getCholesterol(food)
            elseif nutrient.getter == "getSodium" then
                value = Food:getSodium(food)
            elseif nutrient.getter == "getMagnesium" then
                value = Food:getMagnesium(food)
            elseif nutrient.getter == "getPotassium" then
                value = Food:getPotassium(food)
            elseif nutrient.getter == "getVitaminA" then
                value = Food:getVitaminA(food)
            elseif nutrient.getter == "getVitaminD" then
                value = Food:getVitaminD(food)
            elseif nutrient.getter == "getVitaminE" then
                value = Food:getVitaminE(food)
            elseif nutrient.getter == "getVitaminK" then
                value = Food:getVitaminK(food)
            elseif nutrient.getter == "getVitaminC" then
                value = Food:getVitaminC(food)
            elseif nutrient.getter == "getVitaminB1" then
                value = Food:getVitaminB1(food)
            elseif nutrient.getter == "getVitaminB2" then
                value = Food:getVitaminB2(food)
            elseif nutrient.getter == "getVitaminB3" then
                value = Food:getVitaminB3(food)
            elseif nutrient.getter == "getVitaminB5" then
                value = Food:getVitaminB5(food)
            elseif nutrient.getter == "getVitaminB6" then
                value = Food:getVitaminB6(food)
            elseif nutrient.getter == "getVitaminB9" then
                value = Food:getVitaminB9(food)
            elseif nutrient.getter == "getVitaminB12" then
                value = Food:getVitaminB12(food)
            elseif nutrient.getter == "getCalcium" then
                value = Food:getCalcium(food)
            elseif nutrient.getter == "getPhosphorus" then
                value = Food:getPhosphorus(food)
            elseif nutrient.getter == "getIron" then
                value = Food:getIron(food)
            elseif nutrient.getter == "getZinc" then
                value = Food:getZinc(food)
            end
            
            if value then
                tooltip:DrawText(font, nutrient.label .. ": " .. value, 5, y, 0.8, 0.8, 0.8, 1)
                y = y + lineHeight
            end
        end
    end
end

function PPNFTooltip.getNutrientsForKnowledgeLevel(cookingLevel, hasNutritionist)
    if hasNutritionist or cookingLevel >= 10 then
        return {
            {getter = "getCals", label = "Calories"},
            {getter = "getCarbs", label = "Carbs"},
            {getter = "getProteinPlus", label = "Protein"},
            {getter = "getFats", label = "Fats"},
            {getter = "getCholesterol", label = "Cholesterol"},
            {getter = "getSodium", label = "Sodium"},
            {getter = "getVitaminA", label = "Vitamin A"},
            {getter = "getVitaminD", label = "Vitamin D"},
            {getter = "getVitaminE", label = "Vitamin E"},
            {getter = "getVitaminK", label = "Vitamin K"},
            {getter = "getVitaminC", label = "Vitamin C"},
            {getter = "getVitaminB1", label = "Vitamin B1"},
            {getter = "getVitaminB2", label = "Vitamin B2"},
            {getter = "getVitaminB3", label = "Vitamin B3"},
            {getter = "getVitaminB5", label = "Vitamin B5"},
            {getter = "getVitaminB6", label = "Vitamin B6"},
            {getter = "getVitaminB9", label = "Vitamin B9"},
            {getter = "getVitaminB12", label = "Vitamin B12"},
            {getter = "getMagnesium", label = "Magnesium"},
            {getter = "getPotassium", label = "Potassium"},
            {getter = "getCalcium", label = "Calcium"},
            {getter = "getPhosphorus", label = "Phosphorus"},
            {getter = "getIron", label = "Iron"},
            {getter = "getZinc", label = "Zinc"},
        }
    elseif cookingLevel >= 6 then
        -- Show basic nutrients + main vitamins and minerals
        return {
            {getter = "getCals", label = "Calories"},
            {getter = "getCarbs", label = "Carbs"},
            {getter = "getProteinPlus", label = "Protein"},
            {getter = "getFats", label = "Fats"},
            {getter = "getVitaminA", label = "Vitamin A"},
            {getter = "getVitaminC", label = "Vitamin C"},
            {getter = "getVitaminD", label = "Vitamin D"},
            {getter = "getCalcium", label = "Calcium"},
            {getter = "getIron", label = "Iron"},
        }
    else
        -- Show only basic macronutrients
        return {
            {getter = "getCals", label = "Calories"},
            {getter = "getCarbs", label = "Carbs"},
            {getter = "getProteinPlus", label = "Protein"},
            {getter = "getFats", label = "Fats"},
        }
    end
end

function PPNFTooltip.overrideInventoryHover()
    local original_prerender = ISInventoryPane.prerender

    function ISInventoryPane:prerender()
        original_prerender(self)

        local mouseX, mouseY = getMouseX(), getMouseY()
        local hoveredItem = self:getItemAt(mouseX, mouseY)

        if hoveredItem and instanceof(hoveredItem, "Food") then
            local player = getPlayer()
            player:getModData().hoveredFoodItem = hoveredItem
            player:getModData().nutritionPanelOpen = false

            -- CALL YOUR CUSTOM TOOLTIP HERE
            if PPNFTooltip and PPNFTooltip.onHoverStart then
                PPNFTooltip.onHoverStart(hoveredItem)
            end
        else
            local player = getPlayer()
            player:getModData().hoveredFoodItem = nil
        end
    end
end

return PPNFTooltip
