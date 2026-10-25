--[[
    KIÊN SCRIPT — BẢN GỐC GIAO DIỆN M1 ĐỎ ĐEN (FULL TIẾNG VIỆT)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local nguoiDung = Players.LocalPlayer
local playerGui = nguoiDung:WaitForChild("PlayerGui")
local EggHitRequest = ReplicatedStorage:WaitForChild("EggHitRequest")

local kienEnabled = true
local kienIsProcessing = false
local kienCurrentMultiplier = 4

-- Xóa menu cũ nếu có
local cu = playerGui:FindFirstChild("KienMenuM1")
if cu then cu:Destroy() end

--// BẢNG MÀU GIAO DIỆN M1 ĐỎ ĐEN
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
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function boGoc(parent, radius)
    tao("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, parent)
end

local function vien(parent, color, thickness, transparency)
    return tao("UIStroke", {
        Color = color or Mau.Do,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function hieuDung(obj, duration, props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local screenGui = tao("ScreenGui", {
    Name = "KienMenuM1",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

--// THÔNG BÁO NỔI Ở GIỮA ĐỈNH MÀN HÌNH
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
            if tbPhienBan == phienBanHienTai then
                thongBaoLabel.Visible = false
            end
        end
    end)
end

--// NÚT MỞ MENU NỔI TRÊN MÀN HÌNH (CHỮ K)
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

--// CỬA SỔ MENU CHÍNH M1 (ĐỎ ĐEN)
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

--// THANH TIÊU ĐỀ (TOP BAR)
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
    Text = "KIÊN  |  MENU M1",
    TextColor3 = Mau.Trang,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamBlack,
    TextSize = 19,
}, thanhTieuDe)

tao("TextLabel", {
    Position = UDim2.new(0, 66, 0, 35),
    Size = UDim2.new(0, 320, 0, 17),
    BackgroundTransparency = 1,
    Text = "BLACK NEBULA  •  KIÊN  •  by ? Tiktok",
    TextColor3 = Mau.Do,
    TextXAlignment = Enum.TextXAlignment.Left,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
}, thanhTieuDe)

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

--// THANH ĐIỀU HƯỚNG (SIDEBAR)
local thanhBen = tao("Frame", {
    Position = UDim2.new(0, 0, 0, 66),
    Size = UDim2.new(0, 155, 1, -66),
    BackgroundColor3 = Mau.Panel,
    BorderSizePixel = 0,
}, menuChinh)

tao("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, thanhBen)

tao("UIPadding", {
    PaddingTop = UDim.new(0, 17),
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
}, thanhBen)

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

tao("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, khungCuon)

local danhSachTrang = {
    TRANG_CHU = {
        TieuDe = "TRANG CHỦ / TỔNG QUAN",
        MoTa = "Chào mừng bạn đến với Kiên Script",
        Muc = {
            {Loai = "banner", TieuDe = "BLACK NEBULA M1", MoTa = "Giao diện đỏ đen độc quyền cho Kiên — by ? Tiktok"},
            {Loai = "info", TieuDe = "TRẠNG THÁI", MoTa = "Hệ thống nhân đôi sát thương (Multiplier) đã sẵn sàng."},
        },
    },
    NHAN_DOI = {
        TieuDe = "NHÂN ĐÔI ĐAM / CÀI ĐẶT",
        MoTa = "Chọn hệ số nhân sát thương khi mở trứng",
        Muc = {
            {Loai = "mult", TieuDe = "Hệ số nhân sát thương (1x - 5x)", MoTa = "Tăng tốc độ và tối ưu số lượng đòn đánh mở trứng."},
        },
    },
    THONG_TIN = {
        TieuDe = "THÔNG TIN / TÁC GIẢ",
        MoTa = "Chi tiết dự án cá nhân",
        Muc = {
            {Loai = "info", TieuDe = "CHỦ SỞ HỮU", MoTa = "KIÊN"},
            {Loai = "info", TieuDe = "CHỮ KÝ", MoTa = "by ? Tiktok"},
        },
    },
}

local function xoaNoiDungCu()
    for _, child in ipairs(khungCuon:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
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

local hienThiTrang
hienThiTrang = function(tenTrang)
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

            tao("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            }, nutChua)

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
                    if val == 1 then
                        hienThongBao("Chế độ 1x: Đã tắt (Bình thường)")
                    else
                        hienThongBao("Đã đổi sang: " .. val .. "x Đam!")
                    end
                    for mVal, btn in pairs(danhSachNut) do
                        if mVal == val then
                            hieuDung(btn, 0.15, {BackgroundColor3 = Mau.DoDam})
                        else
                            hieuDung(btn, 0.15, {BackgroundColor3 = Mau.Panel})
                        end
                    end
                end)
            end
        else
            taoThe(item.TieuDe, item.MoTa, 68)
        end
    end
end

local tenNut = {"TRANG_CHU", "NHAN_DOI", "THONG_TIN"}
local tenHienThi = {"TRANG CHỦ", "NHÂN ĐÔI", "THÔNG TIN"}
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

--// ĐÓNG / MỞ CỬA SỔ CHÍNH
local function datMoMenu(hienThi)
    if hienThi then
        menuChinh.Visible = true
        menuChinh.Size = UDim2.fromOffset(610, 390)
        hieuDung(menuChinh, 0.22, {Size = UDim2.fromOffset(650, 420)})
    else
        hieuDung(menuChinh, 0.18, {Size = UDim2.fromOffset(610, 390)})
        task.delay(0.19, function()
            menuChinh.Visible = false
        end)
    end
end

nutMoMenu.Activated:Connect(function()
    datMoMenu(not menuChinh.Visible)
end)

nutDong.Activated:Connect(function()
    datMoMenu(false)
end)

--// KÉO THẢ CỬA SỔ (DRAG WINDOW)
local dangKeo = false
local viTriBatDau
local viTriKhung

thanhTieuDe.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dangKeo = true
        viTriBatDau = input.Position
        viTriKhung = menuChinh.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dangKeo and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local doLech = input.Position - viTriBatDau
        menuChinh.Position = UDim2.new(
            viTriKhung.X.Scale,
            viTriKhung.X.Offset + doLech.X,
            viTriKhung.Y.Scale,
            viTriKhung.Y.Offset + doLech.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dangKeo = false
    end
end)

--// LOGIC NHÂN ĐÔI SÁT THƯƠNG (EGG MULTIPLIER)
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
					local nextHit = baseHit + i
					self:FireServer(eggObject, nextHit)
				end
				
				task.wait(1.0)
				kienIsProcessing = false
			end)
		end
	end
	
	return kienOldNameCall(self, ...)
end)

hienThiTrang("TRANG_CHU")
hienThongBao("Kiên Script M1 — Sẵn sàng hoạt động!")
	
