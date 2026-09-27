-- Footsteps (LocalScript in StarterPlayer > StarterPlayerScripts)
-- A footstep sound for every step, chosen by what's underfoot (cobbles, stone paving...).
-- Sprinting is loud and carries far, walking is normal, crouching is barely audible.
-- It plays everyone's footsteps, not just yours: other players are heard from where they are,
-- getting quieter with distance. Your own steps line up with the head bob (CameraFeel counts them).
-- Roblox's default running sound is muted so it doesn't play on top.
-- Sounds and volumes are in ReplicatedStorage.Config (FOOTSTEP_...).
--
-- Which sound a floor gets: if the part has an attribute "FootstepSound" (e.g. "Cobble"), that
-- name is used; otherwise the part's Material (e.g. "Cobblestone", "Slate"). Turn on
-- Config.FOOTSTEP_DEBUG to print the name of whatever you're walking on.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local localPlayer = Players.LocalPlayer
local random = Random.new()

-- how someone is moving, worked out from their speed (works for other players too)
local function movementOf(speed)
	if speed > (Config.WALK_SPEED + Config.SPRINT_SPEED) / 2 then return "Sprint" end
	if speed < (Config.CROUCH_SPEED + Config.WALK_SPEED) / 2 then return "Crouch" end
	return "Walk"
end

-- the name of the floor under a character
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local lastFloorName = nil
local function floorUnder(root)
	local characters = {}
	for _, player in Players:GetPlayers() do
		if player.Character then table.insert(characters, player.Character) end
	end
	rayParams.FilterDescendantsInstances = characters
	local result = workspace:Raycast(root.Position, Vector3.new(0, -8, 0), rayParams)
	if not result then return nil end
	return result.Instance:GetAttribute("FootstepSound") or result.Material.Name
end

local function playStep(character, movement)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local floor = floorUnder(root)
	if not floor then return end
	if Config.FOOTSTEP_DEBUG and character == localPlayer.Character and floor ~= lastFloorName then
		lastFloorName = floor
		print("[Footsteps] walking on: " .. floor)
	end
	local ids = Config.FOOTSTEP_SOUNDS[floor] or Config.FOOTSTEP_SOUNDS.Default
	if not ids or #ids == 0 then return end
	local id = ids[random:NextInteger(1, #ids)] -- a different recording each step sounds less robotic
	if id == 0 then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = Config.FOOTSTEP_VOLUME[movement]
	sound.PlaybackSpeed = 1 + random:NextNumber(-1, 1) * Config.FOOTSTEP_PITCH_VARIATION
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = 6
	sound.RollOffMaxDistance = Config.FOOTSTEP_HEARING_DISTANCE[movement]
	sound.Parent = root
	sound.Ended:Once(function() sound:Destroy() end)
	sound:Play()
end

-- mute Roblox's default running sound on every character
local function muteDefaultRunning(character)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then return end
	local function mute(child)
		if child:IsA("Sound") and child.Name == "Running" then child.Volume = 0 end
	end
	for _, child in root:GetChildren() do mute(child) end
	root.ChildAdded:Connect(mute)
end
local function watchPlayer(player)
	player.CharacterAdded:Connect(muteDefaultRunning)
	if player.Character then task.spawn(muteDefaultRunning, player.Character) end
end
Players.PlayerAdded:Connect(watchPlayer)
for _, player in Players:GetPlayers() do watchPlayer(player) end

local distanceSinceStep = {} -- [character] = studs walked since their last footstep (other players)
local lastLocalSteps = State.footsteps

RunService.Heartbeat:Connect(function(dt)
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and root and humanoid.Health > 0 then
			local velocity = root.AssemblyLinearVelocity
			local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			local movement = movementOf(speed)
			if player == localPlayer then
				-- your own steps: whenever the head bob counts a footstep
				if State.footsteps ~= lastLocalSteps then
					lastLocalSteps = State.footsteps
					playStep(character, State.sprinting and "Sprint" or State.crouching and "Crouch" or "Walk")
				end
			elseif humanoid.FloorMaterial ~= Enum.Material.Air and speed > 0.5 then
				-- other players: a step every so many studs, like the head bob does for you
				local stepLength = movement == "Sprint" and Config.BOB_STEP_LENGTH_SPRINT or Config.BOB_STEP_LENGTH_WALK
				local walked = (distanceSinceStep[character] or 0) + speed * dt
				if walked >= stepLength then
					walked -= stepLength
					playStep(character, movement)
				end
				distanceSinceStep[character] = walked
			end
		end
	end
	for character in distanceSinceStep do -- forget characters that are gone
		if not character.Parent then distanceSinceStep[character] = nil end
	end
end)
