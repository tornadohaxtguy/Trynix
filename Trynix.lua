loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end
    function LPH_JIT_MAX(f) return f end
    function LPH_JIT(f) return f end
    function LPH_ENCFUNC(f) return f end
]])();

eli_inext = function(t, i)
    i = i + 1;
    local v = t[i];
    if v ~= nil then return i, v end;
end;
eli_ipairs = function(t) return eli_inext, t, 0 end;
eli_pairs = function(t) return next, t, nil end;
if not cloneref then cloneref = function(ref) return ref end end

do
    if hookfunction and newcclosure and getcallingscript then
        pcall(function()
            local Old1 = nil; Old1 = hookfunction(setmetatable, newcclosure(function(Table, MetaTable)
                if type(MetaTable) == "table" and rawget(MetaTable, "__mode") == "kv" then
                    local Caller = getcallingscript();
                    if Caller and Caller.Name == "MiscellaneousController" then
                        return Old1(Table, { });
                    end;
                end;

                return Old1(Table, MetaTable);
            end));
        end);

        pcall(function()
            local Ol2 = nil; Ol2 = hookfunction(rawlen, newcclosure(function(Table)
                if type(Table) == "table" then
                    local Caller = getcallingscript();
                    if Caller and Caller.Name == "MiscellaneousController" then
                        return 3;
                    end;
                end;

                return Ol2(Table);
            end));
        end);
    end;
end;
print("-");
task.wait(1);

pcall(function()
    if not (hookfunction and newcclosure and getrenv) then return end;
    local oldtable; oldtable = hookfunction(getrenv().setmetatable, newcclosure(function(Table, Metatable)
        if Metatable and typeof(Metatable) == "table" and rawget(Metatable, "__mode") == "kv" then
            local trace = debug.traceback();
            if trace:find("MiscellaneousController") then
                return oldtable({1, 2, 3}, {});
            end;
        end;
        return oldtable(Table, Metatable);
    end));
end);

coroutine.wrap(function()
    pcall(function()
        local acWords = {"anticheat", "ac", "detection", "ban", "kick", "security", "moderation"};
        local function disableScript(obj)
            obj.Disabled = true;
        end;
        local function checkScript(obj)
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                local n = string.lower(obj.Name);
                for _, ac in eli_ipairs(acWords) do
                    if string.find(n, ac, 1, true) then
                        pcall(disableScript, obj);
                        break;
                    end;
                end;
            end;
        end;
        local function blockScript(obj)
            pcall(checkScript, obj);
        end;

        pcall(function()
            game.DescendantAdded:Connect(blockScript);
        end);

        pcall(function()
            local descendants = game:GetDescendants();
            for index = 1, #descendants do
                blockScript(descendants[index]);
                if index % 4000 == 0 then
                    task.wait();
                end;
            end;
        end);
    end);

    pcall(function()
        local networkClient = game:GetService("NetworkClient");
        if networkClient then
            networkClient.ChildAdded:Connect(function(child)
                pcall(function()
                    local ok, n = pcall(function() return child.Name:lower() end);
                    if ok and n then
                        if n:find("anticheat") or n:find("detection") then
                            pcall(function() child:Destroy() end);
                        end;
                    end;
                end);
            end);
        end;
    end);
end)();

pcall(function()
    local fake = Instance.new("RemoteEvent");
    fake.Name = "ClientAlert";
    fake.Parent = LocalPlayer;
end);

