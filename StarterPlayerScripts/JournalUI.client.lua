-- JournalUI (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Your journal: press J to open or close it. An open Victorian book covering most of the screen:
--   left page, Clues: filled in automatically when you find something (night, stage, district).
--   right page, Notes: write anything you like. Saved to the server, kept for the whole match.
-- You can keep walking while it's open. The mouse is freed so you can click and type, which
-- means you can't look around until you close it again.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
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

local function pageImage(id, x)
	local image = Instance.new("ImageLabel")
	image.Position = UDim2.fromScale(x, 0)
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
pageImage(Config.JOURNAL_LEFT_IMAGE_ID, 0)
pageImage(Config.JOURNAL_RIGHT_IMAGE_ID, 0.5)
if Config.JOURNAL_LEFT_IMAGE_ID == 0 or Config.JOURNAL_RIGHT_IMAGE_ID == 0 then
	warn("[JournalUI] Book images not set yet: upload art/journal-left.png and art/journal-right.png and put their IDs in Config")
end

-- a Modal button frees the mouse while the journal is open (first person normally locks it)
local mouseFreer = Instance.new("TextButton")
mouseFreer.Text = ""
mouseFreer.BackgroundTransparency = 1
mouseFreer.Size = UDim2.fromOffset(1, 1)
mouseFreer.Modal = true
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

local function textArea(area)
	local f = Instance.new("Frame")
	f.BackgroundTransparency = 1
	f.Position = UDim2.fromScale(area.x, area.y)
	f.Size = UDim2.fromScale(area.w, area.h)
	f.Parent = book
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

local shown = 0
remotes:WaitForChild("NewClue").OnClientEvent:Connect(function(clue)
	addClueEntry(clue)
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end -- e.g. typing in the notes or chat
	if input.KeyCode == Enum.KeyCode[Config.JOURNAL_KEY] then
		gui.Enabled = not gui.Enabled
		if not gui.Enabled then
			notes:ReleaseFocus()
			sendNotes()
		end
	end
end)
