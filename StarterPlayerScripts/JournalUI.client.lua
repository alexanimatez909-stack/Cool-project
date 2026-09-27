-- JournalUI (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Your journal: press J to open or close it. An open Victorian book covering most of the screen:
--   left page, Clues: filled in automatically when you find something (night, stage, district).
--   right page, Notes: write anything you like. Saved to the server, kept for the whole match.
-- A small journal icon with a fancy "J" sits in the bottom-right corner, so players know it's
-- there; clicking it also opens the journal (for phones and tablets), and a brass X on the book's
-- corner closes it. A red dot appears on the icon when a new clue arrives, until you open the journal.
-- Opening: the closed book rises up from the bottom of the screen and opens in the middle, straight
-- onto the Clues and Notes pages: the front half (cover and half the pages) swings over to the left
-- (faked 3D: it gets narrower towards the spine and darker as it turns, and its thick stack of page
-- edges shows while it's side-on). Closing plays it backwards, faster.
-- You can keep walking while it's open. The mouse is freed so you can click and type, which
-- means you can't look around until you close it again.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local remotes = ReplicatedStorage:WaitForChild("JournalRemotes")
local player = Players.LocalPlayer

local PAPER = Color3.fromRGB(232, 222, 196)
local INK = Color3.fromRGB(45, 32, 20)
local FADED_INK = Color3.fromRGB(120, 95, 65)
local BRASS = Color3.fromRGB(150, 112, 55)
local STAGE_NAMES = { Gathering = "Gathering", Dusk = "Dusk", DeepNight = "Deep night", LastHour = "Last hour", Day = "Day" }

---------------------------------------------------------------- building the book
-- The book is two images (art/journal-left.png and art/journal-right.png) side by side:
-- leather cover, parchment pages, "Clues" written on the left page and "Notes" on the right.
-- The clue list and the notes sit on top of the pages. Everything scales with the screen.
local LEFT_TEXT = { x = 0.100, y = 0.225, w = 0.353, h = 0.615 }  -- where text goes, as a share of the whole book
local RIGHT_TEXT = { x = 0.548, y = 0.225, w = 0.353, h = 0.615 }

local gui = Instance.new("ScreenGui")
gui.Name = "Journal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false

local dim = Instance.new("Frame") -- darkens the world behind the book
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.Parent = gui

local book = Instance.new("Frame")
book.Name = "Book"
book.AnchorPoint = Vector2.new(0.5, 0.5)
book.Position = UDim2.fromScale(0.5, 0.5)
book.Size = UDim2.fromScale(0.94, 0.9) -- as big as fits on the screen, keeping the book's shape
book.BackgroundTransparency = 1
book.Parent = gui
local ratio = Instance.new("UIAspectRatioConstraint")
ratio.AspectRatio = 1.5
ratio.Parent = book

-- each half is pinned at the spine (the middle of the book) so it can be squashed towards it
local function pageImage(id, x)
	local image = Instance.new("ImageLabel")
	image.AnchorPoint = Vector2.new(x == 0 and 1 or 0, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromScale(0.5, 1)
	image.BackgroundTransparency = 1
	image.Parent = book
	if id ~= 0 then
		image.Image = "rbxassetid://" .. id
	else -- no image uploaded yet: plain parchment instead
		image.BackgroundTransparency = 0
		image.BackgroundColor3 = PAPER
		image.BorderSizePixel = 0
	end
	return image
end
local leftPage = pageImage(Config.JOURNAL_LEFT_IMAGE_ID, 0)
pageImage(Config.JOURNAL_RIGHT_IMAGE_ID, 0.5)
local cover = pageImage(Config.JOURNAL_COVER_IMAGE_ID, 0.5) -- the closed front cover, lying over the right page
cover.ZIndex = 8
if Config.JOURNAL_COVER_IMAGE_ID == 0 then cover.BackgroundColor3 = Color3.fromRGB(85, 35, 15) end

-- the edges of the pages in the turning half, seen while it's side-on
local pageEdges = Instance.new("Frame")
pageEdges.Name = "PageEdges"
pageEdges.AnchorPoint = Vector2.new(0.5, 0.5)
pageEdges.Position = UDim2.fromScale(0.5, 0.5)
pageEdges.BackgroundColor3 = Color3.new(1, 1, 1) -- the colours come from the gradient below
pageEdges.BorderSizePixel = 0
pageEdges.ZIndex = 7
pageEdges.Visible = false
pageEdges.Parent = book
local edgeShade = Instance.new("UIGradient") -- darker towards the covers, like a stack of pages
edgeShade.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 45, 25)),
	ColorSequenceKeypoint.new(0.15, Color3.fromRGB(200, 185, 150)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 230, 205)),
	ColorSequenceKeypoint.new(0.85, Color3.fromRGB(200, 185, 150)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 45, 25)),
})
edgeShade.Parent = pageEdges
local bookScale = Instance.new("UIScale")
bookScale.Parent = book
if Config.JOURNAL_LEFT_IMAGE_ID == 0 or Config.JOURNAL_RIGHT_IMAGE_ID == 0 then
	warn("[JournalUI] Book images not set yet: upload art/journal-left.png and art/journal-right.png and put their IDs in Config")
