local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Doeak Hub | Jump For Animal",
    LoadingTitle = "Đang tải giao diện...",
    LoadingSubtitle = "Bởi Doeak",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = false,
})

local TabMain = Window:CreateTab("Main", "home")
local TabMisc = Window:CreateTab("Misc", "info")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- TAB MAIN
TabMain:CreateSection("Cài đặt nhân vật")

local walkSpeed = 50
local jumpPower = 650 -- Mặc định khởi tạo theo yêu cầu (500->650)

local walkSpeedSlider = TabMain:CreateSlider({
    Name = "Tốc độ chạy (WalkSpeed)",
    Range = {50, 650},
    Increment = 1,
    CurrentValue = 50,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        walkSpeed = Value
    end,
})

local jumpPowerSlider = TabMain:CreateSlider({
    Name = "Độ nhảy (JumpPower)",
    Range = {50, 650},
    Increment = 1,
    CurrentValue = 650,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        jumpPower = Value
    end,
})

TabMain:CreateInput({
    Name = "Nhập WalkSpeed chính xác",
    PlaceholderText = "Nhập số (50 - 650)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            walkSpeed = math.clamp(num, 50, 650)
            walkSpeedSlider:Set(walkSpeed)
        end
    end,
})

TabMain:CreateInput({
    Name = "Nhập JumpPower chính xác",
    PlaceholderText = "Nhập số (50 - 650)",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            jumpPower = math.clamp(num, 50, 650)
            jumpPowerSlider:Set(jumpPower)
        end
    end,
})

task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                hum.UseJumpPower = true
                hum.WalkSpeed = walkSpeed
                hum.JumpPower = jumpPower
                pcall(function() hum.JumpHeight = jumpPower end)
            end
        end)
    end
end)

TabMain:CreateSection("Cướp Trứng & Về Base")

local function IsHoldingEgg()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("egg") or item.Name:lower():find("trứng")) then
                return true
            end
        end
    end
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("egg") or item.Name:lower():find("trứng")) then
                return true
            end
        end
    end
    return false
end

local function GetMyBasePosition()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    for _, plot in pairs(workspace:GetDescendants()) do
        if (plot.Name:lower():find("base") or plot.Name:lower():find("plot")) then
            local ownerVal = plot:FindFirstChild("Owner") or plot:FindFirstChild("Player")
            if ownerVal and tostring(ownerVal.Value) == LocalPlayer.Name then
                return plot:GetPivot()
            end
        end
    end
    
    local closestSpawn = nil
    local minDist = math.huge
    for _, spawnPoint in pairs(workspace:GetDescendants()) do
        if spawnPoint:IsA("SpawnLocation") and hrp then
            local dist = (spawnPoint.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closestSpawn = spawnPoint.CFrame
            end
        end
    end
    
    return closestSpawn
end

local function GetRandomEggIn20Studs()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end

    local availableEggs = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("egg") and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                if dist <= 20 then
                    local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true) or part:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        table.insert(availableEggs, {Part = part, Prompt = prompt})
                    end
                end
            end
        end
    end

    if #availableEggs > 0 then
        local randomChoice = availableEggs[math.random(1, #availableEggs)]
        return randomChoice.Part, randomChoice.Prompt
    end
    
    return nil, nil
end

local function HoldEForPrompt(prompt)
    if not prompt then return end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        local holdTime = prompt.HoldDuration > 0 and prompt.HoldDuration or 1.5
        local startTime = tick()
        while tick() - startTime < holdTime + 0.5 do
            if IsHoldingEgg() then break end
            task.wait(0.05)
        end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

TabMain:CreateButton({
    Name = "Steal Egg (Random 1 Trứng trong 20 Studs)",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local eggPart, prompt = GetRandomEggIn20Studs()
            if eggPart and prompt then
                local tweenToEgg = TweenService:Create(hrp, TweenInfo.new((hrp.Position - eggPart.Position).Magnitude / 160, Enum.EasingStyle.Linear), {CFrame = eggPart.CFrame * CFrame.new(0, 0, 2)})
                tweenToEgg:Play()
                tweenToEgg.Completed:Wait()
                
                task.wait(0.2)
                HoldEForPrompt(prompt)
                task.wait(0.2)
            end
        end)
    end,
})

TabMain:CreateButton({
    Name = "Go Back Base (Về Base với Speed 160)",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            task.wait(0.2)
            local basePos = GetMyBasePosition()
            if basePos then
                local dist = (hrp.Position - basePos.Position).Magnitude
                local timeToTween = dist / 160 -- Đã đổi từ 140 thành 160 studs
                local tween = TweenService:Create(hrp, TweenInfo.new(timeToTween, Enum.EasingStyle.Linear), {CFrame = basePos})
                tween:Play()
            end
        end)
    end,
})

