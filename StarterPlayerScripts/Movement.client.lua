-- Movement (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The one script that decides how fast you move: walk, sprint while Shift is held, or crouch.
-- Sprinting uses stamina; all the numbers are in ReplicatedStorage.Config.
-- Crouching also lowers your view (Humanoid.CameraOffset), eased so it sinks smoothly.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer

local humanoid = nil
local shiftHeld = false
local crouchWanted = false -- toggle mode: flipped by the crouch key; hold mode: true while it's held
local lastSprintTime = -math.huge -- when you last sprinted (for the refill delay)
local crouchMix = 0 -- 0 standing .. 1 crouched (eased, so the view sinks smoothly)
local sideMix = 0   -- -1 stepping left .. 1 stepping right (eased, so the view slides smoothly)

local function onCharacter(character)
	humanoid = character:WaitForChild("Humanoid")
	State.stamina, State.sprinting, State.exhausted, State.crouching = 1, false, false, false
	crouchWanted = false
	crouchMix = 0
	humanoid.WalkSpeed = Config.WALK_SPEED
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	onCharacter(player.Character)
end

local SPRINT_KEYS = { [Enum.KeyCode.LeftShift] = true, [Enum.KeyCode.RightShift] = true }
local CROUCH_KEY = Enum.KeyCode[Config.CROUCH_KEY]
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- typing in chat, etc.
	if SPRINT_KEYS[input.KeyCode] then
		shiftHeld = true
	elseif input.KeyCode == CROUCH_KEY then
		if Config.CROUCH_TOGGLE then
			crouchWanted = not crouchWanted
		else
			crouchWanted = true
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if SPRINT_KEYS[input.KeyCode] then
		shiftHeld = false
	elseif input.KeyCode == CROUCH_KEY and not Config.CROUCH_TOGGLE then
		crouchWanted = false
	end
end)

RunService.Heartbeat:Connect(function(dt)
	if not humanoid or humanoid.Health <= 0 then return end

	local moving = humanoid.MoveDirection.Magnitude > 0.1
	State.sprinting = shiftHeld and moving and not State.exhausted

	if State.sprinting then
		lastSprintTime = os.clock()
		State.stamina = math.max(0, State.stamina - dt / Config.STAMINA_DRAIN_TIME)
		if State.stamina <= 0 then
			State.exhausted = true
			State.sprinting = false
		end
	elseif os.clock() - lastSprintTime >= Config.STAMINA_REFILL_DELAY then
		State.stamina = math.min(1, State.stamina + dt / Config.STAMINA_REFILL_TIME)
	end
	if State.exhausted and State.stamina >= Config.STAMINA_RESPRINT_AT then
		State.exhausted = false
	end

	-- sprinting stands you up; in toggle mode you stay standing afterwards
	if State.sprinting and Config.CROUCH_TOGGLE then
		crouchWanted = false
	end
	State.crouching = crouchWanted and not State.sprinting

	local speed = Config.WALK_SPEED
	if State.sprinting then
		speed = Config.SPRINT_SPEED
	elseif State.crouching then
		speed = Config.CROUCH_SPEED
	end
	if humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end

	-- CameraOffset moves the view without moving the body: forward so your eyes sit at the
	-- front of your head (not behind it), down while crouching, and a little to the side you're
	-- stepping toward (walking left puts your view nearer your left shoulder).
	local target = State.crouching and 1 or 0
	crouchMix += (target - crouchMix) * (1 - math.exp(-Config.CROUCH_CAMERA_SMOOTHING * dt))
	local root = humanoid.RootPart
	local sideTarget = 0
	if root and moving and not State.reduceMotion then
		sideTarget = math.clamp(root.CFrame:VectorToObjectSpace(humanoid.MoveDirection).X, -1, 1)
	end
	sideMix += (sideTarget - sideMix) * (1 - math.exp(-Config.CAMERA_SIDE_SMOOTHING * dt))
	humanoid.CameraOffset = Vector3.new(
		Config.CAMERA_SIDE_SHIFT * sideMix,
		-Config.CROUCH_CAMERA_DROP * crouchMix,
		-Config.CAMERA_FORWARD_OFFSET
	)
end)
