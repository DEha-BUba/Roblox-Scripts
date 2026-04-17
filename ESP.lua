-- Gelişmiş ESP Scripti - BEYAZ RENK (3 Kademeli Mesafe Sistemi)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace

-- ESP ayarları
local settings = {
    enabled = true,
    showBox = true,           
    showSkeleton = true,      
    showHealth = true,        
    showName = true,          
    showDistance = true,      
    showTracer = true,        
    
    -- TÜM RENKLER BEYAZ (duvar önü/arkası fark etmez)
    boxColor = Color3.new(1, 1, 1),           -- Beyaz
    boxColorBehindWall = Color3.new(1, 1, 1), -- Beyaz
    skeletonColor = Color3.new(1, 1, 1),      -- Beyaz
    skeletonColorBehindWall = Color3.new(1, 1, 1), -- Beyaz
    textColor = Color3.new(1, 1, 1),          -- Beyaz
    textColorBehindWall = Color3.new(1, 1, 1), -- Beyaz
    tracerColor = Color3.new(1, 1, 1),        -- Beyaz
    tracerColorBehindWall = Color3.new(1, 1, 1), -- Beyaz
    
    healthBarColor = Color3.new(0, 1, 0),     -- Can barı yeşil (isteğe bağlı)
    
    -- MESAFE KADEMELERİ
    closeDistance = 250,       -- 0-250: Herşey dahil
    mediumDistance = 500,      -- 250-500: Sadece renk (isim, can, kutu)
    -- 500+: Hiçbirşey
    
    tracerThickness = 2,      
    skeletonThickness = 2,
    updateInterval = 0.03
}

-- ESP objelerini tutacak tablo
local espObjects = {}
local raycastParams = RaycastParams.new()
local lastUpdate = 0

-- Kemik bağlantıları
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

