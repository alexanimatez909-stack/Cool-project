-- MakeMovementAnimations: builds everyone's movement animations as KeyframeSequences.
-- Paste the whole file into Studio's Command Bar (View > Command Bar) and press Enter.
-- It creates them in ServerStorage > MovementAnimations, plus copies the Animation Editor can load for a rig
-- named "Dummy" (Avatar tab > Rig Builder > R15). Open each one in the Animation Editor, tweak, and publish it.
--
-- Decided with Alexander:
--   * Style: CAUTIOUS - slightly hunched, careful, nervous in the dark.
--   * Made for first person: arms stay low and close to the body so they don't swing across the view
--     (the camera doesn't follow the body's lean, so the hunch never tilts your view).
--   * The lantern hangs from the belt when it's off; LanternHold raises it in the LEFT hand when it's on.
--     LanternHold only moves the left arm, so it plays ON TOP of any movement animation.
--   * No jumping, so there is no jump/fall animation.
-- Speeds: the loops are timed to the footstep rhythm in Config (walk 8 studs per step at 18, sprint 7 at 28),
-- so legs, head bob and footstep sounds land together. The game speeds them up/down to match how fast you move.
-- Angles are a first guess: tweak them in the Animation Editor until they look right.

local ServerStorage = game:GetService("ServerStorage")

-- Joint angles are in degrees: { x, y, z } and optional py (raise/lower the body, LowerTorso only).
-- Arms/legs: positive x swings FORWARD, negative BACK. Knees: negative x bends. Feet: positive x lifts the toes.
-- Torso/Head: negative x leans/looks DOWN-forward, positive y turns LEFT.
-- Arms: positive z moves the right arm OUT and the left arm IN.

-- Swap left and right (for the second half of a step).
local function mirror(joints)
	local out = {}
	for name, a in pairs(joints) do
		local other = name:gsub("^Left", "@"):gsub("^Right", "Left"):gsub("^@", "Right")
		out[other] = { x = a.x, y = -(a.y or 0), z = -(a.z or 0), py = a.py }
	end
	return out
end

local function j(x, y, z) return { x = x or 0, y = y or 0, z = z or 0 } end

-- ---------------------------------------------------------------- Walk (cautious)
local walkContact = { -- right foot lands in front
	LowerTorso = { x = 0, py = -0.12 },
	UpperTorso = j(-6, -4), Head = j(6, 4),
	RightUpperLeg = j(28), RightLowerLeg = j(-8), RightFoot = j(-10),
	LeftUpperLeg = j(-22), LeftLowerLeg = j(-25), LeftFoot = j(30),
	RightUpperArm = j(-12, 0, 4), RightLowerArm = j(20),
	LeftUpperArm = j(16, 0, -4), LeftLowerArm = j(30),
}
local walkPassing = { -- left leg swings past
	LowerTorso = { x = 0, py = 0.04 },
	UpperTorso = j(-6), Head = j(6),
	RightUpperLeg = j(2), RightLowerLeg = j(-5), RightFoot = j(3),
	LeftUpperLeg = j(15), LeftLowerLeg = j(-55), LeftFoot = j(25),
	RightUpperArm = j(0, 0, 4), RightLowerArm = j(22),
	LeftUpperArm = j(2, 0, -4), LeftLowerArm = j(22),
}

-- ---------------------------------------------------------------- Sprint
local sprintContact = {
	LowerTorso = { x = 0, py = -0.2 },
	UpperTorso = j(-15, -6), Head = j(15, 6),
	RightUpperLeg = j(50), RightLowerLeg = j(-20), RightFoot = j(-5),
	LeftUpperLeg = j(-35), LeftLowerLeg = j(-50), LeftFoot = j(30),
	RightUpperArm = j(-35, 0, 5), RightLowerArm = j(80), RightHand = j(-10),
	LeftUpperArm = j(35, 0, -5), LeftLowerArm = j(85), LeftHand = j(-10),
}
local sprintPassing = {
	LowerTorso = { x = 0, py = 0.15 },
	UpperTorso = j(-15), Head = j(15),
	RightUpperLeg = j(0), RightLowerLeg = j(-10), RightFoot = j(5),
	LeftUpperLeg = j(30), LeftLowerLeg = j(-100), LeftFoot = j(30),
	RightUpperArm = j(0, 0, 5), RightLowerArm = j(80), RightHand = j(-10),
	LeftUpperArm = j(0, 0, -5), LeftLowerArm = j(80), LeftHand = j(-10),
}