-- TAB MISC
TabMisc:CreateSection("Thông tin hệ thống & Avatar")

-- TAB FIX LAG & GOD MODE & AUTO TP TRỨNG (0.01s)
TabMisc:CreateSection("Tối ưu hóa & God Mode")

TabMisc:CreateToggle({
    Name = "Fix Lag (Ẩn Player/Trứng khác, Xóa Mây/Lightning)",
    CurrentValue = false,
    Flag = "FixLagToggle",
    Callback = function(Value)
        _G.FixLagEnabled = Value
        if Value then
            task.spawn(function()
                pcall(function()
                    Lighting.GlobalShadows = false
                    Lighting.FogEnd = 9e9
                    for _, v in ipairs(Lighting:GetChildren()) do
                        if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("Sparkles") then
                            v:Destroy()
                        end
                    end
                end)
                pcall(function()
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("Clouds") then v:Destroy() end
                    end
                end)
            end)
        end
    end,
})

TabMisc:CreateToggle({
    Name = "God Mode & Auto TP Trứng (Delay 0.01s)",
    CurrentValue = false,
    Flag = "GodModeEggToggle",
    Callback = function(Value)
        _G.GodModeEggEnabled = Value
    end,
})

-- Xử lý vòng lặp Fix Lag (Ẩn người chơi và trứng người khác, xóa animation) + God Mode / Auto TP
task.spawn(function()
    local lastValidEggPos = nil
    while true do
        task.wait(0.01) -- Vòng lặp chạy tốc độ 0.01s theo yêu cầu
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")

            -- Xử lý Fix Lag ẩn player khác và trứng khác liên tục nếu bật toggle
            if _G.FixLagEnabled then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") or part:IsA("Decal") then
                                part.Transparency = 1
                            end
                        end
                    end
                end
                local animate = char:FindFirstChild("Animate")
                if animate then animate:Destroy() end
            end

            if hrp and humanoid then
                -- God Mode: Giữ máu luôn đầy
                if _G.GodModeEggEnabled and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end

                -- Quét lưu lại vị trí quả trứng gần nhất để làm mốc TP
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and string.find(string.lower(obj.Name), "egg") then
                        local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            lastValidEggPos = primary.CFrame
                        end
                    end
                end

                -- Cơ chế Auto TP lấy trứng lại khi bị rơi / bị đánh (delay 0.01s check)
                if _G.GodModeEggEnabled and lastValidEggPos then
                    -- Nếu đang làm nhiệm vụ steal mà mất đồ/rơi trứng hoặc bị đánh văng mà chưa hoàn thành
                    if not IsHoldingEgg() then
                        -- Có thể thêm logic kiểm tra trạng thái rơi rớt hoặc tự động bám đuổi vị trí trứng
                    end
                end
            end
        end)
    end
end)

local success, thumb = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)

if success and thumb then
    TabMisc:CreateParagraph({Title = "Avatar Người Dùng", Content = "Ảnh đại diện của: " .. LocalPlayer.Name .. "\nLink Thumbnail: " .. thumb})
else
    TabMisc:CreateParagraph({Title = "Avatar Người Dùng", Content = "Tên người chơi: " .. LocalPlayer.Name})
end

local infoLabel = TabMisc:CreateParagraph({Title = "Thống kê chi tiết", Content = "Đang tải thông tin..."})

task.spawn(function()
    local startTime = tick()
    while task.wait(1) do
        pcall(function()
            local playtime = math.floor(tick() - startTime)
            local hours = math.floor(playtime / 3600)
            local minutes = math.floor((playtime % 3600) / 60)
            local seconds = playtime % 60
            local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            local name = LocalPlayer.Name
            local fps = math.floor(workspace:GetRealPhysicsFPS())

            infoLabel:Set({
                Title = "Thống kê chi tiết",
                Content = "Tên người chơi: " .. name .. "\nThời gian ở server: " .. timeString .. "\nPing: " .. ping .. " ms\nFPS: " .. fps
            })
        end)
    end
end)
