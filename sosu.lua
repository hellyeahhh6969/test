-- Physics System for Delta Executor
-- С упрощенной физикой (BodyGyro + BodyPosition)

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
local boobSize = 0.6
local assSize = 1.1
local meshesAdded = false
local torso = nil

-- Функция создания меша
local function createPart(name, parent, pos, size, meshId, scale, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Parent = parent
    part.CFrame = pos
    part.Size = size
    part.BrickColor = color or BrickColor.new("Medium stone grey")
    part.CanCollide = false
    part.Locked = false
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

-- Функция добавления физики (через BodyPosition)
local function addPhysics(part, torso, isAss)
    -- BodyPosition для удержания позиции
    local bp = Instance.new("BodyPosition")
    bp.Parent = part
    bp.MaxForce = Vector3.new(1000, 1000, 1000)
    bp.P = 3000
    bp.D = 500
    bp.Position = part.Position
    
    -- BodyGyro для вращения
    local bg = Instance.new("BodyGyro")
    bg.Parent = part
    bg.MaxTorque = Vector3.new(1000, 1000, 1000)
    bg.P = 3000
    bg.D = 500
    bg.CFrame = part.CFrame
    
    -- Обновляем позицию в каждом кадре
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not part.Parent then
            connection:Disconnect()
            return
        end
        
        -- Целевая позиция (с небольшим смещением для физики)
        local offset = Vector3.new(0, -0.2, 0)
        local targetPos = torso.Position + (part.CFrame - part.Position) + offset
        
        -- Если это ягодицы - больше смещение вниз
        if isAss then
            targetPos = targetPos + Vector3.new(0, -0.3, 0)
        end
        
        bp.Position = targetPos
        
        -- Вращение к торсу
        bg.CFrame = torso.CFrame
    end)
    
    return bp, bg, connection
end

-- Функция добавления мешей
local function addMeshes()
    -- Удаляем старые
    for _, p in ipairs(physicsParts) do
        p:Destroy()
    end
    physicsParts = {}
    
    torso = character:FindFirstChild("Torso")
    if not torso then
        torso = character:FindFirstChild("UpperTorso")
    end
    
    if not torso then
        print("❌ Торс не найден!")
        return false
    end
    
    local color = torso.BrickColor
    
    -- Позиции
    local boobPos = Vector3.new(0.55, 0.25, -0.9)
    local assPos = Vector3.new(0.45, -0.7, 0.5)
    
    -- Грудь правая
    local rBoob = createPart("RightBoob", character, 
        torso.CFrame * CFrame.new(boobPos.X, boobPos.Y, boobPos.Z),
        Vector3.new(1.5, 1.4, 1.2),
        "rbxassetid://7135906486",
        Vector3.new(boobSize, boobSize * 0.97, boobSize * 0.97),
        color
    )
    table.insert(physicsParts, rBoob)
    addPhysics(rBoob, torso, false)
    
    -- Грудь левая
    local lBoob = createPart("LeftBoob", character, 
        torso.CFrame * CFrame.new(-boobPos.X, boobPos.Y, boobPos.Z),
        Vector3.new(1.5, 1.4, 1.2),
        "rbxassetid://7135906486",
        Vector3.new(boobSize, boobSize * 0.97, boobSize * 0.97),
        color
    )
    table.insert(physicsParts, lBoob)
    addPhysics(lBoob, torso, false)
    
    -- Ягодица правая
    local rAss = createPart("RightAss", character, 
        torso.CFrame * CFrame.new(assPos.X, assPos.Y, assPos.Z),
        Vector3.new(1.4, 1.0, 0.8),
        "rbxassetid://7135906486",
        Vector3.new(assSize, assSize * 0.82, assSize * 0.82),
        color
    )
    table.insert(physicsParts, rAss)
    addPhysics(rAss, torso, true)
    
    -- Ягодица левая
    local lAss = createPart("LeftAss", character, 
        torso.CFrame * CFrame.new(-assPos.X, assPos.Y, assPos.Z),
        Vector3.new(1.4, 1.0, 0.8),
        "rbxassetid://7135906486",
        Vector3.new(assSize, assSize * 0.82, assSize * 0.82),
        color
    )
    table.insert(physicsParts, lAss)
    addPhysics(lAss, torso, true)
    
    meshesAdded = true
    print("✅ Меши добавлены с физикой! (" .. #physicsParts .. " штук)")
    return true
end

-- Функция удаления мешей
local function removeMeshes()
    for _, p in ipairs(physicsParts) do
        p:Destroy()
    end
    physicsParts = {}
    meshesAdded = false
    print("🗑️ Меши удалены")
end

-- СОЗДАНИЕ GUI
local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    gui.Name = "PhysicsGUI"
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 250, 0, 200)
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
    
    -- Инфо
    local info = Instance.new("TextLabel")
    info.Parent = frame
    info.Size = UDim2.new(1, 0, 0, 40)
    info.Position = UDim2.new(0, 0, 0, 130)
    info.Text = "💗 Boob Size: " .. string.format("%.2f", boobSize) .. "\n🍑 Ass Size: " .. string.format("%.2f", assSize)
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
            status.Text = "✅ Меши успешно добавлены!"
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
        status.Text = "🗑️ Меши удалены!"
        status.TextColor3 = Color3.new(1, 0.6, 0.4)
        addBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
        addBtn.Text = "➕ ДОБАВИТЬ МЕШИ"
    end)
    
    -- Обновление при респавне
    player.CharacterAdded:Connect(function()
        wait(2)
        character = player.Character
        meshesAdded = false
        status.Text = "📌 Статус: Меши не добавлены"
        status.TextColor3 = Color3.new(1, 0.6, 0.4)
        addBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
        addBtn.Text = "➕ ДОБАВИТЬ МЕШИ"
        print("🔄 Персонаж пересоздан")
    end)
    
    print("✅ GUI создан!")
end

-- ЗАПУСК
pcall(function()
    createGUI()
end)

print("✅ Система загружена!")
print("💗 Нажмите 'ДОБАВИТЬ МЕШИ' для активации")
print("🔧 Физика: BodyPosition + BodyGyro")
