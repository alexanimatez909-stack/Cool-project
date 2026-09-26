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