task.spawn(function()
    pcall(LPH_NO_VIRTUALIZE(function()
        if type(getgc) ~= "function" then return end;
        local rf = game:GetService("ReplicatedFirst");
        local ls3 = rf:WaitForChild("LocalScript3", 10);

        local gc = getgc(false);
        for index = 1, #gc do
            local f = gc[index];
            if type(f) == "function" and (type(islclosure) ~= "function" or islclosure(f)) then
                local ok, e = pcall(getfenv, f);
                if ok and type(e) == "table" then
                    local ok2, scr = pcall(function() return rawget(e, "script") end);
                    if ok2 and scr and typeof(scr) == "Instance" then
                        local ok3, scrStr = pcall(tostring, scr);

                        if ok3 and (scr == ls3 or (type(scrStr) == "string" and scrStr:find("LoadingScreen"))) then
                            local ok4, cs = pcall(debug.getconstants, f);
                            if ok4 and type(cs) == "table" then
                                for _, k in eli_ipairs(cs) do
                                    if type(k) == "string" and (k:find("TakeTheL") or k:find("ban") or k:find("kick")) then
                                        pcall(function()
                                            hookfunction(f, function() end);
                                        end);
                                        break;
                                    end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            if index % 1500 == 0 then
                task.wait();
            end;
        end;
    end));
end);

local antidetect = true;
local detecteds = {
    ["localscript3"] = true,
    ["miscellaneouscontroller"] = true
};
local callerVerdicts = setmetatable({}, { __mode = "k" });
local original;
pcall(function()
    if not (hookmetamethod and newcclosure and getcallingscript) then return end;
    original = hookmetamethod(game, "__index", newcclosure(LPH_NO_VIRTUALIZE(function(self, key)
        if antidetect and (key == "Name" or key == "Text") then
            local caller = getcallingscript();
            if caller then
                local blocked = callerVerdicts[caller];
                if blocked == nil then
                    local ok, result = pcall(function()
                        return detecteds[string.lower(original(caller, "Name"))] == true;
                    end);
                    blocked = ok and result or false;
                    callerVerdicts[caller] = blocked;
                end;
                if blocked then
                    return "";
                end;
            end;
        end;
        return original(self, key);
    end)));
end);
getgenv().set_antidetect = function(v)
    antidetect = v and true or false;
end;

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") -- Added TweenService

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")



-- ----------------------------------------------------
-- STATE VARIABLES & CONNECTIONS
-- ----------------------------------------------------
local isTeleported = false
local isSpinning = false
local isNoclip = false
local guiVisible = true
local isFading = false -- Prevents spamming the toggle key while animating
local isFlying = false
local flySpeed = 50
local flyConnection = nil


local originalCFrame = nil
local spinConnection = nil
local noclipConnection = nil

local SPIN_SPEED = 30

local connections = {}

-- ----------------------------------------------------
-- UI BUILD (Trynix Dark Theme)
-- ----------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StyleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create ScreenGui
screenGui.Name = "StatsGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create Main Frame
local frame = Instance.new("Frame")
frame.Name = "InfoFrame"
frame.Size = UDim2.new(0, 260, 0, 36)
frame.Position = UDim2.new(0, 15, 0, 15) -- Top-left corner with padding
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2 -- 80% opaque (20% transparent)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Rounded corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame

-- Subtle thin outline (Color: 0, 120, 215)
local uiStroke = Instance.new("UIStroke")
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Color = Color3.fromRGB(0, 120, 215)
uiStroke.Thickness = 1
uiStroke.Transparency = 0.3 -- Subtle transparency
uiStroke.Parent = frame

-- Text Label
local label = Instance.new("TextLabel")
label.Name = "StatsLabel"
label.Size = UDim2.new(1, -20, 1, 0)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamMedium
label.TextColor3 = Color3.fromRGB(245, 245, 245)
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left
label.Text = "Trynix | Tester Build | X fps"
label.Parent = frame

-- FPS Counter Logic
local frameCount = 0
local elapsedTime = 0

RunService.RenderStepped:Connect(function(deltaTime)
	frameCount += 1
	elapsedTime += deltaTime

	if elapsedTime >= 1 then
		local fps = math.floor(frameCount / elapsedTime)
		label.Text = string.format("Trynix | Tester Build | %d fps", fps)
		
		-- Reset counters
		frameCount = 0
		elapsedTime = 0
	end
end)

-- Main Container Frame (CanvasGroup enables smooth group fading)
local mainFrame = Instance.new("CanvasGroup")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 580, 0, 360)
mainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 21, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.GroupTransparency = 0 -- Fully visible by default
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

-- Sidebar (Left)
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(16, 15, 19)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 6)
sidebarCorner.Parent = sidebar

