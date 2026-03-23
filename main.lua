local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClawRemote = ReplicatedStorage:WaitForChild("ClawRemote")

-- !! UPDATE THESE PATHS TO MATCH YOUR MODEL !!
local CLAW_MACHINE = workspace:WaitForChild("ClawMachine") 
local MAIN_PART = CLAW_MACHINE.Claw.MainPart -- This part must be ANCHORED
local PRIZE_FOLDER = CLAW_MACHINE.Prizes -- Folder containing UNANCHORED prizes
local DROP_CHUTE = Vector3.new(0, 15, 0) -- Change to your hole's position!

local IsBusy = false

local function findNearestPrize()
	local closest = nil
	local shortestDist = math.huge
	
	for _, item in pairs(PRIZE_FOLDER:GetChildren()) do
		local part = item:IsA("BasePart") and item or item.PrimaryPart
		if part then
			local dist = (MAIN_PART.Position - part.Position).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				closest = part
			end
		end
	end
	return closest
end

ClawRemote.OnServerEvent:Connect(function()
	if IsBusy then return end
	IsBusy = true
	
	local target = findNearestPrize()
	if not target then IsBusy = false return end

	-- 1. TRACK (Move to Prize)
	local startPos = MAIN_PART.Position
	local hoverPos = Vector3.new(target.Position.X, MAIN_PART.Position.Y, target.Position.Z)
	TweenService:Create(MAIN_PART, TweenInfo.new(2), {Position = hoverPos}):Play()
	task.wait(2.1)

	-- 2. DROP
	local dropPos = Vector3.new(hoverPos.X, target.Position.Y + 1, hoverPos.Z)
	TweenService:Create(MAIN_PART, TweenInfo.new(1.5, Enum.EasingStyle.SineIn), {Position = dropPos}):Play()
	task.wait(1.6)

	-- 3. CATCH (Weld)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = MAIN_PART
	weld.Part1 = target
	weld.Parent = MAIN_PART

	-- 4. RETRACT
	TweenService:Create(MAIN_PART, TweenInfo.new(1.5), {Position = hoverPos}):Play()
	task.wait(1.6)

	-- 5. GO TO CHUTE
	local chuteTop = Vector3.new(DROP_CHUTE.X, MAIN_PART.Position.Y, DROP_CHUTE.Z)
	TweenService:Create(MAIN_PART, TweenInfo.new(2.5), {Position = chuteTop}):Play()
	task.wait(2.6)

	-- 6. RELEASE
	weld:Destroy()
	task.wait(1)
	
	-- 7. RETURN HOME
	TweenService:Create(MAIN_PART, TweenInfo.new(1.5), {Position = startPos}):Play()
	task.wait(1.6)
	
	IsBusy = false
end)
