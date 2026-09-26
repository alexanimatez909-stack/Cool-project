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
