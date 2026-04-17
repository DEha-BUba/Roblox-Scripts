-- SÜPER STALKER SCRIPTİ (5 STUD + GELİŞMİŞ RADAR)
-- STARTERPLAYER -> STARTERCHARACTERSCRIPTS İÇİNE KOYUN

local Players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Kamera için güvenli bekle
local camera = workspace.CurrentCamera or workspace:WaitForChild("Camera", 5)

-- Değişkenler
local gui = nil
local targetPlayer = nil
local isFollowing = false
local FOLLOW_DISTANCE = 5 -- 5 stud olarak değiştirildi
local character = nil
local humanoid = nil
local rootPart = nil
local playerListVisible = false
local radarVisible = false
local teleportEffect = true
local autoTarget = false
local oldCameraType = camera and camera.CameraType or Enum.CameraType.Custom

-- Smooth follow için değişkenler
local smoothEnabled = false
local smoothSpeed = 50

-- Karakter hazır olana kadar bekle
local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    
    local success, result = pcall(function()
        humanoid = character:WaitForChild("Humanoid", 5)
        rootPart = character:WaitForChild("HumanoidRootPart", 5)
    end)
    
    if not success or not humanoid or not rootPart then
        warn("❌ Karakter parçaları bulunamadı!")
        return false
    end
    
    if humanoid then
        humanoid.Died:Connect(function()
            stopFollowing()
            print("💀 Karakter öldü, takip durduruldu")
        end)
    end
    
    print("✅ Karakter hazır:", character.Name)
    return true
end

-- En yakın oyuncuyu bul
local function findNearestPlayer()
    if not rootPart then return nil end
    
    local nearestPlayer = nil
    local nearestDistance = math.huge
    local currentPos = rootPart.Position
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local plrRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if plrRoot then
                local distance = (plrRoot.Position - currentPos).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = plr
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Işınlanma efekti
local function createTeleportEffect(position)
    if not rootPart then return end
    
    local oldEffect = workspace:FindFirstChild("TeleportEffect")
    if oldEffect then
        oldEffect:Destroy()
    end
    
    local effect = Instance.new("Part")
    effect.Name = "TeleportEffect"
    effect.Size = Vector3.new(2, 2, 2)
    effect.Position = position or (rootPart and rootPart.Position or Vector3.new())
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.3
    effect.BrickColor = BrickColor.new("Bright blue")
    effect.Material = Enum.Material.Neon
    effect.Parent = workspace
    
    local pointLight = Instance.new("PointLight")
    pointLight.Parent = effect
    pointLight.Brightness = 5
    pointLight.Range = 10
    pointLight.Color = Color3.new(0, 1, 1)
    
    local tweenInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = tweenService:Create(effect, tweenInfo, {
        Size = Vector3.new(5, 5, 5),
        Transparency = 1
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        effect:Destroy()
    end)
end

-- Karakteri hedefe ışınla veya glide et
local function moveToTarget()
    if not targetPlayer then return false end
    if not targetPlayer.Character then return false end
    if not rootPart or not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    
    local targetChar = targetPlayer.Character
    if not targetChar then return false end
    
    local targetHum = targetChar:FindFirstChild("Humanoid")
    if not targetHum or targetHum.Health <= 0 then
        stopFollowing()
        return false
    end
    
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    
    local lookVector = targetRoot.CFrame.LookVector
    local targetPos = targetRoot.Position - (lookVector * FOLLOW_DISTANCE)
    local targetRotation = targetRoot.Orientation.Y
    
    if smoothEnabled then
        local currentPos = rootPart.Position
        local direction = (targetPos - currentPos).Unit
        local distance = (targetPos - currentPos).Magnitude
        
        if distance > 2 then
            local moveVector = direction * math.min(smoothSpeed * 0.1, distance)
            local newPos = currentPos + moveVector
            
            pcall(function()
                rootPart.CFrame = CFrame.new(newPos) * CFrame.Angles(0, math.rad(targetRotation), 0)
            end)
        end
    else
        if teleportEffect then
            createTeleportEffect(rootPart.Position)
        end
        
        pcall(function()
            rootPart.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(targetRotation), 0)
        end)
        
        if teleportEffect then
            task.wait(0.1)
            createTeleportEffect(rootPart.Position)
        end
    end
    
    pcall(function()
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
            local head = character and character:FindFirstChild("Head")
            if head then
                local cameraPos = head.Position + Vector3.new(0, 0.5, 0)
                local lookAtPos = targetRoot.Position + (lookVector * 10)
                camera.CFrame = CFrame.new(cameraPos, lookAtPos)
            else
                camera.CFrame = CFrame.new(rootPart.Position + Vector3.new(0, 2, 0), targetRoot.Position + (lookVector * 10))
            end
        end
    end)
    
    return true
