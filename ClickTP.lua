-- StarterPlayerScripts'e LocalScript olarak ekle
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

mouse.Button1Down:Connect(function()
	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	local hit = mouse.Target
	local pos = mouse.Hit
	
	if character and humanoid and hit then
		character:SetPrimaryPartCFrame(CFrame.new(pos.Position + Vector3.new(0, 3, 0)))
	end
end)
