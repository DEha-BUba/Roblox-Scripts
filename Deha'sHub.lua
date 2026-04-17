-- DEHA'S AIMBOT HUB + ESP SYSTEM
-- Tam entegre versiyon (DÜZELTİLDİ)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

-- ============ AIMBOT SETTINGS ============
local AimbotSettings = {
    FOV = 150,
    MaxDistance = 200,
    WallCheck = true,
    TargetPart = "Head",
    AimbotEnabled = false,
    AutoFire = true,
    FireDelay = 0.1,
    TeamDistance = 15,
    ShowFOVCircle = true
}

-- ============ ESP SETTINGS ============
local ESPSettings = {
    enabled = true,
    showBox = true,           
    showSkeleton = true,      
    showHealth = true,        
    showName = true,          
    showDistance = true,      
    showTracer = true,        
    
    closeDistance = 250,      
    mediumDistance = 500,     
    
    tracerThickness = 2,      
    skeletonThickness = 2,
    updateInterval = 0.03
}

-- ============ TEAM & DECLINED LISTS ============
local TeamPlayers = {}
local DeclinedPlayers = {}

-- ============ VARIABLES ============
local currentTarget = nil
local lastFireTime = 0
local currentNearPlayer = nil
local notificationActive = false
local isGUIOpen = true

-- ESP Variables
local espObjects = {}
local raycastParams = RaycastParams.new()
local lastUpdate = 0

-- Bone connections for skeleton
local boneConnections = {
    {"LeftFoot", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftUpperLeg"},
    {"LeftUpperLeg", "HumanoidRootPart"},
    {"RightFoot", "RightLowerLeg"},
    {"RightLowerLeg", "RightUpperLeg"},
    {"RightUpperLeg", "HumanoidRootPart"},
    {"HumanoidRootPart", "UpperTorso"},
    {"UpperTorso", "Head"},
    {"LeftHand", "LeftLowerArm"},
    {"LeftLowerArm", "LeftUpperArm"},
    {"LeftUpperArm", "UpperTorso"},
    {"RightHand", "RightLowerArm"},
    {"RightLowerArm", "RightUpperArm"},
    {"RightUpperArm", "UpperTorso"}
}

-- ============ GUI ELEMENTS ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DehasAimbotHub"
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(1, -75, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "D"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 24
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 30)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 550)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 50, 50)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TitleBar.BackgroundTransparency = 0.1
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Deha's Aimbot Hub + ESP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

-- Settings Panel
local SettingsPanel = Instance.new("Frame")
SettingsPanel.Size = UDim2.new(0, 300, 0, 130)
SettingsPanel.Position = UDim2.new(0, 10, 0, 50)
SettingsPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
SettingsPanel.BackgroundTransparency = 0.3
SettingsPanel.BorderSizePixel = 0
SettingsPanel.Parent = MainFrame

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 8)
SettingsCorner.Parent = SettingsPanel

-- Aimbot Toggle
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(0, 280, 0, 35)
AimbotToggle.Position = UDim2.new(0, 10, 0, 10)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
AimbotToggle.Text = "AIMBOT: OFF"
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.GothamBold
AimbotToggle.TextSize = 14
AimbotToggle.Parent = SettingsPanel

local AimbotCorner = Instance.new("UICorner")
AimbotCorner.CornerRadius = UDim.new(0, 6)
AimbotCorner.Parent = AimbotToggle

-- FOV Circle Toggle
local FOVToggle = Instance.new("TextButton")
FOVToggle.Size = UDim2.new(0, 135, 0, 35)
FOVToggle.Position = UDim2.new(0, 10, 0, 55)
FOVToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
FOVToggle.Text = "FOV: ON"
FOVToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggle.Font = Enum.Font.GothamBold
FOVToggle.TextSize = 12
FOVToggle.Parent = SettingsPanel

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(0, 6)
FOVCorner.Parent = FOVToggle

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Size = UDim2.new(0, 135, 0, 35)
ESPToggle.Position = UDim2.new(0, 155, 0, 55)
ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
ESPToggle.Text = "ESP: ON"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.GothamBold
ESPToggle.TextSize = 12
ESPToggle.Parent = SettingsPanel

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 6)
ESPCorner.Parent = ESPToggle

