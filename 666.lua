-- 加载 WindUI 库
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ========== 服务与变量 ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingAvailable = pcall(function() local _ = Drawing.new; return true end)
if not DrawingAvailable then
    warn("Drawing 库不可用，视觉效果将被禁用")
end

-- ========== 设置 ==========
local Settings = {
    Esp = false,
    DynamicAimbot = false,
    AimPart = "Head",
    BlackHole = false,
    SpeedBoost = false,
    WalkSpeedValue = 64,
    Invisible = false,
    EspLine = false,
    EspInfo = false,
    Fly = false,
    FlySpeed = 10,
    GodMode = false,
    Halo = false,
    Fixed = false,
    NoClip = false,
    AimSpeed = 0.5,
}

local lockedPlayer = nil
local blackHoleConnection = nil
local invisibleConnection = nil
local flyConnection = nil
local godModeConnection = nil
local fixedConnection = nil
local noClipConnection = nil
local haloPart = nil
local haloWeld = nil
local antiKickLoaded = false
local fixedPosition = nil
local mainWindowCreated = false
local selectedTeleportPlayer = nil
local translationLoaded = false

-- ========== 反作弊保护 ==========
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("功能执行出错: " .. tostring(result))
    end
    return result
end

-- ========== 传送到玩家位置 ==========
local function teleportToPlayer(targetPlayer)
    safeCall(function()
        if not targetPlayer then
            WindUI:Notify({
                Title = "错误",
                Content = "请先选择要传送的玩家",
                Duration = 3
            })
            return
        end
        
        local char = Player.Character
        if not char then
            WindUI:Notify({
                Title = "错误",
                Content = "您的角色不存在",
                Duration = 3
            })
            return
        end
        
        local targetChar = targetPlayer.Character
        if not targetChar then
            WindUI:Notify({
                Title = "错误",
                Content = "目标玩家角色不存在",
                Duration = 3
            })
            return
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        
        if not hrp then
            WindUI:Notify({
                Title = "错误",
                Content = "您的HumanoidRootPart不存在",
                Duration = 3
            })
            return
        end
        
        if not targetHrp then
            WindUI:Notify({
                Title = "错误",
                Content = "目标玩家HumanoidRootPart不存在",
                Duration = 3
            })
            return
        end
        
        hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 2, 0)
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        
        WindUI:Notify({
            Title = "传送成功",
            Content = "已传送到 " .. targetPlayer.Name,
            Duration = 3
        })
    end)
end

