-- ÇALIŞAN BYPASS FLY - HAREKET SORUNU DÜZELTİLDİ
local player = game.Players.LocalPlayer

repeat wait() until player.Character
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 50
local fakePart = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "FlyBypass"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0.5, -110, 0.5, -90)
frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Gölge
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
title.BackgroundTransparency = 0.3
title.Text = "🚀 BYPASS FLY (F)"
title.TextColor3 = Color3.new(0, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

local hizLabel = Instance.new("TextLabel")
hizLabel.Size = UDim2.new(1, 0, 0, 30)
hizLabel.Position = UDim2.new(0, 0, 0, 35)
hizLabel.BackgroundTransparency = 1
hizLabel.Text = "⚡ HIZ: 50"
hizLabel.TextColor3 = Color3.new(0, 1, 0)
hizLabel.Font = Enum.Font.SourceSansBold
hizLabel.TextScaled = true
hizLabel.Parent = frame

local hizArtir = Instance.new("TextButton")
hizArtir.Size = UDim2.new(0.45, 0, 0, 35)
hizArtir.Position = UDim2.new(0.025, 0, 0, 70)
hizArtir.BackgroundColor3 = Color3.new(0, 0.6, 0)
hizArtir.Text = "➕ HIZ +"
hizArtir.TextColor3 = Color3.new(1, 1, 1)
hizArtir.Font = Enum.Font.SourceSansBold
hizArtir.TextScaled = true
hizArtir.Parent = frame

local hizAzalt = Instance.new("TextButton")
hizAzalt.Size = UDim2.new(0.45, 0, 0, 35)
hizAzalt.Position = UDim2.new(0.525, 0, 0, 70)
hizAzalt.BackgroundColor3 = Color3.new(0.6, 0, 0)
hizAzalt.Text = "➖ HIZ -"
hizAzalt.TextColor3 = Color3.new(1, 1, 1)
hizAzalt.Font = Enum.Font.SourceSansBold
hizAzalt.TextScaled = true
hizAzalt.Parent = frame

local acKapa = Instance.new("TextButton")
acKapa.Size = UDim2.new(0.95, 0, 0, 40)
acKapa.Position = UDim2.new(0.025, 0, 0, 110)
acKapa.BackgroundColor3 = Color3.new(0.7, 0.7, 0)
acKapa.Text = "🛸 UÇUŞ AÇ"
acKapa.TextColor3 = Color3.new(1, 1, 1)
acKapa.Font = Enum.Font.SourceSansBold
acKapa.TextScaled = true
acKapa.Parent = frame

local durumLabel = Instance.new("TextLabel")
durumLabel.Size = UDim2.new(1, 0, 0, 25)
durumLabel.Position = UDim2.new(0, 0, 0, 155)
durumLabel.BackgroundTransparency = 1
durumLabel.Text = "✅ BYPASS AKTİF"
durumLabel.TextColor3 = Color3.new(0, 1, 0)
durumLabel.Font = Enum.Font.SourceSans
durumLabel.TextScaled = true
durumLabel.Parent = frame

-- Bypass fonksiyonu
local function bypassFly()
    if flying then
        -- UÇUŞU KAPAT
        flying = false
        acKapa.Text = "🛸 UÇUŞ AÇ"
        acKapa.BackgroundColor3 = Color3.new(0.7, 0.7, 0)
        durumLabel.Text = "✅ YÜRÜME MODU"
        
        -- Fake part'i temizle
        if fakePart then
            fakePart:Destroy()
            fakePart = nil
        end
        
        -- NORMAL YÜRÜME AYARLARI (HAREKET İÇİN)
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        humanoid.WalkSpeed = 16  -- Normal yürüme hızı
        humanoid.JumpPower = 50   -- Normal zıplama
        humanoid:ChangeState(Enum.HumanoidStateType.Running)  -- Koşma moduna zorla
        
        -- Fizik motorunu normale döndür
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, workspace.CurrentCamera.CFrame.Y, 0)
        
        print("Uçuş kapandı - Yürüme aktif")
        
    else
        -- UÇUŞU AÇ
        flying = true
        acKapa.Text = "⛔ UÇUŞ KAPAT"
        acKapa.BackgroundColor3 = Color3.new(0.8, 0, 0)
        durumLabel.Text = "🚀 UÇUYOR..."
        
        -- Fake part oluştur (bypass için)
        fakePart = Instance.new("Part")
        fakePart.Name = "BypassPart"
        fakePart.Size = Vector3.new(2, 2, 2)
        fakePart.Transparency = 1
        fakePart.Anchored = true
        fakePart.CanCollide = false
        fakePart.Parent = workspace
        
        -- UÇUŞ AYARLARI
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        humanoid.WalkSpeed = 0    -- Yürüme hızını sıfırla
        humanoid.JumpPower = 0    -- Zıplamayı sıfırla
        
        print("Uçuş açıldı - Bypass aktif")
    end
