local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerName = player.Name
local playerModel = workspace.playerModels:WaitForChild(playerName)
local axe = playerModel:WaitForChild("axe")
local hitHitbox = axe:WaitForChild("hitHitbox")
local handle = axe:WaitForChild("handle")
local platform = nil

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlatformToggleGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 400, 0, 50)
textLabel.Position = UDim2.new(0, 20, 0, 20)
textLabel.AnchorPoint = Vector2.new(0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Platform Toggle = Hold R"
textLabel.TextStrokeTransparency = 0.5
textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 36
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Parent = screenGui

local mobileText = Instance.new("TextLabel")
mobileText.Size = UDim2.new(0, 400, 0, 40)
mobileText.Position = UDim2.new(0, 20, 0, 80)
mobileText.AnchorPoint = Vector2.new(0, 0)
mobileText.BackgroundTransparency = 1
mobileText.Text = "Mobile Button: OFF"
mobileText.TextStrokeTransparency = 0.5
mobileText.TextStrokeColor3 = Color3.new(0, 0, 0)
mobileText.Font = Enum.Font.GothamBold
mobileText.TextSize = 30
mobileText.TextXAlignment = Enum.TextXAlignment.Left
mobileText.Parent = screenGui

local mobileButton = Instance.new("TextButton")
mobileButton.Size = UDim2.new(0, 100, 0, 100)
mobileButton.Position = UDim2.new(0, 20, 0, 130)
mobileButton.AnchorPoint = Vector2.new(0, 0)
mobileButton.BackgroundTransparency = 0
mobileButton.Text = ""
mobileButton.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.5, 0)
uiCorner.Parent = mobileButton

local function createPlatform()
    if platform then return end
    
    local hitboxBottom = hitHitbox.Position - Vector3.new(0, hitHitbox.Size.Y / 2, 0)
    local platformSize = Vector3.new(hitHitbox.Size.X * 6, 0.5, hitHitbox.Size.Z * 4)
    local platformPos = hitboxBottom - Vector3.new(0, platformSize.Y / 2, 0)
    
    platform = Instance.new("Part")
    platform.Name = "PlatformVisualizer"
    platform.Size = platformSize
    platform.CFrame = CFrame.new(platformPos)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.Transparency = 0
    platform.Parent = workspace
    
    local physicsService = game:GetService("PhysicsService")
    
    if not physicsService:CollisionGroupExists("PlatformGroup") then
        physicsService:CreateCollisionGroup("PlatformGroup")
    end
    if not physicsService:CollisionGroupExists("PlayerAxeHandleGroup") then
        physicsService:CreateCollisionGroup("PlayerAxeHandleGroup")
    end
    
    physicsService:CollisionGroupSetCollidable("PlatformGroup", "PlayerAxeHandleGroup", false)
    physicsService:SetPartCollisionGroup(platform, "PlatformGroup")
    physicsService:SetPartCollisionGroup(handle, "PlayerAxeHandleGroup")
end

local function destroyPlatform()
    if platform then
        platform:Destroy()
        platform = nil
    end
    local physicsService = game:GetService("PhysicsService")
    physicsService:SetPartCollisionGroup(handle, "Default")
end

RunService.RenderStepped:Connect(function()
    local time = tick() * 0.6
    local hue = (time % 1)
    local rainbowColor = Color3.fromHSV(hue, 1, 1)
    
    textLabel.TextColor3 = rainbowColor
    mobileText.TextColor3 = rainbowColor
    mobileButton.BackgroundColor3 = rainbowColor
    
    if platform and platform.Parent then
        platform.Color = rainbowColor
        mobileText.Text = "Mobile Button: ON"
    else
        mobileText.Text = "Mobile Button: OFF"
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        createPlatform()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        destroyPlatform()
    end
end)

mobileButton.MouseButton1Click:Connect(function()
    if platform then
        destroyPlatform()
    else
        createPlatform()
    end
end)