-- ========== 翻译功能 ==========
local function loadTranslation()
    if translationLoaded then
        WindUI:Notify({
            Title = "提示",
            Content = "翻译已加载，请勿重复执行",
            Duration = 3
        })
        return
    end
    
    translationLoaded = true
    safeCall(function()
        WindUI:Notify({
            Title = "翻译已加载",
            Content = "正在启动翻译引擎...",
            Duration = 3
        })
        
        local Translations = {
            ["Homelander"] = "祖国人",
            ["homelander"] = "祖国人",
            ["HOMELANDER"] = "祖国人",
            ["fly"] = "飞",
            ["FLY"] = "飞",
            ["Fly"] = "飞",
            ["NO"] = "关闭",
            ["no"] = "关闭",
            ["No"] = "关闭",
            ["OFF"] = "关闭",
            ["off"] = "关闭",
            ["Off"] = "关闭",
            ["ON"] = "开启",
            ["on"] = "开启",
            ["On"] = "开启",
            ["X-Rey"] = "透视眼",
            ["x-rey"] = "透视眼",
            ["X-REY"] = "透视眼",
            ["X"] = "透",
            ["x"] = "透",
            ["Rey"] = "视",
            ["rey"] = "视",
            ["REY"] = "视",
            ["Ground Land"] = "着陆",
            ["ground land"] = "着陆",
            ["GROUND LAND"] = "着陆",
            ["Slow"] = "慢慢飞",
            ["slow"] = "慢慢飞",
            ["SLOW"] = "慢慢飞",
            ["Fast"] = "快速飞",
            ["fast"] = "快速飞",
            ["FAST"] = "快速飞",
            ["RandomVoines"] = "随机台词",
            ["randomvoines"] = "随机台词",
            ["RANDOMVOINES"] = "随机台词",
            ["Random Voines"] = "随机台词",
            ["random voines"] = "随机台词",
            ["RANDOM VOINES"] = "随机台词",
            ["Normal"] = "正常飞",
            ["normal"] = "正常飞",
            ["NORMAL"] = "正常飞",
            ["lock buttons"] = "锁定按钮",
            ["Lock Buttons"] = "锁定按钮",
            ["LOCK BUTTONS"] = "锁定按钮",
            ["camera follow on"] = "相机跟随开启",
            ["Camera Follow On"] = "相机跟随开启",
            ["CAMERA FOLLOW ON"] = "相机跟随开启",
            ["hide buttons"] = "隐藏按钮",
            ["Hide Buttons"] = "隐藏按钮",
            ["HIDE BUTTONS"] = "隐藏按钮",
            ["camera lift during laser on"] = "激光开启时相机抬升",
            ["Camera Lift During Laser On"] = "激光开启时相机抬升",
            ["CAMERA LIFT DURING LASER ON"] = "激光开启时相机抬升",
            ["laser eye offset"] = "激光眼偏移",
            ["Laser Eye Offset"] = "激光眼偏移",
            ["LASER EYE OFFSET"] = "激光眼偏移",
            ["shiftlock off"] = "锁定视角关闭",
            ["Shiftlock Off"] = "锁定视角关闭",
            ["SHIFTLOCK OFF"] = "锁定视角关闭",
            ["laser fling on"] = "激光弹飞开启",
            ["Laser Fling On"] = "激光弹飞开启",
            ["LASER FLING ON"] = "激光弹飞开启",
            ["camera X offset"] = "相机X轴偏移",
            ["Camera X Offset"] = "相机X轴偏移",
            ["CAMERA X OFFSET"] = "相机X轴偏移"
        }

        local function translateText(text)
            if not text or type(text) ~= "string" then
                return text
            end

            if Translations[text] then
                return Translations[text]
            end

            for en, cn in pairs(Translations) do
                if text:find(en) then
                    return text:gsub(en, cn)
                end
            end

            return text
        end

        local function setupTranslationEngine()
            local success, err = pcall(function()
                local mt = getrawmetatable(game)
                if not mt then return end
                local oldIndex = mt.__newindex
                setreadonly(mt, false)

                mt.__newindex = newcclosure(function(t, k, v)
                    if (t:IsA("TextLabel") or t:IsA("TextButton") or t:IsA("TextBox")) and k == "Text" then
                        v = translateText(tostring(v))
                    end
                    return oldIndex(t, k, v)
                end)

                setreadonly(mt, true)
            end)

            if not success then
                local translated = {}
                local function scanAndTranslate()
                    for _, gui in ipairs(game:GetService("CoreGui"):GetDescendants()) do
                        if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                            pcall(function()
                                local text = gui.Text
                                if text and text ~= "" then
                                    local translatedText = translateText(text)
                                    if translatedText ~= text then
                                        gui.Text = translatedText
                                        translated[gui] = true
                                    end
                                end
                            end)
                        end
                    end

                    local player = game:GetService("Players").LocalPlayer
                    if player and player:FindFirstChild("PlayerGui") then
                        for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
                            if (gui:IsA("TextLabel") or gui:IsA("TextButton") or gui:IsA("TextBox")) and not translated[gui] then
                                pcall(function()
                                    local text = gui.Text
                                    if text and text ~= "" then
                                        local translatedText = translateText(text)
                                        if translatedText ~= text then
                                            gui.Text = translatedText
                                            translated[gui] = true
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end

                local function setupDescendantListener(parent)
                    parent.DescendantAdded:Connect(function(descendant)
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                            task.wait(0.1)
                            pcall(function()
                                local text = descendant.Text
                                if text and text ~= "" then
                                    local translatedText = translateText(text)
                                    if translatedText ~= text then
                                        descendant.Text = translatedText
                                    end
                                end
                            end)
                        end
                    end)
                end

                pcall(setupDescendantListener, game:GetService("CoreGui"))
                local player = game:GetService("Players").LocalPlayer
                if player and player:FindFirstChild("PlayerGui") then
                    pcall(setupDescendantListener, player.PlayerGui)
                end

                while true do
                    scanAndTranslate()
                    task.wait(3)
                end
            end
        end

        task.wait(2)
        setupTranslationEngine()

        local HttpService = game:GetService("HttpService")
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local CoreGui = game:GetService("CoreGui")
        local AutoTranslateEnabled = false
        local translateLoop = nil
        local translatedTexts = {}

        local function isEnglish(text)
            if not text or text == "" then return false end
            local englishCount = 0
            local totalCount = 0
            for char in text:gmatch(".") do
                local byte = string.byte(char)
                if byte then
                    totalCount = totalCount + 1
                    if (byte >= 65 and byte <= 90) or (byte >= 97 and byte <= 122) then
                        englishCount = englishCount + 1
                    end
                end
            end
            if totalCount == 0 then return false end
            return (englishCount / totalCount) > 0.5
        end

        local function autoTranslateText(text)
            if not text or text == "" or #text < 2 then return nil end
            if translatedTexts[text] then return translatedTexts[text] end
            local success, result = pcall(function()
                local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=zh-CN&dt=t&q=" .. HttpService:UrlEncode(text)
                local response = game:HttpGet(url)
                local decoded = HttpService:JSONDecode(response)
                if decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
                    return decoded[1][1][1]
                end
                return nil
            end)
            if success and result then translatedTexts[text] = result; return result end
            return nil
        end

        local function processTextObject(obj)
            if not AutoTranslateEnabled then return end
            if not obj:IsA("TextLabel") and not obj:IsA("TextButton") and not obj:IsA("TextBox") then return end
            local originalText = obj.Text
            if not originalText or originalText == "" then return end
            if not isEnglish(originalText) then return end
            local translated = autoTranslateText(originalText)
            if translated and translated ~= originalText then obj.Text = translated end
        end

        local function scanAndTranslateAuto(container, maxCount)
            local c = 0
            for _, obj in ipairs(container:GetDescendants()) do
                if c >= maxCount then break end
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    if isEnglish(obj.Text) then
                        processTextObject(obj); c = c + 1
                    end
                end
            end
        end

        local function startAutoTranslate()
            if translateLoop then return end
            translateLoop = true
            task.spawn(function()
                while translateLoop and AutoTranslateEnabled do
                    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if PlayerGui then scanAndTranslateAuto(PlayerGui, 5) end
                    pcall(function()
                        for _, gui in ipairs(CoreGui:GetChildren()) do
                            if gui:IsA("ScreenGui") then scanAndTranslateAuto(gui, 5) end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end

        local function stopAutoTranslate()
            translateLoop = false
        end

        AutoTranslateEnabled = true
        startAutoTranslate()

        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/main/homelander.lua"))()
        end)

        if not success then
            warn("加载失败:", err)
        end
        
        WindUI:Notify({
            Title = "翻译引擎已启动",
            Content = "正在自动翻译UI文字...",
            Duration = 3
        })
    end)
end

-- ========== 原速 ==========
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

-- ========== 固定功能 ==========
local function enableFixed()
    Settings.Fixed = true
    safeCall(function()
        local char = Player.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        fixedPosition = rootPart.Position
        if fixedConnection then fixedConnection:Disconnect() end
        fixedConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Fixed then return end
            local currentChar = Player.Character
            if not currentChar then return end
            local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
            if not currentRoot then return end
            currentRoot.CFrame = CFrame.new(fixedPosition)
            currentRoot.Velocity = Vector3.new(0, 0, 0)
            currentRoot.RotVelocity = Vector3.new(0, 0, 0)
        end)
    end)
end

local function disableFixed()
    Settings.Fixed = false
    safeCall(function()
        if fixedConnection then
            fixedConnection:Disconnect()
            fixedConnection = nil
        end
        fixedPosition = nil
    end)
end

-- ========== 穿墙功能 ==========
local function enableNoClip()
    Settings.NoClip = true
    safeCall(function()
        if noClipConnection then noClipConnection:Disconnect() end
        noClipConnection = RunService.Heartbeat:Connect(function()
            if not Settings.NoClip then return end
            local char = Player.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function()
                        part.CanCollide = false
                    end)
                end
            end
        end)
    end)
end

local function disableNoClip()
    Settings.NoClip = false
    safeCall(function()
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        local char = Player.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = true
                end)
            end
        end
    end)
end

Player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if Settings.Fly then safeCall(enableFly) end
    if Settings.Fixed then safeCall(enableFixed) end
    if Settings.NoClip then safeCall(enableNoClip) end
end)

