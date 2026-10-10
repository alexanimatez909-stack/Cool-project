-- MakeStabAnimation: builds the Cutthroat's knife stab as a KeyframeSequence.
-- Paste the whole file into Studio's Command Bar (View > Command Bar) and press Enter.
-- It creates ServerStorage.CutthroatStab, plus a copy the Animation Editor can load for a rig named "Dummy".
-- Then open it in the Animation Editor to tweak, and publish it to get its animation ID.
--
-- Decided with Alexander: the knife is drawn from the BACK (under the coat), then a quick FORWARD THRUST.
-- Timeline (about 1 second):
--   0.00 rest
--   0.15 right hand reaches behind the back          (marker "KnifeOut" at 0.20: show the knife in the hand)
--   0.30 knife drawn, arm pulled back at the side
--   0.42 thrust forward                              (marker "Hit" at 0.42: the victim goes down here)
--   0.55 hold
--   0.75 hand back behind the back                   (marker "KnifeAway" at 0.80: hide the knife)
--   0.95 rest
-- Angles are a first guess: adjust them in the Animation Editor until it looks right.

local ServerStorage = game:GetService("ServerStorage")

local rad = math.rad
local function rot(x, y, z)
	return CFrame.Angles(rad(x or 0), rad(y or 0), rad(z or 0))
end

-- Each pose: joint rotations in degrees. Missing joints stay at rest.
-- (Positive X on an arm swings it forward; negative swings it back. Positive Y on the waist turns left.)
local POSES = {
	{ time = 0.00, joints = {} },
	{ time = 0.15, joints = { -- reach behind the back
		UpperTorso    = rot(0, -20, 0),
		RightUpperArm = rot(-45, 0, -15),
		RightLowerArm = rot(80, 0, 0),
		RightHand     = rot(0, 0, 0),
		Head          = rot(0, 15, 0),
	}},
	{ time = 0.30, joints = { -- knife drawn, arm cocked back at the side
		UpperTorso    = rot(0, -25, 0),
		RightUpperArm = rot(-20, 0, -10),
		RightLowerArm = rot(100, 0, 0),
		RightHand     = rot(-20, 0, 0),
		LeftUpperArm  = rot(20, 0, 0),
		Head          = rot(0, 20, 0),
	}},
	{ time = 0.42, joints = { -- thrust forward
		UpperTorso    = rot(-10, 25, 0),
		RightUpperArm = rot(80, 0, 0),
		RightLowerArm = rot(10, 0, 0),
		RightHand     = rot(-10, 0, 0),
		LeftUpperArm  = rot(45, 0, 10),
		LeftLowerArm  = rot(40, 0, 0),
		Head          = rot(5, -20, 0),
	}, style = Enum.PoseEasingStyle.Linear },
	{ time = 0.55, joints = { -- hold the stab for a moment
		UpperTorso    = rot(-10, 25, 0),
		RightUpperArm = rot(75, 0, 0),
		RightLowerArm = rot(15, 0, 0),
		RightHand     = rot(-10, 0, 0),
		LeftUpperArm  = rot(40, 0, 10),
		LeftLowerArm  = rot(40, 0, 0),
		Head          = rot(5, -20, 0),
	}},
	{ time = 0.75, joints = { -- put the knife away behind the back
		UpperTorso    = rot(0, -15, 0),
		RightUpperArm = rot(-45, 0, -15),
		RightLowerArm = rot(80, 0, 0),
		Head          = rot(0, 10, 0),
	}},
	{ time = 0.95, joints = {} },
}

local MARKERS = {
	{ time = 0.20, name = "KnifeOut" },
	{ time = 0.42, name = "Hit" },
	{ time = 0.80, name = "KnifeAway" },
}

-- The R15 joint tree: each part's pose sits inside its parent's pose.
local TREE = {
	HumanoidRootPart = { "LowerTorso" },
	LowerTorso = { "UpperTorso", "LeftUpperLeg", "RightUpperLeg" },
	UpperTorso = { "Head", "LeftUpperArm", "RightUpperArm" },
	LeftUpperArm = { "LeftLowerArm" },
	LeftLowerArm = { "LeftHand" },
	RightUpperArm = { "RightLowerArm" },
	RightLowerArm = { "RightHand" },
}

local function addPose(parent, name, joints, style)
	local pose = Instance.new("Pose")
	pose.Name = name
	pose.CFrame = joints[name] or CFrame.new()
	pose.Weight = 1
	pose.EasingStyle = style or Enum.PoseEasingStyle.Cubic
	pose.EasingDirection = Enum.PoseEasingDirection.Out
	pose.Parent = parent
	for _, child in ipairs(TREE[name] or {}) do
		addPose(pose, child, joints, style)
	end
end

local seq = Instance.new("KeyframeSequence")
seq.Name = "CutthroatStab"
seq.Loop = false
seq.Priority = Enum.AnimationPriority.Action

for _, p in ipairs(POSES) do
	local kf = Instance.new("Keyframe")
	kf.Time = p.time
	addPose(kf, "HumanoidRootPart", p.joints, p.style)
	kf.Parent = seq
end

for _, m in ipairs(MARKERS) do
	-- markers sit on their own keyframe at that exact time (no poses, so it doesn't change the motion)
	local kf = Instance.new("Keyframe")
	kf.Time = m.time
	local marker = Instance.new("KeyframeMarker")
	marker.Name = m.name
	kf:AddMarker(marker)
	kf.Parent = seq
end

-- 1) A plain copy in ServerStorage (right-click it > "Save to Roblox" to publish straight away).
local old = ServerStorage:FindFirstChild("CutthroatStab")
if old then old:Destroy() end
seq.Parent = ServerStorage

-- 2) A copy where the Animation Editor looks for saved animations of a rig named "Dummy".
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
local oldSave = rigSaves:FindFirstChild("CutthroatStab")
if oldSave then oldSave:Destroy() end
seq:Clone().Parent = rigSaves

print("[MakeStabAnimation] CutthroatStab created in ServerStorage (" .. #POSES .. " poses, markers: KnifeOut, Hit, KnifeAway)")
