-- Physics System for Delta Executor
-- С выбором пола и типа персонажа + кнопка удаления одежды
-- МЕШИ ПЕРЕВЕРНУТЫ ОСТРОЙ СТОРОНОЙ ВВЕРХ
-- КНОПКИ + И - ДЛЯ РАЗМЕРА
-- ОГРАНИЧЕНИЯ: ГРУДЬ 0.60 - 0.95, ЯГОДИЦЫ 0.50 - 1.00

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

-- ============================================================
--   ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================================
local physicsParts = {}
local meshesAdded = false
local torso = nil
local connections = {}
local boobSize = 0.4
local assSize = 0.3
local clothingRemoved = false
local savedClothing = {}
local selectedGender = nil
local selectedBodyType = nil
local mainGUI = nil
local genderGUI = nil

-- ============================================================
--   ФУНКЦИЯ УДАЛЕНИЯ ТОЛЬКО ОДЕЖДЫ И РЮКЗАКА
-- ============================================================
local function removeClothingOnly(char)
    if clothingRemoved then return end
    
    local shirt = char:FindFirstChild("Shirt")
    if shirt then
        savedClothing.Shirt = shirt
        shirt:Destroy()
        print("👕 Shirt удален")
    end
    
    local pants = char:FindFirstChild("Pants")
    if pants then
        savedClothing.Pants = pants
        pants:Destroy()
        print("👖 Pants удалены")
    end
    
    local backpack = char:FindFirstChild("Backpack")
    if backpack then
        savedClothing.Backpack = backpack
        backpack:Destroy()
        print("🎒 Рюкзак удален")
    end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            local isClothing = false
            
            if child:FindFirstChild("Handle") then
                local handle = child.Handle
                for _, att in ipairs(handle:GetChildren()) do
                    if att:IsA("Attachment") then
                        local name = att.Name:lower()
                        if name:find("shirt") or name:find("pants") or name:find("cloth") then
                            isClothing = true
                            break
                        end
                    end
                end
            end
            
            local nameLower = child.Name:lower()
            if nameLower:find("shirt") or nameLower:find("pants") or nameLower:find("cloth") or nameLower:find("jacket") then
                isClothing = true
            end
            
            if isClothing then
                table.insert(savedClothing, child)
                child:Destroy()
                print("👕 Аксессуар-одежда удален: " .. child.Name)
            end
        end
    end
    
    clothingRemoved = true
    print("✅ Одежда и рюкзак удалены!")
end

-- ============================================================
--   ФУНКЦИЯ ВОССТАНОВЛЕНИЯ ОДЕЖДЫ
-- ============================================================
local function restoreClothing()
    clothingRemoved = false
    savedClothing = {}
    print("🔄 Одежда будет восстановлена при следующем респавне")
end

-- ============================================================
--   ФУНКЦИЯ УДАЛЕНИЯ ОДЕЖДЫ (ОТДЕЛЬНАЯ КНОПКА)
-- ============================================================
local function removeClothingOnlyManual(char)
    local shirt = char:FindFirstChild("Shirt")
    if shirt then
        shirt:Destroy()
        print("👕 Shirt удален")
    end
    
    local pants = char:FindFirstChild("Pants")
    if pants then
        pants:Destroy()
        print("👖 Pants удалены")
    end
    
    local backpack = char:FindFirstChild("Backpack")
    if backpack then
        backpack:Destroy()
        print("🎒 Рюкзак удален")
    end
    
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") then
            local isClothing = false
            
            if child:FindFirstChild("Handle") then
                local handle = child.Handle
                for _, att in ipairs(handle:GetChildren()) do
                    if att:IsA("Attachment") then
                        local name = att.Name:lower()
                        if name:find("shirt") or name:find("pants") or name:find("cloth") then
                            isClothing = true
                            break
                        end
                    end
                end
            end
            
            local nameLower = child.Name:lower()
            if nameLower:find("shirt") or nameLower:find("pants") or nameLower:find("cloth") or nameLower:find("jacket") then
                isClothing = true
            end
            
            if isClothing then
                child:Destroy()
                print("👕 Аксессуар-одежда удален: " .. child.Name)
            end
        end
    end
    
    clothingRemoved = true
    print("✅ Одежда и рюкзак удалены (вручную)!")