-- Team List Label
local TeamLabel = Instance.new("TextLabel")
TeamLabel.Size = UDim2.new(0, 300, 0, 25)
TeamLabel.Position = UDim2.new(0, 10, 0, 195)
TeamLabel.BackgroundTransparency = 1
TeamLabel.Text = "✅ TEAM PLAYERS (Green ESP)"
TeamLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
TeamLabel.Font = Enum.Font.GothamBold
TeamLabel.TextSize = 12
TeamLabel.TextXAlignment = Enum.TextXAlignment.Left
TeamLabel.Parent = MainFrame

-- Team List
local TeamListFrame = Instance.new("ScrollingFrame")
TeamListFrame.Size = UDim2.new(0, 300, 0, 100)
TeamListFrame.Position = UDim2.new(0, 10, 0, 220)
TeamListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TeamListFrame.BackgroundTransparency = 0.3
TeamListFrame.BorderSizePixel = 0
TeamListFrame.Parent = MainFrame

local TeamListCorner = Instance.new("UICorner")
TeamListCorner.CornerRadius = UDim.new(0, 6)
TeamListCorner.Parent = TeamListFrame

local TeamListLayout = Instance.new("UIListLayout")
TeamListLayout.Padding = UDim.new(0, 5)
TeamListLayout.Parent = TeamListFrame

-- Declined List Label
local DeclinedLabel = Instance.new("TextLabel")
DeclinedLabel.Size = UDim2.new(0, 300, 0, 25)
DeclinedLabel.Position = UDim2.new(0, 10, 0, 330)
DeclinedLabel.BackgroundTransparency = 1
DeclinedLabel.Text = "❌ DECLINED PLAYERS (Red ESP)"
DeclinedLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
DeclinedLabel.Font = Enum.Font.GothamBold
DeclinedLabel.TextSize = 12
DeclinedLabel.TextXAlignment = Enum.TextXAlignment.Left
DeclinedLabel.Parent = MainFrame

-- Declined List
local DeclinedListFrame = Instance.new("ScrollingFrame")
DeclinedListFrame.Size = UDim2.new(0, 300, 0, 100)
DeclinedListFrame.Position = UDim2.new(0, 10, 0, 355)
DeclinedListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
DeclinedListFrame.BackgroundTransparency = 0.3
DeclinedListFrame.BorderSizePixel = 0
DeclinedListFrame.Parent = MainFrame

local DeclinedListCorner = Instance.new("UICorner")
DeclinedListCorner.CornerRadius = UDim.new(0, 6)
DeclinedListCorner.Parent = DeclinedListFrame

local DeclinedListLayout = Instance.new("UIListLayout")
DeclinedListLayout.Padding = UDim.new(0, 5)
DeclinedListLayout.Parent = DeclinedListFrame

-- Notification Frame
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "NotificationFrame"
NotificationFrame.Size = UDim2.new(0, 350, 0, 80)
NotificationFrame.Position = UDim2.new(0.5, -175, 0, -100)
NotificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
NotificationFrame.BackgroundTransparency = 0.05
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local NotificationCorner = Instance.new("UICorner")
NotificationCorner.CornerRadius = UDim.new(0, 12)
NotificationCorner.Parent = NotificationFrame

local NotificationStroke = Instance.new("UIStroke")
NotificationStroke.Color = Color3.fromRGB(255, 200, 50)
NotificationStroke.Thickness = 2
NotificationStroke.Parent = NotificationFrame

local NotificationText = Instance.new("TextLabel")
NotificationText.Size = UDim2.new(1, -20, 0, 30)
NotificationText.Position = UDim2.new(0, 10, 0, 10)
NotificationText.BackgroundTransparency = 1
NotificationText.Text = "Want to team with Player?"
NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotificationText.Font = Enum.Font.GothamBold
NotificationText.TextSize = 14
NotificationText.Parent = NotificationFrame

local YesButton = Instance.new("TextButton")
YesButton.Size = UDim2.new(0, 100, 0, 30)
YesButton.Position = UDim2.new(0, 20, 1, -45)
YesButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
YesButton.Text = "YES (G)"
YesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
YesButton.Font = Enum.Font.GothamBold
YesButton.TextSize = 13
YesButton.Parent = NotificationFrame

