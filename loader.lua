--[[
    Azurion Hub - Elite Loader (Instant Load)
    Professional Interface with Modern Design, Acrylic Effects, and Security
]]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Configuration
local Config = {
    HubName = "AzurionLoader",
    Version = "v3.2"
}

-- Cleanup previous executions
if CoreGui:FindFirstChild("AzurionLoader") then
    CoreGui.AzurionLoader:Destroy()
end

-- Script Database
local scripts = {
    [131623223084840] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/Wave%20a%20Brainrot/tsunami.lua",
    [126509999114328] = "https://raw.githubusercontent.com/azuriondeve/azurionhub/refs/heads/main/games/99%20Nights/main.lua"
}

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(12, 10, 18),
    Accent = Color3.fromRGB(138, 43, 226),
    Secondary = Color3.fromRGB(25, 20, 35),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 160),
    Error = Color3.fromRGB(255, 60, 60),
    Success = Color3.fromRGB(80, 255, 120)
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AzurionLoader"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 180)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -90)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Glow/Stroke
local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2.5
Stroke.Color = Theme.Accent
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 100)),
    ColorSequenceKeypoint.new(1, Theme.Background)
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Header
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = Config.HubName
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.Parent = MainFrame

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 50, 0, 20)
VersionLabel.Position = UDim2.new(1, -60, 0, 15)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = Config.Version
VersionLabel.TextColor3 = Theme.Accent
VersionLabel.Font = Enum.Font.GothamBold
VersionLabel.TextSize = 10
VersionLabel.Parent = MainFrame

-- Content Container
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -40, 1, -60)
Content.Position = UDim2.new(0, 20, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.3, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializing..."
StatusLabel.TextColor3 = Theme.SubText
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 14
StatusLabel.Parent = Content

-- Loading Bar
local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, 0, 0, 6)
ProgressBG.Position = UDim2.new(0, 0, 0.65, 0)
ProgressBG.BackgroundColor3 = Theme.Secondary
ProgressBG.BorderSizePixel = 0
ProgressBG.Parent = Content

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Theme.Accent
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBG

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = ProgressFill

-- Exit Button (Visible only on error)
local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(0.6, 0, 0, 35)
ExitButton.Position = UDim2.new(0.2, 0, 0.5, 0)
ExitButton.BackgroundColor3 = Theme.Secondary
ExitButton.Text = "Close"
ExitButton.TextColor3 = Theme.Text
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextSize = 14
ExitButton.Visible = false
ExitButton.Parent = Content

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ExitButton

-- Functions
local function animateProgress(target, speed)
    local tween = TweenService:Create(ProgressFill, TweenInfo.new(speed or 1, Enum.EasingStyle.Quart), {Size = UDim2.new(target, 0, 1, 0)})
    tween:Play()
    return tween
end

local function closeUI()
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(MainFrame, info, {Size = UDim2.new(0, 340, 0, 0), Position = UDim2.new(0.5, -170, 0.5, 0)}):Play()
    TweenService:Create(Stroke, info, {Transparency = 1}):Play()
    task.wait(0.5)
    ScreenGui:Destroy()
end

-- Main Logic
task.spawn(function()
    -- Start-up Animation
    MainFrame.BackgroundTransparency = 1
    Title.TextTransparency = 1
    Content.GroupTransparency = 1
    
    TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
    TweenService:Create(Title, TweenInfo.new(0.7), {TextTransparency = 0}):Play()
    task.wait(0.5)
    
    -- Step 1: Checking Game
    StatusLabel.Text = "Verifying Game Compatibility..."
    animateProgress(0.4, 1)
    task.wait(1.2)
    
    local placeId = game.PlaceId
    if scripts[placeId] then
        -- Step 2: Loading
        StatusLabel.Text = "Game Supported! Fetching Hub..."
        StatusLabel.TextColor3 = Theme.Success
        animateProgress(1, 0.8)
        task.wait(1)
        
        closeUI()
        
        local success, err = pcall(function()
            loadstring(game:HttpGet(scripts[placeId]))()
        end)
        
        if not success then
            warn("[Azurion] Execution Error: " .. tostring(err))
        end
    else
        -- Step 3: Error
        StatusLabel.Text = "Game Not Supported (ID: " .. placeId .. ")"
        StatusLabel.TextColor3 = Theme.Error
        ProgressBG.Visible = false
        ExitButton.Visible = true
        
        ExitButton.MouseButton1Click:Connect(closeUI)
    end
end)

-- Visual Effects (Hover & Pulse)
ExitButton.MouseEnter:Connect(function()
    TweenService:Create(ExitButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Accent}):Play()
end)
ExitButton.MouseLeave:Connect(function()
    TweenService:Create(ExitButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Secondary}):Play()
end)

task.spawn(function()
    while MainFrame and MainFrame.Parent do
        TweenService:Create(Stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Theme.Accent}):Play()
        task.wait(2)
        TweenService:Create(Stroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = Color3.fromRGB(100, 30, 180)}):Play()
        task.wait(2)
    end
end)
