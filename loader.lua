--[[
    Azurion Hub - Loader
    Interface Roxa com Transições e Verificação de PlaceId
]]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configurações de Scripts
local scripts = {
    [131623223084840] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/Wave%20a%20Brainrot/tsunami.lua"))()
    end,
    [126509999114328] = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/99%20Nights/main.lua"))()
    end
}

-- Criando a Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AzurionLoader"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35) -- Roxo Escuro
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(138, 43, 226) -- Roxo Vivo
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "AZURION HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

-- Status / Texto de Carregamento
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.4, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Checking Game..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Barra de Carregamento (Container)
local LoadingBarBG = Instance.new("Frame")
LoadingBarBG.Size = UDim2.new(0.8, 0, 0, 6)
LoadingBarBG.Position = UDim2.new(0.1, 0, 0.7, 0)
LoadingBarBG.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
LoadingBarBG.BorderSizePixel = 0
LoadingBarBG.Parent = MainFrame

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.Parent = LoadingBarBG

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = LoadingBarFill

-- Botão de Erro (Invisível no início)
local OkayButton = Instance.new("TextButton")
OkayButton.Size = UDim2.new(0.5, 0, 0, 35)
OkayButton.Position = UDim2.new(0.25, 0, 0.65, 0)
OkayButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
OkayButton.Text = "Okay"
OkayButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OkayButton.Font = Enum.Font.GothamBold
OkayButton.TextSize = 14
OkayButton.Visible = false
OkayButton.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = OkayButton

-- Funções de Animação
local function fadeOut()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    TweenService:Create(UIStroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(StatusLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(LoadingBarBG, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadingBarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    tween:Play()
    tween.Completed:Wait()
    ScreenGui:Destroy()
end

-- Lógica de Inicialização
task.spawn(function()
    task.wait(1)
    
    local currentPlaceId = game.PlaceId
    
    -- Animação da Barra
    local fillTween = TweenService:Create(LoadingBarFill, TweenInfo.new(1.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    fillTween:Play()
    
    StatusLabel.Text = "Verifying Place ID: " .. currentPlaceId
    task.wait(1.6)

    if scripts[currentPlaceId] then
        StatusLabel.Text = "Game Supported! Loading..."
        task.wait(1)
        fadeOut()
        
        -- Executa o script do jogo
        local success, err = pcall(function()
            scripts[currentPlaceId]()
        end)
        
        if not success then
            warn("Erro ao carregar o script: " .. tostring(err))
        end
    else
        -- Jogo não suportado
        LoadingBarBG.Visible = false
        StatusLabel.Text = "Jogo não suportado."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        OkayButton.Visible = true
        
        OkayButton.MouseButton1Click:Connect(function()
            fadeOut()
        end)
    end
end)
