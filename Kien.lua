local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local EggHitRequest = ReplicatedStorage:WaitForChild("EggHitRequest")

local enabled = true
local isProcessing = false
local currentMultiplier = 4
local isMenuOpen = true

print("[√12kientomato] Script Fixed Version aktif.")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EggMultiplierTopGUI"
ScreenGui.ResetOnSpawn = false

pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
	ScreenGui.Parent = PlayerGui
end

-- ==================== NOTIFIKASI (TIẾNG VIỆT) ====================
local NotifLabel = Instance.new("TextLabel")
NotifLabel.Name = "FloatingNotification"
NotifLabel.Size = UDim2.new(0, 210, 0, 26)
NotifLabel.AnchorPoint = Vector2.new(1, 0)
NotifLabel.Position = UDim2.new(1, -50, 0, 10)
NotifLabel.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
NotifLabel.BackgroundTransparency = 0.2
NotifLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
NotifLabel.TextSize = 11
NotifLabel.Font = Enum.Font.GothamBold
NotifLabel.Text = ""
NotifLabel.Visible = false
NotifLabel.Parent = ScreenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 6)
notifCorner.Parent = NotifLabel

local function showNotification(msg)
	NotifLabel.Text = " " .. msg
	NotifLabel.Visible = true
	NotifLabel.TextTransparency = 0
	NotifLabel.BackgroundTransparency = 0.2
	
	task.spawn(function()
		task.wait(1.0)
		for i = 0, 1, 0.15 do
			NotifLabel.TextTransparency = i
			NotifLabel.BackgroundTransparency = 0.2 + (i * 0.8)
			task.wait(0.02)
		end
		NotifLabel.Visible = false
	end)
end

-- ==================== MAIN PANEL (KOTAK UTAMA) ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 240, 0, 100)
MainFrame.AnchorPoint = Vector2.new(1, 0)
MainFrame.Position = UDim2.new(1, -10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 25)
MainFrame.BackgroundTransparency = 0.25
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = MainFrame

-- Viền bảy sắc cầu vồng (Rainbow Border)
local rainbowStroke = Instance.new("UIStroke")
rainbowStroke.Thickness = 2
rainbowStroke.Parent = MainFrame

task.spawn(function()
	local hue = 0
	while true do
		hue = (tick() % 5) / 5
		rainbowStroke.Color = Color3.fromHSV(hue, 1, 1)
		RunService.RenderStepped:Wait()
	end
end)

-- ==================== TOMBOL TOGGLE (MINIMIZE) DI KANAN SAT ====================
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleMenuButton"
ToggleBtn.Size = UDim2.new(0, 26, 0, 26)
ToggleBtn.Position = UDim2.new(1, -30, 0, 6)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 38, 55)
ToggleBtn.BackgroundTransparency = 0.3
ToggleBtn.Text = "-"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.ZIndex = 5
ToggleBtn.Parent = MainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = ToggleBtn

-- ==================== NAMA "KIÊN" EFEK KETIK ====================
local NameLabel = Instance.new("TextLabel")
NameLabel.Name = "NameBanner"
NameLabel.Size = UDim2.new(0, 0, 0, 22)
NameLabel.Position = UDim2.new(0, 8, 0, 6)
NameLabel.BackgroundColor3 = Color3.fromRGB(20, 26, 42)
NameLabel.BackgroundTransparency = 0.4
NameLabel.Text = ""
NameLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
NameLabel.TextSize = 12
NameLabel.Font = Enum.Font.GothamBlack
NameLabel.ClipsDescendants = true
NameLabel.Parent = MainFrame

local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 5)
nameCorner.Parent = NameLabel

task.spawn(function()
	task.wait(0.2)
	local resizeTween = TweenService:Create(NameLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 160, 0, 22)})
	resizeTween:Play()
	resizeTween.Completed:Wait()
	
	local targetText = "KIÊN"
	for i = 1, #targetText do
		NameLabel.Text = string.sub(targetText, 1, i)
		task.wait(0.05)
	end
end)

-- ==================== TOMBOL MULTIPLIER (1x - 5x) ====================
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Size = UDim2.new(0, 224, 0, 34)
ButtonContainer.Position = UDim2.new(0, 8, 0, 34)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ButtonContainer

local multipliers = {1, 2, 3, 4, 5}
local multiButtons = {}

for _, val in ipairs(multipliers) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 34)
	btn.BackgroundColor3 = (val == 4) and Color3.fromRGB(45, 100, 220) or Color3.fromRGB(20, 26, 42)
	btn.BackgroundTransparency = 0.3
	btn.Text = val .. "x"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamBold
	btn.Parent = ButtonContainer
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	
	multiButtons[val] = btn
	
	btn.Activated:Connect(function()
		currentMultiplier = val
		for mVal, button in pairs(multiButtons) do
			if mVal == val then
				button.BackgroundColor3 = Color3.fromRGB(45, 100, 220)
				button.BackgroundTransparency = 0.1
			else
				button.BackgroundColor3 = Color3.fromRGB(20, 26, 42)
				button.BackgroundTransparency = 0.4
			end
		end
		
		if val == 1 then
			showNotification("Chế độ 1x: Đã tắt (Bình thường)")
		else
			showNotification("Đã chọn: " .. val .. "x Đam!")
		end
	end)
end

-- ==================== SIGNATURE "by ? Tiktok" ====================
local SigLabel = Instance.new("TextLabel")
SigLabel.Name = "SignatureLabel"
SigLabel.Size = UDim2.new(0, 224, 0, 18)
SigLabel.Position = UDim2.new(0, 8, 0, 74)
SigLabel.BackgroundTransparency = 1
SigLabel.Text = "by ? Tiktok"
SigLabel.TextColor3 = Color3.fromRGB(160, 170, 190)
SigLabel.TextSize = 10
SigLabel.Font = Enum.Font.GothamItalic
SigLabel.Parent = MainFrame

-- ==================== FUNGSI TOMBOL MINIMIZE (TUTUP/BUKA) ====================
ToggleBtn.Activated:Connect(function()
	isMenuOpen = not isMenuOpen
	
	if isMenuOpen then
		MainFrame.Size = UDim2.new(0, 240, 0, 100)
		ToggleBtn.Text = "-"
		NameLabel.Visible = true
		ButtonContainer.Visible = true
		SigLabel.Visible = true
		showNotification("Đã mở menu")
	else
		MainFrame.Size = UDim2.new(0, 40, 0, 38)
		ToggleBtn.Position = UDim2.new(0, 7, 0, 6)
		ToggleBtn.Text = "+"
		NameLabel.Visible = false
		ButtonContainer.Visible = false
		SigLabel.Visible = false
		showNotification("Đã ẩn menu")
	end
end)

-- ==================== LOGIC HOOK FIRESERVER (STABIL & CHUẨN GỐC) ====================
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

print("[√12kientomato] Berhasil dijalankan dengan sempurna!")