end

-- a Modal button frees the mouse while the journal is open (first person normally locks it)
local mouseFreer = Instance.new("TextButton")
mouseFreer.Text = ""
mouseFreer.BackgroundTransparency = 1
mouseFreer.Size = UDim2.fromOffset(1, 1)
mouseFreer.Modal = false -- switched on while the journal is open
mouseFreer.Parent = book

local function label(parent, text, font, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = font
	l.TextColor3 = color
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local textFrames = {}
local function textArea(area)
	local f = Instance.new("Frame")
	f.BackgroundTransparency = 1
	f.Position = UDim2.fromScale(area.x, area.y)
	f.Size = UDim2.fromScale(area.w, area.h)
	f.Visible = false -- only shown once the book is fully open
	f.Parent = book
	table.insert(textFrames, f)
	return f
end

-- left page: the clue list, newest at the top
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.fromScale(1, 1)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = BRASS
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = textArea(LEFT_TEXT)
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list
local empty = label(list, "No clues yet. Investigate what you find at night.", Enum.Font.Garamond, FADED_INK)
empty.Size = UDim2.new(1, -8, 0, 0)
empty.AutomaticSize = Enum.AutomaticSize.Y
empty.LayoutOrder = 0

-- text sizes follow the size of the book, so it reads the same on any screen
local sizes = { header = 16, body = 20, notes = 22 }
local headers, bodies = {}, {}
local function applySizes()
	local h = book.AbsoluteSize.Y
	sizes.header = math.max(12, math.floor(h * 0.021))
	sizes.body = math.max(14, math.floor(h * 0.027))
	sizes.notes = math.max(14, math.floor(h * 0.03))
	layout.Padding = UDim.new(0, math.floor(h * 0.02))
	empty.TextSize = sizes.body
	for _, l in headers do l.TextSize = sizes.header end
	for _, l in bodies do l.TextSize = sizes.body end
end

local clueCount = 0
local function addClueEntry(clue)
	clueCount += 1
	empty.Visible = false
	local entry = Instance.new("Frame")
	entry.BackgroundTransparency = 1
	entry.Size = UDim2.new(1, -8, 0, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.LayoutOrder = -clueCount -- newest first
	entry.Parent = list
	local entryLayout = Instance.new("UIListLayout")
	entryLayout.Padding = UDim.new(0, 2)
	entryLayout.Parent = entry

	local where = { "Night " .. clue.night }
	if clue.stage ~= "" then table.insert(where, STAGE_NAMES[clue.stage] or clue.stage) end
	if clue.district ~= "" then table.insert(where, clue.district) end
	local header = label(entry, table.concat(where, "  ·  "), Enum.Font.Garamond, FADED_INK)
	header.Size = UDim2.new(1, 0, 0, 0)
	header.AutomaticSize = Enum.AutomaticSize.Y
	header.TextSize = sizes.header
	table.insert(headers, header)
	local body = label(entry, clue.text, Enum.Font.Garamond, INK)
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.TextSize = sizes.body
	table.insert(bodies, body)
end

-- right page: one big handwritten text box
local notes = Instance.new("TextBox")
notes.Size = UDim2.fromScale(1, 1)
notes.BackgroundTransparency = 1
notes.Font = Enum.Font.IndieFlower -- handwriting
notes.TextColor3 = INK
notes.PlaceholderText = "Write anything here..."
notes.PlaceholderColor3 = FADED_INK
notes.Text = ""
notes.MultiLine = true
notes.ClearTextOnFocus = false
notes.TextWrapped = true
notes.TextXAlignment = Enum.TextXAlignment.Left
notes.TextYAlignment = Enum.TextYAlignment.Top
notes.Parent = textArea(RIGHT_TEXT)

book:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	applySizes()
	notes.TextSize = sizes.notes
end)
applySizes()
notes.TextSize = sizes.notes

-- a round brass X button on the book's top-right corner, to close it by tapping (phones and tablets)
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Text = ""
closeButton.AnchorPoint = Vector2.new(0.5, 0.5)
closeButton.Position = UDim2.fromScale(0.99, 0.02) -- over the corner, sticking out past the edge
closeButton.Size = UDim2.fromScale(0.1, 0.1)
closeButton.SizeConstraint = Enum.SizeConstraint.RelativeYY -- a circle, sized by the book's height
closeButton.BackgroundColor3 = Color3.fromRGB(207, 162, 76)
closeButton.AutoButtonColor = true
closeButton.ZIndex = 10
closeButton.Visible = false -- only shown once the book is fully open
closeButton.Parent = book
table.insert(textFrames, closeButton)
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)
local closeEdge = Instance.new("UIStroke")
closeEdge.Color = Color3.fromRGB(42, 24, 6)
closeEdge.Thickness = 3
closeEdge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
closeEdge.Parent = closeButton
local closeMin = Instance.new("UISizeConstraint") -- never smaller than a fingertip
closeMin.MinSize = Vector2.new(48, 48)
closeMin.Parent = closeButton
for _, turn in { 45, -45 } do -- the X: two dark bars crossed
	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.5)
	bar.Size = UDim2.fromScale(0.6, 0.12)
	bar.Rotation = turn
	bar.BackgroundColor3 = Color3.fromRGB(42, 24, 6)
	bar.BorderSizePixel = 0
	bar.ZIndex = 11
	bar.Parent = closeButton
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
end

