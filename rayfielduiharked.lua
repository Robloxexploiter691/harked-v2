local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HookedRemote = LocalPlayer.PlayerGui:WaitForChild("HarkedHookedRM", 5)
local HookedRM = HookedRemote.Value

local target = ""
function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end
function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end
function getRoot(char)
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end
local WTS = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end
local mouse = Players.LocalPlayer:GetMouse()
local MousePositionToVector2 = function()
	return Vector2.new(mouse.X, mouse.Y)
end
local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WTS(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end
local SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot(speakerChar).Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot(speakerChar) then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot(speakerChar).Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
}
function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end
function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
	local nameList = splitString(list,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end

local function delete(item)
	pcall(function()
		LocalPlayer.deletebind:Fire(item) or HookedRM:FireServer(item) -- if the delete bind was deleted
	end)
end

local function notify(title, text, duration)
   game:GetService("StarterGui"):SetCore("SendNotification",{
Title = title,
Text = text,
Duration = duration,
})
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Harked V2",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Harked V2",
    LoadingSubtitle = "by sudoersalt",
    Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })

 local Tab = Window:CreateTab("Main", "menu") -- Title, Image

local Input = Tab:CreateInput({
   Name = "Input Example",
   CurrentValue = "",
   PlaceholderText = "Input Placeholder",
   RemoveTextAfterFocusLost = false,
   Flag = "Input1",
   Callback = function(Text)
   target = Text
   end,
})

local Button = Tab:CreateButton({
   Name = "bald",
   Callback = function()
   local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v].Character:GetChildren()) do
			if v:IsA("Accessory") then
				delete(v)
			end
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "ragdoll",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Humanoid"))
	end  
   end,
})

local Button = Tab:CreateButton({
   Name = "kill",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character.Torso.Neck)
		else
			delete(Players[v].Character.Head.Neck)
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "naked",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Pants"))
		delete(Players[v].Character:FindFirstChildOfClass("Shirt"))
		delete(Players[v].Character:FindFirstChildOfClass("ShirtGraphic"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "goto",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character ~= nil then
			if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "rtools",
   Callback = function()
    local players = getPlayer(target)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
			delete(v)
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "box",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v].Character:GetChildren()) do
			if v:IsA("Accessory") then
				delete(v)
			end
		end
		for i, v in pairs(Players[v].Character:GetChildren()) do
			if v:IsA("CharacterMesh") then
				delete(v)
			end
		end
		delete(Players[v].Character:FindFirstChildOfClass("Pants"))
		delete(Players[v].Character:FindFirstChildOfClass("Shirt"))
		delete(Players[v].Character:FindFirstChildOfClass("ShirtGraphic"))
		delete(Players[v].Character["Left Arm"])
		delete(Players[v].Character["Left Leg"])
		delete(Players[v].Character["Right Arm"])
		delete(Players[v].Character["Right Leg"])
		delete(Players[v].Character.Head:FindFirstChildOfClass("SpecialMesh"))
		delete(Players[v].Character.Head:FindFirstChildOfClass("Decal"))
	end
   end,
})

function FindInTable(tbl,val)
	if tbl == nil then return false end
	for _,v in pairs(tbl) do
		if v == val then return true end
	end 
	return false
end

local slockk = false
local banned = {}

Players.PlayerAdded:connect(function(plr)
	if slockk then
		delete(plr)
	end
	if FindInTable(banned, plr.UserId) then
		delete(plr)
	end
end)