-- ========== 升天功能 ==========
local function enableFly()
    Settings.Fly = true
    safeCall(function()
        local char = Player.Character
        if not char then return end
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true
        end
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Fly then return end
            local currentChar = Player.Character
            if not currentChar then return end
            local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
            if not currentRoot then return end
            currentRoot.Velocity = Vector3.new(0, Settings.FlySpeed, 0)
            pcall(function()
                currentRoot.CFrame = CFrame.new(currentRoot.Position + Vector3.new(0, Settings.FlySpeed * 0.1, 0))
            end)
        end)
    end)
end

local function disableFly()
    Settings.Fly = false
    safeCall(function()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
end

-- ========== 上帝模式（无敌） ==========
local function applyGodMode(char)
    if not Settings.GodMode then return end
    safeCall(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.BreakJointsOnDeath = false
        local maxHealth = 1e9
        hum.MaxHealth = maxHealth
        hum.Health = maxHealth
        if godModeConnection then godModeConnection:Disconnect() end
        godModeConnection = RunService.Heartbeat:Connect(function()
            if Settings.GodMode and hum and hum.Parent then
                if hum.Health < maxHealth then
                    hum.Health = maxHealth
                end
                if hum.MaxHealth < maxHealth then
                    hum.MaxHealth = maxHealth
                end
            end
        end)
    end)
end

local function enableGodMode()
    Settings.GodMode = true
    if Player.Character then
        safeCall(applyGodMode, Player.Character)
    end
end

local function disableGodMode()
    Settings.GodMode = false
    safeCall(function()
        if godModeConnection then
            godModeConnection:Disconnect()
            godModeConnection = nil
        end
        local char = Player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.BreakJointsOnDeath = true
                hum.MaxHealth = 100
                if hum.Health > 100 then
                    hum.Health = 100
                end
            end
        end
    end)
end

Player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if Settings.GodMode then safeCall(applyGodMode, char) end
    if Settings.Halo then safeCall(createHalo) end
end)

-- ========== 头顶光环 ==========
local function createHalo()
    safeCall(function()
        if haloPart then
            haloPart:Destroy()
            haloPart = nil
        end
        if haloWeld then
            haloWeld:Destroy()
            haloWeld = nil
        end
        
        local char = Player.Character
        if not char then return end
        
        local head = char:FindFirstChild("Head")
        if not head then return end
        
        haloPart = Instance.new("Part")
        haloPart.Name = "Halo"
        haloPart.Size = Vector3.new(4, 0.3, 4)
        haloPart.Shape = Enum.PartType.Cylinder
        haloPart.BrickColor = BrickColor.new("White")
        haloPart.Material = Enum.Material.Neon
        haloPart.Transparency = 0.3
        haloPart.Anchored = false
        haloPart.CanCollide = false
        haloPart.CanQuery = false
        haloPart.CanTouch = false
        haloPart.LocalTransparencyModifier = 0
        
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://3270017"
        mesh.Scale = Vector3.new(2, 2, 0.3)
        mesh.Parent = haloPart
        
        haloWeld = Instance.new("Weld")
        haloWeld.Part0 = head
        haloWeld.Part1 = haloPart
        haloWeld.C0 = CFrame.new(0, 2.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
        haloWeld.Parent = haloPart
        
        haloPart.Parent = workspace
    end)
end

local function enableHalo()
    Settings.Halo = true
    safeCall(createHalo)
end

local function disableHalo()
    Settings.Halo = false
    safeCall(function()
        if haloPart then
            haloPart:Destroy()
            haloPart = nil
        end
        if haloWeld then
            haloWeld:Destroy()
            haloWeld = nil
        end
    end)
end

task.spawn(function()
    while task.wait() do
        if Settings.Halo and haloPart and haloPart.Parent then
            local breath = (math.sin(tick() * 2) + 1) / 2
            haloPart.Transparency = 0.2 + breath * 0.3
            haloPart.CFrame = haloPart.CFrame * CFrame.Angles(0, 0.02, 0)
        end
    end
end)

-- ========== 目标部位查找 ==========
local function findAimPart(character, aimPartName)
    if not character then return nil end
    local exactMatch = character:FindFirstChild(aimPartName)
    if exactMatch and exactMatch:IsA("BasePart") then return exactMatch end
    
    if aimPartName == "Head" then
        for _, name in ipairs({"Head", "head", "HEAD"}) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then return part end
        end
    end
    
    if aimPartName == "Torso" or aimPartName == "Waist" or aimPartName == "Body" then
        local torsoNames = {
            "Torso", "torso", "TORSO",
            "UpperTorso", "UpperTorso", "uppertorso",
            "LowerTorso", "LowerTorso", "lowertorso",
            "HumanoidRootPart",
            "Waist", "waist", "WAIST",
            "Body", "body", "BODY",
            "Chest", "chest", "CHEST",
            "Spine", "spine", "SPINE",
        }
        for _, name in ipairs(torsoNames) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then return part end
        end
    end
    
    if aimPartName == "Leg" or aimPartName == "腿" then
        local legNames = {
            "LeftLeg", "Left Leg", "leftleg",
            "RightLeg", "Right Leg", "rightleg",
            "Leg", "leg", "LEG",
            "LeftLowerLeg", "RightLowerLeg",
            "LeftFoot", "RightFoot",
        }
        for _, name in ipairs(legNames) do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then return part end
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then return root end
    end
    
    return character:FindFirstChild("HumanoidRootPart")
end

-- ========== 隐身功能 ==========
local originalTransparencies = {}

local function collectAllParts(char)
    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            local handle = child:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                table.insert(parts, handle)
            end
        end
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("MeshPart") and (part.Name == "Shirt" or part.Name == "Pants" or part.Name:find("Clothing")) then
            table.insert(parts, part)
        end
    end
    return parts
end

local function enableInvisibility()
    safeCall(function()
        local char = Player.Character
        if not char then return end
        originalTransparencies = {}
        local parts = collectAllParts(char)
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") then
                originalTransparencies[part] = part.LocalTransparencyModifier or 0
                part.LocalTransparencyModifier = 1
                part.Transparency = 1
            end
        end
        if invisibleConnection then invisibleConnection:Disconnect() end
        invisibleConnection = RunService.Stepped:Connect(function()
            if not Settings.Invisible then return end
            local currentChar = Player.Character
            if not currentChar then return end
            local currentParts = collectAllParts(currentChar)
            for _, part in ipairs(currentParts) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 1
                    part.Transparency = 1
                end
            end
        end)
    end)
end

local function disableInvisibility()
    Settings.Invisible = false
    safeCall(function()
        if invisibleConnection then
            invisibleConnection:Disconnect()
            invisibleConnection = nil
        end
        local char = Player.Character
        if char then
            for part, origTrans in pairs(originalTransparencies) do
                if part and part.Parent and part:IsA("BasePart") then
                    part.LocalTransparencyModifier = origTrans
                    part.Transparency = 0
                end
            end
        end
        originalTransparencies = {}
    end)
end

Player.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if Settings.Invisible then safeCall(enableInvisibility) end
end)