local YesCorner = Instance.new("UICorner")
YesCorner.CornerRadius = UDim.new(0, 6)
YesCorner.Parent = YesButton

local NoButton = Instance.new("TextButton")
NoButton.Size = UDim2.new(0, 100, 0, 30)
NoButton.Position = UDim2.new(1, -120, 1, -45)
NoButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
NoButton.Text = "NO (H)"
NoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoButton.Font = Enum.Font.GothamBold
NoButton.TextSize = 13
NoButton.Parent = NotificationFrame

local NoCorner = Instance.new("UICorner")
NoCorner.CornerRadius = UDim.new(0, 6)
NoCorner.Parent = NoButton

-- ============ DRAWING OBJECTS ============
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = AimbotSettings.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Filled = false

local TargetCircle = Drawing.new("Circle")
TargetCircle.Radius = 12
TargetCircle.Color = Color3.fromRGB(255, 0, 0)
TargetCircle.Thickness = 2
TargetCircle.NumSides = 20
TargetCircle.Filled = false
TargetCircle.Visible = false

local TargetInfo = Drawing.new("Text")
TargetInfo.Size = 14
TargetInfo.Center = true
TargetInfo.Outline = true
TargetInfo.Color = Color3.fromRGB(255, 255, 255)
TargetInfo.Visible = false

-- ============ HELPER FUNCTIONS ============
local function IsTeamPlayer(player)
    for _, teamPlayer in ipairs(TeamPlayers) do
        if teamPlayer.Name == player.Name then
            return true
        end
    end
    return false
end

local function IsDeclinedPlayer(player)
    for _, declinedPlayer in ipairs(DeclinedPlayers) do
        if declinedPlayer.Name == player.Name then
            return true
        end
    end
    return false
end

local function GetPlayerColor(player)
    if IsTeamPlayer(player) then
        return Color3.fromRGB(100, 255, 100) -- Yeşil
    elseif IsDeclinedPlayer(player) then
        return Color3.fromRGB(255, 100, 100) -- Kırmızı
    else
        return Color3.fromRGB(255, 255, 255) -- Beyaz
    end
end

-- ============ ESP CORE FUNCTIONS ============
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function isBehindWall(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then
        return false
    end
    
    local cameraPosition = Camera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    local distance = (cameraPosition - targetPosition).Magnitude
    
    raycastParams.FilterDescendantsInstances = {character, Camera}
    
    local raycastResult = Workspace:Raycast(cameraPosition, direction * distance, raycastParams)
    return raycastResult ~= nil
end

local function createLine(color, thickness)
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    return line
end

local function worldToScreen(position)
    local screenPoint = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), screenPoint.Z > 0
end

local function getDistanceFromPlayer(targetPosition)
    local character = LocalPlayer.Character
    if not character then return math.huge end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end
    
    return (rootPart.Position - targetPosition).Magnitude
end

