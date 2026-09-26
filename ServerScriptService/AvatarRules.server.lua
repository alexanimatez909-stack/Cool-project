-- AvatarRules (Script in ServerScriptService)
-- Makes every player's avatar the same size and gives everyone the same animations
-- (Config.AVATAR_ANIMATIONS), whatever animation pack or body they own. Fair hiding (no tiny avatars) and the same
-- first-person camera height for everyone. The rules are in ReplicatedStorage.Config.
-- Runs on the server because only the server can change what an avatar looks like for everyone.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function onPlayer(player)
	player.CharacterAppearanceLoaded:Connect(applyRules)
end
Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do -- anyone who joined before this script started
	onPlayer(player)
	if player.Character and player:HasAppearanceLoaded() then
		task.spawn(applyRules, player.Character)
	end
end