-- ========== 黑洞 ==========
local function StartBlackHole()
    safeCall(function()
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
    end)
end

local function StopBlackHole()
    Settings.BlackHole = false
    safeCall(function()
        if blackHoleConnection then
            blackHoleConnection:Disconnect()
            blackHoleConnection = nil
        end
    end)
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
    local speed = Settings.AimSpeed or 0.5
    local d = math.floor(distance / 5) * 5
    local baseStrength = 0.14
    if d <= 5 then baseStrength = 0.58
    elseif d <= 10 then baseStrength = 0.53
    elseif d <= 15 then baseStrength = 0.48
    elseif d <= 20 then baseStrength = 0.43
    elseif d <= 25 then baseStrength = 0.38
    elseif d <= 30 then baseStrength = 0.33
    elseif d <= 40 then baseStrength = 0.28
    elseif d <= 50 then baseStrength = 0.23
    elseif d <= 70 then baseStrength = 0.18
    else baseStrength = 0.14 end
    return math.min(baseStrength * (1 + speed * 1.5), 0.98)
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
    local vp = Camera.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local closest = nil
    local minDist = 9999
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local part = findAimPart(char, Settings.AimPart)
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

-- ========== 自瞄循环 ==========
local aimbotLoopRunning = true
local function aimbotLoop()
    while aimbotLoopRunning do
        safeCall(function()
            local active = Settings.DynamicAimbot
            if not active then
                if circle then circle.Visible = false end
                if aimLine then aimLine.Visible = false end
                currentTarget = nil
            else
                circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                aimLine.From = circle.Position
                currentTarget = getTargetInCircle()
                if currentTarget then
                    local tpos, onScreen = Camera:WorldToViewportPoint(currentTarget.Position)
                    if not onScreen or tpos.Z < 0 or not isVisible(currentTarget) then
                        currentTarget = nil
                    end
                end
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
        end)
        task.wait()
    end
end

local function aimbotAimLoop()
    while aimbotLoopRunning do
        safeCall(function()
            if Settings.DynamicAimbot and currentTarget and isVisible(currentTarget) then
                local camPos = Camera.CFrame.Position
                local tarPos = currentTarget.Position
                local dist = (camPos - tarPos).Magnitude
                local strength = getAimStrength(dist)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(camPos, tarPos), strength)
            end
        end)
        task.wait()
    end
end

initAimbotDrawing()
task.spawn(aimbotLoop)
task.spawn(aimbotAimLoop)

-- ========== ESP系统 ==========
local espLines = {}
local espTexts = {}

local function clearEspDrawings()
    for _, line in pairs(espLines) do line:Remove() end
    for _, text in pairs(espTexts) do text:Remove() end
    espLines = {}
    espTexts = {}
end

local function getScreenEdgeFromWorldDirection(targetPos, camera, screenSize)
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local dir = (targetPos - camera.CFrame.Position).Unit
    local screenDir = Vector2.new(
        dir:Dot(camera.CFrame.RightVector),
        -dir:Dot(camera.CFrame.UpVector)
    )
    if screenDir.Magnitude < 0.001 then return center end
    local halfW = screenSize.X / 2 - 20
    local halfH = screenSize.Y / 2 - 20
    local scaleX = halfW / math.abs(screenDir.X)
    local scaleY = halfH / math.abs(screenDir.Y)
    local scale = math.min(scaleX, scaleY)
    return center + screenDir * scale
end

local function updateEspSystem()
    if not DrawingAvailable then return end
    clearEspDrawings()
    local screenSize = Camera.ViewportSize
    local center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if not char then continue end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not rootPart then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
            local health = hum and math.floor(hum.Health) or 0
            local maxHealth = hum and math.floor(hum.MaxHealth) or 100
            local healthPercent = maxHealth > 0 and (health / maxHealth) or 0
            local color = Color3.fromHSV(healthPercent * 0.3, 1, 1)

            local isActuallyVisible = onScreen and pos.Z > 0

            if Settings.EspLine then
                local lineColor = isActuallyVisible and color or Color3.new(1, 0.3, 0.3)
                local line = Drawing.new("Line")
                line.Visible = true
                line.Color = lineColor
                line.Thickness = 1
                line.From = center
                if isActuallyVisible then
                    line.To = Vector2.new(pos.X, pos.Y)
                else
                    local edgePos = getScreenEdgeFromWorldDirection(rootPart.Position, Camera, screenSize)
                    line.To = edgePos
                end
                table.insert(espLines, line)
            end

            if Settings.EspInfo then
                local displayPos
                if isActuallyVisible then
                    displayPos = Vector2.new(pos.X, pos.Y)
                else
                    displayPos = getScreenEdgeFromWorldDirection(rootPart.Position, Camera, screenSize)
                end
                
                local nameText = Drawing.new("Text")
                nameText.Visible = true
                nameText.Position = displayPos + Vector2.new(0, -20)
                nameText.Text = plr.Name
                nameText.Color = Color3.new(1, 1, 1)
                nameText.Size = 14
                nameText.Center = true
                nameText.Outline = true
                nameText.OutlineColor = Color3.new(0, 0, 0)
                table.insert(espTexts, nameText)
                
                local healthText = Drawing.new("Text")
                healthText.Visible = true
                healthText.Position = displayPos + Vector2.new(0, 5)
                healthText.Text = string.format("❤ %d/%d", health, maxHealth)
                healthText.Color = color
                healthText.Size = 12
                healthText.Center = true
                healthText.Outline = true
                healthText.OutlineColor = Color3.new(0, 0, 0)
                table.insert(espTexts, healthText)
                
                local distText = Drawing.new("Text")
                distText.Visible = true
                distText.Position = displayPos + Vector2.new(0, 22)
                distText.Text = string.format("距离 %.0fm", distance)
                distText.Color = Color3.new(1, 1, 0.8)
                distText.Size = 11
                distText.Center = true
                distText.Outline = true
                distText.OutlineColor = Color3.new(0, 0, 0)
                table.insert(espTexts, distText)
            end
        end
    end
end

