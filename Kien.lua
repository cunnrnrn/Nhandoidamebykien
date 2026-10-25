--[[
    KIÊN SCRIPT — M1 BLACK NEBULA (ANTI-CRACK / ANTI-TAMPER)
    Bảo vệ chống đổi tên menu & chống can thiệp script
]]
local _ENV = (getgenv or function() return _G end)()
(function(...)
    local _g = game
    local _Plr = _g:GetService("Players")
    local _Rep = _g:GetService("ReplicatedStorage")
    local _Tws = _g:GetService("TweenService")
    local _Uis = _g:GetService("UserInputService")
    
    local _LPlr = _Plr.LocalPlayer
    local _PGui = _LPlr:WaitForChild("PlayerGui")
    local _EHR = _Rep:WaitForChild("EggHitRequest")

    local _isEnable = true
    local _isBusy = false
    local _multVal = 4

    local _oldGui = _PGui:FindFirstChild("KienMenuM1_Pro")
    if _oldGui then _oldGui:Destroy() end

    local _Colors = {
        Nen = Color3.fromRGB(10, 10, 14),
        Panel = Color3.fromRGB(17, 17, 23),
        The = Color3.fromRGB(24, 24, 32),
        Do = Color3.fromRGB(255, 48, 75),
        DoDam = Color3.fromRGB(120, 20, 40),
        Trang = Color3.fromRGB(245, 245, 250),
        Mo = Color3.fromRGB(145, 145, 160),
        XanhNhe = Color3.fromRGB(70, 230, 155),
    }

    local function _create(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props or {}) do obj[k] = v end
        obj.Parent = parent
        return obj
    end

    local function _round(parent, radius)
        _create("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
    end

    local function _stroke(parent, color, thickness, transparency)
        return _create("UIStroke", { Color = color or _Colors.Do, Thickness = thickness or 1, Transparency = transparency or 0 }, parent)
    end

    local function _tween(obj, duration, props)
        local t = _Tws:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props)
        t:Play()
        return t
    end

    local _ScreenGui = _create("ScreenGui", {
        Name = "KienMenuM1_Pro",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, _PGui)

    --// THÔNG BÁO NỔI THƯỜNG
    local _Notif = _create("TextLabel", {
        Name = "ThongBaoNoi",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 12),
        Size = UDim2.fromOffset(240, 32),
        BackgroundColor3 = _Colors.The,
        TextColor3 = _Colors.XanhNhe,
        Text = "",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Visible = false,
        ZIndex = 100,
    }, _ScreenGui)
    _round(_Notif, 8)
    _stroke(_Notif, _Colors.Do, 1)

    local _notifVer = 0
    local function _notify(text)
        _notifVer = _notifVer + 1
        local currentVer = _notifVer
        _Notif.Text = "  " .. text
        _Notif.Visible = true
        _Notif.TextTransparency = 1
        _Notif.BackgroundTransparency = 1
        _tween(_Notif, 0.2, { TextTransparency = 0, BackgroundTransparency = 0.2 })
        task.delay(1.2, function()
            if _notifVer == currentVer then
                _tween(_Notif, 0.2, { TextTransparency = 1, BackgroundTransparency = 1 })
                task.wait(0.22)
                if _notifVer == currentVer then _Notif.Visible = false end
            end
        end)
    end

    --// BẢNG BÁO LỖI "LOL CRACK" NẾU BỊ SỬA GIAO DIỆN
    local _CrackAlert = _create("Frame", {
        Name = "CrackAlertBox",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(320, 150),
        BackgroundColor3 = Color3.fromRGB(15, 10, 12),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 999,
    }, _ScreenGui)
    _round(_CrackAlert, 14)
    _stroke(_CrackAlert, Color3.fromRGB(255, 0, 0), 2)

    _create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "⚠️ CẢNH BÁO CRACK! ⚠️",
        TextColor3 = Color3.fromRGB(255, 48, 75),
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
    }, _CrackAlert)

    _create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 70),
        BackgroundTransparency = 1,
        Text = "LOL CRACK — Đừng có hòng hack hay sửa tên script của Kiên nhé con trai!",
        TextColor3 = Color3.fromRGB(245, 245, 250),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
    }, _CrackAlert)

    --// HỆ THỐNG KIỂM TRA CHỐNG THAY ĐỔI (ANTI-TAMPER)
    task.spawn(function()
        while task.wait(1) do
            -- Kiểm tra xem ScreenGui có bị đổi tên hoặc bị xóa mất không
            if not _ScreenGui or _ScreenGui.Parent ~= _PGui or _ScreenGui.Name ~= "KienMenuM1_Pro" then
                _CrackAlert.Visible = true
                break
            end
        end
    end)

    --// NÚT MỞ MENU (CHỮ K)
    local _OpenBtn = _create("TextButton", {
        Name = "NutMoMenu",
        Size = UDim2.fromOffset(54, 54),
        Position = UDim2.new(0, 18, 0.5, -27),
        BackgroundColor3 = _Colors.Nen,
        Text = "K",
        TextColor3 = _Colors.Do,
        TextSize = 25,
        Font = Enum.Font.GothamBlack,
        AutoButtonColor = false,
    }, _ScreenGui)
    _round(_OpenBtn, 16)
    _stroke(_OpenBtn, _Colors.Do, 2)

    --// CỬA SỔ MENU CHÍNH M1
    local _Main = _create("Frame", {
        Name = "MenuChinh",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(650, 420),
        BackgroundColor3 = _Colors.Nen,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
    }, _ScreenGui)
    _round(_Main, 16)
    _stroke(_Main, _Colors.Do, 1.5)

    local _Scale = _create("UIScale", { Scale = 1 }, _Main)
    local function _updateScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        _Scale.Scale = math.min(vp.X / 690, vp.Y / 460, 1)
    end
    _updateScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_updateScale)
    end

    --// TOP BAR
    local _TopBar = _create("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = _Colors.Panel,
        BorderSizePixel = 0,
    }, _Main)

    _create("Frame", {
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = _Colors.Do,
        BorderSizePixel = 0,
    }, _TopBar)

    local _Logo = _create("Frame", {
        Position = UDim2.new(0, 17, 0.5, -19),
        Size = UDim2.fromOffset(38, 38),
        BackgroundColor3 = _Colors.DoDam,
    }, _TopBar)
    _round(_Logo, 12)
    _stroke(_Logo, _Colors.Do, 1)

    _create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "K",
        TextColor3 = _Colors.Trang,
        Font = Enum.Font.GothamBlack,
        TextSize = 23,
    }, _Logo)

    _create("TextLabel", {
        Position = UDim2.new(0, 65, 0, 10),
        Size = UDim2.new(0, 280, 0, 25),
        BackgroundTransparency = 1,
        Text = "KIÊN  |  MENU PRO",
        TextColor3 = _Colors.Trang,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBlack,
        TextSize = 19,
    }, _TopBar)

    _create("TextLabel", {
        Position = UDim2.new(0, 66, 0, 35),
        Size = UDim2.new(0, 320, 0, 17),
        BackgroundTransparency = 1,
        Text = "BLACK NEBULA  •  KIÊN  •  by ? Tiktok",
        TextColor3 = _Colors.Do,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
    }, _TopBar)

    local _CloseBtn = _create("TextButton", {
        Position = UDim2.new(1, -45, 0, 15),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = _Colors.The,
        Text = "×",
        TextColor3 = _Colors.Do,
        TextSize = 23,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, _TopBar)
    _round(_CloseBtn, 9)

    --// SIDEBAR
    local _Sidebar = _create("Frame", {
        Position = UDim2.new(0, 0, 0, 66),
        Size = UDim2.new(0, 155, 1, -66),
        BackgroundColor3 = _Colors.Panel,
        BorderSizePixel = 0,
    }, _Main)

    _create("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, _Sidebar)
    _create("UIPadding", { PaddingTop = UDim.new(0, 17), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, _Sidebar)

    local _Content = _create("Frame", {
        Position = UDim2.new(0, 155, 0, 66),
        Size = UDim2.new(1, -155, 1, -66),
        BackgroundTransparency = 1,
    }, _Main)

    local _PageTitle = _create("TextLabel", {
        Position = UDim2.new(0, 20, 0, 15),
        Size = UDim2.new(1, -40, 0, 30),
        BackgroundTransparency = 1,
        Text = "TRANG CHỦ / TỔNG QUAN",
        TextColor3 = _Colors.Trang,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
    }, _Content)

    local _PageHint = _create("TextLabel", {
        Position = UDim2.new(0, 20, 0, 44),
        Size = UDim2.new(1, -40, 0, 20),
        BackgroundTransparency = 1,
        Text = "Không gian của bạn. Phong cách của bạn.",
        TextColor3 = _Colors.Mo,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 11,
    }, _Content)

    local _PageBody = _create("ScrollingFrame", {
        Position = UDim2.new(0, 15, 0, 75),
        Size = UDim2.new(1, -30, 1, -88),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = _Colors.Do,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, _Content)

    _create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, _PageBody)

    local _PagesData = {
        TRANG_CHU = {
            Title = "TRANG CHỦ / TỔNG QUAN",
            Hint = "Chào mừng bạn đến với Kiên Script Pro",
            Items = {
                {Type = "banner", Title = "BLACK NEBULA PRO", Desc = "Giao diện đỏ đen tích hợp chống crack — by ? Tiktok"},
                {Type = "info", Title = "TRẠNG THÁI", Desc = "Hệ thống nhân đôi sát thương (Multiplier) hoạt động hoàn hảo."},
            },
        },
        NHAN_DOI = {
            Title = "NHÂN ĐÔI ĐAM / CÀI ĐẶT",
            Hint = "Chọn hệ số nhân sát thương khi mở trứng",
            Items = {
                {Type = "mult", Title = "Hệ số nhân sát thương (1x - 5x)", Desc = "Tăng tốc độ và tối ưu số lượng đòn đánh mở trứng."},
            },
        },
        THONG_TIN = {
            Title = "THÔNG TIN / TÁC GIẢ",
            Hint = "Chi tiết dự án cá nhân",
            Items = {
                {Type = "info", Title = "CHỦ SỞ HỮU", Desc = "KIÊN"},
                {Type = "info", Title = "CHỮ KÝ", Desc = "by ? Tiktok"},
            },
        },
    }

    local function _clearBody()
        for _, child in ipairs(_PageBody:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then child:Destroy() end
        end
    end

    local function _makeCard(titleText, descText, height)
        local card = _create("Frame", {
            Size = UDim2.new(1, -4, 0, height or 68),
            BackgroundColor3 = _Colors.The,
            BorderSizePixel = 0,
        }, _PageBody)
        _round(card, 12)
        _stroke(card, _Colors.DoDam, 1, 0.35)

        _create("TextLabel", {
            Position = UDim2.new(0, 14, 0, 11),
            Size = UDim2.new(1, -28, 0, 20),
            BackgroundTransparency = 1,
            Text = titleText,
            TextColor3 = _Colors.Trang,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
        }, card)

        _create("TextLabel", {
            Position = UDim2.new(0, 14, 0, 34),
            Size = UDim2.new(1, -28, 0, 22),
            BackgroundTransparency = 1,
            Text = descText,
            TextColor3 = _Colors.Mo,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            TextWrapped = true,
        }, card)

        return card
    end

    local _renderPage
    _renderPage = function(name)
        local data = _PagesData[name]
        if not data then return end

        _PageTitle.Text = data.Title
        _PageHint.Text = data.Hint
        _clearBody()

        for _, item in ipairs(data.Items) do
            if item.Type == "banner" then
                local card = _makeCard(item.Title, item.Desc, 90)
                _create("Frame", {
                    Position = UDim2.new(0, 14, 1, -5),
                    Size = UDim2.new(0.45, 0, 0, 2),
                    BackgroundColor3 = _Colors.Do,
                    BorderSizePixel = 0,
                }, card)
            elseif item.Type == "mult" then
                local card = _makeCard(item.Title, item.Desc, 85)
                
                local btnHolder = _create("Frame", {
                    Position = UDim2.new(0, 14, 0, 52),
                    Size = UDim2.new(1, -28, 0, 28),
                    BackgroundTransparency = 1,
                }, card)

                _create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                }, btnHolder)

                local multipliers = {1, 2, 3, 4, 5}
                local mButtons = {}

                for _, val in ipairs(multipliers) do
                    local mBtn = _create("TextButton", {
                        Size = UDim2.new(0, 42, 0, 26),
                        BackgroundColor3 = (val == _multVal) and _Colors.DoDam or _Colors.Panel,
                        Text = val .. "x",
                        TextColor3 = _Colors.Trang,
                        Font = Enum.Font.GothamBold,
                        TextSize = 12,
                        AutoButtonColor = false,
                    }, btnHolder)
                    _round(mBtn, 6)
                    _stroke(mBtn, _Colors.Do, 1, 0.5)

                    mButtons[val] = mBtn

                    mBtn.Activated:Connect(function()
                        _multVal = val
                        if val == 1 then
                            _notify("Chế độ 1x: Đã tắt (Bình thường)")
                        else
                            _notify("Đã đổi sang: " .. val .. "x Đam!")
                        end
                        for mVal, btn in pairs(mButtons) do
                            if mVal == val then
                                _tween(btn, 0.15, { BackgroundColor3 = _Colors.DoDam })
                            else
                                _tween(btn, 0.15, { BackgroundColor3 = _Colors.Panel })
                            end
                        end
                    end)
                end
            else
                _makeCard(item.Title, item.Desc, 68)
            end
        end
    end

    local _navKeys = {"TRANG_CHU", "NHAN_DOI", "THONG_TIN"}
    local _navNames = {"TRANG CHỦ", "NHÂN ĐÔI", "THÔNG TIN"}
    local _navButtons = {}

    for idx, name in ipairs(_navKeys) do
        local btn = _create("TextButton", {
            Name = name,
            LayoutOrder = idx,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = (name == "TRANG_CHU") and _Colors.DoDam or _Colors.Panel,
            Text = "   " .. _navNames[idx],
            TextColor3 = (name == "TRANG_CHU") and _Colors.Trang or _Colors.Mo,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
        }, _Sidebar)
        _round(btn, 9)
        _navButtons[name] = btn

        btn.Activated:Connect(function()
            for _, other in pairs(_navButtons) do
                _tween(other, 0.15, { BackgroundColor3 = _Colors.Panel })
                other.TextColor3 = _Colors.Mo
            end
            _tween(btn, 0.15, { BackgroundColor3 = _Colors.DoDam })
            btn.TextColor3 = _Colors.Trang
            _renderPage(name)
        end)
    end

    --// ĐÓNG / MỞ MENU
    local function _setMenuOpen(isOpen)
        if isOpen then
            _Main.Visible = true
            _Main.Size = UDim2.fromOffset(610, 390)
            _tween(_Main, 0.22, { Size = UDim2.fromOffset(650, 420) })
        else
            _tween(_Main, 0.18, { Size = UDim2.fromOffset(610, 390) })
            task.delay(0.19, function() _Main.Visible = false end)
        end
    end

    _OpenBtn.Activated:Connect(function() _setMenuOpen(not _Main.Visible) end)
    _CloseBtn.Activated:Connect(function() _setMenuOpen(false) end)

    --// KÉO THẢ CỬA SỔ
    local _isDragging = false
    local _dragStart, _startPos

    _TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _isDragging = true
            _dragStart = input.Position
            _startPos = _Main.Position
        end
    end)

    _Uis.InputChanged:Connect(function(input)
        if _isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - _dragStart
            _Main.Position = UDim2.new(
                _startPos.X.Scale, _startPos.X.Offset + delta.X,
                _startPos.Y.Scale, _startPos.Y.Offset + delta.Y
            )
        end
    end)

    _Uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _isDragging = false
        end
    end)

    --// LOGIC NHÂN ĐÔI SÁT THƯƠNG
    local _oldMeta
    _oldMeta = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if _isEnable and not _isBusy and _multVal > 1 and self == _EHR and method == "FireServer" then
            local eggObj = args[1]
            local baseHit = args[2] or 1
            
            if eggObj then
                _isBusy = true
                local extra = _multVal - 1
                
                task.spawn(function()
                    for i = 1, extra do
                        self:FireServer(eggObj, baseHit + i)
                    end
                    task.wait(1.0)
                    _isBusy = false
                end)
            end
        end
        
        return _oldMeta(self, ...)
    end)

    _renderPage("TRANG_CHU")
    _notify("Kiên Script Pro Max — Chống Crack Đã Bật!")
end)()