end

-- GELİŞMİŞ RADAR (YENİ)
local function createRadar()
    if not gui or not gui.screen then return end
    
    -- Ana radar çerçevesi
    local radarFrame = Instance.new("Frame")
    radarFrame.Name = "RadarFrame"
    radarFrame.Parent = gui.screen
    radarFrame.Size = UDim2.new(0, 240, 0, 260)
    radarFrame.Position = UDim2.new(1, -250, 1, -270)
    radarFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.1)
    radarFrame.BackgroundTransparency = 0.2
    radarFrame.BorderSizePixel = 3
    radarFrame.BorderColor3 = Color3.new(0, 1, 1)
    radarFrame.Visible = radarVisible
    radarFrame.ZIndex = 10
    
    -- Radar başlık çubuğu
    local titleBar = Instance.new("Frame")
    titleBar.Parent = radarFrame
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.new(0, 0.3, 0.3)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 11
    
    local radarTitle = Instance.new("TextLabel")
    radarTitle.Parent = titleBar
    radarTitle.Size = UDim2.new(1, -30, 1, 0)
    radarTitle.Position = UDim2.new(0, 0, 0, 0)
    radarTitle.Text = "🔍 RADAR - 5 STUD"
    radarTitle.TextColor3 = Color3.new(1, 1, 1)
    radarTitle.BackgroundTransparency = 1
    radarTitle.Font = Enum.Font.SourceSansBold
    radarTitle.TextSize = 16
    radarTitle.ZIndex = 12
    
    local closeRadarBtn = Instance.new("TextButton")
    closeRadarBtn.Parent = titleBar
    closeRadarBtn.Size = UDim2.new(0, 30, 0, 30)
    closeRadarBtn.Position = UDim2.new(1, -30, 0, 0)
    closeRadarBtn.Text = "X"
    closeRadarBtn.TextColor3 = Color3.new(1, 1, 1)
    closeRadarBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeRadarBtn.Font = Enum.Font.SourceSansBold
    closeRadarBtn.TextSize = 18
    closeRadarBtn.BorderSizePixel = 0
    closeRadarBtn.ZIndex = 12
    
    closeRadarBtn.MouseButton1Click:Connect(function()
        radarVisible = false
        radarFrame.Visible = false
    end)
    
    -- Radar ekranı (daire şeklinde)
    local radarScreen = Instance.new("Frame")
    radarScreen.Parent = radarFrame
    radarScreen.Size = UDim2.new(0, 200, 0, 200)
    radarScreen.Position = UDim2.new(0.5, -100, 0.5, -85)
    radarScreen.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    radarScreen.BackgroundTransparency = 0.3
    radarScreen.BorderSizePixel = 2
    radarScreen.BorderColor3 = Color3.new(0, 1, 1)
    radarScreen.ZIndex = 11
    
    -- Radar ızgarası
    for i = 1, 4 do
        local circle = Instance.new("Frame")
        circle.Parent = radarScreen
        circle.Size = UDim2.new(0, 40 * i, 0, 40 * i)
        circle.Position = UDim2.new(0.5, -(20 * i), 0.5, -(20 * i))
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 1
        circle.BorderColor3 = Color3.new(0, 0.5, 0.5)
        circle.ZIndex = 12
    end
    
    -- Merkez noktası (sen)
    local centerDot = Instance.new("Frame")
    centerDot.Parent = radarScreen
    centerDot.Size = UDim2.new(0, 8, 0, 8)
    centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    centerDot.BackgroundColor3 = Color3.new(0, 1, 0)
    centerDot.BorderSizePixel = 1
    centerDot.BorderColor3 = Color3.new(1, 1, 1)
    centerDot.ZIndex = 15
    
    -- Merkez yazısı
    local centerLabel = Instance.new("TextLabel")
    centerLabel.Parent = radarScreen
    centerLabel.Size = UDim2.new(0, 40, 0, 20)
    centerLabel.Position = UDim2.new(0.5, -20, 0.5, 10)
    centerLabel.Text = "SEN"
    centerLabel.TextColor3 = Color3.new(0, 1, 0)
    centerLabel.BackgroundTransparency = 1
    centerLabel.Font = Enum.Font.SourceSansBold
    centerLabel.TextSize = 10
    centerLabel.ZIndex = 15
    
    -- Mesafe göstergesi
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Parent = radarFrame
    distanceLabel.Size = UDim2.new(1, 0, 0, 25)
    distanceLabel.Position = UDim2.new(0, 0, 1, -25)
    distanceLabel.Text = "Hedef: Yok"
    distanceLabel.TextColor3 = Color3.new(1, 1, 0)
    distanceLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    distanceLabel.Font = Enum.Font.SourceSansBold
    distanceLabel.TextSize = 14
    distanceLabel.ZIndex = 11
    
    gui.radarFrame = radarFrame
    gui.radarScreen = radarScreen
    gui.radarDistance = distanceLabel
    
    -- Radar güncelleme döngüsü
    task.spawn(function()
        while true do
            task.wait(0.1)
            if radarVisible and rootPart and gui.radarScreen then
                -- Eski blipleri temizle
                for _, child in pairs(gui.radarScreen:GetChildren()) do
                    if child.Name == "RadarBlip" or child.Name == "DistanceLine" then
                        child:Destroy()
                    end
                end
                
                local playerCount = 0
                
                -- Oyuncuları radar'da göster
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local plrRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if plrRoot then
                            local relativePos = plrRoot.Position - rootPart.Position
                            local distance = (plrRoot.Position - rootPart.Position).Magnitude
                            
                            -- Radar menzili 50 stud
                            if distance < 50 then
                                playerCount = playerCount + 1
                                
                                -- Radar koordinatları (merkezden uzaklık)
                                local radarX = (relativePos.X / 50) * 80
                                local radarZ = (relativePos.Z / 50) * 80
                                
                                -- Sadece radar ekranı içinde kalacak şekilde sınırla
                                radarX = math.clamp(radarX, -90, 90)
                                radarZ = math.clamp(radarZ, -90, 90)
                                
                                -- Blip oluştur
                                local blip = Instance.new("Frame")
                                blip.Name = "RadarBlip"
                                blip.Parent = gui.radarScreen
                                blip.Size = UDim2.new(0, 8, 0, 8)
                                blip.Position = UDim2.new(0.5, radarX - 4, 0.5, -radarZ - 4)
                                blip.BackgroundColor3 = plr == targetPlayer and Color3.new(1, 0, 0) or Color3.new(1, 1, 0)
                                blip.BorderSizePixel = 1
                                blip.BorderColor3 = Color3.new(1, 1, 1)
                                blip.ZIndex = 14
                                
                                -- Hedefse mesafe çizgisi ve isim
                                if plr == targetPlayer then
                                    -- Mesafe çizgisi
                                    local line = Instance.new("Frame")
                                    line.Name = "DistanceLine"
                                    line.Parent = gui.radarScreen
                                    line.Size = UDim2.new(0, 2, 0, distance * 2)
                                    line.Position = UDim2.new(0.5, -1, 0.5, 0)
                                    line.Rotation = math.deg(math.atan2(radarX, -radarZ))
                                    line.BackgroundColor3 = Color3.new(1, 0, 0)
                                    line.BackgroundTransparency = 0.5
                                    line.ZIndex = 13
                                    
                                    -- İsim etiketi
                                    local nameTag = Instance.new("TextLabel")
                                    nameTag.Name = "RadarBlip"
                                    nameTag.Parent = gui.radarScreen
                                    nameTag.Size = UDim2.new(0, 60, 0, 16)
                                    nameTag.Position = UDim2.new(0.5, radarX + 10, 0.5, -radarZ - 8)
                                    nameTag.Text = plr.Name
                                    nameTag.TextColor3 = Color3.new(1, 1, 1)
                                    nameTag.BackgroundColor3 = Color3.new(0, 0, 0)
                                    nameTag.BackgroundTransparency = 0.3
                                    nameTag.Font = Enum.Font.SourceSansBold
                                    nameTag.TextSize = 12
                                    nameTag.ZIndex = 14
                                end
                            end
                        end
                    end
                end
                
                -- Mesafe bilgisini güncelle
                if targetPlayer and targetPlayer.Character then
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local dist = (targetRoot.Position - rootPart.Position).Magnitude
                        gui.radarDistance.Text = string.format("🎯 %s: %.1f stud", targetPlayer.Name, dist)
                    else
                        gui.radarDistance.Text = "🎯 Hedef: Ölü"
                    end
                else
                    gui.radarDistance.Text = "🎯 Hedef: Yok"
                end
                
                -- Oyuncu sayısını göster
                if playerCount == 0 then
                    local noPlayer = Instance.new("TextLabel")
                    noPlayer.Name = "RadarBlip"
                    noPlayer.Parent = gui.radarScreen
                    noPlayer.Size = UDim2.new(1, 0, 0, 30)
                    noPlayer.Position = UDim2.new(0, 0, 0.5, -15)
                    noPlayer.Text = "YAKINDA OYUNCU YOK"
                    noPlayer.TextColor3 = Color3.new(1, 1, 0)
                    noPlayer.BackgroundTransparency = 1
                    noPlayer.Font = Enum.Font.SourceSansBold
                    noPlayer.TextSize = 14
                    noPlayer.ZIndex = 14
                end
            end
        end
    end)
