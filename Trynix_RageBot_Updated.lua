local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Anti-Detection (from original script)
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

-- ============================================================
-- STATE VARIABLES & CONNECTIONS
-- ============================================================
local isTeleported = false
local isSpinning = false
local isNoclip = false
local guiVisible = true
local isFading = false
local isFlying = false
local flySpeed = 50
local flyConnection = nil

local rageBotActive = false
local fastFireActive = false
local fastMeleeActive = false
local voidTpActive = false

local originalCFrame = nil
local spinConnection = nil
local noclipConnection = nil
local rageBotConnection = nil

local SPIN_SPEED = 30
local RAGEBOT_VOID_PULSE = 0.2 -- How long void tp stays on for pulse

local connections = {}

-- ============================================================
-- UI BUILD
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TrynixGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Stats Frame
local frame = Instance.new("Frame")
frame.Name = "InfoFrame"
frame.Size = UDim2.new(0, 260, 0, 36)
frame.Position = UDim2.new(0, 15, 0, 15)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Color = Color3.fromRGB(0, 120, 215)
uiStroke.Thickness = 1
uiStroke.Transparency = 0.3
uiStroke.Parent = frame

local label = Instance.new("TextLabel")
label.Name = "StatsLabel"
label.Size = UDim2.new(1, -20, 1, 0)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamMedium
label.TextColor3 = Color3.fromRGB(245, 245, 245)
label.TextSize = 13
label.TextXAlignment = Enum.TextXAlignment.Left
label.Text = "Trynix | RageBot OFF | FPS 0"
label.Parent = frame

local frameCount = 0
local elapsedTime = 0

RunService.RenderStepped:Connect(function(deltaTime)
	frameCount += 1
	elapsedTime += deltaTime

	if elapsedTime >= 1 then
		local fps = math.floor(frameCount / elapsedTime)
		local rbStatus = rageBotActive and "ON" or "OFF"
		label.Text = string.format("Trynix | RageBot %s | FPS %d", rbStatus, fps)
		frameCount = 0
		elapsedTime = 0
	end
end)

-- Main Container Frame
local mainFrame = Instance.new("CanvasGroup")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 700, 0, 500)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 21, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.GroupTransparency = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 6)
mainCorner.Parent = mainFrame

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(16, 15, 19)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 6)
sidebarCorner.Parent = sidebar

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
local rageTabBtn = createTabButton("RageTabBtn", "Rage", 2)
local settingsTabBtn = createTabButton("SettingsTabBtn", "Settings", 3)

-- Highlight Main as default active tab
mainTabBtn.BackgroundTransparency = 0.8
mainTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -145, 1, -10)
contentArea.Position = UDim2.new(0, 142, 0, 5)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- ============================================================
-- MENU 1: MAIN PAGE
-- ============================================================
local mainPage = Instance.new("Frame")
mainPage.Name = "MainPage"
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Visible = true
mainPage.Parent = contentArea

local cardBox = Instance.new("Frame")
cardBox.Name = "CardBox"
cardBox.Size = UDim2.new(1, 0, 1, 0)
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
cardHeader.Text = "Features"
cardHeader.TextColor3 = Color3.fromRGB(180, 180, 195)
cardHeader.TextSize = 13
cardHeader.Font = Enum.Font.SourceSansSemibold
cardHeader.TextXAlignment = Enum.TextXAlignment.Left
cardHeader.Parent = cardBox

-- Helper to create toggle rows
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

local voidToggleBg, voidToggleCircle = createToggleRow(cardBox, "VoidRow", "Void Teleport [V]", 40)
local spinToggleBg, spinToggleCircle = createToggleRow(cardBox, "SpinRow", "Spin Bot [X]", 80)
local noclipToggleBg, noclipToggleCircle = createToggleRow(cardBox, "NoclipRow", "Noclip [N]", 120)
local flyToggleBg, flyToggleCircle = createToggleRow(cardBox, "FlyRow", "Fly [F]", 160)

-- ============================================================
-- MENU 2: RAGE PAGE
-- ============================================================
local ragePage = Instance.new("Frame")
ragePage.Name = "RagePage"
ragePage.Size = UDim2.new(1, 0, 1, 0)
ragePage.BackgroundTransparency = 1
ragePage.Visible = false
ragePage.Parent = contentArea

local rageBox = Instance.new("Frame")
rageBox.Name = "RageBox"
rageBox.Size = UDim2.new(1, 0, 1, 0)
rageBox.BackgroundColor3 = Color3.fromRGB(28, 27, 34)
rageBox.BorderSizePixel = 0
rageBox.Parent = ragePage

