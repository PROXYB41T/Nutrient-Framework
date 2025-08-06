-- PPNF Main Controller
-- Single file that handles everything

local PPNFNutritionPanel = require "PPNFNutritionPanel"
local PPNFTooltip = require "PPNFTooltip"
local PPNFApplyNutrition = require "PPNFApplyNutrition"
local PPNFMain = {}

-- Register all events
function PPNFMain.registerEvents()
    Events.OnKeyPressed.Add(PPNFMain.onKeyPressed)
    Events.OnFillInventoryObjectContextMenu.Add(PPNFMain.onRightClickFood)
    -- TODO: Hook into existing hover events for tooltips
end

function PPNFMain.init()
    print("PPNFMain: Init started")
    PPNFMain.registerEvents()
    PPNFApplyNutrition.applyNutrition()
    print("PPNFMain: Init complete")
end


function PPNFMain.onKeyPressed(key)
    if key == Keyboard.KEY_N then
        PPNFNutritionPanel.open(item, openWithFood, foodName)
    end
end

function PPNFMain.onRightClickFood(player, context, items)
    -- Check if any of the items are food
    for i = 1, #items do
        local item = items[i]
        if instanceof(item, "Food") then
            -- Add "Open Nutrition Panel" option to the top of the context menu
            context:addOptionOnTop("Open Nutrition Panel", item, PPNFMain.openNutritionPanelForFood)
            break -- Only add the option once, even if multiple food items
        end
    end
end

-- Callback when user clicks "Open Nutrition Panel" from context menu
function PPNFMain.openNutritionPanelForFood(item)
    PPNFNutritionPanel.openWithFood(item)
end

-- Handle hover events for tooltips
function PPNFMain.onHoverFood(item)
    -- TODO: Show nutrition tooltip
end

-- Handle when hover starts on food item
function PPNFMain.onHoverStart(item)
    -- TODO: Check if nutrition panel is open
    -- TODO: If panel is open: Update nutrition panel to show food, skip tooltip
    -- TODO: If panel is closed: Call PPNFTooltip.onHoverStart(item) to show tooltip
end

-- Handle when hover ends on food item
function PPNFMain.onHoverEnd()
    -- TODO: Call PPNFTooltip.onHoverEnd()
    -- TODO: Restore nutrition panel to player mode if open
end

function PPNFMain.applyNutrition()
    PPNFApplyNutrition.applyPPNFScriptNutrition()
end

-- Start everything when the game loads
Events.OnLoad.Add(PPNFMain.init)
Events.OnGameStart.Add(PPNFTooltip.overrideInventoryHover)

return PPNFMain
