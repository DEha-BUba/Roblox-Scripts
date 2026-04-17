local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local canMove = true
local cooldown = 0

print("For Better Use Open ShiftLock ")

local function moveCharacter(direction)
	if not canMove then return end
	
	local character = player.Character
	if not character or not character.PrimaryPart then return end
	
	local rootPart = character.PrimaryPart
	local moveVector = Vector3.new()
	
	if direction == "forward" then
		moveVector = rootPart.CFrame.LookVector * 10
	elseif direction == "backward" then
		moveVector = -rootPart.CFrame.LookVector * 10
	elseif direction == "right" then
		moveVector = rootPart.CFrame.RightVector * 10
	elseif direction == "left" then
		moveVector = -rootPart.CFrame.RightVector * 10
	end
	
	rootPart.CFrame = rootPart.CFrame + moveVector
	
	-- Cooldown başlat
	canMove = false
	task.wait(cooldown)
	canMove = true
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Sadece ok tuşlarını kontrol et
	if input.KeyCode == Enum.KeyCode.W then
		moveCharacter("forward")
	elseif input.KeyCode == Enum.KeyCode.S then
		moveCharacter("backward")
	elseif input.KeyCode == Enum.KeyCode.D then
		moveCharacter("right")
	elseif input.KeyCode == Enum.KeyCode.A then
		moveCharacter("left")
	end
end)
