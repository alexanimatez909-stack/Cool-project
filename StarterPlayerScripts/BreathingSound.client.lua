-- BreathingSound (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Your own breathing: quiet when rested, louder and faster the lower your stamina is.
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
	local tired = State.exhausted and 1 or (1 - State.stamina)
	level = lerp(level, tired, 1 - math.exp(-Config.BREATH_SOUND_SMOOTHING * dt))
	sound.Volume = lerp(Config.BREATH_VOLUME_CALM, Config.BREATH_VOLUME_TIRED, level)
	sound.PlaybackSpeed = lerp(Config.BREATH_SPEED_CALM, Config.BREATH_SPEED_TIRED, level)
end)
