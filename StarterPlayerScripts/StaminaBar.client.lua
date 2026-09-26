-- StaminaBar (LocalScript in StarterPlayer > StarterPlayerScripts)
-- A thin Victorian stamina line in the bottom-left corner: pale ink on a dark track, with a
-- small brass diamond at each end. No numbers; it only appears while stamina isn't full,
-- and turns a dull red and pulses when you've run out.
-- Position, size and colours are in ReplicatedStorage.Config (STAMINA_BAR_...).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer

local WIDTH, HEIGHT = Config.STAMINA_BAR_WIDTH, 3
local CAP_SIZE = 9                                    -- the brass diamonds
local FILL_COLOR = Color3.fromRGB(222, 212, 190)      -- pale, like old paper
local EXHAUSTED_COLOR = Color3.fromRGB(140, 45, 40)   -- dull red
local BRASS_COLOR = Color3.fromRGB(176, 141, 79)
local TRACK_TRANSPARENCY, FILL_TRANSPARENCY, BRASS_TRANSPARENCY = 0.55, 0.1, 0.15
local FADE_SPEED = 4 -- how fast it fades in and out (per second)

local gui = Instance.new("ScreenGui")
gui.Name = "StaminaBar"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- holder: bottom-left corner, leaving room for the diamonds
local holder = Instance.new("Frame")
holder.Name = "Holder"
holder.AnchorPoint = Vector2.new(0, 1)
holder.Position = UDim2.new(0, Config.STAMINA_BAR_MARGIN, 1, -Config.STAMINA_BAR_MARGIN)
holder.Size = UDim2.fromOffset(WIDTH, CAP_SIZE)
holder.BackgroundTransparency = 1
holder.Parent = gui

local track = Instance.new("Frame")
track.Name = "Track"
track.AnchorPoint = Vector2.new(0, 0.5)
track.Position = UDim2.fromScale(0, 0.5)
track.Size = UDim2.new(1, 0, 0, HEIGHT)
track.BackgroundColor3 = Color3.new(0, 0, 0)
track.BorderSizePixel = 0
track.Parent = holder

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
mark.Size = UDim2.fromOffset(1, HEIGHT + 6)
mark.BackgroundColor3 = BRASS_COLOR
mark.BorderSizePixel = 0
mark.Parent = track

-- a small brass diamond at each end of the line
local function makeCap(x)
	local cap = Instance.new("Frame")
	cap.Name = "Cap"
	cap.AnchorPoint = Vector2.new(0.5, 0.5)
	cap.Position = UDim2.fromScale(x, 0.5)
	cap.Size = UDim2.fromOffset(CAP_SIZE * 0.7, CAP_SIZE * 0.7)
	cap.Rotation = 45
	cap.BackgroundColor3 = BRASS_COLOR
	cap.BorderSizePixel = 0
	cap.ZIndex = 2
	cap.Parent = holder
	return cap
end
local caps = { makeCap(0), makeCap(1) }

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
	for _, cap in caps do
		cap.BackgroundTransparency = BRASS_TRANSPARENCY + (1 - BRASS_TRANSPARENCY) * hide
	end
end)
