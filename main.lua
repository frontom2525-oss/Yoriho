-- ============================================
-- YORIHO KEY SYSTEM
-- ============================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

-- ССЫЛКА НА keys_db.json (RAW с GitHub)
local KEYS_URL = "https://raw.githubusercontent.com/frontom2525-oss/Yoriho/refs/heads/main/keys_db.json"

-- ОСНОВНОЙ СКРИПТ (загрузится после ключа)
local function loadMainScript()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/frontom2525-oss/Yoriho/refs/heads/main/main.lua"))()
end

-- ПРОВЕРКА КЛЮЧА
local function checkKey(key)
    local ok, response = pcall(function()
        return game:HttpGet(KEYS_URL)
    end)
    if not ok or not response then
        return false, "Ошибка загрузки базы"
    end
    
    local db = HttpService:JSONDecode(response)
    if not db[key] then
        return false, "Ключ не найден"
    end
    
    local info = db[key]
    
    if info.type == "vip" or info.expires == "never" then
        return true, "vip"
    end
    
    local year = tonumber(string.match(info.expires, "(%d+)-"))
    local month = tonumber(string.match(info.expires, "%d+%-(%d+)-"))
    local day = tonumber(string.match(info.expires, "%d+%-%d+%-(%d+)"))
    local hour = tonumber(string.match(info.expires, "T(%d+):"))
    local min = tonumber(string.match(info.expires, "T%d+:(%d+)"))
    
    if not year or not month or not day then
        return false, "Ошибка даты"
    end
    
    local now = os.time()
    local expireTime = os.time({
        year = year, month = month, day = day,
        hour = hour or 0, min = min or 0, sec = 0
    })
    
    if now > expireTime then
        return false, "Ключ истёк"
    end
    
    return true, "regular"
end

-- KEY GUI
local old = lp.PlayerGui:FindFirstChild("YorihoKeyGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "YorihoKeyGui"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 240)
frame.Position = UDim2.new(0.5, -160, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(180, 120, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "YORIHO KEY SYSTEM"
title.TextColor3 = Color3.fromRGB(200, 150, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, -20, 0, 20)
desc.Position = UDim2.new(0, 10, 0, 40)
desc.BackgroundTransparency = 1
desc.Text = "Введи ключ для доступа"
desc.TextColor3 = Color3.fromRGB(180, 180, 190)
desc.Font = Enum.Font.Gotham
desc.TextSize = 12
desc.Parent = frame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 0, 40)
keyBox.Position = UDim2.new(0, 20, 0, 70)
keyBox.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "YORIHO-XXXX-XXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.Font = Enum.Font.GothamBold
keyBox.TextSize = 13
keyBox.ClearTextOnFocus = false
keyBox.Parent = frame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 120)
btn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
btn.Text = "ПРОВЕРИТЬ"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 13
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 165)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = frame

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Size = UDim2.new(1, -40, 0, 30)
getKeyBtn.Position = UDim2.new(0, 20, 0, 185)
getKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
getKeyBtn.Text = "✈ Получить ключ в боте"
getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
getKeyBtn.Font = Enum.Font.GothamBold
getKeyBtn.TextSize = 12
getKeyBtn.Parent = frame
Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)
getKeyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://t.me/Steal_egg_stock_yoriho_bot")
    end)
end)

-- RGB
task.spawn(function()
    local hue = 0
    while gui.Parent do
        task.wait(0.05)
        hue = (hue + 0.01) % 1
        local c = Color3.fromHSV(hue, 0.7, 1)
        stroke.Color = c
        title.TextColor3 = c
    end
end)

-- Проверка
btn.MouseButton1Click:Connect(function()
    local key = keyBox.Text
    if key == "" then
        status.Text = "Введи ключ!"
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    status.Text = "Проверка..."
    status.TextColor3 = Color3.fromRGB(255, 200, 50)
    btn.Text = "ПРОВЕРКА..."
    
    task.spawn(function()
        local valid, msg = checkKey(key)
        
        if valid then
            if msg == "vip" then
                status.Text = "👑 VIP! Навсегда!"
            else
                status.Text = "✅ Ключ принят! 1 день."
            end
            status.TextColor3 = Color3.fromRGB(80, 220, 120)
            task.wait(1.5)
            gui:Destroy()
            loadMainScript()
        else
            status.Text = "❌ " .. msg
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.Text = "ПРОВЕРИТЬ"
            keyBox.Text = ""
        end
    end)
end)

print("[Yoriho Key System] Загружено")