local espConnection
local function enableEspSystem()
    if espConnection then espConnection:Disconnect() end
    espConnection = RunService.Heartbeat:Connect(function()
        if Settings.EspLine or Settings.EspInfo then
            updateEspSystem()
        else
            clearEspDrawings()
        end
    end)
end

local function disableEspSystem()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    clearEspDrawings()
end

-- ========== ESP高亮 ==========
local espActive = false
local function addHighlightToPlayer(p)
    if p == Player then return end
    local function add()
        if not p.Character then return end
        if p.Character:FindFirstChild("ESP") then p.Character.ESP:Destroy() end
        
        local e = Instance.new("Highlight")
        e.Name = "ESP"
        e.FillColor = Color3.fromRGB(255, 255, 255)
        e.OutlineColor = Color3.fromRGB(255, 0, 0)
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

enableEspSystem()

-- ========== 防踢功能 ==========
local function loadAntiKick()
    if antiKickLoaded then
        WindUI:Notify({
            Title = "提示",
            Content = "防踢已加载，请勿重复执行",
            Duration = 3
        })
        return
    end
    
    antiKickLoaded = true
    safeCall(function()
        WindUI:Notify({
            Title = "防踢已加载",
            Content = "输入 /antikick 开启或关闭",
            Duration = 5
        })
        
        local MasterEnabled = false
        
        local function toggleAntiKick(Value)
            MasterEnabled = Value
            if Value then
                local mt = getrawmetatable(game)
                if mt then
                    setreadonly(mt, false)
                    local old = mt.__namecall
                    mt.__namecall = newcclosure(function(Self, ...)
                        local method = getnamecallmethod()
                        if method == "Kick" and Self == game.Players.LocalPlayer then
                            for i = 1, 10 do
                                game.StarterGui:SetCore("SendNotification", {
                                    Title = "拦截成功！";
                                    Text = "服务器想踢我？做梦去吧！";
                                    Duration = 3;
                                })
                                task.wait(0.3)
                            end
                            game.StarterGui:SetCore("SendNotification", {
                                Title = "拦截成功";
                                Text = "服务器踢不动老子！";
                                Duration = 10;
                            })
                            return
                        end
                        return old(Self, ...)
                    end)
                    setreadonly(mt, true)
                end
                
                game.Players.LocalPlayer.CharacterRemoving:Connect(function()
                    task.wait(0.1)
                    game.Players.LocalPlayer:LoadCharacter()
                end)
                
                local connection
                connection = game:GetService("RunService").Stepped:Connect(function()
                    if not MasterEnabled then 
                        connection:Disconnect()
                        return 
                    end
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart
                        root.CFrame = root.CFrame + Vector3.new(math.random(-5,5)/100, 0, math.random(-5,5)/100)
                    end
                end)
                
                game.Players.LocalPlayer.OnTeleport:Connect(function(State)
                    if State == Enum.TeleportState.Started then
                        task.wait(0.1)
                        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
                    end
                end)
                
                WindUI:Notify({Title = "全开无敌", Content = "高检测服务器死了？", Duration = 6})
            end
        end
        
        game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
            if msg:lower() == "/antikick" then
                MasterEnabled = not MasterEnabled
                if MasterEnabled then
                    toggleAntiKick(true)
                    WindUI:Notify({Title = "防踢已开启", Content = "已激活全部防御", Duration = 3})
                else
                    WindUI:Notify({Title = "防踢已关闭", Content = "已关闭防御", Duration = 3})
                end
            end
        end)
    end)
end

