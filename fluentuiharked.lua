--[====================================================================================================[

██╗  ██╗ █████╗ ██████╗ ██╗  ██╗███████╗██████╗     ██╗   ██╗██████╗ 
██║  ██║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝██╔══██╗    ██║   ██║╚════██╗
███████║███████║██████╔╝█████╔╝ █████╗  ██║  ██║    ██║   ██║ █████╔╝
██╔══██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝  ██║  ██║    ╚██╗ ██╔╝██╔═══╝ 
██║  ██║██║  ██║██║  ██║██║  ██╗███████╗██████╔╝     ╚████╔╝ ███████╗
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝       ╚═══╝  ╚══════╝

Credits to C:\Drive
]====================================================================================================]--


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
		if LocalPlayer:FindFirstChild("deletebind") then
			LocalPlayer.deletebind:Fire(item)
		else
			HookedRM:FireServer(item)
		end
	end)
end

local function notify(title, text, duration)
   game:GetService("StarterGui"):SetCore("SendNotification",{
Title = title,
Text = text,
Duration = duration,
})
end

local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()

local Window = Fluent:CreateWindow({
    Title = "Harked V2",
    SubTitle = "by sudoersalt",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.P -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "menu" }),
	Misc = Window:AddTab({ Title = "Misc", Icon = "code" })
}

 local Input = Tabs.Main:AddInput("Input", {
        Title = "Input",
        Default = "",
        Placeholder = "Input Players Name",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            target = Value
        end
    })    

    Tabs.Main:AddButton({
        Title = "bald",
        Description = "",
        Callback = function()
            local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v].Character:GetChildren()) do
			if v:IsA("Accessory") then
				delete(v)
			end
		end
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "ragdoll",
        Description = "",
        Callback = function()
          local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Humanoid"))
	end  
        end
    })

    Tabs.Main:AddButton({
        Title = "kill",
        Description = "",
        Callback = function()
          local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character.Torso.Neck)
		else
			delete(Players[v].Character.Head.Neck)
		end
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "naked",
        Description = "",
        Callback = function()
          local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Pants"))
		delete(Players[v].Character:FindFirstChildOfClass("Shirt"))
		delete(Players[v].Character:FindFirstChildOfClass("ShirtGraphic"))
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "goto",
        Description = "",
        Callback = function()
          local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character ~= nil then
			if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').SeatPart then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Sit = false
				wait(.1)
			end
			getRoot(Players.LocalPlayer.Character).CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(3,1,0)
		end
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "rtools",
        Description = "",
        Callback = function()
          local players = getPlayer(target)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v]:FindFirstChildOfClass("Backpack"):GetChildren()) do
			delete(v)
		end
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "box",
        Description = "",
        Callback = function()
          local players = getPlayer(target, Players.LocalPlayer)
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
        end
    })



local slockk = false
local banned = {}

Players.PlayerAdded:connect(function(plr)
	if slockk then
		delete(plr)
	end
	if table.find(banned, plr) then
		delete(plr)
	end
end)
    
