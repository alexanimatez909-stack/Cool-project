-- MovementAnimations (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Plays OUR movement animations (Config.MOVEMENT_ANIMATIONS) instead of Roblox's default ones:
-- idle, walk, sprint, crouch, crouch-walk, out of breath, and the lantern held up on top.
-- It reads what your body is doing from MovementState (written by the Movement script), picks one animation,
-- and speeds it up or slows it down to match how fast you're really moving, so your feet don't slide.
-- Runs on your own computer: Roblox automatically shows your character's animations to everyone else.
-- Until the Walk ID is filled in, it does nothing and Roblox's default animations keep playing.
-- It also turns jumping off (Config.ALLOW_JUMP).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer

local FADE = 0.2 -- seconds to blend from one animation into the next

local tracks = {}     -- name -> loaded animation
local current = nil   -- the movement animation playing now
local humanoid, root = nil, nil

local function load(animator, name)
	local id = Config.MOVEMENT_ANIMATIONS[name]
	if not id or id == 0 then return nil end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. id
	local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
	if not ok then
		warn("[MovementAnimations] Couldn't load " .. name .. " (" .. id .. "): " .. tostring(track))
		return nil
	end
	track.Looped = true
	return track
end

local function onCharacter(character)
	tracks, current = {}, nil
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
	if not Config.ALLOW_JUMP then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	end
	if (Config.MOVEMENT_ANIMATIONS.Walk or 0) == 0 then return end -- not set up yet: keep Roblox's animations

	-- switch off Roblox's own Animate script and stop what it was playing
	local animate = character:WaitForChild("Animate", 5)
	if animate then animate.Disabled = true end
	local animator = humanoid:WaitForChild("Animator")
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
	for name in Config.MOVEMENT_ANIMATIONS do
		tracks[name] = load(animator, name)
	end
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then
	task.spawn(onCharacter, player.Character)
end

-- which animation fits right now, and the speed it was made for (nil = don't scale its speed)
local function choose(speed)
	local moving = speed > 0.5 and humanoid.MoveDirection.Magnitude > 0.1
	if State.crouching then
		if moving then return "CrouchWalk", Config.CROUCH_SPEED end
		return "CrouchIdle"
	end
	if moving and State.sprinting then return "Sprint", Config.SPRINT_SPEED end
	if moving then return "Walk", Config.WALK_SPEED end
	if State.exhausted then return "OutOfBreath" end
	return "Idle"
end

RunService.Heartbeat:Connect(function()
	if not humanoid or not root or not tracks.Walk or humanoid.Health <= 0 then return end

	local velocity = root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local name, madeFor = choose(speed)
	local track = tracks[name] or (madeFor and tracks.Walk) or tracks.Idle

	if track ~= current then
		if current then current:Stop(FADE) end
		if track then track:Play(FADE) end
		current = track
	end
	if track and madeFor then
		track:AdjustSpeed(math.clamp(speed / madeFor, 0.5, 1.5))
	end

	-- the lantern arm plays on top of whatever the legs are doing (the lantern sets "LanternOn" on your character)
	local lantern = tracks.LanternHold
	if lantern then
		local on = humanoid.Parent and humanoid.Parent:GetAttribute("LanternOn") == true
		if on and not lantern.IsPlaying then
			lantern:Play(FADE)
		elseif not on and lantern.IsPlaying then
			lantern:Stop(FADE)
		end
	end
end)