-- ========== 飞行脚本加载（黎铭飞行，白色半透明） ==========
local function loadFlyScript()
    safeCall(function()
        WindUI:Notify({
            Title = "黎铭飞行已加载",
            Content = "点击按钮打开飞行面板",
            Duration = 3
        })
        
        local main = Instance.new("ScreenGui")
        main.Name = "FlyScript"
        main.Parent = Player:WaitForChild("PlayerGui")
        main.ResetOnSpawn = false
        
        local Frame = Instance.new("Frame")
        Frame.Parent = main
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.4
        Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
        Frame.Size = UDim2.new(0, 190, 0, 57)
        Frame.Active = true
        Frame.Draggable = true
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 8)
        frameCorner.Parent = Frame
        
        local up = Instance.new("TextButton")
        up.Parent = Frame
        up.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        up.BackgroundTransparency = 0.5
        up.Size = UDim2.new(0, 44, 0, 28)
        up.Font = Enum.Font.SourceSans
        up.Text = "上升"
        up.TextColor3 = Color3.fromRGB(50, 50, 50)
        up.TextSize = 14
        local upCorner = Instance.new("UICorner")
        upCorner.CornerRadius = UDim.new(0, 4)
        upCorner.Parent = up
        
        local down = Instance.new("TextButton")
        down.Parent = Frame
        down.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        down.BackgroundTransparency = 0.5
        down.Position = UDim2.new(0, 0, 0.491228074, 0)
        down.Size = UDim2.new(0, 44, 0, 28)
        down.Font = Enum.Font.SourceSans
        down.Text = "下降"
        down.TextColor3 = Color3.fromRGB(50, 50, 50)
        down.TextSize = 14
        local downCorner = Instance.new("UICorner")
        downCorner.CornerRadius = UDim.new(0, 4)
        downCorner.Parent = down
        
        local onof = Instance.new("TextButton")
        onof.Parent = Frame
        onof.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        onof.BackgroundTransparency = 0.5
        onof.Position = UDim2.new(0.702823281, 0, 0.491228074, 0)
        onof.Size = UDim2.new(0, 56, 0, 28)
        onof.Font = Enum.Font.SourceSans
        onof.Text = "飞行"
        onof.TextColor3 = Color3.fromRGB(50, 50, 50)
        onof.TextSize = 14
        local onofCorner = Instance.new("UICorner")
        onofCorner.CornerRadius = UDim.new(0, 4)
        onofCorner.Parent = onof
        
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = Frame
        TextLabel.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        TextLabel.BackgroundTransparency = 0.6
        TextLabel.Position = UDim2.new(0.469327301, 0, 0, 0)
        TextLabel.Size = UDim2.new(0, 100, 0, 28)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "黎铭飞行"
        TextLabel.TextColor3 = Color3.fromRGB(30, 30, 30)
        TextLabel.TextScaled = true
        TextLabel.TextSize = 14
        TextLabel.TextWrapped = true
        
        local plus = Instance.new("TextButton")
        plus.Parent = Frame
        plus.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        plus.BackgroundTransparency = 0.5
        plus.Position = UDim2.new(0.231578946, 0, 0, 0)
        plus.Size = UDim2.new(0, 45, 0, 28)
        plus.Font = Enum.Font.SourceSans
        plus.Text = "速度+1"
        plus.TextColor3 = Color3.fromRGB(50, 50, 50)
        plus.TextScaled = true
        plus.TextSize = 14
        plus.TextWrapped = true
        local plusCorner = Instance.new("UICorner")
        plusCorner.CornerRadius = UDim.new(0, 4)
        plusCorner.Parent = plus
        
        local speed = Instance.new("TextLabel")
        speed.Parent = Frame
        speed.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        speed.BackgroundTransparency = 0.5
        speed.Position = UDim2.new(0.468421042, 0, 0.491228074, 0)
        speed.Size = UDim2.new(0, 44, 0, 28)
        speed.Font = Enum.Font.SourceSans
        speed.Text = "1"
        speed.TextColor3 = Color3.fromRGB(50, 50, 50)
        speed.TextScaled = true
        speed.TextSize = 14
        speed.TextWrapped = true
        local speedCorner = Instance.new("UICorner")
        speedCorner.CornerRadius = UDim.new(0, 4)
        speedCorner.Parent = speed
        
        local mine = Instance.new("TextButton")
        mine.Parent = Frame
        mine.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        mine.BackgroundTransparency = 0.5
        mine.Position = UDim2.new(0.231578946, 0, 0.491228074, 0)
        mine.Size = UDim2.new(0, 45, 0, 29)
        mine.Font = Enum.Font.SourceSans
        mine.Text = "速度-1"
        mine.TextColor3 = Color3.fromRGB(50, 50, 50)
        mine.TextScaled = true
        mine.TextSize = 14
        mine.TextWrapped = true
        local mineCorner = Instance.new("UICorner")
        mineCorner.CornerRadius = UDim.new(0, 4)
        mineCorner.Parent = mine
        
        local closebutton = Instance.new("TextButton")
        closebutton.Parent = Frame
        closebutton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        closebutton.BackgroundTransparency = 0.5
        closebutton.Font = "SourceSans"
        closebutton.Size = UDim2.new(0, 45, 0, 28)
        closebutton.Text = "关闭"
        closebutton.TextColor3 = Color3.fromRGB(50, 50, 50)
        closebutton.TextSize = 30
        closebutton.Position = UDim2.new(0, 0, -1, 27)
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closebutton
        
        local mini = Instance.new("TextButton")
        mini.Parent = Frame
        mini.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        mini.BackgroundTransparency = 0.5
        mini.Font = "SourceSans"
        mini.Size = UDim2.new(0, 45, 0, 28)
        mini.Text = "隐藏"
        mini.TextColor3 = Color3.fromRGB(50, 50, 50)
        mini.TextSize = 30
        mini.Position = UDim2.new(0, 44, -1, 27)
        local miniCorner = Instance.new("UICorner")
        miniCorner.CornerRadius = UDim.new(0, 4)
        miniCorner.Parent = mini
        
        local mini2 = Instance.new("TextButton")
        mini2.Parent = Frame
        mini2.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        mini2.BackgroundTransparency = 0.5
        mini2.Font = "SourceSans"
        mini2.Size = UDim2.new(0, 45, 0, 28)
        mini2.Text = "+"
        mini2.TextColor3 = Color3.fromRGB(50, 50, 50)
        mini2.TextSize = 40
        mini2.Position = UDim2.new(0, 44, -1, 57)
        mini2.Visible = false
        local mini2Corner = Instance.new("UICorner")
        mini2Corner.CornerRadius = UDim.new(0, 4)
        mini2Corner.Parent = mini2
        
        local speedsVal = 1
        local nowe = false
        local tis, dis
        
        onof.MouseButton1Down:Connect(function()
            safeCall(function()
                if nowe == true then
                    nowe = false
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                                hum:SetStateEnabled(state, true)
                            end
                            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
                        end
                        local animate = char:FindFirstChild("Animate")
                        if animate then animate.Disabled = false end
                    end
                else 
                    nowe = true
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        local animate = char:FindFirstChild("Animate")
                        if animate then animate.Disabled = true end
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then
                            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                                hum:SetStateEnabled(state, false)
                            end
                            hum:ChangeState(Enum.HumanoidStateType.Swimming)
                        end
                    end
                    
                    local plr = game.Players.LocalPlayer
                    local char2 = plr.Character
                    if char2 then
                        local torso = char2:FindFirstChild("Torso") or char2:FindFirstChild("UpperTorso")
                        if torso then
                            local bg = Instance.new("BodyGyro", torso)
                            bg.P = 9e4
                            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                            bg.cframe = torso.CFrame
                            local bv = Instance.new("BodyVelocity", torso)
                            bv.velocity = Vector3.new(0,0.1,0)
                            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
                            if nowe == true then
                                plr.Character.Humanoid.PlatformStand = true
                            end
                            local ctrl = {f = 0, b = 0, l = 0, r = 0}
                            local lastctrl = {f = 0, b = 0, l = 0, r = 0}
                            local maxspeed = 50
                            local speedVal = 0
                            game:GetService("UserInputService").InputBegan:Connect(function(input)
                                if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
                                if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
                                if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
                                if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
                            end)
                            game:GetService("UserInputService").InputEnded:Connect(function(input)
                                if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
                                if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
                                if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
                                if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
                            end)
                            while nowe == true do
                                wait()
                                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                                    speedVal = speedVal + 0.5 + (speedVal/maxspeed)
                                    if speedVal > maxspeed then speedVal = maxspeed end
                                elseif speedVal ~= 0 then
                                    speedVal = speedVal - 1
                                    if speedVal < 0 then speedVal = 0 end
                                end
                                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f+ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*0.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speedVal
                                    lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
                                elseif speedVal ~= 0 then
                                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f+lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*0.2,0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speedVal
                                else
                                    bv.velocity = Vector3.new(0,0,0)
                                end
                                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speedVal/maxspeed),0,0)
                            end
                            bg:Destroy()
                            bv:Destroy()
                            if plr.Character and plr.Character.Humanoid then
                                plr.Character.Humanoid.PlatformStand = false
                            end
                        end
                    end
                end
            end)
        end)
        
        up.MouseButton1Down:Connect(function()
            tis = up.MouseEnter:Connect(function()
                while tis do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,1,0)
                    end
                end
            end)
        end)
        up.MouseLeave:Connect(function()
            if tis then tis:Disconnect(); tis = nil end
        end)
        
        down.MouseButton1Down:Connect(function()
            dis = down.MouseEnter:Connect(function()
                while dis do
                    wait()
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0,-1,0)
                    end
                end
            end)
        end)
        down.MouseLeave:Connect(function()
            if dis then dis:Disconnect(); dis = nil end
        end)
        
        plus.MouseButton1Down:Connect(function()
            speedsVal = speedsVal + 1
            speed.Text = speedsVal
        end)
        
        mine.MouseButton1Down:Connect(function()
            if speedsVal == 1 then
                speed.Text = 'cannot be less than 1'
                wait(1)
                speed.Text = speedsVal
            else
                speedsVal = speedsVal - 1
                speed.Text = speedsVal
            end
        end)
        
        closebutton.MouseButton1Click:Connect(function()
            main:Destroy()
        end)
        
        mini.MouseButton1Click:Connect(function()
            up.Visible = false; down.Visible = false; onof.Visible = false
            plus.Visible = false; speed.Visible = false; mine.Visible = false
            mini.Visible = false; mini2.Visible = true
            Frame.BackgroundTransparency = 1
            closebutton.Position = UDim2.new(0, 0, -1, 57)
        end)
        
        mini2.MouseButton1Click:Connect(function()
            up.Visible = true; down.Visible = true; onof.Visible = true
            plus.Visible = true; speed.Visible = true; mine.Visible = true
            mini.Visible = true; mini2.Visible = false
            Frame.BackgroundTransparency = 0.4
            closebutton.Position = UDim2.new(0, 0, -1, 27)
        end)
        
        WindUI:Notify({Title = "黎铭飞行面板已打开", Content = "点击飞行按钮开始飞行", Duration = 3})
    end)