-- ---------------------------------------------------------------- Crouch
-- Body drops about 1.5 studs: thighs forward, knees bent, feet kept flat (thigh + knee + foot = 0).
local function crouchBase(breath)
	return {
		LowerTorso = { x = 0, py = -1.45 + breath * 0.03 },
		UpperTorso = j(-25 + breath * 2), Head = j(25 - breath * 2),
		RightUpperLeg = j(70), RightLowerLeg = j(-130), RightFoot = j(60),
		LeftUpperLeg = j(70), LeftLowerLeg = j(-130), LeftFoot = j(60),
		RightUpperArm = j(20, 0, 5), RightLowerArm = j(40),
		LeftUpperArm = j(20, 0, -5), LeftLowerArm = j(40),
	}
end
local crouchContact = {
	LowerTorso = { x = 0, py = -1.5 },
	UpperTorso = j(-25, -3), Head = j(25, 3),
	RightUpperLeg = j(85), RightLowerLeg = j(-125), RightFoot = j(40),
	LeftUpperLeg = j(50), LeftLowerLeg = j(-135), LeftFoot = j(85),
	RightUpperArm = j(15, 0, 5), RightLowerArm = j(40),
	LeftUpperArm = j(25, 0, -5), LeftLowerArm = j(40),
}
local crouchPassing = {
	LowerTorso = { x = 0, py = -1.4 },
	UpperTorso = j(-25), Head = j(25),
	RightUpperLeg = j(65), RightLowerLeg = j(-130), RightFoot = j(65),
	LeftUpperLeg = j(75), LeftLowerLeg = j(-145), LeftFoot = j(70),
	RightUpperArm = j(20, 0, 5), RightLowerArm = j(40),
	LeftUpperArm = j(20, 0, -5), LeftLowerArm = j(40),
}

-- ---------------------------------------------------------------- Idle (slow breathing)
local function idlePose(breath)
	return {
		LowerTorso = { x = 0, py = breath * 0.02 },
		UpperTorso = j(-6 + breath * 2), Head = j(6 - breath * 2),
		RightUpperLeg = j(2), RightLowerLeg = j(-4), RightFoot = j(2),
		LeftUpperLeg = j(2), LeftLowerLeg = j(-4), LeftFoot = j(2),
		RightUpperArm = j(3 - breath, 0, 4), RightLowerArm = j(12),
		LeftUpperArm = j(3 - breath, 0, -4), LeftLowerArm = j(12),
	}
end

-- ---------------------------------------------------------------- Out of breath (hands towards the knees)
local function breathlessPose(breath)
	return {
		LowerTorso = { x = -15, py = -0.3 + breath * 0.03 },
		UpperTorso = j(-25 + breath * 4), Head = j(35 - breath * 4),
		RightUpperLeg = j(35), RightLowerLeg = j(-35), RightFoot = j(15),
		LeftUpperLeg = j(35), LeftLowerLeg = j(-35), LeftFoot = j(15),
		RightUpperArm = j(30 - breath * 2, 0, 8), RightLowerArm = j(10),
		LeftUpperArm = j(30 - breath * 2, 0, -8), LeftLowerArm = j(10),
	}
end

-- ---------------------------------------------------------------- Lantern held up (left arm only)
local function lanternPose(sway)
	return {
		LeftUpperArm = j(40 + sway * 2, 0, 10 - sway), LeftLowerArm = j(55), LeftHand = j(-45),
	}
end

