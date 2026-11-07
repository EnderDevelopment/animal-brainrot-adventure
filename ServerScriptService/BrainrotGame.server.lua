-- Animal Brainrot: server-owned world, creatures, capture rewards, and player data.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local world = Workspace:FindFirstChild("AnimalBrainrotWorld")
if world then
	world:Destroy()
end
world = Instance.new("Folder")
world.Name = "AnimalBrainrotWorld"
world.Parent = Workspace

local creatureFolder = Instance.new("Folder")
creatureFolder.Name = "Creatures"
creatureFolder.Parent = world

local colors = {
	Color3.fromRGB(255, 112, 105), Color3.fromRGB(80, 206, 169),
	Color3.fromRGB(255, 202, 72), Color3.fromRGB(139, 117, 255),
	Color3.fromRGB(91, 183, 255), Color3.fromRGB(255, 139, 205),
}

local function part(parent, name, size, color, position, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.Color = color
	object.Position = position
	object.Anchored = true
	object.CanCollide = true
	object.Material = Enum.Material.SmoothPlastic
	if shape then object.Shape = shape end
	object.Parent = parent
	return object
end

local function makeIsland()
	local base = part(world, "Meadow Island", Vector3.new(190, 10, 190), Color3.fromRGB(88, 177, 93), Vector3.new(0, -5, 0))
	base.Material = Enum.Material.Grass
	part(world, "Island Soil", Vector3.new(190, 18, 190), Color3.fromRGB(126, 85, 59), Vector3.new(0, -19, 0)).Material = Enum.Material.Ground
	part(world, "Spawn Plaza", Vector3.new(28, 1, 28), Color3.fromRGB(235, 211, 145), Vector3.new(0, 0.5, 0)).Material = Enum.Material.Sand
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Creature Camp"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 1.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = world

	for index = 1, 24 do
		local angle = index * math.pi * 2 / 24
		local x, z = math.cos(angle) * 68, math.sin(angle) * 68
		local trunk = part(world, "Tree Trunk", Vector3.new(3, 10, 3), Color3.fromRGB(113, 74, 48), Vector3.new(x, 5, z), Enum.PartType.Cylinder)
		trunk.CanCollide = true
		part(world, "Tree Canopy", Vector3.new(12, 12, 12), Color3.fromRGB(70, 156, 85), Vector3.new(x, 12, z), Enum.PartType.Ball).CanCollide = false
	end

	for index = 1, 10 do
		local x = math.random(-75, 75)
		local z = math.random(-75, 75)
		if math.abs(x) > 20 or math.abs(z) > 20 then
			local rock = part(world, "Meadow Boulder", Vector3.new(math.random(5, 10), math.random(3, 7), math.random(5, 10)), Color3.fromRGB(112, 126, 125), Vector3.new(x, 2, z), Enum.PartType.Ball)
			rock.Material = Enum.Material.Slate
		end
	end
end

local function makeCreature(name, index, position)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("CreatureName", name)
	model:SetAttribute("Reward", 15 + index * 10)
	model.Parent = creatureFolder
	local color = colors[(index - 1) % #colors + 1]
	local body = part(model, "Body", Vector3.new(4.2, 3.2, 3.2), color, position, Enum.PartType.Ball)
	body.CanCollide = false
	model.PrimaryPart = body
	part(model, "Face", Vector3.new(2.5, 2.2, 0.35), color:Lerp(Color3.new(1, 1, 1), 0.23), position + Vector3.new(0, 0.1, -1.35), Enum.PartType.Ball).CanCollide = false
	for eye = -1, 1, 2 do
		local eyePart = part(model, "Eye", Vector3.new(0.38, 0.48, 0.22), Color3.new(0.08, 0.08, 0.12), position + Vector3.new(eye * 0.55, 0.35, -1.68), Enum.PartType.Ball)
		eyePart.CanCollide = false
	end
	local earSize = index % 2 == 0 and Vector3.new(0.7, 1.35, 0.65) or Vector3.new(0.8, 0.75, 0.7)
	for ear = -1, 1, 2 do
		local earPart = part(model, "Ear", earSize, color, position + Vector3.new(ear * 1.15, 1.55, 0), Enum.PartType.Ball)
		earPart.CanCollide = false
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = name
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = body

	local collected = false
	prompt.Triggered:Connect(function(player)
		if collected or not player.Parent then return end
		collected = true
		local stats = player:FindFirstChild("leaderstats")
		local coins = stats and stats:FindFirstChild("Coins")
		local collection = player:FindFirstChild("CreatureCollection")
		if coins then coins.Value += model:GetAttribute("Reward") end
		if collection then
			local count = collection:FindFirstChild(name)
			if not count then
				count = Instance.new("IntValue")
				count.Name = name
				count.Parent = collection
			end
			count.Value += 1
		end
		model:Destroy()
		task.delay(12, function()
			if creatureFolder.Parent then makeCreature(name, index, position) end
		end)
	end)
end

makeIsland()

local creatureNames = {"Bananacat", "Capybara Supremo", "Crocodilo Bop", "Pigeon Dancer", "Froggo Mambo", "Sharky Snack"}
for index, name in ipairs(creatureNames) do
	local angle = index * math.pi * 2 / #creatureNames
	makeCreature(name, index, Vector3.new(math.cos(angle) * 38, 3, math.sin(angle) * 38))
end

Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = stats
	local collection = Instance.new("Folder")
	collection.Name = "CreatureCollection"
	collection.Parent = player
end)