end

-- ============================================================
--   ФУНКЦИЯ ОБНОВЛЕНИЯ РАЗМЕРОВ МЕШЕЙ
-- ============================================================
local function updateMeshSizes()
    if not meshesAdded then return end
    if not torso or not torso.Parent then return end
    
    local char = torso.Parent
    
    -- Обновляем грудь
    for _, name in ipairs({"RightBoob", "LeftBoob"}) do
        local part = char:FindFirstChild(name)
        if part then
            part.Size = Vector3.new(1.5 * (boobSize/0.6), 1.4 * (boobSize/0.6), 1.2 * (boobSize/0.6))
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.Scale = Vector3.new(boobSize, boobSize * 0.97, boobSize * 0.97)
            end
        end
    end
    
    -- Обновляем ягодицы
    for _, name in ipairs({"RightAss", "LeftAss"}) do
        local part = char:FindFirstChild(name)
        if part then
            part.Size = Vector3.new(1.4 * (assSize/1.1), 1.0 * (assSize/1.1), 0.8 * (assSize/1.1))
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.Scale = Vector3.new(assSize, assSize * 0.82, assSize * 0.82)
            end
        end
    end
end

-- ============================================================
--   ФУНКЦИЯ СОЗДАНИЯ МЕША
-- ============================================================
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

-- ============================================================
--   ФУНКЦИЯ ПРИВЯЗКИ ЧЕРЕЗ WELD
-- ============================================================
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