Tabs.Main:AddButton({
        Title = "ban",
        Description = "",
        Callback = function()
          local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		table.insert(banned, Players[v].UserId)
		delete(Players[v])
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "slock",
        Description = "",
        Callback = function()
          if slockk then 
		notify("SLOCK", "SLOCK: false", 5)
		slockk = false
	else
		notify("SLOCK", "SLOCK: true", 5)
		slockk = true
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "kick",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v])
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "blockhead",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character.Head:FindFirstChildOfClass("SpecialMesh"))
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "stools",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Humanoid"))
		repeat wait() until Players[v].Character:FindFirstChildOfClass("Humanoid").Parent == nil
		for _, v in ipairs(Players[v].Character:GetChildren()) do
			if v:IsA("BackpackItem") and v:FindFirstChild("Handle") then
				Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(v)
			end
		end
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "noface",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character.Head:FindFirstChildOfClass("Decal"))
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "punish",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character)
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "pantsless",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Pants"))
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "shirtless",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Shirt"))
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "tshirtless",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("ShirtGraphic"))
	end
        end
    })

    Tabs.Main:AddButton({
        Title = "noregen",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChild("Health"))
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "stopanim",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		delete(Players[v].Character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator"))
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "blockchar",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		for i, v in pairs(Players[v].Character:GetChildren()) do
			if v:IsA("CharacterMesh") then
				delete(v)
			end
		end
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "nolimbs",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
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
        end
    })

	Tabs.Main:AddButton({
        Title = "nola",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Left Arm"])
		else
			delete(Players[v].Character["LeftUpperArm"])
		end
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "noll",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Left Leg"])
		else
			delete(Players[v].Character["LeftUpperLeg"])
		end
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "nora",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Right Arm"])
		else
			delete(Players[v].Character["RightUpperArm"])
		end
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "norl",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			delete(Players[v].Character["Right Leg"])
		else
			delete(Players[v].Character["RightUpperLeg"])
		end
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "nowaist",
        Description = "R15 only",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
			delete(Players[v].Character.UpperTorso.Waist)
		end
	end
        end
    })

	Tabs.Main:AddButton({
        Title = "noroot",
        Description = "",
        Callback = function()
         local players = getPlayer(target, Players.LocalPlayer)
	for i, v in pairs(players) do
		if Players[v].Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
			delete(Players[v].Character.LowerTorso.Root)
		end
	end
        end
    })

	Tabs.Misc:AddButton({
        Title = "IY",
        Description = "",
        Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end
    })

	Tabs.Misc:AddButton({
        Title = "Dex",
        Description = "",
        Callback = function()
         pcall(loadstring(game:HttpGet("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua"))())
        end
    })

	local selectionbox = Instance.new("SelectionBox", workspace)
local equipped = false
local oldmouse = mouse.Icon
local destroytool = Instance.new("Tool", Players.LocalPlayer:FindFirstChildOfClass("Backpack"))
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
	local destroytool = Instance.new("Tool", Players.LocalPlayer:FindFirstChildOfClass("Backpack"))
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

local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if isMobile then
local TweenService = game:GetService("TweenService")
	local UIBUTTON = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local ImageButton = Instance.new("ImageButton")
	local UICorner = Instance.new("UICorner")
	local UICorner_2 = Instance.new("UICorner")

	UIBUTTON.Name = "UIBUTTON"
	UIBUTTON.Parent = game.CoreGui
	UIBUTTON.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Frame.Parent = UIBUTTON
	Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Transparency = 1
	Frame.Position = UDim2.new(0.157012194, 0, 0.164366379, 0)
	Frame.Size = UDim2.new(0, 115, 0, 49)

ImageButton.Parent = Frame
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Active = true
ImageButton.Draggable = true
ImageButton.Position = UDim2.new(0.218742043, 0, -0.155235752, 0)
ImageButton.Size = UDim2.new(0, 64, 0, 64)

-- Set initial image to "open"
ImageButton.Image = "rbxassetid://121633059385797" -- Open image asset ID
local isOpen = true -- Variable to track the state

ImageButton.MouseButton1Click:Connect(function()
    -- Animate the button size
    ImageButton:TweenSize(UDim2.new(0, 60, 0, 60), Enum.EasingDirection.In, Enum.EasingStyle.Elastic, 0.1)
    delay(0.1, function()
        ImageButton:TweenSize(UDim2.new(0, 64, 0, 64), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.1)
    end)

    -- Toggle the image based on the state
    if isOpen then
        ImageButton.Image = "rbxassetid://121633059385797" -- Replace with close image asset ID
    else
        ImageButton.Image = "rbxassetid://121633059385797" -- Open image asset ID
    end
    isOpen = not isOpen -- Toggle the state

    -- Simulate key presses
    local VirtualInputManager = game:GetService("VirtualInputManager")
   VirtualInputManager:SendKeyEvent(true,"P",false,game)
end)
end

Window:SelectTab(1)