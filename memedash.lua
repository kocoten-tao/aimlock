-- Meme Dash (Dense & Massive Fire Edition - No Wings)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local config = {
    FlyHeight = 50,
    IsFarming = false,
    IsAntiAfk = true,
    HeadFire = false,
    HandsFire = false,
    CrossOrbitFire = false
}

local farmConn = nil
local orbitConn1 = nil
local orbitConn2 = nil
local freezePos = nil

-- Hàm lấy Nhân vật & Các bộ phận cơ thể chuẩn xác
local function getCharParts()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)
    local head = char:WaitForChild("Head", 5)
    local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    return char, root, hum, head, leftArm, rightArm
end

-- 1. Lửa Trên Đầu (Lửa to hơn, rực rỡ và bùng cháy mạnh)
local function updateHeadFire()
    local _, _, _, head = getCharParts()
    if not head then return end
    
    for _, v in ipairs(head:GetChildren()) do
        if v.Name == "MD_HeadFire" then v:Destroy() end
    end

    if config.HeadFire then
        local fire = Instance.new("Fire")
        fire.Name = "MD_HeadFire"
        fire.Size = 9 -- Kích thước lớn hơn
        fire.Heat = 22 -- Nhiệt độ cao giúp lửa cháy bùng mạnh
        fire.Color = Color3.fromRGB(255, 30, 0)
        fire.SecondaryColor = Color3.fromRGB(255, 150, 0)
        fire.Parent = head
    end
end

-- 2. Lửa Hai Tay (Lửa to và đậm màu hơn ở hai tay)
local function updateHandsFire()
    local _, _, _, _, leftArm, rightArm = getCharParts()
    
    if leftArm then
        for _, v in ipairs(leftArm:GetChildren()) do if v.Name == "MD_HandFire" then v:Destroy() end end
        if config.HandsFire then
            local lFire = Instance.new("Fire")
            lFire.Name = "MD_HandFire"
            lFire.Size = 7 -- Kích thước lớn hơn
            lFire.Heat = 20
            lFire.Color = Color3.fromRGB(255, 40, 0)
            lFire.SecondaryColor = Color3.fromRGB(255, 160, 0)
            lFire.Parent = leftArm
        end
    end

    if rightArm then
        for _, v in ipairs(rightArm:GetChildren()) do if v.Name == "MD_HandFire" then v:Destroy() end end
        if config.HandsFire then
            local rFire = Instance.new("Fire")
            rFire.Name = "MD_HandFire"
            rFire.Size = 7 -- Kích thước lớn hơn
            rFire.Heat = 20
            rFire.Color = Color3.fromRGB(255, 40, 0)
            rFire.SecondaryColor = Color3.fromRGB(255, 160, 0)
            rFire.Parent = rightArm
        end
    end
end

-- 3. Lửa Bay Quanh Người (Lửa to, bùng cháy rực rỡ)
local function updateCrossOrbitFire()
    if orbitConn1 then orbitConn1:Disconnect() orbitConn1 = nil end
    if orbitConn2 then orbitConn2:Disconnect() orbitConn2 = nil end
    
    local char, root = getCharParts()
    if char then
        local p1 = char:FindFirstChild("OrbitPart1")
        local p2 = char:FindFirstChild("OrbitPart2")
        if p1 then p1:Destroy() end
        if p2 then p2:Destroy() end
    end

    if not config.CrossOrbitFire or not root then return end

    local part1 = Instance.new("Part")
    part1.Name = "OrbitPart1"
    part1.Size = Vector3.new(0.2, 0.2, 0.2)
    part1.Transparency = 1
    part1.CanCollide = false
    part1.Anchored = true
    part1.Parent = char

    local f1 = Instance.new("Fire")
    f1.Size = 8 -- Lửa bay to và dày hơn
    f1.Heat = 18
    f1.Color = Color3.fromRGB(255, 90, 0)
    f1.SecondaryColor = Color3.fromRGB(255, 200, 0)
    f1.Parent = part1

    local part2 = Instance.new("Part")
    part2.Name = "OrbitPart2"
    part2.Size = Vector3.new(0.2, 0.2, 0.2)
    part2.Transparency = 1
    part2.CanCollide = false
    part2.Anchored = true
    part2.Parent = char

    local f2 = Instance.new("Fire")
    f2.Size = 8 -- Lửa bay to và dày hơn
    f2.Heat = 18
    f2.Color = Color3.fromRGB(0, 140, 255)
    f2.SecondaryColor = Color3.fromRGB(0, 240, 255)
    f2.Parent = part2

    local angle1 = 0
    local angle2 = math.pi

    orbitConn1 = RunService.RenderStepped:Connect(function(dt)
        if not root or not root.Parent then return end
        angle1 = angle1 + (dt * 5)
        angle2 = angle2 + (dt * 5)
        
        local radius = 3.5
        local pos = root.Position
        
        local x1 = math.cos(angle1) * radius
        local z1 = math.sin(angle1) * radius
        local y1 = math.sin(angle1 * 2) * 2
        part1.CFrame = CFrame.new(pos + Vector3.new(x1, y1, z1))

        local x2 = math.cos(angle2) * radius
        local z2 = math.sin(angle2) * radius
        local y2 = math.sin(angle2 * 2 + math.pi) * 2
        part2.CFrame = CFrame.new(pos + Vector3.new(x2, y2, z2))
    end)
