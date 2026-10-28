-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 1/5)
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local nguoiDung = Players.LocalPlayer
local playerGui = nguoiDung:WaitForChild("PlayerGui")
local EggHitRequest = ReplicatedStorage:WaitForChild("EggHitRequest")

local kienEnabled = true
local kienIsProcessing = false
local kienCurrentMultiplier = 4
local basePositions = { Base1 = nil, Base2 = nil }
local baseModes = { Base1 = "Tele", Base2 = "Tele" } -- Mặc định: "Run", "Fly", "Tele"
local baseFlySpeeds = { Base1 = 100, Base2 = 100 }

local isAutoWalking = false
local moveConnection = nil
local isPoppedOut = false
local isLocked = false
local espEnabled = false
local instantPromptEnabled = false
local activeEspTags = {}

local noclipEnabled = false
local noclipConnection = nil
local speedEnabled = false
local speedValue = 50
local speedConnection = nil

local flyEnabled = false
local flySpeed = 50
local flyConnection = nil
local flyUpState, flyDownState = false, false

local isFlyingToPlayer = false
local targetFlyPlayer = nil
local flyToPlayerConn = nil

pcall(function()
    local cu = playerGui:FindFirstChild("KienMenuM1")
    if cu then cu:Destroy() end
    local cuPop = playerGui:FindFirstChild("PopoutFrameKien")
    if cuPop then cuPop:Destroy() end
    local cuFly = playerGui:FindFirstChild("FlyGuiKien")
    if cuFly then cuFly:Destroy() end
end)

local Mau = {
    Nen = Color3.fromRGB(255, 255, 255),
    Panel = Color3.fromRGB(240, 240, 245),
    The = Color3.fromRGB(245, 245, 250),
    NutBam = Color3.fromRGB(250, 250, 255),
    Do = Color3.fromRGB(220, 40, 60),
    DoDam = Color3.fromRGB(180, 20, 40),
    Trang = Color3.fromRGB(255, 255, 255),
    Den = Color3.fromRGB(15, 15, 20),
    Mo = Color3.fromRGB(100, 100, 120),
    XanhNhe = Color3.fromRGB(20, 140, 90),
}

local function tao(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function boGoc(parent, radius)
    tao("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, parent)
end

local function vien(parent, color, thickness, transparency)
    return tao("UIStroke", { Color = color or Mau.Do, Thickness = thickness or 1, Transparency = transparency or 0.4 }, parent)
end

local function hieuDung(obj, duration, props)
    local t = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Anti-Lag Super Optimization
local function superAntiLag()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        settings().Rendering.QualityLevel = 1
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            end
        end
    end)
end
superAntiLag()

local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if isLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if isLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isLocked then return end
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local parentGui = playerGui
pcall(function()
    if gethui then
        parentGui = gethui()
    elseif syn and syn.protect_gui then
        parentGui = Instance.new("Folder")
        syn.protect_gui(parentGui)
        parentGui.Parent = CoreGui
    end
end)

local screenGui = tao("ScreenGui", {
    Name = "KienMenuM1",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parentGui)

local thongBaoLabel = tao("TextLabel", {
    Name = "ThongBaoNoi",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 15),
    Size = UDim2.fromOffset(320, 38),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.3,
    TextColor3 = Mau.Den,
    Text = "",
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    Visible = false,
    ZIndex = 200,
}, screenGui)
boGoc(thongBaoLabel, 12)
vien(thongBaoLabel, Mau.Do, 1.5, 0.3)

local function hienThongBao(noiDung)
    thongBaoLabel.Text = "⚡ " .. noiDung
    thongBaoLabel.Visible = true
    thongBaoLabel.TextTransparency = 1
    thongBaoLabel.BackgroundTransparency = 1
    hieuDung(thongBaoLabel, 0.2, {TextTransparency = 0, BackgroundTransparency = 0.3})
    
    task.delay(1.8, function()
        hieuDung(thongBaoLabel, 0.2, {TextTransparency = 1, BackgroundTransparency = 1})
        task.wait(0.22)
        thongBaoLabel.Visible = false
    end)
end

local nutMoMenu = tao("TextButton", {
    Name = "NutMoMenu",
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.new(0, 20, 0.5, -28),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35,
    Text = "K",
    TextColor3 = Mau.Do,
    TextSize = 28,
    Font = Enum.Font.GothamBlack,
    AutoButtonColor = false,
    ZIndex = 150,
}, screenGui)
boGoc(nutMoMenu, 18)
vien(nutMoMenu, Mau.Do, 2.5, 0.2)
makeDraggable(nutMoMenu)

local menuChinh = tao("Frame", {
    Name = "MenuChinh",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(660, 430),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35, 
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
}, screenGui)
boGoc(menuChinh, 18)
vien(menuChinh, Mau.Do, 1.8, 0.3)
makeDraggable(menuChinh)

local tyLeGiaoDien = tao("UIScale", { Scale = 1 }, menuChinh)
local function capNhatTyLe()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    tyLeGiaoDien.Scale = math.min(viewport.X / 700, viewport.Y / 470, 1)
end
capNhatTyLe()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(capNhatTyLe)
end

local thanhTieuDe = tao("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Color3.fromRGB(240, 240, 250),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
}, menuChinh)
boGoc(thanhTieuDe, 18)

tao("Frame", {
    Position = UDim2.new(0, 0, 1, -4),
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Mau.Do,
    BorderSizePixel = 0,
}, thanhTieuDe)

local logo = tao("Frame", {
    Position = UDim2.new(0, 16, 0.5, -19),
    Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = Mau.Do,
}, thanhTieuDe)
boGoc(logo, 12)
vien(logo, Mau.Trang, 1, 0.3)

