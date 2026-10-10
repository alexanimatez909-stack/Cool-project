-- MakeStabAnimation: builds the Cutthroat's knife stab as a KeyframeSequence.
-- Paste the whole file into Studio's Command Bar (View > Command Bar) and press Enter.
-- It creates ServerStorage.CutthroatStab, plus a copy the Animation Editor can load for a rig named "Dummy".
-- Then open it in the Animation Editor to tweak, and publish it to get its animation ID.
--
-- Decided with Alexander: about 2.5 seconds and it must look good (custom kill animations could be sold later).
-- The knife is drawn from the BACK (he turns his head and looks over his shoulder as if reaching for it; the
-- first-person camera follows the head), then a FORWARD THRUST, the knife is pulled out (now with a little blood,
-- not graphic) and put back behind the coat.
-- Timeline:
--   0.00 rest
--   0.35 looks over his right shoulder, hand reaches behind the back
--   0.60 hand under the coat                       (marker "KnifeOut" at 0.65: show the knife in the hand)
--   0.95 knife drawn, head turns back to the target
--   1.15 wind-up
--   1.30 thrust forward                             (marker "Hit" at 1.30: the victim goes down here)
--   1.60 hold, small push
--   1.80 pull the knife out                         (marker "Bloody" at 1.80: show the blood on the blade)
--   2.05 glance down at the knife
--   2.30 hand back behind the back                  (marker "KnifeAway" at 2.35: hide the knife)
--   2.50 rest
-- Angles are a first guess: adjust them in the Animation Editor until it looks right.
-- Each keyframe's easing controls the movement FROM it to the next keyframe.

local ServerStorage = game:GetService("ServerStorage")

local rad = math.rad
local function rot(x, y, z)
	return CFrame.Angles(rad(x or 0), rad(y or 0), rad(z or 0))
end

local Style, Dir = Enum.PoseEasingStyle, Enum.PoseEasingDirection

-- Each pose: joint rotations in degrees. Missing joints stay at rest.
-- (Arms: positive X swings forward, negative back. Waist/Head: positive Y turns left, negative right;
--  Head: negative X looks down.)
local POSES = {
	{ time = 0.00, joints = {} },
	{ time = 0.35, joints = { -- look over the right shoulder, reach behind the back
		UpperTorso    = rot(0, -35, 0),
		Head          = rot(-25, -45, 0),
		RightUpperArm = rot(-50, 0, -20),
		RightLowerArm = rot(90, 0, 0),
		LeftUpperArm  = rot(10, 0, 0),
	}},
	{ time = 0.60, joints = { -- hand under the coat, still looking
		UpperTorso    = rot(0, -40, 0),
		Head          = rot(-30, -50, 0),
		RightUpperArm = rot(-55, 0, -15),
		RightLowerArm = rot(95, 0, 0),
		RightHand     = rot(-15, 0, 0),
		LeftUpperArm  = rot(10, 0, 0),
	}},
	{ time = 0.95, joints = { -- knife drawn, eyes back on the target
		UpperTorso    = rot(0, -25, 0),
		Head          = rot(0, 20, 0),
		RightUpperArm = rot(-25, 0, -10),
		RightLowerArm = rot(105, 0, 0),
		RightHand     = rot(-20, 0, 0),
		LeftUpperArm  = rot(20, 0, 0),
	}},
	{ time = 1.15, joints = { -- wind-up, then speed into the stab
		UpperTorso    = rot(5, -30, 0),
		Head          = rot(0, 25, 0),
		RightUpperArm = rot(-30, 0, -10),
		RightLowerArm = rot(110, 0, 0),
		RightHand     = rot(-20, 0, 0),
		LeftUpperArm  = rot(30, 0, 5),
	}, style = Style.Quad, dir = Dir.In },
	{ time = 1.30, joints = { -- thrust forward, left hand grabs
		UpperTorso    = rot(-12, 25, 0),
		Head          = rot(5, -20, 0),
		RightUpperArm = rot(80, 0, 0),
		RightLowerArm = rot(10, 0, 0),
		RightHand     = rot(-10, 0, 0),
		LeftUpperArm  = rot(50, 0, 10),
		LeftLowerArm  = rot(40, 0, 0),
	}},
	{ time = 1.60, joints = { -- hold, small push
		UpperTorso    = rot(-15, 28, 0),
		Head          = rot(5, -22, 0),
		RightUpperArm = rot(85, 0, 0),
		RightLowerArm = rot(5, 0, 0),
		RightHand     = rot(-10, 0, 0),
		LeftUpperArm  = rot(50, 0, 10),
		LeftLowerArm  = rot(40, 0, 0),
	}, style = Style.Quad, dir = Dir.Out },
	{ time = 1.80, joints = { -- pull the knife out
		UpperTorso    = rot(-5, 0, 0),
		Head          = rot(0, 0, 0),
		RightUpperArm = rot(30, 0, 0),
		RightLowerArm = rot(70, 0, 0),
		RightHand     = rot(-10, 0, 0),
		LeftUpperArm  = rot(15, 0, 0),
	}},
	{ time = 2.05, joints = { -- glance down at the knife
		UpperTorso    = rot(-5, -10, 0),
		Head          = rot(-25, -10, 0),
		RightUpperArm = rot(40, 0, 0),
		RightLowerArm = rot(110, 0, 0),
		RightHand     = rot(0, 0, 0),
	}},
	{ time = 2.30, joints = { -- put it back behind the coat
		UpperTorso    = rot(0, -25, 0),
		Head          = rot(-10, -30, 0),
		RightUpperArm = rot(-50, 0, -20),
		RightLowerArm = rot(90, 0, 0),
	}},
	{ time = 2.50, joints = {} },
}

local MARKERS = {
	{ time = 0.65, name = "KnifeOut" },
	{ time = 1.30, name = "Hit" },
	{ time = 1.80, name = "Bloody" },
	{ time = 2.35, name = "KnifeAway" },
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

local function addPose(parent, name, joints, style, dir)
	local pose = Instance.new("Pose")
	pose.Name = name
	pose.CFrame = joints[name] or CFrame.new()
	pose.Weight = 1
	pose.EasingStyle = style or Style.Cubic
	pose.EasingDirection = dir or Dir.InOut
	pose.Parent = parent
	for _, child in ipairs(TREE[name] or {}) do
		addPose(pose, child, joints, style, dir)
	end
end

local seq = Instance.new("KeyframeSequence")
seq.Name = "CutthroatStab"
seq.Loop = false
seq.Priority = Enum.AnimationPriority.Action2 -- above LanternToggle (Action), so the stab wins

for _, p in ipairs(POSES) do
	local kf = Instance.new("Keyframe")
	kf.Time = p.time
	addPose(kf, "HumanoidRootPart", p.joints, p.style, p.dir)
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
saveForEditor(seq)

print("[MakeStabAnimation] CutthroatStab created in ServerStorage (" .. #POSES .. " poses, markers: KnifeOut, Hit, Bloody, KnifeAway)")