-- Title Logo / Text
local logoText = Instance.new("TextLabel")
logoText.Name = "Logo"
logoText.Size = UDim2.new(1, -20, 0, 40)
logoText.Position = UDim2.new(0, 12, 0, 10)
logoText.BackgroundTransparency = 1
logoText.Text = "Trynix"
logoText.TextColor3 = Color3.fromRGB(200, 200, 210)
logoText.TextSize = 18
logoText.Font = Enum.Font.Code
logoText.TextXAlignment = Enum.TextXAlignment.Left
logoText.Parent = sidebar

-- Navigation Buttons Container
local navContainer = Instance.new("Frame")
navContainer.Name = "NavContainer"
navContainer.Size = UDim2.new(1, 0, 1, -60)
navContainer.Position = UDim2.new(0, 0, 0, 50)
navContainer.BackgroundTransparency = 1
navContainer.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Padding = UDim.new(0, 4)
navLayout.Parent = navContainer

-- Helper function to create nav tab buttons
local function createTabButton(name, text, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.Position = UDim2.new(0, 6, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. text
    btn.TextColor3 = Color3.fromRGB(130, 130, 145)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSans
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = layoutOrder
    btn.Parent = navContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    return btn
end

local mainTabBtn = createTabButton("MainTabBtn", "Main", 1)
local settingsTabBtn = createTabButton("SettingsTabBtn", "Settings", 2)

-- Highlight Main as default active tab
mainTabBtn.BackgroundTransparency = 0.8
mainTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Content Area (Right)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -145, 1, -10)
contentArea.Position = UDim2.new(0, 142, 0, 5)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- ----------------------------------------------------
-- MENU 1: MAIN PAGE
-- ----------------------------------------------------
local mainPage = Instance.new("Frame")
mainPage.Name = "MainPage"
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Visible = true
mainPage.Parent = contentArea

-- Card Container Box inside Main Page
local cardBox = Instance.new("Frame")
cardBox.Name = "CardBox"
cardBox.Size = UDim2.new(0.5, -5, 1, 0)
cardBox.BackgroundColor3 = Color3.fromRGB(28, 27, 34)
cardBox.BorderSizePixel = 0
cardBox.Parent = mainPage

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 6)
cardCorner.Parent = cardBox

local cardHeader = Instance.new("TextLabel")
cardHeader.Name = "Header"
cardHeader.Size = UDim2.new(1, -20, 0, 30)
cardHeader.Position = UDim2.new(0, 10, 0, 5)
cardHeader.BackgroundTransparency = 1
cardHeader.Text = "features"
cardHeader.TextColor3 = Color3.fromRGB(180, 180, 195)
cardHeader.TextSize = 13
cardHeader.Font = Enum.Font.SourceSansSemibold
cardHeader.TextXAlignment = Enum.TextXAlignment.Left
cardHeader.Parent = cardBox

-- Helper to create toggle rows matching the UI style
local function createToggleRow(parent, name, labelText, topPos)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, topPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBg = Instance.new("Frame")
    toggleBg.Name = "ToggleBg"
    toggleBg.Size = UDim2.new(0, 34, 0, 18)
    toggleBg.Position = UDim2.new(1, -34, 0.5, -9)
    toggleBg.BackgroundColor3 = Color3.fromRGB(45, 43, 53)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 12, 0, 12)
    toggleCircle.Position = UDim2.new(0, 3, 0.5, -6)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle

    return toggleBg, toggleCircle
end

-- ui toggles for the ui and features
local voidToggleBg, voidToggleCircle = createToggleRow(cardBox, "VoidRow", "Void Teleport [V]", 40)
local spinToggleBg, spinToggleCircle = createToggleRow(cardBox, "SpinRow", "Spin Bot [X]", 80)
local noclipToggleBg, noclipToggleCircle = createToggleRow(cardBox, "NoclipRow", "Noclip [N]", 120)
local flyToggleBg, flyToggleCircle = createToggleRow(cardBox, "FlyRow", "Fly [F]", 160)


