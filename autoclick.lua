-- [[ Ultimate Mobile Auto Clicker - Sửa lỗi liệt nút Bật/Tắt ]]
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local isRunning = false
local isVisible = true
local isAlive = true
local clicksPerSecond = 50
local interval = 1 / clicksPerSecond

local targetMarkers = {}

-- Xóa UI cũ nếu có
if CoreGui:FindFirstChild("UltimateAutoClickerGui") then
    CoreGui.UltimateAutoClickerGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltimateAutoClickerGui"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Hàm tạo điểm hồng tâm mới
local function createTargetMarker()
    local index = #targetMarkers + 1
    
    local targetMarker = Instance.new("Frame")
    targetMarker.Name = "Target_" .. index
    targetMarker.Parent = screenGui
    targetMarker.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    targetMarker.BackgroundTransparency = 0.35
    targetMarker.Position = UDim2.new(0.4 + (index * 0.05), -15, 0.45, -15)
    targetMarker.Size = UDim2.new(0, 30, 0, 30)
    targetMarker.Active = true
    targetMarker.Draggable = true

    Instance.new("UICorner", targetMarker).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", targetMarker)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5

    local label = Instance.new("TextLabel", targetMarker)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(index)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13

    table.insert(targetMarkers, targetMarker)
end

-- Hàm xóa điểm hồng tâm
local function removeTargetMarker()
    if #targetMarkers > 1 then
        local lastMarker = table.remove(targetMarkers)
        lastMarker:Destroy()
    end
end

-- Tạo sẵn 1 điểm đầu tiên
createTargetMarker()

-- MENU CHÍNH HÌNH VUÔNG
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.Position = UDim2.new(0.5, -80, 0.15, 0)
mainFrame.Size = UDim2.new(0, 160, 0, 175)
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local uiStroke = Instance.new("UIStroke", mainFrame)
uiStroke.Color = Color3.fromRGB(70, 70, 100)
uiStroke.Thickness = 1.5

-- Tiêu đề
local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 0, 0, 6)
titleLabel.Size = UDim2.new(1, 0, 0, 20)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚡ AUTO CLICK"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
titleLabel.TextSize = 11

-- Nút Bật/Tắt Auto Click (Hàng 1)
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
toggleBtn.Position = UDim2.new(0, 10, 0, 30)
toggleBtn.Size = UDim2.new(0, 140, 0, 26)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Text = "TRẠNG THÁI: TẮT"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 11
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Nhóm Tốc độ [-] [CPS] [+] (Hàng 2)
local minusBtn = Instance.new("TextButton", mainFrame)
minusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
minusBtn.Position = UDim2.new(0, 10, 0, 61)
minusBtn.Size = UDim2.new(0, 32, 0, 26)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.TextSize = 14
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 6)

local speedLabel = Instance.new("TextLabel", mainFrame)
speedLabel.BackgroundTransparency = 1
speedLabel.Position = UDim2.new(0, 45, 0, 61)
speedLabel.Size = UDim2.new(0, 70, 0, 26)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = "50 CPS"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 11

local plusBtn = Instance.new("TextButton", mainFrame)
plusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
plusBtn.Position = UDim2.new(0, 118, 0, 61)
plusBtn.Size = UDim2.new(0, 32, 0, 26)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.TextSize = 14
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 6)

-- Nút Thêm/Xóa Điểm (Hàng 3)
local addTargetBtn = Instance.new("TextButton", mainFrame)
addTargetBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 220)
addTargetBtn.Position = UDim2.new(0, 10, 0, 92)
addTargetBtn.Size = UDim2.new(0, 67, 0, 24)
addTargetBtn.Font = Enum.Font.GothamBold
addTargetBtn.Text = "+ Điểm"
addTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addTargetBtn.TextSize = 10
Instance.new("UICorner", addTargetBtn).CornerRadius = UDim.new(0, 6)

local delTargetBtn = Instance.new("TextButton", mainFrame)
delTargetBtn.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
delTargetBtn.Position = UDim2.new(0, 83, 0, 92)
delTargetBtn.Size = UDim2.new(0, 67, 0, 24)
delTargetBtn.Font = Enum.Font.GothamBold
delTargetBtn.Text = "- Điểm"
delTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
delTargetBtn.TextSize = 10
Instance.new("UICorner", delTargetBtn).CornerRadius = UDim.new(0, 6)

