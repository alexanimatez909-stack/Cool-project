-- FirstPersonBody (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Lets you see your own body (torso, arms, legs) when you look down in first person.
-- Every frame Roblox hides your whole character in first person; straight after that, this shows
-- it again, except your head and anything worn on it (hats, hair), because the camera sits
-- inside your head.
-- Until there's a crouch animation (Config.CROUCH_ANIMATION_ID), the body hides while you crouch,
-- because the lowered camera would otherwise end up inside your chest.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- true for the head itself and for accessories worn on it (hats, hair, glasses).
-- An accessory is worn on the head if its attachment point (e.g. HatAttachment,
-- HairAttachment) is one of the head's attachment points.
local function isOnHead(part, head)
	if part == head then return true end
	if not part:FindFirstAncestorOfClass("Accessory") then return false end
	for _, attachment in part:GetChildren() do
		if attachment:IsA("Attachment") and head:FindFirstChild(attachment.Name) then
			return true
		end
	end
	return false
end

RunService:BindToRenderStep("FirstPersonBody", Enum.RenderPriority.Camera.Value + 2, function()
	if not Config.SHOW_BODY_IN_FIRST_PERSON then return end
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head then return end
	-- only in first person (in third person Roblox shows everything anyway)
	local firstPerson = player.CameraMode == Enum.CameraMode.LockFirstPerson
		or (camera.CFrame.Position - head.Position).Magnitude < 3
	if not firstPerson then return end

	local hideBody = State.crouching and Config.CROUCH_ANIMATION_ID == 0
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = (hideBody or isOnHead(part, head)) and 1 or 0
		end
	end
end)
