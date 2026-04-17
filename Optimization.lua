--[[
      UOS(Universal Optimization Script) Boot
      Credits: Breezipsettings!(me)
      If you Found Any Error/Bugs, Find me at: https://scriptblox.com/u/breezipsettings
]]

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

--// SOUND ENGINE
local function PlayWinSound(id, customVol)
    local s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(id)
    s.Parent = SoundService
    s.Volume = customVol or 0.5
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

--// AUTO-START SOUND
PlayWinSound("98842022139488", 0.25)

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local GlassEffect = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local LogLabel = Instance.new("TextLabel")
local StartButton = Instance.new("TextButton")
local ProgressBarBackground = Instance.new("Frame")
local ProgressBarFill = Instance.new("Frame")
local VersionLabel = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local UIStroke = Instance.new("UIStroke")
local UIScale = Instance.new("UIScale")

--// ANTI-DETECTION: RANDOMIZED IDENTITY
ScreenGui.Name = "UOS_" .. math.random(100000, 999999)
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

--// Scaling
UIScale.Parent = MainFrame
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    UIScale.Scale = 1.25
else
    UIScale.Scale = 1.05
end

MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(120, 160, 200)
MainFrame.BackgroundTransparency = 0.4
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 260, 0, 175)
MainFrame.Active = true
MainFrame.Selectable = true

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Transparency = 0.4
UIStroke.Parent = MainFrame

GlassEffect.Name = "InnerGlass"
GlassEffect.Parent = MainFrame
GlassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassEffect.BackgroundTransparency = 0.8
GlassEffect.Position = UDim2.new(0, 5, 0, 5)
GlassEffect.Size = UDim2.new(1, -10, 1, -10)

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 8)
InnerCorner.Parent = GlassEffect

UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 220, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 140, 180))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 8)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "UOS Sentinel - Aero"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 0, 0, 38)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Font = Enum.Font.SourceSansItalic
Status.Text = "Ready to Boot"
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 15

LogLabel.Name = "Log"
LogLabel.Parent = MainFrame
LogLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LogLabel.BackgroundTransparency = 0.9
LogLabel.Position = UDim2.new(0, 15, 0, 65)
LogLabel.Size = UDim2.new(1, -30, 0, 50)
LogLabel.Font = Enum.Font.Code
LogLabel.Text = "Waiting for user..."
LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogLabel.TextSize = 12
LogLabel.TextWrapped = true
LogLabel.TextXAlignment = Enum.TextXAlignment.Left

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 5)
LogCorner.Parent = LogLabel

--// PROGRESS BAR
ProgressBarBackground.Name = "ProgressBG"
ProgressBarBackground.Parent = MainFrame
ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ProgressBarBackground.BackgroundTransparency = 0.7
ProgressBarBackground.Position = UDim2.new(0, 15, 0, 120)
ProgressBarBackground.Size = UDim2.new(1, -30, 0, 8)
ProgressBarBackground.Visible = false

local PBGCorner = Instance.new("UICorner")
PBGCorner.CornerRadius = UDim.new(1, 0)
PBGCorner.Parent = ProgressBarBackground

ProgressBarFill.Name = "ProgressFill"
ProgressBarFill.Parent = ProgressBarBackground
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)

local PFillCorner = Instance.new("UICorner")
PFillCorner.CornerRadius = UDim.new(1, 0)
PFillCorner.Parent = ProgressBarFill

--// START BUTTON
StartButton.Name = "StartButton"
StartButton.Parent = MainFrame
StartButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
StartButton.Position = UDim2.new(0.5, -45, 0, 130)
StartButton.Size = UDim2.new(0, 90, 0, 30)
StartButton.Font = Enum.Font.SourceSansBold
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.TextSize = 16

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = StartButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1.5
ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
ButtonStroke.Transparency = 0.5
ButtonStroke.Parent = StartButton

--// VERSION INFO
VersionLabel.Name = "Version"
VersionLabel.Parent = MainFrame
VersionLabel.BackgroundTransparency = 1
VersionLabel.Position = UDim2.new(0, 0, 1, -18)
VersionLabel.Size = UDim2.new(1, -8, 0, 12)
VersionLabel.Font = Enum.Font.SourceSans
VersionLabel.Text = "Build 7601: Service Pack 1"
VersionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
VersionLabel.TextSize = 10
VersionLabel.TextTransparency = 0.5
VersionLabel.TextXAlignment = Enum.TextXAlignment.Right

--// DRAGGABLE LOGIC
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

