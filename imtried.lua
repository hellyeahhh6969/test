-- Delta Optimized Script (RYZEN v2) - ADD PHYSICS TO EXISTING CHARACTER
-- Добавляет физику тканей (грудь и ягодицы) на существующего персонажа (R6/R15)
-- БЕЗ создания нового персонажа

task.wait(1)

local Players = game:GetService("Players")
local owner = "xrutru"
local player = Players:FindFirstChild(owner)
if not player then
    warn("Игрок xrutru не найден!")
    return
end

local character = player.Character
if not character then
    repeat task.wait() until player.Character
    character = player.Character
end

-- Ждём полной загрузки персонажа
repeat task.wait() until character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")

print("✅ Персонаж " .. player.Name .. " найден, добавляем физику тканей...")

-- ============================================================
-- ДОБАВЛЕНИЕ ЧАСТЕЙ ТЕЛА С МЕШАМИ И ФИЗИКОЙ
-- ============================================================

local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
if not torso then
    warn("Торс не найден!")
    return
end

-- Функция для создания части с мешем
local function createBodyPart(name, meshId, scale, position, cframeOffset)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(1.7, 1.7, 1.4)
    part.CFrame = torso.CFrame * CFrame.new(position)
    part.Color = torso.Color
    part.BrickColor = torso.BrickColor
    part.Material = Enum.Material.SmoothPlastic
    part.Locked = false
    part.CanCollide = true
    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5, 0.5, 0.5)
    part.Parent = character
    
    -- Создаём меш
    local mesh = Instance.new("SpecialMesh")
    mesh.Parent = part
    mesh.MeshId = meshId
    mesh.Scale = scale
    mesh.MeshType = Enum.MeshType.FileMesh
    
    return part, mesh
end

-- ============================================================
-- ДОБАВЛЯЕМ ГРУДЬ
-- ============================================================

-- Левая грудь
local leftBoobPart, leftBoobMesh = createBodyPart(
    "LeftBoob",
    "rbxassetid://7135906486",
    Vector3.new(0.71, 0.72, 0.72),
    Vector3.new(-0.52, 0.17, -0.97)
)

-- Правая грудь
local rightBoobPart, rightBoobMesh = createBodyPart(
    "Rightboob",
    "rbxassetid://7135906486",
    Vector3.new(0.70, 0.71, 0.71),
    Vector3.new(0.52, 0.17, -0.96)
)

-- Средняя часть груди (для соединения)
local breastPart, breastMesh = createBodyPart(
    "Breast",
    "rbxassetid://7606070501",
    Vector3.new(1.66, 1.57, 1.34),
    Vector3.new(-0.01, 0.18, -1)
)
breastPart.Transparency = 0.02

-- ============================================================
-- ДОБАВЛЯЕМ ЯГОДИЦЫ
-- ============================================================

-- Левая ягодица
local leftAssPart, leftAssMesh = createBodyPart(
    "LeftAss",
    "rbxassetid://9051039280",
    Vector3.new(255.3, 248.74, 247.76),
    Vector3.new(-0.66, -1.33, 0.4)
)

-- Правая ягодица
local rightAssPart, rightAssMesh = createBodyPart(
    "RightAss",
    "rbxassetid://9051039280",
    Vector3.new(260.72, 251.3, 249.44),
    Vector3.new(0.56, -1.31, 0.4)
)

-- ============================================================
-- НАСТРОЙКА ФИЗИКИ (SpringConstraint + BallSocketConstraint)
-- ============================================================

