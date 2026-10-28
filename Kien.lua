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

local function autoBoostFPS()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = 1
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            end
        end
    end)
end
autoBoostFPS()

local thongBaoLabel = tao("TextLabel", {
    Name = "ThongBaoNoi",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 15),
    Size = UDim2.fromOffset(320, 38),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.25,
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
    hieuDung(thongBaoLabel, 0.2, {TextTransparency = 0, BackgroundTransparency = 0.25})
    
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
    BackgroundTransparency = 0.3,
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
    BackgroundTransparency = 0.22, -- Độ trong suốt siêu cao, nhìn cực kỳ mịn và đẹp
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
    BackgroundTransparency = 0.45,
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
    BackgroundTransparency = 0.3,
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
    BackgroundTransparency = 0.3,
    Text = "🔓",
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, thanhTieuDe)
boGoc(nutKhoa, 8)
vien(nutKhoa, Mau.Mo, 1, 0.5)

nutKhoa.MouseButton1Click:Connect(function()
    isLocked = not isLocked
    if isLocked then
        nutKhoa.Text = "🔒"
        hienThongBao("Đã khóa vị trí Menu!")
    else
        nutKhoa.Text = "🔓"
        hienThongBao("Đã mở khóa Menu!")
    end
end)

local nutDong = tao("TextButton", {
    Position = UDim2.new(1, -45, 0, 16),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.3,
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
    BackgroundTransparency = 0.5,
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
    Size = UDim2.fromOffset(210, 160),
    Position = UDim2.new(0.65, 0, 0.35, 0),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.22,
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
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
}, PopoutFrame)
boGoc(PopoutTopBar, 14)

tao("TextLabel", {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -50, 1, 0),
    BackgroundTransparency = 1,
    Text = "⚡ ĐIỀU KHIỂN NHANH",
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
    BackgroundTransparency = 0.3,
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
    if isPopoutMinimized then
        PopoutContent.Visible = false
        PopoutFrame.Size = UDim2.fromOffset(210, 35)
        nutThuGonPopout.Text = "+"
        hienThongBao("Đã thu gọn bảng điều khiển nhanh!")
    else
        PopoutContent.Visible = true
        PopoutFrame.Size = UDim2.fromOffset(210, 160)
        nutThuGonPopout.Text = "-"
        hienThongBao("Đã phóng to bảng điều khiển nhanh!")
    end
end)

local function taoControlNhanh(parent)
    local btn1 = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "🚀 Chạy Về Base 1",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(btn1, 8)
    vien(btn1, Mau.Do, 1, 0.4)

    local btn2 = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "🚀 Chạy Về Base 2",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(btn2, 8)
    vien(btn2, Mau.Do, 1, 0.4)

    local btn3 = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Mau.Do,
        BackgroundTransparency = 0.1,
        Text = "🛑 Dừng Lại Ngay",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(btn3, 8)
    vien(btn3, Mau.Trang, 1, 0.3)

    return btn1, btn2, btn3
end

local g1, g2, g3 = taoControlNhanh(PopoutContent)

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
    hienThongBao("Đang tự chạy về " .. tenBase .. "...")

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

g1.MouseButton1Click:Connect(function()
    hieuDung(g1, 0.1, {BackgroundColor3 = Mau.DoDam})
    task.delay(0.1, function() hieuDung(g1, 0.1, {BackgroundColor3 = Mau.NutBam}) end)
    if not basePositions.Base1 then hienThongBao("Chưa lưu tọa độ Base 1!"); return end
    startMoveTo(basePositions.Base1, "Base 1")
end)

g2.MouseButton1Click:Connect(function()
    hieuDung(g2, 0.1, {BackgroundColor3 = Mau.DoDam})
    task.delay(0.1, function() hieuDung(g2, 0.1, {BackgroundColor3 = Mau.NutBam}) end)
    if not basePositions.Base2 then hienThongBao("Chưa lưu tọa độ Base 2!"); return end
    startMoveTo(basePositions.Base2, "Base 2")
end)

