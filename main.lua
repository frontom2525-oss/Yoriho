-- ============================================
-- YORIHO KEY SYSTEM + SEARCH SERVER (ЕДИНЫЙ, RU/EN)
-- ============================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local lp = Players.LocalPlayer

-- ССЫЛКА НА БАЗУ КЛЮЧЕЙ
local KEYS_URL = "https://raw.githubusercontent.com/frontom2525-oss/Yoriho/main/keys_db.json"

-- ССЫЛКА НА БОТА С КЛЮЧАМИ
local BOT_URL = "https://t.me/Keyssystemyoriho_bot"

-- ============================================
-- ТЕКУЩИЙ ЯЗЫК (общий)
-- ============================================
local currentLang = "RU"

local function L(ru, en)
    if currentLang == "RU" then return ru else return en end
end

-- ============================================
-- ФУНКЦИЯ ПРОВЕРКИ КЛЮЧА
-- ============================================
local function checkKey(key)
    local ok, response = pcall(function()
        return game:HttpGet(KEYS_URL)
    end)
    if not ok or not response then
        return false, L("Ошибка загрузки базы", "Database load error")
    end
    
    local db = HttpService:JSONDecode(response)
    if not db[key] then
        return false, L("Ключ не найден", "Key not found")
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
        return false, L("Ошибка даты", "Date error")
    end
    
    local now = os.time()
    local expireTime = os.time({
        year = year, month = month, day = day,
        hour = hour or 0, min = min or 0, sec = 0
    })
    
    if now > expireTime then
        return false, L("Ключ истёк", "Key expired")
    end
    
    return true, "regular"
end

-- ============================================
-- ССЫЛКИ НА ОБНОВЛЕНИЕ ТЕКСТА
-- ============================================
local updateKeyLang
local updateMainLang

-- ============================================
-- KEY GUI (ОКНО ВВОДА КЛЮЧА)
-- ============================================
local oldKeyGui = lp.PlayerGui:FindFirstChild("YorihoKeyGui")
if oldKeyGui then oldKeyGui:Destroy() end

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "YorihoKeyGui"
keyGui.ResetOnSpawn = false
keyGui.Parent = lp:WaitForChild("PlayerGui")

local kFrame = Instance.new("Frame")
kFrame.Size = UDim2.new(0, 320, 0, 250)
kFrame.Position = UDim2.new(0.5, -160, 0.4, 0)
kFrame.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
kFrame.BackgroundTransparency = 0.1
kFrame.BorderSizePixel = 0
kFrame.Active = true
kFrame.Draggable = true
kFrame.Parent = keyGui
Instance.new("UICorner", kFrame).CornerRadius = UDim.new(0, 14)

local kStroke = Instance.new("UIStroke", kFrame)
kStroke.Color = Color3.fromRGB(180, 120, 255)
kStroke.Thickness = 2

local kTitle = Instance.new("TextLabel")
kTitle.Size = UDim2.new(1, -90, 0, 40)
kTitle.Position = UDim2.new(0, 10, 0, 0)
kTitle.BackgroundTransparency = 1
kTitle.Text = "YORIHO KEY SYSTEM"
kTitle.TextColor3 = Color3.fromRGB(200, 150, 255)
kTitle.Font = Enum.Font.GothamBold
kTitle.TextSize = 15
kTitle.TextXAlignment = Enum.TextXAlignment.Left
kTitle.Parent = kFrame

-- Кнопка языка (в ключ-системе)
local kLangBtn = Instance.new("TextButton")
kLangBtn.Size = UDim2.new(0, 40, 0, 24)
kLangBtn.Position = UDim2.new(1, -50, 0, 8)
kLangBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
kLangBtn.BackgroundTransparency = 0.15
kLangBtn.Text = "RU"
kLangBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kLangBtn.Font = Enum.Font.GothamBold
kLangBtn.TextSize = 11
kLangBtn.Parent = kFrame
Instance.new("UICorner", kLangBtn).CornerRadius = UDim.new(0, 6)

local kLangStroke = Instance.new("UIStroke", kLangBtn)
kLangStroke.Color = Color3.fromRGB(80, 180, 255)
kLangStroke.Thickness = 1
kLangStroke.Transparency = 0.3

