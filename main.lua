local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClawRemote = Instance.new("RemoteEvent") 
ClawRemote.Name = "ClawRemote"
ClawRemote.Parent = ReplicatedStorage

-- CONFIG
local MACHINE = workspace:WaitForChild("ClawMachine")
local CLAW = MACHINE:WaitForChild("MainPart")
local PRIZE_FOLDER = MACHINE:WaitForChild("Prizes")
local DROP_BIN = Vector3.new(15, CLAW.Position.Y, 15) -- CHANGE THIS to your hole's position

local IsBusy = false

local function getBestPrize()
	local target = nil
	local closestDist = math.huge
	
	for _, item in pairs(PRIZE_FOLDER:GetChildren()) do
		local p = item:IsA("BasePart") and item or item.PrimaryPart
		if p and p:IsA("BasePart") then
			local dist = (Vector2.new(CLAW.Position.X, CLAW.Position.Z) - Vector2.new(p.Position.X, p.Position.Z)).Magnitude
			if dist < closestDist then
				closestDist = dist
				target = p
			end
		end
	end
	return target
end

ClawRemote.OnServerEvent:Connect(function(player, state)
	if IsBusy or not state then return end
	IsBusy = true
	
	local target = getBestPrize()
	if not target then 
		warn("Bot: No prizes found in Folder!")
		IsBusy = false 
		return 
	end

	-- 1. CALCULATE TOP OF PRIZE (Raycast for perfection)
	local rayOrigin = Vector3.new(target.Position.X, CLAW.Position.Y, target.Position.Z)
	local rayDirection = Vector3.new(0, -20, 0)
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
	
	local targetY = target.Position.Y + (target.Size.Y / 2)
	if raycastResult then targetY = raycastResult.Position.Y end

	-- 2. MOVE TO TARGET (X, Z)
	local hoverPos = Vector3.new(target.Position.X, CLAW.Position.Y, target.Position.Z)
	TweenService:Create(CLAW, TweenInfo.new(1.2, Enum.EasingStyle.QuadOut), {Position = hoverPos}):Play()
	task.wait(1.3)

	-- 3. DROP (Y)
	local dropPos = Vector3.new(hoverPos.X, targetY - 0.2, hoverPos.Z)
	TweenService:Create(CLAW, TweenInfo.new(1, Enum.EasingStyle.SineIn), {Position = dropPos}):Play()
	task.wait(1.1)

	-- 4. THE PERFECT GRAB (Force Weld)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = CLAW
	weld.Part1 = target
	weld.Parent = CLAW
	target.CanCollide = false -- Prevents getting stuck on the way up

	-- 5. LIFT
	TweenService:Create(CLAW, TweenInfo.new(1, Enum.EasingStyle.QuadOut), {Position = hoverPos}):Play()
	task.wait(1.1)

	-- 6. MOVE TO BIN
	TweenService:Create(CLAW, TweenInfo.new(1.5), {Position = DROP_BIN}):Play()
	task.wait(1.6)

	-- 7. RELEASE
	weld:Destroy()
	target.CanCollide = true
	task.wait(1)
	
	IsBusy = false
end)
