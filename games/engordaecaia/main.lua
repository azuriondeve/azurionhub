local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local rs = game:GetService("ReplicatedStorage")

local running = false

-- Criar GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,120,0,50)
button.Position = UDim2.new(0.5,-60,0.5,-25)
button.Text = "START"
button.BackgroundColor3 = Color3.fromRGB(40,40,40)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = gui

-- Sistema de arrastar
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	button.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		
		dragging = true
		dragStart = input.Position
		startPos = button.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Função do botão
button.MouseButton1Click:Connect(function()
	running = not running
	
	if running then
		button.Text = "STOP"
		
		task.spawn(function()
			while running do
				
				local args = {
					"Pagar",
					999999999999999999
				}

				rs.Remotes.GameManager:FireServer(unpack(args))

				local args2 = {
					"GanhouTrofeu",
					500
				}

				rs.Remotes.GameManager:FireServer(unpack(args2))

				task.wait(0.0001)
			end
		end)
		
	else
		button.Text = "START"
	end
end)
