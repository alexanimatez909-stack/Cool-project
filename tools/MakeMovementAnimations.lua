-- MakeMovementAnimations: builds everyone's movement animations as KeyframeSequences.
-- Paste the whole file into Studio's Command Bar (View > Command Bar) and press Enter.
-- It creates them in ServerStorage > MovementAnimations, plus copies the Animation Editor can load for a rig
-- named "Dummy" (Avatar tab > Rig Builder > R15). Open each one in the Animation Editor, tweak, and publish it.
--
-- Decided with Alexander:
--   * Style: CAUTIOUS - slightly hunched, careful, nervous in the dark. Fluid, like DOORS.
--   * Made for first person: hands are carried low in front (you see them when you look down) but never
--     swing up across the view (the camera doesn't follow the body's lean, so the hunch never tilts your view).
--   * Moving sideways or backwards is handled by the MovementAnimations script (it turns the hips toward
--     where you're going and plays the walk backwards), so these are all forward animations.
--   * The lantern hangs from the belt when it's off; LanternHold raises it in the LEFT hand when it's on.
--     LanternHold only moves the left arm, so it plays ON TOP of any movement animation.
--   * No jumping, so there is no jump/fall animation.
-- Speeds: the loops are timed to the footstep rhythm in Config (walk 8 studs per step at 18, sprint 7 at 28),
-- so legs, head bob and footstep sounds land together. The game speeds them up/down to match how fast you move.
-- Angles are a first guess: tweak them in the Animation Editor until they look right.

local ServerStorage = game:GetService("ServerStorage")

-- STYLE (decided): blocky R15 body with FLUID movement, like DOORS (Alexander's reference): smooth blends,
-- hands carried in front of the body (visible when you look down), arms swinging with the opposite leg.
-- How poses blend into each other: Cubic = smooth and fluid (default); Linear = stiffer, puppet-like;
-- Constant = jumps from pose to pose like stop-motion. Change it, run the script again, and compare.
local EASING_STYLE = Enum.PoseEasingStyle.Cubic
-- How much the shoulders and head twist with each step (lifelike body detail). 0 = none, 1 = full.
local TWIST = 0.5
-- How far the arms swing (1 = the full DOORS scoop below; 0.5 = half; 0 = arms still halfway).
local ARM_SWING = 1

-- ARMS (Alexander's DOORS notes): calm swing; the elbow stays at about a RIGHT ANGLE, the upper arm hangs
-- nearly straight down and only swings a little, so the forearm stays LEVEL (upper arm + elbow = about 90).
-- At the front of the swing the elbow pushes out/up a bit and the hand scoops gently inward.

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

-- DOORS-style arms (from Alexander's frame-by-frame screenshots): at the back of the swing the arm hangs BY
-- YOUR SIDE, nearly straight. Swinging forward, the elbow bends and the forearm SCOOPS UP and slightly inward,
-- until the hand's skin side faces straight forward; at the very front it lifts ever so slightly more, then
-- drops back down to your side. t goes from -1 (arm back, by your side) to 1 (front, scooped up).
-- Each pose: upper arm forward, upper arm out, elbow bend, forearm curve inward, hand turn.
local ARM_BACK  = { up = -5, out = 3, elbow = 15,  curve = 0,  turn = 0 }
local ARM_FRONT = { up = 12, out = 6, elbow = 105, curve = 10, turn = 1 }
-- How far the hand turns at the front so its skin side faces forward (degrees). If it turns the wrong
-- way in the Animation Editor, make this negative.
local HAND_TURN = 0 -- decided: no hand twist
local function arms(rightT, leftT, size)
	-- size: 1 = walk; bigger for sprint. ARM_SWING scales everything around the middle of the swing.
	local out = {}
	for side, t in { Right = rightT, Left = leftT } do
		local sgn = side == "Right" and 1 or -1 -- z sign that points this arm OUTWARD
		local u = 0.5 + (t / 2) * ARM_SWING     -- 0 = back, 1 = front
		local function mix(key) return ARM_BACK[key] + (ARM_FRONT[key] - ARM_BACK[key]) * u end
		out[side .. "UpperArm"] = j(mix("up") * size, 0, sgn * mix("out"))
		out[side .. "LowerArm"] = j(mix("elbow"), 0, -sgn * mix("curve"))
		out[side .. "Hand"] = j(0, sgn * mix("turn") * HAND_TURN, 0)
	end
	return out
end
local function with(base, extra)
	for k, v in pairs(extra) do base[k] = v end
	return base
end

-- ---------------------------------------------------------------- Walk (cautious)
local walkContact = with({ -- right foot lands in front
	LowerTorso = { x = 0, py = -0.12 },
	UpperTorso = j(-4, -4 * TWIST), Head = j(4, 4 * TWIST),
	RightUpperLeg = j(28), RightLowerLeg = j(-8), RightFoot = j(-10),
	LeftUpperLeg = j(-22), LeftLowerLeg = j(-25), LeftFoot = j(30),
}, arms(-1, 1, 1)) -- right leg forward = right arm back (by your side), left arm scooped forward
local walkPassing = { -- left leg swings past
	LowerTorso = { x = 0, py = 0.04 },
	UpperTorso = j(-4), Head = j(4),
	RightUpperLeg = j(2), RightLowerLeg = j(-5), RightFoot = j(3),
	LeftUpperLeg = j(15), LeftLowerLeg = j(-55), LeftFoot = j(25),
}
with(walkPassing, arms(0, 0, 1))

-- ---------------------------------------------------------------- Sprint
local sprintContact = with({
	LowerTorso = { x = 0, py = -0.2 },
	UpperTorso = j(-7, -6 * TWIST), Head = j(7, 6 * TWIST),
	RightUpperLeg = j(50), RightLowerLeg = j(-20), RightFoot = j(-5),
	LeftUpperLeg = j(-35), LeftLowerLeg = j(-50), LeftFoot = j(30),
}, arms(-1, 1, 1.6))
local sprintPassing = {
	LowerTorso = { x = 0, py = 0.15 },
	UpperTorso = j(-7), Head = j(7),
	RightUpperLeg = j(0), RightLowerLeg = j(-10), RightFoot = j(5),
	LeftUpperLeg = j(30), LeftLowerLeg = j(-100), LeftFoot = j(30),
}
with(sprintPassing, arms(0, 0, 1.6))

-- ---------------------------------------------------------------- Crouch
-- Like DOORS: one foot planted in front, the other knee down behind, arms held forward together.
-- Body drops about 1.2 studs. (Planted foot: thigh + knee + foot = 0 keeps it flat on the floor.)
local function crouchBase(breath)
	return {
		LowerTorso = { x = 0, py = -1.2 + breath * 0.03 },
		UpperTorso = j(-20 + breath * 2), Head = j(20 - breath * 2),
		RightUpperLeg = j(85), RightLowerLeg = j(-105), RightFoot = j(20),   -- foot planted in front
		LeftUpperLeg = j(-5), LeftLowerLeg = j(-95), LeftFoot = j(40),       -- knee down behind
		RightUpperArm = j(35 + breath * 3, 0, -8), RightLowerArm = j(55 - breath * 3, 0, -10),
		LeftUpperArm = j(35 + breath * 3, 0, 8), LeftLowerArm = j(55 - breath * 3, 0, 10),
	}
end
local crouchContact = { -- right foot forward, left leg back and low
	LowerTorso = { x = 0, py = -1.2 },
	UpperTorso = j(-20, -3 * TWIST), Head = j(20, 3 * TWIST),
	RightUpperLeg = j(80), RightLowerLeg = j(-110), RightFoot = j(30),
	LeftUpperLeg = j(10), LeftLowerLeg = j(-100), LeftFoot = j(60),
	RightUpperArm = j(32, 0, -8), RightLowerArm = j(58, 0, -10),
	LeftUpperArm = j(38, 0, 8), LeftLowerArm = j(52, 0, 10),
}
local crouchPassing = { -- left leg swings forward past the right
	LowerTorso = { x = 0, py = -1.1 },
	UpperTorso = j(-20), Head = j(20),
	RightUpperLeg = j(55), RightLowerLeg = j(-115), RightFoot = j(60),
	LeftUpperLeg = j(65), LeftLowerLeg = j(-140), LeftFoot = j(75),
	RightUpperArm = j(35, 0, -8), RightLowerArm = j(55, 0, -10),
	LeftUpperArm = j(35, 0, 8), LeftLowerArm = j(55, 0, 10),
}

-- ---------------------------------------------------------------- Idle (slow breathing)
local function idlePose(breath)
	return {
		LowerTorso = { x = 0, py = breath * 0.02 },
		UpperTorso = j(-6 + breath * 2), Head = j(6 - breath * 2),
		RightUpperLeg = j(2), RightLowerLeg = j(-4), RightFoot = j(2),
		LeftUpperLeg = j(2), LeftLowerLeg = j(-4), LeftFoot = j(2),
		RightUpperArm = j(2 + breath * 2, 0, 3), RightLowerArm = j(88 - breath * 2),  -- forearms level in front,
		LeftUpperArm = j(2 + breath * 2, 0, -3), LeftLowerArm = j(88 - breath * 2),   -- drifting with the breath
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
	{ name = "Walk", priority = Enum.AnimationPriority.Movement, length = 0.9, stepping = true,
		keys = { { 0, walkContact }, { 0.225, walkPassing }, { 0.45, mirror(walkContact) },
			{ 0.675, mirror(walkPassing) }, { 0.9, walkContact } } },
	{ name = "Sprint", priority = Enum.AnimationPriority.Movement, length = 0.5, stepping = true,
		keys = { { 0, sprintContact }, { 0.125, sprintPassing }, { 0.25, mirror(sprintContact) },
			{ 0.375, mirror(sprintPassing) }, { 0.5, sprintContact } } },
	{ name = "CrouchIdle", priority = Enum.AnimationPriority.Movement, length = 3,
		keys = { { 0, crouchBase(0) }, { 1.5, crouchBase(1) }, { 3, crouchBase(0) } } },
	{ name = "CrouchWalk", priority = Enum.AnimationPriority.Movement, length = 1.2, stepping = true,
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
local function addPose(parent, name, joints, partial, direction)
	local a = joints[name]
	local pose = Instance.new("Pose")
	pose.Name = name
	if a then
		pose.CFrame = CFrame.new(0, a.py or 0, 0) * CFrame.Angles(rad(a.x or 0), rad(a.y or 0), rad(a.z or 0))
	end
	-- the root never moves; in a partial animation, joints it doesn't mention are left alone (weight 0)
	pose.Weight = (name == "HumanoidRootPart" or (partial and not a)) and 0 or 1
	pose.EasingStyle = EASING_STYLE
	pose.EasingDirection = direction or Enum.PoseEasingDirection.InOut
	pose.Parent = parent
	for _, child in ipairs(TREE[name] or {}) do
		addPose(pose, child, joints, partial, direction)
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
	rigSaves.Parent = saves
end
rigSaves.Value = workspace:FindFirstChild("Dummy")

-- older place the Animation Editor also loads from: an "AnimSaves" folder inside the rig itself
local dummy = workspace:FindFirstChild("Dummy")
local rigFolder = nil
if dummy then
	rigFolder = dummy:FindFirstChild("AnimSaves")
	if not rigFolder then
		rigFolder = Instance.new("ObjectValue")
		rigFolder.Name = "AnimSaves"
		rigFolder.Parent = dummy
	end
else
	warn("No model named Dummy in Workspace: make one with Rig Builder (R15, Block Avatar (2012)) and name it Dummy")
end
local function saveForEditor(seq)
	for _, place in { rigSaves, rigFolder } do
		local old = place and place:FindFirstChild(seq.Name)
		if old then old:Destroy() end
		if place then seq:Clone().Parent = place end
	end
end

for _, anim in ipairs(ANIMATIONS) do
	local seq = Instance.new("KeyframeSequence")
	seq.Name = anim.name
	seq.Loop = true
	seq.Priority = anim.priority
	for i, key in ipairs(anim.keys) do
		local kf = Instance.new("Keyframe")
		kf.Time = key[1]
		-- Smooth steps: in a stepping loop the body slows down only at the ends of each stride (the odd keys)
		-- and keeps moving through the middle (the even keys), like a pendulum, instead of pausing at every key.
		local direction = nil
		if anim.stepping then
			direction = (i % 2 == 1) and Enum.PoseEasingDirection.In or Enum.PoseEasingDirection.Out
		end
		addPose(kf, "HumanoidRootPart", key[2], anim.partial, direction)
		kf.Parent = seq
	end
	seq.Parent = folder

	saveForEditor(seq)
end

print("[MakeMovementAnimations] created " .. #ANIMATIONS .. " animations in ServerStorage.MovementAnimations")