local function setupPhysics(part, torso, offset, stiffness, damping, maxForce)
    -- Крепление на торсе
    local torsoAtt = Instance.new("Attachment")
    torsoAtt.Parent = torso
    torsoAtt.Position = offset
    
    -- Крепление на части
    local partAtt = Instance.new("Attachment")
    partAtt.Parent = part
    partAtt.Position = Vector3.new(0, 0, 0)
    
    -- Пружина
    local spring = Instance.new("SpringConstraint")
    spring.Parent = part
    spring.Attachment0 = torsoAtt
    spring.Attachment1 = partAtt
    spring.Stiffness = stiffness or 50
    spring.Damping = damping or 10
    spring.MaxForce = maxForce or 1000
    spring.FreeLength = 0.3
    
    -- Шарнир для вращения
    local socket = Instance.new("BallSocketConstraint")
    socket.Parent = part
    socket.Attachment0 = torsoAtt
    socket.Attachment1 = partAtt
    socket.LimitsEnabled = true
    socket.TwistLimitsEnabled = true
    socket.UpperAngle = 30
    socket.LowerAngle = -30
    
    return spring, socket
end

-- Применяем физику к каждой части
setupPhysics(leftBoobPart, torso, Vector3.new(-0.52, 0.17, -0.97), 45, 8, 1000)
setupPhysics(rightBoobPart, torso, Vector3.new(0.52, 0.17, -0.96), 45, 8, 1000)
setupPhysics(breastPart, torso, Vector3.new(-0.01, 0.18, -1), 35, 7, 800)
setupPhysics(leftAssPart, torso, Vector3.new(-0.66, -1.33, 0.4), 60, 10, 1200)
setupPhysics(rightAssPart, torso, Vector3.new(0.56, -1.31, 0.4), 60, 10, 1200)

print("✅ Физика тканей добавлена!")

-- ============================================================
-- ПРИВЯЗКА К ТОРСУ (чтобы части двигались с персонажем)
-- ============================================================

-- Создаём привязку через Weld (запасной вариант, если физика не работает)
local function addBackupWeld(part, torso, offset)
    local weld = Instance.new("Weld")
    weld.Parent = part
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(offset)
    weld.Enabled = false -- Выключен, используем только если физика отключена
    return weld
end

addBackupWeld(leftBoobPart, torso, Vector3.new(-0.52, 0.17, -0.97))
addBackupWeld(rightBoobPart, torso, Vector3.new(0.52, 0.17, -0.96))
addBackupWeld(breastPart, torso, Vector3.new(-0.01, 0.18, -1))
addBackupWeld(leftAssPart, torso, Vector3.new(-0.66, -1.33, 0.4))
addBackupWeld(rightAssPart, torso, Vector3.new(0.56, -1.31, 0.4))

print("✅ Привязка добавлена!")

-- ============================================================
-- СИНХРОНИЗАЦИЯ ЦВЕТА С ПЕРСОНАЖЕМ
-- ============================================================

-- Обновляем цвет частей при изменении цвета торса
local function syncColors()
    local color = torso.Color
    for _, part in ipairs({leftBoobPart, rightBoobPart, breastPart, leftAssPart, rightAssPart}) do
        part.Color = color
        part.BrickColor = torso.BrickColor
    end
end

-- Подписываемся на изменение цвета торса
torso:GetPropertyChangedSignal("Color"):Connect(syncColors)
torso:GetPropertyChangedSignal("BrickColor"):Connect(syncColors)

syncColors()

-- ============================================================
-- GUI ДЛЯ НАСТРОЙКИ РАЗМЕРА ЧАСТЕЙ (упрощённый)
-- ============================================================

task.wait(0.5)

