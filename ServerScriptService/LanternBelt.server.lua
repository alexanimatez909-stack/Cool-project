-- LanternBelt (Script in ServerScriptService)
-- Everyone's lantern hangs from their belt at the LEFT hip, all the time (decided with Alexander).
-- Pressing the lantern key (Config.LANTERN_KEY) asks this script to switch it on or off. The server decides,
-- sets the character attribute "LanternOn" (MovementAnimations then plays the reach-down-and-turn animation),
-- and turns the light on/off a moment later, when the hand turns the knob (Config.LANTERN_SWITCH_DELAY).
--
-- YOUR LANTERN MODEL: put it in ServerStorage and name it "Lantern". It can be a Model or a Tool.
--   * It hangs by its pivot (for a Tool: its Handle), so put the pivot where the hook/handle is.
--   * Every light inside it (PointLight, SpotLight, SurfaceLight) is switched on and off.
--   * Without one, a plain grey placeholder lantern is used.
-- Don't leave a lantern Tool in StarterPack, or players will still get one in their RIGHT hand.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local remote = ReplicatedStorage:FindFirstChild("LanternToggle") or Instance.new("RemoteEvent")
remote.Name = "LanternToggle"
remote.Parent = ReplicatedStorage

-- a simple stand-in until there's a real lantern model
local function placeholder()
	local model = Instance.new("Model")
	model.Name = "Lantern"
	local body = Instance.new("Part")
	body.Name = "Handle"
	body.Size = Vector3.new(0.5, 0.8, 0.5)
	body.Color = Color3.fromRGB(90, 80, 60)
	body.Material = Enum.Material.Metal
	body.Parent = model
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 190, 110)
	light.Range = 16
	light.Brightness = 1.5
	light.Parent = body
	model.PrimaryPart = body
	return model
end

-- a copy of the lantern as a Model (a Tool is turned into a plain Model so Roblox won't put it in the hand)
local function makeLantern()
	local template = ServerStorage:FindFirstChild("Lantern")
	if not template then return placeholder() end
	local copy = template:Clone()
	if copy:IsA("Tool") then
		local model = Instance.new("Model")
		model.Name = "Lantern"
		for _, child in copy:GetChildren() do
			if not child:IsA("Script") and not child:IsA("LocalScript") then child.Parent = model end
		end
		model.PrimaryPart = model:FindFirstChild("Handle")
		copy:Destroy()
		copy = model
	end
	return copy
end

local function lightsOf(lantern)
	local lights = {}
	for _, d in lantern:GetDescendants() do
		if d:IsA("Light") then table.insert(lights, d) end
	end
	return lights
end

local function onCharacter(character)
	local hips = character:WaitForChild("LowerTorso", 10)
	if not hips then return end
	local lantern = makeLantern()
	local o = Config.LANTERN_HIP_OFFSET
	lantern:PivotTo(hips.CFrame * CFrame.new(o.X, o.Y, o.Z) * CFrame.Angles(0, math.rad(Config.LANTERN_HIP_TURN), 0))
	for _, part in lantern:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = hips
			weld.Part1 = part
			weld.Parent = part
		end
	end
	for _, light in lightsOf(lantern) do light.Enabled = false end
	lantern.Parent = character
	character:SetAttribute("LanternOn", false)
end

local lastSwitch = {} -- player -> time of their last switch
remote.OnServerEvent:Connect(function(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local lantern = character and character:FindFirstChild("Lantern")
	if not humanoid or humanoid.Health <= 0 or not lantern then return end
	-- one switch at a time: the animation has to finish first
	if os.clock() - (lastSwitch[player] or 0) < Config.LANTERN_COOLDOWN then return end
	lastSwitch[player] = os.clock()

	local on = not character:GetAttribute("LanternOn")
	character:SetAttribute("LanternOn", on) -- starts the reach-down animation
	task.delay(Config.LANTERN_SWITCH_DELAY, function()
		-- the hand has reached the knob: now the light changes (unless it was switched again meanwhile)
		if character:GetAttribute("LanternOn") ~= on or not lantern.Parent then return end
		for _, light in lightsOf(lantern) do light.Enabled = on end
	end)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then onCharacter(player.Character) end
end)
for _, player in Players:GetPlayers() do
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then task.spawn(onCharacter, player.Character) end
end
Players.PlayerRemoving:Connect(function(player) lastSwitch[player] = nil end)
