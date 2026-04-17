-- StarterPlayerScripts'e LocalScript olarak ekle

-- Güvenli player alma
local player = nil
local mouse = nil

-- Player hazır olana kadar bekle
local function Initialize()
    -- Players servisini al
    local Players = game:GetService("Players")
    
    -- LocalPlayer'ı al (hata kontrolü ile)
    player = Players.LocalPlayer
    
    if not player then
        -- Eğer LocalPlayer yoksa, bekle
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        player = Players.LocalPlayer
    end
    
    if not player then
        warn("Player bulunamadı!")
        return false
    end
    
    -- Mouse'u al
    mouse = player:GetMouse()
    
    if not mouse then
        warn("Mouse bulunamadı!")
        return false
    end
    
    return true
end

-- Teleport fonksiyonu
local function TeleportToMouse()
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local hit = mouse.Target
    local pos = mouse.Hit
    
    if character and humanoid and hit then
        -- Güvenli teleport
        local success, errorMsg = pcall(function()
            character:SetPrimaryPartCFrame(CFrame.new(pos.Position + Vector3.new(0, 3, 0)))
        end)
        
        if not success then
            warn("Teleport başarısız: " .. tostring(errorMsg))
        end
    end
end

-- Scripti başlat
local function StartScript()
    if not Initialize() then
        -- Tekrar dene
        task.wait(1)
        if not Initialize() then
            print("Script başlatılamadı!")
            return
        end
    end
    
    local TweenService = game:GetService("TweenService")
    local isScriptActive = true
    local teleportConnection = nil
    local screenGui = nil
    local closeButton = nil
    local hoverText = nil
    
    -- Tüm temizlik işlemleri
    local function FullCleanup()
        if not isScriptActive then return end
        
        isScriptActive = false
        
        -- Teleport bağlantısını kaldır
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        
        -- GUI'yi temizle
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
            screenGui = nil
        end
        
        print("Teleport script başarıyla kapatıldı ve tamamen temizlendi!")
    end
    
    -- PlayerGui'yi güvenli alma
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        playerGui = Instance.new("ScreenGui")
        playerGui.Name = "PlayerGui"
        playerGui.Parent = player
    end
    
    -- GUI Butonu Oluştur
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportGUI"
    screenGui.ResetOnSpawn = false -- Karakter ölünce yok olmasın
    screenGui.Parent = playerGui
    
    -- Buton
    closeButton = Instance.new("ImageButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BackgroundTransparency = 0.2
    closeButton.BorderSizePixel = 0
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Parent = screenGui
    
    -- Buton efekti
    local function animateButton(button, targetTransparency)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(button, tweenInfo, {BackgroundTransparency = targetTransparency})
        tween:Play()
    end
    
    closeButton.MouseEnter:Connect(function()
        animateButton(closeButton, 0.5)
        if hoverText then hoverText.Visible = true end
    end)
    
    closeButton.MouseLeave:Connect(function()
        animateButton(closeButton, 0.2)
        if hoverText then hoverText.Visible = false end
    end)
    
    -- Hover text
    hoverText = Instance.new("TextLabel")
    hoverText.Size = UDim2.new(0, 120, 0, 30)
    hoverText.Position = UDim2.new(1, -170, 0, 10)
    hoverText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hoverText.BackgroundTransparency = 0.3
    hoverText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hoverText.Text = "Scripti Kapat"
    hoverText.TextScaled = true
    hoverText.Visible = false
    hoverText.Parent = screenGui
    
    -- Butona tıklama
    closeButton.MouseButton1Click:Connect(FullCleanup)
    
    -- Teleport bağlantısını başlat
    teleportConnection = mouse.Button1Down:Connect(TeleportToMouse)
    
    print("Teleport script başarıyla başlatıldı!")
    print("Sol tıklayarak tıkladığınız yere ışınlanabilirsiniz!")
    print("Sağ üstteki kırmızı X butonuna tıklayarak scripti tamamen kapatabilirsiniz")
end

-- Scripti çalıştır
local success, errorMsg = pcall(StartScript)
if not success then
    warn("Script başlatılamadı: " .. tostring(errorMsg))
    
    -- Alternatif başlatma
    task.wait(2)
    pcall(StartScript)
end