--// DETECTION ENGINE
local function GetTargetProfile()
    local Device = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and "Mobile" or "PC"
    LogLabel.Text = "> Device: " .. Device
    ProgressBarBackground.Visible = true
    
    ProgressBarFill:TweenSize(UDim2.new(0.1, 0, 1, 0), "Out", "Linear", 1)
    task.wait(2) 

    Status.Text = "Scanning..."
    PlayWinSound("103595694345761", 0.03)   
    LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogLabel.Text = "> Analyzing system architecture..."
    ProgressBarFill:TweenSize(UDim2.new(0.3, 0, 1, 0), "Out", "Linear", 1.5)
    task.wait(1.5)
    
    LogLabel.Text = "> Checking Adonis Assets"
    ProgressBarFill:TweenSize(UDim2.new(0.5, 0, 1, 0), "Out", "Linear", 1)
    task.wait(1.0)
    if ReplicatedStorage:FindFirstChild("Adonis_Client") or Workspace:FindFirstChild("Adonis_Vars") or game:GetService("JointsService"):FindFirstChild("Adonis_Control") or ReplicatedStorage:FindFirstChild("Adonis") then
        LogLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        LogLabel.Text = "> Found: Adonis [" .. Device .. "]"
        ProgressBarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0.8)
        task.wait(0.8)
        return "Adonis"
    else
        LogLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
        LogLabel.Text = "> Adonis Not Found"
    end
    task.wait(1.2)

    LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogLabel.Text = "> Checking Kohl's Assets"
    ProgressBarFill:TweenSize(UDim2.new(0.7, 0, 1, 0), "Out", "Linear", 1)
    task.wait(1.0)
    if Workspace:FindFirstChild("Admin") or Workspace:FindFirstChild("Kohl's Admin") or Workspace:FindFirstChild("Kohls Admin") or Workspace:FindFirstChild("Kohl's") or ReplicatedStorage:FindFirstChild("Kohl's Admin") then
        LogLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        LogLabel.Text = "> Found: Kohl's Admin [" .. Device .. "]"
        ProgressBarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0.8)
        task.wait(0.8)
        return "Kohls Admin"
    else
        LogLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
        LogLabel.Text = "> Kohl's Not Found"
    end
    task.wait(1.2)

    LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogLabel.Text = "> Checking Cmdr Assets"
    ProgressBarFill:TweenSize(UDim2.new(0.9, 0, 1, 0), "Out", "Linear", 1)
    task.wait(1.0)
    if ReplicatedStorage:FindFirstChild("Cmdr") or LocalPlayer.PlayerGui:FindFirstChild("Cmdr") or ReplicatedStorage:FindFirstChild("CmdrClient") then
        LogLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
        LogLabel.Text = "> Found: Cmdr [" .. Device .. "]"
        ProgressBarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 0.8)
        task.wait(0.8)
        return "Cmdr"
    else
        LogLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
        LogLabel.Text = "> Cmdr Not Found"
    end
    task.wait(1.2)

    LogLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    LogLabel.Text = "> Finalizing Universal [" .. Device .. "]"
    ProgressBarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 1)
    task.wait(1.0)
    return "Universal Optimization"
end

--// BOOT ENGINE
local function BootUOS()
    StartButton.Visible = false
    PlayWinSound("122470643673099", 0.15)

    task.spawn(function()
        local ProfileName = GetTargetProfile()
        Status.Text = "Loading: " .. ProfileName
        
        StarterGui:SetCore("SendNotification", {
            Title = "Scanned Completed.",
            Text = "Loading... " .. ProfileName,
            Duration = 10
        })

        local function TryLoad(url, name)
            local success, result = pcall(function() return game:HttpGet(url) end)
            if success and result then
                pcall(function()
                    loadstring(result)()
                end)
                
                task.wait(3)
                --// FINAL NOTIFICATIONS :DDD
                StarterGui:SetCore("SendNotification", {
                    Title = "UOS Sentinel",
                    Text = "Successfully Loaded Profile: " .. name,
                    Duration = 15
                })
                
                task.wait(2)
                
                StarterGui:SetCore("SendNotification", {
                    Title = "Script loaded enjoy!",
                    Text = "Credits to Breezipsettings",
                    Duration = 15
                })
                
                LogLabel.TextColor3 = Color3.fromRGB(150, 255, 255)
                LogLabel.Text = "> LOADED: " .. name
                return true
            else
                PlayWinSound("96628258513206", 0.2)
                LogLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                LogLabel.Text = "> ERROR: HTTP Fail. Retrying..."
                return false
            end
        end

        local loaded = false
        if ProfileName == "Universal Optimization" then
            loaded = TryLoad("https://pastebin.com/raw/UYxUJ081", "Universal")
            if not loaded then
                task.wait(1.5)
                loaded = TryLoad("https://pastebin.com/raw/0vzxh67w", "Adonis Fallback")
            end
        elseif ProfileName == "Adonis" then
            loaded = TryLoad("https://pastebin.com/raw/0vzxh67w", "Adonis")
        elseif ProfileName == "Kohls Admin" then
            loaded = TryLoad("https://pastebin.com/raw/aXvK3WRk", "Kohl's Admin")
        elseif ProfileName == "Cmdr" then
            loaded = TryLoad("https://pastebin.com/raw/R1bH2Ubs", "Cmdr")
        end
        
        if loaded then
            task.wait(1.5)
            ScreenGui:Destroy()
        else
            PlayWinSound("124716807908907", 0.25)
            Status.Text = "BOOT FAILED"
            task.wait(3)
            ScreenGui:Destroy()
        end
    end)
end

--// INITIALIZE
StartButton.MouseButton1Click:Connect(function()
    pcall(BootUOS)
end)
