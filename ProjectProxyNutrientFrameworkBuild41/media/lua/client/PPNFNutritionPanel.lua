local PPNFNutritionPanel = ISPanel:derive("PPNFNutritionPanel")

function PPNFNutritionPanel:new(x, y, width, height, playerNum)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = playerNum or 0
    o.progressBars = {}
    o.activeTimePeriod = "daily"
    return o
end

function PPNFNutritionPanel:initialise()
    ISPanel.initialise(self)
    self:init()
    self:createTimePeriodButtons()
    self:createProgressBars()
end

function PPNFNutritionPanel:init()
    local playerData = getPlayer():getModData()
    if playerData.initializationDone and not playerData.gettersDone then
        playerData.gettersDone = true
        self.tableHandler = _G.TableHandler
    end
end

function PPNFNutritionPanel.getNutrientsForKnowledgeLevel(cookingLevel, hasNutritionist)
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
        return {
            {getter = "getCals", label = "Calories"},
            {getter = "getCarbs", label = "Carbs"},
            {getter = "getProteinPlus", label = "Protein"},
            {getter = "getFats", label = "Fats"},
        }
    end
end

function PPNFNutritionPanel.addNutritionTab()
    local originalCreateChildren = ISCharacterInfoWindow.createChildren
    
    function ISCharacterInfoWindow:createChildren()
        originalCreateChildren(self)
        
        self.nutritionView = PPNFNutritionPanel:new(0, 8, self.width, self.height-8, self.playerNum)
        self.nutritionView:initialise()
        self.nutritionView.infoText = getText("UI_PPNFNutritionPanel")
        
        self.panel:addView(getText("UI_PPNF_Nutrition"), self.nutritionView)
    end
end

function PPNFNutritionPanel:getVisibleNutrients(cookingLevel, hasNutritionist)
    local knowledgeNutrients = PPNFNutritionPanel.getNutrientsForKnowledgeLevel(cookingLevel, hasNutritionist)
    local visibleGetters = {}
    
    for _, nutrient in ipairs(knowledgeNutrients) do
        visibleGetters[nutrient.getter] = true
    end
    
    local orderedNutrients = {}
    for _, nutrient in ipairs(self.tableHandler.displayOrder) do
        local expectedGetter = "get" .. nutrient.key
        
        if visibleGetters[expectedGetter] then
            table.insert(orderedNutrients, nutrient)
        end
    end
    
    return orderedNutrients
end

function PPNFNutritionPanel.calculateLayout(nutrientCount)
    if nutrientCount == 4 then
        return {
            rows = 2,
            cols = 2,
            arrangement = "grid"
        }
    elseif nutrientCount == 9 then
        return {
            rows = 3,
            cols = 3,
            arrangement = "grid"
        }
    elseif nutrientCount == 25 then
        return {
            rows = 9,
            cols = 3,
            arrangement = "grid_with_remainder"
        }
    else
        local cols = math.min(3, nutrientCount)
        local rows = math.ceil(nutrientCount / cols)
        return {
            rows = rows,
            cols = cols,
            arrangement = "grid"
        }
    end
end

