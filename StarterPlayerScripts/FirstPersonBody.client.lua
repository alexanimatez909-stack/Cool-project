-- FirstPersonBody (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Lets you see your own body when you look down in first person.
-- Every frame Roblox hides your whole character in first person; straight after that, this shows
-- the body parts chosen in Config.FIRST_PERSON_BODY (legs / torso / arms) and anything worn on
-- them. The head always stays hidden, because the camera sits inside it.
-- Your arms also swing less in first person (Config.FIRST_PERSON_ARM_SWING) so they stay low and
-- close to your body instead of swinging into view. Only you see that; others see the full animation.
-- Until there's a crouch animation (Config.MOVEMENT_ANIMATIONS.CrouchIdle), the body hides while you crouch,
-- because the lowered camera would otherwise end up inside your chest.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local State = require(script.Parent:WaitForChild("MovementState"))
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local BODY_GROUPS = {
	Legs = { "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
	Torso = { "UpperTorso" },
	Arms = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand" },
}

-- the body parts to show right now, as a set: shown[part] = true
local function shownParts(character)
	local shown = {}
	for group, names in BODY_GROUPS do
		if Config.FIRST_PERSON_BODY[group] then
			for _, name in names do
				local part = character:FindFirstChild(name)
				if part then shown[part] = true end
			end
		end
	end
	return shown
end

-- a body part is visible if it's in the shown set; an accessory (belt, jacket, hat...) is visible
-- if the body part it hangs from is shown. Anything on the head is therefore always hidden.
local function isVisible(part, shown)
	if shown[part] then return true end
	if not part:FindFirstAncestorOfClass("Accessory") then return false end
	for _, attachment in part:GetChildren() do
		if attachment:IsA("Attachment") then
			for bodyPart in shown do
				if bodyPart:FindFirstChild(attachment.Name) then return true end
			end
		end
	end
	return false
end

local function isFirstPerson(head)
	return player.CameraMode == Enum.CameraMode.LockFirstPerson
		or (camera.CFrame.Position - head.Position).Magnitude < 3
end

RunService:BindToRenderStep("FirstPersonBody", Enum.RenderPriority.Camera.Value + 2, function()
	if not Config.SHOW_BODY_IN_FIRST_PERSON then return end
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	-- only in first person (in third person Roblox shows everything anyway)
	if not head or not isFirstPerson(head) then return end

	local hideBody = State.crouching and (Config.MOVEMENT_ANIMATIONS.CrouchIdle or 0) == 0
	local shown = shownParts(character)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = (not hideBody and isVisible(part, shown)) and 0 or 1
		end
	end
end)

-- Calmer arms: each frame the animation poses the arms, then (just before physics) this pulls
-- that pose part of the way back to "arms hanging straight at your sides".
local ARM_JOINTS = { "RightShoulder", "LeftShoulder", "RightElbow", "LeftElbow" }
RunService.PreSimulation:Connect(function()
	local swing = Config.FIRST_PERSON_ARM_SWING
	if swing >= 1 then return end
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head or not isFirstPerson(head) then return end
	for _, name in ARM_JOINTS do
		local joint = character:FindFirstChild(name, true)
		if joint and joint:IsA("Motor6D") then
			joint.Transform = CFrame.identity:Lerp(joint.Transform, swing)
		end
	end
end)