end

-- Cập nhật toàn bộ hiệu ứng
local function refreshAllEffects()
    updateHeadFire()
    updateHandsFire()
    updateCrossOrbitFire()
end

-- Logic Treo Trời
local function startFarmSky()
    local _, root, hum = getCharParts()
    if not root or not hum then return end
    
    local currentCF = root.CFrame
    freezePos = CFrame.new(currentCF.Position.X, currentCF.Position.Y + config.FlyHeight, currentCF.Position.Z) * (currentCF - currentCF.Position)
    root.CFrame = freezePos

    if farmConn then farmConn:Disconnect() end

    farmConn = RunService.RenderStepped:Connect(function()
        local _, r, h = getCharParts()
        if not r or not h or h.Health <= 0 then return end
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        r.CFrame = freezePos
    end)
    
    refreshAllEffects()
end

local function stopFarmSky()
    if farmConn then farmConn:Disconnect() farmConn = nil end
end

-- Respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    if config.IsFarming then 
        startFarmSky() 
    else
        refreshAllEffects()
    end
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if config.IsAntiAfk then
        VirtualUser:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end
end)

-- ==================== GIAO DIỆN RAYFIELD UI ====================
local Window = Rayfield:CreateWindow({
    Name = "Meme Dash",
    LoadingTitle = "Đang khởi tạo Meme Dash...",
    LoadingSubtitle = "Massive Fire Edition",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

FarmTab:CreateToggle({
    Name = "Bật/Tắt Auto Farm (Treo Trên Trời)",
    CurrentValue = false,
    Flag = "FarmSkyToggle",
    Callback = function(Value)
        config.IsFarming = Value
        if Value then startFarmSky() else stopFarmSky() end
    end,
})

FarmTab:CreateToggle({
    Name = "Bật/Tắt Lửa Trên Đầu",
    CurrentValue = false,
    Flag = "HeadFireToggle",
    Callback = function(Value)
        config.HeadFire = Value
        updateHeadFire()
    end,
})

FarmTab:CreateToggle({
    Name = "Bật/Tắt Lửa Hai Tay",
    CurrentValue = false,
    Flag = "HandsFireToggle",
    Callback = function(Value)
        config.HandsFire = Value
        updateHandsFire()
    end,
})

FarmTab:CreateToggle({
    Name = "Bật/Tắt Lửa Bay Quanh Người",
    CurrentValue = false,
    Flag = "CrossOrbitToggle",
    Callback = function(Value)
        config.CrossOrbitFire = Value
        updateCrossOrbitFire()
    end,
})

FarmTab:CreateToggle({
    Name = "Bật/Tắt Chống AFK",
    CurrentValue = true,
    Flag = "AntiAfkToggle",
    Callback = function(Value) config.IsAntiAfk = Value end,
})

FarmTab:CreateInput({
    Name = "Chiều cao treo trên trời",
    PlaceholderText = "Mặc định: 50",
    NumbersOnly = true,
    OnEnter = true,
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local num = tonumber(Text)
        if num then 
            config.FlyHeight = num
            if config.IsFarming then startFarmSky() end
        end
    end,
})

Rayfield:LoadConfiguration()