local kDesc = Instance.new("TextLabel")
kDesc.Size = UDim2.new(1, -20, 0, 20)
kDesc.Position = UDim2.new(0, 10, 0, 40)
kDesc.BackgroundTransparency = 1
kDesc.Text = L("Введи ключ для доступа", "Enter key to access")
kDesc.TextColor3 = Color3.fromRGB(180, 180, 190)
kDesc.Font = Enum.Font.Gotham
kDesc.TextSize = 12
kDesc.Parent = kFrame

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
keyBox.Parent = kFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local kBtn = Instance.new("TextButton")
kBtn.Size = UDim2.new(1, -40, 0, 40)
kBtn.Position = UDim2.new(0, 20, 0, 120)
kBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
kBtn.Text = L("ПРОВЕРИТЬ", "CHECK")
kBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kBtn.Font = Enum.Font.GothamBold
kBtn.TextSize = 13
kBtn.Parent = kFrame
Instance.new("UICorner", kBtn).CornerRadius = UDim.new(0, 8)

local kStatus = Instance.new("TextLabel")
kStatus.Size = UDim2.new(1, -20, 0, 20)
kStatus.Position = UDim2.new(0, 10, 0, 165)
kStatus.BackgroundTransparency = 1
kStatus.Text = ""
kStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
kStatus.Font = Enum.Font.Gotham
kStatus.TextSize = 11
kStatus.Parent = kFrame

local kGetBtn = Instance.new("TextButton")
kGetBtn.Size = UDim2.new(1, -40, 0, 30)
kGetBtn.Position = UDim2.new(0, 20, 0, 195)
kGetBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
kGetBtn.Text = L("✈ Получить ключ в боте", "✈ Get key in bot")
kGetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kGetBtn.Font = Enum.Font.GothamBold
kGetBtn.TextSize = 12
kGetBtn.Parent = kFrame
Instance.new("UICorner", kGetBtn).CornerRadius = UDim.new(0, 8)
kGetBtn.MouseButton1Click:Connect(function()
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(BOT_URL)
    end)
end)

updateKeyLang = function()
    kLangBtn.Text = currentLang
    kTitle.Text = "YORIHO KEY SYSTEM"
    kDesc.Text = L("Введи ключ для доступа", "Enter key to access")
    kBtn.Text = L("ПРОВЕРИТЬ", "CHECK")
    kGetBtn.Text = L("✈ Получить ключ в боте", "✈ Get key in bot")
end

kLangBtn.MouseButton1Click:Connect(function()
    currentLang = (currentLang == "RU") and "EN" or "RU"
    updateKeyLang()
    if updateMainLang then updateMainLang() end
end)

-- RGB ключ-системы
task.spawn(function()
    local hue = 0
    while keyGui.Parent do
        task.wait(0.05)
        hue = (hue + 0.01) % 1
        local c = Color3.fromHSV(hue, 0.7, 1)
        kStroke.Color = c
        kTitle.TextColor3 = c
        kLangStroke.Color = c
    end
end)

-- Проверка ключа
kBtn.MouseButton1Click:Connect(function()
    local key = keyBox.Text
    if key == "" then
        kStatus.Text = L("Введи ключ!", "Enter key!")
        kStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    kStatus.Text = L("Проверка...", "Checking...")
    kStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
    kBtn.Text = L("ПРОВЕРКА...", "CHECKING...")
    
    task.spawn(function()
        local valid, msg = checkKey(key)
        
        if valid then
            if msg == "vip" then
                kStatus.Text = L("👑 VIP! Навсегда!", "👑 VIP! Forever!")
            else
                kStatus.Text = L("✅ Ключ принят! 1 день.", "✅ Key accepted! 1 day.")
            end
            kStatus.TextColor3 = Color3.fromRGB(80, 220, 120)
            task.wait(1.5)
            keyGui:Destroy()
            loadMainScript()
        else
            kStatus.Text = "❌ " .. msg
            kStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            kBtn.Text = L("ПРОВЕРИТЬ", "CHECK")
            keyBox.Text = ""
        end
    end)
end)

