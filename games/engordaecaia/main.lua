--[[
    Auto Farm Script com Interface para Roblox
    Funcionalidades:
    - Toggle para Farm de Moedas (Pagar)
    - Toggle para Farm de Troféus (GanhouTrofeu)
    - Suporte para Mobile e PC
    - Design moderno com cantos arredondados
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
local menuAberto = true

-- Referências aos Remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local gameManager = remotes and remotes:WaitForChild("GameManager", 5)

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGui"
screenGui.ResetOnSpawn = false
-- Tenta colocar no PlayerGui, se falhar (executor limitado) coloca no CoreGui
if not pcall(function() screenGui.Parent = player.PlayerGui end) then
    screenGui.Parent = CoreGui
end

-- Janela Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 220, 0, 260)
mainFrame.Position = UDim2.new(0.5, -110, 0.4, -130)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Suporte básico para arrastar
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

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleBtn

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
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = bg
    
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
                    gameManager:FireServer("Pagar", 999999999999999999999999999999999999999999999999999999999999999999999999999999999)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Lógica de Farm de Troféus
createToggle("Farm Troféu", UDim2.new(0, 20, 0, 120), function(val)
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

-- Botão de Fechar Menu
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 180, 0, 40)
closeBtn.Position = UDim2.new(0, 20, 0, 200)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeBtn.Text = "Fechar Menu"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner").Parent = closeBtn

-- Alternar visibilidade
local function toggleMenu()
    menuAberto = not menuAberto
    mainFrame.Visible = menuAberto
end

closeBtn.MouseButton1Click:Connect(toggleMenu)
toggleBtn.MouseButton1Click:Connect(toggleMenu)

-- Atalho de teclado (K)


print("Script Carregado com Sucesso!")