end

-- ========== 主界面创建 ==========
local function createMainGUI()
    if mainWindowCreated then return end
    mainWindowCreated = true
    
    Window = WindUI:CreateWindow({
        Title = "dawn",
        Icon = "flower",
        Author = "黎铭",
        Folder = "dawn",
        Size = UDim2.fromOffset(580, 500),
        Transparent = false,
        Theme = "Dark",
        SideBarWidth = 180,
        HasOutline = true,
    })

    Window:EditOpenButton({
        Title = "打开 dawn",
        Icon = "flower",
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 2,
        Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    })

    local Tabs = {
        General  = Window:Tab({ Title = "通用", Icon = "settings" }),
        Visual   = Window:Tab({ Title = "视觉", Icon = "eye" }),
        Combat   = Window:Tab({ Title = "战斗", Icon = "crosshair" }),
    }

    Window:SelectTab(1)

    -- ===== 通用标签页 =====
    Tabs.General:Toggle({
        Title = "加速",
        Value = Settings.SpeedBoost,
        Callback = function(v)
            Settings.SpeedBoost = v
            updateSpeed()
        end
    })

    Tabs.General:Slider({
        Title = "速度大小",
        Value = {
            Min = 20,
            Max = 200,
            Default = Settings.WalkSpeedValue,
        },
        Callback = function(value)
            Settings.WalkSpeedValue = value
            updateSpeed()
        end
    })

    Tabs.General:Toggle({
        Title = "升天",
        Value = Settings.Fly,
        Callback = function(v)
            Settings.Fly = v
            if v then enableFly() else disableFly() end
        end
    })

    Tabs.General:Slider({
        Title = "升天速度",
        Value = {
            Min = 1,
            Max = 50,
            Default = Settings.FlySpeed,
        },
        Callback = function(value)
            Settings.FlySpeed = value
        end
    })

    Tabs.General:Toggle({
        Title = "固定在原地",
        Value = Settings.Fixed,
        Callback = function(v)
            if v then enableFixed() else disableFixed() end
        end
    })

    Tabs.General:Toggle({
        Title = "穿墙",
        Value = Settings.NoClip,
        Callback = function(v)
            if v then enableNoClip() else disableNoClip() end
        end
    })

    Tabs.General:Toggle({
        Title = "隐身（只隐藏身体）",
        Value = Settings.Invisible,
        Callback = function(v)
            Settings.Invisible = v
            if v then enableInvisibility() else disableInvisibility() end
        end
    })

    Tabs.General:Toggle({
        Title = "黑洞",
        Value = Settings.BlackHole,
        Callback = function(v)
            Settings.BlackHole = v
            if v then StartBlackHole() else StopBlackHole() end
        end
    })

    Tabs.General:Toggle({
        Title = "上帝模式 (无敌)",
        Value = Settings.GodMode,
        Callback = function(v)
            if v then enableGodMode() else disableGodMode() end
        end
    })

    Tabs.General:Button({
        Title = "加载高检测防踢",
        Callback = function()
            loadAntiKick()
        end
    })

    Tabs.General:Button({
        Title = "加载黎铭飞行 (独立GUI)",
        Callback = function()
            loadFlyScript()
        end
    })

    Tabs.General:Button({
        Title = "加载翻译引擎",
        Callback = function()
            loadTranslation()
        end
    })

    -- ===== 视觉标签页 =====
    Tabs.Visual:Toggle({
        Title = "ESP 透视高亮",
        Value = Settings.Esp,
        Callback = function(v)
            Settings.Esp = v
            if v then enableEsp() else disableEsp() end
        end
    })

    Tabs.Visual:Toggle({
        Title = "屏幕中心连线",
        Value = Settings.EspLine,
        Callback = function(v)
            Settings.EspLine = v
        end
    })

    Tabs.Visual:Toggle({
        Title = "角色信息显示（含血量）",
        Value = Settings.EspInfo,
        Callback = function(v)
            Settings.EspInfo = v
        end
    })

    Tabs.Visual:Toggle({
        Title = "头顶光环 (仅自己可见)",
        Value = Settings.Halo,
        Callback = function(v)
            if v then enableHalo() else disableHalo() end
        end
    })

    -- ===== 战斗标签页 =====
    Tabs.Combat:Toggle({
        Title = "动态自瞄",
        Value = Settings.DynamicAimbot,
        Callback = function(v)
            Settings.DynamicAimbot = v
        end
    })

    Tabs.Combat:Slider({
        Title = "自瞄速度",
        Value = {
            Min = 0.1,
            Max = 1.0,
            Default = Settings.AimSpeed,
        },
        Callback = function(value)
            Settings.AimSpeed = value
        end
    })

    Tabs.Combat:Slider({
        Title = "自瞄光圈大小",
        Value = {
            Min = 15,
            Max = 450,
            Default = BASE_RADIUS,
        },
        Callback = function(value)
            BASE_RADIUS = value
            if not currentTarget then currentRadius = value end
        end
    })

    Tabs.Combat:Dropdown({
        Title = "瞄准部位",
        Values = { "Head", "Torso", "Leg" },
        Value = "Head",
        Multi = false,
        AllowNone = false,
        Callback = function(part)
            Settings.AimPart = part
        end
    })

    -- 传送功能
    Tabs.Combat:Section({ Title = "传送到玩家" })

    local function refreshPlayerList()
        local names = {}
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= Player then
                table.insert(names, plr.Name)
            end
        end
        return names
    end

    local playerDropdown = Tabs.Combat:Dropdown({
        Title = "选择玩家",
        Values = refreshPlayerList(),
        Multi = false,
        AllowNone = false,
        Callback = function(name)
            if name then
                selectedTeleportPlayer = Players:FindFirstChild(name)
            end
        end
    })

    Tabs.Combat:Button({
        Title = "刷新玩家列表",
        Callback = function()
            playerDropdown:Refresh(refreshPlayerList())
            WindUI:Notify({
                Title = "已刷新",
                Content = "玩家列表已更新",
                Duration = 2
            })
        end
    })

    Tabs.Combat:Button({
        Title = "传送到选中玩家",
        Callback = function()
            if selectedTeleportPlayer then
                teleportToPlayer(selectedTeleportPlayer)
            else
                WindUI:Notify({
                    Title = "错误",
                    Content = "请先选择要传送的玩家",
                    Duration = 3
                })
            end
        end
    })

    -- 退出
    Window:Tab({ Title = "退出", Icon = "log-out" }):Button({
        Title = "关闭所有功能并退出",
        Callback = function()
            Settings.DynamicAimbot = false
            Settings.BlackHole = false
            Settings.Esp = false
            Settings.EspLine = false
            Settings.EspInfo = false
            Settings.Invisible = false
            Settings.Fly = false
            Settings.GodMode = false
            Settings.Halo = false
            Settings.Fixed = false
            Settings.NoClip = false
            disableEsp()
            disableEspSystem()
            disableInvisibility()
            disableFly()
            disableFixed()
            disableNoClip()
            StopBlackHole()
            disableGodMode()
            disableHalo()
            Window:Destroy()
        end
    })