end

-- Oyuncu listesini güncelle
local function updatePlayerList()
    if not gui then return end
    if not gui.playerListFrame then return end
    
    local players = Players:GetPlayers()
    local listFrame = gui.playerListFrame
    
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("ScrollingFrame") or (child:IsA("TextButton") and child.Name ~= "CloseButton") then
            child:Destroy()
        end
    end
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayerScrollFrame"
    scrollFrame.Parent = listFrame
    scrollFrame.Size = UDim2.new(1, 0, 1, -45)
    scrollFrame.Position = UDim2.new(0, 0, 0, 45)
    scrollFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    scrollFrame.BackgroundTransparency = 0.2
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.new(0, 1, 1)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ScrollingEnabled = true
    scrollFrame.ZIndex = 4
    
    local buttonCount = 0
    for i, plr in pairs(players) do
        if plr ~= player then
            buttonCount = buttonCount + 1
            
            local btn = Instance.new("TextButton")
            btn.Parent = scrollFrame
            btn.Name = "PlayerButton_" .. plr.Name
            btn.Size = UDim2.new(0.95, 0, 0, 40)
            btn.Position = UDim2.new(0.025, 0, 0, (buttonCount-1) * 45)
            local displayName = plr.DisplayName or plr.Name
            btn.Text = plr.Name .. "  [" .. displayName .. "]"
            btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 16
            btn.BorderSizePixel = 1
            btn.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
            btn.ZIndex = 5
            btn.AutoButtonColor = false
            
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.new(0.4, 0.4, 0.8)
                btn.BorderColor3 = Color3.new(0, 1, 1)
            end)
            
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
                btn.BorderColor3 = Color3.new(0.5, 0.5, 0.5)
            end)
            
            btn.MouseButton1Click:Connect(function()
                print("🎯 Tıklandı: " .. plr.Name)
                targetPlayer = plr
                isFollowing = true
                if gui then
                    gui.targetLabel.Text = "🎯 Hedef: " .. plr.Name
                    gui.targetLabel.TextColor3 = Color3.new(0, 1, 0)
                    gui.nameBox.Text = plr.Name
                end
                gui.playerListFrame.Visible = false
                playerListVisible = false
                moveToTarget()
            end)
        end
    end
    
    if buttonCount == 0 then
        local noPlayerLabel = Instance.new("TextLabel")
        noPlayerLabel.Parent = scrollFrame
        noPlayerLabel.Size = UDim2.new(1, 0, 0, 50)
        noPlayerLabel.Position = UDim2.new(0, 0, 0, 10)
        noPlayerLabel.Text = "❌ BAŞKA OYUNCU YOK"
        noPlayerLabel.TextColor3 = Color3.new(1, 0, 0)
        noPlayerLabel.BackgroundTransparency = 1
        noPlayerLabel.Font = Enum.Font.SourceSansBold
        noPlayerLabel.TextSize = 20
        noPlayerLabel.ZIndex = 5
    end
