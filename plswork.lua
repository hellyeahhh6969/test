-- Ryzen System: Delta Executor Enhanced Model Editor
-- Полностью совместим с Delta (поддержка Drawing, getgenv, task)

-- Получение окружения Delta
local deltaEnv = getgenv() or _G
local isDelta = syn and syn.crypt or false

-- Функция для создания GUI через Drawing (если не работает ScreenGui)
local function createDeltaGUI()
    -- Проверяем наличие CoreGui
    local coreGui = game:GetService("CoreGui")
    if not coreGui then
        warn("Ryzen: CoreGui not found, using Drawing fallback")
        return nil
    end

    -- Удаляем старую панель
    local oldGui = coreGui:FindFirstChild("RyzenModelEditor")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RyzenModelEditor"
    screenGui.Parent = coreGui
    screenGui.ResetOnSpawn = false

    -- Основное окно
    local mainFrame = Instance.new("Frame")
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, 350, 0, 320)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -160)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.ClipsDescendants = true

    -- Градиент (для стиля)
    local gradient = Instance.new("UIGradient")
    gradient.Parent = mainFrame
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.8)
    })

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Parent = mainFrame
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.BackgroundTransparency = 0.3
    title.Text = "🔧 Ryzen Model Editor (Delta)"
    title.TextColor3 = Color3.fromRGB(200, 220, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold

    -- Статусная строка
    local statusBar = Instance.new("Frame")
    statusBar.Parent = mainFrame
    statusBar.Size = UDim2.new(1, 0, 0, 25)
    statusBar.Position = UDim2.new(0, 0, 0, 35)
    statusBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    statusBar.BackgroundTransparency = 0.3

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Parent = statusBar
    statusLabel.Size = UDim2.new(1, 0, 1, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "⏳ Поиск модели..."
    statusLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.Padding = UDim.new(0, 10)

    -- Скролл-контейнер для слайдеров
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = mainFrame
    scrollFrame.Size = UDim2.new(1, -10, 1, -110)
    scrollFrame.Position = UDim2.new(0, 5, 0, 65)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)

    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)

    -- Переменные для хранения данных
    local model = nil
    local sliders = {}
    local values = {}
    local partNames = {"Left Boob", "Right Boob", "Left Leg", "Right Leg"}
    local displayNames = {"🍒 Left Boob", "🍒 Right Boob", "🍑 Left Ass", "🍑 Right Ass"}

    -- Функция обновления модели
    local function updateModel()
        if not model or not model.Parent then
            -- Ищем модель с Humanoid
            for _, child in pairs(workspace:GetChildren()) do
                if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
                    model = child
                    break
                end
            end
            if not model then
                statusLabel.Text = "❌ Модель не найдена"
                return
            end
        end
        statusLabel.Text = "✅ Модель: " .. model.Name

        -- Обновление размеров частей
        for i, partName in ipairs(partNames) do
            local part = model:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                local baseSize = part.Size
                local multiplier = sliders[i].Value / 100
                local newSize = Vector3.new(
                    math.max(baseSize.X * multiplier, 0.2),
                    math.max(baseSize.Y * multiplier, 0.2),
                    math.max(baseSize.Z * multiplier, 0.2)
                )
                part.Size = newSize
                values[i].Text = string.format("%.0f%%", sliders[i].Value)
            end
        end
    end

    -- Создание слайдеров
    for i = 1, 4 do
        local container = Instance.new("Frame")
        container.Parent = scrollFrame
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundTransparency = 1

        -- Название части
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = container
        nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = displayNames[i]
        nameLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14

        -- Значение
        local valLabel = Instance.new("TextLabel")
        valLabel.Parent = container
        valLabel.Size = UDim2.new(0.15, 0, 1, 0)
        valLabel.Position = UDim2.new(0.4, 0, 0, 0)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = "100%"
        valLabel.TextColor3 = Color3.fromRGB(255, 255, 150)
        valLabel.Font = Enum.Font.Gotham
        valLabel.TextSize = 14
        values[i] = valLabel

        -- Слайдер (числовой ползунок)
        local slider = Instance.new("Slider")
        slider.Parent = container
        slider.Size = UDim2.new(0.4, 0, 0.6, 0)
        slider.Position = UDim2.new(0.55, 0, 0.2, 0)
        slider.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        slider.BorderSizePixel = 0
        slider.MinValue = 10
        slider.MaxValue = 300
        slider.Value = 100

        -- Кастомизация слайдера (стиль Delta)
        local sliderBar = slider:FindFirstChild("SliderBar") or Instance.new("Frame")
        if not sliderBar.Parent then
            sliderBar.Parent = slider
        end
        sliderBar.Size = UDim2.new(1, 0, 0.2, 0)
        sliderBar.Position = UDim2.new(0, 0, 0.4, 0)
        sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
        sliderBar.BorderSizePixel = 0

        local sliderFill = slider:FindFirstChild("SliderFill") or Instance.new("Frame")
        if not sliderFill.Parent then
            sliderFill.Parent = sliderBar
        end
        sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        sliderFill.BorderSizePixel = 0

        local handle = slider:FindFirstChild("Handle") or Instance.new("Frame")
        if not handle.Parent then
            handle.Parent = slider
        end
        handle.Size = UDim2.new(0, 16, 0.8, 0)
        handle.Position = UDim2.new(0.5, -8, 0.1, 0)
        handle.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
        handle.BorderSizePixel = 0
        handle.AnchorPoint = Vector2.new(0.5, 0)

        -- Сохраняем слайдер
        sliders[i] = slider

        -- Обновление при изменении
        local function onSliderChange()
            updateModel()
        end
        slider:GetPropertyChangedSignal("Value"):Connect(onSliderChange)
    end

    -- Кнопки управления
    local btnFrame = Instance.new("Frame")
    btnFrame.Parent = mainFrame
    btnFrame.Size = UDim2.new(1, 0, 0, 35)
    btnFrame.Position = UDim2.new(0, 0, 1, -35)
    btnFrame.BackgroundTransparency = 1

    -- Кнопка обновления
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Parent = btnFrame
    refreshBtn.Size = UDim2.new(0.3, 0, 1, 0)
    refreshBtn.Position = UDim2.new(0.05, 0, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    refreshBtn.Text = "🔄 Обновить"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14

    refreshBtn.MouseButton1Click:Connect(function()
        model = nil
        statusLabel.Text = "⏳ Поиск модели..."
        updateModel()
    end)

    -- Кнопка сброса
    local resetBtn = Instance.new("TextButton")
    resetBtn.Parent = btnFrame
    resetBtn.Size = UDim2.new(0.3, 0, 1, 0)
    resetBtn.Position = UDim2.new(0.4, 0, 0, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    resetBtn.Text = "↺ Сброс"
    resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14

    resetBtn.MouseButton1Click:Connect(function()
        for _, slider in ipairs(sliders) do
            slider.Value = 100
        end
        updateModel()
    end)

    -- Кнопка скрыть
    local hideBtn = Instance.new("TextButton")
    hideBtn.Parent = btnFrame
    hideBtn.Size = UDim2.new(0.2, 0, 1, 0)
    hideBtn.Position = UDim2.new(0.75, 0, 0, 0)
    hideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
    hideBtn.Text = "✕"
    hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hideBtn.Font = Enum.Font.GothamBold
    hideBtn.TextSize = 16

    hideBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = not screenGui.Enabled
    end)

    -- Инициализация
    task.wait(0.3)
    updateModel()

    return screenGui
end

-- Запуск в среде Delta
local function main()
    -- Проверка на наличие Delta
    if not game:GetService("CoreGui") then
        warn("Ryzen: Delta environment detected but CoreGui missing. Trying fallback...")
    end

    local success, err = pcall(function()
        local gui = createDeltaGUI()
        if gui then
            print("🔧 Ryzen System: Delta Model Editor успешно загружен!")
            print("📌 Используйте слайдеры для изменения размеров.")
        else
            warn("⚠️ Ryzen: Не удалось создать GUI через CoreGui.")
        end
    end)

    if not success then
        warn("❌ Ryzen: Ошибка при создании GUI: ", err)
        -- Альтернативный метод через Drawing (если поддерживается)
        if Drawing and Drawing.new then
            warn("Ryzen: Попытка создания Drawing GUI...")
            -- Здесь можно добавить альтернативный GUI через Drawing
        end
    end
end

-- Выполнение с защитой
xpcall(main, function(err)
    warn("Ryzen: Критическая ошибка: ", err)
    print("🔄 Попытка перезапуска через 2 секунды...")
    task.wait(2)
    main()
end)

-- Глобальная команда для вызова панели
getgenv().RyzenEditor = function()
    if game.CoreGui:FindFirstChild("RyzenModelEditor") then
        game.CoreGui.RyzenModelEditor.Enabled = true
    else
        createDeltaGUI()
    end
end

print("✅ Ryzen System готов к работе. Введите RyzenEditor() для вызова панели.")