function PPNFNutritionPanel:createProgressBars()
    local player = getPlayer()
    local cookingLevel = player:getPerkLevel(Perks.Cooking)
    local hasNutritionist = player:HasTrait("Nutritionist")
    
    local visibleNutrients = self:getVisibleNutrients(cookingLevel, hasNutritionist)
    local layout = PPNFNutritionPanel.calculateLayout(#visibleNutrients)
    
    self.progressBars = {}
    
    local barWidth = 120  -- Adjust as needed
    local barHeight = 20  -- Adjust as needed
    local padding = 10
    
    for i, nutrient in ipairs(visibleNutrients) do
        -- Calculate grid position
        local row, col
        if layout.arrangement == "grid_with_remainder" and i == #visibleNutrients then
            -- Last item centered on final row
            row = layout.rows - 1
            col = 1  -- Center column (0-indexed)
        else
            row = math.floor((i - 1) / layout.cols)
            col = (i - 1) % layout.cols
        end
        
        -- Calculate actual pixel position (offset by button area)
        local x = col * (barWidth + padding) + 10  -- Add left margin
        local y = row * (barHeight + padding) + 50  -- Start below buttons and add top margin
        
        -- Create progress bar with nutrient label from displayOrder
        local progressBar = self:newProgressBar(x, y, barWidth, barHeight)
        progressBar.label = getText(nutrient.label)  -- Use the UI text key
        progressBar.nutrientKey = nutrient.key
        progressBar.getter = "get" .. nutrient.key  -- Store the getter function name
        
        -- Calculate actual percentage from player nutrition data
        local playerData = player:getModData()
        local currentIntake = playerData.nutrients and playerData.nutrients[nutrient.key] or 0
        local dailyRequirement = playerData.nutrientList and playerData.nutrientList[nutrient.key] or 1
        progressBar.percentage = (currentIntake / dailyRequirement) * 100
        
        -- Add progress bar as child so it renders
        self:addChild(progressBar)
        table.insert(self.progressBars, progressBar)
    end
end

function PPNFNutritionPanel:newProgressBar(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    
    o.percentage = 0
    o.label = ""
    o.nutrientKey = ""
    o.getter = ""  -- Store the getter function name
    
    return o
end

function PPNFNutritionPanel:getFillTexture()
    if self.percentage > 100 then
        return "media/ui/ppnf_bar_fill_red.png"
    elseif self.percentage >= 80 then
        return "media/ui/ppnf_bar_fill_orange.png"
    elseif self.percentage >= 60 then
        return "media/ui/ppnf_bar_fill_yellow.png"
    elseif self.percentage >= 30 then
        return "media/ui/ppnf_bar_fill_lightblue.png"
    else
        return "media/ui/ppnf_bar_fill_blue.png"
    end
end

function PPNFNutritionPanel:render()
    -- Draw background
    local bgTexture = getTexture("media/ui/ppnf_bar_background.png")
    self:drawTexture(bgTexture, 0, 0, 1, 1, 1, 1)
    
    -- Draw clipped fill
    local fillWidth = (self.width * self.percentage) / 100
    local fillTexture = getTexture(self:getFillTexture())
    self:drawTexture(fillTexture, 0, 0, fillWidth, self.height, 1, 1, 1, 1)
    
    -- Draw nutrient name text centered on the bar
    if self.label then
        local font = UIFont.Small
        local textWidth = getTextManager():MeasureStringX(font, self.label)
        local textHeight = getTextManager():getFontHeight(font)
        
        -- Center the text on the bar
        local textX = (self.width - textWidth) / 2
        local textY = (self.height - textHeight) / 2
        
        -- Draw black outline for better readability
        self:drawText(self.label, textX - 1, textY, 0, 0, 0, 1, font)
        self:drawText(self.label, textX + 1, textY, 0, 0, 0, 1, font)
        self:drawText(self.label, textX, textY - 1, 0, 0, 0, 1, font)
        self:drawText(self.label, textX, textY + 1, 0, 0, 0, 1, font)
        
        -- Draw white text on top
        self:drawText(self.label, textX, textY, 1, 1, 1, 1, font)
    end
    
    -- Render food icon if we're showing food nutrition (only for the main panel, not individual progress bars)
    if self.progressBars then  -- This indicates it's the main panel, not a progress bar
        self:renderFoodIcon()
    end
end

function PPNFNutritionPanel:createTimePeriodButtons()
    local buttonWidth = 80
    local buttonHeight = 25
    local buttonSpacing = 5
    local startX = 10  -- Left margin
    local startY = 10  -- Top margin
    
    -- Daily button
    self.dailyButton = ISButton:new(startX, startY, buttonWidth, buttonHeight, getText("UI_PPNF_Daily"), self, PPNFNutritionPanel.onDailyButtonClick)
    self.dailyButton:initialise()
    self.dailyButton.borderColor = {r=1, g=1, b=1, a=0.4}
    self.dailyButton.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.dailyButton.backgroundColorMouseOver = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.dailyButton)
    
    -- Weekly button  
    local weeklyX = startX + buttonWidth + buttonSpacing
    self.weeklyButton = ISButton:new(weeklyX, startY, buttonWidth, buttonHeight, getText("UI_PPNF_Weekly"), self, PPNFNutritionPanel.onWeeklyButtonClick)
    self.weeklyButton:initialise()
    self.weeklyButton.borderColor = {r=1, g=1, b=1, a=0.4}
    self.weeklyButton.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.weeklyButton.backgroundColorMouseOver = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.weeklyButton)
    
    -- Monthly (28-day) button
    local monthlyX = weeklyX + buttonWidth + buttonSpacing
    self.monthlyButton = ISButton:new(monthlyX, startY, buttonWidth, buttonHeight, getText("UI_PPNF_Monthly"), self, PPNFNutritionPanel.onMonthlyButtonClick)
    self.monthlyButton:initialise()
    self.monthlyButton.borderColor = {r=1, g=1, b=1, a=0.4}
    self.monthlyButton.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.monthlyButton.backgroundColorMouseOver = {r=1, g=1, b=1, a=0.1}
    self:addChild(self.monthlyButton)
    
    -- Set initial active button (Daily by default)
    self.activeTimePeriod = "daily"
    self:setActiveButton(self.dailyButton)
