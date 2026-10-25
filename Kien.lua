local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local EggHitRequest = ReplicatedStorage:WaitForChild("EggHitRequest")

local enabled = true
local isProcessing = false
local currentMultiplier = 4
local isMenuOpen = true

print("[√12kientomato] Script aktif.")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggMultiplierTopGUI"
ScreenGui.ResetOnSpawn = false

pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
	ScreenGui.Parent = PlayerGui
end

-- A. BANNER NAMA (Huruf "KIÊN" tung yang melar & ngầu)
local NameLabel = Instance.new("TextLabel")
NameLabel.Name = "NameBanner"
NameLabel.Size = UDim2.new(0, 0, 0, 22)
NameLabel.AnchorPoint = Vector2.new(1, 1)
NameLabel.Position = UDim2.new(1, -10, 0, 6)
NameLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
NameLabel.BackgroundTransparency = 0.3
NameLabel.Text = ""
NameLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
NameLabel.TextSize = 13
NameLabel.Font = Enum.Font.GothamBlack
NameLabel.ClipsDescendants = true
NameLabel.Parent = ScreenGui

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 5)
nameCorner.Parent = NameLabel

local nameStroke = Instance.new("UIStroke")
nameStroke.Color = Color3.fromRGB(0, 150, 255)
nameStroke.Thickness = 1.5
nameStroke.Parent = NameLabel

-- Animasi melar lalu ketik "KIÊN"
task.spawn(function()
	task.wait(0.4)
	local resizeTween = TweenService:Create(NameLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 235, 0, 22)})
	resizeTween:Play()
	resizeTween.Completed:Wait()
	
	local targetText = "KIÊN"
	for i = 1, #targetText do
		NameLabel.Text = string.sub(targetText, 1, i)
		task.wait(0.06)
	end
end)

-- B. Tombol Toggle/Minimize
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleMenuButton"
ToggleBtn.Size = UDim2.new(0, 32, 0, 32)
ToggleBtn.AnchorPoint = Vector2.new(1, 0)
ToggleBtn.Position = UDim2.new(1, -10, 0, 34)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
ToggleBtn.BackgroundTransparency = 0.35
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = ToggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(0, 0, 0)
toggleStroke.Thickness = 1.5
toggleStroke.Parent = ToggleBtn

-- C. Container Utama untuk Tombol Multiplier (1x sampai 5x)
local Container = Instance.new("Frame")
Container.Name = "MultiplierContainer"
Container.Size = UDim2.new(0, 235, 0, 36)
Container.AnchorPoint = Vector2.new(1, 0)
Container.Position = UDim2.new(1, -48, 0, 34) 
Container.BackgroundTransparency = 1
Container.Parent = ScreenGui

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = Container

local multipliers = {1, 2, 3, 4, 5}
local multiButtons = {}

for _, val in ipairs(multipliers) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 32)
	btn.BackgroundColor3 = (val == 4) and Color3.fromRGB(45, 100, 220) or Color3.fromRGB(30, 35, 50)
	btn.BackgroundTransparency = 0.35 
	btn.Text = val .. "x"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.Parent = Container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.5
	stroke.Parent = btn
	
	multiButtons[val] = btn
	
	btn.Activated:Connect(function()
		currentMultiplier = val
		for mVal, button in pairs(multiButtons) do
			if mVal == val then
				button.BackgroundColor3 = Color3.fromRGB(45, 100, 220)
				button.BackgroundTransparency = 0.2
			else
				button.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
				button.BackgroundTransparency = 0.45
			end
		end
	end)
end

-- Fungsi Buka/Tutup Menu
ToggleBtn.Activated:Connect(function()
	isMenuOpen = not isMenuOpen
	Container.Visible = isMenuOpen
	NameLabel.Visible = isMenuOpen
	if isMenuOpen then
		ToggleBtn.Text = "-"
	else
		ToggleBtn.Text = "+"
	end
end)

-- 2. HOOK / INTERCEPT FIRESERVER
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	
	if enabled and not isProcessing and currentMultiplier > 1 and self == EggHitRequest and method == "FireServer" then
		local eggObject = args[1]
		local baseHit = args[2] or 1
		
		if eggObject then
			isProcessing = true
			local extraCount = currentMultiplier - 1
			
			task.spawn(function()
				for i = 1, extraCount do
					local nextHit = baseHit + i
					self:FireServer(eggObject, nextHit)
				end
				
				task.wait(1.0)
				isProcessing = false
			end)
		end
	end
	
	return oldNameCall(self, ...)
end)

print("[√12kientomato] Siap!")