-- ============ ESP OBJECT MANAGEMENT ============
local function createHighlight(player)
    local color = GetPlayerColor(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = color
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    return highlight
end

local function createBillboard(player)
    local billboard = Instance.new("BillboardGui")
    local mainFrame = Instance.new("Frame")
    local nameLabel = Instance.new("TextLabel")
    local healthBar = Instance.new("Frame")
    local healthFill = Instance.new("Frame")
    local healthText = Instance.new("TextLabel")
    local distanceLabel = Instance.new("TextLabel")
    
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = billboard
    
    nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = GetPlayerColor(player)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = mainFrame
    
    healthBar.Size = UDim2.new(1, 0, 0.2, 0)
    healthBar.Position = UDim2.new(0, 0, 0.3, 0)
    healthBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = mainFrame
    
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBar
    
    healthText.Size = UDim2.new(1, 0, 0.2, 0)
    healthText.Position = UDim2.new(0, 0, 0.5, 0)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Color3.new(1, 1, 1)
    healthText.TextScaled = true
    healthText.Font = Enum.Font.SourceSansBold
    healthText.Parent = mainFrame
    
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = GetPlayerColor(player)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.SourceSansBold
    distanceLabel.Parent = mainFrame
    
    local head = player.Character:FindFirstChild("Head")
    if head then
        billboard.Parent = head
    end
    
    return {
        billboard = billboard,
        nameLabel = nameLabel,
        healthFill = healthFill,
        healthText = healthText,
        distanceLabel = distanceLabel
    }
end

local function createSkeletonLines(color)
    local lines = {}
    for i = 1, #boneConnections do
        lines[i] = createLine(color, ESPSettings.skeletonThickness)
    end
    return lines
end

local function createTracer(color)
    return createLine(color, ESPSettings.tracerThickness)
end

local function updateSkeleton(objects, player)
    if not ESPSettings.showSkeleton then
        if objects.skeletonLines then
            for _, line in ipairs(objects.skeletonLines) do
                line.Visible = false
            end
        end
        return
    end
    
    local color = GetPlayerColor(player)
    local character = objects.character
    
    for i, bones in ipairs(boneConnections) do
        local part1 = character:FindFirstChild(bones[1])
        local part2 = character:FindFirstChild(bones[2])
        
        if part1 and part2 then
            local pos1, onScreen1 = worldToScreen(part1.Position)
            local pos2, onScreen2 = worldToScreen(part2.Position)
            
            if onScreen1 and onScreen2 then
                objects.skeletonLines[i].Color = color
                objects.skeletonLines[i].From = pos1
                objects.skeletonLines[i].To = pos2
                objects.skeletonLines[i].Visible = true
            else
                objects.skeletonLines[i].Visible = false
            end
        else
            objects.skeletonLines[i].Visible = false
        end
    end
end

local function updateTracer(objects, player)
    if not ESPSettings.showTracer then
        if objects.tracer then
            objects.tracer.Visible = false
        end
        return
    end
    
    local color = GetPlayerColor(player)
    local character = objects.character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local screenPos, onScreen = worldToScreen(rootPart.Position)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        
        if onScreen then
            objects.tracer.Color = color
            objects.tracer.From = screenCenter
            objects.tracer.To = screenPos
            objects.tracer.Visible = true
        else
            objects.tracer.Visible = false
        end
    end
end

local function updateBillboard(player, objects, distance, humanoid, head)
    if not objects.billboardData or not head then
        if objects.billboardData then
            objects.billboardData.billboard.Enabled = false
        end
        return
    end
    
    local color = GetPlayerColor(player)
    local billboardData = objects.billboardData
    
    if distance > ESPSettings.mediumDistance then
        billboardData.billboard.Enabled = false
        return
    end
    
    billboardData.billboard.Enabled = true
    billboardData.billboard.Parent = head
    billboardData.nameLabel.TextColor3 = color
    billboardData.distanceLabel.TextColor3 = color
    
    if ESPSettings.showName then
        billboardData.nameLabel.Visible = true
        billboardData.nameLabel.Text = player.Name
    else
        billboardData.nameLabel.Visible = false
    end
    
    if ESPSettings.showHealth and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        billboardData.healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
        billboardData.healthText.Text = string.format("%.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
        
        if healthPercent > 0.6 then
            billboardData.healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
        elseif healthPercent > 0.3 then
            billboardData.healthFill.BackgroundColor3 = Color3.new(1, 1, 0)
        else
            billboardData.healthFill.BackgroundColor3 = Color3.new(1, 0, 0)
        end
        billboardData.healthFill.Visible = true
        billboardData.healthText.Visible = true
    else
        billboardData.healthFill.Visible = false
        billboardData.healthText.Visible = false
    end
    
    if ESPSettings.showDistance and distance <= ESPSettings.closeDistance then
        billboardData.distanceLabel.Visible = true
        billboardData.distanceLabel.Text = string.format("%.1f m", distance)
    else
        billboardData.distanceLabel.Visible = false
    end
end

local function updateESPObject(player, objects)
    if not (player and objects.character and objects.character.Parent) then
        return
    end
    
    local character = objects.character
    local humanoid = character:FindFirstChild("Humanoid")
    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not (humanoid and head and rootPart and humanoid.Health > 0) then
        if objects.highlight then objects.highlight.Enabled = false end
        if objects.skeletonLines then
            for _, line in ipairs(objects.skeletonLines) do line.Visible = false end
        end
        if objects.tracer then objects.tracer.Visible = false end
        if objects.billboardData then objects.billboardData.billboard.Enabled = false end
        return
    end
    
    local distance = getDistanceFromPlayer(rootPart.Position)
    local color = GetPlayerColor(player)
    
    if objects.highlight then
        objects.highlight.Enabled = ESPSettings.showBox
        objects.highlight.FillColor = color
        objects.highlight.OutlineColor = color
    end
    
    if distance <= ESPSettings.closeDistance then
        updateSkeleton(objects, player)
        updateTracer(objects, player)
    else
        if objects.skeletonLines then
            for _, line in ipairs(objects.skeletonLines) do line.Visible = false end
        end
        if objects.tracer then objects.tracer.Visible = false end
    end
    
    updateBillboard(player, objects, distance, humanoid, head)
end

-- ============ TEAM/DECLINED FUNCTIONS ============
local function UpdateTeamList()
    for _, child in ipairs(TeamListFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(TeamPlayers) do
        local playerFrame = Instance.new("Frame")
        playerFrame.Name = player.Name
        playerFrame.Size = UDim2.new(1, -10, 0, 35)
        playerFrame.BackgroundColor3 = Color3.fromRGB(50, 80, 50)
        playerFrame.BackgroundTransparency = 0.2
        playerFrame.Parent = TeamListFrame
        
        local playerCorner = Instance.new("UICorner")
        playerCorner.CornerRadius = UDim.new(0, 6)
        playerCorner.Parent = playerFrame
        
        local playerName = Instance.new("TextLabel")
        playerName.Size = UDim2.new(1, -35, 1, 0)
        playerName.Position = UDim2.new(0, 10, 0, 0)
        playerName.BackgroundTransparency = 1
        playerName.Text = player.Name
        playerName.TextColor3 = Color3.fromRGB(100, 255, 100)
        playerName.Font = Enum.Font.GothamBold
        playerName.TextSize = 12
        playerName.TextXAlignment = Enum.TextXAlignment.Left
        playerName.Parent = playerFrame
        
        local removeButton = Instance.new("TextButton")
        removeButton.Size = UDim2.new(0, 25, 0, 25)
        removeButton.Position = UDim2.new(1, -30, 0, 5)
        removeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        removeButton.Text = "✕"
        removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeButton.Font = Enum.Font.GothamBold
        removeButton.TextSize = 14
        removeButton.Parent = playerFrame
        
        local removeCorner = Instance.new("UICorner")
        removeCorner.CornerRadius = UDim.new(0, 4)
        removeCorner.Parent = removeButton
        
        removeButton.MouseButton1Click:Connect(function()
            for i, tp in ipairs(TeamPlayers) do
                if tp.Name == player.Name then
                    table.remove(TeamPlayers, i)
                    break
                end
            end
            playerFrame:Destroy()
            -- ESP rengini güncelle
            if espObjects[player] and espObjects[player].highlight then
                local newColor = GetPlayerColor(player)
                espObjects[player].highlight.FillColor = newColor
                espObjects[player].highlight.OutlineColor = newColor
            end
        end)
    end
end

local function UpdateDeclinedList()
    for _, child in ipairs(DeclinedListFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    for _, player in ipairs(DeclinedPlayers) do
        local playerFrame = Instance.new("Frame")
        playerFrame.Name = player.Name
        playerFrame.Size = UDim2.new(1, -10, 0, 35)
        playerFrame.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
        playerFrame.BackgroundTransparency = 0.2
        playerFrame.Parent = DeclinedListFrame
        
        local playerCorner = Instance.new("UICorner")
        playerCorner.CornerRadius = UDim.new(0, 6)
        playerCorner.Parent = playerFrame
        
        local playerName = Instance.new("TextLabel")
        playerName.Size = UDim2.new(1, -35, 1, 0)
        playerName.Position = UDim2.new(0, 10, 0, 0)
        playerName.BackgroundTransparency = 1
        playerName.Text = player.Name
        playerName.TextColor3 = Color3.fromRGB(255, 100, 100)
        playerName.Font = Enum.Font.Gotham
        playerName.TextSize = 12
        playerName.TextXAlignment = Enum.TextXAlignment.Left
        playerName.Parent = playerFrame
        
        local removeButton = Instance.new("TextButton")
        removeButton.Size = UDim2.new(0, 25, 0, 25)
        removeButton.Position = UDim2.new(1, -30, 0, 5)
        removeButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        removeButton.Text = "✓"
        removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        removeButton.Font = Enum.Font.GothamBold
        removeButton.TextSize = 14
        removeButton.Parent = playerFrame
        
        local removeCorner = Instance.new("UICorner")
        removeCorner.CornerRadius = UDim.new(0, 4)
        removeCorner.Parent = removeButton
        
        removeButton.MouseButton1Click:Connect(function()
            for i, dp in ipairs(DeclinedPlayers) do
                if dp.Name == player.Name then
                    table.remove(DeclinedPlayers, i)
                    break
                end
            end
            playerFrame:Destroy()
            -- ESP rengini güncelle
            if espObjects[player] and espObjects[player].highlight then
                local newColor = GetPlayerColor(player)
                espObjects[player].highlight.FillColor = newColor
                espObjects[player].highlight.OutlineColor = newColor
            end
        end)
    end
end

-- ============ AIMBOT FUNCTIONS ============
local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local raycastParams2 = RaycastParams.new()
    raycastParams2.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams2.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, raycastParams2)
    
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = AimbotSettings.FOV
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeamPlayer(player) then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local targetPart = character:FindFirstChild(AimbotSettings.TargetPart)
                
                if humanoid and humanoid.Health > 0 and targetPart then
                    local distance3D = (Camera.CFrame.Position - targetPart.Position).Magnitude
                    if distance3D > AimbotSettings.MaxDistance then
                        continue
                    end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if distance2D < closestDistance then
                            if not AimbotSettings.WallCheck or IsVisible(targetPart) then
                                closestDistance = distance2D
                                closestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestTarget
end

local function AutoFire()
    if not AimbotSettings.AutoFire or not currentTarget then return end
    
    if not IsVisible(currentTarget) then
        return
    end
    
    local currentTime = tick()
    if currentTime - lastFireTime >= AimbotSettings.FireDelay then
        mouse1click()
        lastFireTime = currentTime
    end
end

local function ShowNotification(player)
    if notificationActive then return end
    
    currentNearPlayer = player
    NotificationText.Text = "🤝 Want to team with " .. player.Name .. "?"
    NotificationFrame.Visible = true
    notificationActive = true
    
    local tween = TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -175, 0, 20)})
    tween:Play()
