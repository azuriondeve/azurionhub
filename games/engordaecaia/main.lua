--[[
    Auto Farm Script com Interface para Roblox
    Funcionalidades:
    - Toggle para Farm de Moedas (Pagar)
    - Toggle para Farm de Troféus (GanhouTrofeu)
    - Toggle para Auto Rebirth com Quantidade Customizada (TextBox)
    - Toggle para Auto Comer
    - Suporte para Mobile e PC
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Proteção básica contra duplicação da UI
local existingGui = player.PlayerGui:FindFirstChild("FarmGui") or CoreGui:FindFirstChild("FarmGui")
if existingGui then existingGui:Destroy() end

-- Variáveis de estado
local farmMoeda = false
local farmTrofeu = false
local autoRebirth = false
local autoComer = false
local rebirthAmount = 1
local menuAberto = true

-- Referências aos Remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local gameManager = remotes and remotes:WaitForChild("GameManager", 5)
local rebirthRemote = ReplicatedStorage:WaitForChild("ComprarRebirth", 5)
local foodRemote = ReplicatedStorage:WaitForChild("AddFoodEvent", 5)

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGui"
screenGui.ResetOnSpawn = false
if not pcall(function() screenGui.Parent = player.PlayerGui end) then
    screenGui.Parent = CoreGui
end

-- Janela Principal (Aumentada para caber a TextBox de Rebirth)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 420)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "AUTO FARM MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- Botão de Minimizar (Floating Button para Mobile)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
toggleBtn.Text = "F"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Função para criar Toggles
local function createToggle(name, position, callback)
    local bg = Instance.new("TextButton")
    bg.Name = name .. "Toggle"
    bg.Size = UDim2.new(0, 180, 0, 45)
    bg.Position = position
    bg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    bg.Text = name
    bg.TextColor3 = Color3.fromRGB(200, 200, 200)
    bg.Font = Enum.Font.Gotham
    bg.TextSize = 14
    bg.Parent = mainFrame
    
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    
    local status = Instance.new("Frame")
    status.Size = UDim2.new(0, 4, 1, 0)
    status.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    status.BorderSizePixel = 0
    status.Parent = bg
    
    local active = false
    bg.MouseButton1Click:Connect(function()
        active = not active
        status.BackgroundColor3 = active and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        bg.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(200, 200, 200)
        callback(active)
    end)
    
    return bg
end

-- Lógica de Farm de Moedas
createToggle("Farm Moedas", UDim2.new(0, 20, 0, 60), function(val)
    farmMoeda = val
    if farmMoeda then
        task.spawn(function()
            while farmMoeda do
                if gameManager then
                    gameManager:FireServer("Pagar", 999999999999999999999999999999999999999)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Lógica de Farm de Troféus
createToggle("Farm Troféu", UDim2.new(0, 20, 0, 115), function(val)
    farmTrofeu = val
    if farmTrofeu then
        task.spawn(function()
            while farmTrofeu do
                if gameManager then
                    gameManager:FireServer("GanhouTrofeu", 500)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Seção de Auto Rebirth com TextBox
createToggle("Auto Rebirth", UDim2.new(0, 20, 0, 170), function(val)
    autoRebirth = val
    if autoRebirth then
        task.spawn(function()
            while autoRebirth do
                if rebirthRemote then
                    rebirthRemote:FireServer(tonumber(rebirthAmount) or 1, "ComprarRebirth")
                end
                task.wait(0.5)
            end
        end)
    end
end)

local amountBox = Instance.new("TextBox")
amountBox.Name = "RebirthAmount"
amountBox.Size = UDim2.new(0, 180, 0, 30)
amountBox.Position = UDim2.new(0, 20, 0, 218)
amountBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
amountBox.BorderSizePixel = 0
amountBox.TextColor3 = Color3.new(1, 1, 1)
amountBox.Text = "1" -- Valor padrão
amountBox.PlaceholderText = "Qtd Rebirth..."
amountBox.Font = Enum.Font.Gotham
amountBox.TextSize = 12
amountBox.Parent = mainFrame
Instance.new("UICorner", amountBox).CornerRadius = UDim.new(0, 4)

amountBox.FocusLost:Connect(function()
    local val = tonumber(amountBox.Text)
    if val then
        rebirthAmount = val
    else
        amountBox.Text = tostring(rebirthAmount)
    end
end)

-- Lógica de Auto Comer
createToggle("Auto Comer", UDim2.new(0, 20, 0, 260), function(val)
    autoComer = val
    if autoComer then
        task.spawn(function()
            while autoComer do
                if foodRemote then
                    foodRemote:FireServer()
                end
                task.wait(0.05)
            end
        end)
    end
end)

-- Botão de Fechar Menu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 180, 0, 40)
closeBtn.Position = UDim2.new(0, 20, 0, 350)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeBtn.Text = "Fechar Menu"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn)

-- Alternar visibilidade
local function toggleMenu()
    menuAberto = not menuAberto
    mainFrame.Visible = menuAberto
end

closeBtn.MouseButton1Click:Connect(toggleMenu)
toggleBtn.MouseButton1Click:Connect(toggleMenu)

-- Atalho de teclado (K)
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.K then
        toggleMenu()
    end
end)

print("Script Atualizado: Auto Rebirth com Quantidade Customizada!")