local guiService = game:GetService("GuiService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BodyScaler"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 310)
mainFrame.Position = UDim2.new(0.5, -130, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "⚡ BODY SCALER ⚡"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.BackgroundTransparency = 0.3
closeBtn.BorderSizePixel = 1
closeBtn.BorderColor3 = Color3.fromRGB(200, 80, 80)
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local parts = {
    {name = "LeftBoob", label = "◄ грудь", part = leftBoobPart},
    {name = "Rightboob", label = "грудь ►", part = rightBoobPart},
    {name = "LeftAss", label = "◄ ягодица", part = leftAssPart},
    {name = "RightAss", label = "ягодица ►", part = rightAssPart}
}

local yPos = 40
local rowHeight = 60
local baseScales = {}

-- Сохраняем базовые размеры
for _, data in ipairs(parts) do
    local mesh = data.part:FindFirstChildOfClass("SpecialMesh")
    if mesh then
        baseScales[data.name] = mesh.Scale
    end
end

for _, data in ipairs(parts) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, rowHeight)
    row.Position = UDim2.new(0, 5, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    row.BackgroundTransparency = 0.5
    row.BorderSizePixel = 0
    row.Parent = mainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.35, 0, 0, 20)
    label.Position = UDim2.new(0.03, 0, 0.05, 0)
    label.Text = data.label
    label.TextColor3 = Color3.fromRGB(200, 200, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.BackgroundTransparency = 1
    label.Parent = row
    
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0.2, 0, 0, 20)
    value.Position = UDim2.new(0.38, 0, 0.05, 0)
    value.Text = "1.00x"
    value.TextColor3 = Color3.fromRGB(150, 255, 150)
    value.TextScaled = true
    value.Font = Enum.Font.GothamBold
    value.BackgroundTransparency = 1
    value.Parent = row
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.35, 0, 0, 4)
    slider.Position = UDim2.new(0.38, 0, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    slider.BorderSizePixel = 0
    slider.Parent = row
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local function createButton(text, color, xPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 20, 0, 20)
        btn.Position = UDim2.new(xPos, 0, 0.6, -10)
        btn.Text = text
        btn.TextColor3 = color
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(100, 100, 150)
        btn.Parent = row
        return btn
    end
    
    local minusBtn = createButton("−", Color3.fromRGB(255, 100, 100), 0.01)
    local plusBtn = createButton("+", Color3.fromRGB(100, 255, 100), 0.95)
    
    local currentScale = 1.0
    local mesh = data.part:FindFirstChildOfClass("SpecialMesh")
    
    local function setScale(newScale)
        if not mesh then return end
        currentScale = math.clamp(newScale, 0.1, 5.0)
        local fillSize = (currentScale - 0.1) / 4.9
        fill.Size = UDim2.new(fillSize, 0, 1, 0)
        value.Text = string.format("%.2fx", currentScale)
        
        local base = baseScales[data.name] or Vector3.new(1, 1, 1)
        mesh.Scale = Vector3.new(base.X * currentScale, base.Y * currentScale, base.Z * currentScale)
    end
    
    minusBtn.MouseButton1Click:Connect(function() setScale(currentScale - 0.1) end)
    plusBtn.MouseButton1Click:Connect(function() setScale(currentScale + 0.1) end)
    
    value.MouseButton1Click:Connect(function()
        local input = guiService:GetTextInput("Введите множитель", "0.1 - 5.0", "", "")
        local num = tonumber(input)
        if num then setScale(num) end
    end)
    
    yPos = yPos + rowHeight + 5
end

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.7, 0, 0, 30)
resetBtn.Position = UDim2.new(0.15, 0, 0, yPos + 5)
resetBtn.Text = "↺ Сброс"
resetBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamBold
resetBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 30)
resetBtn.BorderSizePixel = 1
resetBtn.BorderColor3 = Color3.fromRGB(150, 120, 50)
resetBtn.Parent = mainFrame

resetBtn.MouseButton1Click:Connect(function()
    for _, data in ipairs(parts) do
        local mesh = data.part:FindFirstChildOfClass("SpecialMesh")
        local base = baseScales[data.name]
        if mesh and base then
            mesh.Scale = base
        end
    end
    -- Обновляем UI
    for _, row in ipairs(mainFrame:GetChildren()) do
        if row:IsA("Frame") and row:FindFirstChild("ValueLabel") then
            row.ValueLabel.Text = "1.00x"
            local sliderFill = row:FindFirstChild("Slider"):FindFirstChild("Fill")
            if sliderFill then
                sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            end
        end
    end
end)

local function onInputBegan(input)
    if input.KeyCode == Enum.KeyCode.Escape then
        screenGui:Destroy()
    end
end
game:GetService("UserInputService").InputBegan:Connect(onInputBegan)

print("✅ GUI загружен! Используйте для настройки размера частей.")