end

local function HideNotification()
    if not notificationActive then return end
    
    local tween = TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -175, 0, -100)})
    tween:Play()
    task.wait(0.4)
    NotificationFrame.Visible = false
    notificationActive = false
    currentNearPlayer = nil
end

local function AddToTeam(player)
    if not IsTeamPlayer(player) then
        for i, dp in ipairs(DeclinedPlayers) do
            if dp.Name == player.Name then
                table.remove(DeclinedPlayers, i)
                break
            end
        end
        
        table.insert(TeamPlayers, player)
        UpdateTeamList()
        UpdateDeclinedList()
        
        if espObjects[player] and espObjects[player].highlight then
            local color = GetPlayerColor(player)
            espObjects[player].highlight.FillColor = color
            espObjects[player].highlight.OutlineColor = color
        end
    end
end

local function AddToDeclined(player)
    if not IsDeclinedPlayer(player) then
        for i, tp in ipairs(TeamPlayers) do
            if tp.Name == player.Name then
                table.remove(TeamPlayers, i)
                break
            end
        end
        
        table.insert(DeclinedPlayers, player)
        UpdateTeamList()
        UpdateDeclinedList()
        
        if espObjects[player] and espObjects[player].highlight then
            local color = GetPlayerColor(player)
            espObjects[player].highlight.FillColor = color
            espObjects[player].highlight.OutlineColor = color
        end
    end