-- Raycast parametrelerini ayarla
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- Duvar arkası kontrolü (renk değişmeyecek ama yine de hesapla)
local function isBehindWall(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then
        return false
    end
    
    local cameraPosition = Camera.CFrame.Position
    local direction = (targetPosition - cameraPosition).Unit
    local distance = (cameraPosition - targetPosition).Magnitude
    
    raycastParams.FilterDescendantsInstances = {character, Camera, LocalPlayer.Character}
    
    local raycastResult = Workspace:Raycast(cameraPosition, direction * distance, raycastParams)
    return raycastResult ~= nil
end

-- 2D çizgi çizme fonksiyonu
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

-- Highlight objesi oluştur
local function createHighlight(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = settings.boxColor  -- Beyaz
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = settings.boxColor  -- Beyaz
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    return highlight
end

-- BillboardGui oluştur
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
    nameLabel.TextColor3 = settings.textColor  -- Beyaz
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
    healthFill.BackgroundColor3 = settings.healthBarColor  -- Yeşil
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBar
    
    healthText.Size = UDim2.new(1, 0, 0.2, 0)
    healthText.Position = UDim2.new(0, 0, 0.5, 0)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Color3.new(1, 1, 1)  -- Beyaz
    healthText.TextScaled = true
    healthText.Font = Enum.Font.SourceSansBold
    healthText.Parent = mainFrame
    
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.7, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = settings.textColor  -- Beyaz
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.SourceSansBold
    distanceLabel.Parent = mainFrame
    
    billboard.Parent = player.Character:FindFirstChild("Head")
    
    return {
        billboard = billboard,
        nameLabel = nameLabel,
        healthFill = healthFill,
        healthText = healthText,
        distanceLabel = distanceLabel
    }
end

-- İskelet çizgileri oluştur
local function createSkeletonLines()
    local lines = {}
    for i = 1, #boneConnections do
        lines[i] = createLine(settings.skeletonColor, settings.skeletonThickness)  -- Beyaz
    end
    return lines
end

-- Tracer çizgisi oluştur
local function createTracer()
    return createLine(settings.tracerColor, settings.tracerThickness)  -- Beyaz
end

-- 3D'den 2D'ye çevir
local function worldToScreen(position)
    local screenPoint = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), screenPoint.Z > 0
end

-- Mesafe hesapla
local function getDistanceFromPlayer(targetPosition)
    local character = LocalPlayer.Character
    if not character then return math.huge end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end
    
    return (rootPart.Position - targetPosition).Magnitude
end

-- Renkleri güncelle (ARTIK HEP BEYAZ)
local function updateColorsForWallState(objects, isBehind)
    -- TÜM RENKLER HEP BEYAZ (duvar arkası kontrolü YAPMA)
    if objects.highlight then
        objects.highlight.FillColor = settings.boxColor  -- Beyaz
        objects.highlight.OutlineColor = settings.boxColor  -- Beyaz
    end
    
    if objects.skeletonLines then
        for _, line in ipairs(objects.skeletonLines) do
            line.Color = settings.skeletonColor  -- Beyaz
        end
    end
    
    if objects.tracer then
        objects.tracer.Color = settings.tracerColor  -- Beyaz
    end
    
    if objects.billboardData then
        objects.billboardData.nameLabel.TextColor3 = settings.textColor  -- Beyaz
        objects.billboardData.distanceLabel.TextColor3 = settings.textColor  -- Beyaz
    end
end

-- Oyuncu eklendiğinde
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
        
        task.wait(0.3)
        
        local highlight = createHighlight(player)
        local billboardData = createBillboard(player)
        local skeletonLines = createSkeletonLines()
        local tracer = createTracer()
        
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

-- Oyuncu ayrıldığında
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

-- İskelet güncelleme
local function updateSkeleton(objects, distance, zone)
    if not settings.showSkeleton or zone ~= "close" then
        if objects.skeletonLines then
            for _, line in ipairs(objects.skeletonLines) do
                line.Visible = false
            end
        end
        return
    end
    
    local character = objects.character
    for i, bones in ipairs(boneConnections) do
        local part1 = character:FindFirstChild(bones[1])
        local part2 = character:FindFirstChild(bones[2])
        
        if part1 and part2 then
            local pos1, onScreen1 = worldToScreen(part1.Position)
            local pos2, onScreen2 = worldToScreen(part2.Position)
            
            if onScreen1 and onScreen2 then
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

-- Tracer güncelleme
local function updateTracer(objects, distance, zone)
    if not settings.showTracer or zone ~= "close" then
        if objects.tracer then
            objects.tracer.Visible = false
        end
        return
    end
    
    local character = objects.character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        local screenPos, onScreen = worldToScreen(rootPart.Position)
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        
        if onScreen then
            objects.tracer.From = screenCenter
            objects.tracer.To = screenPos
            objects.tracer.Visible = true
        else
            objects.tracer.Visible = false
        end
    end
end

-- Billboard güncelleme
local function updateBillboard(player, objects, distance, humanoid, head, zone)
    if not objects.billboardData or not head then
        if objects.billboardData then
            objects.billboardData.billboard.Enabled = false
        end
        return
    end
    
    local billboardData = objects.billboardData
    
    if zone == "far" then
        billboardData.billboard.Enabled = false
        return
    end
    
    if zone == "medium" then
        billboardData.billboard.Enabled = true
        billboardData.billboard.Parent = head
        
        if settings.showName then
            billboardData.nameLabel.Visible = true
            billboardData.nameLabel.Text = player.Name
        else
            billboardData.nameLabel.Visible = false
        end
        
        if settings.showHealth and humanoid then
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
        end
        
        billboardData.distanceLabel.Visible = false
        return
    end
    
    if zone == "close" then
        billboardData.billboard.Enabled = true
        billboardData.billboard.Parent = head
        
        if settings.showName then
            billboardData.nameLabel.Visible = true
            billboardData.nameLabel.Text = player.Name
        else
            billboardData.nameLabel.Visible = false
        end
        
        if settings.showHealth and humanoid then
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
        end
        
        if settings.showDistance then
            billboardData.distanceLabel.Visible = true
            billboardData.distanceLabel.Text = string.format("%.1f stud", distance)
        else
            billboardData.distanceLabel.Visible = false
        end
    end
end

-- Mesafe bölgesini belirle
local function getDistanceZone(distance)
    if distance <= settings.closeDistance then
        return "close"      -- 0-250: Her şey dahil
    elseif distance <= settings.mediumDistance then
        return "medium"     -- 250-500: Sadece isim, can, kutu
    else
        return "far"        -- 500+: Hiçbir şey
    end
end

-- Ana güncelleme
local function updateESP()
    if not settings.enabled then return end
    
    local currentTime = tick()
    if currentTime - lastUpdate < settings.updateInterval then
        return
    end
    lastUpdate = currentTime
    
    for player, objects in pairs(espObjects) do
        if not (player and objects.character and objects.character.Parent) then
            continue
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
            continue
        end
        
        local distance = getDistanceFromPlayer(rootPart.Position)
        local zone = getDistanceZone(distance)
        
        -- 500+ ise HİÇBİR ŞEY GÖSTERME
        if zone == "far" then
            if objects.highlight then objects.highlight.Enabled = false end
            if objects.skeletonLines then
                for _, line in ipairs(objects.skeletonLines) do line.Visible = false end
            end
            if objects.tracer then objects.tracer.Visible = false end
            if objects.billboardData then objects.billboardData.billboard.Enabled = false end
            continue
        end
        
        -- Renkleri BEYAZ yap (duvar arkası fark etmez)
        local behindWall = isBehindWall(rootPart.Position)  -- Hesapla ama kullanma
        updateColorsForWallState(objects, false)  -- Renk hep beyaz
        
        -- Kutu göster (her zaman beyaz)
        if objects.highlight then
            objects.highlight.Enabled = settings.showBox and (zone == "close" or zone == "medium")
        end
        
        -- 250-500 arası: İskelet ve tracer YOK
        if zone == "medium" then
            if objects.skeletonLines then
                for _, line in ipairs(objects.skeletonLines) do
                    line.Visible = false
                end
            end
            
            if objects.tracer then
                objects.tracer.Visible = false
            end
        end
        
        -- 0-250 arası: Her şey dahil
        if zone == "close" then
            updateSkeleton(objects, distance, zone)
            updateTracer(objects, distance, zone)
        end
        
        -- Billboard güncelle
        updateBillboard(player, objects, distance, humanoid, head, zone)
    end
end

-- Klavye kontrolü
local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        settings.showBox = not settings.showBox
        print("Kutu: " .. tostring(settings.showBox))
    elseif input.KeyCode == Enum.KeyCode.F3 then
        settings.showSkeleton = not settings.showSkeleton
        print("İskelet: " .. tostring(settings.showSkeleton))
    elseif input.KeyCode == Enum.KeyCode.F4 then
        settings.showHealth = not settings.showHealth
        print("Can: " .. tostring(settings.showHealth))
    elseif input.KeyCode == Enum.KeyCode.F5 then
        settings.showTracer = not settings.showTracer
        print("Çizgi: " .. tostring(settings.showTracer))
    end
end

-- Başlangıç
local function setupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(function() onPlayerAdded(player) end)
    end
    
    Players.PlayerAdded:Connect(function(player)
        task.spawn(function() onPlayerAdded(player) end)
    end)
    
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    UserInputService.InputBegan:Connect(onInputBegan)
    
    RunService.RenderStepped:Connect(updateESP)
    
    print("=== GELİŞMİŞ ESP BAŞLATILDI ===")
    print("RENK: TÜM ELEMENTLER BEYAZ")
    print("")
    print("MESAFE KADEMELERİ:")
    print("  • 0-250 stud: HER ŞEY DAHİL")
    print("    - Beyaz kutu, beyaz iskelet, beyaz tracer")
    print("    - İsim, can, mesafe")
    print("")
    print("  • 250-500 stud: SADECE RENK")
    print("    - Beyaz kutu")
    print("    - İsim ve can (mesafe yok)")
    print("    - İskelet ve tracer YOK")
    print("")
    print("  • 500+ stud: HİÇBİR ŞEY YOK")
    print("")
    print("KONTROLLER: F2=Kutu | F3=İskelet | F4=Can | F5=Çizgi")
end

setupESP()
