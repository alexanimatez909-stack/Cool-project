-- CameraFeel (LocalScript in StarterPlayer > StarterPlayerScripts)
-- DOORS-style reactive first-person camera: head bob on every footstep, a lean when you
-- turn or sidestep, a wider view while sprinting, breathing (faint when rested, heavy when
-- tired) and a wobble when you're out of breath.
-- Every frame, Roblox's own camera script places the camera; this runs straight after it
-- and nudges that position, so the effects never build up or fight the mouse.
-- All numbers are in ReplicatedStorage.Config. "Reduce motion" (Z for now) turns the effects off.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

State.reduceMotion = Config.REDUCE_MOTION_DEFAULT

local function lerp(a, b, t) return a + (b - a) * t end
local function smooth(rate, dt) return 1 - math.exp(-rate * dt) end -- frame-rate independent easing

local phase = 0          -- walking cycle: one footstep every half turn (pi)
local bobAmount = 0      -- 0 standing still .. 1 walking
local sprintMix = 0      -- 0 walking .. 1 sprinting (eased, so bob size changes smoothly)
local roll = 0           -- current lean
local rollVelocity = 0   -- how fast the lean is changing (the spring's momentum)
local shakeAmount = 0    -- 0 .. 1, eases in while exhausted
local shakeTime = 0
local breathAmount = 0   -- 0 rested .. 1 out of breath (eased)
local breathPhase = 0    -- one full breath per turn (2*pi)
local fov = Config.CAMERA_FOV
local lagPitch, lagYaw = nil, nil                        -- where the "heavy" view is actually looking
local mouseYaw, lastBaseYaw = nil, nil                   -- total turning so far (keeps counting past a full circle)
local lastYaw = nil
local applied = CFrame.identity -- the effect added last frame

-- Roblox's camera script starts each frame from wherever the camera was left, so an effect
-- left in place would pile up frame after frame (the view creeps down or sideways).
-- Just before it runs, take last frame's effect back off; it's added fresh afterwards.
RunService:BindToRenderStep("CameraFeelUndo", Enum.RenderPriority.Camera.Value - 1, function()
	camera.CFrame = camera.CFrame * applied:Inverse()
	applied = CFrame.identity
end)

RunService:BindToRenderStep("CameraFeel", Enum.RenderPriority.Camera.Value + 1, function(dt)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or humanoid.Health <= 0 then return end
	local reduce = State.reduceMotion

	-- wider view while sprinting
	local targetFov = Config.CAMERA_FOV + ((State.sprinting and not reduce) and (Config.SPRINT_FOV - Config.CAMERA_FOV) or 0)
	fov = lerp(fov, targetFov, smooth(Config.FOV_SMOOTHING, dt))
	camera.FieldOfView = fov

	local velocity = root.AssemblyLinearVelocity
	local flat = Vector3.new(velocity.X, 0, velocity.Z)
	local speed = flat.Magnitude
	local grounded = humanoid.FloorMaterial ~= Enum.Material.Air

	-- head bob, tied to distance walked so every dip is a footstep
	sprintMix = lerp(sprintMix, State.sprinting and 1 or 0, smooth(6, dt))
	local stepLength = lerp(Config.BOB_STEP_LENGTH_WALK, Config.BOB_STEP_LENGTH_SPRINT, sprintMix)
	if grounded and speed > 0.5 then
		local before = math.floor(phase / math.pi)
		phase += speed * dt / stepLength * math.pi
		if math.floor(phase / math.pi) > before then
			State.footsteps += 1
		end
	end
	local moving = grounded and speed > 0.5
	bobAmount = lerp(bobAmount, moving and math.min(speed / Config.WALK_SPEED, 1.3) or 0, smooth(8, dt))

	-- turning and sidestepping lean
	local look = camera.CFrame.LookVector
	local yaw = math.deg(math.atan2(-look.X, -look.Z))
	local yawRate = 0
	if lastYaw then
		yawRate = (yaw - lastYaw + 180) % 360 - 180 -- shortest way round
		yawRate /= math.max(dt, 1e-3)
	end
	lastYaw = yaw
	local strafe = camera.CFrame.RightVector:Dot(flat) / Config.WALK_SPEED
	local targetRoll = -strafe * Config.STRAFE_TILT + yawRate * Config.TURN_TILT
	targetRoll = math.clamp(targetRoll, -Config.TILT_MAX, Config.TILT_MAX)
	-- the lean is a spring: it swings towards the target, overshoots a little, then settles,
	-- so stopping a fast turn makes the view swing past centre and spring back
	local step = math.min(dt, 1 / 30) -- a very slow frame can't make the spring fly off
	rollVelocity += ((targetRoll - roll) * Config.TILT_SPRING_STIFFNESS - rollVelocity * Config.TILT_SPRING_DAMPING) * step
	roll += rollVelocity * step

	-- out-of-breath wobble
	shakeAmount = lerp(shakeAmount, State.exhausted and 1 or 0, smooth(3, dt))
	shakeTime += dt * Config.EXHAUSTED_SHAKE_SPEED

	-- breathing: the view slowly rises and falls. Faint and slow when rested,
	-- deep and quick the more stamina you've used, heaviest when you've run out.
	local tired = State.exhausted and 1 or (1 - State.stamina)
	breathAmount = lerp(breathAmount, tired, smooth(1.5, dt))
	breathPhase += dt * lerp(Config.BREATH_RATE_CALM, Config.BREATH_RATE_TIRED, breathAmount) * 2 * math.pi
	local breath = math.sin(breathPhase)
	local breathY = breath * lerp(Config.BREATH_HEIGHT_CALM, Config.BREATH_HEIGHT_TIRED, breathAmount)
	local breathPitch = breath * lerp(Config.BREATH_NOD_CALM, Config.BREATH_NOD_TIRED, breathAmount)

	-- camera weight: ease the view towards where the mouse points instead of snapping to it
	local basePitch, baseYaw = camera.CFrame:ToOrientation()
	-- Add up how far the mouse turned this frame. Comparing against the running total (instead of
	-- taking the "shortest way round" to the lagging view) means a very fast fling can never make
	-- the view turn back the wrong way.
	if lastBaseYaw then
		mouseYaw += (baseYaw - lastBaseYaw + math.pi) % (2 * math.pi) - math.pi
	else
		mouseYaw = baseYaw
	end
	lastBaseYaw = baseYaw
	if Config.CAMERA_TURN_SMOOTHING > 0 and lagYaw then
		local a = smooth(Config.CAMERA_TURN_SMOOTHING, dt)
		lagPitch = lerp(lagPitch, basePitch, a)
		lagYaw = lerp(lagYaw, mouseYaw, a)
		-- never trail too far behind the mouse
		local maxLag = math.rad(Config.CAMERA_MAX_LAG)
		lagYaw = mouseYaw + math.clamp(lagYaw - mouseYaw, -maxLag, maxLag)
		lagPitch = basePitch + math.clamp(lagPitch - basePitch, -maxLag, maxLag)
	else
		lagPitch, lagYaw = basePitch, mouseYaw
	end
	-- keep the running totals small (a full circle is the same direction)
	local fullTurns = math.floor(mouseYaw / (2 * math.pi)) * 2 * math.pi
	mouseYaw -= fullTurns
	lagYaw -= fullTurns
	local lag = CFrame.fromOrientation(basePitch, baseYaw, 0):Inverse() * CFrame.fromOrientation(lagPitch, lagYaw, 0)

	if reduce then
		applied = lag
		camera.CFrame = camera.CFrame * applied
		return
	end

	local height = lerp(Config.BOB_HEIGHT_WALK, Config.BOB_HEIGHT_SPRINT, sprintMix)
	local sway = lerp(Config.BOB_SWAY_WALK, Config.BOB_SWAY_SPRINT, sprintMix)
	local bobRoll = lerp(Config.BOB_ROLL_WALK, Config.BOB_ROLL_SPRINT, sprintMix)
	local nod = lerp(Config.BOB_NOD_WALK, Config.BOB_NOD_SPRINT, sprintMix)
	-- 'land' peaks sharply each time a foot lands (every half turn of the cycle, when a footstep is counted)
	local land = 1 - math.abs(math.sin(phase))
	local bobY = -land * height * bobAmount                      -- head drops as the foot lands
	local bobX = math.sin(phase) * sway * bobAmount              -- left foot, right foot
	local shake = Config.EXHAUSTED_SHAKE * shakeAmount
	local pitch = math.noise(shakeTime, 0.3) * shake - land * nod * bobAmount + breathPitch -- and nods down with it
	local turn = math.noise(0.7, shakeTime) * shake

	applied = lag
		* CFrame.new(bobX, bobY + breathY, 0)
		* CFrame.Angles(math.rad(pitch), math.rad(turn), math.rad(roll + math.sin(phase) * bobRoll * bobAmount))
	camera.CFrame = camera.CFrame * applied
end)

-- "Reduce motion" toggle, with a short message so you know it changed
local toast = Instance.new("ScreenGui")
toast.Name = "ReduceMotionMessage"
toast.ResetOnSpawn = false
local text = Instance.new("TextLabel")
text.AnchorPoint = Vector2.new(0.5, 0)
text.Position = UDim2.new(0.5, 0, 0, 80)
text.Size = UDim2.fromOffset(300, 28)
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(215, 210, 200)
text.TextStrokeTransparency = 0.5
text.TextSize = 18
text.Font = Enum.Font.Gotham
text.Visible = false
text.Parent = toast
toast.Parent = player:WaitForChild("PlayerGui")

local shown = 0
local function message(s)
	text.Text = s
	text.Visible = true
	shown += 1
	local mine = shown
	task.delay(2, function()
		if shown == mine then text.Visible = false end
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode[Config.REDUCE_MOTION_KEY] then
		State.reduceMotion = not State.reduceMotion
		message("Reduce motion: " .. (State.reduceMotion and "ON" or "OFF"))
	end
end)