end

-- ========== iOS风格验证UI ==========
local function showVerificationUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VerificationUI"
    screenGui.Parent = Player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- 毛玻璃背景
    local blur = Instance.new("BlurEffect")
    blur.Parent = game:GetService("Lighting")
    blur.Size = 0
    
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.4
    background.Parent = screenGui
    
    -- 主弹窗 - iOS风格
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = mainFrame
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 44)
    title.Position = UDim2.new(0, 0, 0, 16)
    title.BackgroundTransparency = 1
    title.Text = "验证"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextSize = 20
    title.Font = Enum.Font.GothamMedium
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = mainFrame
    
    -- 副标题
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -32, 0, 20)
    subtitle.Position = UDim2.new(0, 16, 0, 62)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "请输入验证码以继续"
    subtitle.TextColor3 = Color3.fromRGB(100, 100, 110)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Center
    subtitle.Parent = mainFrame
    
    -- 输入框 - iOS风格
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.85, 0, 0, 44)
    inputBox.Position = UDim2.new(0.075, 0, 0, 90)
    inputBox.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
    inputBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    inputBox.TextSize = 16
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = "验证码"
    inputBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 190)
    inputBox.Text = ""
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = mainFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputBox
    
    -- 分割线
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 148)
    divider.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    divider.BackgroundTransparency = 0
    divider.BorderSizePixel = 0
    divider.Parent = mainFrame
    
    -- 按钮容器
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 52)
    buttonContainer.Position = UDim2.new(0, 0, 0, 148)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame
    
    -- 取消按钮 - iOS风格
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0.5, -0.5, 1, 0)
    cancelBtn.Position = UDim2.new(0, 0, 0, 0)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    cancelBtn.TextColor3 = Color3.fromRGB(0, 122, 255)
    cancelBtn.TextSize = 17
    cancelBtn.Font = Enum.Font.GothamMedium
    cancelBtn.Text = "取消"
    cancelBtn.BackgroundTransparency = 1
    cancelBtn.Parent = buttonContainer
    
    -- 确认按钮 - iOS风格
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0.5, -0.5, 1, 0)
    confirmBtn.Position = UDim2.new(0.5, 0.5, 0, 0)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    confirmBtn.TextColor3 = Color3.fromRGB(0, 122, 255)
    confirmBtn.TextSize = 17
    confirmBtn.Font = Enum.Font.GothamMedium
    confirmBtn.Text = "确认"
    confirmBtn.BackgroundTransparency = 1
    confirmBtn.Parent = buttonContainer
    
    -- 垂直分割线
    local vDivider = Instance.new("Frame")
    vDivider.Size = UDim2.new(0, 1, 1, 0)
    vDivider.Position = UDim2.new(0.5, 0, 0, 0)
    vDivider.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    vDivider.BackgroundTransparency = 0
    vDivider.BorderSizePixel = 0
    vDivider.Parent = buttonContainer
    
    -- 错误提示
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(0.85, 0, 0, 20)
    errorLabel.Position = UDim2.new(0.075, 0, 0, 138)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = ""
    errorLabel.TextColor3 = Color3.fromRGB(255, 59, 48)
    errorLabel.TextSize = 12
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.TextXAlignment = Enum.TextXAlignment.Center
    errorLabel.Visible = false
    errorLabel.Parent = mainFrame
    
    -- 按钮点击事件
    cancelBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        if blur then blur:Destroy() end
    end)
    
    confirmBtn.MouseButton1Click:Connect(function()
        local inputText = inputBox.Text
        if inputText == "dawn" then
            screenGui:Destroy()
            if blur then blur:Destroy() end
            createMainGUI()
            WindUI:Notify({
                Title = "验证成功",
                Content = "正在加载脚本...",
                Duration = 2
            })
        else
            errorLabel.Text = "验证码错误，请重试"
            errorLabel.Visible = true
            inputBox.Text = ""
            inputBox:CaptureFocus()
            task.wait(2)
            errorLabel.Visible = false
        end
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            confirmBtn.MouseButton1Click:Fire()
        end
    end)
    
    task.wait(0.1)
    inputBox:CaptureFocus()
end

-- ========== 启动验证 ==========
showVerificationUI()