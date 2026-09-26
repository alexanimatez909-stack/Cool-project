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