-- Nút Ẩn/Hiện Menu (Hàng 4)
local hideBtn = Instance.new("TextButton", mainFrame)
hideBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 110)
hideBtn.Position = UDim2.new(0, 10, 0, 120)
hideBtn.Size = UDim2.new(0, 140, 0, 22)
hideBtn.Font = Enum.Font.GothamBold
hideBtn.Text = "👁️ Ẩn Menu"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.TextSize = 10
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 6)

-- Nút Thoát script (Hàng 5)
local exitBtn = Instance.new("TextButton", mainFrame)
exitBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
exitBtn.Position = UDim2.new(0, 10, 0, 146)
exitBtn.Size = UDim2.new(0, 140, 0, 22)
exitBtn.Font = Enum.Font.GothamBold
exitBtn.Text = "❌ Thoát Script"
exitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
exitBtn.TextSize = 10
Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0, 6)

-- Nút tròn nhỏ gọi lại menu khi ẩn
local restoreBtn = Instance.new("TextButton", screenGui)
restoreBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
restoreBtn.Position = UDim2.new(0, 10, 0, 10)
restoreBtn.Size = UDim2.new(0, 40, 0, 40)
restoreBtn.Font = Enum.Font.GothamBold
restoreBtn.Text = "⚡"
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.TextSize = 18
restoreBtn.Visible = False
Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)
local restoreStroke = Instance.new("UIStroke", restoreBtn)
restoreStroke.Color = Color3.fromRGB(100, 100, 150)
restoreStroke.Thickness = 1.5

-- SỬ DỤNG SỰ KIỆN .Activated (Tương thích tốt nhất trên mobile & mọi executor)
plusBtn.Activated:Connect(function()
    if clicksPerSecond < 100 then
        clicksPerSecond = clicksPerSecond + 5
        interval = 1 / clicksPerSecond
        speedLabel.Text = clicksPerSecond .. " CPS"
    end
end)

minusBtn.Activated:Connect(function()
    if clicksPerSecond > 5 then
        clicksPerSecond = clicksPerSecond - 5
        interval = 1 / clicksPerSecond
        speedLabel.Text = clicksPerSecond .. " CPS"
    end
end)

toggleBtn.Activated:Connect(function()
    isRunning = not isRunning
    if isRunning then
        toggleBtn.Text = "ĐANG BẬT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    else
        toggleBtn.Text = "TRẠNG THÁI: TẮT"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
end)

addTargetBtn.Activated:Connect(function()
    createTargetMarker()
end)

delTargetBtn.Activated:Connect(function()
    removeTargetMarker()
end)

local function toggleVisibility()
    isVisible = not isVisible
    mainFrame.Visible = isVisible
    for _, marker in ipairs(targetMarkers) do
        if marker and marker.Parent then
            marker.Visible = isVisible
        end
    end
    restoreBtn.Visible = not isVisible
end

hideBtn.Activated:Connect(toggleVisibility)
restoreBtn.Activated:Connect(toggleVisibility)

exitBtn.Activated:Connect(function()
    isAlive = false
    screenGui:Destroy()
end)

-- VÒNG LẶP CLICK NGẦM MƯỢT MÀ
local currentTargetIdx = 1

task.spawn(function()
    local lastTick = os.clock()
    while isAlive do
        if isRunning and #targetMarkers > 0 then
            local now = os.clock()
            if now - lastTick >= interval then
                lastTick = now

                local marker = targetMarkers[currentTargetIdx]
                if marker and marker.Parent and marker.Visible then
                    local absPos = marker.AbsolutePosition
                    local absSize = marker.AbsoluteSize
                    local clickX = absPos.X + (absSize.X / 2)
                    local clickY = absPos.Y + (absSize.Y / 2)

                    task.spawn(function()
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                        end)
                    end)
                end

                currentTargetIdx = (currentTargetIdx % #targetMarkers) + 1
            end
        end
        task.wait()
    end
end)
