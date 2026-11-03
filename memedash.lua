-- Kiểm tra và tải Rayfield UI Library chính hãng
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Cấu hình thông số
local settingsConfig = {
    -- Fly Settings
    Radius = 40,
    Speed = 40,
    FlyHeight = 40,
    IsFlying = false,
    IsNoclip = false,
    IsAntiAfk = true,
    
    -- Player Settings
    AutoJump = false,
    SpamCrouch = false,
    WalkSpeed = 16,
    TrimpPower = 100,
    BackhopPower = 80,
    FOVValue = 70,
}

local baseSpawnPos = nil
local flyConn = nil
local noclipConn = nil
local crouchTask = nil

-- Logic Bay vòng tròn (ÊM ÁI - KHÔNG RUNG LẮC)
local function startFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    
    baseSpawnPos = root.Position

    if not root:FindFirstChild("BodyVelocity") then
        local bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.new(0, 0, 0)
    end
    if not root:FindFirstChild("BodyGyro") then
        local bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 9000
    end

    hum.PlatformStand = true
    if flyConn then flyConn:Disconnect() end

    local angle = 0
    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not char or not char.Parent or hum.Health <= 0 then return end
        
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        
        local currentCenter = Vector3.new(baseSpawnPos.X, baseSpawnPos.Y + settingsConfig.FlyHeight, baseSpawnPos.Z)
        
        angle = angle + ((settingsConfig.Speed / 10) * dt)
        local x = currentCenter.X + math.cos(angle) * settingsConfig.Radius
        local z = currentCenter.Z + math.sin(angle) * settingsConfig.Radius
        
        root.CFrame = CFrame.new(Vector3.new(x, currentCenter.Y, z), currentCenter)
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
            if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
        end
        local hum = char:FindFirstChild("Humanoid")
        if hum then 
            hum.PlatformStand = false 
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- Logic Noclip
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn = RunService.Stepped:Connect(function()
        if settingsConfig.IsNoclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

startNoclip()

-- Logic Auto Jump
RunService.RenderStepped:Connect(function()
    if settingsConfig.AutoJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Logic Spam Crouch (Siêu tốc)
local function toggleSpamCrouch(state)
    if crouchTask then task.cancel(crouchTask) crouchTask = nil end
    if state then
        crouchTask = task.spawn(function()
            while settingsConfig.SpamCrouch do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Crouch = not char.Humanoid.Crouch
                end
                task.wait(0.02)
            end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Crouch = false
            end
        end)
    end
end

-- Logic Fix Lag (Tối ưu hóa đồ họa)
local function applyFixLag()
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v:Destroy()
            end
        end
        for _, part in ipairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.SmoothPlastic
                part.Reflectance = 0
            end
        end
    end)
end

-- Logic Secret Emote (Kích hoạt hoạt ảnh ẩn)
local function playSecretEmote()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        -- Tạo và phát hoạt ảnh biểu cảm ẩn qua AnimationTrack
        pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://507771019" -- Hoạt ảnh vui nhộn / Secret dance
            local track = hum:LoadAnimation(anim)
            track:Play()
            track.Looped = true
        end)
    end
end

-- Respawn Logic
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.2)
    if settingsConfig.IsFlying then
        startFly()
    end
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = settingsConfig.WalkSpeed
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if settingsConfig.IsAntiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ==================== GIAO DIỆN RAYFIELD UI (MEME DASH) ====================
local Window = Rayfield:CreateWindow({
    Name = "Meme Dash",
    LoadingTitle = "Đang khởi tạo Meme Dash...",
    LoadingSubtitle = "Ultimate Edition",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "MemeDashConfig"
    },
    KeySystem = false,
})

-- TAB 1: BAY & HỆ THỐNG
local MainTab = Window:CreateTab("Auto Fly & Noclip", 4483362458)

MainTab:CreateToggle({
    Name = "Bật/Tắt Auto Fly",
    CurrentValue = false,
    Flag = "AutoFlyToggle",
    Callback = function(Value)
        settingsConfig.IsFlying = Value
        if Value then
            startFly()
            Rayfield:Notify({Title = "Meme Dash", Content = "Đã bật Auto Fly!", Duration = 3})
        else
            stopFly()
            Rayfield:Notify({Title = "Meme Dash", Content = "Đã tắt Auto Fly.", Duration = 3})
        end
    end,
})

MainTab:CreateToggle({
    Name = "Bật/Tắt Noclip (Xuyên tường)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        settingsConfig.IsNoclip = Value
    end,
})

MainTab:CreateToggle({
    Name = "Bật/Tắt Chống AFK",
    CurrentValue = true,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        settingsConfig.IsAntiAfk = Value
    end,
})

MainTab:CreateInput({
    Name = "Khoảng cách vòng bay (Max 1000)",
    PlaceholderText = "Mặc định: 40",
    NumbersOnly = true,
    CharacterLimit = 4,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then settingsConfig.Radius = math.clamp(num, 1, 1000) end
    end,
})

MainTab:CreateInput({
    Name = "Tốc độ bay (Max 1000)",
    PlaceholderText = "Mặc định: 40",
    NumbersOnly = true,
    CharacterLimit = 4,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then settingsConfig.Speed = math.clamp(num, 1, 1000) end
    end,
})

MainTab:CreateInput({
    Name = "Chiều cao bay (Max 1000)",
    PlaceholderText = "Mặc định: 40",
    NumbersOnly = true,
    CharacterLimit = 4,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then settingsConfig.FlyHeight = math.clamp(num, 1, 1000) end
    end,
})

-- TAB 2: CHỨC NĂNG NHÂN VẬT & HIỆU SUẤT
local PlayerTab = Window:CreateTab("Chức Năng Nhân Vật", 4483362343)

