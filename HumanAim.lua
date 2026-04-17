local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local mouse = LocalPlayer:GetMouse()

-- ================================
-- KONFIGÜRASYON
-- ================================
local Settings = {
    TriggerDelay = 0.04,          -- 40ms tepki (hızlı)
    MaxDistance = 400,
    MaxFOV = 220,
    MinFOV = 100,
    WallCheck = true,
    TeamCheck = true,
}

-- ================================
-- STATE
-- ================================
local lastShotTime = 0
local espCache = {}

-- Hareket
local horizontalSpeed = 0
local verticalSpeed = 0
local isJumping = false
local lastJumpTime = 0

-- ================================
-- HAREKET ANALİZİ
-- ================================
local function updateMovement()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local vel = rootPart.AssemblyLinearVelocity
    horizontalSpeed = math.sqrt(vel.X^2 + vel.Z^2)
    verticalSpeed = math.abs(vel.Y)
    
    if vel.Y > 8 and not isJumping then
        isJumping = true
        lastJumpTime = tick()
    elseif vel.Y < 2 and isJumping then
        isJumping = false
    end
    
    if tick() - lastJumpTime > 0.3 then
        isJumping = false
    end
end

-- ================================
-- FOV HESAPLA (Hareket + Zıplama)
-- ================================
local function getFOV()
    local hNorm = math.min(1, horizontalSpeed / 22)
    local vNorm = math.min(1, verticalSpeed / 12)
    local jumpBonus = isJumping and 0.5 or 1
    
    local moveScore = (hNorm * 0.7) + (vNorm * 0.3)
    moveScore = moveScore * jumpBonus
    
    local fov = Settings.MaxFOV - (moveScore * (Settings.MaxFOV - Settings.MinFOV))
    return math.clamp(fov, Settings.MinFOV, Settings.MaxFOV)
end

-- ================================
-- GÖRÜNÜRLÜK
-- ================================
local function isVisible(part)
    local char = LocalPlayer.Character
    if not char then return true end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    
    local result = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), params)
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

-- ================================
-- HEDEF NİŞANGAHTA MI?
-- ================================
local function getTargetAtCenter()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local currentFOV = getFOV()
    local bestTarget = nil
    local bestDist = currentFOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    
                    if targetPart then
                        if Settings.TeamCheck and player.Team and LocalPlayer.Team then
                            if player.Team == LocalPlayer.Team then continue end
                        end
                        
                        local dist3D = (Camera.CFrame.Position - targetPart.Position).Magnitude
                        if dist3D <= Settings.MaxDistance then
                            if not Settings.WallCheck or isVisible(targetPart) then
                                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                                if onScreen then
                                    local dist2D = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                    if dist2D < bestDist then
                                        bestDist = dist2D
                                        bestTarget = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if bestTarget then
        local pos, _ = Camera:WorldToViewportPoint(bestTarget.Position)
        local distToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        local tolerance = currentFOV * 0.12
        if distToCenter < tolerance then
            return true
        end
    end
    return false
end

-- ================================
-- ATEŞ ET
-- ================================
local function shoot()
    local now = tick()
    if now - lastShotTime >= Settings.TriggerDelay then
        pcall(function()
            mouse1click()
        end)
        lastShotTime = now
    end
end

-- ================================
-- ESP (Sade kutu + isim + can)
-- ================================
local function setupESP(player)
    local esp = {
        box = Drawing.new("Square"),
        name = Drawing.new("Text"),
        health = Drawing.new("Line"),
        healthBg = Drawing.new("Line"),
    }
    
    esp.box.Thickness = 2
    esp.box.Filled = false
    esp.box.Transparency = 0.3
    
    esp.name.Size = 12
    esp.name.Center = true
    esp.name.Outline = true
    
    esp.healthBg.Thickness = 2.5
    esp.healthBg.Color = Color3.new(0.1, 0.1, 0.1)
    esp.health.Thickness = 2.5
    
    espCache[player] = esp
end

