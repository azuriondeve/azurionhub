--[[
    Azurion Hub - Elite Loader (Instant Load)
    Professional Interface with Modern Design, Draggable UI & Game List Support
]]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

-- Language Configuration
local lang = getgenv().language or "pt"
local Localization = {
    ["pt"] = {
        Initializing = "Inicializando...",
        Verifying = "Verificando Compatibilidade...",
        Supported = "Jogo Suportado! Carregando Hub...",
        NotSupported = "Jogo não Suportado (ID: ",
        SupportedGames = "Jogos Suportados:",
        Close = "Fechar"
    },
    ["en"] = {
        Initializing = "Initializing...",
        Verifying = "Verifying Compatibility...",
        Supported = "Game Supported! Fetching Hub...",
        NotSupported = "Game Not Supported (ID: ",
        SupportedGames = "Supported Games:",
        Close = "Close"
    }
}

local Text = Localization[lang] or Localization["pt"]

-- Configuration
local Config = {
    HubName = "Azurion Hub",
    Version = "v3.6"
}

-- Script Database (Adicionados mais IDs de exemplo para a lista)
local scripts = {
    [131623223084840] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/Wave%20a%20Brainrot/tsunami.lua",
    [126509999114328] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/99%20Nights/main.lua",

}

-- Theme
local Theme = {
    Background = Color3.fromRGB(12, 10, 18),
    Accent = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(25, 20, 35),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 160),
    Error = Color3.fromRGB(255, 60, 60),
    Success = Color3.fromRGB(80, 255, 120)
}

-- Cleanup
if CoreGui:FindFirstChild("AzurionLoader") then CoreGui.AzurionLoader:Destroy() end

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AzurionLoader"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 180)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -90)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Color = Theme.Accent
Stroke.Parent = MainFrame

-- Draggable Logic Function
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(MainFrame)

-- Header
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = Config.HubName
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

-- Content Container
local Content = Instance.new("CanvasGroup")
Content.Size = UDim2.new(1, -40, 0, 100)
Content.Position = UDim2.new(0, 20, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.2, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = Text.Initializing
StatusLabel.TextColor3 = Theme.SubText
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 14
StatusLabel.Parent = Content

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, 0, 0, 6)
ProgressBG.Position = UDim2.new(0, 0, 0.6, 0)
ProgressBG.BackgroundColor3 = Theme.Secondary
ProgressBG.Parent = Content

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.Parent = ProgressBG
Instance.new("UICorner", ProgressFill).CornerRadius = UDim.new(1, 0)

-- List of Supported Games (Initially Hidden)
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Name = "ListFrame"
ListFrame.Size = UDim2.new(1, 0, 0, 120)
ListFrame.Position = UDim2.new(0, 0, 1, 10)
ListFrame.BackgroundTransparency = 1
ListFrame.ScrollBarThickness = 2
ListFrame.ScrollBarImageColor3 = Theme.Accent
ListFrame.Visible = false
ListFrame.Parent = Content

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ListFrame

local function createGameEntry(id)
    local success, info = pcall(function() return MarketplaceService:GetProductInfo(id) end)
    local name = success and info.Name or "Unknown Game ("..id..")"
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundColor3 = Theme.Secondary
    Label.Text = "  • " .. name
    Label.TextColor3 = Theme.SubText
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.Parent = ListFrame
    Instance.new("UICorner", Label).CornerRadius = UDim.new(0, 4)
end

-- Functions
local function animateProgress(target, speed)
    TweenService:Create(ProgressFill, TweenInfo.new(speed or 1, Enum.EasingStyle.Quart), {Size = UDim2.new(target, 0, 1, 0)}):Play()
end

local function closeUI()
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 340, 0, 0), Position = UDim2.new(0.5, -170, 0.5, 0)}):Play()
    task.wait(0.5)
    ScreenGui:Destroy()
end

-- Main Logic
task.spawn(function()
    animateProgress(0.4, 1.5)
    StatusLabel.Text = Text.Verifying
    task.wait(1.5)
    
    local placeId = game.PlaceId
    if scripts[placeId] then
        StatusLabel.Text = Text.Supported
        StatusLabel.TextColor3 = Theme.Success
        animateProgress(1, 0.8)
        task.wait(1)
        closeUI()
        
        if scripts[placeId] ~= "" then
            loadstring(game:HttpGet(scripts[placeId]))()
        end
    else
        -- Expand UI for List
        StatusLabel.Text = Text.NotSupported .. placeId .. ")"
        StatusLabel.TextColor3 = Theme.Error
        
        task.wait(0.5)
        
        -- Animation to Expand
        TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 340, 0, 320)}):Play()
        TweenService:Create(Content, TweenInfo.new(0.6), {Size = UDim2.new(1, -40, 0, 240)}):Play()
        
        task.wait(0.3)
        ProgressBG.Visible = false
        StatusLabel.Text = Text.SupportedGames
        StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ListFrame.Visible = true
        TweenService:Create(ListFrame, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0, 40)}):Play()
        
        -- Populate List
        for id, _ in pairs(scripts) do
            task.spawn(function() createGameEntry(id) end)
        end
        
        -- Add Close Button at the bottom
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(1, 0, 0, 35)
        CloseBtn.Position = UDim2.new(0, 0, 0.85, 0)
        CloseBtn.BackgroundColor3 = Theme.Secondary
        CloseBtn.Text = Text.Close
        CloseBtn.TextColor3 = Theme.Text
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.Parent = Content
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
        
        CloseBtn.MouseButton1Click:Connect(closeUI)
    end
end)