end

local function CheckNearbyPlayers()
    local closestDistance = AimbotSettings.TeamDistance
    local closestPlayer = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not IsTeamPlayer(player) and not IsDeclinedPlayer(player) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local localChar = LocalPlayer.Character
                    if localChar and localChar:FindFirstChild("HumanoidRootPart") then
                        local distance = (localChar.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    if closestPlayer and (not currentNearPlayer or currentNearPlayer ~= closestPlayer) then
        if notificationActive then
            HideNotification()
        end
        ShowNotification(closestPlayer)
    elseif not closestPlayer and notificationActive then
        HideNotification()
    end
end

-- ============ ESP EVENT HANDLERS ============
local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    
    local function onCharacterAdded(character)
        if espObjects[player] then
            local old = espObjects[player]
            if old.highlight then old.highlight:Destroy() end
            if old.billboardData then old.billboardData.billboard:Destroy() end
            if old.skeletonLines then
                for _, line in ipairs(old.skeletonLines) do line:Remove() end
            end
            if old.tracer then old.tracer:Remove() end
        end
        
        task.wait(0.5)
        
        if not character or not character.Parent then return end
        
        local color = GetPlayerColor(player)
        local highlight = createHighlight(player)
        local billboardData = createBillboard(player)
        local skeletonLines = createSkeletonLines(color)
        local tracer = createTracer(color)
        
        espObjects[player] = {
            highlight = highlight,
            billboardData = billboardData,
            skeletonLines = skeletonLines,
            tracer = tracer,
            character = character
        }
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function onPlayerRemoving(player)
    if espObjects[player] then
        local obj = espObjects[player]
        if obj.highlight then obj.highlight:Destroy() end
        if obj.billboardData then obj.billboardData.billboard:Destroy() end
        if obj.skeletonLines then
            for _, line in ipairs(obj.skeletonLines) do line:Remove() end
        end
        if obj.tracer then obj.tracer:Remove() end
        espObjects[player] = nil
    end
end

local function updateESP()
    if not ESPSettings.enabled then return end
    
    for player, objects in pairs(espObjects) do
        updateESPObject(player, objects)
    end
end

-- ============ GUI DRAGGING ============
local dragging = false
local dragInput
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============ BUTTON EVENTS ============
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    isGUIOpen = false
end)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    isGUIOpen = MainFrame.Visible
end)