end

-- GUI oluşturma
local function createGUI()
    local playerGui = player:WaitForChild("PlayerGui", 10)
    if not playerGui then return nil end
    
    local oldGui = playerGui:FindFirstChild("StalkerGUI")
    if oldGui then oldGui:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StalkerGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    screenGui.IgnoreGuiInset = true
    
    -- ANA PANEL ---------------------------------
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, 380, 0, 340)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0, 1, 1)
    mainFrame.Active = true
    mainFrame.Visible = true
    mainFrame.ZIndex = 2
    
    local dragBar = Instance.new("Frame")
    dragBar.Parent = mainFrame
    dragBar.Size = UDim2.new(1, 0, 0, 35)
    dragBar.Position = UDim2.new(0, 0, 0, 0)
    dragBar.BackgroundColor3 = Color3.new(0, 0.5, 0.5)
    dragBar.BorderSizePixel = 0
    dragBar.Active = true
    dragBar.ZIndex = 3
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = dragBar
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.Text = "⚡ STALKER - 5 STUD ⚡"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.ZIndex = 4
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Parent = mainFrame
    infoLabel.Size = UDim2.new(0.9, 0, 0, 20)
    infoLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
    infoLabel.Text = "🔹 X: Takip | Ctrl+F: Panel | 5 stud arkada"
    infoLabel.TextColor3 = Color3.new(0, 1, 1)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 12
    infoLabel.ZIndex = 3
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Parent = mainFrame
    targetLabel.Size = UDim2.new(0.9, 0, 0, 25)
    targetLabel.Position = UDim2.new(0.05, 0, 0.19, 0)
    targetLabel.Text = "Hedef: Yok"
    targetLabel.TextColor3 = Color3.new(1, 1, 0)
    targetLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    targetLabel.Font = Enum.Font.SourceSansBold
    targetLabel.TextSize = 16
    targetLabel.ZIndex = 3
    
    local nameBox = Instance.new("TextBox")
    nameBox.Parent = mainFrame
    nameBox.Size = UDim2.new(0.9, 0, 0, 30)
    nameBox.Position = UDim2.new(0.05, 0, 0.28, 0)
    nameBox.PlaceholderText = "İsim yaz veya listeden seç"
    nameBox.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
    nameBox.Text = ""
    nameBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    nameBox.TextColor3 = Color3.new(1, 1, 1)
    nameBox.Font = Enum.Font.SourceSans
    nameBox.TextSize = 14
    nameBox.ClearTextOnFocus = false
    nameBox.ZIndex = 3
    
    -- Butonlar
    local teleportButton = Instance.new("TextButton")
    teleportButton.Parent = mainFrame
    teleportButton.Size = UDim2.new(0.28, 0, 0, 30)
    teleportButton.Position = UDim2.new(0.05, 0, 0.37, 0)
    teleportButton.Text = "⚡ TAKİP BAŞLAT"
    teleportButton.BackgroundColor3 = Color3.new(0, 0.6, 0.6)
    teleportButton.TextColor3 = Color3.new(1, 1, 1)
    teleportButton.Font = Enum.Font.SourceSansBold
    teleportButton.TextSize = 12
    teleportButton.BorderSizePixel = 0
    teleportButton.ZIndex = 3
    
    local listButton = Instance.new("TextButton")
    listButton.Parent = mainFrame
    listButton.Size = UDim2.new(0.28, 0, 0, 30)
    listButton.Position = UDim2.new(0.36, 0, 0.37, 0)
    listButton.Text = "👥 LİSTE"
    listButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.8)
    listButton.TextColor3 = Color3.new(1, 1, 1)
    listButton.Font = Enum.Font.SourceSansBold
    listButton.TextSize = 14
    listButton.BorderSizePixel = 0
    listButton.ZIndex = 3
    
    local radarButton = Instance.new("TextButton")
    radarButton.Parent = mainFrame
    radarButton.Size = UDim2.new(0.28, 0, 0, 30)
    radarButton.Position = UDim2.new(0.67, 0, 0.37, 0)
    radarButton.Text = "🔍 RADAR"
    radarButton.BackgroundColor3 = Color3.new(0.5, 0.5, 0)
    radarButton.TextColor3 = Color3.new(1, 1, 1)
    radarButton.Font = Enum.Font.SourceSansBold
    radarButton.TextSize = 14
    radarButton.BorderSizePixel = 0
    radarButton.ZIndex = 3
    
    local stopButton = Instance.new("TextButton")
    stopButton.Parent = mainFrame
    stopButton.Size = UDim2.new(0.28, 0, 0, 30)
    stopButton.Position = UDim2.new(0.05, 0, 0.45, 0)
    stopButton.Text = "🛑 DURDUR"
    stopButton.BackgroundColor3 = Color3.new(0.6, 0, 0)
    stopButton.TextColor3 = Color3.new(1, 1, 1)
    stopButton.Font = Enum.Font.SourceSansBold
    stopButton.TextSize = 14
    stopButton.BorderSizePixel = 0
    stopButton.ZIndex = 3
    
    local autoButton = Instance.new("TextButton")
    autoButton.Parent = mainFrame
    autoButton.Size = UDim2.new(0.28, 0, 0, 30)
    autoButton.Position = UDim2.new(0.36, 0, 0.45, 0)
    autoButton.Text = "🎯 OTO: KAPALI"
    autoButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.2)
    autoButton.TextColor3 = Color3.new(1, 1, 1)
    autoButton.Font = Enum.Font.SourceSansBold
    autoButton.TextSize = 12
    autoButton.BorderSizePixel = 0
    autoButton.ZIndex = 3
    
    local smoothButton = Instance.new("TextButton")
    smoothButton.Parent = mainFrame
    smoothButton.Size = UDim2.new(0.28, 0, 0, 30)
    smoothButton.Position = UDim2.new(0.67, 0, 0.45, 0)
    smoothButton.Text = "🦋 GLIDE: KAPALI"
    smoothButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.4)
    smoothButton.TextColor3 = Color3.new(1, 1, 1)
    smoothButton.Font = Enum.Font.SourceSansBold
    smoothButton.TextSize = 11
    smoothButton.BorderSizePixel = 0
    smoothButton.ZIndex = 3
    
    local effectButton = Instance.new("TextButton")
    effectButton.Parent = mainFrame
    effectButton.Size = UDim2.new(0.28, 0, 0, 30)
    effectButton.Position = UDim2.new(0.05, 0, 0.53, 0)
    effectButton.Text = "✨ Efekt: AÇIK"
    effectButton.BackgroundColor3 = Color3.new(0.5, 0, 0.5)
    effectButton.TextColor3 = Color3.new(1, 1, 1)
    effectButton.Font = Enum.Font.SourceSansBold
    effectButton.TextSize = 12
    effectButton.BorderSizePixel = 0
    effectButton.ZIndex = 3
    
    -- OYUNCU LİSTESİ PANELİ
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Parent = screenGui
    playerListFrame.Size = UDim2.new(0, 300, 0, 450)
    playerListFrame.Position = UDim2.new(0, 400, 0, 10)
    playerListFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    playerListFrame.BackgroundTransparency = 0.1
    playerListFrame.BorderSizePixel = 3
    playerListFrame.BorderColor3 = Color3.new(0, 1, 1)
    playerListFrame.Visible = false
    playerListFrame.Active = true
    playerListFrame.ZIndex = 5
    
    local listTitle = Instance.new("TextLabel")
    listTitle.Parent = playerListFrame
    listTitle.Name = "ListTitle"
    listTitle.Size = UDim2.new(1, 0, 0, 45)
    listTitle.Position = UDim2.new(0, 0, 0, 0)
    listTitle.Text = "👥 OYUNCU LİSTESİ"
    listTitle.TextColor3 = Color3.new(1, 1, 1)
    listTitle.BackgroundColor3 = Color3.new(0, 0.5, 0.5)
    listTitle.Font = Enum.Font.SourceSansBold
    listTitle.TextSize = 22
    listTitle.BorderSizePixel = 0
    listTitle.ZIndex = 6
    
    local closeListBtn = Instance.new("TextButton")
    closeListBtn.Parent = playerListFrame
    closeListBtn.Name = "CloseButton"
    closeListBtn.Size = UDim2.new(0, 45, 0, 45)
    closeListBtn.Position = UDim2.new(1, -45, 0, 0)
    closeListBtn.Text = "X"
    closeListBtn.TextColor3 = Color3.new(1, 1, 1)
    closeListBtn.BackgroundColor3 = Color3.new(0.8, 0, 0)
    closeListBtn.Font = Enum.Font.SourceSansBold
    closeListBtn.TextSize = 24
    closeListBtn.BorderSizePixel = 0
    closeListBtn.ZIndex = 7
    
    closeListBtn.MouseButton1Click:Connect(function()
        playerListFrame.Visible = false
        playerListVisible = false
    end)
    
    return {
        screen = screenGui,
        frame = mainFrame,
        dragBar = dragBar,
        nameBox = nameBox,
        teleportButton = teleportButton,
        stopButton = stopButton,
        listButton = listButton,
        radarButton = radarButton,
        autoButton = autoButton,
        smoothButton = smoothButton,
        effectButton = effectButton,
        targetLabel = targetLabel,
        playerListFrame = playerListFrame
    }
