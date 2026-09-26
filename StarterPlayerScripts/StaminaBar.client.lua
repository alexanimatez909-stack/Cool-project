-- StaminaBar (LocalScript in StarterPlayer > StarterPlayerScripts)
-- A thin horror-game stamina bar near the bottom of the screen. No numbers; it only appears
-- while stamina isn't full, and turns a dull red and pulses when you've run out.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer

local WIDTH, HEIGHT = 220, 4
local FILL_COLOR = Color3.fromRGB(215, 210, 200)      -- pale, like old paper
local EXHAUSTED_COLOR = Color3.fromRGB(140, 45, 40)   -- dull red
local TRACK_TRANSPARENCY, FILL_TRANSPARENCY = 0.6, 0.15
local FADE_SPEED = 4 -- how fast it fades in and out (per second)

local gui = Instance.new("ScreenGui")
gui.Name = "StaminaBar"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local track = Instance.new("Frame")
track.Name = "Track"
track.AnchorPoint = Vector2.new(0.5, 1)
track.Position = UDim2.new(0.5, 0, 1, -60)
track.Size = UDim2.fromOffset(WIDTH, HEIGHT)
track.BackgroundColor3 = Color3.new(0, 0, 0)
track.BorderSizePixel = 0
track.Parent = gui

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.fromScale(1, 1)
fill.BackgroundColor3 = FILL_COLOR
fill.BorderSizePixel = 0
fill.Parent = track

local mark = Instance.new("Frame") -- faint mark where you can sprint again after running out
mark.Name = "ResprintMark"
mark.AnchorPoint = Vector2.new(0.5, 0.5)
mark.Position = UDim2.fromScale(Config.STAMINA_RESPRINT_AT, 0.5)
mark.Size = UDim2.fromOffset(1, HEIGHT + 4)
mark.BackgroundColor3 = FILL_COLOR
mark.BorderSizePixel = 0
mark.Parent = track

gui.Parent = player:WaitForChild("PlayerGui")

local visibility = 0     -- 0 = hidden, 1 = fully shown
local fullSince = -math.huge -- starts full and hidden

RunService.RenderStepped:Connect(function(dt)
	local full = State.stamina >= 1
	if not full then fullSince = os.clock() end
	local want = (not full or os.clock() - fullSince < Config.STAMINA_BAR_HIDE_DELAY) and 1 or 0
	visibility += math.clamp(want - visibility, -FADE_SPEED * dt, FADE_SPEED * dt)

	fill.Size = UDim2.fromScale(State.stamina, 1)
	local pulse = 0
	if State.exhausted then
		fill.BackgroundColor3 = EXHAUSTED_COLOR
		pulse = (math.sin(os.clock() * 5) + 1) / 2 * 0.4 -- slow throb
	else
		fill.BackgroundColor3 = FILL_COLOR
	end

	local hide = 1 - visibility
	track.BackgroundTransparency = TRACK_TRANSPARENCY + (1 - TRACK_TRANSPARENCY) * hide
	fill.BackgroundTransparency = math.min(1, FILL_TRANSPARENCY + pulse + (1 - FILL_TRANSPARENCY) * hide)
	mark.BackgroundTransparency = 0.5 + 0.5 * hide
end)
