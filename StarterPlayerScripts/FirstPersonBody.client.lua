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
	Arms = { "LeftLowerArm", "LeftHand", "RightLowerArm", "RightHand" }, -- forearms and hands
	UpperArms = { "LeftUpperArm", "RightUpperArm" }, -- the shoulders: right next to the camera, so they block the view
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
-- Returns the body part it belongs to (or nil if hidden).
local function visibleBodyPart(part, shown)
	if shown[part] then return part end
	if not part:FindFirstAncestorOfClass("Accessory") then return nil end
	for _, attachment in part:GetChildren() do
		if attachment:IsA("Attachment") then
			for bodyPart in shown do
				if bodyPart:FindFirstChild(attachment.Name) then return bodyPart end
			end
		end
	end
	return nil
end

-- Like DOORS: your upper body (torso, shoulders, arms, hands) only appears when you look DOWN.
-- Looking ahead you see none of your body; it fades in between FIRST_PERSON_BODY_FADE_START degrees below
-- level and that plus FIRST_PERSON_BODY_FADE_RANGE. (Legs are below your view when you look ahead anyway.)
local UPPER_BODY = {
	UpperTorso = true, LeftUpperArm = true, RightUpperArm = true,
	LeftLowerArm = true, RightLowerArm = true, LeftHand = true, RightHand = true,
}
local function upperBodyShown()
	local lookingDown = -math.deg(math.asin(math.clamp(camera.CFrame.LookVector.Y, -1, 1)))
	return math.clamp((lookingDown - Config.FIRST_PERSON_BODY_FADE_START) / Config.FIRST_PERSON_BODY_FADE_RANGE, 0, 1)
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
	local upperShown = upperBodyShown()
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then
			local bodyPart = not hideBody and visibleBodyPart(part, shown)
			if not bodyPart then
				part.LocalTransparencyModifier = 1
			elseif UPPER_BODY[bodyPart.Name] then
				part.LocalTransparencyModifier = 1 - upperShown
			else
				part.LocalTransparencyModifier = 0
			end
		end
	end
end)

-- Calmer arms: each frame the animation poses the arms, then (just before physics) this pulls
-- that pose part of the way back to "arms hanging straight at your sides".
-- Only for Roblox's default animations: our own (Config.MOVEMENT_ANIMATIONS) are already made for first person.
local ARM_JOINTS = { "RightShoulder", "LeftShoulder", "RightElbow", "LeftElbow" }
RunService.PreSimulation:Connect(function()
	local swing = Config.FIRST_PERSON_ARM_SWING
	if swing >= 1 or (Config.MOVEMENT_ANIMATIONS and (Config.MOVEMENT_ANIMATIONS.Walk or 0) ~= 0) then return end
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