end

-- Hareket
game:GetService("RunService").Heartbeat:Connect(function()
    if not rootPart then return end
    
    if flying then
        -- UÇUŞ MODU
        local move = Vector3.new(0, 0, 0)
        local input = game:GetService("UserInputService")
        local camera = workspace.CurrentCamera
        
        if input:IsKeyDown(Enum.KeyCode.W) then
            move = move + camera.CFrame.LookVector * speed
        end
        if input:IsKeyDown(Enum.KeyCode.S) then
            move = move - camera.CFrame.LookVector * speed
        end
        if input:IsKeyDown(Enum.KeyCode.A) then
            move = move - camera.CFrame.RightVector * speed
        end
        if input:IsKeyDown(Enum.KeyCode.D) then
            move = move + camera.CFrame.RightVector * speed
        end
        if input:IsKeyDown(Enum.KeyCode.Space) then
            move = move + Vector3.new(0, speed, 0)
        end
        if input:IsKeyDown(Enum.KeyCode.LeftShift) then
            move = move + Vector3.new(0, -speed, 0)
        end
        
        if move.Magnitude > 0 then
            local newPos = rootPart.Position + (move * 0.1)
            rootPart.CFrame = CFrame.new(newPos) * CFrame.Angles(0, camera.CFrame.Y, 0)
            
            -- Tüm fizik sıfırlama (uçuş için)
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        end
        
        if fakePart then
            fakePart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end)

-- Her frame fizik kontrolü
game:GetService("RunService").Stepped:Connect(function()
    if rootPart then
        if flying then
            -- UÇARKEN fizik sıfırla
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        else
            -- YÜRÜRKEN fizik normal çalışsın (HİÇBİR ŞEY YAPMA)
            -- Bu sayede normal yürüme çalışır
        end
    end
end)

-- Butonlar
hizArtir.MouseButton1Click:Connect(function()
    speed = speed + 10
    hizLabel.Text = "⚡ HIZ: " .. speed
end)

hizAzalt.MouseButton1Click:Connect(function()
    speed = math.max(10, speed - 10)
    hizLabel.Text = "⚡ HIZ: " .. speed
end)

acKapa.MouseButton1Click:Connect(bypassFly)

-- F tuşu
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        bypassFly()
    end
end)

-- Karakter değişimi
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(0.5)
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Her karakter değişiminde NORMAL ayarları yükle
    humanoid.WalkSpeed = 16
    humanoid.JumpPower = 50
    humanoid.AutoRotate = true
    humanoid.PlatformStand = false
    
    if flying then
        -- Eğer uçuş açıksa, kapatıp aç (yeni karakterde)
        flying = false
        wait(0.1)
        bypassFly()
    end
    
    print("Yeni karakter - Normal yürüme aktif")
end)

-- BAŞLANGIÇ AYARLARI (ÇOK ÖNEMLİ)
humanoid.WalkSpeed = 16
humanoid.JumpPower = 50
humanoid.AutoRotate = true
humanoid.PlatformStand = false

print("✅ BYPASS FLY HAZIR! F tuşu ile aç/kapat, kapatınca normal yürüme çalışır")