-- the journal icon in the corner, with the key as a brass badge (clicking it opens the journal)
local iconGui = Instance.new("ScreenGui")
iconGui.Name = "JournalIcon"
iconGui.ResetOnSpawn = false
iconGui.IgnoreGuiInset = true
local icon = Instance.new("ImageButton")
icon.Name = "Icon"
icon.AnchorPoint = Vector2.new(1, 1)
icon.Position = UDim2.fromScale(1 - Config.JOURNAL_ICON_MARGIN, 1 - Config.JOURNAL_ICON_MARGIN)
icon.Size = UDim2.fromScale(1, Config.JOURNAL_ICON_SIZE)
icon.BackgroundTransparency = 1
icon.Parent = iconGui
local iconRatio = Instance.new("UIAspectRatioConstraint")
iconRatio.AspectRatio = 1
iconRatio.DominantAxis = Enum.DominantAxis.Height
iconRatio.Parent = icon
if Config.JOURNAL_ICON_IMAGE_ID ~= 0 then
	icon.Image = "rbxassetid://" .. Config.JOURNAL_ICON_IMAGE_ID
else -- no image uploaded yet: a plain leather-coloured square
	icon.BackgroundTransparency = 0
	icon.BackgroundColor3 = Color3.fromRGB(85, 35, 15)
	Instance.new("UICorner", icon).CornerRadius = UDim.new(0.1, 0)
