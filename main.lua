-- 加载 WindUI 库
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== 服务与变量 ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 检查 Drawing 是否可用
local DrawingAvailable = pcall(function() local _ = Drawing.new; return true end)
if not DrawingAvailable then
    warn("Drawing 库不可用，自瞄视觉效果将被禁用")
end

-- ========== 设置 ==========
local Settings = {
    Esp = false,
    DynamicAimbot = false,
    CursorAimbot = false,
    AimPart = "Head",
    BlackHole = false,
    SpeedBoost = false,
    WalkSpeedValue = 64,
}

local lockedPlayer = nil
local blackHoleConnection = nil

-- 原速
local defaultWalkSpeed = 16
local function updateSpeed()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Settings.SpeedBoost and Settings.WalkSpeedValue or defaultWalkSpeed
    end
end
Player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.1)
    updateSpeed()
end)

-- ========== 黑洞 ==========
local function StartBlackHole()
    if blackHoleConnection then blackHoleConnection:Disconnect() end
    blackHoleConnection = RunService.Heartbeat:Connect(function()
        if not Settings.BlackHole then return end
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local center = root.Position
        local maxRange = 20
        local maxRangeSq = maxRange * maxRange
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj:CanSetNetworkOwnership() then
                pcall(function() obj:SetNetworkOwner(Player) end)
                local pos = obj.Position
                local delta = pos - center
                local distSq = delta:Dot(delta)
                if distSq < maxRangeSq then
                    local dir = delta.Unit
                    local pullForce = 25
                    local rotateForce = 30
                    local angle = tick() * 10
                    local orbit = Vector3.new(math.cos(angle), 0.2, math.sin(angle)) * 12
                    obj.Velocity = (orbit - dir * pullForce)
                    obj.RotVelocity = Vector3.new(0, rotateForce, 0)
                end
            end
        end
    end)
end
local function StopBlackHole()
    Settings.BlackHole = false
    if blackHoleConnection then
        blackHoleConnection:Disconnect()
        blackHoleConnection = nil
    end
end

-- ========== 自瞄相关 ==========
local circle, aimLine
local BASE_RADIUS = 50
local MIN_RADIUS = 25
local STICK_MARGIN = 1.3
local currentRadius = BASE_RADIUS
local currentTarget = nil
local hue = 0

local function initAimbotDrawing()
    if circle then circle:Remove() end
    if aimLine then aimLine:Remove() end
    if DrawingAvailable then
        circle = Drawing.new("Circle")
        circle.Visible = false
        circle.Color = Color3.new(1,0,0)
        circle.Thickness = 1
        circle.Filled = false
        circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        circle.Radius = BASE_RADIUS
        aimLine = Drawing.new("Line")
        aimLine.Visible = false
        aimLine.Color = Color3.new(1,0,0)
        aimLine.Thickness = 1
        aimLine.From = circle.Position
    end
end

local function getAimStrength(distance)
    local d = math.floor(distance / 5) * 5
    if d <= 5 then return 0.58
    elseif d <= 10 then return 0.53
    elseif d <= 15 then return 0.48
    elseif d <= 20 then return 0.43
    elseif d <= 25 then return 0.38
    elseif d <= 30 then return 0.33
    elseif d <= 40 then return 0.28
    elseif d <= 50 then return 0.23
    elseif d <= 70 then return 0.18
    else return 0.14 end
end

local function isVisible(target)
    local char = Player.Character
    if not char or not target then return false end
    local origin = Camera.CFrame.Position
    local dir = target.Position - origin
    local ray = Ray.new(origin, dir.Unit * dir.Magnitude)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char, target.Parent})
    return hit == nil
end

local function getTargetInCircle()
    if not Camera then return nil end
    if lockedPlayer then
        if lockedPlayer.Character then
            local hum = lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
            local part = lockedPlayer.Character:FindFirstChild(Settings.AimPart)
            if hum and part and hum.Health > 0 and isVisible(part) then
                return part
            end
        end
        return nil
    end
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local closest = nil
    local minDist = 9999
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local part = char:FindFirstChild(Settings.AimPart)
                if hum and part and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and pos.Z > 0 and isVisible(part) then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < currentRadius * STICK_MARGIN and dist < minDist then
                            minDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function getTargetAtCursor()
    if not Camera then return nil end
    if lockedPlayer then
        if lockedPlayer.Character then
            local hum = lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
            local part = lockedPlayer.Character:FindFirstChild(Settings.AimPart)
            if hum and part and hum.Health > 0 and isVisible(part) then
                return part
            end
        end
        return nil
    end
    local cursorPos = UserInputService:GetMouseLocation()
    local closest = nil
    local minDist = 200
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local part = char:FindFirstChild(Settings.AimPart)
                if hum and part and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen and pos.Z > 0 and isVisible(part) then
                        local dist = (Vector2.new(pos.X, pos.Y) - cursorPos).Magnitude
                        if dist < minDist then
                            minDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ========== 自瞄循环（修复 continue 问题） ==========