local rageCorner = Instance.new("UICorner")
rageCorner.CornerRadius = UDim.new(0, 6)
rageCorner.Parent = rageBox

local rageHeader = Instance.new("TextLabel")
rageHeader.Name = "Header"
rageHeader.Size = UDim2.new(1, -20, 0, 30)
rageHeader.Position = UDim2.new(0, 10, 0, 5)
rageHeader.BackgroundTransparency = 1
rageHeader.Text = "Rage Features"
rageHeader.TextColor3 = Color3.fromRGB(180, 180, 195)
rageHeader.TextSize = 13
rageHeader.Font = Enum.Font.SourceSansSemibold
rageHeader.TextXAlignment = Enum.TextXAlignment.Left
rageHeader.Parent = rageBox

local rageBotToggleBg, rageBotToggleCircle = createToggleRow(rageBox, "RageBotRow", "RageBot [R]", 40)
local fastFireToggleBg, fastFireToggleCircle = createToggleRow(rageBox, "FastFireRow", "Fast Fire [U]", 80)
local fastMeleeToggleBg, fastMeleeToggleCircle = createToggleRow(rageBox, "FastMeleeRow", "Fast Melee [I]", 120)

-- ============================================================
-- MENU 3: SETTINGS PAGE
-- ============================================================
local settingsPage = Instance.new("Frame")
settingsPage.Name = "SettingsPage"
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.Visible = false
settingsPage.Parent = contentArea

local settingsBox = Instance.new("Frame")
settingsBox.Name = "SettingsBox"
settingsBox.Size = UDim2.new(1, 0, 1, 0)
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

-- ============================================================
-- LOGIC & FUNCTIONS
-- ============================================================

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

-- Helper functions
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    return char
end

local function getRootPart(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)
end

local function getNearestEnemy()
    local myRoot = getRootPart(getCharacter())
    if not myRoot then return nil end

    local bestTarget = nil
    local bestDistance = math.huge

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = getRootPart(otherPlayer.Character)
            if otherRoot then
                local dist = (myRoot.Position - otherRoot.Position).Magnitude
                if dist < bestDistance then
                    bestDistance = dist
                    bestTarget = otherPlayer
                end
            end
        end
    end

    return bestTarget
end

local function getTargetHead(target)
    if not target or not target.Character then return nil end
    return target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("UpperTorso")
end

local function switchTab(selected)
    mainPage.Visible = false
    ragePage.Visible = false
    settingsPage.Visible = false

    mainTabBtn.BackgroundTransparency = 1
    mainTabBtn.TextColor3 = Color3.fromRGB(130, 130, 145)
    rageTabBtn.BackgroundTransparency = 1
    rageTabBtn.TextColor3 = Color3.fromRGB(130, 130, 145)
    settingsTabBtn.BackgroundTransparency = 1
    settingsTabBtn.TextColor3 = Color3.fromRGB(130, 130, 145)

    if selected == "Main" then
        mainPage.Visible = true
        mainTabBtn.BackgroundTransparency = 0.8
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
        mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    elseif selected == "Rage" then
        ragePage.Visible = true
        rageTabBtn.BackgroundTransparency = 0.8
        rageTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
        rageTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        settingsPage.Visible = true
        settingsTabBtn.BackgroundTransparency = 0.8
        settingsTabBtn.BackgroundColor3 = Color3.fromRGB(140, 80, 220)
        settingsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

table.insert(connections, mainTabBtn.MouseButton1Click:Connect(function()
    switchTab("Main")
end))

table.insert(connections, rageTabBtn.MouseButton1Click:Connect(function()
    switchTab("Rage")
end))

table.insert(connections, settingsTabBtn.MouseButton1Click:Connect(function()
    switchTab("Settings")
end))

-- ============================================================
-- RAGEBOT FUNCTIONALITY (SERVER-SIDE VOID TP)
-- ============================================================

local function startRageBot()
    if rageBotConnection then
        rageBotConnection:Disconnect()
    end

    rageBotConnection = RunService.RenderStepped:Connect(function()
        if not rageBotActive then
            rageBotConnection:Disconnect()
            return
        end

        local target = getNearestEnemy()
        if not target or not target.Character then return end

        local targetRoot = getRootPart(target.Character)
        local targetHead = getTargetHead(target)
        if not targetRoot or not targetHead then return end

        local myChar = getCharacter()
        local myRoot = getRootPart(myChar)
        if not myRoot then return end

        -- Disable void teleport temporarily
        voidTpActive = false
        setToggleState(voidToggleBg, voidToggleCircle, false)

        -- Teleport player to target head position
        myRoot.CFrame = targetHead.CFrame + targetHead.CFrame.LookVector * 3

        -- Small delay for positioning
        task.wait(0.05)

        -- Simulate mouse click for attack
        mouse1press()
        task.wait(0.1)
        mouse1release()

        -- Re-enable void teleport for brief moment (0.2 seconds)
        voidTpActive = true
        setToggleState(voidToggleBg, voidToggleCircle, true)

        task.wait(RAGEBOT_VOID_PULSE)

        -- Turn off void tp again and repeat cycle
        voidTpActive = false
        setToggleState(voidToggleBg, voidToggleCircle, false)

        task.wait(0.1) -- Small delay before next cycle
    end)
