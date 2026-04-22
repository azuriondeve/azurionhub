-- Azurion Hub - Loader SEM UI + Kick

local Players = game:GetService("Players")

-- Scripts suportados (PlaceId ou GameId)
local scripts = {
    [131623223084840] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/Wave%20a%20Brainrot/tsunami.lua",
    [126509999114328] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/99%20Nights/main.lua",
    [994732206] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/bloxfruit/main.lua",
    [104901094326217] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/engordaecaia/main.lua",
    [70845479499574] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/Bitebynight/main.lua",
}

-- Detecta IDs
local placeId = game.PlaceId
local gameId = game.GameId

-- Procura script correspondente
local targetScript = scripts[placeId] or scripts[gameId]

-- Executa ou kicka
if targetScript then
    loadstring(game:HttpGet(targetScript))()
else
    local player = Players.LocalPlayer
    if player then
        player:Kick("This game is not supported by Azurion Hub.")
    end
end
