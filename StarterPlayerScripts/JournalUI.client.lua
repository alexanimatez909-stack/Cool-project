-- JournalUI (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Your journal: press J to open or close it. Two pages:
--   Clues: filled in automatically when you find something (with the night, stage and district).
--   Notes: write anything you like. Saved to the server, kept for the whole match.
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

---------------------------------------------------------------- building the notebook
local gui = Instance.new("ScreenGui")
gui.Name = "Journal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = false

local book = Instance.new("Frame")
book.Name = "Book"
book.AnchorPoint = Vector2.new(1, 0.5)
book.Position = UDim2.fromScale(0.97, 0.5)
book.Size = UDim2.fromScale(1, 0.66)
book.BackgroundColor3 = PAPER
book.Parent = gui
local ratio = Instance.new("UIAspectRatioConstraint")
ratio.AspectRatio = 0.75
ratio.DominantAxis = Enum.DominantAxis.Height
ratio.Parent = book
Instance.new("UICorner", book).CornerRadius = UDim.new(0, 6)
local edge = Instance.new("UIStroke")
edge.Color = BRASS
edge.Thickness = 3
edge.Parent = book
local padding = Instance.new("UIPadding")
padding.PaddingTop, padding.PaddingBottom = UDim.new(0.03, 0), UDim.new(0.03, 0)
padding.PaddingLeft, padding.PaddingRight = UDim.new(0.06, 0), UDim.new(0.06, 0)
padding.Parent = book

local function label(parent, text, font, size, color)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = font
	l.TextSize = size
	l.TextColor3 = color
	l.TextWrapped = true
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local title = label(book, "Journal", Enum.Font.Garamond, 34, INK)
title.Size = UDim2.new(1, 0, 0, 40)
title.TextXAlignment = Enum.TextXAlignment.Center

-- the two tabs
local tabs = {}
local function makeTab(name, x)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = name
	b.Font = Enum.Font.Garamond
	b.TextSize = 24
	b.TextColor3 = INK
	b.BackgroundTransparency = 1
	b.Position = UDim2.new(x, 0, 0, 44)
	b.Size = UDim2.new(0.5, 0, 0, 30)
	b.Parent = book
	local underline = Instance.new("Frame")
	underline.Name = "Underline"
	underline.AnchorPoint = Vector2.new(0.5, 1)
	underline.Position = UDim2.fromScale(0.5, 1)
	underline.Size = UDim2.new(0.5, 0, 0, 2)
	underline.BackgroundColor3 = BRASS
	underline.BorderSizePixel = 0
	underline.Parent = b
	tabs[name] = b
	return b
end
makeTab("Clues", 0)
makeTab("Notes", 0.5)
-- a Modal button frees the mouse while the journal is open (first person normally locks it)
tabs.Clues.Modal = true

local PAGE_TOP = 84
local function makePage(name)
	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.BackgroundTransparency = 1
	page.Position = UDim2.new(0, 0, 0, PAGE_TOP)
	page.Size = UDim2.new(1, 0, 1, -PAGE_TOP)
	page.Parent = book
	return page
end

-- Clues page: a scrolling list, newest at the top
local cluesPage = makePage("Clues")
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.fromScale(1, 1)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = BRASS
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = cluesPage
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list
local empty = label(list, "No clues yet. Investigate what you find at night.", Enum.Font.Garamond, 20, FADED_INK)
empty.Size = UDim2.new(1, -8, 0, 50)
empty.LayoutOrder = 0

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
	local header = label(entry, table.concat(where, "  ·  "), Enum.Font.Garamond, 17, FADED_INK)
	header.Size = UDim2.new(1, 0, 0, 18)
	local body = label(entry, clue.text, Enum.Font.Garamond, 21, INK)
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
end

-- Notes page: one big handwritten text box
local notesPage = makePage("Notes")
local notes = Instance.new("TextBox")
notes.Size = UDim2.fromScale(1, 1)
notes.BackgroundTransparency = 1
notes.Font = Enum.Font.IndieFlower -- handwriting
notes.TextSize = 22
notes.TextColor3 = INK
notes.PlaceholderText = "Write anything here..."
notes.PlaceholderColor3 = FADED_INK
notes.Text = ""
notes.MultiLine = true
notes.ClearTextOnFocus = false
notes.TextWrapped = true
notes.TextXAlignment = Enum.TextXAlignment.Left
notes.TextYAlignment = Enum.TextYAlignment.Top
notes.Parent = notesPage

local function showPage(name)
	cluesPage.Visible = name == "Clues"
	notesPage.Visible = name == "Notes"
	for tabName, tab in tabs do
		tab.Underline.Visible = tabName == name
		tab.TextTransparency = tabName == name and 0 or 0.4
	end
end
tabs.Clues.Activated:Connect(function() showPage("Clues") end)
tabs.Notes.Activated:Connect(function() showPage("Notes") end)
showPage("Clues")

-- a short message when a new clue arrives
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "JournalToast"
toastGui.ResetOnSpawn = false
local toast = label(toastGui, "", Enum.Font.Garamond, 22, PAPER)
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