end

-- Manuel sürükleme
local function setupDragging(frame, dragBar)
    if not frame or not dragBar then return end
    
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                frameStart.X.Scale, 
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, 
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
end

-- Karakteri güncelle
local function updateCharacter()
    character = player.Character
    if character then
        humanoid = character:FindFirstChild("Humanoid")
        rootPart = character:FindFirstChild("HumanoidRootPart")
    end
end

-- Hedefi bul
local function findAndFollowTarget(playerName)
    if not gui then return false end
    
    if playerName == "" then
        if autoTarget then
            local nearest = findNearestPlayer()
            if nearest then
                targetPlayer = nearest
                isFollowing = true
                gui.targetLabel.Text = "🎯 Otomatik: " .. nearest.Name
                gui.targetLabel.TextColor3 = Color3.new(0, 1, 0)
                gui.nameBox.Text = nearest.Name
                return true
            else
                gui.targetLabel.Text = "❌ Yakın oyuncu yok!"
                gui.targetLabel.TextColor3 = Color3.new(1, 0, 0)
                return false
            end
        else
            gui.targetLabel.Text = "❌ İsim girin!"
            gui.targetLabel.TextColor3 = Color3.new(1, 0, 0)
            return false
        end
    end
    
    local players = Players:GetPlayers()
    for _, plr in pairs(players) do
        local plrName = plr.Name:lower()
        local plrDisplay = (plr.DisplayName or ""):lower()
        local searchName = playerName:lower()
        
        if plrName:find(searchName) or plrDisplay:find(searchName) then
            targetPlayer = plr
            isFollowing = true
            gui.targetLabel.Text = "🎯 Hedef: " .. plr.Name
            gui.targetLabel.TextColor3 = Color3.new(0, 1, 0)
            gui.nameBox.Text = plr.Name
            return true
        end
    end
    
    gui.targetLabel.Text = "❌ Oyuncu bulunamadı!"
    gui.targetLabel.TextColor3 = Color3.new(1, 0, 0)
    return false