local Button = Tab:CreateButton({
   Name = "ban",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		table.insert(banned, Players[v].UserId)
		delete(Players[v])
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "slock",
   Callback = function()
    if slockk then 
		notify("SLOCK", "SLOCK: false", 5)
		slockk = false
	else
		notify("SLOCK", "SLOCK: true", 5)
		slockk = true
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "kick",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v])
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "blockhead",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		Destroy(Players[v].Character.Head:FindFirstChildOfClass("SpecialMesh"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "stools",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Humanoid"))
		repeat wait() until Players[v].Character:FindFirstChildOfClass("Humanoid").Parent == nil
		for _, v in ipairs(Players[v].Character:GetChildren()) do
			if v:IsA("BackpackItem") and v:FindFirstChild("Handle") then
				Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(v)
			end
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "noface",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character.Head:FindFirstChildOfClass("Decal"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "punish",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character)
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "pantsless",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Pants"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "shirtless",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Shirt"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "tshirtless",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("ShirtGraphic"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "noregen",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChild("Health"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "stopanim",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"))
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "blockchar",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v].Character:GetChildren()) do
			if v:IsA("CharacterMesh") then
				delete(v)
			end
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "nolimbs",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Left Arm"])
			delete(Players[v].Character["Left Leg"])
			delete(Players[v].Character["Right Arm"])
			delete(Players[v].Character["Right Leg"])
		else
			delete(Players[v].Character["LeftUpperArm"])
			delete(Players[v].Character["LeftUpperLeg"])
			delete(Players[v].Character["RightUpperArm"])
			delete(Players[v].Character["RightUpperLeg"])
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "nola",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Left Arm"])
		else
			delete(Players[v].Character["LeftUpperArm"])
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "noll",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Left Leg"])
		else
			delete(Players[v].Character["LeftUpperLeg"])
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "nora",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Right Arm"])
		else
			delete(Players[v].Character["RightUpperArm"])
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "norl",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Right Leg"])
		else
			delete(Players[v].Character["RightUpperLeg"])
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "nowaist",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
			delete(Players[v].Character.UpperTorso.Waist)
		end
	end
   end,
})

local Button = Tab:CreateButton({
   Name = "noroot",
   Callback = function()
    local players = getPlayer(target, LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
			delete(Players[v].Character.LowerTorso.Root)
		end
	end
   end,
})

local CTab = Window:CreateTab("Misc", "code") 

local Button = CTab:CreateButton({
   Name = "Infinite Yield",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
   end,
})

local Button = CTab:CreateButton({
   Name = "Dex",
   Callback = function()
   pcall(loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))())
   end,
})


local selectionbox = Instance.new("SelectionBox", workspace)
local equipped = false
local oldmouse = mouse.Icon
local destroytool = Instance.new("Tool", LocalPlayer:FindFirstChildOfClass("Backpack"))
destroytool.RequiresHandle = false
destroytool.Name = "Delete"
destroytool.ToolTip = "from Harked Reborn V2"
destroytool.TextureId = "http://www.roblox.com/asset/?id=12223874"
destroytool.CanBeDropped = false
destroytool.Equipped:connect(function()
	equipped = true
	mouse.Icon = "rbxasset://textures\\HammerCursor.png"
	while equipped do
		selectionbox.Adornee = mouse.Target
		wait()
	end
end)
destroytool.Unequipped:connect(function()
	equipped = false
	selectionbox.Adornee = nil
	mouse.Icon = oldmouse
	print(oldmouse)
end)
destroytool.Activated:connect(function()
	local explosion = Instance.new("Explosion", workspace)
	explosion.BlastPressure = 0
	explosion.BlastRadius = 0
	explosion.DestroyJointRadiusPercent = 0
	explosion.ExplosionType = Enum.ExplosionType.NoCraters
	explosion.Position = mouse.Target.Position
	delete(mouse.Target)
end)
game:GetService("StarterGui"):SetCoreGuiEnabled('Backpack', true)
Players.LocalPlayer.CharacterAdded:connect(function()
	local destroytool = Instance.new("Tool", LocalPlayer:FindFirstChildOfClass("Backpack"))
	destroytool.RequiresHandle = false
	destroytool.Name = "Delete"
	destroytool.ToolTip = "from Harked Reborn V2"
	destroytool.TextureId = "http://www.roblox.com/asset/?id=12223874"
	destroytool.CanBeDropped = false
	destroytool.Equipped:connect(function()
		equipped = true
		mouse.Icon = "rbxasset://textures\\HammerCursor.png"
		while equipped do
			selectionbox.Adornee = mouse.Target
			wait()
		end
	end)
	destroytool.Unequipped:connect(function()
		equipped = false
		selectionbox.Adornee = nil
		mouse.Icon = oldmouse
		print(oldmouse)
	end)
	destroytool.Activated:connect(function()
		local explosion = Instance.new("Explosion", workspace)
		explosion.BlastPressure = 0
		explosion.BlastRadius = 0
		explosion.DestroyJointRadiusPercent = 0
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Position = mouse.Target.Position
		delete(mouse.Target)
	end)
	game:GetService("StarterGui"):SetCoreGuiEnabled('Backpack', true)
end)