-- NightCycle (Script in ServerScriptService)
-- The game's clock. The church bell starts each stage of the night (Dusk, Deep night,
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

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local speed = Config.NIGHT_TEST_SPEED -- 1 = normal; higher runs the whole cycle faster for testing
local random = Random.new()

-- the bell: each toll is a fresh copy, so one toll can ring out while the next starts
local bellTemplate = nil
if Config.BELL_SOUND_ID ~= 0 then
	bellTemplate = Instance.new("Sound")
	bellTemplate.Name = "ChurchBell"
	bellTemplate.SoundId = "rbxassetid://" .. Config.BELL_SOUND_ID
	bellTemplate.Volume = 1
	bellTemplate.PlaybackSpeed = Config.BELL_SPEED -- below 1 = slower, deeper and longer
	-- echo: a long fading tail after each toll, like the sound rolling round the streets
	local echo = Instance.new("ReverbSoundEffect")
	echo.DecayTime = Config.BELL_ECHO_TIME
	echo.WetLevel = Config.BELL_ECHO_LEVEL
	echo.Parent = bellTemplate
end

local function toll(times)
	print(("[NightCycle] Bell tolls %d time%s"):format(times, times == 1 and "" or "s"))
	if not bellTemplate then return end
	task.spawn(function()
		for _ = 1, times do
			local bell = bellTemplate:Clone()
			bell.Parent = workspace -- not inside a part, so everyone hears it everywhere
			-- remove it only after the echo has faded too (removing it earlier cuts the echo off)
			bell.Ended:Once(function()
				task.delay(Config.BELL_ECHO_TIME, function() bell:Destroy() end)
			end)
			bell:Play()
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
