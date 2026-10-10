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
--   * The lantern ALWAYS hangs from the belt at your LEFT hip (on or off). Switching it on or off plays
--     LanternToggle once: you reach down to your left side and turn the knob, then your arm goes back.
--     It only moves the left arm (and a small lean/glance down), so it plays ON TOP of any movement animation.
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

-- DOORS-style arms (from Alexander's frame-by-frame screenshots and notes):
--   * the arms hang slightly OUT from the body;
--   * the SHOULDER swings back and forth (t: -1 = back, 1 = front);
--   * the ELBOW lifts the forearm as the arm swings FORWARD, so at the front the forearm points almost
--     straight ahead (nearly level); then the hand LOWERS SLOWLY over the whole back-swing, so it is
--     never thrown down, and starts lifting again late in the forward swing.
-- e: 0 = elbow nearly straight (arm pointing down), 1 = forearm level (hand flat forward).
local ARM_BACK  = { up = -10, out = 6, elbow = 5, curve = 0 }
local ARM_FRONT = { up = 14,  out = 9, elbow = 80, curve = 8 }
local function arms(rightT, leftT, rightE, leftE, size)
	-- size: 1 = walk; bigger for sprint. ARM_SWING scales the shoulder swing around the middle.
	local out = {}
	for side, t in { Right = rightT, Left = leftT } do
		local e = side == "Right" and rightE or leftE
		local sgn = side == "Right" and 1 or -1 -- z sign that points this arm OUTWARD
		local u = 0.5 + (t / 2) * ARM_SWING     -- shoulder: 0 = back, 1 = front
		local function mix(key, f) return ARM_BACK[key] + (ARM_FRONT[key] - ARM_BACK[key]) * f end
		out[side .. "UpperArm"] = j(mix("up", u) * size, 0, sgn * mix("out", e))
		out[side .. "LowerArm"] = j(mix("elbow", e), 0, -sgn * mix("curve", e))
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
}, arms(-1, 1, 0.15, 1, 1)) -- right leg forward = right arm back, hanging; left arm at the front, forearm raised almost level
local walkPassing = { -- left leg swings past
	LowerTorso = { x = 0, py = 0.04 },
	UpperTorso = j(-4), Head = j(4),
	RightUpperLeg = j(2), RightLowerLeg = j(-5), RightFoot = j(3),
	LeftUpperLeg = j(15), LeftLowerLeg = j(-55), LeftFoot = j(25),
}
with(walkPassing, arms(0, 0, 0.35, 0.65, 1)) -- right arm coming forward, starting to lift; left arm going back, lowering slowly

-- ---------------------------------------------------------------- Sprint
local sprintContact = with({
	LowerTorso = { x = 0, py = -0.2 },
	UpperTorso = j(-7, -6 * TWIST), Head = j(7, 6 * TWIST),
	RightUpperLeg = j(50), RightLowerLeg = j(-20), RightFoot = j(-5),
	LeftUpperLeg = j(-35), LeftLowerLeg = j(-50), LeftFoot = j(30),
}, arms(-1, 1, 0.15, 1, 1.6))
local sprintPassing = {
	LowerTorso = { x = 0, py = 0.15 },
	UpperTorso = j(-7), Head = j(7),
	RightUpperLeg = j(0), RightLowerLeg = j(-10), RightFoot = j(5),
	LeftUpperLeg = j(30), LeftLowerLeg = j(-100), LeftFoot = j(30),
}
with(sprintPassing, arms(0, 0, 0.35, 0.65, 1.6))

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
		RightUpperArm = j(breath * 1.5, 0, 3), RightLowerArm = j(6 + breath * 2),  -- hands hanging by your sides,
		LeftUpperArm = j(breath * 1.5, 0, -3), LeftLowerArm = j(6 + breath * 2),   -- the gentlest swing with the breath
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

-- ---------------------------------------------------------------- Lantern switch (left arm, plays once)
-- The lantern hangs at the left hip. Reach down to it, turn the knob, let go.
-- (Left arm: negative z moves it OUT from the body. Hand: y turns the wrist like turning a knob.)
local lanternRest = { LeftUpperArm = j(0, 0, -6), LeftLowerArm = j(10) }
local lanternReach = {
	UpperTorso = j(-8, 10, 0), Head = j(-20, 10, 0),
	LeftUpperArm = j(-8, 0, -14), LeftLowerArm = j(30), LeftHand = j(-20, 0, 0),
}
local lanternTurn = {
	UpperTorso = j(-8, 10, 0), Head = j(-20, 10, 0),
	LeftUpperArm = j(-8, 0, -14), LeftLowerArm = j(30), LeftHand = j(-20, 60, 0),
}

