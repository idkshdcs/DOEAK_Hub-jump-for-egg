-- ==========================================
-- DOEAK HUB - JUMP FOR ANIMALS (FINAL)
-- Key UI + Auto Steal + Auto Place + Character
-- ==========================================

-- Xóa UI cũ
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("DoeakKeyUI") then
    CoreGui.DoeakKeyUI:Destroy()
end

-- ==========================================
-- KEY UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DoeakKeyUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 240)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "🐉 Doeak Hub | Key System"
Title.TextColor3 = Color3.fromRGB(230, 230, 240)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.85, 0, 0, 42)
TextBox.Position = UDim2.new(0.075, 0, 0, 55)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderText = "Nhập Key..."
TextBox.Text = ""
TextBox.TextSize = 14
TextBox.Font = Enum.Font.Gotham
TextBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = TextBox

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.4, 0, 0, 38)
SubmitBtn.Position = UDim2.new(0.075, 0, 0, 115)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
SubmitBtn.Text = "Submit Key"
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.TextSize = 14
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 6)
BtnCorner1.Parent = SubmitBtn

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 38)
GetKeyBtn.Position = UDim2.new(0.525, 0, 0, 115)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.TextSize = 14
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Parent = MainFrame

local BtnCorner2 = Instance.new("UICorner")
BtnCorner2.CornerRadius = UDim.new(0, 6)
BtnCorner2.Parent = GetKeyBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 175)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

GetKeyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard("https://anotepad.com/notes/7xqnhka3")
            StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
            StatusLabel.Text = "Đã copy link Get Key!"
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            StatusLabel.Text = "Executor không hỗ trợ copy!"
        end
    end)
end)