tao("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "K",
    TextColor3 = Mau.Trang,
    Font = Enum.Font.GothamBlack,
    TextSize = 23,
}, logo)

tao("TextLabel", {
    Position = UDim2.new(0, 65, 0, 11),
    Size = UDim2.new(0, 250, 0, 22),
    BackgroundTransparency = 1,
    Text = "KIÊN  |  MENU M1 PRO",
    TextColor3 = Mau.Den,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
}, thanhTieuDe)

tao("TextLabel", {
    Position = UDim2.new(0, 66, 0, 35),
    Size = UDim2.new(0, 280, 0, 16),
    BackgroundTransparency = 1,
    Text = "BLACK NEBULA  •  √12kientomato",
    TextColor3 = Mau.Do,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
}, thanhTieuDe)

local fpsLabel = tao("TextLabel", {
    Position = UDim2.new(1, -170, 0, 18),
    Size = UDim2.fromOffset(75, 26),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35,
    TextColor3 = Mau.XanhNhe,
    Text = "FPS: 60",
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, thanhTieuDe)
boGoc(fpsLabel, 8)
vien(fpsLabel, Mau.Mo, 1, 0.5)

local lastTick = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local currentTick = tick()
    if currentTick - lastTick >= 1 then
        fpsLabel.Text = "FPS: " .. math.floor(frameCount / (currentTick - lastTick))
        frameCount = 0
        lastTick = currentTick
    end
end)

local nutKhoa = tao("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -85, 0, 16),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35,
    Text = "🔓",
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, thanhTieuDe)
boGoc(nutKhoa, 8)
vien(nutKhoa, Mau.Mo, 1, 0.5)

nutKhoa.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    nutKhoa.Text = isLocked and "🔒" or "🔓"
    hienThongBao(isLocked and "Đã khóa vị trí Menu!" or "Đã mở khóa Menu!")
end)

