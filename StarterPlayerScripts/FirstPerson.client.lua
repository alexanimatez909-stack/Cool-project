-- FirstPerson (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Locks the camera to first person. (Movement speed is handled by the Movement script.)
-- Runs on each player's own computer, because the camera belongs to that player only.
-- Later, the night cycle (milestone 4) will switch first person on at night and off for the day debate.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local player = Players.LocalPlayer

local function setFirstPerson(on)
	player.CameraMode = on and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic
end

setFirstPerson(Config.FIRST_PERSON_AT_START)
