-- Physics System for Delta Executor
-- С автоматическим удалением одежды

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

if not player then 
    print("Игрок не найден")
    return 
end

print("✅ Скрипт запущен")

local character = player.Character
if not character then
    character = player.CharacterAdded:Wait()
end

wait(1)

local physicsParts = {}
local meshesAdded = false
local torso = nil
local connections = {}
local boobSize = 0.4
local assSize = 0.3
local clothingRemoved = false

-- ============================================================
--   ФУНКЦИЯ УДАЛЕНИЯ ОДЕЖДЫ
-- ============================================================
local function removeClothing(char)
    if clothingRemoved then return end
    
    -- Удаляем Shirt
    local shirt = char:FindFirstChild("Shirt")
    if shirt then
        shirt:Destroy()
        print("👕 Shirt удален")
    end
    
    -- Удаляем Pants
    local pants = char:FindFirstChild("Pants")
    if pants then
        pants:Destroy()
        print("👖 Pants удалены")
    end
    
    -- Удаляем Torso (если есть как одежда)
    local torsoClothing = char:FindFirstChild("Torso")
    if torsoClothing and torsoClothing:IsA("Accessory") then
        torsoClothing:Destroy()
        print("👕 Torso одежда удалена")
    end
    
    -- Удаляем все Accessory (аксессуары)
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            child:Destroy()
            print("🎒 Аксессуар удален: " .. child.Name)
        end
    end
    
    clothingRemoved = true
    print("✅ Одежда удалена!")
end

-- ============================================================
--   ФУНКЦИЯ ВОССТАНОВЛЕНИЯ ОДЕЖДЫ (опционально)
-- ============================================================
local function restoreClothing(char)
    -- Roblox автоматически восстанавливает одежду при респавне
    -- Эта функция просто сбрасывает флаг
    clothingRemoved = false
    print("🔄 Одежда будет восстановлена при респавне")
end

