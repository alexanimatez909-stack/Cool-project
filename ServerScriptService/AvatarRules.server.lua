-- AvatarRules (Script in ServerScriptService)
-- If StarterPlayer has a model named StarterCharacter, everyone spawns as that body (decided: the blocky R15
-- Block Rig for now), and this script copies each player's own clothes, face and skin colour onto it
-- (Config.KEEP_PLAYER_LOOK). Their accessories and body shape are never copied.
-- Without a StarterCharacter it does the old job below:
-- Makes every player's avatar the same size and gives everyone the same animations
-- (Config.AVATAR_ANIMATIONS), whatever animation pack or body they own. Fair hiding (no tiny avatars) and the same
-- first-person camera height for everyone. The rules are in ReplicatedStorage.Config.
-- Runs on the server because only the server can change what an avatar looks like for everyone.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local BODY_PARTS = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }

local function applyRules(character)
	local humanoid = character:WaitForChild("Humanoid")
	local description = humanoid:GetAppliedDescription()

	local scale = Config.AVATAR_SCALE
	description.HeightScale = scale.Height
	description.WidthScale = scale.Width
	description.DepthScale = scale.Depth
	description.HeadScale = scale.Head
	description.BodyTypeScale = scale.BodyType
	description.ProportionScale = scale.Proportion

	-- everyone moves the same way (0 = Roblox's standard animation)
	for name, id in Config.AVATAR_ANIMATIONS do
		description[name .. "Animation"] = id
	end
	if Config.FORCE_DEFAULT_BODY_PARTS then
		for _, name in BODY_PARTS do
			description[name] = 0 -- 0 = the standard body part
		end
	end

	local ok, err = pcall(function()
		humanoid:ApplyDescription(description)
	end)
	if not ok then
		warn("[AvatarRules] Couldn't apply avatar rules: " .. tostring(err))
	end
end

-- StarterCharacter mode: build a hidden copy of the player's real avatar, then copy only the chosen bits onto
-- the StarterCharacter body and throw the copy away.
local CLOTHES = { "Shirt", "Pants", "ShirtGraphic" }
local function copyPlayerLook(player, character)
	local keep = Config.KEEP_PLAYER_LOOK
	-- test players in Studio have negative UserIds; they just keep the plain body
	local ok, description = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if not ok or not description then return end
	local ok2, avatar = pcall(function()
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if not ok2 or not avatar then
		warn("[AvatarRules] Couldn't load " .. player.Name .. "'s look: " .. tostring(avatar))
		return
	end

	if keep.Clothes then
		for _, className in CLOTHES do
			local old = character:FindFirstChildOfClass(className)
			if old then old:Destroy() end
			local item = avatar:FindFirstChildOfClass(className)
			if item then item:Clone().Parent = character end
		end
	end
	if keep.SkinColour then
		local old = character:FindFirstChildOfClass("BodyColors")
		if old then old:Destroy() end
		local colours = avatar:FindFirstChildOfClass("BodyColors")
		if colours then colours:Clone().Parent = character end
	end
	if keep.Face then
		-- classic faces are a Decal called "face" on the head (newer moving "dynamic heads" have none,
		-- so those players keep the plain face)
		local theirFace = avatar:FindFirstChild("Head") and avatar.Head:FindFirstChild("face")
		local ourFace = character:FindFirstChild("Head") and character.Head:FindFirstChild("face")
		if theirFace and theirFace:IsA("Decal") and ourFace and ourFace:IsA("Decal") then
			ourFace.Texture = theirFace.Texture
		end
	end
	avatar:Destroy()
end

local function usesStarterCharacter()
	return StarterPlayer:FindFirstChild("StarterCharacter") ~= nil
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		if usesStarterCharacter() then
			copyPlayerLook(player, character)
		end
	end)
	player.CharacterAppearanceLoaded:Connect(function(character)
		if not usesStarterCharacter() then
			applyRules(character)
		end
	end)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do -- anyone who joined before this script started
	onPlayer(player)
	if player.Character then
		if usesStarterCharacter() then
			task.spawn(copyPlayerLook, player, player.Character)
		elseif player:HasAppearanceLoaded() then
			task.spawn(applyRules, player.Character)
		end
	end
end
