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
