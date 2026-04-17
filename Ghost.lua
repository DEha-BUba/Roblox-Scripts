-- GHOST MODE - YUKARI/AŞAĞI DÜZELTİLDİ
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

repeat wait() until player.Character
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Değişkenler
local ghostMode = false
local ghostSpeed = 50
local originalCFrame = rootPart.CFrame
local cameraPart = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GhostModeGUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.5, -125, 0.5, -100)
frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.2)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Başlık
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
title.Text = "👻 GHOST MODE (G)"
title.TextColor3 = Color3.new(0.5, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

-- Durum
local durumLabel = Instance.new("TextLabel")
durumLabel.Size = UDim2.new(1, 0, 0, 30)
durumLabel.Position = UDim2.new(0, 0, 0, 35)
durumLabel.BackgroundTransparency = 1
durumLabel.Text = "🔴 KARAKTER MODU"
durumLabel.TextColor3 = Color3.new(1, 0.5, 0)
durumLabel.Font = Enum.Font.SourceSansBold
durumLabel.TextScaled = true
durumLabel.Parent = frame

-- Hız göstergesi
local hizLabel = Instance.new("TextLabel")
hizLabel.Size = UDim2.new(1, 0, 0, 30)
hizLabel.Position = UDim2.new(0, 0, 0, 65)
hizLabel.BackgroundTransparency = 1
hizLabel.Text = "⚡ HIZ: 50"
hizLabel.TextColor3 = Color3.new(0, 1, 0)
hizLabel.Font = Enum.Font.SourceSansBold
hizLabel.TextScaled = true
hizLabel.Parent = frame

-- Hız butonları
local hizArtir = Instance.new("TextButton")
hizArtir.Size = UDim2.new(0.4, 0, 0, 30)
hizArtir.Position = UDim2.new(0.05, 0, 0, 100)
hizArtir.BackgroundColor3 = Color3.new(0, 0.5, 0)
hizArtir.Text = "HIZ +"
hizArtir.Font = Enum.Font.SourceSansBold
hizArtir.TextScaled = true
hizArtir.Parent = frame

local hizAzalt = Instance.new("TextButton")
hizAzalt.Size = UDim2.new(0.4, 0, 0, 30)
hizAzalt.Position = UDim2.new(0.55, 0, 0, 100)
hizAzalt.BackgroundColor3 = Color3.new(0.5, 0, 0)
hizAzalt.Text = "HIZ -"
hizAzalt.Font = Enum.Font.SourceSansBold
hizAzalt.TextScaled = true
hizAzalt.Parent = frame

-- Ghost Mode butonu
local ghostBtn = Instance.new("TextButton")
ghostBtn.Size = UDim2.new(0.9, 0, 0, 35)
ghostBtn.Position = UDim2.new(0.05, 0, 0, 135)
ghostBtn.BackgroundColor3 = Color3.new(0.5, 0.2, 0.7)
ghostBtn.Text = "👻 GHOST MODE AÇ"
ghostBtn.Font = Enum.Font.SourceSansBold
ghostBtn.TextScaled = true
ghostBtn.Parent = frame

-- Işınla butonu (F)
local isinlaLabel = Instance.new("TextLabel")
isinlaLabel.Size = UDim2.new(1, 0, 0, 25)
isinlaLabel.Position = UDim2.new(0, 0, 0, 175)
isinlaLabel.BackgroundTransparency = 1
isinlaLabel.Text = "F'ye bas → IŞINLAN"
isinlaLabel.TextColor3 = Color3.new(1, 1, 0)
isinlaLabel.Font = Enum.Font.SourceSans
isinlaLabel.TextScaled = true
isinlaLabel.Parent = frame

-- Ghost Mode fonksiyonu
local function toggleGhostMode()
    ghostMode = not ghostMode
    
    if ghostMode then
        -- GHOST MODE AÇ
        ghostBtn.Text = "👻 GHOST MODE KAPAT"
        ghostBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
        durumLabel.Text = "🟢 GHOST MODE - GEZİYOR"
        durumLabel.TextColor3 = Color3.new(0, 1, 0)
        
        -- Karakterin pozisyonunu kaydet
        originalCFrame = rootPart.CFrame
        
        -- Karakteri görünmez yap ve dondur
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        
        -- Tüm karakter parçalarını transparan yap
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 1
                v.CanCollide = false
            end
        end
        
        -- Kamerayı serbest bırak
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = rootPart.CFrame * CFrame.new(0, 2, 0)
        
        print("👻 Ghost Mode aktif - Kamerayla gez, F'ye basıp karakteri ışınla")
        
    else
        -- GHOST MODE KAPAT
        ghostBtn.Text = "👻 GHOST MODE AÇ"
        ghostBtn.BackgroundColor3 = Color3.new(0.5, 0.2, 0.7)
        durumLabel.Text = "🔴 KARAKTER MODU"
        durumLabel.TextColor3 = Color3.new(1, 0.5, 0)
        
        -- Karakteri normale döndür
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        
        -- Karakteri tekrar görünür yap
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0
                v.CanCollide = true
            end
        end
        
        -- Kamerayı normale döndür
        camera.CameraType = Enum.CameraType.Custom
    end
end

-- Işınlama fonksiyonu
local function teleportToCamera()
    if not ghostMode then 
        print("Önce Ghost Mode'u aç!")
        return 
    end
    
    if rootPart and camera then
        -- Karakteri kameranın olduğu yere ışınla
        rootPart.CFrame = camera.CFrame * CFrame.new(0, -2, 0)
        
        -- Efekt
        local effect = Instance.new("Part")
        effect.Size = Vector3.new(2, 2, 2)
        effect.BrickColor = BrickColor.new("Bright blue")
        effect.Material = Enum.Material.Neon
        effect.Transparency = 0.5
        effect.CanCollide = false
        effect.Anchored = true
        effect.CFrame = rootPart.CFrame
        effect.Parent = workspace
        game:GetService("Debris"):AddItem(effect, 0.5)
        
        print("✨ Karakter ışınlandı!")
    end
end

-- Hareket (DÜZELTİLDİ - YUKARI/AŞAĞI ÇALIŞIYOR)
game:GetService("RunService").Heartbeat:Connect(function()
    if not ghostMode or not camera then return end
    
    local move = Vector3.new(0, 0, 0)
    local input = game:GetService("UserInputService")
    
    -- İleri
    if input:IsKeyDown(Enum.KeyCode.W) then
        move = move + camera.CFrame.LookVector * ghostSpeed
    end
    
    -- Geri
    if input:IsKeyDown(Enum.KeyCode.S) then
        move = move - camera.CFrame.LookVector * ghostSpeed
    end
    
    -- Sol
    if input:IsKeyDown(Enum.KeyCode.A) then
        move = move - camera.CFrame.RightVector * ghostSpeed
    end
    
    -- Sağ
    if input:IsKeyDown(Enum.KeyCode.D) then
        move = move + camera.CFrame.RightVector * ghostSpeed
    end
    
    -- YUKARI (Space) - DÜZELTİLDİ
    if input:IsKeyDown(Enum.KeyCode.Space) then
        move = move + Vector3.new(0, 1, 0) * ghostSpeed
        print("Yukarı") -- Test için
    end
    
    -- AŞAĞI (Shift) - DÜZELTİLDİ
    if input:IsKeyDown(Enum.KeyCode.LeftShift) then
        move = move + Vector3.new(0, -1, 0) * ghostSpeed
        print("Aşağı") -- Test için
    end
    
    -- Hareket varsa uygula
    if move.Magnitude > 0 then
        camera.CFrame = camera.CFrame + (move * 0.1)
    end
    
    -- Fare ile kamera döndürme (sağ tık basılıyken)
    if input:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local delta = input:GetMouseDelta()
        local rotation = CFrame.Angles(0, -delta.X * 0.003, 0) * CFrame.Angles(-delta.Y * 0.003, 0, 0)
        camera.CFrame = camera.CFrame * rotation
    end
end)

-- Tuş kontrolleri
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        toggleGhostMode()
    end
    
    if input.KeyCode == Enum.KeyCode.F and ghostMode then
        teleportToCamera()
    end
end)

-- Butonlar
hizArtir.MouseButton1Click:Connect(function()
    ghostSpeed = ghostSpeed + 10
    hizLabel.Text = "⚡ HIZ: " .. ghostSpeed
end)

hizAzalt.MouseButton1Click:Connect(function()
    ghostSpeed = math.max(10, ghostSpeed - 10)
    hizLabel.Text = "⚡ HIZ: " .. ghostSpeed
end)

ghostBtn.MouseButton1Click:Connect(toggleGhostMode)

-- Karakter değişiminde
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(0.5)
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if ghostMode then
        ghostMode = false
        toggleGhostMode()
    end
end)

print("👻 GHOST MODE HAZIR!")
print("G = Ghost Mode aç/kapat")
print("WASD = İleri/Geri/Sol/Sağ")
print("SPACE = YUKARI ÇIK (ÇALIŞIYOR)")
print("SHIFT = AŞAĞI İN (ÇALIŞIYOR)")
print("F = Karakteri ışınla")
print("Sağ tık + fare = Kamera döndür")
