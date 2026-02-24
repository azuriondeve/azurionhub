local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/azuriondeve/redz-interface/refs/heads/main/redz-V5-remake/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local Window = Library:MakeWindow({
  Title = "Azurion Hub : Escape Tsunami For Brainrots!",
  SubTitle = "V1.0.0 dev by azur",
  ScriptFolder = "azurionhub-escapetsunamibrainrot"
})



Library:SetTheme("Purple")

Window:SetUIScale(0.8)

local Minimizer = Window:NewMinimizer({
    KeyCode = Enum.KeyCode.LeftControl -- Caso quiser que abra/feche pelo botão use unknown
})

Minimizer:CreateMobileMinimizer({
  Image = "rbxassetid://83205291404596",
  BackgroundColor3 = Color3.fromRGB(128, 0, 128),
--  CornerRadius = 0.5
})
-- Tabs
local FarmTab = Window:MakeTab({
  Title = "Farm",
  Icon = "Laptop" 
})

local VisualTab = Window:MakeTab({
  Title = "Visual",
  Icon = "Camera" 
})

local CreditsTab = Window:MakeTab({
  Title = "Credits",
  Icon = "User" 
})

-- State Variables
local godModeEnabled = false
local espTsunamiEnabled = false
local espBrainrotEnabled = false
local autoUpgradeSpeed = false
local autoUpgradeCarry = false
local walkSpeedValue = 16
local jumpPowerValue = 50
local FIXED_Y_ALT = -1.1 
local dummyModel = nil
local activeESPs = {}
local brainrotESPs = {}

-- Function to hide technical parts
local function hideTechnicalParts(char)
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" or part.Name:lower():find("collision") then
                part.Transparency = 1
                part.LocalTransparencyModifier = 1
                part.CanQuery = false 
            end
        end
    end
end

-- Function to control real character visibility
local function setCharacterVisibility(visible)
    local transparency = visible and 0 or 1
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Name == "HumanoidRootPart" or part.Name:lower():find("collision") then
                part.Transparency = 1
                part.LocalTransparencyModifier = 1
            else
                part.Transparency = transparency
                part.LocalTransparencyModifier = visible and 0 or 1
            end
        elseif part:IsA("Decal") then
            part.Transparency = transparency
        end
    end
end

-- Function to create the Physical Dummy
local function createPhysicalDummy()
    if dummyModel then dummyModel:Destroy() end
    
    character.Archivable = true
    dummyModel = character:Clone()
    character.Archivable = false
    
    dummyModel.Name = "PhysicalDummy"
    
    local dHumanoid = dummyModel:WaitForChild("Humanoid")
    local dRoot = dummyModel:WaitForChild("HumanoidRootPart")
    
    dHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    dHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    dHumanoid.UseJumpPower = true 
    
    for _, obj in pairs(dummyModel:GetDescendants()) do
        if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("Sound") then
            obj:Destroy()
        elseif obj:IsA("BasePart") then
            -- Enable collisions for physical interactions
            obj.CanCollide = true 
            obj.Transparency = 0
            obj.LocalTransparencyModifier = 0
            if obj.Name == "HumanoidRootPart" or obj.Name:lower():find("collision") then 
                obj.Transparency = 1 
                obj.CanCollide = false 
            end
        end
    end
    
    dRoot.Anchored = false 
    dummyModel.Parent = Workspace
    dummyModel:SetPrimaryPartCFrame(rootPart.CFrame * CFrame.new(0, 5, 0))
    
    camera.CameraSubject = dHumanoid
end

-- Generic ESP Logic
local function createESP(object, text, color, storage)
    if storage[object] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AzurionESP"
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18

    billboard.Parent = object
    storage[object] = billboard
end

-- Process single Brainrot
local function setupBrainrotESP(brainrot)
    if not espBrainrotEnabled then return end
    if brainrot.Name == "RenderedBrainrot" then
        local root = brainrot:WaitForChild("Root", 5)
        local nameObj = brainrot:FindFirstChildOfClass("Model") or brainrot:FindFirstChildOfClass("Group")
        local displayName = nameObj and nameObj.Name or "Brainrot"

        if root and root:IsA("BasePart") then
            createESP(root, displayName, Color3.new(1, 1, 1), brainrotESPs)
        end
    end
end

-- Process single Wave/Tsunami
local function setupTsunamiESP(obj)
    if not espTsunamiEnabled then return end
    local name = obj.Name:lower()
    if name:find("tsunami") or name:find("wave") or name:find("hitbox") then
        createESP(obj, "⚠️ TSUNAMI ⚠️", Color3.new(1, 0, 0), activeESPs)
    end
end

