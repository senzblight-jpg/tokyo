-- LocalScript inside StarterPlayerScripts
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClawRemote = ReplicatedStorage:WaitForChild("ClawRemote")

local isAutoMode = false -- The Toggle State

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Enum.KeyCode.Z then
		isAutoMode = not isAutoMode -- Flip the switch
		
		if isAutoMode then
			print("Tokyo Auto-Claw: ON")
			-- Start a loop that tells the server to catch
			task.spawn(function()
				while isAutoMode do
					ClawRemote:FireServer()
					task.wait(8) -- Wait for the claw to finish a full cycle
				end
			end)
		else
			print("Tokyo Auto-Claw: OFF")
		end
	end
end)
