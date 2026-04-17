local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

local Settings = {
    FOV = 150,
    MaxDistance = 200,
    WallCheck = true,
    TeamCheck = true,
    TargetPart = "Head",
    AimbotEnabled = false,
    AutoFire = true,
    FireDelay = 0.1,
}

local currentTarget = nil
local lastFireTime = 0
local lastUpdateTime = 0
local playerCache = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = Settings.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 2
FOVCircle.NumSides = 60
FOVCircle.Filled = false

local TargetCircle = Drawing.new("Circle")
TargetCircle.Radius = 10
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

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local function GetClosestTarget()
    local closestTarget = nil
    local closestDistance = Settings.FOV
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    local currentTime = tick()
    
    if currentTime - lastUpdateTime > 0.1 then
        playerCache = Players:GetPlayers()
        lastUpdateTime = currentTime
    end
    
    for _, player in ipairs(playerCache) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                local targetPart = character:FindFirstChild(Settings.TargetPart)
                
                if humanoid and humanoid.Health > 0 and targetPart then
                    if Settings.TeamCheck and player.Team and player.Team == LocalPlayer.Team then
                        continue
                    end
                    
                    local distance3D = (Camera.CFrame.Position - targetPart.Position).Magnitude
                    if distance3D > Settings.MaxDistance then
                        continue
                    end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if distance2D < closestDistance then
                            if not Settings.WallCheck or IsVisible(targetPart) then
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
    if not Settings.AutoFire or not currentTarget then return end
    
    if not IsVisible(currentTarget) then
        return
    end
    
    local currentTime = tick()
    if currentTime - lastFireTime >= Settings.FireDelay then
        mouse1click()
        lastFireTime = currentTime
    end
end

RunService.RenderStepped:Connect(function()
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Position = mousePos
    
    if Settings.AimbotEnabled then
        FOVCircle.Color = currentTarget and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
    else
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Q then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        if not Settings.AimbotEnabled then
            currentTarget = nil
        end
    end
end)

RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if Settings.AimbotEnabled then
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
    if currentTarget and Settings.AimbotEnabled then
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
                
                TargetInfo.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                TargetInfo.Text = string.format("%s | %dm", player.Name, math.floor(distance3D))
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