-- Update function for visual state of toggle switches
local function setToggleState(toggleBg, toggleCircle, active)
    if active then
        toggleBg.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
        toggleCircle.Position = UDim2.new(1, -15, 0.5, -6)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        toggleBg.BackgroundColor3 = Color3.fromRGB(45, 43, 53)
        toggleCircle.Position = UDim2.new(0, 3, 0.5, -6)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    end
end

-- ----------------------------------------------------
-- MENU 2: SETTINGS PAGE
-- ----------------------------------------------------
local settingsPage = Instance.new("Frame")
settingsPage.Name = "SettingsPage"
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false
settingsPage.Parent = contentArea

local settingsBox = Instance.new("Frame")
settingsBox.Name = "SettingsBox"
settingsBox.Size = UDim2.new(0.5, -5, 1, 0)
settingsBox.BackgroundColor3 = Color3.fromRGB(28, 27, 34)
settingsBox.BorderSizePixel = 0
settingsBox.Parent = settingsPage

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 6)
settingsCorner.Parent = settingsBox

local settingsHeader = Instance.new("TextLabel")
settingsHeader.Name = "Header"
settingsHeader.Size = UDim2.new(1, -20, 0, 30)
settingsHeader.Position = UDim2.new(0, 10, 0, 5)
settingsHeader.BackgroundTransparency = 1
settingsHeader.Text = "GUI Settings"
settingsHeader.TextColor3 = Color3.fromRGB(180, 180, 195)
settingsHeader.TextSize = 13
settingsHeader.Font = Enum.Font.SourceSansSemibold
settingsHeader.TextXAlignment = Enum.TextXAlignment.Left
settingsHeader.Parent = settingsBox

local unloadBtn = Instance.new("TextButton")
unloadBtn.Name = "UnloadButton"
unloadBtn.Size = UDim2.new(1, -20, 0, 32)
unloadBtn.Position = UDim2.new(0, 10, 0, 45)
unloadBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
unloadBtn.Text = "Unload GUI"
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.TextSize = 14
unloadBtn.Font = Enum.Font.SourceSansBold
unloadBtn.Parent = settingsBox

local unloadCorner = Instance.new("UICorner")
unloadCorner.CornerRadius = UDim.new(0, 4)
unloadCorner.Parent = unloadBtn


-- ----------------------------------------------------
-- LOGIC & FUNCTIONS
-- ----------------------------------------------------
local function switchTab(selected)
    if selected == "Main" then
        mainPage.Visible = true
        settingsPage.Visible = false
        mainTabBtn.BackgroundTransparency = 0.8
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
        mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        settingsTabBtn.BackgroundTransparency = 1
        settingsTabBtn.TextColor3 = Color3.fromRGB(130, 130, 145)
    else
        mainPage.Visible = false
        settingsPage.Visible = true
        settingsTabBtn.BackgroundTransparency = 0.8
        settingsTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
        settingsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        mainTabBtn.BackgroundTransparency = 1
        mainTabBtn.TextColor3 = Color3.fromRGB(130, 130, 145)
    end
end

table.insert(connections, mainTabBtn.MouseButton1Click:Connect(function()
    switchTab("Main")
end))

table.insert(connections, settingsTabBtn.MouseButton1Click:Connect(function()
    switchTab("Settings")
end))

-- Smooth Fade Function
local function toggleGui()
    if isFading then return end
    isFading = true
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    guiVisible = not guiVisible

    if guiVisible then
        mainFrame.Visible = true
        local tween = TweenService:Create(mainFrame, tweenInfo, { GroupTransparency = 0 })
        tween:Play()
        tween.Completed:Wait()
    else
        local tween = TweenService:Create(mainFrame, tweenInfo, { GroupTransparency = 1 })
        tween:Play()
        tween.Completed:Wait()
        mainFrame.Visible = false -- Hides the main frame without disabling screenGui
    end
    
    isFading = false
end

local voidVelocity = nil

