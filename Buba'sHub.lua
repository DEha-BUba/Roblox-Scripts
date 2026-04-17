-- 🔴 DEHA'S SCRIPT HUB 🔴
-- Küçültme butonlu versiyon

-- Script listesi (isim ve dosya adı)
local scripts = {
    {name = "🎯 AimBot", file = "AimBot.lua"},
    {name = "🪓 Ball & Axe", file = "Ball%26Axe.lua"},
    {name = "🖱️ ClickTP", file = "ClickTP.lua"},
    {name = "💨 Dash", file = "Dash.lua"},
    {name = "👁️ ESP", file = "ESP.lua"},
    {name = "👻 Ghost", file = "Ghost.lua"},
    {name = "🎯 HumanAim", file = "HumanAim.lua"},
    {name = "🧱 Jenga", file = "Jenga.lua"},
    {name = "🚫 NoClip", file = "NoClip.lua"},
    {name = "⚡ Optimization", file = "Optimization.lua"},
    {name = "👀 Stalk", file = "Stalk.lua"},
    {name = "🌀 Teleport", file = "Telelport.lua"},
    {name = "🕊️ Fly", file = "fly.lua"},
}

-- GitHub RAW ana linki
local githubBase = "https://raw.githubusercontent.com/DEha-BUba/Roblox-Scripts/main/"

-- GUI Oluşturma
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DehasScriptHub"
screenGui.Parent = player.PlayerGui

-- Ana Pencere (Frame)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 550)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(180, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Küçültme durumu için değişken
local isMinimized = false
local originalSize = mainFrame.Size
local originalScrollVisible = true

-- Köşe yuvarlama
local corners = Instance.new("UICorner")
corners.CornerRadius = UDim.new(0, 8)
corners.Parent = mainFrame

-- Başlık Çubuğu
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorners = Instance.new("UICorner")
titleCorners.CornerRadius = UDim.new(0, 8)
titleCorners.Parent = titleBar

-- Başlık Yazısı
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -90, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔴 DEHA'S SCRIPT HUB"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Küçültme Butonu (➖)
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 40, 1, 0)
minimizeButton.Position = UDim2.new(1, -45, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
minimizeButton.Text = "➖"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 22
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

local minimizeCorners = Instance.new("UICorner")
minimizeCorners.CornerRadius = UDim.new(0, 8)
minimizeCorners.Parent = minimizeButton

-- Kaydırmalı Alan (ScrollingFrame)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScriptList"
scrollFrame.Size = UDim2.new(1, -20, 1, -80)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
scrollFrame.BackgroundTransparency = 0.3
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
scrollFrame.Parent = mainFrame

local scrollCorners = Instance.new("UICorner")
scrollCorners.CornerRadius = UDim.new(0, 6)
scrollCorners.Parent = scrollFrame

-- Butonları düzenlemek için UIListLayout
local listLayout = Instance.new("UIListLayout")
listLayout.Name = "ButtonLayout"
listLayout.Padding = UDim.new(0, 8)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = scrollFrame

-- Alt Bilgi (Footer)
local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.Size = UDim2.new(1, 0, 0, 25)
footer.Position = UDim2.new(0, 0, 1, -25)
footer.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
footer.BackgroundTransparency = 0.5
footer.Text = "DEHA'S HUB | Tıkla ve Çalıştır"
footer.TextColor3 = Color3.fromRGB(200, 200, 200)
footer.TextSize = 11
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.BorderSizePixel = 0
footer.Parent = mainFrame

local footerCorners = Instance.new("UICorner")
footerCorners.CornerRadius = UDim.new(0, 6)
footerCorners.Parent = footer

-- Küçültme butonu hover efekti
minimizeButton.MouseEnter:Connect(function()
    minimizeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
end)
minimizeButton.MouseLeave:Connect(function()
    minimizeButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end)

-- Küçültme/Büyütme işlevi
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- KÜÇÜLT
        mainFrame.Size = UDim2.new(0, 450, 0, 40)
        scrollFrame.Visible = false
        footer.Visible = false
        minimizeButton.Text = "🗖"  -- Büyütme ikonu
        titleLabel.Text = "🔴 DEHA'S HUB [KÜÇÜLTÜLDÜ]"
    else
        -- BÜYÜT (eski haline döndür)
        mainFrame.Size = UDim2.new(0, 450, 0, 550)
        scrollFrame.Visible = true
        footer.Visible = true
        minimizeButton.Text = "➖"  -- Küçültme ikonu
        titleLabel.Text = "🔴 DEHA'S SCRIPT HUB"
    end
end)

-- Buton oluşturma
local function createScriptButton(scriptName, fileName)
    local button = Instance.new("TextButton")
    button.Name = fileName:gsub("%.lua", "") .. "Button"
    button.Size = UDim2.new(0.95, 0, 0, 45)
    button.Position = UDim2.new(0.025, 0, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    button.Text = scriptName
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamSemibold
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(180, 0, 0)
    button.Parent = scrollFrame
    
    -- Buton köşe yuvarlama
    local btnCorners = Instance.new("UICorner")
    btnCorners.CornerRadius = UDim.new(0, 6)
    btnCorners.Parent = button
    
    -- Hover efektleri
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
        button.TextSize = 17
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        button.TextSize = 16
    end)
    
    -- Tıklama işlevi (DÜZELTİLDİ - Gerçekten indiriyor)
    button.MouseButton1Click:Connect(function()
        local url = githubBase .. fileName
        local originalText = button.Text
        
        -- İndirme durumunu göster
        button.Text = "📥 İNDİRİLİYOR..."
        button.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        button.TextSize = 14
        
        -- İndirme işlemini dene
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and result then
            -- İndirme başarılı
            button.Text = "⚙️ ÇALIŞTIRILIYOR..."
            task.wait(0.2)
            
            -- Scripti çalıştır
            local func, loadErr = loadstring(result)
            if func then
                local execSuccess, execErr = pcall(function()
                    func()
                end)
                if execSuccess then
                    button.Text = "✅ ÇALIŞTI!"
                    button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                else
                    button.Text = "❌ HATA: " .. tostring(execErr):sub(1, 25)
                    button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
                end
            else
                button.Text = "❌ YÜKLEME HATASI"
                button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            end
            
            -- 1.5 saniye sonra eski haline dön
            task.wait(1.5)
            button.Text = originalText
            button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
            button.TextSize = 16
            
        else
            -- İndirme başarısız
            button.Text = "❌ İNDİRME HATASI!"
            button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            print("Hata: " .. tostring(result))
            
            task.wait(1.5)
            button.Text = originalText
            button.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
            button.TextSize = 16
        end
    end)
    
    return button
end

-- Tüm butonları oluştur
for _, scriptInfo in ipairs(scripts) do
    createScriptButton(scriptInfo.name, scriptInfo.file)
end

-- Canvas boyutunu güncelle (kaydırma için)
local function updateCanvasSize()
    local totalHeight = listLayout.AbsoluteContentSize.Y
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 10)
end

-- Layout değiştiğinde canvas boyutunu güncelle
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
task.wait(0.1)
updateCanvasSize()

print("🔴Buba's HUB başarıyla yüklendi!")