local function updateESP()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local currentFOV = getFOV()
    
    for player, esp in pairs(espCache) do
        local char = player.Character
        if not char then
            esp.box.Visible = false
            continue
        end
        
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or humanoid.Health <= 0 or not hrp then
            esp.box.Visible = false
            continue
        end
        
        local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist > Settings.MaxDistance then
            esp.box.Visible = false
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then
            esp.box.Visible = false
            continue
        end
        
        local visible = isVisible(hrp)
        local distToCenter = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        local inFOV = distToCenter < currentFOV
        
        -- Renk belirleme
        local color
        if inFOV and visible then
            color = Color3.new(0, 1, 0)  -- Yeşil (nişangahın içinde)
        elseif humanoid.Health < 30 then
            color = Color3.new(1, 0.3, 0)  -- Turuncu (canı az)
        else
            color = Color3.new(1, 0.2, 0.2)  -- Kırmızı
        end
        
        -- Boyut
        local scale = 4.5 / dist
        local w = 60 * scale
        local h = 80 * scale
        
        -- Kutu
        esp.box.Size = Vector2.new(w, h)
        esp.box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
        esp.box.Color = color
        esp.box.Visible = visible
        
        -- İsim + mesafe
        local hpText = humanoid.Health < 60 and " [" .. math.floor(humanoid.Health) .. "]" or ""
        esp.name.Text = player.Name .. hpText .. " [" .. math.floor(dist) .. "m]"
        esp.name.Position = Vector2.new(pos.X, pos.Y - h/2 - 12)
        esp.name.Color = color
        esp.name.Visible = true
        
        -- Can barı
        local hpPercent = humanoid.Health / humanoid.MaxHealth
        local barHeight = h * hpPercent
        
        esp.healthBg.From = Vector2.new(pos.X - w/2 - 5, pos.Y + h/2)
        esp.healthBg.To = Vector2.new(pos.X - w/2 - 5, pos.Y - h/2)
        esp.healthBg.Visible = true
        
        esp.health.From = Vector2.new(pos.X - w/2 - 5, pos.Y + h/2)
        esp.health.To = Vector2.new(pos.X - w/2 - 5, pos.Y + h/2 - barHeight)
        
        if hpPercent < 0.3 then
            esp.health.Color = Color3.new(1, 0, 0)
        elseif hpPercent < 0.5 then
            esp.health.Color = Color3.new(1, 1, 0)
        else
            esp.health.Color = Color3.new(0, 1, 0)
        end
        esp.health.Visible = true
    end
end

-- ================================
-- FOV DAİRESİ
-- ================================
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.NumSides = 72
fovCircle.Filled = false
fovCircle.Transparency = 0.4
fovCircle.Color = Color3.new(0, 1, 0)

local statusText = Drawing.new("Text")
statusText.Size = 12
statusText.Position = Vector2.new(10, 30)
statusText.Outline = true
statusText.Color = Color3.new(0.7, 0.7, 0.7)

-- ================================
-- ANA DÖNGÜ
-- ================================
RunService.RenderStepped:Connect(function()
    updateMovement()
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local currentFOV = getFOV()
    
    -- FOV dairesi
    fovCircle.Radius = currentFOV
    fovCircle.Position = center
    
    -- ESP
    updateESP()
    
    -- TRIGGER BOT (her zaman açık)
    local onTarget = getTargetAtCenter()
    
    -- Durum göstergesi
    local moveIcon = isJumping and "🦘" or (horizontalSpeed > 16 and "🏃" or (horizontalSpeed > 5 and "🚶" or "🧍"))
    statusText.Text = string.format("%s | H:%.0f | FOV:%.0f | %s", 
        moveIcon, horizontalSpeed, currentFOV,
        onTarget and "🎯 ATEŞ EDİYOR" or "⚡ HAZIR")
    
    if onTarget then
        statusText.Color = Color3.new(0, 1, 0)
        fovCircle.Color = Color3.new(0, 1, 0)
        shoot()
    else
        statusText.Color = Color3.new(0.5, 0.5, 0.5)
        fovCircle.Color = Color3.new(0, 0.8, 0.2)
    end
end)

-- ================================
-- BAŞLANGIÇ
-- ================================
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        setupESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        setupESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            obj:Remove()
        end
        espCache[player] = nil
    end
end)

print("==========================================")
print("=== TRIGGER BOT + ESP (HER ZAMAN AÇIK) ===")
print("")
print("✅ NASIL ÇALIŞIR:")
print("  • Nişangahını düşmanın üzerine getir")
print("  • OTOMATİK ATEŞ EDER")
print("  • Hiçbir tuşa basmana gerek yok")
print("")
print("✅ ESP:")
print("  • Yeşil kutu = Nişangahın içinde")
print("  • Kırmızı kutu = Düşman")
print("  • Turuncu = Canı az")
print("  • Can barı + mesafe")
print("")
print("✅ FOV:")
print("  • Dururken: 220")
print("  • Koşarken: 100-150")
print("  • Zıplarken: En dar")
print("==========================================")