-- Функция создания меша с поворотом
local function createPart(name, parent, cframe, size, meshId, scale, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Parent = parent
    part.CFrame = cframe
    part.Size = size
    part.BrickColor = color or BrickColor.new("Medium stone grey")
    part.CanCollide = false
    part.Locked = true
    part.Material = Enum.Material.SmoothPlastic
    part.Anchored = false
    part.Transparency = 0
    
    if meshId then
        local mesh = Instance.new("SpecialMesh")
        mesh.Parent = part
        mesh.MeshId = meshId
        mesh.Scale = scale or Vector3.new(1, 1, 1)
        mesh.MeshType = Enum.MeshType.FileMesh
    end
    
    return part
end

-- Функция создания привязки через Weld с поворотом
local function attachWithWeld(part, torso, offset, rotation)
    local weld = Instance.new("Weld")
    weld.Parent = part
    weld.Part0 = torso
    weld.Part1 = part
    
    local cf = CFrame.new(offset)
    
    if rotation then
        cf = cf * rotation
    end
    
    weld.C0 = torso.CFrame:inverse() * (torso.CFrame * cf)
    weld.Name = "AttachWeld"
    return weld
end

-- Функция добавления мешей
local function addMeshes()
    -- Удаляем старые меши
    for _, p in ipairs(physicsParts) do
        p:Destroy()
    end
    physicsParts = {}
    
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    -- Получаем персонажа
    local char = player.Character
    if not char then
        print("❌ Персонаж не найден!")
        return false
    end
    
    -- 🔥 УДАЛЯЕМ ОДЕЖДУ
    removeClothing(char)
    
    torso = char:FindFirstChild("Torso")
    if not torso then
        torso = char:FindFirstChild("UpperTorso")
    end
    
    if not torso then
        print("❌ Торс не найден!")
        return false
    end
    
    local color = torso.BrickColor
    
    local boobPos = Vector3.new(0.55, 0.25, -0.9)
    local assPos = Vector3.new(0.45, -0.7, 0.5)
    
    -- Повороты для груди
    local boobRotation = CFrame.Angles(
        math.rad(0),
        math.rad(30),
        math.rad(25)
    )
    
    local boobRotationLeft = CFrame.Angles(
        math.rad(0),
        math.rad(-30),
        math.rad(-25)
    )
    
    -- Повороты для ягодиц
    local assRotation = CFrame.Angles(
        math.rad(0),
        math.rad(15),
        math.rad(10)
    )
    
    local assRotationLeft = CFrame.Angles(
        math.rad(0),
        math.rad(-15),
        math.rad(-10)
    )
    
    -- ГРУДЬ ПРАВАЯ
    local rBoob = createPart("RightBoob", char, 
        torso.CFrame * CFrame.new(boobPos.X, boobPos.Y, boobPos.Z) * boobRotation,
        Vector3.new(1.5 * (boobSize/0.6), 1.4 * (boobSize/0.6), 1.2 * (boobSize/0.6)),
        "rbxassetid://7135906486",
        Vector3.new(boobSize, boobSize * 0.97, boobSize * 0.97),
        color
    )
    table.insert(physicsParts, rBoob)
    attachWithWeld(rBoob, torso, boobPos, boobRotation)
    
    -- ГРУДЬ ЛЕВАЯ
    local lBoob = createPart("LeftBoob", char, 
        torso.CFrame * CFrame.new(-boobPos.X, boobPos.Y, boobPos.Z) * boobRotationLeft,
        Vector3.new(1.5 * (boobSize/0.6), 1.4 * (boobSize/0.6), 1.2 * (boobSize/0.6)),
        "rbxassetid://7135906486",
        Vector3.new(boobSize, boobSize * 0.97, boobSize * 0.97),
        color
    )
    table.insert(physicsParts, lBoob)
    attachWithWeld(lBoob, torso, Vector3.new(-boobPos.X, boobPos.Y, boobPos.Z), boobRotationLeft)
    
    -- ЯГОДИЦА ПРАВАЯ
    local rAss = createPart("RightAss", char, 
        torso.CFrame * CFrame.new(assPos.X, assPos.Y, assPos.Z) * assRotation,
        Vector3.new(1.4 * (assSize/1.1), 1.0 * (assSize/1.1), 0.8 * (assSize/1.1)),
        "rbxassetid://7135906486",
        Vector3.new(assSize, assSize * 0.82, assSize * 0.82),
        color
    )
    table.insert(physicsParts, rAss)
    attachWithWeld(rAss, torso, assPos, assRotation)
    
    -- ЯГОДИЦА ЛЕВАЯ
    local lAss = createPart("LeftAss", char, 
        torso.CFrame * CFrame.new(-assPos.X, assPos.Y, assPos.Z) * assRotationLeft,
        Vector3.new(1.4 * (assSize/1.1), 1.0 * (assSize/1.1), 0.8 * (assSize/1.1)),
        "rbxassetid://7135906486",
        Vector3.new(assSize, assSize * 0.82, assSize * 0.82),
        color
    )
    table.insert(physicsParts, lAss)
    attachWithWeld(lAss, torso, Vector3.new(-assPos.X, assPos.Y, assPos.Z), assRotationLeft)
    
    -- Обновление цвета
    local colorConn = torso:GetPropertyChangedSignal("BrickColor"):Connect(function()
        local newColor = torso.BrickColor
        for _, part in ipairs(physicsParts) do
            if part and part.Parent then
                part.BrickColor = newColor
            end
        end
    end)
    table.insert(connections, colorConn)
    
    meshesAdded = true
    print("✅ Меши добавлены! (" .. #physicsParts .. " штук)")
    print("💗 Размер груди: 0.40")
    print("🍑 Размер ягодиц: 0.30")
    print("👕 Одежда удалена!")
    return true
end

-- Функция удаления мешей
local function removeMeshes()
    for _, p in ipairs(physicsParts) do
        p:Destroy()
    end
    physicsParts = {}
    
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    meshesAdded = false
    print("🗑️ Меши удалены")
end

-- СОЗДАНИЕ GUI
local function createGUI()
    local oldGui = player.PlayerGui:FindFirstChild("PhysicsGUI")
    if oldGui then oldGui:Destroy() end
    
    local gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    gui.Name = "PhysicsGUI"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 250, 0, 220)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.5)
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Text = "⚡ PHYSICS ⚡"
    title.TextColor3 = Color3.new(1, 0.6, 0.8)
    title.BackgroundTransparency = 1
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    
    -- Статус
    local status = Instance.new("TextLabel")
    status.Parent = frame
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 0, 30)
    status.Text = "📌 Статус: Меши не добавлены"
    status.TextColor3 = Color3.new(1, 0.6, 0.4)
    status.BackgroundTransparency = 1
    status.TextSize = 11
    status.Font = Enum.Font.GothamMedium
    
    -- Кнопка добавить
    local addBtn = Instance.new("TextButton")
    addBtn.Parent = frame
    addBtn.Size = UDim2.new(0.8, 0, 0, 30)
    addBtn.Position = UDim2.new(0.1, 0, 0, 55)
    addBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
    addBtn.BorderSizePixel = 0
    addBtn.Text = "➕ ДОБАВИТЬ МЕШИ"
    addBtn.TextColor3 = Color3.new(1, 1, 1)
    addBtn.TextSize = 12
    addBtn.Font = Enum.Font.GothamBold
    
    -- Кнопка удалить
    local remBtn = Instance.new("TextButton")
    remBtn.Parent = frame
    remBtn.Size = UDim2.new(0.8, 0, 0, 30)
    remBtn.Position = UDim2.new(0.1, 0, 0, 90)
    remBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    remBtn.BorderSizePixel = 0
    remBtn.Text = "🗑️ УДАЛИТЬ МЕШИ"
    remBtn.TextColor3 = Color3.new(1, 1, 1)
    remBtn.TextSize = 12
    remBtn.Font = Enum.Font.GothamBold
    
    -- Кнопка удалить одежду (отдельно)
    local clothBtn = Instance.new("TextButton")
    clothBtn.Parent = frame
    clothBtn.Size = UDim2.new(0.8, 0, 0, 25)
    clothBtn.Position = UDim2.new(0.1, 0, 0, 125)
    clothBtn.BackgroundColor3 = Color3.new(0.5, 0.2, 0.5)
    clothBtn.BorderSizePixel = 0
    clothBtn.Text = "👕 УДАЛИТЬ ОДЕЖДУ"
    clothBtn.TextColor3 = Color3.new(1, 1, 1)
    clothBtn.TextSize = 11
    clothBtn.Font = Enum.Font.GothamBold
    
    -- Инфо
    local info = Instance.new("TextLabel")
    info.Parent = frame
    info.Size = UDim2.new(1, 0, 0, 40)
    info.Position = UDim2.new(0, 0, 0, 155)
    info.Text = "💗 Boob: 0.40 | 🍑 Ass: 0.30\n👕 Одежда удаляется автоматически"
    info.TextColor3 = Color3.new(0.8, 0.8, 0.9)
    info.BackgroundTransparency = 1
    info.TextSize = 10
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Логика кнопок
    addBtn.MouseButton1Click:Connect(function()
        if meshesAdded then
            status.Text = "⚠️ Меши уже добавлены!"
            status.TextColor3 = Color3.new(1, 0.8, 0.2)
            wait(1)
            status.Text = "📌 Статус: Меши добавлены ✅"
            status.TextColor3 = Color3.new(0.4, 1, 0.4)
            return
        end
        
        if addMeshes() then
            status.Text = "✅ Меши + одежда удалены!"
            status.TextColor3 = Color3.new(0.4, 1, 0.4)
            addBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            addBtn.Text = "✅ МЕШИ ДОБАВЛЕНЫ"
        else
            status.Text = "❌ Ошибка! Торс не найден"
            status.TextColor3 = Color3.new(1, 0.3, 0.3)
        end
    end)
    
    remBtn.MouseButton1Click:Connect(function()
        if not meshesAdded then
            status.Text = "⚠️ Меши уже удалены!"
            status.TextColor3 = Color3.new(1, 0.8, 0.2)
            wait(1)
            status.Text = "📌 Статус: Меши не добавлены"
            status.TextColor3 = Color3.new(1, 0.6, 0.4)
            return
        end
        
        removeMeshes()
        status.Text = "🗑️ Меши удалены! Одежда будет при респавне"
        status.TextColor3 = Color3.new(1, 0.6, 0.4)
        addBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
        addBtn.Text = "➕ ДОБАВИТЬ МЕШИ"
    end)
    
    -- Отдельная кнопка для удаления одежды
    clothBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if not char then
            status.Text = "❌ Персонаж не найден!"
            status.TextColor3 = Color3.new(1, 0.3, 0.3)
            return
        end
        
        removeClothing(char)
        status.Text = "👕 Одежда удалена!"
        status.TextColor3 = Color3.new(0.8, 0.4, 1)
        wait(1)
        if meshesAdded then
            status.Text = "📌 Статус: Меши добавлены ✅"
            status.TextColor3 = Color3.new(0.4, 1, 0.4)
        else
            status.Text = "📌 Статус: Меши не добавлены"
            status.TextColor3 = Color3.new(1, 0.6, 0.4)
        end
    end)
    
    -- Обновление при респавне
    player.CharacterAdded:Connect(function()
        wait(2)
        character = player.Character
        meshesAdded = false
        clothingRemoved = false
        status.Text = "📌 Статус: Меши не добавлены"
        status.TextColor3 = Color3.new(1, 0.6, 0.4)
        addBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
        addBtn.Text = "➕ ДОБАВИТЬ МЕШИ"
        print("🔄 Персонаж пересоздан, одежда восстановлена")
    end)
    
    print("✅ GUI создан!")
end

-- ЗАПУСК
pcall(function()
    createGUI()
end)

print("✅ Система загружена!")
print("💗 Размер груди: 0.40")
print("🍑 Размер ягодиц: 0.30")
print("👕 При добавлении мешей одежда удаляется автоматически")
print("💗 Нажмите 'ДОБАВИТЬ МЕШИ' для активации")
