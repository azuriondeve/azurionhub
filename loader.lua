local scripts = {
    [131623223084840] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/Wave%20a%20Brainrot/tsunami.lua"))()
    end,

    [1234567890] = function()
        print("Script do jogo 2 carregado")
    end,

    [9876543210] = function()
        print("Script do jogo 3 carregado")
    end
}

local currentPlaceId = game.PlaceId

if scripts[currentPlaceId] then
    scripts[currentPlaceId]()
else
    warn("Jogo não suportado.")
end