end

local badge = Instance.new("TextLabel") -- the key, on a round brass badge (only until the icon image is uploaded)
badge.Name = "KeyBadge"
badge.AnchorPoint = Vector2.new(0.5, 0.5)
badge.Position = UDim2.fromScale(0.82, 0.82)
badge.Size = UDim2.fromScale(0.38, 0.38)
badge.BackgroundColor3 = Color3.fromRGB(207, 162, 76)
badge.Text = Config.JOURNAL_KEY
badge.Font = Enum.Font.Garamond
badge.TextScaled = true
badge.TextColor3 = Color3.fromRGB(42, 24, 6)
badge.Visible = Config.JOURNAL_ICON_IMAGE_ID == 0 -- the uploaded icon already has a fancy J on it
badge.Parent = icon
Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)
local badgeEdge = Instance.new("UIStroke")
badgeEdge.Color = Color3.fromRGB(42, 24, 6)
badgeEdge.Thickness = 2
badgeEdge.Parent = badge

local newDot = Instance.new("Frame") -- shows there's a clue you haven't looked at yet
newDot.Name = "NewClueDot"
newDot.AnchorPoint = Vector2.new(0.5, 0.5)
newDot.Position = UDim2.fromScale(0.85, 0.12)
newDot.Size = UDim2.fromScale(0.22, 0.22)
newDot.BackgroundColor3 = Color3.fromRGB(156, 31, 34)
newDot.Visible = false
newDot.Parent = icon
Instance.new("UICorner", newDot).CornerRadius = UDim.new(1, 0)
local dotEdge = Instance.new("UIStroke")
dotEdge.Color = Color3.fromRGB(246, 223, 156)
dotEdge.Thickness = 2
dotEdge.Parent = newDot
iconGui.Parent = player:WaitForChild("PlayerGui")

-- a short message when a new clue arrives
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "JournalToast"
toastGui.ResetOnSpawn = false
local toast = label(toastGui, "", Enum.Font.Garamond, PAPER)
toast.TextSize = 22
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 60)
toast.Size = UDim2.fromOffset(500, 28)
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.TextStrokeTransparency = 0.5
toast.Visible = false

gui.Parent = player:WaitForChild("PlayerGui")
toastGui.Parent = player.PlayerGui

---------------------------------------------------------------- loading, saving, opening
local journal = remotes:WaitForChild("Get"):InvokeServer()
for _, clue in journal.clues do
	addClueEntry(clue)
end
notes.Text = journal.notes

local isOpen = false -- whether the journal is open (or opening)
local shown = 0
remotes:WaitForChild("NewClue").OnClientEvent:Connect(function(clue)
	addClueEntry(clue)
	if not isOpen then newDot.Visible = true end
	toast.Text = "A new clue in your journal  (" .. Config.JOURNAL_KEY .. ")"
	toast.Visible = true
	shown += 1
	local mine = shown
	task.delay(3, function()
		if shown == mine then toast.Visible = false end
	end)
end)

-- notes are sent to the server a moment after you stop typing, and when you click away
local saveNotes = remotes:WaitForChild("SaveNotes")
local lastSent = notes.Text
local function sendNotes()
	if notes.Text ~= lastSent then
		lastSent = notes.Text
		saveNotes:FireServer(notes.Text)
	end
end
notes:GetPropertyChangedSignal("Text"):Connect(function()
	if #notes.Text > Config.JOURNAL_NOTES_MAX then
		notes.Text = string.sub(notes.Text, 1, Config.JOURNAL_NOTES_MAX)
	end
end)
notes.FocusLost:Connect(sendNotes)
task.spawn(function()
	while true do
		task.wait(2)
		sendNotes()
	end
end)

