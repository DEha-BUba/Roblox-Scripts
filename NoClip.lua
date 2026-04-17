-- TEK SCRIPT - StarterPlayerScripts'e KOYUN
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local noclip = false
local character = player.Character or player.CharacterAdded:Wait()

-- GUI oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoClipGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Buton
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 45)
button.Position = UDim2.new(0, 15, 0, 15)
button.Text = "NoClip: KAPALI (N)"
button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.BorderSizePixel = 0
button.Parent = screenGui

-- Buton köşeleri
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Buton gölge
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 4, 1, 4)
shadow.Position = UDim2.new(0, -2, 0, -2)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.ZIndex = -1
shadow.Parent = button

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 10)
shadowCorner.Parent = shadow

-- Butonu sürükleme
local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- NoClip toggle fonksiyonu
local function toggleNoClip()
    noclip = not noclip
    
    if noclip then
        button.Text = "NoClip: AÇIK (N)"
        button.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        button.Text = "NoClip: KAPALI (N)"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
    
    -- Karakter parçalarını güncelle
    character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclip
                part.CanTouch = not noclip
            end
        end
    end
end

-- N tuşu ile aç/kapa
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
        toggleNoClip()
    end
end)

-- Butona tıklama ile aç/kapa
button.MouseButton1Click:Connect(toggleNoClip)

-- NoClip döngüsü (her frame)
RunService.Stepped:Connect(function()
    character = player.Character
    if character and noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanTouch = false
            end
        end
    end
end)

-- Karakter yeniden doğduğunda
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(0.5) -- Karakterin tam oluşmasını bekle
    if noclip then
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanTouch = false
            end
        end
    end
end)

print("NoClip script yüklendi! N tuşu veya buton ile aç/kapa yapabilirsiniz.")