end

function PPNFNutritionPanel:setActiveButton(activeButton)
    -- Reset all buttons to inactive state
    local buttons = {self.dailyButton, self.weeklyButton, self.monthlyButton}
    for _, button in ipairs(buttons) do
        if button then
            button.backgroundColor = {r=0, g=0, b=0, a=0.5}
            button.textColor = {r=1, g=1, b=1, a=1}
        end
    end
    
    -- Set active button appearance
    if activeButton then
        activeButton.backgroundColor = {r=0.2, g=0.6, b=1, a=0.8}  -- Blue background for active
        activeButton.textColor = {r=1, g=1, b=1, a=1}  -- White text
    end
end

function PPNFNutritionPanel:onDailyButtonClick()
    self.activeTimePeriod = "daily"
    self:setActiveButton(self.dailyButton)
    self:updateProgressBarsForTimePeriod()
end

function PPNFNutritionPanel:onWeeklyButtonClick()
    self.activeTimePeriod = "weekly"
    self:setActiveButton(self.weeklyButton)
    self:updateProgressBarsForTimePeriod()
end

function PPNFNutritionPanel:onMonthlyButtonClick()
    self.activeTimePeriod = "monthly"
    self:setActiveButton(self.monthlyButton)
    self:updateProgressBarsForTimePeriod()
end

