local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

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
local isScriptActive = true

-- Drawing nesnelerini tutacak değişkenler
local FOVCircle = nil
local TargetCircle = nil
local TargetInfo = nil

-- GUI Butonu Oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimbotGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local closeButton = Instance.new("ImageButton")
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeButton.BackgroundTransparency = 0.2
closeButton.BorderSizePixel = 0
closeButton.Image = "rbxassetid://3926305904"
closeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Parent = screenGui

-- Buton hover efekti
local function animateButton(button, targetTransparency)
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = targetTransparency})
    tween:Play()
end

closeButton.MouseEnter:Connect(function()
    animateButton(closeButton, 0.5)
end)

closeButton.MouseLeave:Connect(function()
    animateButton(closeButton, 0.2)
end)

-- Tüm Drawing nesnelerini temizleme fonksiyonu
local function ClearDrawings()
    if FOVCircle then
        FOVCircle.Visible = false
        FOVCircle:Remove()
        FOVCircle = nil
    end
    
    if TargetCircle then
        TargetCircle.Visible = false
        TargetCircle:Remove()
        TargetCircle = nil
    end
    
    if TargetInfo then
        TargetInfo.Visible = false
        TargetInfo:Remove()
        TargetInfo = nil
    end
end

-- Drawing nesnelerini oluşturma fonksiyonu
local function CreateDrawings()
    ClearDrawings() -- Önce varsa temizle
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = true
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    
    TargetCircle = Drawing.new("Circle")
    TargetCircle.Radius = 10
    TargetCircle.Color = Color3.fromRGB(255, 0, 0)
    TargetCircle.Thickness = 2
    TargetCircle.NumSides = 20
    TargetCircle.Filled = false
    TargetCircle.Visible = false
    
    TargetInfo = Drawing.new("Text")
    TargetInfo.Size = 14
    TargetInfo.Center = true
    TargetInfo.Outline = true
    TargetInfo.Color = Color3.fromRGB(255, 255, 255)
    TargetInfo.Visible = false
end

-- Butona tıklama işlevi (tam temizlik)
closeButton.MouseButton1Click:Connect(function()
    if not isScriptActive then return end
    
    isScriptActive = false
    
    -- Tüm Drawing nesnelerini temizle (FOV dairesi dahil)
    ClearDrawings()
    
    -- GUI'yi temizle
    if screenGui then
        screenGui:Destroy()
    end
    
    -- Tüm bağlantıları temizle
    if _renderStepConnection then
        RunService:UnbindFromRenderStep("Aimbot")
        _renderStepConnection = nil
    end
    
    if _renderSteppedConnection1 then
        _renderSteppedConnection1:Disconnect()
        _renderSteppedConnection1 = nil
    end
    
    if _renderSteppedConnection2 then
        _renderSteppedConnection2:Disconnect()
        _renderSteppedConnection2 = nil
    end
    
    if _inputConnection then
        _inputConnection:Disconnect()
        _inputConnection = nil
    end
    
    -- Değişkenleri temizle
    currentTarget = nil
    playerCache = nil
    
    -- Settings tablosunu temizle
    if Settings then
        for key in pairs(Settings) do
            Settings[key] = nil
        end
        Settings = nil
    end
    
    print("Aimbot script başarıyla kapatıldı ve tüm çizimler (FOV dairesi dahil) temizlendi!")
end)

-- Drawing nesnelerini oluştur
CreateDrawings()

-- Fonksiyonlar
local function IsVisible(targetPart)
    if not isScriptActive then return false end
    
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
    if not isScriptActive then return nil end
    
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
    if not isScriptActive then return end
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

-- RenderStepped bağlantıları
local _renderSteppedConnection1 = RunService.RenderStepped:Connect(function()
    if not isScriptActive or not FOVCircle then return end
    
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    FOVCircle.Position = mousePos
    
    if Settings and Settings.AimbotEnabled then
        FOVCircle.Color = currentTarget and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
    elseif FOVCircle then
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    end
end)

local _inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not isScriptActive then return end
    
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Q then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        if not Settings.AimbotEnabled then
            currentTarget = nil
        end
    end
end)

local _renderStepConnection = RunService:BindToRenderStep("Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
    if not isScriptActive then return end
    
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

local _renderSteppedConnection2 = RunService.RenderStepped:Connect(function()
    if not isScriptActive then return end
    
    if currentTarget and Settings.AimbotEnabled and TargetCircle and TargetInfo then
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
    elseif TargetCircle and TargetInfo then
        TargetCircle.Visible = false
        TargetInfo.Visible = false
    end
end)

print("Aimbot script başarıyla başlatıldı!")
print("Q tuşu ile aimbot'u açıp kapatabilirsiniz")
print("Sağ üstteki kırmızı X butonuna tıklayarak scripti tamamen kapatabilirsiniz")
print("Not: Kapatınca FOV dairesi ve diğer tüm çizimler tamamen silinecektir")