end

local function stopRageBot()
    if rageBotConnection then
        rageBotConnection:Disconnect()
        rageBotConnection = nil
    end
    voidTpActive = false
    setToggleState(voidToggleBg, voidToggleCircle, false)
end

-- ============================================================
-- FAST FIRE RATE
-- ============================================================

local function applyFastFire()
    pcall(function()
        if not fastFireActive then return end

        -- Hook into weapon systems to reduce fire cooldown
        local tools = player.Backpack:GetChildren()
        for _, tool in ipairs(tools) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local shootCooldown = tool:FindFirstChild("ShootCooldown")
                    if shootCooldown then
                        shootCooldown.Value = shootCooldown.Value * 0.3 -- 70% faster
                    end
                end
            end
        end

        -- Also hook character tools
        local char = getCharacter()
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local shootCooldown = item:FindFirstChild("ShootCooldown")
                    if shootCooldown then
                        shootCooldown.Value = shootCooldown.Value * 0.3
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- FAST MELEE
-- ============================================================

local function applyFastMelee()
    pcall(function()
        if not fastMeleeActive then return end

        local char = getCharacter()
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    local attackCooldown = item:FindFirstChild("AttackCooldown")
                    if attackCooldown then
                        attackCooldown.Value = attackCooldown.Value * 0.3 -- 70% faster
                    end
                end
            end
        end
    end)
end

-- Apply fast fire and melee on render step
RunService.RenderStepped:Connect(function()
    if fastFireActive then
        applyFastFire()
    end
    if fastMeleeActive then
        applyFastMelee()
    end
end)

-- ============================================================
-- TOGGLE BUTTON CONNECTIONS
-- ============================================================

-- RageBot Toggle
table.insert(connections, rageBotToggleBg.MouseButton1Click:Connect(function()
    rageBotActive = not rageBotActive
    setToggleState(rageBotToggleBg, rageBotToggleCircle, rageBotActive)

    if rageBotActive then
        startRageBot()
    else
        stopRageBot()
    end
end))

-- Fast Fire Toggle
table.insert(connections, fastFireToggleBg.MouseButton1Click:Connect(function()
    fastFireActive = not fastFireActive
    setToggleState(fastFireToggleBg, fastFireToggleCircle, fastFireActive)
end))

-- Fast Melee Toggle
table.insert(connections, fastMeleeToggleBg.MouseButton1Click:Connect(function()
    fastMeleeActive = not fastMeleeActive
    setToggleState(fastMeleeToggleBg, fastMeleeToggleCircle, fastMeleeActive)
end))

-- Void Teleport Toggle
table.insert(connections, voidToggleBg.MouseButton1Click:Connect(function()
    if not rageBotActive then -- Only allow manual toggle if ragebot is off
        voidTpActive = not voidTpActive
        setToggleState(voidToggleBg, voidToggleCircle, voidTpActive)
    end
end))

-- Unload Button
table.insert(connections, unloadBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    if rageBotConnection then
        rageBotConnection:Disconnect()
    end
end))

-- ============================================================
-- KEYBOARD SHORTCUTS
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.R then
        rageBotActive = not rageBotActive
        setToggleState(rageBotToggleBg, rageBotToggleCircle, rageBotActive)
        if rageBotActive then
            startRageBot()
        else
            stopRageBot()
        end
    elseif input.KeyCode == Enum.KeyCode.U then
        fastFireActive = not fastFireActive
        setToggleState(fastFireToggleBg, fastFireToggleCircle, fastFireActive)
    elseif input.KeyCode == Enum.KeyCode.I then
        fastMeleeActive = not fastMeleeActive
        setToggleState(fastMeleeToggleBg, fastMeleeToggleCircle, fastMeleeActive)
    elseif input.KeyCode == Enum.KeyCode.V then
        if not rageBotActive then
            voidTpActive = not voidTpActive
            setToggleState(voidToggleBg, voidToggleCircle, voidTpActive)
        end
    end
end)

print("Trynix RageBot Script Loaded!")
