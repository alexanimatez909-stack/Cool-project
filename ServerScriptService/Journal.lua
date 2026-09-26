-- Journal (ModuleScript in ServerScriptService)
-- Keeps every player's journal on the server: the clues they've found and their own notes.
-- Clues can only be added here, by the server (a player can't fake one), and journals are kept
-- by player ID, so someone who disconnects and rejoins the match gets theirs back.
-- Other server scripts use it like this:
--   local Journal = require(game.ServerScriptService.Journal)
--   Journal.addClue(player, "Blood spots, fresh. They lead south, toward the river.", "Market")
--   Journal.clueCount(player)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local Journal = {}
local journals = {} -- [userId] = { clues = { {text, night, stage, district, at}, ... }, notes = "" }

-- the messages between the server and each player's journal screen
local remotes = Instance.new("Folder")
remotes.Name = "JournalRemotes"
local getJournal = Instance.new("RemoteFunction") -- player asks: "give me my journal"
getJournal.Name = "Get"
getJournal.Parent = remotes
local saveNotes = Instance.new("RemoteEvent")     -- player sends: "here are my notes"
saveNotes.Name = "SaveNotes"
saveNotes.Parent = remotes
local newClue = Instance.new("RemoteEvent")       -- server tells a player: "you found a clue"
newClue.Name = "NewClue"
newClue.Parent = remotes
remotes.Parent = ReplicatedStorage

local function journalOf(player)
	local journal = journals[player.UserId]
	if not journal then
		journal = { clues = {}, notes = "" }
		journals[player.UserId] = journal
	end
	return journal
end

-- Add a clue to a player's journal and show it to them straight away.
function Journal.addClue(player, text, district)
	local clue = {
		text = text,
		night = workspace:GetAttribute("Night") or 0,
		stage = workspace:GetAttribute("StageName") or "",
		district = district or "",
		at = workspace:GetServerTimeNow(),
	}
	table.insert(journalOf(player).clues, clue)
	newClue:FireClient(player, clue)
	return clue
end

function Journal.getClues(player)
	return journalOf(player).clues
end

function Journal.clueCount(player)
	return #journalOf(player).clues
end

-- Raw notes, exactly as the player wrote them. Before showing them to anyone ELSE
-- (e.g. a dropped journal), they must be filtered with TextService.
function Journal.getNotes(player)
	return journalOf(player).notes
end

getJournal.OnServerInvoke = function(player)
	return journalOf(player)
end

local lastSave = {} -- [userId] = time of the last save, so nobody can spam the server
saveNotes.OnServerEvent:Connect(function(player, text)
	if typeof(text) ~= "string" then return end
	local now = os.clock()
	if lastSave[player.UserId] and now - lastSave[player.UserId] < 0.5 then return end
	lastSave[player.UserId] = now
	journalOf(player).notes = string.sub(text, 1, Config.JOURNAL_NOTES_MAX)
end)

Players.PlayerRemoving:Connect(function(player)
	lastSave[player.UserId] = nil -- the journal itself is kept in case they rejoin
end)

return Journal
