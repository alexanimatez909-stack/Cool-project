-- LanternControl (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Press the lantern key (Config.LANTERN_KEY) to switch the lantern on your belt on or off.
-- It only asks the server (LanternBelt), which decides and switches it for everyone.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local remote = ReplicatedStorage:WaitForChild("LanternToggle")

UserInputService.InputBegan:Connect(function(input, typing)
	if typing then return end -- e.g. typing in the chat
	if input.KeyCode == Enum.KeyCode[Config.LANTERN_KEY] then
		remote:FireServer()
	end
end)