-- ==========================================
-- MAIN SCRIPT
-- ==========================================
local function LoadMainScript()
    ScreenGui:Destroy()
    
    -- Load Rayfield
    local Rayfield
    for _, url in ipairs({
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
    }) do
        local ok, res = pcall(function() return loadstring(game:HttpGet(url))() end)
        if ok and res and type(res) == "table" then Rayfield = res; break end
    end
    if not Rayfield then warn("Không load được Rayfield!"); return end

    local Window = Rayfield:CreateWindow({
        Name = "🐉 Doeak Hub | Jump for Animals",
        LoadingTitle = "Đang tải...",
        LoadingSubtitle = "by Doeak",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
    })

    -- ===== SERVICES =====
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")

    -- ===== BIẾN =====
    local selectedArena = "Meadow"
    local autoStealAFK = false
    local isBusy = false
    local PLACE_RADIUS = 25
    local PLACE_HEIGHT = 5
    local USE_RANDOM = true
    local CLICK_COUNT = 4
    local walkSpeed = 50
    local jumpPower = 100

    -- ===== LOG =====
    local function L(msg) print("[Doeak] " .. msg) end
    local function posStr(v) 
        if not v then return "nil" end
        return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z) 
    end

    -- ===== HELPERS =====
    local function getCarried()
        return tonumber(LocalPlayer:GetAttribute("CarriedEggCount")) or 0
    end

    local function getMyPlot()
        local map = Workspace:FindFirstChild("Map")
        if not map then return nil end
        local plots = map:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in pairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner then
                local val = tostring(owner.Value)
                if val == tostring(LocalPlayer.UserId) or val == LocalPlayer.Name then
                    return plot
                end
            end
        end
        return nil
    end

    local function getPlotCenter()
        local plot = getMyPlot()
        if not plot then return nil end
        local sum = Vector3.new(0, 0, 0)
        local count = 0
        for _, obj in pairs(plot:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "EggRoot" then
                local isInPlacedEggs = false
                local p = obj.Parent
                while p and p ~= plot do
                    if p.Name == "PlacedEggs" then isInPlacedEggs = true; break end
                    p = p.Parent
                end
                if not isInPlacedEggs then
                    sum = sum + obj.Position
                    count = count + 1
                end
            end
        end
        if count > 0 then return sum / count end
        if plot:IsA("Model") then
            local ok, pivot = pcall(function() return plot:GetPivot().Position end)
            if ok and pivot then return pivot end
        end
        return nil
    end

    local function getPlacePosition()
        local center = getPlotCenter()
        if not center then return nil end
        if USE_RANDOM then
            local angle = math.random() * math.pi * 2
            local radius = math.random() * PLACE_RADIUS
            return center + Vector3.new(math.cos(angle) * radius, PLACE_HEIGHT, math.sin(angle) * radius)
        end
        return center + Vector3.new(0, PLACE_HEIGHT, 0)
    end

    local function findEgg()
        local map = Workspace:FindFirstChild("Map")
        if not map then return nil end
        local stages = map:FindFirstChild("Stages")
        if not stages then return nil end
        local stage = stages:FindFirstChild(selectedArena)
        if not stage then return nil end
        local spawnedEggs = stage:FindFirstChild("SpawnedEggs")
        if not spawnedEggs then return nil end
        local eggs = {}
        for _, eggModel in pairs(spawnedEggs:GetChildren()) do
            local eggRoot = eggModel:FindFirstChild("EggRoot")
            if eggRoot then
                local attach = eggRoot:FindFirstChild("EggPromptAttachment")
                if attach then
                    local prompt = attach:FindFirstChild("CollectPrompt")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        table.insert(eggs, { Model = eggModel, Root = eggRoot, Prompt = prompt })
                    end
                end
            end
        end
        if #eggs == 0 then return nil end
        return eggs[math.random(1, #eggs)]
    end

    local function flyTo(pos)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local dist = (hrp.Position - pos).Magnitude
        local time = math.clamp(dist / 220, 0.15, 5)
        local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
        tween:Play()
        tween.Completed:Wait()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        return true
    end

    local function findEggTool()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return nil end
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find("egg") then
                return item
            end
        end
        return nil
    end

    local function clickAt(x, y)
        pcall(function()
            if VirtualInputManager then
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
        end)
    end

    local function clickRandom()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local x = math.random(math.floor(vp.X * 0.3), math.floor(vp.X * 0.7))
        local y = math.random(math.floor(vp.Y * 0.3), math.floor(vp.Y * 0.7))
        clickAt(x, y)
    end

    local function lookAtPlot()
        local center = getPlotCenter()
        if not center then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local lookDir = (center - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + lookDir)
        local cam = Workspace.CurrentCamera
        if cam then
            pcall(function() cam.CFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 3, 0), center) end)
        end
    end

    local function placeEgg()
        local plot = getMyPlot()
        if not plot then L("⚠ Không có plot"); return false end
        local eggTool = findEggTool()
        if not eggTool then L("⚠ Không có egg tool"); return false end
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return false end

        if eggTool.Parent ~= char then
            humanoid:EquipTool(eggTool)
            task.wait(0.4)
        end
        L("Equip: " .. eggTool.Name)

        local placePos = getPlacePosition()
        if not placePos then return false end
        L("Bay tới: " .. posStr(placePos))
        flyTo(placePos)
        task.wait(0.3)
        lookAtPlot()
        task.wait(0.3)

        -- Fire HatchPrompt (skip animation)
        for _, obj in pairs(plot:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                local action = obj.ActionText:lower()
                if action:find("skip") or action:find("hatch") then
                    if fireproximityprompt then fireproximityprompt(obj) end
                end
            end
        end
        task.wait(0.3)

        -- Click random để đặt
        L("Click " .. CLICK_COUNT .. " lần")
        for i = 1, CLICK_COUNT do
            clickRandom()
            task.wait(0.4)
            if getCarried() == 0 then
                L("✅ Đã đặt (sau " .. i .. " click)")
                return true
            end
        end

        -- Retry nếu chưa
        if getCarried() > 0 then
            for _, obj in pairs(plot:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and fireproximityprompt then
                    fireproximityprompt(obj)
                end
            end
            for i = 1, 3 do
                clickRandom()
                task.wait(0.4)
                if getCarried() == 0 then
                    L("✅ Đã đặt sau retry")
                    return true
                end
            end
        end

        for i = 1, 10 do
            task.wait(0.3)
            if getCarried() == 0 then L("✅ Đã đặt"); return true end
        end
        L("❌ Đặt thất bại")
        return false
    end

    -- ==========================================
    -- TAB AUTO FARM
    -- ==========================================
    local TabMain = Window:CreateTab("Auto Farm", 4483362458)

    TabMain:CreateDropdown({
        Name = "Chọn Khu Vực",
        Options = {"Meadow", "Crystal Mines", "Mystic Isles", "Winter", "Desert", 
                   "Prehistoric", "Savannah", "Jungle", "Celestial Heights", "Coral Reef"},
        CurrentOption = {selectedArena},
        Flag = "ArenaFlag",
        Callback = function(Option)
            selectedArena = type(Option) == "table" and (Option[1] or "Meadow") or tostring(Option)
            L("Đổi stage → " .. selectedArena)
        end,
    })

    TabMain:CreateToggle({
        Name = "Auto Steal + Auto Place",
        CurrentValue = false,
        Flag = "AutoStealToggle",
        Callback = function(v)
            autoStealAFK = v
            L(v and "BẬT" or "TẮT")
        end,
    })

    TabMain:CreateToggle({
        Name = "Đặt trứng ngẫu nhiên (dàn đều)",
        CurrentValue = true,
        Flag = "RandomPlaceFlag",
        Callback = function(v) USE_RANDOM = v end,
    })

    TabMain:CreateSlider({
        Name = "Bán kính random (studs)",
        Range = {5, 60},
        Increment = 1,
        CurrentValue = PLACE_RADIUS,
        Flag = "RadiusFlag",
        Callback = function(v) PLACE_RADIUS = v end,
    })

    TabMain:CreateSlider({
        Name = "Độ cao khi đặt (studs)",
        Range = {2, 15},
        Increment = 1,
        CurrentValue = PLACE_HEIGHT,
        Flag = "HeightFlag",
        Callback = function(v) PLACE_HEIGHT = v end,
    })

    TabMain:CreateSlider({
        Name = "Số lần click mỗi lần đặt",
        Range = {1, 10},
        Increment = 1,
        CurrentValue = CLICK_COUNT,
        Flag = "ClickCountFlag",
        Callback = function(v) CLICK_COUNT = v end,
    })

    TabMain:CreateButton({
        Name = "🧪 Test đặt trứng (khi đang cầm)",
        Callback = function()
            task.spawn(function() L("=== Test đặt ==="); placeEgg() end)
        end,
    })

    TabMain:CreateButton({
        Name = "🏠 Teleport về Base",
        Callback = function()
            local pos = getPlotCenter()
            if pos then
                flyTo(pos + Vector3.new(0, 5, 0))
                L("Đã về base")
            end
        end,
    })

    -- ==========================================
    -- TAB CHARACTER
    -- ==========================================
    local TabChar = Window:CreateTab("Nhân vật", 4483362458)

    TabChar:CreateSlider({
        Name = "Tốc độ chạy (WalkSpeed)",
        Range = {16, 300},
        Increment = 1,
        CurrentValue = walkSpeed,
        Flag = "WalkSpeedFlag",
        Callback = function(v) walkSpeed = v end,
    })

    TabChar:CreateSlider({
        Name = "Độ nhảy (JumpPower)",
        Range = {50, 900},
        Increment = 1,
        CurrentValue = jumpPower,
        Flag = "JumpPowerFlag",
        Callback = function(v) jumpPower = v end,
    })

    TabChar:CreateButton({
        Name = "⚡ Áp dụng WalkSpeed & JumpPower",
        Callback = function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = walkSpeed
                hum.JumpPower = jumpPower
                hum.UseJumpPower = true
                L("Đã set: Speed=" .. walkSpeed .. " | Jump=" .. jumpPower)
            end
        end,
    })

    -- Auto update character
    task.spawn(function()
        while true do
            task.wait(0.5)
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed ~= walkSpeed then hum.WalkSpeed = walkSpeed end
                if hum.UseJumpPower and hum.JumpPower ~= jumpPower then
                    hum.JumpPower = jumpPower
                end
            end
        end
    end)

    -- ==========================================
    -- TAB TIỆN ÍCH
    -- ==========================================
    local UtilTab = Window:CreateTab("Tiện ích", 4483340051)

    local originalLighting = { GlobalShadows = nil, Brightness = nil, FogEnd = nil }
    pcall(function()
        originalLighting.GlobalShadows = Lighting.GlobalShadows
        originalLighting.Brightness = Lighting.Brightness
        originalLighting.FogEnd = Lighting.FogEnd
    end)

    local antiAfkConn
    UtilTab:CreateToggle({
        Name = "Anti-AFK",
        CurrentValue = false,
        Flag = "AntiAfkFlag",
        Callback = function(v)
            if v then
                local vu = game:GetService("VirtualUser")
                antiAfkConn = LocalPlayer.Idled:Connect(function()
                    vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                end)
            else
                if antiAfkConn then antiAfkConn:Disconnect() end
                antiAfkConn = nil
            end
        end,
    })

    UtilTab:CreateToggle({
        Name = "Fix Lag (Potato Graphics)",
        CurrentValue = false,
        Flag = "FixLagFlag",
        Callback = function(v)
            pcall(function()
                if v then
                    Lighting.GlobalShadows = false
                    Lighting.Brightness = 1
                    Lighting.FogEnd = 999999
                    for _, p in pairs(Workspace:GetDescendants()) do
                        if p:IsA("ParticleEmitter") or p:IsA("Trail") 
                        or p:IsA("Smoke") or p:IsA("Fire") then
                            p.Enabled = false
                        end
                    end
                else
                    if originalLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = originalLighting.GlobalShadows end
                    if originalLighting.Brightness ~= nil then Lighting.Brightness = originalLighting.Brightness end
                    if originalLighting.FogEnd ~= nil then Lighting.FogEnd = originalLighting.FogEnd end
                end
            end)
        end,
    })

    UtilTab:CreateToggle({
        Name = "Auto Server Hop (30 phút)",
        CurrentValue = false,
        Flag = "HopFlag",
        Callback = function(v)
            _G.AutoHopEnabled = v
        end,
    })

    task.spawn(function()
        while true do
            task.wait(1800)
            if _G.AutoHopEnabled then
                pcall(function()
                    local servers = {}
                    local req = HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                    for _, s in pairs(req.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            table.insert(servers, s.id)
                        end
                    end
                    if #servers > 0 then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                    end
                end)
            end
        end
    end)

    UtilTab:CreateButton({
        Name = "🔄 Server Hop ngay",
        Callback = function()
            pcall(function()
                local servers = {}
                local req = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for _, s in pairs(req.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(servers, s.id)
                    end
                end
                if #servers > 0 then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                end
            end)
        end,
    })

    -- ==========================================
    -- LUỒNG CHÍNH AUTO STEAL
    -- ==========================================
    task.spawn(function()
        L("Vòng lặp sẵn sàng")
        while true do
            task.wait(0.5)
            if autoStealAFK and not isBusy then
                isBusy = true
                local ok, err = pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    -- Đang mang trứng → về base đặt
                    if getCarried() > 0 then
                        L("Mang " .. getCarried() .. " trứng → về base")
                        local placePos = getPlacePosition()
                        if placePos then
                            flyTo(placePos)
                            task.wait(0.3)
                            placeEgg()
                        end
                        return
                    end
                    
                    -- Tìm trứng
                    local egg = findEgg()
                    if not egg then 
                        L("Không có trứng ở " .. selectedArena)
                        task.wait(1)
                        return 
                    end
                    
                    -- Bay tới
                    L("Target: " .. egg.Model.Name)
                    flyTo(egg.Root.Position + Vector3.new(0, 3, 0))
                    task.wait(0.2)
                    
                    -- Fire prompt
                    local carriedBefore = getCarried()
                    if fireproximityprompt then fireproximityprompt(egg.Prompt) end
                    
                    local success = false
                    for i = 1, 15 do
                        task.wait(0.15)
                        if getCarried() > carriedBefore then
                            success = true
                            L("✅ Cướp: " .. egg.Model.Name)
                            break
                        end
                        if i == 7 and fireproximityprompt then
                            fireproximityprompt(egg.Prompt)
                        end
                    end
                    
                    if not success then
                        L("❌ Cướp thất bại")
                        task.wait(0.3)
                        return
                    end
                    
                    -- Về base đặt
                    task.wait(0.3)
                    local placePos = getPlacePosition()
                    if placePos then
                        flyTo(placePos)
                        task.wait(0.3)
                        placeEgg()
                    end
                    
                    L("--- Chu kỳ xong ---")
                end)
                
                if not ok then
                    warn("[Doeak] Lỗi: " .. tostring(err))
                end
                isBusy = false
            end
        end
    end)

    Rayfield:Notify({
        Title = "🐉 Doeak Hub",
        Content = "Script đã sẵn sàng!",
        Duration = 4,
    })
    print("✅ DOEK HUB LOADED")
end

-- ==========================================
-- KEY CHECK
-- ==========================================
SubmitBtn.MouseButton1Click:Connect(function()
    local key = TextBox.Text:gsub("%s+", "")
    if key == "DOEAK-HUB:36" or key == "DOEAK-HUB-36" or key == "doeak-hub:36" then
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        StatusLabel.Text = "✅ Key chính xác! Đang tải..."
        task.wait(0.5)
        LoadMainScript()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        StatusLabel.Text = "❌ Sai key! Thử lại."
    end
end)
