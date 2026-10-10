-- FirstPersonBody (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Lets you see your own body when you look down in first person.
-- Every frame Roblox hides your whole character in first person; straight after that, this shows
-- the body parts chosen in Config.FIRST_PERSON_BODY (legs / torso / arms) and anything worn on
-- them, plus the lantern on your belt. The head always stays hidden, because the camera sits inside it.
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
	-- the lantern hangs on your belt, so it shows with your hips (LanternBelt)
	local lantern = part:FindFirstAncestor("Lantern")
	if lantern and lantern.Parent == player.Character then
		return shown[player.Character:FindFirstChild("LowerTorso")] and part or nil
	end
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

-- Like DOORS: the body is ALWAYS there, it just sits below your view. Look straight ahead and you see none
-- of it; tilt the camera down a little and the edge of a hand creeps in; look right down and you see your chest,
-- arms and legs. Nothing pops in at a set angle. The only parts hidden are ones almost touching the camera
-- (closer than Config.FIRST_PERSON_NEAR_HIDE studs), which would otherwise fill the screen.
local function nearCamera(part)
	local p = part.CFrame:PointToObjectSpace(camera.CFrame.Position)
	local half = part.Size / 2
	local closest = Vector3.new(math.clamp(p.X, -half.X, half.X), math.clamp(p.Y, -half.Y, half.Y), math.clamp(p.Z, -half.Z, half.Z))
	return (p - closest).Magnitude < Config.FIRST_PERSON_NEAR_HIDE
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
			local bodyPart = not hideBody and visibleBodyPart(part, shown)
			if not bodyPart or nearCamera(part) then
				part.LocalTransparencyModifier = 1
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