AimbotToggle.MouseButton1Click:Connect(function()
    AimbotSettings.AimbotEnabled = not AimbotSettings.AimbotEnabled
    if AimbotSettings.AimbotEnabled then
        AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        AimbotToggle.Text = "AIMBOT: ON"
    else
        AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        AimbotToggle.Text = "AIMBOT: OFF"
        currentTarget = nil
    end
end)

FOVToggle.MouseButton1Click:Connect(function()
    AimbotSettings.ShowFOVCircle = not AimbotSettings.ShowFOVCircle
    FOVCircle.Visible = AimbotSettings.ShowFOVCircle
    if AimbotSettings.ShowFOVCircle then
        FOVToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        FOVToggle.Text = "FOV: ON"
    else
        FOVToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        FOVToggle.Text = "FOV: OFF"
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    ESPSettings.enabled = not ESPSettings.enabled
    if ESPSettings.enabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        ESPToggle.Text = "ESP: ON"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ESPToggle.Text = "ESP: OFF"
        for _, objects in pairs(espObjects) do
            if objects.highlight then objects.highlight.Enabled = false end
            if objects.billboardData then objects.billboardData.billboard.Enabled = false end
            if objects.skeletonLines then
                for _, line in ipairs(objects.skeletonLines) do line.Visible = false end
            end
            if objects.tracer then objects.tracer.Visible = false end
        end
    end
end)

YesButton.MouseButton1Click:Connect(function()
    if currentNearPlayer then
        AddToTeam(currentNearPlayer)
        HideNotification()
    end
end)

NoButton.MouseButton1Click:Connect(function()
    if currentNearPlayer then
        AddToDeclined(currentNearPlayer)
        HideNotification()
    end
end)

