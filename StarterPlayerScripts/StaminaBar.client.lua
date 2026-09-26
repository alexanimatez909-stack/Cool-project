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