g3.MouseButton1Click:Connect(function()
    hieuDung(g3, 0.1, {BackgroundColor3 = Color3.fromRGB(150, 10, 30)})
    task.delay(0.1, function() hieuDung(g3, 0.1, {BackgroundColor3 = Mau.Do}) end)
    stopWalking()
    hienThongBao("🛑 Đã dừng lại ngay lập tức!")
end)
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

-- FLY V3 TỐI ƯU: Kéo hướng nào bay chuẩn hướng đó theo góc nhìn camera, tốc độ cực kỳ ổn định, mượt mà
local function taoGiaoDienFly()
    local flyGui = tao("Frame", {
        Name = "FlyGuiKien",
        Size = UDim2.fromOffset(190, 110),
        Position = UDim2.new(0.05, 0, 0.55, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.22,
        BorderSizePixel = 0,
        Visible = false,
    }, screenGui)
    boGoc(flyGui, 14)
    vien(flyGui, Mau.Do, 1.5, 0.3)
    makeDraggable(flyGui)

    local flyTop = tao("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(235, 235, 245),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    }, flyGui)
    boGoc(flyTop, 14)

    tao("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        Text = "✈️ FLY V3 MENU",
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
    tao("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, flyBody)

    local btnMiniFly = tao("TextButton", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(1, -28, 0, 3),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.3,
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
        if isFlyMinimized then
            flyBody.Visible = false
            flyGui.Size = UDim2.fromOffset(190, 34)
            btnMiniFly.Text = "+"
            hienThongBao("Đã thu gọn bảng Fly!")
        else
            flyBody.Visible = true
            flyGui.Size = UDim2.fromOffset(190, 110)
            btnMiniFly.Text = "-"
            hienThongBao("Đã mở rộng bảng Fly!")
        end
    end)

    local flyToggleBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "Fly: OFF",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, flyBody)
    boGoc(flyToggleBtn, 8)
    vien(flyToggleBtn, Mau.Do, 1, 0.4)

    local speedControlRow = tao("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    }, flyBody)
    tao("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, speedControlRow)

    local btnGiam = tao("TextButton", {
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "(-)",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, speedControlRow)
    boGoc(btnGiam, 6)
    vien(btnGiam, Mau.Mo, 1, 0.5)

    local lblSpeed = tao("TextLabel", {
        Size = UDim2.new(0.38, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Tốc: 50",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
    }, speedControlRow)

    local btnTang = tao("TextButton", {
        Size = UDim2.new(0.3, 0, 1, 0),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "(+)",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, speedControlRow)
    boGoc(btnTang, 6)
    vien(btnTang, Mau.Mo, 1, 0.5)

    btnTang.MouseButton1Click:Connect(function()
        hieuDung(btnTang, 0.1, {BackgroundColor3 = Mau.DoDam})
        task.delay(0.1, function() hieuDung(btnTang, 0.1, {BackgroundColor3 = Mau.NutBam}) end)
        flySpeed = math.min(500, flySpeed + 25)
        lblSpeed.Text = "Tốc: " .. flySpeed
        hienThongBao("Tốc độ bay: " .. flySpeed)
    end)

    btnGiam.MouseButton1Click:Connect(function()
        hieuDung(btnGiam, 0.1, {BackgroundColor3 = Mau.DoDam})
        task.delay(0.1, function() hieuDung(btnGiam, 0.1, {BackgroundColor3 = Mau.NutBam}) end)
        flySpeed = math.max(10, flySpeed - 25)
        lblSpeed.Text = "Tốc: " .. flySpeed
        hienThongBao("Tốc độ bay: " .. flySpeed)
    end)

    local function toggleFly(state)
        flyEnabled = state
        if flyEnabled then
            flyToggleBtn.Text = "Fly: ON"
            flyToggleBtn.BackgroundColor3 = Mau.DoDam
            hienThongBao("Đã Bật chế độ Fly V3 (Đỉnh cao)!")

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

                    if moveDir.Magnitude > 0 then
                        -- Bay theo đúng hướng góc nhìn camera (hướng nhìn và nút di chuyển joystick)
                        local camCF = cam.CFrame
                        vel = (camCF.LookVector * moveDir.Z + camCF.RightVector * moveDir.X + Vector3.new(0, moveDir.Y, 0)).Unit * flySpeed
                    end
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

    flyToggleBtn.MouseButton1Click:Connect(function()
        toggleFly(not flyEnabled)
    end)

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

local function moBangChonPlayer(parent)
    local frameChon = tao("Frame", {
        Size = UDim2.new(1, 0, 0, 230),
        BackgroundColor3 = Color3.fromRGB(230, 230, 240),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
    }, parent)
    boGoc(frameChon, 10)
    vien(frameChon, Mau.Do, 1, 0.4)

    local searchBox = tao("TextBox", {
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 30),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.2,
        TextColor3 = Mau.Den,
        PlaceholderText = "🔍 Nhập tên người chơi để tìm...",
        PlaceholderColor3 = Mau.Mo,
        Text = "",
        TextSize = 11,
        Font = Enum.Font.Gotham,
    }, frameChon)
    boGoc(searchBox, 6)
    vien(searchBox, Mau.Do, 1, 0.5)

    local scrollPlayers = tao("ScrollingFrame", {
        Position = UDim2.new(0, 10, 0, 50),
        Size = UDim2.new(1, -20, 1, -60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Mau.Do,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, frameChon)
    tao("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, scrollPlayers)

    local function taiDanhSach(filterText)
        for _, child in ipairs(scrollPlayers:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= nguoiDung then
                if filterText == "" or string.find(string.lower(p.Name), string.lower(filterText)) then
                    local pBtn = tao("TextButton", {
                        Size = UDim2.new(1, 0, 0, 32),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.2,
                        Text = "👤 " .. p.Name,
                        TextColor3 = Mau.Den,
                        Font = Enum.Font.GothamBold,
                        TextSize = 11,
                        AutoButtonColor = false,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }, scrollPlayers)
                    boGoc(pBtn, 6)
                    vien(pBtn, Mau.Do, 1, 0.4)

                    pBtn.MouseButton1Click:Connect(function()
                        hieuDung(pBtn, 0.1, {BackgroundColor3 = Mau.DoDam})
                        task.delay(0.1, function() hieuDung(pBtn, 0.1, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}) end)
                        bayToiPlayer(p)
                    end)
                end
            end
        end
    end

    taiDanhSach("")
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        taiDanhSach(searchBox.Text)
    end)
end

local function xayDungTabTools(parent)
    local espBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "👁️ Định Vị Player & Khoảng Cách: OFF",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(espBtn, 8)
    vien(espBtn, Mau.Do, 1, 0.4)

    local noclipBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "👻 Đi Xuyên Tường (Noclip): OFF",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(noclipBtn, 8)
    vien(noclipBtn, Mau.Do, 1, 0.4)

    local flyMenuBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "✈️ Mở / Đóng Bảng Fly V3",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(flyMenuBtn, 8)
    vien(flyMenuBtn, Mau.Do, 1, 0.4)

    local speedFrame = tao("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
    }, parent)
    boGoc(speedFrame, 8)
    vien(speedFrame, Mau.Do, 1, 0.4)

    tao("TextLabel", {
        Position = UDim2.new(0, 10, 0, 4),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Text = "⚡ Tốc Độ Chạy (Tối đa 500):",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, speedFrame)

    local speedBox = tao("TextBox", {
        Position = UDim2.new(0, 10, 0, 22),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Text = "50",
        TextColor3 = Mau.Do,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
    }, speedFrame)

    speedBox.FocusLost:Connect(function()
        local val = tonumber(speedBox.Text)
        if val then
            speedValue = math.clamp(val, 16, 500)
            speedBox.Text = tostring(speedValue)
            if speedEnabled then toggleSpeed(true, speedValue) end
        end
    end)

    local speedToggleBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "⚡ Bật Tốc Độ Chạy (Speed): OFF",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(speedToggleBtn, 8)
    vien(speedToggleBtn, Mau.Do, 1, 0.4)

    local hopBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "🌐 Hop Server Ít Người",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(hopBtn, 8)
    vien(hopBtn, Mau.Do, 1, 0.4)

    local rejoinBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "🔄 Vào Lại Server (Rejoin)",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parent)
    boGoc(rejoinBtn, 8)
    vien(rejoinBtn, Mau.Do, 1, 0.4)

    espBtn.MouseButton1Click:Connect(function()
        espEnabled = not espEnabled
        espBtn.Text = espEnabled and "👁️ Định Vị Player & Khoảng Cách: ON" or "👁️ Định Vị Player & Khoảng Cách: OFF"
        toggleEsp(espEnabled)
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        noclipEnabled = not noclipEnabled
        noclipBtn.Text = noclipEnabled and "👻 Đi Xuyên Tường (Noclip): ON" or "👻 Đi Xuyên Tường (Noclip): OFF"
        toggleNoclip(noclipEnabled)
    end)

    flyMenuBtn.MouseButton1Click:Connect(function()
        flyMenuInstance.Visible = not flyMenuInstance.Visible
        hienThongBao(flyMenuInstance.Visible and "Đã mở bảng Fly V3!" or "Đã đóng bảng Fly V3!")
    end)

    speedToggleBtn.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        speedToggleBtn.Text = speedEnabled and "⚡ Bật Tốc Độ Chạy (Speed): ON" or "⚡ Bật Tốc Độ Chạy (Speed): OFF"
        toggleSpeed(speedEnabled, speedValue)
    end)

    hopBtn.MouseButton1Click:Connect(hopServer)
    rejoinBtn.MouseButton1Click:Connect(rejoinGame)
	end
-- ==========================================
-- SCRIPT: √12kientomato MENU M1 PRO (PHẦN 5A/5)
-- ==========================================
local function xayDungTabTeleport(parent)
    tao("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "🎯 CHỌN NGƯỜI CHƠI ĐỂ BAY (TỐC ĐỘ 150):",
        TextColor3 = Mau.Mo,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)

    moBangChonPlayer(parent)

    local stopFlyBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.Do,
        BackgroundTransparency = 0.1,
        Text = "🛑 DỪNG KHẨN CẤP BAY",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, parent)
    boGoc(stopFlyBtn, 8)
    vien(stopFlyBtn, Mau.Trang, 1, 0.3)

    stopFlyBtn.MouseButton1Click:Connect(function()
        stopWalking()
        hienThongBao("🛑 Đã dừng khẩn cấp bay!")
    end)
end

local function xayDungTabAuto(parent)
    local save1 = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "📍 Lưu Tọa Độ Vị Trí 1",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, parent)
    boGoc(save1, 8)
    vien(save1, Mau.Do, 1, 0.4)

    local save2 = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "📍 Lưu Tọa Độ Vị Trí 2",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, parent)
    boGoc(save2, 8)
    vien(save2, Mau.Do, 1, 0.4)

    local tachBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Mau.NutBam,
        BackgroundTransparency = 0.2,
        Text = "📌 Tách Bảng Điều Khiển Nhanh Ra Ngoài",
        TextColor3 = Mau.Den,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, parent)
    boGoc(tachBtn, 8)
    vien(tachBtn, Mau.Do, 1, 0.4)

    local lbl = tao("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "Base 1: Chưa lưu | Base 2: Chưa lưu",
        TextColor3 = Mau.Mo,
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
    }, parent)

    save1.MouseButton1Click:Connect(function()
        local char = nguoiDung.Character or nguoiDung.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            basePositions.Base1 = hrp.Position
            save1.Text = "📍 Vị Trí 1: Đã lưu"
            lbl.Text = "Base 1: Đã lưu | Base 2: " .. (basePositions.Base2 and "Đã lưu" or "Chưa")
            hienThongBao("Đã lưu Base 1 thành công!")
        end
    end)

    save2.MouseButton1Click:Connect(function()
        local char = nguoiDung.Character or nguoiDung.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            basePositions.Base2 = hrp.Position
            save2.Text = "📍 Vị Trí 2: Đã lưu"
            lbl.Text = "Base 1: " .. (basePositions.Base1 and "Đã lưu" or "Chưa") .. " | Base 2: Đã lưu"
            hienThongBao("Đã lưu Base 2 thành công!")
        end
    end)

    tachBtn.MouseButton1Click:Connect(function()
        isPoppedOut = not isPoppedOut
        if isPoppedOut then
            PopoutFrame.Visible = true
            tachBtn.Text = "📌 Đã Tách Bảng Ra Ngoài"
            hienThongBao("Đã tách bảng thành công!")
        else
            PopoutFrame.Visible = false
            tachBtn.Text = "📌 Tách Bảng Điều Khiển Nhanh Ra Ngoài"
            hienThongBao("Đã thu hồi bảng về Menu!")
        end
    end)
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
            {Loai = "info", TieuDe = "TRẠNG THÁI", MoTa = "Tự động tăng FPS, Nhặt đồ nhanh, Định vị & Bay Player sẵn sàng."},
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
        TieuDe = "TỰ ĐỘNG CHẠY VỊ TRÍ",
        MoTa = "Lưu tọa độ vị trí và bật bảng chạy nhanh",
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

    tao("TextLabel", {
        Position = UDim2.new(0, 14, 0, 11),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text = tieuDeText,
        TextColor3 = Mau.Den,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
    }, the)

    tao("TextLabel", {
        Position = UDim2.new(0, 14, 0, 34),
        Size = UDim2.new(1, -28, 0, 22),
        BackgroundTransparency = 1,
        Text = moTaText,
        TextColor3 = Mau.Mo,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
    }, the)
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
            tao("Frame", {
                Position = UDim2.new(0, 14, 1, -5),
                Size = UDim2.new(0.45, 0, 0, 2),
                BackgroundColor3 = Mau.Do,
                BorderSizePixel = 0,
            }, the)
        elseif item.Loai == "mult" then
            local the = taoThe(item.TieuDe, item.MoTa, 85)
            local nutChua = tao("Frame", {
                Position = UDim2.new(0, 14, 0, 52),
                Size = UDim2.new(1, -28, 0, 28),
                BackgroundTransparency = 1,
            }, the)

            tao("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, nutChua)

            local heSo = {1, 2, 3, 4, 5}
            local danhSachNut = {}

            for _, val in ipairs(heSo) do
                local nutM = tao("TextButton", {
                    Size = UDim2.new(0, 42, 0, 26),
                    BackgroundColor3 = (val == kienCurrentMultiplier) and Mau.DoDam or Mau.NutBam,
                    BackgroundTransparency = (val == kienCurrentMultiplier) and 0.1 or 0.2,
                    Text = val .. "x",
                    TextColor3 = (val == kienCurrentMultiplier) and Mau.Trang or Mau.Den,
                    Font = Enum.Font.GothamBold,
                    TextSize = 12,
                    AutoButtonColor = false,
                }, nutChua)
                boGoc(nutM, 6)
                vien(nutM, Mau.Do, 1, 0.5)
                danhSachNut[val] = nutM

                nutM.Activated:Connect(function()
                    kienCurrentMultiplier = val
                    if val == 1 then hienThongBao("Chế độ 1x: Đã tắt (Bình thường)") else hienThongBao("Đã đổi sang: " .. val .. "x Đam!") end
                    for mVal, btn in pairs(danhSachNut) do
                        if mVal == val then
                            hieuDung(btn, 0.15, {BackgroundColor3 = Mau.DoDam})
                            btn.TextColor3 = Mau.Trang
                        else
                            hieuDung(btn, 0.15, {BackgroundColor3 = Mau.NutBam})
                            btn.TextColor3 = Mau.Den
                        end
                    end
                end)
            end
        elseif item.Loai == "autobase" then
            local the = tao("Frame", { Size = UDim2.new(1, -4, 0, 180), BackgroundTransparency = 1 }, khungCuon)
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
        BackgroundTransparency = name == "TRANG_CHU" and 0.1 or 0.4,
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
            hieuDung(other, 0.15, {BackgroundColor3 = Color3.fromRGB(245, 245, 255)})
            other.TextColor3 = Mau.Den
        end
        hieuDung(nut, 0.15, {BackgroundColor3 = Mau.DoDam})
        nut.TextColor3 = Mau.Trang
        hienThiTrang(name)
    end)
end

nutMoMenu.MouseButton1Click:Connect(function()
    menuChinh.Visible = not menuChinh.Visible
end)

nutDong.MouseButton1Click:Connect(function()
    menuChinh.Visible = false
end)

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
hienThongBao("√12kientomato M1 Pro — Sẵn sàng hoạt động!")
	