-- ============ KEYBINDS ============
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Q then
            AimbotSettings.AimbotEnabled = not AimbotSettings.AimbotEnabled
            if AimbotSettings.AimbotEnabled then
                AimbotToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                AimbotToggle.Text = "AIMBOT: ON"
            else
                AimbotToggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                AimbotToggle.Text = "AIMBOT: OFF"
                currentTarget = nil
            end
        elseif input.KeyCode == Enum.KeyCode.G and notificationActive then
            if currentNearPlayer then
                AddToTeam(currentNearPlayer)
                HideNotification()
            end
        elseif input.KeyCode == Enum.KeyCode.H and notificationActive then
            if currentNearPlayer then
                AddToDeclined(currentNearPlayer)
                HideNotification()
            end
        elseif input.KeyCode == Enum.KeyCode.F2 then
            ESPSettings.showBox = not ESPSettings.showBox
            print("Box ESP: " .. tostring(ESPSettings.showBox))
        elseif input.KeyCode == Enum.KeyCode.F3 then
            ESPSettings.showSkeleton = not ESPSettings.showSkeleton
            print("Skeleton: " .. tostring(ESPSettings.showSkeleton))
        elseif input.KeyCode == Enum.KeyCode.F4 then
            ESPSettings.showHealth = not ESPSettings.showHealth
            print("Health Bar: " .. tostring(ESPSettings.showHealth))
        elseif input.KeyCode == Enum.KeyCode.F5 then
            ESPSettings.showTracer = not ESPSettings.showTracer
            print("Tracer: " .. tostring(ESPSettings.showTracer))
        end
    end
end)

-- ============ MAIN LOOPS ============
RunService.RenderStepped:Connect(function()
    if AimbotSettings.ShowFOVCircle then
        local mousePos = Vector2.new(mouse.X, mouse.Y)
        FOVCircle.Position = mousePos
        
        if AimbotSettings.AimbotEnabled then
            FOVCircle.Color = currentTarget and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
        else
            FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        end
    end
    
    CheckNearbyPlayers()
    updateESP()
end)

RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if AimbotSettings.AimbotEnabled then
        currentTarget = GetClosestTarget()
        
        if currentTarget then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, currentTarget.Position)
            AutoFire()
        end
    else
        currentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if currentTarget and AimbotSettings.AimbotEnabled then
        local screenPos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
        
        if onScreen then
            TargetCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
            TargetCircle.Visible = true
            
            local character = currentTarget.Parent
            local humanoid = character:FindFirstChild("Humanoid")
            local player = Players:GetPlayerFromCharacter(character)
            
            if player and humanoid then
                local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                local distance3D = (Camera.CFrame.Position - currentTarget.Position).Magnitude
                
                TargetInfo.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                TargetInfo.Text = string.format("%s | %dm | ❤️%d", player.Name, math.floor(distance3D), math.floor(humanoid.Health))
                TargetInfo.Visible = true
                
                if not IsVisible(currentTarget) then
                    TargetInfo.Color = Color3.fromRGB(255, 0, 0)
                elseif healthPercent < 25 then
                    TargetInfo.Color = Color3.fromRGB(255, 0, 0)
                elseif healthPercent < 50 then
                    TargetInfo.Color = Color3.fromRGB(255, 165, 0)
                else
                    TargetInfo.Color = Color3.fromRGB(0, 255, 0)
                end
            end
        else
            TargetCircle.Visible = false
            TargetInfo.Visible = false
        end
    else
        TargetCircle.Visible = false
        TargetInfo.Visible = false
    end
end)

-- ============ INITIALIZATION ============
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function() onPlayerAdded(player) end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

UpdateTeamList()
UpdateDeclinedList()

-- Console messages
print("========================================")
print("Deha's Hub Loaded!")
print("========================================")
print("AIMBOT CONTROLS:")
print("Q - Toggle Aimbot ON/OFF")
print("G - Accept team request")
print("H - Decline team request")
print("")
print("ESP CONTROLS:")
print("F2 - Toggle Box ESP")
print("F3 - Toggle Skeleton")
print("F4 - Toggle Health Bar")
print("F5 - Toggle Tracer")
print("")
print("ESP COLOR SYSTEM:")
print("✅ GREEN - Team Players (No aimbot)")
print("❌ RED - Declined Players")
print("⚪ WHITE - Neutral Players")
print("========================================")
