-- YORIHO HUB (compact)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

if lp.PlayerGui:FindFirstChild("YorihoHub") then lp.PlayerGui.YorihoHub:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "YorihoHub"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 220, 0, 200)
f.Position = UDim2.new(0.5, -110, 0.3, 0)
f.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
f.BorderSizePixel = 0
f.Active = true
f.Draggable = true
f.Parent = gui
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, -50, 0, 35)
t.Position = UDim2.new(0, 12, 0, 0)
t.BackgroundTransparency = 1
t.Text = "YORIHO HUB"
t.TextColor3 = Color3.fromRGB(200, 150, 255)
t.Font = Enum.Font.GothamBold
t.TextSize = 15
t.TextXAlignment = Enum.TextXAlignment.Left
t.Parent = f

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 24, 0, 24)
x.Position = UDim2.new(1, -30, 0, 6)
x.BackgroundColor3 = Color3.fromRGB(180, 50, 80)
x.Text = "X"
x.TextColor3 = Color3.fromRGB(255, 255, 255)
x.Font = Enum.Font.GothamBold
x.TextSize = 12
x.Parent = f
Instance.new("UICorner", x).CornerRadius = UDim.new(0, 6)
x.MouseButton1Click:Connect(function() gui:Destroy() end)

local function btn(text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 32)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(45, 42, 55)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(230, 230, 240)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

-- NOCLIP
local noclip = false
local ncBtn = btn("Noclip: OFF", 45)
ncBtn.MouseButton1Click:Connect(function()
    noclip = not noclip
    ncBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
    ncBtn.BackgroundColor3 = noclip and Color3.fromRGB(50, 100, 60) or Color3.fromRGB(45, 42, 55)
end)
RunService.Stepped:Connect(function()
    if noclip and lp.Character then
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- FLY
local fly = false
local bv
local flyBtn = btn("Fly: OFF", 85)
flyBtn.MouseButton1Click:Connect(function()
    fly = not fly
    flyBtn.Text = "Fly: " .. (fly and "ON" or "OFF")
    flyBtn.BackgroundColor3 = fly and Color3.fromRGB(50, 100, 60) or Color3.fromRGB(45, 42, 55)
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if fly and root then
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end
    else
        if bv then bv:Destroy() bv = nil end
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

RunService.Heartbeat:Connect(function()
    if fly and bv and bv.Parent then
        local cam = workspace.CurrentCamera
        local move = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        bv.Velocity = move.Magnitude > 0 and move.Unit * 80 or Vector3.new(0, 0, 0)
    end
end)

-- SPEED
local sp = 16
local spBtn = btn("Speed: 16", 125)
local spUp = Instance.new("TextButton")
spUp.Size = UDim2.new(0, 30, 0, 32)
spUp.Position = UDim2.new(1, -75, 0, 125)
spUp.BackgroundColor3 = Color3.fromRGB(45, 42, 55)
spUp.Text = "+"
spUp.TextColor3 = Color3.fromRGB(230, 230, 240)
spUp.Font = Enum.Font.GothamBold
spUp.TextSize = 16
spUp.Parent = f
Instance.new("UICorner", spUp).CornerRadius = UDim.new(0, 8)

local spDown = Instance.new("TextButton")
spDown.Size = UDim2.new(0, 30, 0, 32)
spDown.Position = UDim2.new(1, -40, 0, 125)
spDown.BackgroundColor3 = Color3.fromRGB(45, 42, 55)
spDown.Text = "−"
spDown.TextColor3 = Color3.fromRGB(230, 230, 240)
spDown.Font = Enum.Font.GothamBold
spDown.TextSize = 16
spDown.Parent = f
Instance.new("UICorner", spDown).CornerRadius = UDim.new(0, 8)

spUp.MouseButton1Click:Connect(function()
    sp = math.min(sp + 20, 200)
    spBtn.Text = "Speed: " .. sp
end)
spDown.MouseButton1Click:Connect(function()
    sp = math.max(sp - 20, 16)
    spBtn.Text = "Speed: " .. sp
end)

RunService.Heartbeat:Connect(function()
    local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if h and h.WalkSpeed ~= sp then h.WalkSpeed = sp end
end)

print("[Yoriho Hub] loaded")
