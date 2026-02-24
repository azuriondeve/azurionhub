local scripts = {
    [131623223084840] = function()
        print("cu")
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