local aimbotLoopRunning = true
local function aimbotLoop()
    while aimbotLoopRunning do
        local activeDynamic = Settings.DynamicAimbot
        local activeCursor = Settings.CursorAimbot
        local active = activeDynamic or activeCursor
        if not active then
            if circle then circle.Visible = false end
            if aimLine then aimLine.Visible = false end
            currentTarget = nil
        else
            if activeDynamic then
                circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                aimLine.From = circle.Position
                currentTarget = getTargetInCircle()
            elseif activeCursor then
                local cursorPos = UserInputService:GetMouseLocation()
                circle.Position = cursorPos
                aimLine.From = cursorPos
                currentTarget = getTargetAtCursor()
            end
            -- 验证目标有效性
            if currentTarget then
                local tpos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
                if not onScreen or tpos.Z < 0 or not isVisible(currentTarget) then
                    currentTarget = nil
                end
            end
            -- 绘制更新
            if currentTarget then
                currentRadius = currentRadius + (MIN_RADIUS - currentRadius) * 0.12
                hue = (hue + 0.01) % 1
                circle.Color = Color3.fromHSV(hue, 0.9, 1)
                aimLine.Color = circle.Color
                circle.Visible = true
                local tpos2 = Camera:WorldToViewportPoint(currentTarget.Position)
                aimLine.To = Vector2.new(tpos2.X, tpos2.Y)
                aimLine.Visible = true
            else
                currentRadius = currentRadius + (BASE_RADIUS - currentRadius) * 0.12
                circle.Color = Color3.new(1,0,0)
                circle.Visible = true
                aimLine.Visible = false
            end
            circle.Radius = currentRadius
        end
        task.wait()
    end
end

local function aimbotAimLoop()
    while aimbotLoopRunning do
        local active = Settings.DynamicAimbot or Settings.CursorAimbot
        if active and currentTarget and isVisible(currentTarget) then
            local camPos = Camera.CFrame.Position
            local tarPos = currentTarget.Position
            if lockedPlayer then
                Camera.CFrame = CFrame.lookAt(camPos, tarPos)
            else
                local dist = (camPos - tarPos).Magnitude
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(camPos, tarPos), getAimStrength(dist))
            end
        end
        task.wait()
    end
end

initAimbotDrawing()
task.spawn(aimbotLoop)
task.spawn(aimbotAimLoop)

-- ========== ESP ==========
local espActive = false
local function addHighlightToPlayer(p)
    if p == Player then return end
    local function add()
        if not p.Character then return end
        if p.Character:FindFirstChild("ESP") then p.Character.ESP:Destroy() end
        local e = Instance.new("Highlight")
        e.Name = "ESP"
        e.FillColor = Color3.new(1,0,0)
        e.OutlineColor = Color3.new(1,1,1)
        e.FillTransparency = 0.5
        e.OutlineTransparency = 0
        e.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        e.Adornee = p.Character
        e.Parent = p.Character
    end
    add()
    p.CharacterAdded:Connect(add)
end

local function enableEsp()
    espActive = true
    for _, p in pairs(Players:GetPlayers()) do addHighlightToPlayer(p) end
    Players.PlayerAdded:Connect(function(plr)
        if espActive then addHighlightToPlayer(plr) end
    end)
end

local function disableEsp()
    espActive = false
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESP") then
            p.Character.ESP:Destroy()
        end
    end
end

-- ========== WindUI 窗口构建 ==========
-- 创建窗口（无 KeySystem）
local Window = WindUI:CreateWindow({
    Title = "Tulip 郁金香",
    Icon = "flower",
    Author = "b站优质up主",
    Folder = "TulipUI",
    Size = UDim2.fromOffset(580, 400),
    Transparent = false,
    Theme = "Dark",
    SideBarWidth = 180,
    HasOutline = true,
    -- KeySystem 已完全移除
})

