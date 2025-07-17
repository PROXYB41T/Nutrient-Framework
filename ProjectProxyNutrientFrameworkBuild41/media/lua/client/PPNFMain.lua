require "PPNFNutritionPanel"
require "PPNFTooltip"

local PPNFMain = {}

-- Register all events
function PPNFMain.registerEvents()
    Events.OnKeyPressed.Add(PPNFMain.onKeyPressed)
    Events.OnFillInventoryObjectContextMenu.Add(PPNFMain.onRightClickFood)
    -- TODO: Hook into existing hover events for tooltips
end

-- Initialize everything
function PPNFMain.init()
    PPNFMain.registerEvents()
    PPNFTooltip.init()
end

-- Handle key presses
function PPNFMain.onKeyPressed(key)
    if key == Keyboard.KEY_N then
        PPNFNutritionPanel.open()
    end
end

-- Handle right click on food items
function PPNFMain.onRightClickFood(player, context, items)
    local item = items[1]
    if instanceof(item, "Food") then
        context:addOptionOnTop("Nutrition Info: " .. item:getName(), item, PPNFNutritionPanel.open, true, item:getName())
    end
end



function PPNFMain.hookTooltipSystem()
    local originalDoTooltip = zombie.inventory.types.Food.DoTooltip
    
    local function customFoodDoTooltip(item, tooltip)
        PPNFTooltip.customFoodTooltip(item, tooltip)
        
        if PPNFNutritionPanel.isOpen() then
            PPNFNutritionPanel.updateWithFood(item)
        end
    end
    
    zombie.inventory.types.Food.DoTooltip = customFoodDoTooltip
end

Events.OnGameStart.Add(PPNFMain.init)

return PPNFMain
