require 'Items/ProceduralDistributions'

print("PPNF: Loading vitamin distributions...")

-- Add vitamins to existing distributions using base game structure
local function addToDistribution(distName, items)
    if ProceduralDistributions and ProceduralDistributions.list and ProceduralDistributions.list[distName] and ProceduralDistributions.list[distName].items then
        for i = 1, #items, 2 do
            table.insert(ProceduralDistributions.list[distName].items, items[i])     -- item name
            table.insert(ProceduralDistributions.list[distName].items, items[i+1])  -- weight
        end
        print("PPNF: Added " .. (#items/2) .. " vitamin items to " .. distName)
    else
        print("PPNF: WARNING - Distribution '" .. distName .. "' not found")
    end
end

-- Define all vitamin items with their spawn weights (rare but findable)
local vitaminItems = {
    "ProjectProxyNutrientFrameworkBuild41.MultiVitamins", 1,
    "ProjectProxyNutrientFrameworkBuild41.AVitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B1Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B2Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B3Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B5Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B6Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B9Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.B12Vitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.CVitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.DVitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.EVitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.KVitamins", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.CalciumTablets", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.IronTablets", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.MagnesiumTablets", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.PotassiumTablets", 0.5,
    "ProjectProxyNutrientFrameworkBuild41.ZincTablets", 0.5,
}

-- Add to medical/pharmacy distributions (higher weights)
local medicalDists = {"MedicalClinicDrugs", "MedicalStorageDrugs", "PharmacyCosmetics", "StoreShelfMedical"}
for _, dist in ipairs(medicalDists) do
    addToDistribution(dist, vitaminItems)
end

-- Add to general store distributions (lower weights)  
local generalItems = {}
for i = 1, #vitaminItems, 2 do
    table.insert(generalItems, vitaminItems[i])
    table.insert(generalItems, math.max(1, math.floor(vitaminItems[i+1] / 2))) -- half weight
end

local generalDists = {"DrugShackDrugs"}
for _, dist in ipairs(generalDists) do
    addToDistribution(dist, generalItems)
end

print("PPNF: Vitamin distribution setup completed")