local nutDong = tao("TextButton", {
    Position = UDim2.new(1, -45, 0, 16),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35,
    Text = "×",
    TextColor3 = Mau.Do,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, thanhTieuDe)
boGoc(nutDong, 8)
vien(nutDong, Mau.Mo, 1, 0.5)

local thanhBen = tao("Frame", {
    Position = UDim2.new(0, 0, 0, 66),
    Size = UDim2.new(0, 155, 1, -66),
    BackgroundColor3 = Color3.fromRGB(235, 235, 245),
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
}, menuChinh)

tao("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, thanhBen)
tao("UIPadding", { PaddingTop = UDim.new(0, 17), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, thanhBen)

local khungNoiDung = tao("Frame", {
    Position = UDim2.new(0, 155, 0, 66),
    Size = UDim2.new(1, -155, 1, -66),
    BackgroundTransparency = 1,
}, menuChinh)

local tieuDeTrang = tao("TextLabel", {
    Position = UDim2.new(0, 20, 0, 15),
    Size = UDim2.new(1, -40, 0, 25),
    BackgroundTransparency = 1,
    Text = "TRANG CHỦ / TỔNG QUAN",
    TextColor3 = Mau.Den,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
}, khungNoiDung)

local moTaTrang = tao("TextLabel", {
    Position = UDim2.new(0, 20, 0, 42),
    Size = UDim2.new(1, -40, 0, 20),
    BackgroundTransparency = 1,
    Text = "Không gian của bạn. Phong cách của bạn.",
    TextColor3 = Mau.Mo,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Gotham,
    TextSize = 11,
}, khungNoiDung)

local khungCuon = tao("ScrollingFrame", {
    Position = UDim2.new(0, 15, 0, 72),
    Size = UDim2.new(1, -30, 1, -85),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Mau.Do,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, khungNoiDung)

tao("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, khungCuon)
-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 2/5)
-- ==========================================
local PopoutFrame = tao("Frame", {
    Name = "PopoutFrameKien",
    Size = UDim2.fromOffset(230, 200),
    Position = UDim2.new(0.65, 0, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
}, screenGui)
boGoc(PopoutFrame, 14)
vien(PopoutFrame, Mau.Do, 1.5, 0.3)
makeDraggable(PopoutFrame)

local PopoutTopBar = tao("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(235, 235, 245),
    BackgroundTransparency = 0.45,
    BorderSizePixel = 0,
}, PopoutFrame)
boGoc(PopoutTopBar, 14)

tao("TextLabel", {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -50, 1, 0),
    BackgroundTransparency = 1,
    Text = "⚡ ĐIỀU KHIỂN NHANH BASE",
    TextColor3 = Mau.Den,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, PopoutTopBar)

local PopoutContent = tao("Frame", {
    Position = UDim2.new(0, 10, 0, 38),
    Size = UDim2.new(1, -20, 1, -45),
    BackgroundTransparency = 1,
}, PopoutFrame)
tao("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, PopoutContent)

local isPopoutMinimized = false
local nutThuGonPopout = tao("TextButton", {
    Size = UDim2.fromOffset(26, 26),
    Position = UDim2.new(1, -28, 0, 3),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.35,
    Text = "-",
    TextColor3 = Mau.Den,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, PopoutTopBar)
boGoc(nutThuGonPopout, 6)
vien(nutThuGonPopout, Mau.Mo, 1, 0.5)

nutThuGonPopout.MouseButton1Click:Connect(function()
    isPopoutMinimized = not isPopoutMinimized
    PopoutContent.Visible = not isPopoutMinimized
    PopoutFrame.Size = isPopoutMinimized and UDim2.fromOffset(230, 35) or UDim2.fromOffset(230, 200)
    nutThuGonPopout.Text = isPopoutMinimized and "+" or "-"
end)

local function stopWalking()
    isAutoWalking = false
    isFlyingToPlayer = false
    if moveConnection then moveConnection:Disconnect(); moveConnection = nil end
    if flyToPlayerConn then flyToPlayerConn:Disconnect(); flyToPlayerConn = nil end
    local char = nguoiDung.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:Move(Vector3.new(0, 0, 0), false) end
end

local function startMoveTo(targetPos, tenBase)
    if moveConnection then moveConnection:Disconnect() end
    isAutoWalking = true
    hienThongBao("Đang giả lập chạy về " .. tenBase .. "...")

    moveConnection = RunService.RenderStepped:Connect(function()
        if not isAutoWalking then stopWalking() return end
        local char = nguoiDung.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not targetPos or not humanoid or not hrp or humanoid.Health <= 0 then
            stopWalking()
            hienThongBao("Lỗi: Mất tọa độ hoặc nhân vật chết!")
            return
        end

        local currentPos = hrp.Position
        local dirVector = Vector3.new(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z)
        if dirVector.Magnitude < 4 then
            stopWalking()
            hienThongBao("Đã đến " .. tenBase .. " thành công!")
            return
        end
        humanoid:Move(dirVector.Unit, false)
    end)
end

local function flyHomeTo(targetPos, tenBase, speed)
    if moveConnection then moveConnection:Disconnect() end
    isAutoWalking = true
    hienThongBao("Đang bay tốc độ " .. speed .. " về " .. tenBase .. "...")

    moveConnection = RunService.RenderStepped:Connect(function(dt)
        if not isAutoWalking then stopWalking() return end
        local char = nguoiDung.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not targetPos or not hrp or not hum or hum.Health <= 0 then
            stopWalking()
            hienThongBao("Lỗi khi bay về nhà!")
            return
        end

        hum.PlatformStand = true
        local direction = targetPos - hrp.Position
        local distance = direction.Magnitude

        if distance < 5 then
            hum.PlatformStand = false
            stopWalking()
            hienThongBao("Đã bay đến " .. tenBase .. " thành công!")
            return
        end

        hrp.CFrame = hrp.CFrame + (direction.Unit * speed * dt)
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end)
end

local function teleportHome(targetPos, tenBase)
    stopWalking()
    local char = nguoiDung.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and targetPos then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        hienThongBao("Đã Teleport thẳng về " .. tenBase .. "!")
    else
        hienThongBao("Chưa lưu tọa độ " .. tenBase .. "!")
    end
end

-- Hàm kích hoạt về Base theo đúng lựa chọn cấu hình trong Menu
local function veBaseTheoCauHinh(baseKey, tenBase)
    local pos = basePositions[baseKey]
    if not pos then hienThongBao("Chưa lưu tọa độ " .. tenBase .. "!"); return end
    
    local mode = baseModes[baseKey] or "Tele"
    if mode == "Run" then
        startMoveTo(pos, tenBase)
    elseif mode == "Fly" then
        local spd = baseFlySpeeds[baseKey] or 100
        flyHomeTo(pos, tenBase, spd)
    elseif mode == "Tele" then
        teleportHome(pos, tenBase)
    end
end

local btnPopBase1 = tao("TextButton", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Mau.NutBam,
    BackgroundTransparency = 0.25,
    Text = "🚀 Về Base 1 (Theo Lựa Chọn)",
    TextColor3 = Mau.Den,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    AutoButtonColor = false,
}, PopoutContent)
boGoc(btnPopBase1, 8)
vien(btnPopBase1, Mau.Do, 1, 0.4)

local btnPopBase2 = tao("TextButton", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Mau.NutBam,
    BackgroundTransparency = 0.25,
    Text = "🚀 Về Base 2 (Theo Lựa Chọn)",
    TextColor3 = Mau.Den,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    AutoButtonColor = false,
}, PopoutContent)
boGoc(btnPopBase2, 8)
vien(btnPopBase2, Mau.Do, 1, 0.4)

local btnDungAll = tao("TextButton", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Mau.DoDam,
    BackgroundTransparency = 0.15,
    Text = "🛑 Dừng Lại Ngay",
    TextColor3 = Mau.Trang,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    AutoButtonColor = false,
}, PopoutContent)
boGoc(btnDungAll, 8)
vien(btnDungAll, Mau.Trang, 1, 0.3)

btnPopBase1.MouseButton1Click:Connect(function() veBaseTheoCauHinh("Base1", "Base 1") end)
btnPopBase2.MouseButton1Click:Connect(function() veBaseTheoCauHinh("Base2", "Base 2") end)
btnDungAll.MouseButton1Click:Connect(function() stopWalking(); hienThongBao("🛑 Đã dừng lại!") end)
-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 3/5)
-- ==========================================
local function batNhatVatPhamNhanh()
    instantPromptEnabled = true
    game.DescendantAdded:Connect(function(obj)
        if instantPromptEnabled and obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
        end
    end)
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
    end
end
batNhatVatPhamNhanh()

local function taoEspChoPlayer(player)
    if player == nguoiDung then return end
    local function onCharacterAdded(char)
        local head = char:WaitForChild("Head", 5)
        if head and not head:FindFirstChild("KienEspTag") then
            local billboard = tao("BillboardGui", {
                Name = "KienEspTag",
                Size = UDim2.fromOffset(200, 50),
                StudsOffset = Vector3.new(0, 3.2, 0),
                AlwaysOnTop = true,
            }, head)

            local txt = tao("TextLabel", {
                Name = "EspText",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = player.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextStrokeTransparency = 0.2,
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            }, billboard)

            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not billboard.Parent or not nguoiDung.Character or not nguoiDung.Character:FindFirstChild("HumanoidRootPart") then
                    if conn then conn:Disconnect() end
                    return
                end
                local myHrp = nguoiDung.Character.HumanoidRootPart
                local targetHrp = char:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    local distance = math.floor((targetHrp.Position - myHrp.Position).Magnitude)
                    txt.Text = player.Name .. " [" .. distance .. "m]"
                end
            end)

            table.insert(activeEspTags, billboard)
        end
    end
    if player.Character then onCharacterAdded(player.Character) end
    player.CharacterAdded:Connect(onCharacterAdded)
end

local function toggleEsp(state)
    espEnabled = state
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do taoEspChoPlayer(p) end
        Players.PlayerAdded:Connect(taoEspChoPlayer)
        hienThongBao("Đã bật định vị player & khoảng cách!")
    else
        for _, tag in ipairs(activeEspTags) do tag:Destroy() end
        activeEspTags = {}
        hienThongBao("Đã tắt định vị người chơi!")
    end
end

local function toggleNoclip(state)
    noclipEnabled = state
    if noclipEnabled then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            local char = nguoiDung.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        hienThongBao("Đã Bật: Đi xuyên tường (Noclip)!")
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        local char = nguoiDung.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        hienThongBao("Đã Tắt: Đi xuyên tường (Noclip)!")
    end
end

local function toggleSpeed(state, val)
    speedEnabled = state
    speedValue = val or 50
    if speedEnabled then
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = RunService.RenderStepped:Connect(function()
            if not speedEnabled then return end
            local char = nguoiDung.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = speedValue end
        end)
        hienThongBao("Đã Bật: Tốc độ chạy " .. speedValue .. "!")
    else
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        local char = nguoiDung.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
        hienThongBao("Đã Tắt: Tốc độ chạy về mặc định!")
    end
end

-- FLY V3 CHUẨN XNEO
local function taoGiaoDienFly()
    local flyGui = tao("Frame", {
        Name = "FlyGuiKien",
        Size = UDim2.fromOffset(210, 150),
        Position = UDim2.new(0.05, 0, 0.55, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Visible = false,
    }, screenGui)
    boGoc(flyGui, 14)
    vien(flyGui, Mau.Do, 1.5, 0.3)
    makeDraggable(flyGui)

    local flyTop = tao("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(235, 235, 245),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
    }, flyGui)
    boGoc(flyTop, 14)

    tao("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        Text = "✈️ FLY V3 MENU (XNEO)",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, flyTop)

    local isFlyMinimized = false
    local flyBody = tao("Frame", {
        Position = UDim2.new(0, 10, 0, 36),
        Size = UDim2.new(1, -20, 1, -42),
        BackgroundTransparency = 1,
    }, flyGui)
    tao("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, flyBody)

    local btnMiniFly = tao("TextButton", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -28, 0, 3),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.35,
        Text = "-",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
    }, flyTop)
    boGoc(btnMiniFly, 6)
    vien(btnMiniFly, Mau.Mo, 1, 0.5)

    btnMiniFly.MouseButton1Click:Connect(function()
        isFlyMinimized = not isFlyMinimized
        flyBody.Visible = not isFlyMinimized
        flyGui.Size = isFlyMinimized and UDim2.fromOffset(210, 34) or UDim2.fromOffset(210, 150)
        btnMiniFly.Text = isFlyMinimized and "+" or "-"
    end)

    local upDownRow = tao("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 }, flyBody)
    tao("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, upDownRow)

    local btnUp = tao("TextButton", {
        Size = UDim2.new(0.48, 0, 1, 0),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.25,
        Text = "▲ UP",
        TextColor3 = Mau.XanhNhe,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, upDownRow)
    boGoc(btnUp, 6)
    vien(btnUp, Mau.XanhNhe, 1, 0.4)

    local btnDown = tao("TextButton", {
        Size = UDim2.new(0.48, 0, 1, 0),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.25,
        Text = "▼ DOWN",
        TextColor3 = Mau.Do,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, upDownRow)
    boGoc(btnDown, 6)
    vien(btnDown, Mau.Do, 1, 0.4)

    btnUp.MouseButton1Down:Connect(function() flyUpState = true end)
    btnUp.MouseButton1Up:Connect(function() flyUpState = false end)
    btnDown.MouseButton1Down:Connect(function() flyDownState = true end)
    btnDown.MouseButton1Up:Connect(function() flyDownState = false end)

    local flyToggleBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.25,
        Text = "Fly: OFF",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, flyBody)
    boGoc(flyToggleBtn, 8)
    vien(flyToggleBtn, Mau.Do, 1, 0.4)

    local speedControlRow = tao("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1 }, flyBody)
    tao("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, speedControlRow)

    local btnGiam = tao("TextButton", { Size = UDim2.new(0.3, 0, 1, 0), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "(-)", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, speedControlRow)
    boGoc(btnGiam, 6)
    vien(btnGiam, Mau.Mo, 1, 0.5)

    local lblSpeed = tao("TextLabel", { Size = UDim2.new(0.38, 0, 1, 0), BackgroundTransparency = 1, Text = "Tốc: 50", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11 }, speedControlRow)

    local btnTang = tao("TextButton", { Size = UDim2.new(0.3, 0, 1, 0), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "(+)", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, speedControlRow)
    boGoc(btnTang, 6)
    vien(btnTang, Mau.Mo, 1, 0.5)

    btnTang.MouseButton1Click:Connect(function()
        flySpeed = math.min(500, flySpeed + 25)
        lblSpeed.Text = "Tốc: " .. flySpeed
        hienThongBao("Tốc độ bay: " .. flySpeed)
    end)

    btnGiam.MouseButton1Click:Connect(function()
        flySpeed = math.max(10, flySpeed - 25)
        lblSpeed.Text = "Tốc: " .. flySpeed
        hienThongBao("Tốc độ bay: " .. flySpeed)
    end)

    local function toggleFly(state)
        flyEnabled = state
        if flyEnabled then
            flyToggleBtn.Text = "Fly: ON"
            flyToggleBtn.BackgroundColor3 = Mau.DoDam
            hienThongBao("Đã Bật chế độ Fly V3!")

            if flyConnection then flyConnection:Disconnect() end
            flyConnection = RunService.RenderStepped:Connect(function(dt)
                if not flyEnabled then return end
                local char = nguoiDung.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    hum.PlatformStand = true
                    local cam = workspace.CurrentCamera
                    local moveDir = hum.MoveDirection
                    local vel = Vector3.new(0, 0, 0)
                    local camCF = cam.CFrame

                    if moveDir.Magnitude > 0 then
                        vel = (camCF.LookVector * moveDir.Z + camCF.RightVector * moveDir.X).Unit * flySpeed
                    end
                    if flyUpState then vel = vel + Vector3.new(0, flySpeed, 0)
                    elseif flyDownState then vel = vel - Vector3.new(0, flySpeed, 0) end

                    hrp.AssemblyLinearVelocity = vel
                end
            end)
        else
            flyToggleBtn.Text = "Fly: OFF"
            flyToggleBtn.BackgroundColor3 = Mau.NutBam
            hienThongBao("Đã Tắt chế độ Fly!")
            if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
            local char = nguoiDung.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end

    flyToggleBtn.MouseButton1Click:Connect(function() toggleFly(not flyEnabled) end)
    return flyGui
end

local flyMenuInstance = taoGiaoDienFly()
-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 4/5)
-- ==========================================
local function bayToiPlayer(targetPlayer)
    if flyToPlayerConn then flyToPlayerConn:Disconnect() end
    targetFlyPlayer = targetPlayer
    isFlyingToPlayer = true
    hienThongBao("Đang bay tốc độ 150 đến " .. targetPlayer.Name .. "...")

    flyToPlayerConn = RunService.RenderStepped:Connect(function(dt)
        if not isFlyingToPlayer or not targetFlyPlayer or not targetFlyPlayer.Character then
            if flyToPlayerConn then flyToPlayerConn:Disconnect(); flyToPlayerConn = nil end
            return
        end

        local myChar = nguoiDung.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetChar = targetFlyPlayer.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

        if myHrp and targetHrp then
            local direction = (targetHrp.Position - myHrp.Position)
            local distance = direction.Magnitude
            if distance < 6 then
                isFlyingToPlayer = false
                if flyToPlayerConn then flyToPlayerConn:Disconnect(); flyToPlayerConn = nil end
                hienThongBao("Đã đến cạnh " .. targetFlyPlayer.Name .. "!")
                return
            end
            myHrp.CFrame = myHrp.CFrame + (direction.Unit * 150 * dt)
            myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function hopServer()
    hienThongBao("Đang tìm server ít người...")
    local placeId = game.PlaceId
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and result and result.data then
        for _, s in ipairs(result.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(placeId, s.id, nguoiDung)
                return
            end
        end
    end
    hienThongBao("Không tìm thấy server phù hợp!")
end

local function rejoinGame()
    hienThongBao("Đang kết nối lại server...")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, nguoiDung)
end

-- Khung chọn cấu hình Base có nút xổ `^` thu gọn mượt mà
local function taoKhungBaseDropdown(parent, baseKey, tenBaseLabel)
    local mainFrame = tao("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.25,
        ClipsDescendants = true,
    }, parent)
    boGoc(mainFrame, 10)
    vien(mainFrame, Mau.Do, 1, 0.4)

    local btnSave = tao("TextButton", {
        Size = UDim2.new(0.65, -10, 0, 32),
        Position = UDim2.new(0, 8, 0, 5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.3,
        Text = "📍 Lưu Tọa Độ " .. tenBaseLabel,
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, mainFrame)
    boGoc(btnSave, 6)
    vien(btnSave, Mau.Do, 1, 0.5)

    local btnToggle = tao("TextButton", {
        Size = UDim2.new(0.3, 0, 0, 32),
        Position = UDim2.new(0.67, 0, 0, 5),
        BackgroundColor3 = Mau.Do,
        BackgroundTransparency = 0.2,
        Text = "Chế độ ^",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, mainFrame)
    boGoc(btnToggle, 6)

    local dropContent = tao("Frame", {
        Position = UDim2.new(0, 8, 0, 42),
        Size = UDim2.new(1, -16, 0, 115),
        BackgroundTransparency = 1,
    }, mainFrame)
    tao("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, dropContent)

    local optModeRow = tao("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 }, dropContent)
    tao("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, optModeRow)

    local btnRun = tao("TextButton", { Size = UDim2.new(0.32, 0, 1, 0), BackgroundColor3 = Mau.NutBam, Text = "🚀 Chạy", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false }, optModeRow)
    boGoc(btnRun, 6); vien(btnRun, Mau.Mo, 1, 0.5)

    local btnFly = tao("TextButton", { Size = UDim2.new(0.32, 0, 1, 0), BackgroundColor3 = Mau.NutBam, Text = "✈️ Bay", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false }, optModeRow)
    boGoc(btnFly, 6); vien(btnFly, Mau.Mo, 1, 0.5)

    local btnTele = tao("TextButton", { Size = UDim2.new(0.32, 0, 1, 0), BackgroundColor3 = Mau.DoDam, Text = "⚡ Tele", TextColor3 = Mau.Trang, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false }, optModeRow)
    boGoc(btnTele, 6); vien(btnTele, Mau.Trang, 1, 0.4)

    local speedFrame = tao("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.3 }, dropContent)
    boGoc(speedFrame, 6)

    tao("TextLabel", { Position = UDim2.new(0, 8, 0, 0), Size = UDim2.new(0.6, 0, 1, 0), BackgroundTransparency = 1, Text = "⚡ Tốc độ bay (1-500):", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, speedFrame)

    local speedBox = tao("TextBox", { Position = UDim2.new(0.62, 0, 0.15, 0), Size = UDim2.new(0.35, 0, 0.7, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.2, Text = "100", TextColor3 = Mau.Do, Font = Enum.Font.GothamBold, TextSize = 11 }, speedFrame)
    boGoc(speedBox, 6)

    local btnGoNow = tao("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Mau.DoDam, Text = "▶️ VỀ " .. string.upper(tenBaseLabel) .. " NGAY", TextColor3 = Mau.Trang, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, dropContent)
    boGoc(btnGoNow, 6)

    local isExpanded = false
    btnToggle.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        hieuDung(mainFrame, 0.25, { Size = UDim2.new(1, 0, 0, isExpanded and 165 or 42) })
        btnToggle.Text = isExpanded and "Thu gọn v" or "Chế độ ^"
    end)

    local function updateModeButtons(selMode)
        baseModes[baseKey] = selMode
        btnRun.BackgroundColor3 = (selMode == "Run") and Mau.DoDam or Mau.NutBam
        btnRun.TextColor3 = (selMode == "Run") and Mau.Trang or Mau.Den
        btnFly.BackgroundColor3 = (selMode == "Fly") and Mau.DoDam or Mau.NutBam
        btnFly.TextColor3 = (selMode == "Fly") and Mau.Trang or Mau.Den
        btnTele.BackgroundColor3 = (selMode == "Tele") and Mau.DoDam or Mau.NutBam
        btnTele.TextColor3 = (selMode == "Tele") and Mau.Trang or Mau.Den
        hienThongBao("Đã chọn chế độ: " .. selMode .. " cho " .. tenBaseLabel)
    end

    btnRun.MouseButton1Click:Connect(function() updateModeButtons("Run") end)
    btnFly.MouseButton1Click:Connect(function() updateModeButtons("Fly") end)
    btnTele.MouseButton1Click:Connect(function() updateModeButtons("Tele") end)

    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text) or 100
        val = math.clamp(val, 1, 500)
        speedBox.Text = tostring(val)
        baseFlySpeeds[baseKey] = val
    end)

    btnSave.MouseButton1Click:Connect(function()
        local char = nguoiDung.Character or nguoiDung.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            basePositions[baseKey] = hrp.Position
            btnSave.Text = "📍 " .. tenBaseLabel .. ": Đã Lưu"
            hienThongBao("Đã lưu tọa độ " .. tenBaseLabel .. "!")
        end
    end)

    btnGoNow.MouseButton1Click:Connect(function() veBaseTheoCauHinh(baseKey, tenBaseLabel) end)
	end
-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 5A/5)
-- ==========================================
local function moBangChonPlayer(parent)
    local frameChon = tao("Frame", { Size = UDim2.new(1, 0, 0, 230), BackgroundColor3 = Color3.fromRGB(230, 230, 240), BackgroundTransparency = 0.45, BorderSizePixel = 0 }, parent)
    boGoc(frameChon, 10); vien(frameChon, Mau.Do, 1, 0.4)

    local searchBox = tao("TextBox", { Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 0, 30), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.25, TextColor3 = Mau.Den, PlaceholderText = "🔍 Nhập tên người chơi...", PlaceholderColor3 = Mau.Mo, Text = "", TextSize = 11, Font = Enum.Font.Gotham }, frameChon)
    boGoc(searchBox, 6); vien(searchBox, Mau.Do, 1, 0.5)

    local scrollPlayers = tao("ScrollingFrame", { Position = UDim2.new(0, 10, 0, 50), Size = UDim2.new(1, -20, 1, -60), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = Mau.Do, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y }, frameChon)
    tao("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, scrollPlayers)

    local function taiDanhSach(filterText)
        for _, child in ipairs(scrollPlayers:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= nguoiDung then
                if filterText == "" or string.find(string.lower(p.Name), string.lower(filterText)) then
                    local pBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.25, Text = "👤 " .. p.Name, TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left }, scrollPlayers)
                    boGoc(pBtn, 6); vien(pBtn, Mau.Do, 1, 0.4)
                    pBtn.MouseButton1Click:Connect(function() bayToiPlayer(p) end)
                end
            end
        end
    end

    taiDanhSach("")
    searchBox:GetPropertyChangedSignal("Text"):Connect(function() taiDanhSach(searchBox.Text) end)
end

local function xayDungTabTeleport(parent)
    tao("TextLabel", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "🎯 CHỌN NGƯỜI CHƠI ĐỂ BAY (TỐC ĐỘ 150):", TextColor3 = Mau.Mo, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, parent)
    moBangChonPlayer(parent)

    local stopFlyBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.Do, BackgroundTransparency = 0.1, Text = "🛑 DỪNG KHẨN CẤP BAY", TextColor3 = Mau.Trang, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false }, parent)
    boGoc(stopFlyBtn, 8); vien(stopFlyBtn, Mau.Trang, 1, 0.3)
    stopFlyBtn.MouseButton1Click:Connect(function() stopWalking(); hienThongBao("🛑 Đã dừng khẩn cấp bay!") end)
end

local function xayDungTabAuto(parent)
    taoKhungBaseDropdown(parent, "Base1", "Nhà 1")
    taoKhungBaseDropdown(parent, "Base2", "Nhà 2")

    local tachBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "📌 Tách Bảng Điều Khiển Nhanh Ra Ngoài", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(tachBtn, 8); vien(tachBtn, Mau.Do, 1, 0.4)

    tachBtn.MouseButton1Click:Connect(function()
        isPoppedOut = not isPoppedOut
        PopoutFrame.Visible = isPoppedOut
        tachBtn.Text = isPoppedOut and "📌 Đã Tách Bảng Ra Ngoài" or "📌 Tách Bảng Điều Khiển Nhanh Ra Ngoài"
        hienThongBao(isPoppedOut and "Đã tách bảng thành công!" or "Đã thu hồi bảng về Menu!")
    end)
end

local function xayDungTabTools(parent)
    local espBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "👁️ Định Vị Player & Khoảng Cách: OFF", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(espBtn, 8); vien(espBtn, Mau.Do, 1, 0.4)

    local noclipBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "👻 Đi Xuyên Tường (Noclip): OFF", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(noclipBtn, 8); vien(noclipBtn, Mau.Do, 1, 0.4)

    local flyMenuBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "✈️ Mở / Đóng Bảng Fly V3", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(flyMenuBtn, 8); vien(flyMenuBtn, Mau.Do, 1, 0.4)

    local speedToggleBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "⚡ Bật Tốc Độ Chạy (Speed): OFF", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(speedToggleBtn, 8); vien(speedToggleBtn, Mau.Do, 1, 0.4)

    local hopBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "🌐 Hop Server Ít Người", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(hopBtn, 8); vien(hopBtn, Mau.Do, 1, 0.4)

    local rejoinBtn = tao("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Mau.NutBam, BackgroundTransparency = 0.25, Text = "🔄 Vào Lại Server (Rejoin)", TextColor3 = Mau.Den, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false }, parent)
    boGoc(rejoinBtn, 8); vien(rejoinBtn, Mau.Do, 1, 0.4)

    espBtn.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espBtn.Text = espEnabled and "👁️ Định Vị Player: ON" or "👁️ Định Vị Player: OFF"; toggleEsp(espEnabled) end)
    noclipBtn.MouseButton1Click:Connect(function() noclipEnabled = not noclipEnabled; noclipBtn.Text = noclipEnabled and "👻 Đi Xuyên Tường: ON" or "👻 Đi Xuyên Tường: OFF"; toggleNoclip(noclipEnabled) end)
    flyMenuBtn.MouseButton1Click:Connect(function() flyMenuInstance.Visible = not flyMenuInstance.Visible end)
    speedToggleBtn.MouseButton1Click:Connect(function() speedEnabled = not speedEnabled; speedToggleBtn.Text = speedEnabled and "⚡ Bật Tốc Độ Chạy: ON" or "⚡ Bật Tốc Độ Chạy: OFF"; toggleSpeed(speedEnabled, speedValue) end)
    hopBtn.MouseButton1Click:Connect(hopServer)
    rejoinBtn.MouseButton1Click:Connect(rejoinGame)
	end
-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 5B/5)
-- ==========================================
local danhSachTrang = {
    TRANG_CHU = {
        TieuDe = "TRANG CHỦ / TỔNG QUAN",
        MoTa = "Chào mừng bạn đến với Kiên Script",
        Muc = {
            {Loai = "banner", TieuDe = "BLACK NEBULA M1", MoTa = "Giao diện trắng trong suốt tối ưu — by Kiên"},
            {Loai = "info", TieuDe = "TRẠNG THÁI", MoTa = "Anti-Lag Super, Auto Base Dropdown, Fly V3 XNEO sẵn sàng."},
        },
    },
    NHAN_DOI = {
        TieuDe = "NHÂN ĐÔI ĐAM / CÀI ĐẶT",
        MoTa = "Chọn hệ số nhân sát thương khi mở trứng",
        Muc = {
            {Loai = "mult", TieuDe = "Hệ số nhân sát thương (1x - 5x)", MoTa = "Tăng tốc độ và tối ưu số lượng đòn đánh mở trứng."},
        },
    },
    AUTO_BASE = {
        TieuDe = "TỰ ĐỘNG VỀ NHÀ (DROPDOWN ^)",
        MoTa = "Tùy chọn Chạy / Bay (1-500) / Teleport",
        Muc = {
            {Loai = "autobase"},
        },
    },
    TELEPORT = {
        TieuDe = "BAY TỚI NGƯỜI CHƠI",
        MoTa = "Chọn player, tìm kiếm tên và bay tốc độ 150",
        Muc = {
            {Loai = "teleport"},
        },
    },
    TOOLS = {
        TieuDe = "TIỆN ÍCH & TĂNG FPS",
        MoTa = "Định vị player, Hop server và tối ưu hóa",
        Muc = {
            {Loai = "tools"},
        },
    },
    THONG_TIN = {
        TieuDe = "THÔNG TIN / TÁC GIẢ",
        MoTa = "Chi tiết dự án cá nhân",
        Muc = {
            {Loai = "info", TieuDe = "CHỦ SỞ HỮU", MoTa = "KIÊN (√12kientomato)"},
            {Loai = "info", TieuDe = "PHIÊN BẢN", MoTa = "Menu M1 Pro - Mobile Optimized"},
        },
    },
}

local function xoaNoiDungCu()
    for _, child in ipairs(khungCuon:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then child:Destroy() end
    end
end

local function taoThe(tieuDeText, moTaText, chieuCao)
    local the = tao("Frame", {
        Size = UDim2.new(1, -4, 0, chieuCao or 68),
        BackgroundColor3 = Color3.fromRGB(235, 235, 245),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
    }, khungCuon)
    boGoc(the, 12)
    vien(the, Mau.Mo, 1, 0.5)

    tao("TextLabel", { Position = UDim2.new(0, 14, 0, 11), Size = UDim2.new(1, -28, 0, 20), BackgroundTransparency = 1, Text = tieuDeText, TextColor3 = Mau.Den, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamBold, TextSize = 12 }, the)
    tao("TextLabel", { Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 22), BackgroundTransparency = 1, Text = moTaText, TextColor3 = Mau.Mo, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true }, the)
    return the
end

local function hienThiTrang(tenTrang)
    local duLieu = danhSachTrang[tenTrang]
    if not duLieu then return end

    tieuDeTrang.Text = duLieu.TieuDe
    moTaTrang.Text = duLieu.MoTa
    xoaNoiDungCu()

    for _, item in ipairs(duLieu.Muc) do
        if item.Loai == "banner" then
            local the = taoThe(item.TieuDe, item.MoTa, 90)
            tao("Frame", { Position = UDim2.new(0, 14, 1, -5), Size = UDim2.new(0.45, 0, 0, 2), BackgroundColor3 = Mau.Do, BorderSizePixel = 0 }, the)
        elseif item.Loai == "mult" then
            local the = taoThe(item.TieuDe, item.MoTa, 85)
            local nutChua = tao("Frame", { Position = UDim2.new(0, 14, 0, 52), Size = UDim2.new(1, -28, 0, 28), BackgroundTransparency = 1 }, the)
            tao("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, nutChua)

            local heSo = {1, 2, 3, 4, 5}
            local danhSachNut = {}

            for _, val in ipairs(heSo) do
                local nutM = tao("TextButton", {
                    Size = UDim2.new(0, 42, 0, 26),
                    BackgroundColor3 = (val == kienCurrentMultiplier) and Mau.DoDam or Mau.NutBam,
                    BackgroundTransparency = (val == kienCurrentMultiplier) and 0.15 or 0.25,
                    Text = val .. "x",
                    TextColor3 = (val == kienCurrentMultiplier) and Mau.Trang or Mau.Den,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    AutoButtonColor = false,
                }, nutChua)
                boGoc(nutM, 6); vien(nutM, Mau.Do, 1, 0.5)
                danhSachNut[val] = nutM

                nutM.Activated:Connect(function()
                    kienCurrentMultiplier = val
                    hienThongBao((val == 1) and "Chế độ 1x: Đã tắt" or ("Đã đổi sang: " .. val .. "x Đam!"))
                    for mVal, btn in pairs(danhSachNut) do
                        btn.BackgroundColor3 = (mVal == val) and Mau.DoDam or Mau.NutBam
                        btn.TextColor3 = (mVal == val) and Mau.Trang or Mau.Den
                    end
                end)
            end
        elseif item.Loai == "autobase" then
            local the = tao("Frame", { Size = UDim2.new(1, -4, 0, 380), BackgroundTransparency = 1 }, khungCuon)
            local container = tao("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, the)
            tao("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, container)
            xayDungTabAuto(container)
        elseif item.Loai == "teleport" then
            local the = tao("Frame", { Size = UDim2.new(1, -4, 0, 310), BackgroundTransparency = 1 }, khungCuon)
            local container = tao("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, the)
            tao("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, container)
            xayDungTabTeleport(container)
        elseif item.Loai == "tools" then
            local the = tao("Frame", { Size = UDim2.new(1, -4, 0, 310), BackgroundTransparency = 1 }, khungCuon)
            local container = tao("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, the)
            tao("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, container)
            xayDungTabTools(container)
        else
            taoThe(item.TieuDe, item.MoTa, 68)
        end
    end
end

local tenNut = {"TRANG_CHU", "NHAN_DOI", "AUTO_BASE", "TELEPORT", "TOOLS", "THONG_TIN"}
local tenHienThi = {"TRANG CHỦ", "NHÂN ĐÔI", "AUTO BASE", "BAY PLAYER", "TIỆN ÍCH", "THÔNG TIN"}
local cacNutBen = {}

for index, name in ipairs(tenNut) do
    local nut = tao("TextButton", {
        Name = name,
        LayoutOrder = index,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = name == "TRANG_CHU" and Mau.DoDam or Color3.fromRGB(245, 245, 255),
        BackgroundTransparency = name == "TRANG_CHU" and 0.15 or 0.45,
        Text = "   " .. tenHienThi[index],
        TextColor3 = name == "TRANG_CHU" and Mau.Trang or Mau.Den,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, thanhBen)
    boGoc(nut, 9)
    cacNutBen[name] = nut

    nut.Activated:Connect(function()
        for _, other in pairs(cacNutBen) do
            other.BackgroundColor3 = Color3.fromRGB(245, 245, 255)
            other.TextColor3 = Mau.Den
        end
        nut.BackgroundColor3 = Mau.DoDam
        nut.TextColor3 = Mau.Trang
        hienThiTrang(name)
    end)
end

nutMoMenu.MouseButton1Click:Connect(function() menuChinh.Visible = not menuChinh.Visible end)
nutDong.MouseButton1Click:Connect(function() menuChinh.Visible = false end)

local kienOldNameCall
kienOldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	if kienEnabled and not kienIsProcessing and kienCurrentMultiplier > 1 and self == EggHitRequest and method == "FireServer" then
		local eggObject = args[1]
		local baseHit = args[2] or 1
		if eggObject then
			kienIsProcessing = true
			local extraCount = kienCurrentMultiplier - 1
			task.spawn(function()
				for i = 1, extraCount do
					self:FireServer(eggObject, baseHit + i)
				end
				task.wait(1.0)
				kienIsProcessing = false
			end)
		end
	end
	return kienOldNameCall(self, ...)
end)

hienThiTrang("TRANG_CHU")
hienThongBao("√12kientomato M1 Pro — Đã sẵn sàng hoạt động!")
	