function PPNFNutritionPanel:updateProgressBarsForTimePeriod()
    local player = getPlayer()
    local playerData = player:getModData()
    
    for _, progressBar in ipairs(self.progressBars) do
        local nutrientKey = progressBar.nutrientKey
        local percentage = 0
        
        if self.activeTimePeriod == "daily" then
            -- Current day's intake
            local currentIntake = playerData.nutrients and playerData.nutrients[nutrientKey] or 0
            local dailyRequirement = playerData.nutrientList and playerData.nutrientList[nutrientKey] or 1
            percentage = (currentIntake / dailyRequirement) * 100
            
        elseif self.activeTimePeriod == "weekly" then
            -- Calculate average over last 7 days from intake history
            local intakeHistory = playerData.intakeHistory and playerData.intakeHistory[nutrientKey] or {}
            local currentIntake = playerData.nutrients and playerData.nutrients[nutrientKey] or 0
            local dailyRequirement = playerData.nutrientList and playerData.nutrientList[nutrientKey] or 1
            
            local totalIntake = currentIntake  -- Start with current day
            local daysCount = 1
            
            -- Add up to 6 previous days from history
            for i = 1, math.min(6, #intakeHistory) do
                totalIntake = totalIntake + (intakeHistory[i] or 0)
                daysCount = daysCount + 1
            end
            
            local averageIntake = totalIntake / daysCount
            percentage = (averageIntake / dailyRequirement) * 100
            
        elseif self.activeTimePeriod == "monthly" then
            -- Calculate average over last 28 days from intake history
            local intakeHistory = playerData.intakeHistory and playerData.intakeHistory[nutrientKey] or {}
            local currentIntake = playerData.nutrients and playerData.nutrients[nutrientKey] or 0
            local dailyRequirement = playerData.nutrientList and playerData.nutrientList[nutrientKey] or 1
            
            local totalIntake = currentIntake  -- Start with current day
            local daysCount = 1
            
            -- Add up to 27 previous days from history
            for i = 1, math.min(27, #intakeHistory) do
                totalIntake = totalIntake + (intakeHistory[i] or 0)
                daysCount = daysCount + 1
            end
            
            local averageIntake = totalIntake / daysCount
            percentage = (averageIntake / dailyRequirement) * 100
        end
        
        progressBar.percentage = percentage
    end
end

function PPNFNutritionPanel:updateProgressBarsForFood()
    -- Show food nutrition instead of player nutrition when flag is active
    local player = getPlayer()
    local playerData = player:getModData()
    
    -- Check if we should show food nutrition (flag set by tooltip)
    if not playerData.nutritionPanelOpen then
        return false  -- No food being hovered, use normal player nutrition
    end
    
    -- Get the food item (set by tooltip system when flag is active)
    local foodItem = playerData.hoveredFoodItem
    
    for _, progressBar in ipairs(self.progressBars) do
        local nutrientKey = progressBar.nutrientKey
        local getterName = progressBar.getter
        
        -- Use the stored getter to get food's nutrient value
        local foodValue = foodItem[getterName](foodItem)

        
        -- Calculate percentage based on daily requirement
        local dailyRequirement = playerData.nutrientList and playerData.nutrientList[nutrientKey] or 1
        local percentage = (foodValue / dailyRequirement) * 100
        
        progressBar.percentage = percentage
    end
    
    return true  -- Food nutrition was displayed
end

function PPNFNutritionPanel:prerender()
    ISPanel.prerender(self)
    
    -- Update button visibility based on whether we're showing food nutrition
    self:updateButtonVisibility()
    
    -- Update progress bars based on current state
    if not self:updateProgressBarsForFood() then
        self:updateProgressBarsForTimePeriod()
    end
end

function PPNFNutritionPanel:renderFoodIcon()
    -- Show food item icon when hovering over food
    local player = getPlayer()
    local playerData = player:getModData()
    
    if not playerData.nutritionPanelOpen or not playerData.hoveredFoodItem then
        return
    end
    
    local foodItem = playerData.hoveredFoodItem
    
    -- Get the food item's texture/icon through the script item (correct API for Food objects)
    local scriptItem = foodItem:getScriptItem()
    local iconName = scriptItem:getIcon()
    local itemTexture = getTexture(iconName)
    
    if itemTexture then
        -- Position the icon where the buttons normally are
        local iconSize = 32  -- Size of the food icon
        local iconX = 10     -- Same X position as buttons
        local iconY = 10     -- Same Y position as buttons
        
        -- Draw the food item icon
        self:drawTexture(itemTexture, iconX, iconY, iconSize, iconSize, 1, 1, 1, 1)
        
        -- Get food display name through script item (correct API for Food objects)
        local foodName = scriptItem:getDisplayName()
        if foodName then
            local font = UIFont.Small
            local textX = iconX + iconSize + 10  -- Position text to the right of icon
            local textY = iconY + (iconSize - getTextManager():getFontHeight(font)) / 2  -- Center vertically
            
            -- Draw black outline for better readability
            self:drawText(foodName, textX - 1, textY, 0, 0, 0, 1, font)
            self:drawText(foodName, textX + 1, textY, 0, 0, 0, 1, font)
            self:drawText(foodName, textX, textY - 1, 0, 0, 0, 1, font)
            self:drawText(foodName, textX, textY + 1, 0, 0, 0, 1, font)
            
            -- Draw white text on top
            self:drawText(foodName, textX, textY, 1, 1, 1, 1, font)
        end
    end
end

function PPNFNutritionPanel:updateButtonVisibility()
    -- Hide time period buttons when showing food nutrition, show them otherwise
    local player = getPlayer()
    local playerData = player:getModData()
    
    local showButtons = not (playerData.nutritionPanelOpen and playerData.hoveredFoodItem)
    
    if self.dailyButton then
        self.dailyButton:setVisible(showButtons)
    end
    if self.weeklyButton then
        self.weeklyButton:setVisible(showButtons)
    end
    if self.monthlyButton then
        self.monthlyButton:setVisible(showButtons)
    end
end

-- Open the nutrition panel
function PPNFNutritionPanel.open(item, openWithFood, foodName)
    -- Get the character info window to access the nutrition panel
    local player = getPlayer()
    local playerData = player:getModData()
    
    -- Open the character info window if it's not already open
    local characterInfoWindow = getPlayerInfoPanel(player:getPlayerNum())
    if not characterInfoWindow then
        -- Create and show the character info window
        local characterInfo = ISCharacterInfoWindow:new(50, 50, 600, 400, player)
        characterInfo:initialise()
        characterInfo:addToUIManager()
        characterInfo:setVisible(true)
        characterInfoWindow = characterInfo
    else
        -- Make sure it's visible
        characterInfoWindow:setVisible(true)
        characterInfoWindow:bringToTop()
    end
    
    -- Switch to the nutrition tab
    if characterInfoWindow.panel then
        local nutritionTabText = getText("UI_PPNF_Nutrition")
        for i = 1, characterInfoWindow.panel.viewList:size() do
            local tabView = characterInfoWindow.panel.viewList:get(i-1)
            if tabView and tabView.name == nutritionTabText then
                characterInfoWindow.panel:activateView(nutritionTabText)
                break
            end
        end
    end
    
    -- If opening with food, set up food display
    if openWithFood and item then
        playerData.nutritionPanelOpen = true
        playerData.hoveredFoodItem = item
        
        -- Access the nutrition view and refresh it
        if characterInfoWindow.nutritionView then
            characterInfoWindow.nutritionView:updateProgressBarsForFood()
        end
    else
        -- Clear food display flags
        playerData.nutritionPanelOpen = false
        playerData.hoveredFoodItem = nil
    end
end

return PPNFNutritionPanel
