-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Cài đặt
local Settings = {
    AimlockEnabled = false,
    AutoShootEnabled = false,
    TeamCheck = true,
    FOVSize = 280,
    Smoothness = 0.35,
    Minimized = false
}

-- Biến quản lý mục tiêu
local currentTarget = nil

-- Tạo GUI Menu phong cách Cyberpunk / Modern Dark UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraSmoothHeadAimlock"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Khung Menu chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 210, 0, 205)
MainFrame.Position = UDim2.new(0.5, -105, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Bo góc mượt mà
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Viền phát sáng sang trọng
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(75, 75, 110)
MainStroke.Thickness = 1.8
MainStroke.Parent = MainFrame

-- Thanh tiêu đề (Header)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local FixCover = Instance.new("Frame")
FixCover.Size = UDim2.new(1, 0, 0, 8)
FixCover.Position = UDim2.new(0, 0, 1, -8)
FixCover.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
FixCover.BorderSizePixel = 0
FixCover.Parent = TitleBar

-- Tiêu đề Text
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ ông Sinh [FOV: 280]"
Title.TextColor3 = Color3.fromRGB(230, 235, 255)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Nút Thu Gọn (-) / Mở Rộng (+)
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -28, 0, 4)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 14
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

-- Container chứa các nút chức năng
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, 0, 1, -32)
ContentContainer.Position = UDim2.new(0, 0, 0, 32)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- Hàm tạo nút bấm
local function fnCreateButton(posY, defaultText, defaultColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = defaultColor
    btn.Text = defaultText
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ContentContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = btn

    return btn
end

-- Khởi tạo các nút chức năng
local ToggleButton = fnCreateButton(8, "Aimlock: OFF", Color3.fromRGB(170, 40, 40))
local AutoShootButton = fnCreateButton(46, "Auto Shoot: OFF", Color3.fromRGB(170, 40, 40))
local TeamCheckButton = fnCreateButton(84, "Team Check: ON", Color3.fromRGB(40, 150, 40))

-- Nút chỉnh FOV (-) và (+)
local FovMinus = Instance.new("TextButton")
FovMinus.Size = UDim2.new(0.43, 0, 0, 30)
FovMinus.Position = UDim2.new(0.05, 0, 0, 123)
FovMinus.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
FovMinus.Text = "FOV -"
FovMinus.TextColor3 = Color3.fromRGB(220, 220, 230)
FovMinus.TextSize = 11
FovMinus.Font = Enum.Font.GothamMedium
FovMinus.Parent = ContentContainer
Instance.new("UICorner", FovMinus).CornerRadius = UDim.new(0, 6)
local StrokeM = Instance.new("UIStroke", FovMinus) StrokeM.Color = Color3.fromRGB(255,255,255) StrokeM.Transparency = 0.8 StrokeM.Thickness = 1

local FovPlus = Instance.new("TextButton")
FovPlus.Size = UDim2.new(0.43, 0, 0, 30)
FovPlus.Position = UDim2.new(0.52, 0, 0, 123)
FovPlus.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
FovPlus.Text = "FOV +"
FovPlus.TextColor3 = Color3.fromRGB(220, 220, 230)
FovPlus.TextSize = 11
FovPlus.Font = Enum.Font.GothamMedium
FovPlus.Parent = ContentContainer
Instance.new("UICorner", FovPlus).CornerRadius = UDim.new(0, 6)
local StrokeP = Instance.new("UIStroke", FovPlus) StrokeP.Color = Color3.fromRGB(255,255,255) StrokeP.Transparency = 0.8 StrokeP.Thickness = 1

-- Vòng tròn FOV (Viền dày = 3, cầu vồng)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Transparency = 0.8
FOVCircle.Thickness = 3
FOVCircle.Filled = false
FOVCircle.Radius = Settings.FOVSize

-- Xử lý nút thu gọn / mở rộng (-)
MinimizeButton.MouseButton1Click:Connect(function()
    Settings.Minimized = not Settings.Minimized
    if Settings.Minimized then
        MainFrame.Size = UDim2.new(0, 210, 0, 32)
        MinimizeButton.Text = "+"
        ContentContainer.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 210, 0, 205)
        MinimizeButton.Text = "-"
        ContentContainer.Visible = true
    end
end)

