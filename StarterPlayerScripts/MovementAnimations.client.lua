-- MovementAnimations (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Plays OUR movement animations (Config.MOVEMENT_ANIMATIONS) instead of Roblox's default ones:
-- idle, walk, sprint, crouch, crouch-walk, out of breath, and the lantern held up on top.
-- It reads what your body is doing from MovementState (written by the Movement script), picks one animation,
-- and speeds it up or slows it down to match how fast you're really moving, so your feet don't slide.
-- Runs on your own computer: Roblox automatically shows your character's animations to everyone else.
-- Until the Walk ID is filled in, it does nothing and Roblox's default animations keep playing.
-- It also turns jumping off (Config.ALLOW_JUMP).
-- Direction (like DOORS, the body changes shape with direction): walking backwards plays the walk in reverse,
-- and moving sideways or diagonally turns the hips toward where you're going (the chest stays facing forward)
-- with a slight lean. That twist is added on every player's computer for every character, so everyone sees it.
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
		-- walking backwards plays the step in reverse
		local localMove = root.CFrame:VectorToObjectSpace(velocity)
		local backwards = -localMove.Z < -0.2 * speed
		track:AdjustSpeed(math.clamp(speed / madeFor, 0.5, 1.5) * (backwards and -1 or 1))
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

-- Hips turn toward the direction of travel; chest stays forward. Worked out from each character's own
-- velocity, so it runs here for EVERY player (joint changes made by a script aren't shared automatically).
local twist = {} -- character -> { yaw, lean } (eased)
RunService.PreSimulation:Connect(function(dt)
	local ease = 1 - math.exp(-Config.STRAFE_SMOOTHING * dt)
	for _, other in Players:GetPlayers() do
		local character = other.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		local lower = character and character:FindFirstChild("LowerTorso")
		local upper = character and character:FindFirstChild("UpperTorso")
		local rootJoint = lower and lower:FindFirstChild("Root")
		local waist = upper and upper:FindFirstChild("Waist")
		if hrp and rootJoint and waist then
			local v = hrp.CFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity)
			local forward, side = -v.Z, v.X
			local targetYaw, targetLean = 0, 0
			if math.sqrt(forward * forward + side * side) > 1 then
				local maxTurn = math.rad(Config.STRAFE_HIP_TURN)
				targetYaw = math.clamp(math.atan2(side, math.abs(forward)), -maxTurn, maxTurn)
				if forward < 0 then targetYaw = -targetYaw end -- walking backwards: the hips turn the other way
				targetYaw = -targetYaw -- positive turns left, and moving right should turn the hips right
				targetLean = -math.clamp(side / Config.WALK_SPEED, -1, 1) * math.rad(Config.STRAFE_LEAN)
			end
			local t = twist[character]
			if not t then
				t = { yaw = 0, lean = 0 }
				twist[character] = t
				character.AncestryChanged:Connect(function(_, parent)
					if not parent then twist[character] = nil end
				end)
			end
			t.yaw += (targetYaw - t.yaw) * ease
			t.lean += (targetLean - t.lean) * ease
			rootJoint.Transform = rootJoint.Transform * CFrame.Angles(0, t.yaw, t.lean)
			waist.Transform = waist.Transform * CFrame.Angles(0, -t.yaw, 0)
		end
	end
end)