local function toggleVoidTeleport()
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    if not isTeleported then
        originalCFrame = rootPart.CFrame
        
        -- Use BodyVelocity instead of anchoring to maintain server replication
        voidVelocity = Instance.new("BodyVelocity")
        voidVelocity.Name = "VoidVelocity"
        voidVelocity.MaxForce = Vector3.new(1, 1, 1) * 10^6
        voidVelocity.Velocity = Vector3.zero
        voidVelocity.Parent = rootPart

        isTeleported = true
        setToggleState(voidToggleBg, voidToggleCircle, true)

        task.spawn(function()
            while isTeleported and character and rootPart do
                local continuousVoidPosition = CFrame.new(
                    math.random(-10000000, -100000), 
                    math.random(5000, 10000), 
                    math.random(-10000000, -100000)
                )
                rootPart.CFrame = continuousVoidPosition
                task.wait(0.05)
            end
        end)
    else
        isTeleported = false
        
        -- Clean up the BodyVelocity
        if voidVelocity then
            voidVelocity:Destroy()
            voidVelocity = nil
        end
        
        if rootPart:FindFirstChild("VoidVelocity") then
            rootPart.VoidVelocity:Destroy()
        end

        if originalCFrame then
            rootPart.CFrame = originalCFrame
        end
        setToggleState(voidToggleBg, voidToggleCircle, false)
    end
end

local function toggleSpin()
    isSpinning = not isSpinning
    setToggleState(spinToggleBg, spinToggleCircle, isSpinning)

    if isSpinning then
        spinConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(SPIN_SPEED), 0)
            end
        end)
    else
        if spinConnection then
            spinConnection:Disconnect()
            spinConnection = nil
        end
    end
end

local function toggleNoclip()
    isNoclip = not isNoclip
    setToggleState(noclipToggleBg, noclipToggleCircle, isNoclip)

    if isNoclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        -- Restore collision immediately on all character parts
        local character = player.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

local function toggleFly()
    isFlying = not isFlying
    setToggleState(flyToggleBg, flyToggleCircle, isFlying)

    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if isFlying then
        if humanoid then humanoid.PlatformStand = true end

        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Name = "FlyVelocity"
        bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10^6
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = rootPart

        flyConnection = RunService.RenderStepped:Connect(function()
            if not isFlying or not rootPart or not rootPart.Parent then
                return
            end

            local camera = workspace.CurrentCamera
            local moveVector = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveVector = moveVector + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveVector = moveVector - Vector3.new(0, 1, 0)
            end

            -- Prevent zero-vector normalization (NaN) which causes extreme speed flinging
            if moveVector.Magnitude > 0 then
                bodyVelocity.Velocity = moveVector.Unit * flySpeed
            else
                bodyVelocity.Velocity = Vector3.zero
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if humanoid then humanoid.PlatformStand = false end
        if rootPart and rootPart:FindFirstChild("FlyVelocity") then
            rootPart.FlyVelocity:Destroy()
        end
    end
end

--========================================
-- Unload / Reset All
--========================================
local function unload()
    if isSpinning then
        toggleSpin()
    end

    if isNoclip then
        toggleNoclip()
    end

    if isTeleported then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            if rootPart:FindFirstChild("VoidVelocity") then
                rootPart.VoidVelocity:Destroy()
            end
            if originalCFrame then
                rootPart.CFrame = originalCFrame
            end
        end
        isTeleported = false
    end

    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    table.clear(connections)

    screenGui:Destroy()
end

table.insert(connections, unloadBtn.MouseButton1Click:Connect(unload))

-- UI Toggle Row Click Handlers
table.insert(connections, voidToggleBg.Parent.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleVoidTeleport()
    end
end))

table.insert(connections, spinToggleBg.Parent.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleSpin()
    end
end))

table.insert(connections, noclipToggleBg.Parent.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleNoclip()
    end
end))

table.insert(connections, flyToggleBg.Parent.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleFly()
    end
end))

-- Keybind Listeners
table.insert(connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.V then
        toggleVoidTeleport()
    elseif input.KeyCode == Enum.KeyCode.X then
        toggleSpin()
    elseif input.KeyCode == Enum.KeyCode.N then
        toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.RightShift then
        toggleGui()
    end
end))