-- Each animation: length in seconds, keyframes as { time, joints }, priority, and whether it only moves
-- some joints (partial = the other joints are left to whatever else is playing).
local ANIMATIONS = {
	{ name = "Idle", priority = Enum.AnimationPriority.Idle, length = 4,
		keys = { { 0, idlePose(0) }, { 2, idlePose(1) }, { 4, idlePose(0) } } },
	{ name = "Walk", priority = Enum.AnimationPriority.Movement, length = 0.9,
		keys = { { 0, walkContact }, { 0.225, walkPassing }, { 0.45, mirror(walkContact) },
			{ 0.675, mirror(walkPassing) }, { 0.9, walkContact } } },
	{ name = "Sprint", priority = Enum.AnimationPriority.Movement, length = 0.5,
		keys = { { 0, sprintContact }, { 0.125, sprintPassing }, { 0.25, mirror(sprintContact) },
			{ 0.375, mirror(sprintPassing) }, { 0.5, sprintContact } } },
	{ name = "CrouchIdle", priority = Enum.AnimationPriority.Movement, length = 3,
		keys = { { 0, crouchBase(0) }, { 1.5, crouchBase(1) }, { 3, crouchBase(0) } } },
	{ name = "CrouchWalk", priority = Enum.AnimationPriority.Movement, length = 1.2,
		keys = { { 0, crouchContact }, { 0.3, crouchPassing }, { 0.6, mirror(crouchContact) },
			{ 0.9, mirror(crouchPassing) }, { 1.2, crouchContact } } },
	{ name = "OutOfBreath", priority = Enum.AnimationPriority.Movement, length = 0.8,
		keys = { { 0, breathlessPose(0) }, { 0.4, breathlessPose(1) }, { 0.8, breathlessPose(0) } } },
	{ name = "LanternHold", priority = Enum.AnimationPriority.Action, length = 2, partial = true,
		keys = { { 0, lanternPose(0) }, { 1, lanternPose(1) }, { 2, lanternPose(0) } } },
}

-- The R15 joint tree: each part's pose sits inside its parent's pose.
local TREE = {
	HumanoidRootPart = { "LowerTorso" },
	LowerTorso = { "UpperTorso", "LeftUpperLeg", "RightUpperLeg" },
	UpperTorso = { "Head", "LeftUpperArm", "RightUpperArm" },
	LeftUpperArm = { "LeftLowerArm" }, LeftLowerArm = { "LeftHand" },
	RightUpperArm = { "RightLowerArm" }, RightLowerArm = { "RightHand" },
	LeftUpperLeg = { "LeftLowerLeg" }, LeftLowerLeg = { "LeftFoot" },
	RightUpperLeg = { "RightLowerLeg" }, RightLowerLeg = { "RightFoot" },
}

local rad = math.rad
local function addPose(parent, name, joints, partial)
	local a = joints[name]
	local pose = Instance.new("Pose")
	pose.Name = name
	if a then
		pose.CFrame = CFrame.new(0, a.py or 0, 0) * CFrame.Angles(rad(a.x or 0), rad(a.y or 0), rad(a.z or 0))
	end
	-- the root never moves; in a partial animation, joints it doesn't mention are left alone (weight 0)
	pose.Weight = (name == "HumanoidRootPart" or (partial and not a)) and 0 or 1
	pose.EasingStyle = Enum.PoseEasingStyle.Cubic
	pose.EasingDirection = Enum.PoseEasingDirection.InOut
	pose.Parent = parent
	for _, child in ipairs(TREE[name] or {}) do
		addPose(pose, child, joints, partial)
	end
end

local folder = ServerStorage:FindFirstChild("MovementAnimations")
if folder then folder:Destroy() end
folder = Instance.new("Folder")
folder.Name = "MovementAnimations"
folder.Parent = ServerStorage

-- where the Animation Editor looks for saved animations of a rig named "Dummy"
local saves = ServerStorage:FindFirstChild("RBX_ANIMSAVES")
if not saves then
	saves = Instance.new("Model")
	saves.Name = "RBX_ANIMSAVES"
	saves.Parent = ServerStorage
end
local rigSaves = saves:FindFirstChild("Dummy")
if not rigSaves then
	rigSaves = Instance.new("ObjectValue")
	rigSaves.Name = "Dummy"
	rigSaves.Value = workspace:FindFirstChild("Dummy")
	rigSaves.Parent = saves
end

for _, anim in ipairs(ANIMATIONS) do
	local seq = Instance.new("KeyframeSequence")
	seq.Name = anim.name
	seq.Loop = true
	seq.Priority = anim.priority
	for _, key in ipairs(anim.keys) do
		local kf = Instance.new("Keyframe")
		kf.Time = key[1]
		addPose(kf, "HumanoidRootPart", key[2], anim.partial)
		kf.Parent = seq
	end
	seq.Parent = folder

	local old = rigSaves:FindFirstChild(anim.name)
	if old then old:Destroy() end
	seq:Clone().Parent = rigSaves
end

print("[MakeMovementAnimations] created " .. #ANIMATIONS .. " animations in ServerStorage.MovementAnimations")
