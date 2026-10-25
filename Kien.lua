--[[ √12kientomato — M1 BLACK NEBULA (PHẦN 1) ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local nguoiDung = Players.LocalPlayer
local playerGui = nguoiDung:WaitForChild("PlayerGui")
local EggHitRequest = ReplicatedStorage:WaitForChild("EggHitRequest")

local kienEnabled = true
local kienIsProcessing = false
local kienCurrentMultiplier = 4
local basePositions = { Base1 = nil, Base2 = nil }
local selectedBase = "Base1"
local isAutoWalking = false
local moveConnection = nil
local isPoppedOut = false
local isLocked = false

pcall(function()
    local cu = playerGui:FindFirstChild("KienMenuM1")
    if cu then cu:Destroy() end
end)

local Mau = {
    Nen = Color3.fromRGB(10, 10, 14),
    Panel = Color3.fromRGB(17, 17, 23),
    The = Color3.fromRGB(24, 24, 32),
    Do = Color3.fromRGB(255, 48, 75),
    DoDam = Color3.fromRGB(120, 20, 40),
    Trang = Color3.fromRGB(245, 245, 250),
    Mo = Color3.fromRGB(145, 145, 160),
    XanhNhe = Color3.fromRGB(70, 230, 155),
}

local function tao(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function boGoc(parent, radius)
    tao("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function vien(parent, color, thickness, transparency)
    return tao("UIStroke", { Color = color or Mau.Do, Thickness = thickness or 1, Transparency = transparency or 0 }, parent)
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

local screenGui = tao("ScreenGui", {
    Name = "KienMenuM1",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local thongBaoLabel = tao("TextLabel", {
    Name = "ThongBaoNoi",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 12),
    Size = UDim2.fromOffset(240, 32),
    BackgroundColor3 = Mau.The,
    TextColor3 = Mau.XanhNhe,
    Text = "",
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Visible = false,
    ZIndex = 100,
}, screenGui)
boGoc(thongBaoLabel, 8)
vien(thongBaoLabel, Mau.Do, 1)

local tbPhienBan = 0
local function hienThongBao(noiDung)
    tbPhienBan += 1
    local phienBanHienTai = tbPhienBan
    thongBaoLabel.Text = "  " .. noiDung
    thongBaoLabel.Visible = true
    thongBaoLabel.TextTransparency = 1
    thongBaoLabel.BackgroundTransparency = 1
    hieuDung(thongBaoLabel, 0.2, {TextTransparency = 0, BackgroundTransparency = 0.2})
    task.delay(1.2, function()
        if tbPhienBan == phienBanHienTai then
            hieuDung(thongBaoLabel, 0.2, {TextTransparency = 1, BackgroundTransparency = 1})
            task.wait(0.22)
            if tbPhienBan == phienBanHienTai then thongBaoLabel.Visible = false end
        end
    end)
end

local nutMoMenu = tao("TextButton", {
    Name = "NutMoMenu",
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.new(0, 18, 0.5, -27),
    BackgroundColor3 = Mau.Nen,
    Text = "K",
    TextColor3 = Mau.Do,
    TextSize = 25,
    Font = Enum.Font.GothamBlack,
    AutoButtonColor = false,
}, screenGui)
boGoc(nutMoMenu, 16)
vien(nutMoMenu, Mau.Do, 2)
makeDraggable(nutMoMenu)

local menuChinh = tao("Frame", {
    Name = "MenuChinh",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.fromOffset(650, 420),
    BackgroundColor3 = Mau.Nen,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
}, screenGui)
boGoc(menuChinh, 16)
vien(menuChinh, Mau.Do, 1.5)
makeDraggable(menuChinh)

local tyLeGiaoDien = tao("UIScale", { Scale = 1 }, menuChinh)
local function capNhatTyLe()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    tyLeGiaoDien.Scale = math.min(viewport.X / 690, viewport.Y / 460, 1)
end
capNhatTyLe()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(capNhatTyLe)
end

local thanhTieuDe = tao("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Mau.Panel,
    BorderSizePixel = 0,
}, menuChinh)

tao("Frame", {
    Position = UDim2.new(0, 0, 1, -2),
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Mau.Do,
    BorderSizePixel = 0,
}, thanhTieuDe)

local logo = tao("Frame", {
    Position = UDim2.new(0, 17, 0.5, -19),
    Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = Mau.DoDam,
}, thanhTieuDe)
boGoc(logo, 12)
vien(logo, Mau.Do, 1)

tao("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "K",
    TextColor3 = Mau.Trang,
    Font = Enum.Font.GothamBlack,
    TextSize = 23,
}, logo)

tao("TextLabel", {
    Position = UDim2.new(0, 65, 0, 10),
    Size = UDim2.new(0, 280, 0, 25),
    BackgroundTransparency = 1,
    Text = "KIÊN  |  MENU M1 PRO",
    TextColor3 = Mau.Trang,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBlack,
    TextSize = 19,
}, thanhTieuDe)

tao("TextLabel", {
    Position = UDim2.new(0, 66, 0, 35),
    Size = UDim2.new(0, 320, 0, 17),
    BackgroundTransparency = 1,
    Text = "BLACK NEBULA  •  √12kientomato  •  by ? Tiktok",
    TextColor3 = Mau.Do,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
}, thanhTieuDe)

local nutKhoa = tao("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -80, 0, 15),
    BackgroundColor3 = Mau.The,
    Text = "🔓",
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, thanhTieuDe)
boGoc(nutKhoa, 9)

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
    Position = UDim2.new(1, -45, 0, 15),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = Mau.The,
    Text = "×",
    TextColor3 = Mau.Do,
    TextSize = 23,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, thanhTieuDe)
boGoc(nutDong, 9)

local thanhBen = tao("Frame", {
    Position = UDim2.new(0, 0, 0, 66),
    Size = UDim2.new(0, 155, 1, -66),
    BackgroundColor3 = Mau.Panel,
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
    Size = UDim2.new(1, -40, 0, 30),
    BackgroundTransparency = 1,
    Text = "TRANG CHỦ / TỔNG QUAN",
    TextColor3 = Mau.Trang,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 17,
}, khungNoiDung)

local moTaTrang = tao("TextLabel", {
    Position = UDim2.new(0, 20, 0, 44),
    Size = UDim2.new(1, -40, 0, 20),
    BackgroundTransparency = 1,
    Text = "Không gian của bạn. Phong cách của bạn.",
    TextColor3 = Mau.Mo,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.Gotham,
    TextSize = 11,
}, khungNoiDung)

local khungCuon = tao("ScrollingFrame", {
    Position = UDim2.new(0, 15, 0, 75),
    Size = UDim2.new(1, -30, 1, -88),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Mau.Do,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, khungNoiDung)

tao("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, khungCuon)

local PopoutFrame = tao("Frame", {
    Name = "PopoutFrame",
    Size = UDim2.fromOffset(220, 260),
    Position = UDim2.new(0.65, 0, 0.35, 0),
    BackgroundColor3 = Mau.Nen,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
}, screenGui)
boGoc(PopoutFrame, 14)
vien(PopoutFrame, Mau.Do, 1.5)
makeDraggable(PopoutFrame)

local PopoutTopBar = tao("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundColor3 = Mau.Panel,
    BorderSizePixel = 0,
}, PopoutFrame)

tao("TextLabel", {
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -12, 1, 0),
    BackgroundTransparency = 1,
    Text = "📌 BẢNG ĐIỀU KHIỂN AUTO CHẠY",
    TextColor3 = Mau.Trang,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
}, PopoutTopBar)

local PopoutContent = tao("Frame", {
    Position = UDim2.new(0, 10, 0, 45),
    Size = UDim2.new(1, -20, 1, -55),
    BackgroundTransparency = 1,
}, PopoutFrame)

tao("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, PopoutContent)
--[[ √12kientomato — M1 BLACK NEBULA (PHẦN 2) ]]
local danhSachTrang = {
    TRANG_CHU = {
        TieuDe = "TRANG CHỦ / TỔNG QUAN",
        MoTa = "Chào mừng bạn đến với Kiên Script",
        Muc = {
            {Loai = "banner", TieuDe = "BLACK NEBULA M1", MoTa = "Giao diện đỏ đen độc quyền — by ? Tiktok"},
            {Loai = "info", TieuDe = "TRẠNG THÁI", MoTa = "Hệ thống nhân đôi sát thương & Auto Base sẵn sàng."},
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
        MoTa = "Lưu tọa độ Base 1, Base 2 và tự động di chuyển",
        Muc = {
            {Loai = "autobase"},
        },
    },
    THONG_TIN = {
        TieuDe = "THÔNG TIN / TÁC GIẢ",
        MoTa = "Chi tiết dự án cá nhân",
        Muc = {
            {Loai = "info", TieuDe = "CHỦ SỞ HỮU", MoTa = "KIÊN (√12kientomato)"},
            {Loai = "info", TieuDe = "CHỮ KÝ", MoTa = "by ? Tiktok"},
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
        BackgroundColor3 = Mau.The,
        BorderSizePixel = 0,
    }, khungCuon)
    boGoc(the, 12)
    vien(the, Mau.DoDam, 1, 0.35)

    tao("TextLabel", {
        Position = UDim2.new(0, 14, 0, 11),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text = tieuDeText,
        TextColor3 = Mau.Trang,
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

local PopoutBtn, SaveBase1Btn, SaveBase2Btn, SelectBaseBtn, AutoWalkBtn, StopWalkBtn, StatusLabel

local function xayDungChucNangAuto(parentFrame)
    PopoutBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(100, 50, 150),
        Text = "📌 Tách Bảng Auto Ra Ngoài",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parentFrame)
    boGoc(PopoutBtn, 8)
    vien(PopoutBtn, Mau.Do, 1, 0.5)

    SaveBase1Btn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Mau.Panel,
        Text = "📍 Lưu Vị Trí Base 1",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parentFrame)
    boGoc(SaveBase1Btn, 8)
    vien(SaveBase1Btn, Mau.Do, 1, 0.5)

    SaveBase2Btn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Mau.Panel,
        Text = "📍 Lưu Vị Trí Base 2",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parentFrame)
    boGoc(SaveBase2Btn, 8)
    vien(SaveBase2Btn, Mau.Do, 1, 0.5)

    SelectBaseBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Mau.DoDam,
        Text = "🎯 Đang Chọn: Base 1",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, parentFrame)
    boGoc(SelectBaseBtn, 8)
    vien(SelectBaseBtn, Mau.Do, 1, 0.5)

    AutoWalkBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(40, 140, 80),
        Text = "🚀 BẮT ĐẦU TỰ CHẠY: OFF",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, parentFrame)
    boGoc(AutoWalkBtn, 8)
    vien(AutoWalkBtn, Mau.Trang, 1, 0.3)

    StopWalkBtn = tao("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(180, 40, 40),
        Text = "🛑 DỪNG LẠI NGAY LẬP TỨC",
        TextColor3 = Mau.Trang,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
    }, parentFrame)
    boGoc(StopWalkBtn, 8)
    vien(StopWalkBtn, Mau.Trang, 1, 0.3)

    StatusLabel = tao("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "Base 1: Chưa lưu | Base 2: Chưa lưu",
        TextColor3 = Mau.Mo,
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
    }, parentFrame)
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
                    BackgroundColor3 = (val == kienCurrentMultiplier) and Mau.DoDam or Mau.Panel,
                    Text = val .. "x",
                    TextColor3 = Mau.Trang,
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
                        if mVal == val then hieuDung(btn, 0.15, {BackgroundColor3 = Mau.DoDam}) else hieuDung(btn, 0.15, {BackgroundColor3 = Mau.Panel}) end
                    end
                end)
            end
        elseif item.Loai == "autobase" then
            local the = tao("Frame", { Size = UDim2.new(1, -4, 0, 250), BackgroundTransparency = 1 }, khungCuon)
            local container = tao("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, the)
            tao("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, container)
            xayDungChucNangAuto(container)
            ganSuKienAutoChay()
        else
            taoThe(item.TieuDe, item.MoTa, 68)
        end
    end
end

xayDungChucNangAuto(PopoutContent)

PopoutBtn.MouseButton1Click:Connect(function()
    isPoppedOut = not isPoppedOut
    if isPoppedOut then
        PopoutFrame.Visible = true
        PopoutBtn.Text = "📌 Đã Tách Bảng Ra Ngoài"
        hienThongBao("Đã tách bảng Auto thành công!")
    else
        PopoutFrame.Visible = false
        PopoutBtn.Text = "📌 Tách Bảng Auto Ra Ngoài"
        hienThongBao("Đã thu hồi bảng Auto về Menu!")
    end
end)

local tenNut = {"TRANG_CHU", "NHAN_DOI", "AUTO_BASE", "THONG_TIN"}
local tenHienThi = {"TRANG CHỦ", "NHÂN ĐÔI", "AUTO BASE", "THÔNG TIN"}
local cacNutBen = {}

for index, name in ipairs(tenNut) do
    local nut = tao("TextButton", {
        Name = name,
        LayoutOrder = index,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = name == "TRANG_CHU" and Mau.DoDam or Mau.Panel,
        Text = "   " .. tenHienThi[index],
        TextColor3 = name == "TRANG_CHU" and Mau.Trang or Mau.Mo,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
    }, thanhBen)
    boGoc(nut, 9)
    cacNutBen[name] = nut

    nut.Activated:Connect(function()
        for _, other in pairs(cacNutBen) do
            hieuDung(other, 0.15, {BackgroundColor3 = Mau.Panel})
            other.TextColor3 = Mau.Mo
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

local function stopWalking()
    isAutoWalking = false
    if AutoWalkBtn then
        AutoWalkBtn.Text = "🚀 BẮT ĐẦU TỰ CHẠY: OFF"
        AutoWalkBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
    end
    if moveConnection then
        moveConnection:Disconnect()
        moveConnection = nil
    end
    local char = nguoiDung.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid:Move(Vector3.new(0, 0, 0), false) end
end

local function startAbsoluteWorldMovement()
    if moveConnection then moveConnection:Disconnect() end
    moveConnection = RunService.RenderStepped:Connect(function()
        if not isAutoWalking then stopWalking() return end
        local char = nguoiDung.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local targetPos = basePositions[selectedBase]

        if not targetPos or not humanoid or not hrp or humanoid.Health <= 0 then
            stopWalking()
            hienThongBao("Đã dừng: Mất tọa độ hoặc nhân vật chết!")
            return
        end

        local currentPos = hrp.Position
        local dirVector = Vector3.new(targetPos.X - currentPos.X, 0, targetPos.Z - currentPos.Z)
        if dirVector.Magnitude < 4 then
            stopWalking()
            hienThongBao("Đã đến " .. selectedBase .. " thành công!")
            return
        end
        humanoid:Move(dirVector.Unit, false)
    end)
end

function ganSuKienAutoChay()
    if SaveBase1Btn then
        SaveBase1Btn.MouseButton1Click:Connect(function()
            local char = nguoiDung.Character or nguoiDung.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                basePositions.Base1 = hrp.Position
                SaveBase1Btn.Text = "📍 Base 1: Đã lưu vị trí"
                StatusLabel.Text = "Base 1: Đã lưu | Base 2: " .. (basePositions.Base2 and "Đã lưu" or "Chưa")
                hienThongBao("Đã lưu Base 1 thành công!")
            end
        end)
    end

    if SaveBase2Btn then
        SaveBase2Btn.MouseButton1Click:Connect(function()
            local char = nguoiDung.Character or nguoiDung.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                basePositions.Base2 = hrp.Position
                SaveBase2Btn.Text = "📍 Base 2: Đã lưu vị trí"
                StatusLabel.Text = "Base 1: " .. (basePositions.Base1 and "Đã lưu" or "Chưa") .. " | Base 2: Đã lưu"
                hienThongBao("Đã lưu Base 2 thành công!")
            end
        end)
    end

    if SelectBaseBtn then
        SelectBaseBtn.MouseButton1Click:Connect(function()
            if selectedBase == "Base1" then
                selectedBase = "Base2"
                SelectBaseBtn.Text = "🎯 Đang Chọn: Base 2"
                hienThongBao("Đã chuyển sang: Base 2")
            else
                selectedBase = "Base1"
                SelectBaseBtn.Text = "🎯 Đang Chọn: Base 1"
                hienThongBao("Đã chuyển sang: Base 1")
            end
        end)
    end

    if AutoWalkBtn then
        AutoWalkBtn.MouseButton1Click:Connect(function()
            if not basePositions[selectedBase] then
                hienThongBao("Chưa lưu tọa độ " .. selectedBase .. "!")
                return
            end
            isAutoWalking = not isAutoWalking
            if isAutoWalking then
                AutoWalkBtn.Text = "🚀 BẮT ĐẦU TỰ CHẠY: ON"
                AutoWalkBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                hienThongBao("Đang chạy đến " .. selectedBase .. "...")
                startAbsoluteWorldMovement()
            else
                stopWalking()
                hienThongBao("Đã tắt tự chạy!")
            end
        end)
    end

    if StopWalkBtn then
        StopWalkBtn.MouseButton1Click:Connect(function()
            stopWalking()
            hienThongBao("🛑 Đã dừng ngay lập tức!")
        end)
    end
end

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
hienThongBao("√12kientomato M1 — Sẵn sàng hoạt động!")
	
