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
-- NIGHT: three bells start three stages of different lengths (seconds)
---------------------------------------------------------------------
Config.NIGHT_STAGES = {
	{ name = "Dusk", length = 60 },      -- bell 1: lamps on, light fog, everyone spreads out
	{ name = "DeepNight", length = 75 }, -- bell 2: some districts go dark, main hunting time
	{ name = "LastHour", length = 30 },  -- bell 3: short, tense final push
}
Config.DARK_FROM_STAGE = 2           -- districts go dark when this bell rings
Config.DARK_DISTRICT_CHOICES = { "Market", "Terraces", "Soho", "CathedralQtr", "Docks" } -- Courthouse Square never goes dark
Config.DARK_DISTRICTS_MIN = 2        -- how many districts go dark each night (picked at random)
Config.DARK_DISTRICTS_MAX = 3
Config.BELL_SOUND_ID = 6891548543            -- church bell sound ID number (0 = silent for now)
Config.BELL_TOLL_GAP = 2.5           -- seconds between tolls (bell 2 tolls twice, bell 3 three times)
Config.BELL_SPEED = 0.85             -- 1 = as recorded; lower = slower, deeper and longer
Config.BELL_ECHO_TIME = 6            -- seconds the echo takes to fade away (higher = slower fade)
Config.BELL_ECHO_LEVEL = 0           -- how loud the echo is (0 = as loud as the bell, -10 = quieter)
Config.BELL_FADE_TIME = 3            -- each toll fades out over its last few seconds (hides a sudden cut)
Config.NIGHT_START_DELAY = 5        -- seconds between being gathered in the Courthouse Square and the first bell
Config.NIGHT_SPAWN_RADIUS = 15       -- players are spread in a circle this wide (studs) round the NightSpawn marker
Config.DAY_PLACEHOLDER_LENGTH = 10   -- for now day is just a pause before the next night
Config.CLOCK_SHOW_TIMER = true       -- show the countdown on screen (false = just the night and stage)
Config.NIGHT_TEST_SPEED = 1          -- 1 = normal speed; e.g. 5 = the whole cycle runs 5x faster (testing only)

-- Fog (0 = clear, 1 = very thick). Each stage's amount rolls in gradually.
Config.FOG = { Day = 0.25, Dusk = 0.35, DeepNight = 0.5, LastHour = 0.5, Dawn = 0.38 }
Config.FOG_LIFT_START = 0.6          -- in the last hour, fog only starts lifting after 60% of the stage has passed
Config.FOG_CHANGE_SPEED = 0.3        -- how fast the fog rolls in between stages (lower = slower)

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
Config.STAMINA_BAR_IMAGE_ID = 0     -- the uploaded art/stamina-frame.png image ID (0 = plain outline for now)
Config.STAMINA_BAR_SIZE = 0.09      -- height of the whole bar as a share of the screen height (0.09 = 9%)
Config.STAMINA_BAR_MARGIN = 0.02    -- gap from the bottom-left corner as a share of the screen
Config.STAMINA_LOW_AT = 0.25        -- below this much stamina (25%) the bar flashes red
Config.STAMINA_FLASH_SPEED = 6      -- how fast it flashes (higher = faster)