end

-- Takibi durdur
local function stopFollowing()
    isFollowing = false
    targetPlayer = nil
    if gui then
        gui.targetLabel.Text = "Hedef: Yok"
        gui.targetLabel.TextColor3 = Color3.new(1, 1, 0)
    end
    
    pcall(function()
        if camera then
            camera.CameraType = oldCameraType
        end
    end)
end

-- X tuşu ile takip başlat/durdur
local function toggleFollow()
    if isFollowing then
        stopFollowing()
    else
        if gui and gui.nameBox and gui.nameBox.Text ~= "" then
            findAndFollowTarget(gui.nameBox.Text)
        elseif autoTarget then
            findAndFollowTarget("")
        else
            playerListVisible = not playerListVisible
            if gui and gui.playerListFrame then
                gui.playerListFrame.Visible = playerListVisible
                if playerListVisible then
                    updatePlayerList()
                    gui.targetLabel.Text = "📋 Listeden seç"
                    gui.targetLabel.TextColor3 = Color3.new(0, 1, 1)
                end
            end
        end
    end
end

-- Buton güncellemeleri
local function updateEffectButton()
    if not gui then return end
    if teleportEffect then
        gui.effectButton.Text = "✨ Efekt: AÇIK"
        gui.effectButton.BackgroundColor3 = Color3.new(0.5, 0, 0.5)
    else
        gui.effectButton.Text = "💫 Efekt: KAPALI"
        gui.effectButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    end