-- 弹出“继续/退出”确认框
WindUI:Popup({
    Title = "欢迎使用 Tulip",
    Icon = "flower",
    Content = "是否继续加载脚本？",
    Buttons = {
        {
            Title = "退出",
            Icon = "x",
            Callback = function()
                Window:Destroy()  -- 关闭并移除窗口
            end,
            Variant = "Secondary",
        },
        {
            Title = "继续",
            Icon = "arrow-right",
            Callback = function()
                -- 不执行任何操作，窗口将保持显示
            end,
            Variant = "Primary",
        }
    }
})

Window:EditOpenButton({
    Title = "打开 Tulip",
    Icon = "flower",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
})

-- 标签页
local Tabs = {
    Main     = Window:Tab({ Title = "主页", Icon = "home" }),
    General  = Window:Tab({ Title = "通用", Icon = "settings" }),
    Visual   = Window:Tab({ Title = "视觉", Icon = "eye" }),
    Combat   = Window:Tab({ Title = "战斗", Icon = "crosshair" }),
}

Window:SelectTab(1)

-- ===== 主页 =====
Tabs.Main:Paragraph({
    Title = "欢迎使用 Tulip 郁金香",
    Desc = "由 b站优质up主 开源，请勿删除致谢信息。\n优化自瞄逻辑请自行改进。",
    Image = "flower",
    Color = "Blue",
})

-- ===== 通用标签页 =====
-- 加速
Tabs.General:Toggle({
    Title = "加速",
    Value = Settings.SpeedBoost,
    Callback = function(v)
        Settings.SpeedBoost = v
        updateSpeed()
    end
})

-- 黑洞
Tabs.General:Toggle({
    Title = "黑洞",
    Value = Settings.BlackHole,
    Callback = function(v)
        Settings.BlackHole = v
        if v then StartBlackHole() else StopBlackHole() end
    end
})

-- ===== 视觉标签页 =====
Tabs.Visual:Toggle({
    Title = "ESP 透视",
    Value = Settings.Esp,
    Callback = function(v)
        Settings.Esp = v
        if v then enableEsp() else disableEsp() end
    end
})

-- ===== 战斗标签页 =====
-- 动态自瞄
Tabs.Combat:Toggle({
    Title = "动态自瞄",
    Value = Settings.DynamicAimbot,
    Callback = function(v)
        Settings.DynamicAimbot = v
        if v then Settings.CursorAimbot = false end
    end
})

-- 光标自瞄
Tabs.Combat:Toggle({
    Title = "光标自瞄",
    Value = Settings.CursorAimbot,
    Callback = function(v)
        Settings.CursorAimbot = v
        if v then Settings.DynamicAimbot = false end
    end
})

-- 锁敌模式
local lockModeDropdown = Tabs.Combat:Dropdown({
    Title = "锁敌模式",
    Values = { "无差别", "目标锁敌" },
    Value = "无差别",
    Multi = false,
    AllowNone = false,
    Callback = function(opt)
        if opt == "无差别" then
            lockedPlayer = nil
        end
    end,
})

-- 目标选择（仅目标锁敌时有效）
local playerDropdown
local function refreshPlayerList()
    local playerNames = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            table.insert(playerNames, plr.Name)
        end
    end
    return playerNames
end

playerDropdown = Tabs.Combat:Dropdown({
    Title = "选择目标",
    Values = refreshPlayerList(),
    Multi = false,
    AllowNone = true,
    Callback = function(name)
        if name and lockModeDropdown.Value == "目标锁敌" then
            lockedPlayer = Players:FindFirstChild(name)
        else
            lockedPlayer = nil
        end
    end,
})

-- 刷新按钮
Tabs.Combat:Button({
    Title = "刷新玩家列表",
    Callback = function()
        playerDropdown:Refresh(refreshPlayerList())
    end,
})

-- 战斗页面提示
Tabs.Combat:Paragraph({
    Title = "说明",
    Desc = "动态自瞄会跟随圆圈内的目标；光标自瞄跟随鼠标最近的目标。\n‘目标锁敌’模式下需在下方选择锁定对象。",
    Color = "Grey",
})

-- ===== 清理与退出 =====
Window:Tab({ Title = "退出", Icon = "log-out" }):Button({
    Title = "关闭所有功能并隐藏窗口",
    Callback = function()
        Settings.DynamicAimbot = false
        Settings.CursorAimbot = false
        Settings.BlackHole = false
        Settings.Esp = false
        disableEsp()
        StopBlackHole()
        lockedPlayer = nil
        Window:Destroy()
    end
})