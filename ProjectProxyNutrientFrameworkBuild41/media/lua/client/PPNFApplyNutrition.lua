PPNFApplyNutrition = {}

local modItemsPath = "media/scripts/items.txt"

function PPNFApplyNutrition.applyNutrition()
    local allItems = getScriptManager():getAllItems()
    if not allItems then
        print("PPNF: Could not get all items from ScriptManager")
        return
    end

    for i = 0, allItems:size() - 1 do
        local scriptItem = allItems:get(i)
        if scriptItem:getTypeString() == "Food" then
            local itemName = scriptItem:getFullName()
            local runtimeItem = InventoryItemFactory.CreateItem(itemName)

            if runtimeItem and instanceof(runtimeItem, "Food") then
                local food = runtimeItem:getFoodComponent()
                if food then
                    local function setIfPresent(prop, setter)
                        local val = scriptItem:getProperty(prop)
                        if val then
                            food[setter](food, tonumber(val))
                        end
                    end

                    -- Macronutrients
                    setIfPresent("Calories", "setCalories")
                    setIfPresent("Lipids", "setLipids")
                    setIfPresent("Carbohydrates", "setCarbohydrates")
                    setIfPresent("Protein", "setProteins")

                    -- Micronutrients - assuming setters exist, if not, you'll need to handle them separately
                    setIfPresent("Cholesterol", "setCholesterol")
                    setIfPresent("Sodium", "setSodium")
                    setIfPresent("Magnesium", "setMagnesium")
                    setIfPresent("Potassium", "setPotassium")

                    setIfPresent("VitaminA", "setVitaminA")
                    setIfPresent("VitaminD", "setVitaminD")
                    setIfPresent("VitaminE", "setVitaminE")
                    setIfPresent("VitaminK", "setVitaminK")
                    setIfPresent("VitaminC", "setVitaminC")

                    setIfPresent("VitaminB1", "setVitaminB1")
                    setIfPresent("VitaminB2", "setVitaminB2")
                    setIfPresent("VitaminB3", "setVitaminB3")
                    setIfPresent("VitaminB5", "setVitaminB5")
                    setIfPresent("VitaminB6", "setVitaminB6")
                    setIfPresent("VitaminB9", "setVitaminB9")
                    setIfPresent("VitaminB12", "setVitaminB12")

                    setIfPresent("Calcium", "setCalcium")
                    setIfPresent("Phosphorus", "setPhosphorus")
                    setIfPresent("Iron", "setIron")
                    setIfPresent("Zinc", "setZinc")
                end
            end
        end
    end
end

return PPNFApplyNutrition