print("[Yoriho Key System] Загружено")

-- ============================================
-- ОСНОВНОЙ СКРИПТ (SEARCH SERVER v10)
-- ============================================
function loadMainScript()
    print("[Yoriho] Ключ принят, запускаем чит...")
    
    local TeleportService = game:GetService("TeleportService")
    local TweenService = game:GetService("TweenService")
    local PlaceId = game.PlaceId
    
    local old = lp.PlayerGui:FindFirstChild("YorihoSearchServer")
    if old then old:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "YorihoSearchServer"
    gui.ResetOnSpawn = false
    gui.Parent = lp:WaitForChild("PlayerGui")
    
    -- ============================================
    -- ГЛАВНОЕ ОКНО
    -- ============================================
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 230)
    frame.Position = UDim2.new(0.5, -170, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    
    local gradient = Instance.new("UIGradient", frame)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 25, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 12, 20))
    }
    gradient.Rotation = 90
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(180, 120, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.1
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = 0
    shadow.Parent = frame
    
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 340, 0, 230),
        Position = UDim2.new(0.5, -170, 0.35, 0)
    }):Play()
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 0, 32)
    title.Position = UDim2.new(0, 14, 0, 2)
    title.BackgroundTransparency = 1
    title.Text = "Yoriho Search Server"
    title.TextColor3 = Color3.fromRGB(200, 150, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    -- Кнопка языка (в чите)
    local langBtn = Instance.new("TextButton")
    langBtn.Size = UDim2.new(0, 40, 0, 22)
    langBtn.Position = UDim2.new(1, -86, 0, 7)
    langBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
    langBtn.BackgroundTransparency = 0.15
    langBtn.Text = currentLang
    langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 11
    langBtn.Parent = frame
    Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 6)
    
    local langStroke = Instance.new("UIStroke", langBtn)
    langStroke.Color = Color3.fromRGB(80, 180, 255)
    langStroke.Thickness = 1
    langStroke.Transparency = 0.3
    
    -- Крестик
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -36, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 80)
    closeBtn.BackgroundTransparency = 0.1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        local tw = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 230)
        })
        tw:Play()
        tw.Completed:Connect(function() gui:Destroy() end)
    end)
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -28, 0, 1)
    divider.Position = UDim2.new(0, 14, 0, 38)
    divider.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    divider.BorderSizePixel = 0
    divider.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -28, 0, 55)
    status.Position = UDim2.new(0, 14, 0, 44)
    status.BackgroundTransparency = 1
    status.Text = L("Готов. Жми кнопку.", "Ready. Press the button.")
    status.TextColor3 = Color3.fromRGB(200, 200, 215)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextWrapped = true
    status.TextYAlignment = Enum.TextYAlignment.Top
    status.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -28, 0, 42)
    btn.Position = UDim2.new(0, 14, 0, 108)
    btn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    btn.BackgroundTransparency = 0.05
    btn.Text = L("НАЧАТЬ ПОИСК", "START SEARCH")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(120, 180, 255)
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.3
    
    local tgBtn = Instance.new("TextButton")
    tgBtn.Size = UDim2.new(1, -28, 0, 30)
    tgBtn.Position = UDim2.new(0, 14, 1, -40)
    tgBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 140)
    tgBtn.BackgroundTransparency = 0.15
    tgBtn.Text = "✈  @Keyssystemyoriho_bot"
    tgBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tgBtn.Font = Enum.Font.GothamBold
    tgBtn.TextSize = 12
    tgBtn.Parent = frame
    Instance.new("UICorner", tgBtn).CornerRadius = UDim.new(0, 8)
    
    local tgStroke = Instance.new("UIStroke", tgBtn)
    tgStroke.Color = Color3.fromRGB(80, 180, 255)
    tgStroke.Thickness = 1
    tgStroke.Transparency = 0.3
    
    tgBtn.MouseButton1Click:Connect(function()
        pcall(function()
            game:GetService("GuiService"):OpenBrowserWindow(BOT_URL)
        end)
    end)
    
    -- Шторка с цветами
    local colorPanel = Instance.new("Frame")
    colorPanel.Size = UDim2.new(0, 36, 0, 110)
    colorPanel.Position = UDim2.new(0, -36, 0.5, -55)
    colorPanel.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
    colorPanel.BackgroundTransparency = 0.25
    colorPanel.BorderSizePixel = 0
    colorPanel.Parent = gui
    Instance.new("UICorner", colorPanel).CornerRadius = UDim.new(0, 10)
    
    local colorStroke = Instance.new("UIStroke", colorPanel)
    colorStroke.Color = Color3.fromRGB(180, 120, 255)
    colorStroke.Thickness = 1
    colorStroke.Transparency = 0.3
    
    local colorTab = Instance.new("TextButton")
    colorTab.Size = UDim2.new(0, 20, 0, 50)
    colorTab.Position = UDim2.new(0, 0, 0.5, -25)
    colorTab.BackgroundColor3 = Color3.fromRGB(40, 32, 55)
    colorTab.BackgroundTransparency = 0.15
    colorTab.Text = ">"
    colorTab.TextColor3 = Color3.fromRGB(200, 150, 255)
    colorTab.Font = Enum.Font.GothamBold
    colorTab.TextSize = 14
    colorTab.Parent = gui
    Instance.new("UICorner", colorTab).CornerRadius = UDim.new(0, 6)
    
    local colorLayout = Instance.new("UIListLayout", colorPanel)
    colorLayout.FillDirection = Enum.FillDirection.Vertical
    colorLayout.Padding = UDim.new(0, 6)
    colorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    colorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    
    local colors = {
        Color3.fromRGB(180, 120, 255),
        Color3.fromRGB(255, 90, 120),
        Color3.fromRGB(80, 180, 240),
        Color3.fromRGB(90, 220, 130),
        Color3.fromRGB(255, 180, 60),
    }
    
    for _, c in ipairs(colors) do
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(0, 24, 0, 18)
        cb.BackgroundColor3 = c
        cb.Text = ""
        cb.Parent = colorPanel
        Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)
        cb.MouseButton1Click:Connect(function()
            stroke.Color = c
            title.TextColor3 = c
            colorStroke.Color = c
            colorTab.TextColor3 = c
        end)
    end
    
    local panelOpen = false
    colorTab.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        if panelOpen then
            TweenService:Create(colorPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, 5, 0.5, -55)
            }):Play()
            colorTab.Text = "<"
        else
            TweenService:Create(colorPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0, -36, 0.5, -55)
            }):Play()
            colorTab.Text = ">"
        end
    end)
    
    -- Кнопка Y (RGB)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
    toggleBtn.BackgroundTransparency = 0
    toggleBtn.Text = "Y"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 24
    toggleBtn.AutoButtonColor = false
    toggleBtn.Active = true
    toggleBtn.Draggable = true
    toggleBtn.Parent = gui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 14)
    
    local toggleStroke = Instance.new("UIStroke", toggleBtn)
    toggleStroke.Color = Color3.fromRGB(255, 255, 255)
    toggleStroke.Thickness = 2
    toggleStroke.Transparency = 0.2
    
    TweenService:Create(toggleBtn, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 50, 0, 50)
    }):Play()
    
    local menuOpen = true
    toggleBtn.MouseButton1Click:Connect(function()
        TweenService:Create(toggleBtn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 42, 0, 42)
        }):Play()
        task.wait(0.1)
        TweenService:Create(toggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 50, 0, 50)
        }):Play()
        
        menuOpen = not menuOpen
        if menuOpen then
            frame.Visible = true
            colorPanel.Visible = true
            colorTab.Visible = true
            TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 340, 0, 230)
            }):Play()
        else
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 230)
            }):Play()
            colorPanel.Visible = false
            colorTab.Visible = false
            task.wait(0.3)
            frame.Visible = false
        end
    end)
    
    -- RGB кнопки Y и меню
    local hueY = 0
    task.spawn(function()
        while gui.Parent do
            task.wait(0.05)
            hueY = (hueY + 0.008) % 1
            local newColor = Color3.fromHSV(hueY, 0.8, 1)
            toggleBtn.BackgroundColor3 = newColor
            toggleStroke.Color = Color3.fromHSV((hueY + 0.5) % 1, 0.6, 1)
        end
    end)
    
    local hue = 0
    task.spawn(function()
        while gui.Parent do
            task.wait(0.05)
            hue = (hue + 0.01) % 1
            local newColor = Color3.fromHSV(hue, 0.7, 1)
            stroke.Color = newColor
            title.TextColor3 = newColor
            btnStroke.Color = newColor
            colorStroke.Color = newColor
            tgStroke.Color = newColor
            langStroke.Color = newColor
        end
    end)
    
    -- Обновление языка внутри чита
    updateMainLang = function()
        langBtn.Text = currentLang
        title.Text = "Yoriho Search Server"
        btn.Text = L("НАЧАТЬ ПОИСК", "START SEARCH")
        if not running then
            status.Text = L("Готов. Жми кнопку.", "Ready. Press the button.")
        end
    end
    
    langBtn.MouseButton1Click:Connect(function()
        currentLang = (currentLang == "RU") and "EN" or "RU"
        updateMainLang()
        if updateKeyLang then updateKeyLang() end
    end)
    
    -- Логика поиска
    local running = false
    
    local function getServers(cursor)
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor then
            url = url .. "&cursor=" .. cursor
        end
        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if ok and res then
            return res.data or {}, res.nextPageCursor
        end
        return {}, nil
    end
    
    local function collectServers()
        local list = {}
        local cursor = nil
        for page = 1, 20 do
            local servers, nextCursor = getServers(cursor)
            for _, s in ipairs(servers) do
                if s.id ~= game.JobId then
                    local count = s.playing or 0
                    if count == 1 then
                        table.insert(list, s)
                    end
                end
            end
            cursor = nextCursor
            if not cursor then break end
            task.spawn(function()
                for _ = 1, 5 do
                    status.Text = L("Собираем... найдено: ", "Collecting... found: ") .. math.random(100, 9999)
                    task.wait(0.05)
                end
            end)
            task.wait(0.1)
        end
        return list
    end
    
    local function flashFound()
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
        flash.BackgroundTransparency = 0.5
        flash.BorderSizePixel = 0
        flash.Parent = frame
        Instance.new("UICorner", flash).CornerRadius = UDim.new(0, 14)
        TweenService:Create(flash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        task.wait(0.8)
        flash:Destroy()
    end
    
    btn.MouseButton1Click:Connect(function()
        if running then return end
        running = true
        btn.Text = L("РАБОТАЕТ...", "WORKING...")
        btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        
        task.spawn(function()
            status.Text = L("Шаг 1: Сканируем серверы...", "Step 1: Scanning servers...")
            status.TextColor3 = Color3.fromRGB(255, 200, 50)
            
            local serverList = collectServers()
            
            if #serverList == 0 then
                status.Text = L("Не нашли сервер с 1 игроком.", "No server with 1 player found.")
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
                running = false
                btn.Text = L("НАЧАТЬ ПОИСК", "START SEARCH")
                return
            end
            
            for i = 1, 15 do
                status.Text = L("Найдено: ", "Found: ") .. math.random(1, 999) .. L(" серверов!", " servers!")
                task.wait(0.05)
            end
            status.Text = L("Найдено ", "Found ") .. #serverList .. L(" серверов!", " servers!")
            status.TextColor3 = Color3.fromRGB(80, 220, 120)
            flashFound()
            task.wait(0.3)
            
            local index = 0
            while running and index < #serverList do
                index = index + 1
                local server = serverList[index]
                
                status.Text = L("Попытка ", "Attempt ") .. index .. "/" .. #serverList
                status.TextColor3 = Color3.fromRGB(255, 200, 50)
                
                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, lp)
                end)
                
                if not ok then
                    task.wait(0.5)
                else
                    task.wait(3)
                end
            end
            
            status.Text = L("Все серверы проверены.", "All servers checked.")
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            running = false
            btn.Text = L("НАЧАТЬ ПОИСК", "START SEARCH")
        end)
    end)
    
    print("[Yoriho Search Server v10] loaded")
end

updateMainLang = updateMainLang or function() end