-- Xử lý bật/tắt Aimlock
ToggleButton.MouseButton1Click:Connect(function()
    Settings.AimlockEnabled = not Settings.AimlockEnabled
    if Settings.AimlockEnabled then
        ToggleButton.Text = "Aimlock: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
    else
        ToggleButton.Text = "Aimlock: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
        currentTarget = nil
    end
end)

-- Xử lý bật/tắt Auto Shoot
AutoShootButton.MouseButton1Click:Connect(function()
    Settings.AutoShootEnabled = not Settings.AutoShootEnabled
    if Settings.AutoShootEnabled then
        AutoShootButton.Text = "Auto Shoot: ON"
        AutoShootButton.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
    else
        AutoShootButton.Text = "Auto Shoot: OFF"
        AutoShootButton.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    end
end)

-- Xử lý bật/tắt Team Check
TeamCheckButton.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    if Settings.TeamCheck then
        TeamCheckButton.Text = "Team Check: ON"
        TeamCheckButton.BackgroundColor3 = Color3.fromRGB(40, 160, 40)
    else
        TeamCheckButton.Text = "Team Check: OFF"
        TeamCheckButton.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
    end
end)

-- Xử lý tăng giảm FOV
FovPlus.MouseButton1Click:Connect(function()
    Settings.FOVSize = math.clamp(Settings.FOVSize + 30, 50, 600)
    FOVCircle.Radius = Settings.FOVSize
    Title.Text = "⚡ ông Sinh [FOV: " .. Settings.FOVSize .. "]"
end)

FovMinus.MouseButton1Click:Connect(function()
    Settings.FOVSize = math.clamp(Settings.FOVSize - 30, 50, 600)
    FOVCircle.Radius = Settings.FOVSize
    Title.Text = "⚡ ông Sinh [FOV: " .. Settings.FOVSize .. "]"
end)

-- Hàm kiểm tra tường (WallCheck)
local function IsVisible(targetPart)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character, Camera}
    raycastParams.IgnoreWater = true
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    
    return true
end

-- Hàm kiểm tra mục tiêu còn sống
local function IsTargetValid(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local head = player.Character:FindFirstChild("Head")
    
    if not humanoid or humanoid.Health <= 0 or not head then return false end
    
    if Settings.TeamCheck and player.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
        return false
    end
    
    if not IsVisible(head) then return false end
    
    return true
end

-- Hàm tìm mục tiêu mới trong FOV
local function GetClosestPlayerInFOV()
    local closestPlayer = nil
    local shortestDistance = Settings.FOVSize
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local canTarget = true
                if Settings.TeamCheck and player.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
                    canTarget = false
                end

                if canTarget then
                    local head = player.Character.Head
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)

                    if onScreen then
                        local vector2D = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distance = (vector2D - mousePos).Magnitude

                        if distance < shortestDistance then
                            if IsVisible(head) then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Vòng lặp cập nhật chống khựng bằng Slerp CFrame
RunService.RenderStepped:Connect(function()
    local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = mousePos

    -- Hiệu ứng cầu vồng cho viền FOV
    FOVCircle.Color = Color3.fromHSV((os.clock() % 5) / 5, 1, 1)

    if Settings.AimlockEnabled then
        if not IsTargetValid(currentTarget) then
            currentTarget = GetClosestPlayerInFOV()
        end

        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
            local head = currentTarget.Character.Head
            
            -- Tính toán hướng nhìn thẳng vào đầu mục tiêu một cách cực kỳ mượt mà không bị khựng lắc
            local camPos = Camera.CFrame.Position
            local targetRotation = CFrame.new(camPos, head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetRotation, Settings.Smoothness)

            -- Auto Shoot siêu tốc
            if Settings.AutoShootEnabled then
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end)
            end
        end
    else
        currentTarget = nil
    end
end)
