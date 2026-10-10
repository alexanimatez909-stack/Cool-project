"""Builds a Studio Command Bar installer from the script files in this repo.
Usage: python3 tools/make_installer.py > tools/RestorePlayerScripts.lua"""
import sys

# (repo file, parent path in Studio, name, class)
SCRIPTS = [
    ("ReplicatedStorage/Config.lua", "ReplicatedStorage", "Config", "ModuleScript"),
    ("StarterPlayerScripts/MovementState.lua", "StarterPlayer.StarterPlayerScripts", "MovementState", "ModuleScript"),
    ("StarterPlayerScripts/Movement.client.lua", "StarterPlayer.StarterPlayerScripts", "Movement", "LocalScript"),
    ("StarterPlayerScripts/CameraFeel.client.lua", "StarterPlayer.StarterPlayerScripts", "CameraFeel", "LocalScript"),
    ("StarterPlayerScripts/FirstPerson.client.lua", "StarterPlayer.StarterPlayerScripts", "FirstPerson", "LocalScript"),
    ("StarterPlayerScripts/StaminaBar.client.lua", "StarterPlayer.StarterPlayerScripts", "StaminaBar", "LocalScript"),
    ("StarterPlayerScripts/BreathingSound.client.lua", "StarterPlayer.StarterPlayerScripts", "Breathing_Sound", "LocalScript"),
    ("StarterPlayerScripts/FirstPersonBody.client.lua", "StarterPlayer.StarterPlayerScripts", "FirstPersonBody", "LocalScript"),
    ("StarterPlayerScripts/NightFog.client.lua", "StarterPlayer.StarterPlayerScripts", "NightFog", "LocalScript"),
    ("StarterPlayerScripts/NightClock.client.lua", "StarterPlayer.StarterPlayerScripts", "NightClock", "LocalScript"),
    ("StarterPlayerScripts/JournalUI.client.lua", "StarterPlayer.StarterPlayerScripts", "JournalUI", "LocalScript"),
    ("StarterPlayerScripts/Footsteps.client.lua", "StarterPlayer.StarterPlayerScripts", "Footsteps", "LocalScript"),
    ("StarterPlayerScripts/MovementAnimations.client.lua", "StarterPlayer.StarterPlayerScripts", "MovementAnimations", "LocalScript"),
    ("StarterPlayerScripts/LanternControl.client.lua", "StarterPlayer.StarterPlayerScripts", "LanternControl", "LocalScript"),
    ("ServerScriptService/LanternBelt.server.lua", "ServerScriptService", "LanternBelt", "Script"),
    ("ServerScriptService/Journal.lua", "ServerScriptService", "Journal", "ModuleScript"),
    ("ServerScriptService/JournalServer.server.lua", "ServerScriptService", "JournalServer", "Script"),
    ("ServerScriptService/AvatarRules.server.lua", "ServerScriptService", "AvatarRules", "Script"),
    ("ServerScriptService/NightCycle.server.lua", "ServerScriptService", "NightCycle", "Script"),
]

KEEP_IDS = """	-- keep the animation IDs you already pasted into Config in Studio (the repo copy may still have 0s)
	local oldBlock = oldSource:match("Config%.MOVEMENT_ANIMATIONS%s*=%s*(%b{})")
	if oldBlock then
		source = source:gsub("(Config%.MOVEMENT_ANIMATIONS%s*=%s*)(%b{})", function(head, block)
			block = block:gsub("(\\n%s*)(%w+)(%s*=%s*)0,", function(indent, key, eq)
				local id = oldBlock:match("[^%w]" .. key .. "%s*=%s*(%d+)")
				if id and id ~= "0" then return indent .. key .. eq .. id .. "," end
			end)
			return head .. block
		end, 1)
	end
"""

out = ["-- Paste into Studio's Command Bar (View > Command Bar) and press Enter.",
       "-- Replaces the scripts below with the versions from the repo.",
       "-- Animation IDs already in your Config (MOVEMENT_ANIMATIONS) are kept; other Config edits are replaced.",
       "local done = {}"]
for path, parent, name, cls in SCRIPTS:
    src = open(path).read()
    keep = KEEP_IDS if name == "Config" else ""
    assert "]=]" not in src, path
    out.append(f'''do
	local parent = game
	for part in ("{parent}"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("{name}")
	if s and s.ClassName ~= "{cls}" then s:Destroy(); s = nil end
	local oldSource = s and s.Source or ""
	s = s or Instance.new("{cls}")
	s.Name = "{name}"
	local source = [=[
{src}]=]
{keep}	s.Source = source
	s.Parent = parent
	table.insert(done, "{parent}.{name}")
end''')
out.append('print("INSTALL" .. "ED: " .. table.concat(done, ", "))')
sys.stdout.write("\n".join(out) + "\n")
