-- JournalServer (Script in ServerScriptService)
-- Starts the journal (the Journal module). For testing, while Config.JOURNAL_TEST_CLUES is on,
-- every player gets a made-up clue at each bell so you can see clues arrive in the journal.
-- Turn that off once the real clue system exists.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Journal = require(script.Parent:WaitForChild("Journal"))

local TEST_CLUES = {
	Dusk = "Test clue: fresh boot prints in the mud, heading toward Soho.",
	DeepNight = "Test clue: a torn thread of red wool caught on a railing.",
	LastHour = "Test clue: a lantern was seen near the Docks at the second bell.",
}

if Config.JOURNAL_TEST_CLUES then
	workspace:GetAttributeChangedSignal("StageName"):Connect(function()
		local text = TEST_CLUES[workspace:GetAttribute("StageName")]
		if not text then return end
		for _, player in Players:GetPlayers() do
			Journal.addClue(player, text, "Test district")
		end
	end)
end
