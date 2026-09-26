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
Config.BELL_SOUND_ID = 0             -- church bell sound ID number (0 = silent for now)
Config.BELL_TOLL_GAP = 2.5           -- seconds between tolls (bell 2 tolls twice, bell 3 three times)
Config.BELL_SPEED = 0.85             -- 1 = as recorded; lower = slower, deeper and longer
Config.BELL_ECHO_TIME = 6            -- seconds the echo takes to fade away (higher = slower fade)
Config.BELL_ECHO_LEVEL = 0           -- how loud the echo is (0 = as loud as the bell, -10 = quieter)
Config.BELL_FADE_TIME = 3            -- each toll fades out over its last few seconds (hides a sudden cut)
Config.DAY_PLACEHOLDER_LENGTH = 10   -- for now day is just a pause before the next night
Config.NIGHT_TEST_SPEED = 1          -- 1 = normal speed; e.g. 5 = the whole cycle runs 5x faster (testing only)

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