-- Update Brainrot ESP
local function updateBrainrotESP()
    for obj, gui in pairs(brainrotESPs) do
        if not obj or not obj.Parent then
            gui:Destroy()
            brainrotESPs[obj] = nil
        end
    end

    if not espBrainrotEnabled then return end

    local container = Workspace:FindFirstChild("ActiveBrainrots")
    if container then
        for _, rarityFolder in pairs(container:GetChildren()) do
            for _, brainrot in pairs(rarityFolder:GetChildren()) do
                setupBrainrotESP(brainrot)
            end
        end
    end
end

-- Update Tsunami ESP
local function updateTsunamiESP()
    for obj, gui in pairs(activeESPs) do
        if not obj or not obj.Parent then
            gui:Destroy()
            activeESPs[obj] = nil
        end
    end

    if not espTsunamiEnabled then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        setupTsunamiESP(obj)
    end
end

Workspace.DescendantAdded:Connect(function(descendant)
    if espTsunamiEnabled then setupTsunamiESP(descendant) end
end)

local brainrotContainer = Workspace:WaitForChild("ActiveBrainrots", 10)
if brainrotContainer then
    for _, folder in pairs(brainrotContainer:GetChildren()) do
        folder.ChildAdded:Connect(function(child)
            if espBrainrotEnabled then setupBrainrotESP(child) end
        end)
    end
end

-- ================= TAB: FARM =================

FarmTab:AddParagraph("Welcome!", "Azurion Hub is ready for action.\nEnjoy the automated features.")

FarmTab:AddSection("Main Farm")


local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local fixedY = -1.4
local farmSpeed = 250
local autoFarmEnabled = false
local amountToTake = 1

local selectedRarities = {}
local promptConnection
local noclipConnection
local respawnConnection

local baseReturn = Vector3.new(110.176125, fixedY, 55.8251228)

--------------------------------------------------
-- IMPROVED NOCLIP SYSTEM (WITH RESPAWN SUPPORT)
--------------------------------------------------

local function applyNoclip()
    if not autoFarmEnabled then return end
    if player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local function toggleNoclip(state)
    if noclipConnection then noclipConnection:Disconnect() end
    if respawnConnection then respawnConnection:Disconnect() end

    if state then
        noclipConnection = RunService.Stepped:Connect(applyNoclip)
        respawnConnection = player.CharacterAdded:Connect(function(char)
            char:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            applyNoclip()
        end)
        applyNoclip()
    else
        if player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

--------------------------------------------------
-- INSTANT INTERACT SYSTEM
--------------------------------------------------

