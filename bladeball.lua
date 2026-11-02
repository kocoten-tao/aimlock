-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Balls = Workspace:WaitForChild("Balls")

-- Settings Variable
local Settings = {
    AutoParry = false,
    AutoSpam = false,
    PingOffset = 0.05,
    SpamDistance = 12,
    WalkSpeed = 16,
    JumpPower = 50,
    BallHighlight = false
}

-- Trigger Parry Action
local function triggerParry()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.005)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Get Active Ball
local function getActiveBall()
    for _, ball in pairs(Balls:GetChildren()) do
        if ball:GetAttribute("realBall") == true or ball:FindFirstChild("zoomies") then
            return ball
        end
    end
    return Balls:FindFirstChildOfClass("Part")
end

-- Highlight Ball Effect
local highlight = Instance.new("Highlight")
highlight.Name = "BladeBallESP"
highlight.FillColor = Color3.fromRGB(255, 0, 50)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.4

----------------------------------------------------------------
-- GUI UI CREATION (Mobile-Friendly & Draggable)
----------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BladeBallHub"
ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(28, 34, 46)
Title.Text = "  BLADE BALL AUTO HUB"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -55)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.CanvasSize = UDim2.new(0, 0, 0, 450)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Helper: Create Toggle Button
local function createToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(35, 42, 55)
    btn.Text = name .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(35, 42, 55)
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Helper: Create Slider Button (Simple Adjuster)
local function createSlider(name, val, min, max, step, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(35, 42, 55)
    frame.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. name .. ": " .. tostring(val)
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 30, 0, 30)
    minus.Position = UDim2.new(0.65, 0, 0.15, 0)
    minus.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.Parent = frame

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 30, 0, 30)
    plus.Position = UDim2.new(0.82, 0, 0.15, 0)
    plus.BackgroundColor3 = Color3.fromRGB(50, 60, 75)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.Parent = frame

    local current = val
    minus.MouseButton1Click:Connect(function()
        if current - step >= min then
            current = current - step
            lbl.Text = "  " .. name .. ": " .. tostring(math.floor(current * 100) / 100)
            callback(current)
        end
    end)

    plus.MouseButton1Click:Connect(function()
        if current + step <= max then
            current = current + step
            lbl.Text = "  " .. name .. ": " .. tostring(math.floor(current * 100) / 100)
            callback(current)
        end
    end)
end

-- Add Menu Elements
createToggle("Auto Parry (TTI)", Settings.AutoParry, function(v) Settings.AutoParry = v end)
createToggle("Auto Spam (Close Range)", Settings.AutoSpam, function(v) Settings.AutoSpam = v end)
createToggle("Ball ESP Highlight", Settings.BallHighlight, function(v) 
    Settings.BallHighlight = v 
    if not v then highlight.Parent = nil end
end)
createSlider("Ping Offset", Settings.PingOffset, 0.01, 0.3, 0.01, function(v) Settings.PingOffset = v end)
createSlider("Spam Distance", Settings.SpamDistance, 5, 25, 1, function(v) Settings.SpamDistance = v end)
createSlider("Speed Multiplier", Settings.WalkSpeed, 16, 100, 4, function(v) 
    Settings.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

----------------------------------------------------------------
-- MAIN SCRIPT LOGIC
----------------------------------------------------------------
RunService.PreRender:Connect(function()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Character Speed Fix
    if character:FindFirstChild("Humanoid") and character.Humanoid.WalkSpeed ~= Settings.WalkSpeed then
        character.Humanoid.WalkSpeed = Settings.WalkSpeed
    end

    local hrp = character.HumanoidRootPart
    local ball = getActiveBall()

    if ball then
        -- ESP Highlight Manager
        if Settings.BallHighlight then
            highlight.Parent = ball
        end

        if ball:FindFirstChild("AssemblyLinearVelocity") then
            local ballPos = ball.Position
            local playerPos = hrp.Position
            local distance = (ballPos - playerPos).Magnitude
            local speed = ball.AssemblyLinearVelocity.Magnitude

            local ballVelocity = ball.AssemblyLinearVelocity
            local ballToPlayer = (playerPos - ballPos).Unit
            local dotProduct = ballVelocity.Unit:Dot(ballToPlayer)

            -- 1. Auto Spam Mode (Khi bóng quá gần)
            if Settings.AutoSpam and distance <= Settings.SpamDistance then
                triggerParry()
                return
            end

            -- 2. Auto Parry TTI Mode
            if Settings.AutoParry and dotProduct > 0.25 and speed > 0 then
                local timeToImpact = distance / speed
                local threshold = 0.35 + Settings.PingOffset

                if timeToImpact <= threshold then
                    triggerParry()
                end
            end
        end
    end
end)
