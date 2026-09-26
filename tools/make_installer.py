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
    ("ServerScriptService/AvatarRules.server.lua", "ServerScriptService", "AvatarRules", "Script"),
    ("ServerScriptService/NightCycle.server.lua", "ServerScriptService", "NightCycle", "Script"),
]

out = ["-- Paste into Studio's Command Bar (View > Command Bar) and press Enter.",
       "-- Replaces the scripts below with the versions from the repo.",
       "local done = {}"]
for path, parent, name, cls in SCRIPTS:
    src = open(path).read()
    assert "]=]" not in src, path
    out.append(f'''do
	local parent = game
	for part in ("{parent}"):gmatch("[^.]+") do parent = parent:WaitForChild(part) end
	local s = parent:FindFirstChild("{name}")
	if s and s.ClassName ~= "{cls}" then s:Destroy(); s = nil end
	s = s or Instance.new("{cls}")
	s.Name = "{name}"
	s.Source = [=[
{src}]=]
	s.Parent = parent
	table.insert(done, "{parent}.{name}")
end''')
out.append('print("INSTALL" .. "ED: " .. table.concat(done, ", "))')
sys.stdout.write("\n".join(out) + "\n")