end

local function updateAutoButton()
    if not gui then return end
    if autoTarget then
        gui.autoButton.Text = "🎯 OTO: AÇIK"
        gui.autoButton.BackgroundColor3 = Color3.new(0, 0.6, 0)
    else
        gui.autoButton.Text = "🎯 OTO: KAPALI"
        gui.autoButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.2)
    end
end

local function updateSmoothButton()
    if not gui then return end
    if smoothEnabled then
        gui.smoothButton.Text = "🦋 GLIDE: AÇIK"
        gui.smoothButton.BackgroundColor3 = Color3.new(0.5, 0, 0.8)
    else
        gui.smoothButton.Text = "🦋 GLIDE: KAPALI"
        gui.smoothButton.BackgroundColor3 = Color3.new(0.4, 0.2, 0.4)
    end
end

-- Hareket döngüsü
task.spawn(function()
    while true do
        task.wait(0.25)
        
        if isFollowing and targetPlayer then
            pcall(function()
                if targetPlayer.Character and humanoid and humanoid.Health > 0 then
                    moveToTarget()
                end
            end)
        end
        
        if autoTarget and not isFollowing then
            local nearest = findNearestPlayer()
            if nearest then
                targetPlayer = nearest
                isFollowing = true
                if gui then
                    gui.targetLabel.Text = "🎯 Otomatik: " .. nearest.Name
                    gui.targetLabel.TextColor3 = Color3.new(0, 1, 0)
                    gui.nameBox.Text = nearest.Name
                end
            end
        end
    end
end)