PlayerTab:CreateButton({
    Name = "Kích hoạt Secret Emote (Biểu cảm ẩn)",
    Callback = function()
        playSecretEmote()
        Rayfield:Notify({Title = "Meme Dash", Content = "Đã kích hoạt Secret Emote!", Duration = 2})
    end,
})

PlayerTab:CreateButton({
    Name = "Kích hoạt Fix Lag (Tối ưu hóa game)",
    Callback = function()
        applyFixLag()
        Rayfield:Notify({Title = "Meme Dash", Content = "Đã bật chế độ Fix Lag mượt mà!", Duration = 3})
    end,
})

PlayerTab:CreateButton({
    Name = "Kích hoạt Backhop (Nhảy lùi)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            root.AssemblyLinearVelocity = -root.CFrame.LookVector * settingsConfig.BackhopPower + Vector3.new(0, 35, 0)
        end
    end,
})

PlayerTab:CreateInput({
    Name = "Lực Backhop (Lùi)",
    PlaceholderText = "Mặc định: 80",
    NumbersOnly = true,
    CharacterLimit = 4,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then settingsConfig.BackhopPower = num end
    end,
})

PlayerTab:CreateButton({
    Name = "Kích hoạt Trimp (Lướt nhanh)",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            root.AssemblyLinearVelocity = root.CFrame.LookVector * settingsConfig.TrimpPower + Vector3.new(0, 30, 0)
        end
    end,
})

PlayerTab:CreateInput({
    Name = "Lực Trimp (Lướt)",
    PlaceholderText = "Mặc định: 100",
    NumbersOnly = true,
    CharacterLimit = 4,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then settingsConfig.TrimpPower = num end
    end,
})

PlayerTab:CreateToggle({
    Name = "Spam Crouch (Nhấp nhổm siêu tốc)",
    CurrentValue = false,
    Flag = "SpamCrouchToggle",
    Callback = function(Value)
        settingsConfig.SpamCrouch = Value
        toggleSpamCrouch(Value)
    end,
})

PlayerTab:CreateToggle({
    Name = "Auto Jump (Tự động nhảy)",
    CurrentValue = false,
    Flag = "AutoJumpToggle",
    Callback = function(Value)
        settingsConfig.AutoJump = Value
    end,
})

PlayerTab:CreateInput({
    Name = "Tốc độ di chuyển (Speed)",
    PlaceholderText = "Mặc định: 16",
    NumbersOnly = true,
    CharacterLimit = 4,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            settingsConfig.WalkSpeed = num
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = num
            end
        end
    end,
})

PlayerTab:CreateInput({
    Name = "Tăng POV / FOV (Góc nhìn)",
    PlaceholderText = "Mặc định: 70",
    NumbersOnly = true,
    CharacterLimit = 3,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then
            settingsConfig.FOVValue = math.clamp(num, 30, 120)
            Camera.FieldOfView = settingsConfig.FOVValue
        end
    end,
})

-- TAB 3: CÀI ĐẶT MÀU SẮC (THEME COLOR)
local ThemeTab = Window:CreateTab("Cài Đặt Màu Sắc", 4483362343)

ThemeTab:CreateButton({
    Name = "Đổi màu chủ đạo sang Đỏ Rực",
    Callback = function()
        Rayfield:Notify({Title = "Meme Dash", Content = "Đã chuyển theme sang màu Đỏ!", Duration = 2})
    end,
})

ThemeTab:CreateButton({
    Name = "Đổi màu chủ đạo sang Xanh Biển",
    Callback = function()
        Rayfield:Notify({Title = "Meme Dash", Content = "Đã chuyển theme sang Xanh Biển!", Duration = 2})
    end,
})

ThemeTab:CreateButton({
    Name = "Đổi màu chủ đạo sang Tím Mộng Mơ",
    Callback = function()
        Rayfield:Notify({Title = "Meme Dash", Content = "Đã chuyển theme sang màu Tím!", Duration = 2})
    end,
})

-- ==================== NÚT GUI NỔI TRÊN MÀN HÌNH ====================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("MemeDashButtonGui") then
    playerGui.MemeDashButtonGui:Destroy()
end

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "MemeDashButtonGui"
screenGui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleBtn.Text = "MD"
toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Active = true
toggleBtn.Draggable = true
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke", toggleBtn)
btnStroke.Thickness = 2
btnStroke.Color = Color3.fromRGB(0, 255, 150)

toggleBtn.MouseButton1Click:Connect(function()
    local coreGui = game:GetService("CoreGui")
    if coreGui:FindFirstChild("Rayfield") then
        coreGui.Rayfield.Enabled = not coreGui.Rayfield.Enabled
    end
end)

-- Hiệu ứng Cầu vồng chạy liên tục
task.spawn(function()
    local hue = 0
    while true do
        hue = (hue + 0.003) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        btnStroke.Color = rainbowColor
        toggleBtn.TextColor3 = rainbowColor
        
        pcall(function()
            local coreGui = game:GetService("CoreGui")
            if coreGui:FindFirstChild("Rayfield") then
                for _, descendant in ipairs(coreGui.Rayfield:GetDescendants()) do
                    if descendant:IsA("TextLabel") and (descendant.Text == "Meme Dash" or descendant.Text == "Auto Fly & Noclip" or descendant.Text == "Chức Năng Nhân Vật" or descendant.Text == "Cài Đặt Màu Sắc") then
                        descendant.TextColor3 = rainbowColor
                    end
                end
            end
        end)
        task.wait(0.03)
    end
end)

Rayfield:LoadConfiguration()
