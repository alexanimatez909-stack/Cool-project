-- Movement (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The one script that decides how fast you move: walk, or sprint while Shift is held.
-- Sprinting uses stamina; all the numbers are in ReplicatedStorage.Config.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer

local humanoid = nil
local shiftHeld = false
local lastSprintTime = -math.huge -- when you last sprinted (for the refill delay)

local function onCharacter(character)
	humanoid = character:WaitForChild("Humanoid")
	State.stamina, State.sprinting, State.exhausted = 1, false, false
	humanoid.WalkSpeed = Config.WALK_SPEED
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	onCharacter(player.Character)
end

local SPRINT_KEYS = { [Enum.KeyCode.LeftShift] = true, [Enum.KeyCode.RightShift] = true }
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- typing in chat, etc.
	if SPRINT_KEYS[input.KeyCode] then shiftHeld = true end
end)
UserInputService.InputEnded:Connect(function(input)
	if SPRINT_KEYS[input.KeyCode] then shiftHeld = false end
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

	local speed = State.sprinting and Config.SPRINT_SPEED or Config.WALK_SPEED
	if humanoid.WalkSpeed ~= speed then
		humanoid.WalkSpeed = speed
	end
end)