-- Footsteps: a sound per floor. The name is the part's Material (e.g. Cobblestone, Slate) or, if the
-- part has an attribute "FootstepSound", that text. Several IDs = a random one each step. 0 = silent.
Config.FOOTSTEP_SOUNDS = {
	Cobblestone = { 0 },            -- the cobbled roads
	Slate = { 0 },                  -- stone-block pavements (change the name to match your pavement's Material)
	Default = { 0 },                -- anything not listed above
}
Config.FOOTSTEP_VOLUME = { Crouch = 0.12, Walk = 0.45, Sprint = 0.9 }
-- Per floor loudness, to even out recordings that are quieter or louder (1 = normal, 2 = twice as loud).
-- Use the same names as in FOOTSTEP_SOUNDS. Floors not listed stay at 1.
Config.FOOTSTEP_FLOOR_VOLUME = {
	Slate = 2,                      -- the pavement recording is quieter than the cobbles
}
Config.FOOTSTEP_HEARING_DISTANCE = { Crouch = 15, Walk = 45, Sprint = 100 } -- studs; how far other players hear you
Config.FOOTSTEP_PITCH_VARIATION = 0.08 -- each step slightly higher or lower, so it doesn't sound robotic
Config.FOOTSTEP_DEBUG = true           -- prints the name of the floor you walk on (turn off when done)

---------------------------------------------------------------------
-- CAMERA FEEL (DOORS-style). Distances in studs, angles in degrees.
---------------------------------------------------------------------
Config.CAMERA_FOV = 70              -- normal field of view
Config.SPRINT_FOV = 80              -- widens while sprinting
Config.FOV_SMOOTHING = 6            -- how quickly the view widens/narrows (higher = snappier)

-- Head bob: one dip per footstep. Step length decides how often you step.
Config.BOB_STEP_LENGTH_WALK = 8     -- studs travelled per footstep while walking
Config.BOB_STEP_LENGTH_SPRINT = 7      -- quick running rhythm (footstep sounds follow the same steps)
Config.BOB_HEIGHT_WALK = 0.15       -- how far the head dips each step (the main DOORS-style bob)
Config.BOB_HEIGHT_SPRINT = 0.2     -- small, because running steps are quick
Config.BOB_NOD_WALK = 0.35          -- the view nods down slightly as each foot lands
Config.BOB_NOD_SPRINT = 0.5
Config.BOB_SWAY_WALK = 0.02         -- side-to-side sway (left foot, right foot) - kept small
Config.BOB_SWAY_SPRINT = 0.04
Config.BOB_ROLL_WALK = 0.1          -- slight roll with each step
Config.BOB_ROLL_SPRINT = 0.12

-- Camera weight: the view follows the mouse with a tiny smooth delay instead of snapping.
-- Higher = snappier (lighter), lower = heavier. 0 switches it off. Not turned off by reduce motion (it calms the view).
Config.CAMERA_TURN_SMOOTHING = 10
Config.CAMERA_MAX_LAG = 180         -- the heavy view never trails more than this many degrees behind the mouse

-- Tilt: gentle and smooth, like DOORS
Config.STRAFE_TILT = 1              -- lean into a sidestep (A/D) at full walking speed
Config.TURN_TILT = 0.012            -- lean per degree-per-second of turning the camera
Config.TILT_MAX = 4
Config.TILT_SMOOTHING = 6           -- only used by older versions of CameraFeel (safe to keep)
-- The lean moves like a spring, so it overshoots a little and swings back when you stop turning.
Config.TILT_SPRING_STIFFNESS = 60   -- how hard it pulls towards the lean (higher = quicker)
Config.TILT_SPRING_DAMPING = 8      -- how quickly the swinging dies down (lower = more wobble, higher = no overshoot)

-- Out of breath (while the stamina bar is red)
Config.EXHAUSTED_SHAKE = 2          -- wobble size
Config.EXHAUSTED_SHAKE_SPEED = 2.5  -- wobble speed

-- Breathing: the view gently rises and falls. Faint when rested, deep and quick when out of breath.
Config.BREATH_RATE_CALM = 0.25      -- breaths per second when rested
Config.BREATH_RATE_TIRED = 0.9      -- breaths per second when out of breath
Config.BREATH_HEIGHT_CALM = 0.03    -- how far the view rises per breath (studs)
Config.BREATH_HEIGHT_TIRED = 0.15
Config.BREATH_NOD_CALM = 0.15       -- how far the view tilts up per breath (degrees)
Config.BREATH_NOD_TIRED = 1.2

-- Breathing sound (only you hear it). Louder and faster the less stamina you have.
Config.BREATH_SOUND_ID = 8258601662         -- the sound's ID number from the Creator Store (0 = no sound)
Config.BREATH_SOUND_START_AT = 0.35 -- breathing starts when stamina drops below 35%, loudest at 0%
Config.BREATH_VOLUME_CALM = 0       -- volume when rested (0 = silent)
Config.BREATH_VOLUME_TIRED = 0.8    -- volume when out of stamina
Config.BREATH_SPEED_CALM = 0.9      -- playback speed when rested (lower = slower and deeper)
Config.BREATH_SPEED_TIRED = 1.15    -- playback speed when out of breath (faster panting)
Config.BREATH_SOUND_SMOOTHING = 2   -- how quickly the sound follows your stamina (higher = quicker)

-- Visible body: look down to see your torso, arms and legs (the head always stays hidden)
Config.SHOW_BODY_IN_FIRST_PERSON = true
Config.FIRST_PERSON_BODY = { Legs = true, Torso = false, Arms = false } -- which parts you see when you look down
Config.FIRST_PERSON_ARM_SWING = 0.3 -- how much your arms swing in first person (0 = still at your sides, 1 = full animation)
Config.CAMERA_FORWARD_OFFSET = 1    -- moves your eyes forward (studs) so you don't look out from behind your head
Config.CROUCH_ANIMATION_ID = 0      -- your crouch animation's ID number (0 = none yet: the body hides while crouched)

-- Reduce motion: turns off bob, tilt, shake and the sprint FOV change
Config.REDUCE_MOTION_DEFAULT = false
Config.REDUCE_MOTION_KEY = "Z"      -- temporary toggle key until there's a settings menu

---------------------------------------------------------------------
-- AVATARS: everyone the same size with standard animations (fair hiding, same camera height)
---------------------------------------------------------------------
Config.AVATAR_SCALE = { Height = 1, Width = 1, Depth = 1, Head = 1, BodyType = 0, Proportion = 0 }
-- Everyone uses these animations, whatever pack they own. Catalog IDs of Roblox animations; 0 = Roblox's standard one.
-- Currently the Rthro pack (Roblox's most natural-looking one).
Config.AVATAR_ANIMATIONS = {
	Walk = 2510202577,
	Run = 2510198475,
	Idle = 0,          -- TODO: Rthro Idle catalog ID (2510197257 was wrong)
	Jump = 0,          -- TODO: Rthro Jump catalog ID (2510197830 was wrong)
	Fall = 2510195892,
	Climb = 0,         -- TODO: Rthro Climb catalog ID (2510192778 was wrong)
	Swim = 0,          -- TODO: Rthro Swim catalog ID (2510199791 was wrong)
	Mood = 0,
}
Config.FORCE_DEFAULT_BODY_PARTS = true  -- standard body shape (tall or oddly shaped bodies would still differ in size)

---------------------------------------------------------------------
-- JOURNAL
---------------------------------------------------------------------
Config.JOURNAL_KEY = "J"            -- opens and closes the journal
Config.JOURNAL_LEFT_IMAGE_ID = 0    -- uploaded art/journal-left.png (0 = plain parchment for now)
Config.JOURNAL_RIGHT_IMAGE_ID = 0   -- uploaded art/journal-right.png
Config.JOURNAL_ICON_IMAGE_ID = 0    -- uploaded art/journal-icon.png: the journal icon in the bottom-right corner
Config.JOURNAL_COVER_IMAGE_ID = 0   -- uploaded art/journal-cover.png: the closed front cover (swings open)
Config.JOURNAL_OPEN_TIME = 0.7      -- seconds for the open animation (book rises, cover swings); 0 = instant
Config.JOURNAL_OPEN_SOUND_ID = 0    -- sound when opening (a book / leather / page sound); 0 = none
Config.JOURNAL_CLOSE_SOUND_ID = 0   -- sound when closing (can be the same ID)
Config.JOURNAL_SOUND_VOLUME = 0.6
Config.JOURNAL_ICON_SIZE = 0.1      -- icon height as a share of the screen height
Config.JOURNAL_ICON_MARGIN = 0.02   -- gap from the bottom-right corner as a share of the screen
Config.JOURNAL_NOTES_MAX = 2000     -- longest your notes can be (characters)
Config.JOURNAL_TEST_CLUES = true    -- testing only: a made-up clue at each bell (turn off once real clues exist)

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
	crouching = false,    -- crouched right now (Movement writes it and lowers the view)
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
	-- front of your head (not behind it), and down while crouching.
	local target = State.crouching and 1 or 0
	crouchMix += (target - crouchMix) * (1 - math.exp(-Config.CROUCH_CAMERA_SMOOTHING * dt))
	humanoid.CameraOffset = Vector3.new(0, -Config.CROUCH_CAMERA_DROP * crouchMix, -Config.CAMERA_FORWARD_OFFSET)
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
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.CameraFeel")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("FirstPerson")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "FirstPerson"
	s.Source = [=[
-- FirstPerson (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Locks the camera to first person. (Movement speed is handled by the Movement script.)
-- Runs on each player's own computer, because the camera belongs to that player only.
-- Later, the night cycle (milestone 4) will switch first person on at night and off for the day debate.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local player = Players.LocalPlayer

local function setFirstPerson(on)
	player.CameraMode = on and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
end

setFirstPerson(Config.FIRST_PERSON_AT_START)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.FirstPerson")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("StaminaBar")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "StaminaBar"
	s.Source = [=[
-- StaminaBar (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The ornate Victorian stamina bar in the bottom-left corner: a brass frame with scrollwork and
-- "Stamina" written above it (an uploaded image, Config.STAMINA_BAR_IMAGE_ID), with the stamina
-- line sliding inside it. It only appears while stamina isn't full. When you're low
-- (below Config.STAMINA_LOW_AT) or out of breath, the whole bar flashes red.
-- It scales with the screen, so it looks the same size on a phone, laptop or big monitor.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer

-- where the see-through channel sits inside the frame image (art/stamina-frame.png, 2048 x 336)
local IMAGE_ASPECT = 2048 / 336
local CHANNEL_POSITION = UDim2.fromScale(0.1484, 0.5536)
local CHANNEL_SIZE = UDim2.fromScale(0.7031, 0.1310)

local FILL_COLOR = Color3.fromRGB(222, 205, 160)      -- warm parchment
local LOW_COLOR = Color3.fromRGB(150, 40, 34)         -- dull red
local FLASH_TINT = Color3.fromRGB(255, 95, 80)        -- what the brass frame flashes towards
local BRASS_COLOR = Color3.fromRGB(176, 141, 79)
local FADE_SPEED = 4 -- how fast it fades in and out (per second)

local gui = Instance.new("ScreenGui")
gui.Name = "StaminaBar"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- holder: bottom-left, sized as a fraction of the screen height, keeping the image's shape
local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.AnchorPoint = Vector2.new(0, 1)
holder.Position = UDim2.new(Config.STAMINA_BAR_MARGIN, 0, 1 - Config.STAMINA_BAR_MARGIN, 0)
holder.Size = UDim2.fromScale(1, Config.STAMINA_BAR_SIZE)
holder.BackgroundTransparency = 1
holder.Parent = gui
local aspect = Instance.new("UIAspectRatioConstraint")
aspect.AspectRatio = IMAGE_ASPECT
aspect.DominantAxis = Enum.DominantAxis.Height
aspect.Parent = holder

-- the dark channel and the stamina line inside it (drawn underneath the frame image)
local track = Instance.new("Frame")
track.Name = "Track"
track.Position = CHANNEL_POSITION
track.Size = CHANNEL_SIZE
track.BackgroundColor3 = Color3.fromRGB(26, 18, 10)
track.BorderSizePixel = 0
track.Parent = holder

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(1, 1)
fill.BackgroundColor3 = FILL_COLOR
fill.BorderSizePixel = 0
fill.Parent = track
local shine = Instance.new("UIGradient") -- lighter at the top, darker at the bottom, like glass
shine.Rotation = 90
shine.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(170, 170, 170))
shine.Parent = fill

local mark = Instance.new("Frame") -- faint mark where you can sprint again after running out
mark.Name = "ResprintMark"
mark.AnchorPoint = Vector2.new(0.5, 0.5)
mark.Position = UDim2.fromScale(Config.STAMINA_RESPRINT_AT, 0.5)
mark.Size = UDim2.new(0, 2, 1, 0)
mark.BackgroundColor3 = BRASS_COLOR
mark.BorderSizePixel = 0
mark.Parent = track

-- the brass frame image on top
local frame = Instance.new("ImageLabel")
frame.Name = "Frame"
frame.Size = UDim2.fromScale(1, 1)
frame.BackgroundTransparency = 1
frame.ZIndex = 2
frame.Parent = holder
if Config.STAMINA_BAR_IMAGE_ID ~= 0 then
	frame.Image = "rbxassetid://" .. Config.STAMINA_BAR_IMAGE_ID
else
	warn("[StaminaBar] No frame image yet: upload art/stamina-frame.png and put its ID in Config.STAMINA_BAR_IMAGE_ID")
	local stroke = Instance.new("UIStroke") -- a plain brass outline until the image is uploaded
	stroke.Color = BRASS_COLOR
	stroke.Thickness = 2
	stroke.Parent = track
end

gui.Parent = player:WaitForChild("PlayerGui")

local visibility = 0     -- 0 = hidden, 1 = fully shown
local fullSince = -math.huge -- starts full and hidden

RunService.RenderStepped:Connect(function(dt)
	local full = State.stamina >= 1
	if not full then fullSince = os.clock() end
	local want = (not full or os.clock() - fullSince < Config.STAMINA_BAR_HIDE_DELAY) and 1 or 0
	visibility += math.clamp(want - visibility, -FADE_SPEED * dt, FADE_SPEED * dt)
	local hide = 1 - visibility

	fill.Size = UDim2.fromScale(State.stamina, 1)

	-- low or out of breath: the line turns red and the whole bar flashes red
	local low = State.exhausted or State.stamina < Config.STAMINA_LOW_AT
	local flash = low and (math.sin(os.clock() * Config.STAMINA_FLASH_SPEED) + 1) / 2 or 0
	fill.BackgroundColor3 = low and LOW_COLOR:Lerp(FLASH_TINT, flash * 0.5) or FILL_COLOR
	frame.ImageColor3 = Color3.new(1, 1, 1):Lerp(FLASH_TINT, flash * 0.75)

	track.BackgroundTransparency = 0.15 + 0.85 * hide
	fill.BackgroundTransparency = hide
	mark.BackgroundTransparency = 0.4 + 0.6 * hide
	frame.ImageTransparency = hide
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.StaminaBar")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("Breathing_Sound")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "Breathing_Sound"
	s.Source = [=[
-- BreathingSound (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Your own breathing: silent until stamina is low, then louder and faster as it runs out.
-- Only you hear it (it plays on your own computer, not out in the world).
-- The sound and all the numbers are in ReplicatedStorage.Config.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))

if not Config.BREATH_SOUND_ID or Config.BREATH_SOUND_ID == 0 then
	warn("[BreathingSound] No sound yet: put a sound ID number in Config.BREATH_SOUND_ID")
	return
end

local sound = Instance.new("Sound")
sound.Name = "Breathing"
sound.SoundId = "rbxassetid://" .. Config.BREATH_SOUND_ID
sound.Looped = true
sound.Volume = 0
sound.Parent = SoundService
sound:Play()

local function lerp(a, b, t) return a + (b - a) * t end
local level = 0 -- 0 rested .. 1 out of breath (eased, so the sound swells and fades smoothly)

RunService.Heartbeat:Connect(function(dt)
	-- silent above BREATH_SOUND_START_AT; from there it builds up to full at empty stamina,
	-- and stays full while you're out of breath (red bar)
	local start = Config.BREATH_SOUND_START_AT
	local tired = math.clamp((start - State.stamina) / start, 0, 1)
	if State.exhausted then tired = 1 end
	level = lerp(level, tired, 1 - math.exp(-Config.BREATH_SOUND_SMOOTHING * dt))
	sound.Volume = lerp(Config.BREATH_VOLUME_CALM, Config.BREATH_VOLUME_TIRED, level)
	sound.PlaybackSpeed = lerp(Config.BREATH_SPEED_CALM, Config.BREATH_SPEED_TIRED, level)
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.Breathing_Sound")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("FirstPersonBody")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "FirstPersonBody"
	s.Source = [=[
-- FirstPersonBody (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Lets you see your own body when you look down in first person.
-- Every frame Roblox hides your whole character in first person; straight after that, this shows
-- the body parts chosen in Config.FIRST_PERSON_BODY (legs / torso / arms) and anything worn on
-- them. The head always stays hidden, because the camera sits inside it.
-- Your arms also swing less in first person (Config.FIRST_PERSON_ARM_SWING) so they stay low and
-- close to your body instead of swinging into view. Only you see that; others see the full animation.
-- Until there's a crouch animation (Config.CROUCH_ANIMATION_ID), the body hides while you crouch,
-- because the lowered camera would otherwise end up inside your chest.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local BODY_GROUPS = {
	Legs = { "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	Torso = { "UpperTorso" },
	Arms = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" },
}

-- the body parts to show right now, as a set: shown[part] = true
local function shownParts(character)
	local shown = {}
	for group, names in BODY_GROUPS do
		if Config.FIRST_PERSON_BODY[group] then
			for _, name in names do
				local part = character:FindFirstChild(name)
				if part then shown[part] = true end
			end
		end
	end
	return shown
end

-- a body part is visible if it's in the shown set; an accessory (belt, jacket, hat...) is visible
-- if the body part it hangs from is shown. Anything on the head is therefore always hidden.
local function isVisible(part, shown)
	if shown[part] then return true end
	if not part:FindFirstAncestorOfClass("Accessory") then return false end
	for _, attachment in part:GetChildren() do
		if attachment:IsA("Attachment") then
			for bodyPart in shown do
				if bodyPart:FindFirstChild(attachment.Name) then return true end
			end
		end
	end
	return false
end

local function isFirstPerson(head)
	return player.CameraMode == Enum.CameraMode.LockFirstPerson
		or (camera.CFrame.Position - head.Position).Magnitude < 3
end

RunService:BindToRenderStep("FirstPersonBody", Enum.RenderPriority.Camera.Value + 2, function()
	if not Config.SHOW_BODY_IN_FIRST_PERSON then return end
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	-- only in first person (in third person Roblox shows everything anyway)
	if not head or not isFirstPerson(head) then return end

	local hideBody = State.crouching and Config.CROUCH_ANIMATION_ID == 0
	local shown = shownParts(character)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = (not hideBody and isVisible(part, shown)) and 0 or 1
		end
	end
end)

-- Calmer arms: each frame the animation poses the arms, then (just before physics) this pulls
-- that pose part of the way back to "arms hanging straight at your sides".
local ARM_JOINTS = { "RightShoulder", "LeftShoulder", "RightElbow", "LeftElbow" }
RunService.PreSimulation:Connect(function()
	local swing = Config.FIRST_PERSON_ARM_SWING
	if swing >= 1 then return end
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head or not isFirstPerson(head) then return end
	for _, name in ARM_JOINTS do
		local joint = character:FindFirstChild(name, true)
		if joint and joint:IsA("Motor6D") then
			joint.Transform = CFrame.identity:Lerp(joint.Transform, swing)
		end
	end
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.FirstPersonBody")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("NightFog")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "NightFog"
	s.Source = [=[
-- NightFog (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Fog that follows the night: light at dusk, thicker in deep night, and in the last hour it
-- slowly starts lifting as dawn gets close. Changes roll in gradually, never instantly.
-- It reads the time from the NightCycle clock (attributes on workspace); all amounts are in
-- ReplicatedStorage.Config. It runs on each player's computer so that later some districts
-- (like the Docks) can be foggier than others depending on where you are.
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

-- Roblox's Atmosphere object draws the fog. Use the one in Lighting, or make one.
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
	atmosphere = Instance.new("Atmosphere")
	atmosphere.Color = Color3.fromRGB(170, 170, 165)
	atmosphere.Decay = Color3.fromRGB(110, 110, 105)
	atmosphere.Parent = Lighting
end

local function smoothstep(t) return t * t * (3 - 2 * t) end -- eases in and out

-- how thick the fog should be right now
local function targetFog()
	local stageName = workspace:GetAttribute("StageName") or "Day"
	local fog = Config.FOG[stageName] or Config.FOG.Day
	if stageName == "LastHour" then
		-- how far through the last hour we are: 0 = just started, 1 = dawn
		local length = Config.NIGHT_STAGES[3].length / Config.NIGHT_TEST_SPEED
		local left = (workspace:GetAttribute("StageEndsAt") or 0) - workspace:GetServerTimeNow()
		local progress = math.clamp(1 - left / length, 0, 1)
		if progress > Config.FOG_LIFT_START then
			local lift = (progress - Config.FOG_LIFT_START) / (1 - Config.FOG_LIFT_START)
			fog += (Config.FOG.Dawn - fog) * smoothstep(lift)
		end
	end
	return fog
end

atmosphere.Density = targetFog()
RunService.Heartbeat:Connect(function(dt)
	local target = targetFog()
	atmosphere.Density += (target - atmosphere.Density) * (1 - math.exp(-Config.FOG_CHANGE_SPEED * dt))
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.NightFog")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("NightClock")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "NightClock"
	s.Source = [=[
-- NightClock (LocalScript in StarterPlayer > StarterPlayerScripts)
-- A small line at the top of the screen: which night it is, the stage, and the time left,
-- e.g. "Night 2 · Deep night · 0:42". It reads the time from the NightCycle clock
-- (attributes on workspace), so it never drifts from the bells.
-- Config.CLOCK_SHOW_TIMER = false hides the countdown and leaves just the night and stage.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local player = Players.LocalPlayer

local STAGE_NAMES = {
	Gathering = "Gathering",
	Dusk = "Dusk",
	DeepNight = "Deep night",
	LastHour = "Last hour",
	Day = "Day",
}

local gui = Instance.new("ScreenGui")
gui.Name = "NightClock"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.new(0.5, 0, 0, 14)
label.Size = UDim2.fromOffset(400, 26)
label.BackgroundTransparency = 1
label.Font = Enum.Font.Garamond
label.TextSize = 22
label.TextColor3 = Color3.fromRGB(215, 210, 200) -- pale, like old paper (same as the stamina bar)
label.TextStrokeTransparency = 0.6
label.Text = ""
label.Parent = gui
gui.Parent = player:WaitForChild("PlayerGui")

local function formatTime(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return ("%d:%02d"):format(seconds // 60, seconds % 60)
end

RunService.RenderStepped:Connect(function()
	local stageName = workspace:GetAttribute("StageName")
	if not stageName then
		label.Text = "" -- the clock hasn't started yet
		return
	end
	local parts = {}
	if workspace:GetAttribute("Phase") == "Night" then
		table.insert(parts, "Night " .. (workspace:GetAttribute("Night") or 1))
	end
	table.insert(parts, STAGE_NAMES[stageName] or stageName)
	if Config.CLOCK_SHOW_TIMER then
		local left = (workspace:GetAttribute("StageEndsAt") or 0) - workspace:GetServerTimeNow()
		table.insert(parts, formatTime(left))
	end
	label.Text = table.concat(parts, "  ·  ")
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.NightClock")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("JournalUI")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "JournalUI"
	s.Source = [=[
-- JournalUI (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Your journal: press J to open or close it. An open Victorian book covering most of the screen:
--   left page, Clues: filled in automatically when you find something (night, stage, district).
--   right page, Notes: write anything you like. Saved to the server, kept for the whole match.
-- A small journal icon with a fancy "J" sits in the bottom-right corner, so players know it's
-- there; clicking it also opens the journal (for phones and tablets), and a brass X on the book's
-- corner closes it. A red dot appears on the icon when a new clue arrives, until you open the journal.
-- Opening: the closed book rises up from the bottom of the screen, then its cover swings open
-- (faked 3D: the cover gets narrower towards the spine and darker as it turns). Closing plays it backwards.
-- You can keep walking while it's open. The mouse is freed so you can click and type, which
-- means you can't look around until you close it again.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local remotes = ReplicatedStorage:WaitForChild("JournalRemotes")
local player = Players.LocalPlayer

local PAPER = Color3.fromRGB(232, 222, 196)
local INK = Color3.fromRGB(45, 32, 20)
local FADED_INK = Color3.fromRGB(120, 95, 65)
local BRASS = Color3.fromRGB(150, 112, 55)
local STAGE_NAMES = { Gathering = "Gathering", Dusk = "Dusk", DeepNight = "Deep night", LastHour = "Last hour", Day = "Day" }

---------------------------------------------------------------- building the book
-- The book is two images (art/journal-left.png and art/journal-right.png) side by side:
-- leather cover, parchment pages, "Clues" written on the left page and "Notes" on the right.
-- The clue list and the notes sit on top of the pages. Everything scales with the screen.
local LEFT_TEXT = { x = 0.100, y = 0.225, w = 0.353, h = 0.615 }  -- where text goes, as a share of the whole book
local RIGHT_TEXT = { x = 0.548, y = 0.225, w = 0.353, h = 0.615 }

local gui = Instance.new("ScreenGui")
gui.Name = "Journal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false

local dim = Instance.new("Frame") -- darkens the world behind the book
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.Parent = gui

local book = Instance.new("Frame")
book.Name = "Book"
book.AnchorPoint = Vector2.new(0.5, 0.5)
book.Position = UDim2.fromScale(0.5, 0.5)
book.Size = UDim2.fromScale(0.94, 0.9) -- as big as fits on the screen, keeping the book's shape
book.BackgroundTransparency = 1
book.Parent = gui
local ratio = Instance.new("UIAspectRatioConstraint")
ratio.AspectRatio = 1.5
ratio.Parent = book

-- each half is pinned at the spine (the middle of the book) so it can be squashed towards it
local function pageImage(id, x)
	local image = Instance.new("ImageLabel")
	image.AnchorPoint = Vector2.new(x == 0 and 1 or 0, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromScale(0.5, 1)
	image.BackgroundTransparency = 1
	image.Parent = book
	if id ~= 0 then
		image.Image = "rbxassetid://" .. id
	else -- no image uploaded yet: plain parchment instead
		image.BackgroundTransparency = 0
		image.BackgroundColor3 = PAPER
		image.BorderSizePixel = 0
	end
	return image
end
local leftPage = pageImage(Config.JOURNAL_LEFT_IMAGE_ID, 0)
pageImage(Config.JOURNAL_RIGHT_IMAGE_ID, 0.5)
local cover = pageImage(Config.JOURNAL_COVER_IMAGE_ID, 0.5) -- the closed front cover, lying over the right page
cover.ZIndex = 5
if Config.JOURNAL_COVER_IMAGE_ID == 0 then cover.BackgroundColor3 = Color3.fromRGB(85, 35, 15) end
local bookScale = Instance.new("UIScale")
bookScale.Parent = book
if Config.JOURNAL_LEFT_IMAGE_ID == 0 or Config.JOURNAL_RIGHT_IMAGE_ID == 0 then
	warn("[JournalUI] Book images not set yet: upload art/journal-left.png and art/journal-right.png and put their IDs in Config")
end

-- a Modal button frees the mouse while the journal is open (first person normally locks it)
local mouseFreer = Instance.new("TextButton")
mouseFreer.Text = ""
mouseFreer.BackgroundTransparency = 1
mouseFreer.Size = UDim2.fromOffset(1, 1)
mouseFreer.Modal = false -- switched on while the journal is open
mouseFreer.Parent = book

local function label(parent, text, font, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = font
	l.TextColor3 = color
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local textFrames = {}
local function textArea(area)
	local f = Instance.new("Frame")
	f.BackgroundTransparency = 1
	f.Position = UDim2.fromScale(area.x, area.y)
	f.Size = UDim2.fromScale(area.w, area.h)
	f.Visible = false -- only shown once the book is fully open
	f.Parent = book
	table.insert(textFrames, f)
	return f
end

-- left page: the clue list, newest at the top
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.fromScale(1, 1)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = BRASS
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = textArea(LEFT_TEXT)
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list
local empty = label(list, "No clues yet. Investigate what you find at night.", Enum.Font.Garamond, FADED_INK)
empty.Size = UDim2.new(1, -8, 0, 0)
empty.AutomaticSize = Enum.AutomaticSize.Y
empty.LayoutOrder = 0

-- text sizes follow the size of the book, so it reads the same on any screen
local sizes = { header = 16, body = 20, notes = 22 }
local headers, bodies = {}, {}
local function applySizes()
	local h = book.AbsoluteSize.Y
	sizes.header = math.max(12, math.floor(h * 0.021))
	sizes.body = math.max(14, math.floor(h * 0.027))
	sizes.notes = math.max(14, math.floor(h * 0.03))
	layout.Padding = UDim.new(0, math.floor(h * 0.02))
	empty.TextSize = sizes.body
	for _, l in headers do l.TextSize = sizes.header end
	for _, l in bodies do l.TextSize = sizes.body end
end

local clueCount = 0
local function addClueEntry(clue)
	clueCount += 1
	empty.Visible = false
	local entry = Instance.new("Frame")
	entry.BackgroundTransparency = 1
	entry.Size = UDim2.new(1, -8, 0, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.LayoutOrder = -clueCount -- newest first
	entry.Parent = list
	local entryLayout = Instance.new("UIListLayout")
	entryLayout.Padding = UDim.new(0, 2)
	entryLayout.Parent = entry

	local where = { "Night " .. clue.night }
	if clue.stage ~= "" then table.insert(where, STAGE_NAMES[clue.stage] or clue.stage) end
	if clue.district ~= "" then table.insert(where, clue.district) end
	local header = label(entry, table.concat(where, "  ·  "), Enum.Font.Garamond, FADED_INK)
	header.Size = UDim2.new(1, 0, 0, 0)
	header.AutomaticSize = Enum.AutomaticSize.Y
	header.TextSize = sizes.header
	table.insert(headers, header)
	local body = label(entry, clue.text, Enum.Font.Garamond, INK)
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.TextSize = sizes.body
	table.insert(bodies, body)
end

-- right page: one big handwritten text box
local notes = Instance.new("TextBox")
notes.Size = UDim2.fromScale(1, 1)
notes.BackgroundTransparency = 1
notes.Font = Enum.Font.IndieFlower -- handwriting
notes.TextColor3 = INK
notes.PlaceholderText = "Write anything here..."
notes.PlaceholderColor3 = FADED_INK
notes.Text = ""
notes.MultiLine = true
notes.ClearTextOnFocus = false
notes.TextWrapped = true
notes.TextXAlignment = Enum.TextXAlignment.Left
notes.TextYAlignment = Enum.TextYAlignment.Top
notes.Parent = textArea(RIGHT_TEXT)

book:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	applySizes()
	notes.TextSize = sizes.notes
end)
applySizes()
notes.TextSize = sizes.notes

-- a round brass X button on the book's top-right corner, to close it by tapping (phones and tablets)
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Text = ""
closeButton.AnchorPoint = Vector2.new(0.5, 0.5)
closeButton.Position = UDim2.fromScale(0.975, 0.04)
closeButton.Size = UDim2.fromScale(0.075, 0.075)
closeButton.SizeConstraint = Enum.SizeConstraint.RelativeYY -- a circle, sized by the book's height
closeButton.BackgroundColor3 = Color3.fromRGB(207, 162, 76)
closeButton.AutoButtonColor = true
closeButton.ZIndex = 10
closeButton.Visible = false -- only shown once the book is fully open
closeButton.Parent = book
table.insert(textFrames, closeButton)
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)
local closeEdge = Instance.new("UIStroke")
closeEdge.Color = Color3.fromRGB(42, 24, 6)
closeEdge.Thickness = 3
closeEdge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
closeEdge.Parent = closeButton
local closeMin = Instance.new("UISizeConstraint") -- never smaller than a fingertip
closeMin.MinSize = Vector2.new(40, 40)
closeMin.Parent = closeButton
for _, turn in { 45, -45 } do -- the X: two dark bars crossed
	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.5)
	bar.Size = UDim2.fromScale(0.6, 0.12)
	bar.Rotation = turn
	bar.BackgroundColor3 = Color3.fromRGB(42, 24, 6)
	bar.BorderSizePixel = 0
	bar.ZIndex = 11
	bar.Parent = closeButton
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
end

-- the journal icon in the corner, with the key as a brass badge (clicking it opens the journal)
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "JournalIcon"
iconGui.ResetOnSpawn = false
iconGui.IgnoreGuiInset = true
local icon = Instance.new("ImageButton")
icon.Name = "Icon"
icon.AnchorPoint = Vector2.new(1, 1)
icon.Position = UDim2.fromScale(1 - Config.JOURNAL_ICON_MARGIN, 1 - Config.JOURNAL_ICON_MARGIN)
icon.Size = UDim2.fromScale(1, Config.JOURNAL_ICON_SIZE)
icon.BackgroundTransparency = 1
icon.Parent = iconGui
local iconRatio = Instance.new("UIAspectRatioConstraint")
iconRatio.AspectRatio = 1
iconRatio.DominantAxis = Enum.DominantAxis.Height
iconRatio.Parent = icon
if Config.JOURNAL_ICON_IMAGE_ID ~= 0 then
	icon.Image = "rbxassetid://" .. Config.JOURNAL_ICON_IMAGE_ID
else -- no image uploaded yet: a plain leather-coloured square
	icon.BackgroundTransparency = 0
	icon.BackgroundColor3 = Color3.fromRGB(85, 35, 15)
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0.1, 0)
end

local badge = Instance.new("TextLabel") -- the key, on a round brass badge (only until the icon image is uploaded)
badge.Name = "KeyBadge"
badge.AnchorPoint = Vector2.new(0.5, 0.5)
badge.Position = UDim2.fromScale(0.82, 0.82)
badge.Size = UDim2.fromScale(0.38, 0.38)
badge.BackgroundColor3 = Color3.fromRGB(207, 162, 76)
badge.Text = Config.JOURNAL_KEY
badge.Font = Enum.Font.Garamond
badge.TextScaled = true
badge.TextColor3 = Color3.fromRGB(42, 24, 6)
badge.Visible = Config.JOURNAL_ICON_IMAGE_ID == 0 -- the uploaded icon already has a fancy J on it
badge.Parent = icon
Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
local badgeEdge = Instance.new("UIStroke")
badgeEdge.Color = Color3.fromRGB(42, 24, 6)
badgeEdge.Thickness = 2
badgeEdge.Parent = badge

local newDot = Instance.new("Frame") -- shows there's a clue you haven't looked at yet
newDot.Name = "NewClueDot"
newDot.AnchorPoint = Vector2.new(0.5, 0.5)
newDot.Position = UDim2.fromScale(0.85, 0.12)
newDot.Size = UDim2.fromScale(0.22, 0.22)
newDot.BackgroundColor3 = Color3.fromRGB(156, 31, 34)
newDot.Visible = false
newDot.Parent = icon
Instance.new("UICorner", newDot).CornerRadius = UDim.new(1, 0)
local dotEdge = Instance.new("UIStroke")
dotEdge.Color = Color3.fromRGB(246, 223, 156)
dotEdge.Thickness = 2
dotEdge.Parent = newDot
iconGui.Parent = player:WaitForChild("PlayerGui")

-- a short message when a new clue arrives
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "JournalToast"
toastGui.ResetOnSpawn = false
local toast = label(toastGui, "", Enum.Font.Garamond, PAPER)
toast.TextSize = 22
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 60)
toast.Size = UDim2.fromOffset(500, 28)
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.TextStrokeTransparency = 0.5
toast.Visible = false

gui.Parent = player:WaitForChild("PlayerGui")
toastGui.Parent = player.PlayerGui

---------------------------------------------------------------- loading, saving, opening
local journal = remotes:WaitForChild("Get"):InvokeServer()
for _, clue in journal.clues do
	addClueEntry(clue)
end
notes.Text = journal.notes

local isOpen = false -- whether the journal is open (or opening)
local shown = 0
remotes:WaitForChild("NewClue").OnClientEvent:Connect(function(clue)
	addClueEntry(clue)
	if not isOpen then newDot.Visible = true end
	toast.Text = "A new clue in your journal  (" .. Config.JOURNAL_KEY .. ")"
	toast.Visible = true
	shown += 1
	local mine = shown
	task.delay(3, function()
		if shown == mine then toast.Visible = false end
	end)
end)

-- notes are sent to the server a moment after you stop typing, and when you click away
local saveNotes = remotes:WaitForChild("SaveNotes")
local lastSent = notes.Text
local function sendNotes()
	if notes.Text ~= lastSent then
		lastSent = notes.Text
		saveNotes:FireServer(notes.Text)
	end
end
notes:GetPropertyChangedSignal("Text"):Connect(function()
	if #notes.Text > Config.JOURNAL_NOTES_MAX then
		notes.Text = string.sub(notes.Text, 1, Config.JOURNAL_NOTES_MAX)
	end
end)
notes.FocusLost:Connect(sendNotes)
task.spawn(function()
	while true do
		task.wait(2)
		sendNotes()
	end
end)

---------------------------------------------------------------- the open / close animation
-- progress goes from 0 (closed, off screen) to 1 (open). The first part raises the closed book,
-- the rest swings the cover open. Closing just runs progress backwards.
local RISE = 0.35 -- share of the animation spent raising the book (the rest is the cover swinging)
local progress = 0

local function sound(id)
	if id == 0 then return nil end
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = Config.JOURNAL_SOUND_VOLUME
	s.Parent = gui
	return s
end
local openSound = sound(Config.JOURNAL_OPEN_SOUND_ID)
local closeSound = sound(Config.JOURNAL_CLOSE_SOUND_ID)

local function smooth(x) -- eases in and out
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

local function draw()
	local rise = smooth(progress / RISE)
	local swing = smooth((progress - RISE) / (1 - RISE))
	local angle = swing * math.pi -- 0 = cover shut, pi = cover lying open on the left

	-- while closed the right half (the cover) sits in the middle of the screen; it slides to the
	-- left as the cover opens, so the open book ends up centred
	book.AnchorPoint = Vector2.new(0.75 - 0.25 * swing, 0.5)
	book.Position = UDim2.fromScale(0.5, 0.5 + 0.9 * (1 - rise)) -- comes up from below the screen
	bookScale.Scale = 0.85 + 0.15 * rise

	-- the turning cover: as wide as cos(angle) on the right, then the inside lands on the left
	local lift = 1 + 0.06 * math.sin(angle) -- the edge coming towards you looks a little bigger
	local shade = 0.55 + 0.45 * math.abs(math.cos(angle)) -- darker when it's side-on
	local grey = Color3.new(shade, shade, shade)
	cover.Visible = angle < math.pi / 2
	cover.Size = UDim2.fromScale(0.5 * math.max(math.cos(angle), 0), lift)
	cover.ImageColor3 = grey
	leftPage.Visible = angle > math.pi / 2
	leftPage.Size = UDim2.fromScale(0.5 * math.max(-math.cos(angle), 0), angle > math.pi / 2 and lift or 1)
	leftPage.ImageColor3 = grey

	dim.BackgroundTransparency = 1 - 0.55 * rise
	for _, f in textFrames do f.Visible = progress >= 1 end
	gui.Enabled = progress > 0
end
draw()

RunService.RenderStepped:Connect(function(dt)
	local target = isOpen and 1 or 0
	if progress == target then return end
	if Config.JOURNAL_OPEN_TIME <= 0 or State.reduceMotion then
		progress = target -- no animation
	else
		local step = dt / Config.JOURNAL_OPEN_TIME
		progress = math.clamp(progress + (isOpen and step or -step), 0, 1)
	end
	draw()
end)

local function setOpen(open)
	if open == isOpen then return end
	isOpen = open
	if open then
		newDot.Visible = false
		if openSound then openSound:Play() end
	else
		notes:ReleaseFocus()
		sendNotes()
		if closeSound then closeSound:Play() end
	end
	gui.Enabled = true
	mouseFreer.Modal = open -- give the mouse back to the camera straight away when closing
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- e.g. typing in the notes or chat
	if input.KeyCode == Enum.KeyCode[Config.JOURNAL_KEY] then
		setOpen(not isOpen)
	end
end)
icon.Activated:Connect(function()
	setOpen(not isOpen)
end)
closeButton.Activated:Connect(function()
	setOpen(false)
end)
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.JournalUI")
end
do
	local parent = game
	for part in ("StarterPlayer.StarterPlayerScripts"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("Footsteps")
	if s and s.ClassName ~= "LocalScript" then s:Destroy(); s = nil end
	s = s or Instance.new("LocalScript")
	s.Name = "Footsteps"
	s.Source = [=[
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
	-- some recordings are quieter than others, so each floor can be turned up or down
	sound.Volume = Config.FOOTSTEP_VOLUME[movement] * (Config.FOOTSTEP_FLOOR_VOLUME[floor] or 1)
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
			local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
			if player == localPlayer then
				-- your own steps: whenever the head bob counts a footstep
				if State.footsteps ~= lastLocalSteps then
					lastLocalSteps = State.footsteps
					playStep(character, State.sprinting and "Sprint" or State.crouching and "Crouch" or "Walk")
				end
			elseif grounded and speed > 0.5 then
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
]=]
	s.Parent = parent
	table.insert(done, "StarterPlayer.StarterPlayerScripts.Footsteps")
end
do
	local parent = game
	for part in ("ServerScriptService"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("Journal")
	if s and s.ClassName ~= "ModuleScript" then s:Destroy(); s = nil end
	s = s or Instance.new("ModuleScript")
	s.Name = "Journal"
	s.Source = [=[
-- Journal (ModuleScript in ServerScriptService)
-- Keeps every player's journal on the server: the clues they've found and their own notes.
-- Clues can only be added here, by the server (a player can't fake one), and journals are kept
-- by player ID, so someone who disconnects and rejoins the match gets theirs back.
-- Other server scripts use it like this:
--   local Journal = require(game.ServerScriptService.Journal)
--   Journal.addClue(player, "Blood spots, fresh. They lead south, toward the river.", "Market")
--   Journal.clueCount(player)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local Journal = {}
local journals = {} -- [userId] = { clues = { {text, night, stage, district, at}, ... }, notes = "" }

-- the messages between the server and each player's journal screen
local remotes = Instance.new("Folder")
remotes.Name = "JournalRemotes"
local getJournal = Instance.new("RemoteFunction") -- player asks: "give me my journal"
getJournal.Name = "Get"
getJournal.Parent = remotes
local saveNotes = Instance.new("RemoteEvent")     -- player sends: "here are my notes"
saveNotes.Name = "SaveNotes"
saveNotes.Parent = remotes
local newClue = Instance.new("RemoteEvent")       -- server tells a player: "you found a clue"
newClue.Name = "NewClue"
newClue.Parent = remotes
remotes.Parent = ReplicatedStorage

local function journalOf(player)
	local journal = journals[player.UserId]
	if not journal then
		journal = { clues = {}, notes = "" }
		journals[player.UserId] = journal
	end
	return journal
end

-- Add a clue to a player's journal and show it to them straight away.
function Journal.addClue(player, text, district)
	local clue = {
		text = text,
		night = workspace:GetAttribute("Night") or 0,
		stage = workspace:GetAttribute("StageName") or "",
		district = district or "",
		at = workspace:GetServerTimeNow(),
	}
	table.insert(journalOf(player).clues, clue)
	newClue:FireClient(player, clue)
	return clue
end

function Journal.getClues(player)
	return journalOf(player).clues
end

function Journal.clueCount(player)
	return #journalOf(player).clues
end

-- Raw notes, exactly as the player wrote them. Before showing them to anyone ELSE
-- (e.g. a dropped journal), they must be filtered with TextService.
function Journal.getNotes(player)
	return journalOf(player).notes
end

getJournal.OnServerInvoke = function(player)
	return journalOf(player)
end

local lastSave = {} -- [userId] = time of the last save, so nobody can spam the server
saveNotes.OnServerEvent:Connect(function(player, text)
	if typeof(text) ~= "string" then return end
	local now = os.clock()
	if lastSave[player.UserId] and now - lastSave[player.UserId] < 0.5 then return end
	lastSave[player.UserId] = now
	journalOf(player).notes = string.sub(text, 1, Config.JOURNAL_NOTES_MAX)
end)

Players.PlayerRemoving:Connect(function(player)
	lastSave[player.UserId] = nil -- the journal itself is kept in case they rejoin
end)

return Journal
]=]
	s.Parent = parent
	table.insert(done, "ServerScriptService.Journal")
end
do
	local parent = game
	for part in ("ServerScriptService"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("JournalServer")
	if s and s.ClassName ~= "Script" then s:Destroy(); s = nil end
	s = s or Instance.new("Script")
	s.Name = "JournalServer"
	s.Source = [=[
-- JournalServer (Script in ServerScriptService)
-- Starts the journal (the Journal module). For testing, while Config.JOURNAL_TEST_CLUES is on,
-- every player gets a made-up clue at each bell so you can see clues arrive in the journal.
-- Turn that off once the real clue system exists.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Journal = require(script.Parent:WaitForChild("Journal"))

local TEST_CLUES = {
	Dusk = "Test clue: fresh boot prints in the mud, heading toward Soho.",
	DeepNight = "Test clue: a torn thread of red wool caught on a railing.",
	LastHour = "Test clue: a lantern was seen near the Docks at the second bell.",
}

if Config.JOURNAL_TEST_CLUES then
	workspace:GetAttributeChangedSignal("StageName"):Connect(function()
		local text = TEST_CLUES[workspace:GetAttribute("StageName")]
		if not text then return end
		for _, player in Players:GetPlayers() do
			Journal.addClue(player, text, "Test district")
		end
	end)
end
]=]
	s.Parent = parent
	table.insert(done, "ServerScriptService.JournalServer")
end
do
	local parent = game
	for part in ("ServerScriptService"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("AvatarRules")
	if s and s.ClassName ~= "Script" then s:Destroy(); s = nil end
	s = s or Instance.new("Script")
	s.Name = "AvatarRules"
	s.Source = [=[
-- AvatarRules (Script in ServerScriptService)
-- Makes every player's avatar the same size and gives everyone the same animations
-- (Config.AVATAR_ANIMATIONS), whatever animation pack or body they own. Fair hiding (no tiny avatars) and the same
-- first-person camera height for everyone. The rules are in ReplicatedStorage.Config.
-- Runs on the server because only the server can change what an avatar looks like for everyone.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local BODY_PARTS = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }

local function applyRules(character)
	local humanoid = character:WaitForChild("Humanoid")
	local description = humanoid:GetAppliedDescription()

	local scale = Config.AVATAR_SCALE
	description.HeightScale = scale.Height
	description.WidthScale = scale.Width
	description.DepthScale = scale.Depth
	description.HeadScale = scale.Head
	description.BodyTypeScale = scale.BodyType
	description.ProportionScale = scale.Proportion

	-- everyone moves the same way (0 = Roblox's standard animation)
	for name, id in Config.AVATAR_ANIMATIONS do
		description[name .. "Animation"] = id
	end
	if Config.FORCE_DEFAULT_BODY_PARTS then
		for _, name in BODY_PARTS do
			description[name] = 0 -- 0 = the standard body part
		end
	end

	local ok, err = pcall(function()
		humanoid:ApplyDescription(description)
	end)
	if not ok then
		warn("[AvatarRules] Couldn't apply avatar rules: " .. tostring(err))
	end
end

local function onPlayer(player)
	player.CharacterAppearanceLoaded:Connect(applyRules)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do -- anyone who joined before this script started
	onPlayer(player)
	if player.Character and player:HasAppearanceLoaded() then
		task.spawn(applyRules, player.Character)
	end
end
]=]
	s.Parent = parent
	table.insert(done, "ServerScriptService.AvatarRules")
end
do
	local parent = game
	for part in ("ServerScriptService"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("NightCycle")
	if s and s.ClassName ~= "Script" then s:Destroy(); s = nil end
	s = s or Instance.new("Script")
	s.Name = "NightCycle"
	s.Source = [=[
-- NightCycle (Script in ServerScriptService)
-- The game's clock. Each night everyone is gathered in the Courthouse Square (at the part named
-- "NightSpawn"), then the church bell starts each stage of the night (Dusk, Deep night,
-- Last hour); at Deep night a few random districts go dark; then day; then the next night.
-- Runs on the server so every player hears the same bell at the same moment.
-- All lengths and choices are in ReplicatedStorage.Config.
--
-- Other scripts (fog, lamps, lanterns, a clock on screen) don't talk to this one directly.
-- They read the time from attributes on workspace, which every player receives automatically:
--   Night          which night it is (1, 2, 3...)
--   Phase          "Night" or "Day"
--   Stage          0 = day, 1 = Dusk, 2 = Deep night, 3 = Last hour
--   StageName      "Dusk", "DeepNight", "LastHour" or "Day"
--   StageEndsAt    when this stage ends, in workspace:GetServerTimeNow() seconds (for countdowns)
--   DarkDistricts  districts without lamps right now, e.g. "Soho,Docks" ("" = none)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local speed = Config.NIGHT_TEST_SPEED -- 1 = normal; higher runs the whole cycle faster for testing
local random = Random.new()

-- the bell: each toll is a fresh copy, so one toll can ring out while the next starts
local bellTemplate = nil
if Config.BELL_SOUND_ID ~= 0 then
	-- The echo sits on a sound group (like a channel on a mixing desk) rather than on the sound:
	-- an echo on the sound itself stops dead the moment the recording ends.
	local group = Instance.new("SoundGroup")
	group.Name = "ChurchBell"
	group.Volume = 1 -- a sound group starts at half volume otherwise
	local echo = Instance.new("ReverbSoundEffect")
	echo.DecayTime = Config.BELL_ECHO_TIME
	echo.WetLevel = Config.BELL_ECHO_LEVEL
	echo.Parent = group
	group.Parent = SoundService

	bellTemplate = Instance.new("Sound")
	bellTemplate.Name = "ChurchBell"
	bellTemplate.SoundId = "rbxassetid://" .. Config.BELL_SOUND_ID
	bellTemplate.Volume = 1
	bellTemplate.PlaybackSpeed = Config.BELL_SPEED -- below 1 = slower, deeper and longer
	bellTemplate.SoundGroup = group
end

-- how long one toll lasts, in seconds. Measured once and remembered: a fresh copy can briefly
-- report a length of 0, which would make it fade out instantly.
local bellLength = nil
local function measureLength(bell)
	if bellLength then return bellLength end
	local started = os.clock()
	while bell.TimeLength == 0 and os.clock() - started < 5 do
		task.wait()
	end
	if bell.TimeLength > 0 then
		bellLength = bell.TimeLength / bell.PlaybackSpeed
	end
	return bellLength
end

local function playToll()
	local bell = bellTemplate:Clone()
	bell.Parent = workspace -- not inside a part, so everyone hears it everywhere
	bell:Play()
	local length = measureLength(bell)
	if not length then -- couldn't find out how long it is: no fade, just clean up later
		task.delay(30, function() bell:Destroy() end)
		return
	end
	-- fade the recording out over its last few seconds, so it never ends with a sudden cut
	local fade = math.min(Config.BELL_FADE_TIME, length)
	task.delay(length - fade, function()
		TweenService:Create(bell, TweenInfo.new(fade), { Volume = 0 }):Play()
	end)
	task.delay(length + Config.BELL_ECHO_TIME, function() bell:Destroy() end)
end

local function toll(times)
	print(("[NightCycle] Bell tolls %d time%s"):format(times, times == 1 and "" or "s"))
	if not bellTemplate then return end
	task.spawn(function()
		for _ = 1, times do
			task.spawn(playToll)
			task.wait(Config.BELL_TOLL_GAP)
		end
	end)
end

local function pickDarkDistricts()
	local choices = table.clone(Config.DARK_DISTRICT_CHOICES)
	local count = math.min(random:NextInteger(Config.DARK_DISTRICTS_MIN, Config.DARK_DISTRICTS_MAX), #choices)
	local picked = {}
	for _ = 1, count do
		table.insert(picked, table.remove(choices, random:NextInteger(1, #choices)))
	end
	return picked
end

-- Put everyone in the Courthouse Square, spread evenly round the NightSpawn marker, facing outward
local function gatherPlayers()
	local marker = workspace:FindFirstChild("NightSpawn", true)
	if not marker then
		warn("[NightCycle] No part named NightSpawn in workspace, so players weren't gathered")
		return
	end
	local players = Players:GetPlayers()
	for i, player in players do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local angle = (i / #players) * 2 * math.pi
			local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * Config.NIGHT_SPAWN_RADIUS
			local position = marker.Position + offset + Vector3.new(0, 4, 0)
			character:PivotTo(CFrame.lookAt(position, position + offset))
		end
	end
end

local function setStage(stage, name, seconds)
	workspace:SetAttribute("Stage", stage)
	workspace:SetAttribute("StageName", name)
	workspace:SetAttribute("StageEndsAt", workspace:GetServerTimeNow() + seconds)
end

local night = 0
while true do
	night += 1
	workspace:SetAttribute("Night", night)
	workspace:SetAttribute("Phase", "Night")
	workspace:SetAttribute("DarkDistricts", "")
	print(("[NightCycle] ===== Night %d ====="):format(night))
	gatherPlayers()
	setStage(0, "Gathering", Config.NIGHT_START_DELAY / speed)
	task.wait(Config.NIGHT_START_DELAY / speed)

	for i, stage in Config.NIGHT_STAGES do
		if i == Config.DARK_FROM_STAGE then
			local dark = pickDarkDistricts()
			workspace:SetAttribute("DarkDistricts", table.concat(dark, ","))
			print("[NightCycle] Lamps go out in: " .. table.concat(dark, ", "))
		end
		local seconds = stage.length / speed
		setStage(i, stage.name, seconds)
		print(("[NightCycle] Bell %d: %s (%d s)"):format(i, stage.name, stage.length))
		toll(i) -- bell 1 tolls once, bell 2 twice, bell 3 three times
		task.wait(seconds)
	end

	-- day: just a pause for now (the Courthouse debate and vote come later)
	workspace:SetAttribute("Phase", "Day")
	workspace:SetAttribute("DarkDistricts", "")
	setStage(0, "Day", Config.DAY_PLACEHOLDER_LENGTH / speed)
	print(("[NightCycle] ===== DAY (placeholder, %d s) ====="):format(Config.DAY_PLACEHOLDER_LENGTH))
	task.wait(Config.DAY_PLACEHOLDER_LENGTH / speed)
end
]=]
	s.Parent = parent
	table.insert(done, "ServerScriptService.NightCycle")
end
print("INSTALL" .. "ED: " .. table.concat(done, ", "))