local function toggleInstantTake(state)
    if state then
        for _, prompt in ipairs(game:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
        end
        
        if promptConnection then promptConnection:Disconnect() end
        promptConnection = game.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                descendant.HoldDuration = 0
            end
        end)
    else
        if promptConnection then promptConnection:Disconnect() end
        for _, prompt in ipairs(game:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 1 end
        end
    end
end

--------------------------------------------------
-- SAFE CHARACTER ACCESS
--------------------------------------------------

local function getHRP()
    local char = player.Character
    if not char then return nil end
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid and humanoid.Health > 0 and hrp then
        return hrp
    end
    return nil
end

--------------------------------------------------
-- XZ MOVEMENT WITH Y-LOCK
--------------------------------------------------

local function moveToXZ(hrp, targetPos)
    local reached = false
    local connection
    
    if not hrp or not hrp.Parent then return end

    hrp.Velocity = Vector3.new(0, 0, 0)

    connection = RunService.Heartbeat:Connect(function(dt)
        local currentHRP = getHRP()
        if not autoFarmEnabled or not currentHRP or currentHRP ~= hrp then
            if connection then connection:Disconnect() end
            reached = true
            return
        end

        local currentPos = hrp.Position
        local targetFixed = Vector3.new(targetPos.X, fixedY, targetPos.Z)
        local direction = targetFixed - Vector3.new(currentPos.X, fixedY, currentPos.Z)
        local distance = direction.Magnitude

        if distance <= farmSpeed * dt then
            hrp.CFrame = CFrame.new(targetFixed)
            connection:Disconnect()
            reached = true
        else
            local move = direction.Unit * (farmSpeed * dt)
            hrp.CFrame = CFrame.new(currentPos + move)
            hrp.CFrame = CFrame.new(hrp.Position.X, fixedY, hrp.Position.Z)
        end
    end)

    while not reached and autoFarmEnabled do 
        task.wait() 
        if not getHRP() then break end
    end
end

--------------------------------------------------
-- UI ELEMENTS (RESTORING SLIDERS, DROPDOWNS, ETC)
--------------------------------------------------

FarmTab:AddSlider({
    Name = "Tween Speed",
    Description = "Adjust how fast your character travels (Default: 250)",
    Min = 50,
    Max = 2500,
    Increment = 1,
    Default = 250,
    Callback = function(Value)
        farmSpeed = Value
    end
})

FarmTab:AddDropdown({
    Name = "Select Rarities",
    Description = "Choose which item rarities the bot should target",
    MultiSelect = true,
    Options = {
        "Celestial", "Common", "Cosmic", "Divine", "Epic",
        "Infinity", "Legendary", "Mythical", "Rare", "Secret", "Uncommon"
    },
    Default = {},
    Callback = function(Value)
        selectedRarities = {}
        for rarity, enabled in pairs(Value) do
            if enabled then
                table.insert(selectedRarities, rarity)
            end
        end
    end
})

FarmTab:AddTextBox({
    Name = "Amount Before Return (1–6)",
    Description = "How many items to collect before going back to base",
    Placeholder = "Set 1 to 6",
    ClearOnFocus = true,
    Callback = function(Value)
        local number = tonumber(Value)
        if number then
            amountToTake = math.clamp(number, 1, 6)
        end
    end
})

--------------------------------------------------
-- MAIN AUTO FARM TOGGLE
--------------------------------------------------

FarmTab:AddToggle({
    Name = "Auto Farm Brainrot",
    Description = "Full Auto: Respawns & Farms Automatically",
    Default = false,
    Callback = function(Value)
        autoFarmEnabled = Value
        toggleNoclip(Value)
        toggleInstantTake(Value)

        if Value then
            task.spawn(function()
                while autoFarmEnabled do
                    local hrp = getHRP()
                    
                    if not hrp then
                        repeat task.wait(1) until getHRP() or not autoFarmEnabled
                        if not autoFarmEnabled then break end
                        hrp = getHRP()
                        task.wait(0.5)
                    end
                    
                    local taken = 0
                    while taken < amountToTake and autoFarmEnabled do
                        hrp = getHRP()
                        if not hrp then break end

                        local list = {}
                        for _, rarity in ipairs(selectedRarities) do
                            local folder = workspace.ActiveBrainrots:FindFirstChild(rarity)
                            if folder then
                                for _, brainrot in pairs(folder:GetChildren()) do
                                    if brainrot.Name == "RenderedBrainrot" then
                                        local p = brainrot.PrimaryPart or brainrot:FindFirstChildWhichIsA("BasePart")
                                        if p then table.insert(list, brainrot) end
                                    end
                                end
                            end
                        end

                        if #list == 0 then
                            task.wait(1)
                            break 
                        end

                        local target = list[math.random(1, #list)]
                        local part = target and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart"))
                        
                        if part then
                            moveToXZ(hrp, part.Position)
                            
                            local start = tick()
                            while tick() - start <= 0.4 and autoFarmEnabled and target.Parent do
                                hrp = getHRP()
                                if not hrp then break end
                                
                                hrp.Velocity = Vector3.new(0,0,0)
                                hrp.CFrame = CFrame.new(hrp.Position.X, fixedY, hrp.Position.Z)

                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(0.05)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                task.wait(0.05)
                            end
                            taken = taken + 1
                        end
                        task.wait(0.1)
                    end

                    hrp = getHRP()
                    if hrp and autoFarmEnabled then
                        moveToXZ(hrp, baseReturn)
                    end
                    
                    task.wait(0.5)
                end
            end)
        else
            -- Cleanup on disable
            local hrp = getHRP()
            if hrp then
                hrp.Velocity = Vector3.new(0,0,0)
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

FarmTab:AddSection("Main Exploits")

FarmTab:AddToggle({
    Name = "God Mode",
    Description = "Creates a fake body with real physics while your real character stays safe underground.",
    Default = false,
    Callback = function(Value)
        godModeEnabled = Value
        if Value then
            createPhysicalDummy()
            setCharacterVisibility(true)
        else
            if dummyModel and dummyModel:FindFirstChild("HumanoidRootPart") then
                rootPart.CFrame = dummyModel.HumanoidRootPart.CFrame
                dummyModel:Destroy() 
                dummyModel = nil
            end
            camera.CameraSubject = humanoid
            setCharacterVisibility(true)
        end
    end
})


FarmTab:AddToggle({
    Name = "Instant Take",
    Description = "Removes the hold duration from all existing and future proximity prompts.",
    Default = false,
    Callback = function(Value)
        if Value then
            -- 1. Torna todos os prompts atuais instantâneos
            for _, prompt in ipairs(game:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 0
                end
            end
            
            -- 2. Monitoriza novos prompts que surgirem no jogo
            promptConnection = game.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("ProximityPrompt") then
                    descendant.HoldDuration = 0
                end
            end)
        else
            -- Desconecta a monitorização para parar de afetar novos prompts
            if promptConnection then
                promptConnection:Disconnect()
                promptConnection = nil
            end
            
            -- Retorna os prompts atuais para um valor padrão ao desativar
            for _, prompt in ipairs(game:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    prompt.HoldDuration = 3 -- Valor padrão de retorno
                end
            end
        end
    end
})

FarmTab:AddSection("Auto Upgrades")

FarmTab:AddToggle({
    Name = "Auto Upgrade Speed",
    Description = "Automatically purchases speed upgrades.",
    Default = false,
    Callback = function(Value)
        autoUpgradeSpeed = Value
    end
})

FarmTab:AddToggle({
    Name = "Auto Upgrade Carry",
    Description = "Automatically purchases carry capacity upgrades.",
    Default = false,
    Callback = function(Value)
        autoUpgradeCarry = Value
    end
})

FarmTab:AddSection("Modifiers")

FarmTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Callback = function(Value)
        walkSpeedValue = Value
    end
})

FarmTab:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(Value)
        jumpPowerValue = Value
    end
})

-- ================= TAB: VISUAL =================

VisualTab:AddSection("Detection")

VisualTab:AddToggle({
    Name = "ESP Tsunami/Waves",
    Description = "Shows the location of incoming waves.",
    Default = false,
    Callback = function(Value)
        espTsunamiEnabled = Value
        if Value then updateTsunamiESP() else
            for _, gui in pairs(activeESPs) do gui:Destroy() end
            activeESPs = {}
        end
    end
})

VisualTab:AddToggle({
    Name = "ESP Brainrots",
    Description = "Shows current brainrot entities.",
    Default = false,
    Callback = function(Value)
        espBrainrotEnabled = Value
        if Value then updateBrainrotESP() else
            for _, gui in pairs(brainrotESPs) do gui:Destroy() end
            brainrotESPs = {}
        end
    end
})

-- ================= TAB: CREDITS =================

CreditsTab:AddSection("Development")
CreditsTab:AddParagraph("Lead Developer", "Script developed by azurion.")

CreditsTab:AddButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
})