-- Each animation: length in seconds, keyframes as { time, joints }, priority, and whether it only moves
-- some joints (partial = the other joints are left to whatever else is playing).
-- SMOOTH LOOPS: for walking/running, instead of 4 poses with easing between them (which made the arms
-- "bounce" from pose to pose), we draw one smooth curve through the 4 poses and cut it into many small
-- in-between poses, so every joint MOVES continuously - like a pendulum, never snapping or pausing.
local SMOOTH_SAMPLES = 24 -- in-between poses per loop (more = smoother)

local function catmull(p0, p1, p2, p3, u)
	local u2, u3 = u * u, u * u * u
	return 0.5 * ((2 * p1) + (-p0 + p2) * u + (2 * p0 - 5 * p1 + 4 * p2 - p3) * u2 + (-p0 + 3 * p1 - 3 * p2 + p3) * u3)
end

-- keys: { {time, joints}, ... } with the last key repeating the first (a loop)
local function smoothLoop(keys, length)
	local points = {}
	for i = 1, #keys - 1 do points[i] = keys[i] end
	local n = #points
	local names = {}
	for _, key in ipairs(points) do
		for name in pairs(key[2]) do names[name] = true end
	end
	local function value(k, name, field)
		local a = points[((k - 1) % n) + 1][2][name]
		return a and (a[field] or 0) or 0
	end
	local result = {}
	for step = 0, SMOOTH_SAMPLES - 1 do
		local t = length * step / SMOOTH_SAMPLES
		local k = n
		for i = 1, n do
			local nextTime = (i < n) and points[i + 1][1] or length
			if t >= points[i][1] and t < nextTime then k = i break end
		end
		local startTime = points[k][1]
		local endTime = (k < n) and points[k + 1][1] or length
		local u = (t - startTime) / (endTime - startTime)
		local joints = {}
		for name in pairs(names) do
			local a = {}
			for _, field in ipairs({ "x", "y", "z", "py" }) do
				a[field] = catmull(value(k - 1, name, field), value(k, name, field),
					value(k + 1, name, field), value(k + 2, name, field), u)
			end
			joints[name] = a
		end
		table.insert(result, { t, joints })
	end
	table.insert(result, { length, result[1][2] })
	return result
end

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
	-- plays ONCE (not a loop); marker "Switch" = the moment the knob turns (when the light should change)
	{ name = "LanternToggle", priority = Enum.AnimationPriority.Action, length = 0.9, partial = true, once = true,
		keys = { { 0, lanternRest }, { 0.3, lanternReach }, { 0.45, lanternTurn }, { 0.6, lanternTurn },
			{ 0.9, lanternRest } },
		markers = { { 0.45, "Switch" } } },
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
	if direction == "linear" then
		pose.EasingStyle = Enum.PoseEasingStyle.Linear
		pose.EasingDirection = Enum.PoseEasingDirection.InOut
	else
		pose.EasingStyle = EASING_STYLE
		pose.EasingDirection = direction or Enum.PoseEasingDirection.InOut
	end
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
	seq.Loop = not anim.once
	seq.Priority = anim.priority
	local keys = anim.stepping and smoothLoop(anim.keys, anim.length) or anim.keys
	for _, key in ipairs(keys) do
		local kf = Instance.new("Keyframe")
		kf.Time = key[1]
		-- the smooth loops are already full of in-between poses, so they just go straight from one to the next
		addPose(kf, "HumanoidRootPart", key[2], anim.partial, anim.stepping and "linear" or nil)
		kf.Parent = seq
	end
	for _, m in ipairs(anim.markers or {}) do
		-- a marker sits on its own empty keyframe, so it doesn't change the motion
		local kf = Instance.new("Keyframe")
		kf.Time = m[1]
		local marker = Instance.new("KeyframeMarker")
		marker.Name = m[2]
		kf:AddMarker(marker)
		kf.Parent = seq
	end
	seq.Parent = folder

	saveForEditor(seq)
end

-- 3) Drafts the game can play straight away when you press Play in Studio (no publishing needed while
-- you're tweaking): a copy in ReplicatedStorage, where the player's own scripts can reach it.
local drafts = game:GetService("ReplicatedStorage"):FindFirstChild("MovementAnimationDrafts")
if drafts then drafts:Destroy() end
drafts = folder:Clone()
drafts.Name = "MovementAnimationDrafts"
drafts.Parent = game:GetService("ReplicatedStorage")

print("[MakeMovementAnimations] created " .. #ANIMATIONS .. " animations in ServerStorage.MovementAnimations"
	.. " (+ drafts in ReplicatedStorage for testing in Studio)")
