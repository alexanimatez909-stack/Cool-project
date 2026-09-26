-- Paste into Studio's Command Bar (View > Command Bar) and press Enter.
-- Replaces the scripts below with the versions from the repo.
local done = {}
do
	local parent = game
	for part in ("ReplicatedStorage"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("Config")
	if s and s.ClassName ~= "ModuleScript" then s:Destroy(); s = nil end
	s = s or Instance.new("ModuleScript")
	s.Name = "Config"
	s.Source = [=[
-- Config (ModuleScript in ReplicatedStorage)
-- The game's "settings sheet". Every tuning number lives here, so
-- balancing the game means editing this one file.
-- Other scripts read it with:  local Config = require(game.ReplicatedStorage.Config)

local Config = {}

---------------------------------------------------------------------
-- NIGHT (3 church bells)
---------------------------------------------------------------------
Config.BELLS_PER_NIGHT = 3      -- how many bells ring in one night
Config.BELL_LENGTH = 45         -- seconds between bells
Config.FOG_AT_BELL = 2          -- fog rolls in when this bell rings
Config.LAMPS_OUT_AT_BELL = 3    -- gas lamps flicker out at this bell

---------------------------------------------------------------------
-- DAY (debate + vote in the Courthouse)
---------------------------------------------------------------------
Config.DAY_DISCUSSION_LENGTH = nil  -- TODO: decide (seconds)
Config.DAY_VOTE_LENGTH = nil        -- TODO: decide (seconds)

---------------------------------------------------------------------
-- MOVEMENT (placeholder guesses - tune after playtesting)
---------------------------------------------------------------------
Config.FIRST_PERSON_AT_START = true -- lock the camera to first person (the night cycle will switch it later)
Config.WALK_SPEED = 18          -- normal walking speed (Roblox's default is 16)
Config.SPRINT_SPEED = 28        -- hold Shift (killers are no faster than anyone)
Config.CROUCH_SPEED = 8         -- placeholder

-- Crouch (quiet, slow). Sprinting stands you up.
Config.CROUCH_KEY = "C"
Config.CROUCH_TOGGLE = true         -- true = press to crouch / press again to stand; false = hold to crouch
Config.CROUCH_CAMERA_DROP = 2       -- how many studs your eyes drop while crouched
Config.CROUCH_CAMERA_SMOOTHING = 12 -- how quickly the view sinks and rises (higher = snappier)

-- Stamina (only sprinting uses it). Times in seconds.
Config.STAMINA_DRAIN_TIME = 7   -- full bar to empty while sprinting
Config.STAMINA_REFILL_DELAY = 2 -- pause after you stop sprinting before it starts refilling
Config.STAMINA_REFILL_TIME = 5  -- empty to full while walking or standing
Config.STAMINA_RESPRINT_AT = 0.25 -- after running out, you can't sprint again until the bar is back to 25%
Config.STAMINA_BAR_HIDE_DELAY = 1.5 -- the bar fades away this long after it's full again

---------------------------------------------------------------------
-- CAMERA FEEL (DOORS-style). Distances in studs, angles in degrees.
---------------------------------------------------------------------
Config.CAMERA_FOV = 70              -- normal field of view
Config.SPRINT_FOV = 80              -- widens while sprinting
Config.FOV_SMOOTHING = 6            -- how quickly the view widens/narrows (higher = snappier)

-- Head bob: one dip per footstep. Step length decides how often you step.
Config.BOB_STEP_LENGTH_WALK = 8     -- studs travelled per footstep while walking
Config.BOB_STEP_LENGTH_SPRINT = 10
Config.BOB_HEIGHT_WALK = 0.15       -- how far the head dips each step (the main DOORS-style bob)
Config.BOB_HEIGHT_SPRINT = 0.38
Config.BOB_NOD_WALK = 0.35          -- the view nods down slightly as each foot lands
Config.BOB_NOD_SPRINT = 0.9
Config.BOB_SWAY_WALK = 0.02         -- side-to-side sway (left foot, right foot) - kept small
Config.BOB_SWAY_SPRINT = 0.04
Config.BOB_ROLL_WALK = 0.1          -- slight roll with each step
Config.BOB_ROLL_SPRINT = 0.2

-- Camera weight: the view follows the mouse with a tiny smooth delay instead of snapping.
-- Higher = snappier (lighter). 0 switches it off. Not turned off by reduce motion (it calms the view).
Config.CAMERA_TURN_SMOOTHING = 18

-- Temporary test keys while tuning the camera (switch off before release)
Config.CAMERA_TEST_KEYS = true
Config.TEST_WEIGHT_KEY = "X"        -- cycles camera weight: off / light / medium / heavy
Config.TEST_WEIGHT_STEPS = { 0, 30, 18, 10 }
Config.TEST_FOV_KEY = "V"           -- cycles the normal field of view (sprinting adds the same amount on top)
Config.TEST_FOV_STEPS = { 60, 65, 70, 75 }

-- Tilt: gentle and smooth, like DOORS
Config.STRAFE_TILT = 1              -- lean into a sidestep (A/D) at full walking speed
Config.TURN_TILT = 0.004            -- lean per degree-per-second of turning the camera
Config.TILT_MAX = 1.5
Config.TILT_SMOOTHING = 3           -- lower = the lean eases in and out more slowly

-- Out of breath (while the stamina bar is red)
Config.EXHAUSTED_SHAKE = 0.6        -- wobble size
Config.EXHAUSTED_SHAKE_SPEED = 1.8  -- wobble speed

-- Reduce motion: turns off bob, tilt, shake and the sprint FOV change
Config.REDUCE_MOTION_DEFAULT = false
Config.REDUCE_MOTION_KEY = "Z"      -- temporary toggle key until there's a settings menu

---------------------------------------------------------------------
-- TEAMS: how many Good / Evil / Informants for each lobby size
---------------------------------------------------------------------
Config.LOBBY_SPLITS = {
	[8]  = { Good = 4, Evil = 4, Informants = 0 },
	[12] = { Good = 5, Evil = 5, Informants = 2 },
	[16] = { Good = 7, Evil = 7, Informants = 2 },
	[20] = { Good = 9, Evil = 8, Informants = 3 },
}

---------------------------------------------------------------------
-- RULES
---------------------------------------------------------------------
Config.FRIENDLY_FIRE = true         -- killers can kill their own teammates
Config.KILL_COOLDOWN = nil          -- TODO: decide (seconds)
Config.TEAMKILL_COOLDOWN = nil      -- TODO: decide (should be "very long")

---------------------------------------------------------------------
-- MAP (greybox city). Heights in studs. Buildings get a random height
-- inside their district's {min, max}; the same seed always gives the same city.
---------------------------------------------------------------------
Config.CITY_SEED = 1

-- Houses are 3-5 storeys (40-65 studs, from the scale plan) so streets feel like tall London canyons.
-- Landmarks below are taller still - they're what you navigate by.
Config.DISTRICT_HEIGHTS = {             -- from the map-plan generator
	Market       = { 40, 50 },
	Terraces     = { 50, 60 },          -- grand stucco rows
	Soho         = { 45, 60 },
	CourthouseSq = { 45, 58 },
	CathedralQtr = { 38, 50 },          -- old Tudor houses, lowest
	Docks        = { 48, 65 },          -- warehouses, tallest
}

Config.LANDMARK_HEIGHTS = {             -- from the map-plan generator
	Courthouse = 70,
	CourthouseDome = 95,
	Cathedral = 75,
	Spire = 170,
	Mausoleum = 20,
	MarketHall = 55,
	FlowerHall = 60,
	Church = 60,
	ChurchSteeple = 90,
	Chimney = 120,
	Viaduct = 45,
	NewspaperOffice = 50,               -- Soho press building
	GoodsStation = 70,                  -- through shed at the west end of the Docks
	MusicHall = 50,
	GoodsViaduct = 15,                  -- low brick viaduct bringing the goods line in from the west (scenery)
	BackdropSpire = 110,                -- church spires on the far (south) bank (scenery)
}

-- Map edges (plan v6): streets run on into a backdrop city and are stopped by visible props,
-- with an invisible safety wall along the playable edge behind them.
Config.EDGE_BLOCKER_HEIGHT = 10         -- police cordons and road-works hoardings: taller than a jump
Config.EDGE_GATES_HEIGHT = 16           -- locked iron gates between brick piers
Config.SAFETY_WALL_HEIGHT = 60          -- invisible, only a safety net behind the visible blockers

return Config
]=]
	s.Parent = parent
	table.insert(done, "ReplicatedStorage.Config")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("MovementState")
	if s and s.ClassName ~= "ModuleScript" then s:Destroy(); s = nil end
	s = s or Instance.new("ModuleScript")
	s.Name = "MovementState"
	s.Source = [=[
-- MovementState (ModuleScript in StarterPlayer > StarterPlayerScripts)
-- What the local player's body is doing right now. The Movement and CameraFeel scripts write it;
-- the stamina bar and other effects only read it.
return {
	stamina = 1,          -- 0 = empty, 1 = full
	sprinting = false,    -- running right now
	exhausted = false,    -- ran out; can't sprint again until stamina is back to Config.STAMINA_RESPRINT_AT
	crouching = false,    -- crouched right now (Movement writes it; CameraFeel lowers the view)
	footsteps = 0,        -- counts up once per footstep (CameraFeel); footstep sounds will listen to this
	reduceMotion = false, -- player setting: no head bob, tilt, shake or sprint FOV change
}
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.MovementState")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("Movement")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "Movement"
	s.Source = [=[
-- Movement (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The one script that decides how fast you move: walk, sprint while Shift is held, or crouch.
-- Sprinting uses stamina; all the numbers are in ReplicatedStorage.Config.
-- Crouching only slows you and sets State.crouching; CameraFeel lowers the view.
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

local function onCharacter(character)
	humanoid = character:WaitForChild("Humanoid")
	State.stamina, State.sprinting, State.exhausted, State.crouching = 1, false, false, false
	crouchWanted = false
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
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.Movement")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("CameraFeel")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "CameraFeel"
	s.Source = [=[
-- CameraFeel (LocalScript in StarterPlayer > StarterPlayerScripts)
-- DOORS-style reactive first-person camera: head bob on every footstep, a lean when you
-- turn or sidestep, a wider view while sprinting, a wobble when you're out of breath,
-- and a lower view while crouching.
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
local shakeAmount = 0    -- 0 .. 1, eases in while exhausted
local shakeTime = 0
local crouchMix = 0      -- 0 standing .. 1 crouched (eased, so the view sinks smoothly)
local fov = Config.CAMERA_FOV
local baseFov = Config.CAMERA_FOV                        -- the test key can change these two
local turnSmoothing = Config.CAMERA_TURN_SMOOTHING
local lagPitch, lagYaw = nil, nil                        -- where the "heavy" view is actually looking
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

	-- crouching lowers your eyes. CameraOffset is Roblox's own "move the view, not the body"
	-- setting, so it doesn't pile up like the effects below. Stays on with reduce motion,
	-- because it shows where your head really is.
	crouchMix = lerp(crouchMix, State.crouching and 1 or 0, smooth(Config.CROUCH_CAMERA_SMOOTHING, dt))
	humanoid.CameraOffset = Vector3.new(0, -Config.CROUCH_CAMERA_DROP * crouchMix, 0)

	-- wider view while sprinting
	local targetFov = baseFov + ((State.sprinting and not reduce) and (Config.SPRINT_FOV - Config.CAMERA_FOV) or 0)
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
	roll = lerp(roll, targetRoll, smooth(Config.TILT_SMOOTHING, dt))

	-- out-of-breath wobble
	shakeAmount = lerp(shakeAmount, State.exhausted and 1 or 0, smooth(3, dt))
	shakeTime += dt * Config.EXHAUSTED_SHAKE_SPEED

	-- camera weight: ease the view towards where the mouse points instead of snapping to it
	local basePitch, baseYaw = camera.CFrame:ToOrientation()
	if turnSmoothing > 0 and lagYaw then
		local a = smooth(turnSmoothing, dt)
		lagPitch = lerp(lagPitch, basePitch, a)
		lagYaw += ((baseYaw - lagYaw + math.pi) % (2 * math.pi) - math.pi) * a -- shortest way round
	else
		lagPitch, lagYaw = basePitch, baseYaw
	end
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
	local pitch = math.noise(shakeTime, 0.3) * shake - land * nod * bobAmount -- and nods down with it
	local turn = math.noise(0.7, shakeTime) * shake

	applied = lag
		* CFrame.new(bobX, bobY, 0)
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

local WEIGHT_NAMES = { [0] = "off" }
local function cycle(list, current)
	local i = table.find(list, current) or 0
	return list[i % #list + 1]
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode[Config.REDUCE_MOTION_KEY] then
		State.reduceMotion = not State.reduceMotion
		message("Reduce motion: " .. (State.reduceMotion and "ON" or "OFF"))
	elseif Config.CAMERA_TEST_KEYS and input.KeyCode == Enum.KeyCode[Config.TEST_WEIGHT_KEY] then
		turnSmoothing = cycle(Config.TEST_WEIGHT_STEPS, turnSmoothing)
		message("Camera weight: " .. (WEIGHT_NAMES[turnSmoothing] or tostring(turnSmoothing)) .. "  (lower = heavier)")
	elseif Config.CAMERA_TEST_KEYS and input.KeyCode == Enum.KeyCode[Config.TEST_FOV_KEY] then
		baseFov = cycle(Config.TEST_FOV_STEPS, baseFov)
		message("Field of view: " .. baseFov)
	end
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.CameraFeel")
end
print("INSTALL" .. "ED: " .. table.concat(done, ", "))