-- Upgrade Threads
task.spawn(function()
    while true do
        if autoUpgradeSpeed then
            pcall(function()
                local remote = ReplicatedStorage:WaitForChild("RemoteFunctions", 5):WaitForChild("UpgradeSpeed", 2)
                if remote then remote:InvokeServer(1) end
            end)
        end
        if autoUpgradeCarry then
            pcall(function()
                local remote = ReplicatedStorage:WaitForChild("RemoteFunctions", 5):WaitForChild("UpgradeCarry", 2)
                if remote then remote:InvokeServer(1) end
            end)
        end
        task.wait(0.1)
    end
end)

-- Main Loop
RunService.Stepped:Connect(function()
    hideTechnicalParts(character)
    if dummyModel then hideTechnicalParts(dummyModel) end

    if godModeEnabled and humanoid and humanoid.Health > 0 then
        -- Disable real character collision
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        setCharacterVisibility(true)
        
        if dummyModel and dummyModel:FindFirstChild("HumanoidRootPart") then
            local dRoot = dummyModel.HumanoidRootPart
            local dHumanoid = dummyModel.Humanoid
            
            -- Speed Sync: Uses highest value to ensure game upgrades work
            local currentRealSpeed = humanoid.WalkSpeed
            dHumanoid.WalkSpeed = math.max(currentRealSpeed, walkSpeedValue)
            dHumanoid.JumpPower = jumpPowerValue
            
            -- Direction Sync
            dHumanoid:Move(humanoid.MoveDirection, false)
            
            -- Improved Jump Sync: Force jump if the dummy is stuck or low
            if humanoid.Jump then
                dHumanoid.Jump = true
                -- Se o dummy estiver no chão ou em queda perto do limite de altura, forçamos o estado de pulo
                if dHumanoid:GetState() == Enum.HumanoidStateType.Running or dHumanoid:GetState() == Enum.HumanoidStateType.Landed or dRoot.Position.Y <= (FIXED_Y_ALT + 2) then
                    dHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    -- Força um impulso de velocidade vertical para garantir que saia do chão
                    dRoot.Velocity = Vector3.new(dRoot.Velocity.X, jumpPowerValue, dRoot.Velocity.Z)
                end
            end
            
            -- Position lock: follows horizontal but stays at fixed Y
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.CFrame = CFrame.new(dRoot.Position.X, FIXED_Y_ALT, dRoot.Position.Z) * dRoot.CFrame.Rotation
        end
    else
        -- Default state logic
        if humanoid then
            humanoid.WalkSpeed = walkSpeedValue
            humanoid.JumpPower = jumpPowerValue
        end
    end
    
    if tick() % 1.0 < 0.1 then 
        updateTsunamiESP()
        updateBrainrotESP()
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    hideTechnicalParts(character)
    if godModeEnabled then 
        createPhysicalDummy()
        setCharacterVisibility(true)
    else
        camera.CameraSubject = humanoid
    end
end)