-- ============================================================
--   ФУНКЦИЯ ДОБАВЛЕНИЯ МЕШЕЙ (ЖЕНСКИЙ R6)
--   ОСТРАЯ СТОРОНА МЕША СМОТРИТ ВВЕРХ
-- ============================================================
local function addMeshesFemaleR6()
    -- Удаляем старые меши
    for _, p in ipairs(physicsParts) do
        p:Destroy()
    end
    physicsParts = {}
    
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    local char = player.Character
    if not char then
        print("❌ Персонаж не найден!")
        return false
    end
    
    removeClothingOnly(char)
    
    torso = char:FindFirstChild("Torso")
    if not torso then
        torso = char:FindFirstChild("UpperTorso")
    end
    
    if not torso then
        print("❌ Торс не найден!")
        return false
    end
    
    local color = torso.BrickColor
    
    -- Позиции для R6
    local boobPos = Vector3.new(0.55, 0.25, -0.9)
    local assPos = Vector3.new(0.45, -0.7, 0.5)
    
    -- ============================================================
    --   ПОВОРОТЫ ДЛЯ ГРУДИ (ОСТРАЯ СТОРОНА ВВЕРХ)
    -- ============================================================
    local boobRotation = CFrame.Angles(
        math.rad(-90),
        math.rad(-15),
        math.rad(0)
    )
    
    local boobRotationLeft = CFrame.Angles(
        math.rad(-90),
        math.rad(15),
        math.rad(0)
    )
    
    -- ============================================================
    --   ПОВОРОТЫ ДЛЯ ЯГОДИЦ (ОСТРАЯ СТОРОНА ВВЕРХ)
    -- ============================================================
    local assRotation = CFrame.Angles(
        math.rad(-90),
        math.rad(-10),
        math.rad(0)
    )
    
    local assRotationLeft = CFrame.Angles(
        math.rad(-90),
        math.rad(10),
        math.rad(0)
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
    print("✅ Меши (Женский R6) добавлены! (" .. #physicsParts .. " штук)")
    print("⬆️ Острая сторона мешей смотрит вверх!")
    return true
end

-- ============================================================
--   ФУНКЦИЯ УДАЛЕНИЯ МЕШЕЙ
-- ============================================================
local function removeMeshesAndRestore()
    for _, p in ipairs(physicsParts) do
        p:Destroy()
    end
    physicsParts = {}
    
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    
    meshesAdded = false
    clothingRemoved = false
    savedClothing = {}
    print("🗑️ Меши удалены")
end

-- ============================================================
--   СОЗДАНИЕ ГЛАВНОГО GUI (ФИЗИКА)
-- ============================================================
local function createMainGUI()
    if mainGUI then
        mainGUI:Destroy()
        mainGUI = nil
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Parent = player.PlayerGui
    gui.Name = "PhysicsGUI"
    gui.ResetOnSpawn = false
    mainGUI = gui
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 300, 0, 310)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.new(0.3, 0.3, 0.5)
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 2)
    title.Text = "⚡ PHYSICS ⚡ [" .. selectedGender .. " " .. selectedBodyType .. "]"
    title.TextColor3 = Color3.new(1, 0.6, 0.8)
    title.BackgroundTransparency = 1
    title.TextSize = 12
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
    
    -- Главная кнопка (Вкл/Выкл меши)
    local mainBtn = Instance.new("TextButton")
    mainBtn.Parent = frame
    mainBtn.Size = UDim2.new(0.8, 0, 0, 35)
    mainBtn.Position = UDim2.new(0.1, 0, 0, 55)
    mainBtn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
    mainBtn.BorderSizePixel = 0
    mainBtn.Text = "🟢 ВКЛЮЧИТЬ МЕШИ"
    mainBtn.TextColor3 = Color3.new(1, 1, 1)
    mainBtn.TextSize = 13
    mainBtn.Font = Enum.Font.GothamBold
    
    -- Кнопка удаления одежды
    local clothBtn = Instance.new("TextButton")
    clothBtn.Parent = frame
    clothBtn.Size = UDim2.new(0.8, 0, 0, 30)
    clothBtn.Position = UDim2.new(0.1, 0, 0, 95)
    clothBtn.BackgroundColor3 = Color3.new(0.5, 0.2, 0.5)
    clothBtn.BorderSizePixel = 0
    clothBtn.Text = "👕 УДАЛИТЬ ОДЕЖДУ"
    clothBtn.TextColor3 = Color3.new(1, 1, 1)
    clothBtn.TextSize = 12
    clothBtn.Font = Enum.Font.GothamBold
    
    -- ============================================================
    --   ПАНЕЛЬ РАЗМЕРОВ С КНОПКАМИ + И -
    -- ============================================================
    
    -- РАЗДЕЛИТЕЛЬ
    local divider = Instance.new("Frame")
    divider.Parent = frame
    divider.Size = UDim2.new(0.9, 0, 0, 1)
    divider.Position = UDim2.new(0.05, 0, 0, 130)
    divider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
    divider.BorderSizePixel = 0
    
    -- ГРУДЬ
    local boobLabel = Instance.new("TextLabel")
    boobLabel.Parent = frame
    boobLabel.Size = UDim2.new(0.5, 0, 0, 20)
    boobLabel.Position = UDim2.new(0.05, 0, 0, 138)
    boobLabel.Text = "💗 Грудь: " .. string.format("%.2f", boobSize)
    boobLabel.TextColor3 = Color3.new(1, 0.5, 0.7)
    boobLabel.BackgroundTransparency = 1
    boobLabel.TextSize = 12
    boobLabel.Font = Enum.Font.GothamBold
    boobLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка - (грудь)
    local boobMinus = Instance.new("TextButton")
    boobMinus.Parent = frame
    boobMinus.Size = UDim2.new(0.08, 0, 0, 22)
    boobMinus.Position = UDim2.new(0.6, 0, 0, 137)
    boobMinus.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    boobMinus.BorderSizePixel = 0
    boobMinus.Text = "−"
    boobMinus.TextColor3 = Color3.new(1, 1, 1)
    boobMinus.TextSize = 18
    boobMinus.Font = Enum.Font.GothamBold
    
    -- Кнопка + (грудь)
    local boobPlus = Instance.new("TextButton")
    boobPlus.Parent = frame
    boobPlus.Size = UDim2.new(0.08, 0, 0, 22)
    boobPlus.Position = UDim2.new(0.7, 0, 0, 137)
    boobPlus.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    boobPlus.BorderSizePixel = 0
    boobPlus.Text = "+"
    boobPlus.TextColor3 = Color3.new(1, 1, 1)
    boobPlus.TextSize = 18
    boobPlus.Font = Enum.Font.GothamBold
    
    -- Значение груди (отображение)
    local boobValue = Instance.new("TextLabel")
    boobValue.Parent = frame
    boobValue.Size = UDim2.new(0.08, 0, 0, 20)
    boobValue.Position = UDim2.new(0.85, 0, 0, 138)
    boobValue.Text = string.format("%.2f", boobSize)
    boobValue.TextColor3 = Color3.new(1, 1, 1)
    boobValue.BackgroundTransparency = 1
    boobValue.TextSize = 12
    boobValue.Font = Enum.Font.GothamBold
    boobValue.TextXAlignment = Enum.TextXAlignment.Right
    
    -- ЯГОДИЦЫ
    local assLabel = Instance.new("TextLabel")
    assLabel.Parent = frame
    assLabel.Size = UDim2.new(0.5, 0, 0, 20)
    assLabel.Position = UDim2.new(0.05, 0, 0, 165)
    assLabel.Text = "🍑 Ягодицы: " .. string.format("%.2f", assSize)
    assLabel.TextColor3 = Color3.new(0.5, 0.7, 1)
    assLabel.BackgroundTransparency = 1
    assLabel.TextSize = 12
    assLabel.Font = Enum.Font.GothamBold
    assLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Кнопка - (ягодицы)
    local assMinus = Instance.new("TextButton")
    assMinus.Parent = frame
    assMinus.Size = UDim2.new(0.08, 0, 0, 22)
    assMinus.Position = UDim2.new(0.6, 0, 0, 164)
    assMinus.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    assMinus.BorderSizePixel = 0
    assMinus.Text = "−"
    assMinus.TextColor3 = Color3.new(1, 1, 1)
    assMinus.TextSize = 18
    assMinus.Font = Enum.Font.GothamBold
    
    -- Кнопка + (ягодицы)
    local assPlus = Instance.new("TextButton")
    assPlus.Parent = frame
    assPlus.Size = UDim2.new(0.08, 0, 0, 22)
    assPlus.Position = UDim2.new(0.7, 0, 0, 164)
    assPlus.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
    assPlus.BorderSizePixel = 0
    assPlus.Text = "+"
    assPlus.TextColor3 = Color3.new(1, 1, 1)
    assPlus.TextSize = 18
    assPlus.Font = Enum.Font.GothamBold
    
    -- Значение ягодиц (отображение)
    local assValue = Instance.new("TextLabel")
    assValue.Parent = frame
    assValue.Size = UDim2.new(0.08, 0, 0, 20)
    assValue.Position = UDim2.new(0.85, 0, 0, 165)
    assValue.Text = string.format("%.2f", assSize)
    assValue.TextColor3 = Color3.new(1, 1, 1)
    assValue.BackgroundTransparency = 1
    assValue.TextSize = 12
    assValue.Font = Enum.Font.GothamBold
    assValue.TextXAlignment = Enum.TextXAlignment.Right
    
    -- ============================================================
    --   КНОПКА НАЗАД
    -- ============================================================
    local backBtn = Instance.new("TextButton")
    backBtn.Parent = frame
    backBtn.Size = UDim2.new(0.3, 0, 0, 20)
    backBtn.Position = UDim2.new(0.35, 0, 0, 195)
    backBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
    backBtn.BorderSizePixel = 0
    backBtn.Text = "⬅ НАЗАД"
    backBtn.TextColor3 = Color3.new(1, 1, 1)
    backBtn.TextSize = 10
    backBtn.Font = Enum.Font.GothamBold
    
    -- Инфо
    local info = Instance.new("TextLabel")
    info.Parent = frame
    info.Size = UDim2.new(1, 0, 0, 50)
    info.Position = UDim2.new(0, 0, 0, 225)
    info.Text = "💗 Грудь: 0.60 - 0.95\n🍑 Ягодицы: 0.50 - 1.00\n⬆️ Острая сторона мешей ВВЕРХ"
    info.TextColor3 = Color3.new(0.8, 0.8, 0.9)
    info.BackgroundTransparency = 
