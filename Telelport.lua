local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- GUI'yi oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Arkaplan (Ana çerçeve)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Gölge efekti
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame

-- Başlık çubuğu
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ TELEPORT HACK ⚡"
titleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.Parent = titleBar

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- İçerik
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -40)
contentFrame.Position = UDim2.new(0, 10, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Hedef oyuncu seçim etiketi
local targetLabel = Instance.new("TextLabel")
targetLabel.Name = "TargetLabel"
targetLabel.Size = UDim2.new(1, 0, 0, 25)
targetLabel.Position = UDim2.new(0, 0, 0, 0)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Hedef Oyuncu:"
targetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextSize = 14
targetLabel.TextXAlignment = Enum.TextXAlignment.Left
targetLabel.Parent = contentFrame

-- Oyuncu listesi açılır menü
local playerListButton = Instance.new("TextButton")
playerListButton.Name = "PlayerListButton"
playerListButton.Size = UDim2.new(0.8, -5, 0, 30)
playerListButton.Position = UDim2.new(0, 0, 0, 30)
playerListButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playerListButton.Text = "Oyuncu Listesini Göster"
playerListButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playerListButton.Font = Enum.Font.Gotham
playerListButton.TextSize = 12
playerListButton.Parent = contentFrame

-- Seçili oyuncu göstergesi
local selectedPlayerLabel = Instance.new("TextLabel")
selectedPlayerLabel.Name = "SelectedPlayerLabel"
selectedPlayerLabel.Size = UDim2.new(1, 0, 0, 25)
selectedPlayerLabel.Position = UDim2.new(0, 0, 0, 65)
selectedPlayerLabel.BackgroundTransparency = 1
selectedPlayerLabel.Text = "Seçili: Yok"
selectedPlayerLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
selectedPlayerLabel.Font = Enum.Font.Gotham
selectedPlayerLabel.TextSize = 12
selectedPlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
selectedPlayerLabel.Parent = contentFrame

-- Oyuncu listesi frame'i
local playerListFrame = Instance.new("ScrollingFrame")
playerListFrame.Name = "PlayerListFrame"
playerListFrame.Size = UDim2.new(1, 0, 0, 150)
playerListFrame.Position = UDim2.new(0, 0, 0, 95)
playerListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
playerListFrame.BorderSizePixel = 0
playerListFrame.Visible = false
playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
playerListFrame.ScrollBarThickness = 5
playerListFrame.Parent = contentFrame

-- Teleport hızı ayarı
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 250)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Işınlanma Hızı: 10x/saniye"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = contentFrame

-- Açma/Kapama butonu
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.8, -5, 0, 35)
toggleButton.Position = UDim2.new(0, 0, 0, 280)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
toggleButton.Text = "BAŞLAT"
toggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 14
toggleButton.Parent = contentFrame

-- Bilgi etiketi
local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "InfoLabel"
infoLabel.Size = UDim2.new(1, 0, 0, 20)
infoLabel.Position = UDim2.new(0, 0, 0, 320)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Durum: Bekleniyor..."
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.Parent = contentFrame

-- Değişkenler
local isTeleporting = false
local targetPlayer = nil
local teleportConnection = nil

-- Oyuncu listesini güncelle
local function updatePlayerList()
    playerListFrame:ClearAllChildren()
    local yOffset = 0
    
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player then
            local playerButton = Instance.new("TextButton")
            playerButton.Name = otherPlayer.Name
            playerButton.Size = UDim2.new(1, -10, 0, 25)
            playerButton.Position = UDim2.new(0, 5, 0, yOffset)
            playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            playerButton.Text = otherPlayer.Name .. " (" .. tostring(#otherPlayer.Character:GetChildren()) .. " parça)"
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.Font = Enum.Font.Gotham
            playerButton.TextSize = 11
            playerButton.Parent = playerListFrame
            
            playerButton.MouseEnter:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            playerButton.MouseLeave:Connect(function()
                playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end)
            
            playerButton.MouseButton1Click:Connect(function()
                targetPlayer = otherPlayer
                selectedPlayerLabel.Text = "Seçili: " .. otherPlayer.Name
                playerListFrame.Visible = false
                infoLabel.Text = "Durum: Hedef seçildi - " .. otherPlayer.Name
                
                -- Eğer teleport açıksa hemen yeni hedefe başla
                if isTeleporting then
                    isTeleporting = false
                    wait(0.1)
                    isTeleporting = true
                end
            end)
            
            yOffset = yOffset + 27
        end
    end
    
    playerListFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Oyuncu listesi butonu
playerListButton.MouseButton1Click:Connect(function()
    updatePlayerList()
    playerListFrame.Visible = not playerListFrame.Visible
end)

-- Teleport fonksiyonu
local function teleportToTarget()
    if not targetPlayer or not targetPlayer.Character then
        infoLabel.Text = "Durum: Hedef oyuncu bulunamadı!"
        return
    end
    
    local character = player.Character
    local targetChar = targetPlayer.Character
    
    if character and targetChar and character:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart") then
        -- Efekt için hafif titreme
        local myRoot = character.HumanoidRootPart
        local targetRoot = targetChar.HumanoidRootPart
        
        -- Işınlanma efekti (opsiyonel)
        spawn(function()
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
        end)
    end
end

-- Başlat/Durdur butonu
toggleButton.MouseButton1Click:Connect(function()
    if not targetPlayer then
        infoLabel.Text = "Durum: Lütfen önce bir hedef seçin!"
        return
    end
    
    isTeleporting = not isTeleporting
    
    if isTeleporting then
        toggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        toggleButton.Text = "DURDUR"
        infoLabel.Text = "Durum: Işınlanıyor (10x/saniye) - Hedef: " .. targetPlayer.Name
        
        -- Teleport döngüsü
        teleportConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if isTeleporting and targetPlayer and targetPlayer.Character then
                teleportToTarget()
                wait(0.1) -- Saniyede 10 kez için 0.1 saniye bekle
            end
        end)
    else
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        toggleButton.Text = "BAŞLAT"
        infoLabel.Text = "Durum: Durduruldu - Hedef: " .. (targetPlayer and targetPlayer.Name or "Yok")
    end
end)

-- Oyuncu eklenince listeyi güncelle
game.Players.PlayerAdded:Connect(function()
    if playerListFrame.Visible then
        updatePlayerList()
    end
end)

-- Oyuncu çıkınca listeyi güncelle
game.Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == targetPlayer then
        targetPlayer = nil
        selectedPlayerLabel.Text = "Seçili: Yok"
        if isTeleporting then
            isTeleporting = false
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            toggleButton.Text = "BAŞLAT"
        end
        infoLabel.Text = "Durum: Hedef oyuncu ayrıldı!"
    end
    
    if playerListFrame.Visible then
        updatePlayerList()
    end
end)

-- Animasyon ekle (başlangıçta)
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 0, 0, 0)

TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
    BackgroundTransparency = 0.1,
    Size = UDim2.new(0, 300, 0, 250)
}):Play()