---------------------------------------------------------------- the open / close animation
-- clock runs from 0 (closed, off screen) to the total time (open), in seconds:
--   rise (the closed book comes up) -> the front half swings open.
-- Closing runs the same clock backwards (faster), so it plays in reverse.
local RISE, COVER = Config.JOURNAL_RISE_TIME, Config.JOURNAL_COVER_TIME
local TOTAL = RISE + COVER
local clock = 0

local function sound(id)
	if id == 0 then return nil end
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. id
	s.Volume = Config.JOURNAL_SOUND_VOLUME
	s.Parent = gui
	return s
end
local openSound = sound(Config.JOURNAL_OPEN_SOUND_ID)
local closeSound = sound(Config.JOURNAL_CLOSE_SOUND_ID)

local function smooth(x) -- eases in and out
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end
local function part(start, length) -- how far through one step of the animation we are, 0 to 1
	if length <= 0 then return clock >= start and 1 or 0 end
	return smooth((clock - start) / length)
end

local function turning(angle) -- size bump and shading for something turning over (0 to pi)
	local lift = 1 + 0.06 * math.sin(angle) -- the edge coming towards you looks a little bigger
	local shade = 0.55 + 0.45 * math.abs(math.cos(angle)) -- darker when it's side-on
	return lift, Color3.new(shade, shade, shade)
end

local function draw()
	local rise = part(0, RISE)
	local swing = part(RISE, COVER)
	local angle = swing * math.pi -- 0 = cover shut, pi = cover lying open on the left

	-- while closed the right half (the cover) sits in the middle of the screen; it slides to the
	-- left as the cover opens, so the open book ends up centred
	book.AnchorPoint = Vector2.new(0.75 - 0.25 * swing, 0.5)
	book.Position = UDim2.fromScale(0.5, 0.5 + 0.9 * (1 - rise)) -- comes up from below the screen
	bookScale.Scale = 0.85 + 0.15 * rise

	-- the cover: as wide as cos(angle) on the right, then its inside lands on the left
	local lift, grey = turning(angle)
	cover.Visible = angle < math.pi / 2
	cover.Size = UDim2.fromScale(0.5 * math.max(math.cos(angle), 0), lift)
	cover.ImageColor3 = grey
	leftPage.Visible = angle > math.pi / 2
	leftPage.Size = UDim2.fromScale(0.5 * math.max(-math.cos(angle), 0), angle > math.pi / 2 and lift or 1)
	leftPage.ImageColor3 = grey

	-- side-on, you see the thickness of the half that is turning
	pageEdges.Visible = angle > 0 and angle < math.pi
	pageEdges.Size = UDim2.fromScale(Config.JOURNAL_THICKNESS * math.sin(angle), 0.96 * lift)

	dim.BackgroundTransparency = 1 - 0.55 * rise
	for _, f in textFrames do f.Visible = clock >= TOTAL end
	gui.Enabled = clock > 0
end
draw()

RunService.RenderStepped:Connect(function(dt)
	local target = isOpen and TOTAL or 0
	if clock == target then return end
	if State.reduceMotion then
		clock = target -- no animation
	elseif isOpen then
		clock = math.min(clock + dt, TOTAL)
	else
		clock = math.max(clock - dt * Config.JOURNAL_CLOSE_SPEED, 0)
	end
	draw()
end)

local function setOpen(open)
	if open == isOpen then return end
	isOpen = open
	if open then
		newDot.Visible = false
		if openSound then openSound:Play() end
	else
		notes:ReleaseFocus()
		sendNotes()
		if closeSound then closeSound:Play() end
	end
	gui.Enabled = true
	mouseFreer.Modal = open -- give the mouse back to the camera straight away when closing
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- e.g. typing in the notes or chat
	if input.KeyCode == Enum.KeyCode[Config.JOURNAL_KEY] then
		setOpen(not isOpen)
	end
end)
icon.Activated:Connect(function()
	setOpen(not isOpen)
end)
closeButton.Activated:Connect(function()
	setOpen(false)
end)
