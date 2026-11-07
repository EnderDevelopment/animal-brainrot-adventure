-- Animal Brainrot: compact client HUD for coins and collection progress.
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AnimalBrainrotHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "StatusPanel"
panel.Size = UDim2.fromOffset(270, 112)
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(24, 31, 43)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -28, 0, 32)
title.Position = UDim2.fromOffset(14, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "ANIMAL BRAINROT"
title.TextColor3 = Color3.fromRGB(255, 218, 96)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Size = UDim2.new(1, -28, 0, 25)
coinsLabel.Position = UDim2.fromOffset(14, 46)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Font = Enum.Font.GothamSemibold
coinsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coinsLabel.TextSize = 16
coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
coinsLabel.Parent = panel

local collectionLabel = coinsLabel:Clone()
collectionLabel.Position = UDim2.fromOffset(14, 75)
collectionLabel.Parent = panel

local function updateCoins()
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	coinsLabel.Text = "Coins   " .. (coins and coins.Value or 0)
end

local function updateCollection()
	local collection = player:FindFirstChild("CreatureCollection")
	local total = 0
	if collection then
		for _, value in ipairs(collection:GetChildren()) do
			if value:IsA("IntValue") then total += value.Value end
		end
	end
	collectionLabel.Text = "Collected   " .. total
end

local function connectStats()
	local stats = player:WaitForChild("leaderstats")
	local coins = stats:WaitForChild("Coins")
	coins.Changed:Connect(updateCoins)
	updateCoins()
	local collection = player:WaitForChild("CreatureCollection")
	collection.ChildAdded:Connect(function(value)
		value.Changed:Connect(updateCollection)
		updateCollection()
	end)
	collection.ChildRemoved:Connect(updateCollection)
	updateCollection()
end

connectStats()