-- ANA KOD
local setupSuccess = setupCharacter()
if not setupSuccess then
    print("❌ Karakter kurulumu başarısız!")
    return
end

gui = createGUI()
if not gui then 
    print("❌ GUI oluşturulamadı!")
    return 
end

setupDragging(gui.frame, gui.dragBar)
createRadar() -- Gelişmiş radar oluştur

-- Buton eventleri
gui.teleportButton.MouseButton1Click:Connect(function()
    if gui.nameBox then
        findAndFollowTarget(gui.nameBox.Text)
    end
end)

gui.stopButton.MouseButton1Click:Connect(function()
    stopFollowing()
end)

gui.listButton.MouseButton1Click:Connect(function()
    playerListVisible = not playerListVisible
    if gui.playerListFrame then
        gui.playerListFrame.Visible = playerListVisible
        if playerListVisible then
            updatePlayerList()
        end
    end
end)

gui.radarButton.MouseButton1Click:Connect(function()
    radarVisible = not radarVisible
    if gui.radarFrame then
        gui.radarFrame.Visible = radarVisible
    end
end)

gui.autoButton.MouseButton1Click:Connect(function()
    autoTarget = not autoTarget
    updateAutoButton()
    if autoTarget then
        gui.targetLabel.Text = "📡 Otomatik hedefleme açık"
        gui.targetLabel.TextColor3 = Color3.new(0, 1, 1)
    end
end)

gui.smoothButton.MouseButton1Click:Connect(function()
    smoothEnabled = not smoothEnabled
    updateSmoothButton()
end)

gui.effectButton.MouseButton1Click:Connect(function()
    teleportEffect = not teleportEffect
    updateEffectButton()
end)

-- X tuşu
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.X then
        toggleFollow()
    end
    
    if input.KeyCode == Enum.KeyCode.F and 
       (userInputService:IsKeyDown(Enum.KeyCode.LeftControl) or 
        userInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        if gui and gui.frame then
            gui.frame.Visible = not gui.frame.Visible
        end
    end
end)

-- Hedef oyundan çıkarsa
Players.PlayerRemoving:Connect(function(plr)
    if plr == targetPlayer then
        if gui then
            gui.targetLabel.Text = "❌ Hedef çıktı!"
            gui.targetLabel.TextColor3 = Color3.new(1, 0, 0)
        end
        stopFollowing()
    end
end)

-- Karakter değişirse
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    
    pcall(function()
        humanoid = character:WaitForChild("Humanoid", 5)
        rootPart = character:WaitForChild("HumanoidRootPart", 5)
    end)
    
    if humanoid then
        humanoid.Died:Connect(function()
            stopFollowing()
            print("💀 Karakter öldü, takip durduruldu")
        end)
    end
    
    isFollowing = false
    if gui then
        gui.targetLabel.Text = "Hedef: Yok (yeniden doğdun)"
        gui.targetLabel.TextColor3 = Color3.new(1, 1, 0)
    end
end)

updateEffectButton()
updateAutoButton()
updateSmoothButton()

print("✅ ULTIMATE STALKER - 5 STUD!")
print("⚡ X = Takip | 5 stud arkada | Gelişmiş radar")
