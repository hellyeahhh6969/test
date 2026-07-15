-- Delta Optimized Script (RYZEN v2) - FULL PHYSICS + DUAL GUI
-- Добавляет физику тканей + отдельное GUI для настройки физики

task.wait(2)

local Players = game:GetService("Players")
local owner = "xrutru"
local player = Players:FindFirstChild(owner)

if not player then
    warn("Игрок не найден!")
    return
end

local character = player.Character
if not character then
    repeat task.wait() until player.Character
    character = player.Character
end

repeat task.wait() until character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")

print("✅ Персонаж найден!")

local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
if not torso then
    warn("Торс не найден!")
    return
end

-- Удаляем старые части если есть
for _, part in ipairs(character:GetChildren()) do
    if part:IsA("BasePart") and (part.Name == "LeftBoob" or part.Name == "Rightboob" or 
       part.Name == "Breast" or part.Name == "LeftAss" or part.Name == "RightAss") then
        part:Destroy()
    end
end

local function createPhysicsPart(name, meshId, scale, offset, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(1.5, 1.5, 1.2)
    part.Shape = Enum.PartType.Ball
    part.Material = Enum.Material.SmoothPlastic
    part.Color = color or torso.Color
    part.BrickColor = torso.BrickColor
    part.CanCollide = false
    part.Anchored = false
    part.Locked = false
    part.CustomPhysicalProperties = PhysicalProperties.new(0.6, 0.2, 0.5, 0.4, 0.6)
    part.Transparency = 0.02
    part.Parent = character
    
    local mesh = Instance.new("SpecialMesh")
    mesh.Parent = part
    mesh.MeshId = meshId
    mesh.Scale = scale
    mesh.MeshType = Enum.MeshType.FileMesh
    
    -- Weld для базовой фиксации
    local weld = Instance.new("Weld")
    weld.Parent = part
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(offset)
    weld.Enabled = true
    
    -- SpringConstraint для физики поверх Welds
    local att0 = Instance.new("Attachment")
    att0.Parent = torso
    att0.Position = offset
    
    local att1 = Instance.new("Attachment")
    att1.Parent = part
    att1.Position = Vector3.new(0, 0, 0)
    
    local spring = Instance.new("SpringConstraint")
    spring.Parent = part
    spring.Attachment0 = att0
    spring.Attachment1 = att1
    spring.Stiffness = 80
    spring.Damping = 15
    spring.MaxForce = 2000
    spring.FreeLength = 0.1
    
    return part, mesh, weld, spring
end

-- Создаем части с физикой
local leftBoob, _, leftWeld, leftSpring = createPhysicsPart("LeftBoob", "rbxassetid://7135906486", 
    Vector3.new(0.71, 0.72, 0.72), Vector3.new(-0.52, 0.17, -0.97))
local rightBoob, _, rightWeld, rightSpring = createPhysicsPart("Rightboob", "rbxassetid://7135906486", 
    Vector3.new(0.70, 0.71, 0.71), Vector3.new(0.52, 0.17, -0.96))
local breast, _, breastWeld, breastSpring = createPhysicsPart("Breast", "rbxassetid://7606070501", 
    Vector3.new(1.66, 1.57, 1.34), Vector3.new(-0.01, 0.18, -1))
breast.Transparency = 0.05

local leftAss, _, leftAssWeld, leftAssSpring = createPhysicsPart("LeftAss", "rbxassetid://9051039280", 
    Vector3.new(255.3, 248.74, 247.76), Vector3.new(-0.66, -1.33, 0.4))
local rightAss, _, rightAssWeld, rightAssSpring = createPhysicsPart("RightAss", "rbxassetid://9051039280", 
    Vector3.new(260.72, 251.3, 249.44), Vector3.new(0.56, -1.31, 0.4))

print("✅ Части созданы!")

-- Синхронизация цвета
local function syncColors()
    local color = torso.Color
    for _, part in ipairs({leftBoob, rightBoob, breast, leftAss, rightAss}) do
        if part and part.Parent then
            part.Color = color
            part.BrickColor = torso.BrickColor
        end
    end
end

torso:GetPropertyChangedSignal("Color"):Connect(syncColors)
torso:GetPropertyChangedSignal("BrickColor"):Connect(syncColors)
syncColors()

-- ============================================================
-- ОСНОВНОЙ GUI (BODY SCALER)
-- ============================================================

task.wait(0.5)

local gui = Instance.new("ScreenGui")
gui.Name = "BodyScalerGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 320)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 160)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
title.Text = "⚡ BODY SCALER ⚡"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -28, 0, 3)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 80, 80)
close.TextScaled = true
close.Font = Enum.Font.GothamBold
close.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
close.BorderSizePixel = 1
close.BorderColor3 = Color3.fromRGB(200, 60, 60)
close.Parent = mainFrame
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Кнопка для открытия физики
local physicsBtn = Instance.new("TextButton")
physicsBtn.Size = UDim2.new(0.6, 0, 0, 25)
physicsBtn.Position = UDim2.new(0.2, 0, 0, 30)
physicsBtn.Text = "⚙️ Физика"
physicsBtn.TextColor3 = Color3.fromRGB(100, 255, 200)
physicsBtn.TextScaled = true
physicsBtn.Font = Enum.Font.GothamBold
physicsBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
physicsBtn.BorderSizePixel = 1
physicsBtn.BorderColor3 = Color3.fromRGB(80, 200, 180)
physicsBtn.Parent = mainFrame

local partsData = {
    {name = "LeftBoob", label = "◄ Грудь", part = leftBoob},
    {name = "Rightboob", label = "Грудь ►", part = rightBoob},
    {name = "LeftAss", label = "◄ Ягодица", part = leftAss},
    {name = "RightAss", label = "Ягодица ►", part = rightAss}
}

local yPos = 60
local rowHeight = 50
local baseScales = {}

for _, data in ipairs(partsData) do
    local mesh = data.part:FindFirstChildOfClass("SpecialMesh")
    if mesh then
        baseScales[data.name] = mesh.Scale
    end
end

for _, data in ipairs(partsData) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, rowHeight)
    row.Position = UDim2.new(0, 5, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    row.BackgroundTransparency = 0.4
    row.BorderSizePixel = 0
    row.Parent = mainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 0, 20)
    label.Position = UDim2.new(0.03, 0, 0.1, 0)
    label.Text = data.label
    label.TextColor3 = Color3.fromRGB(200, 200, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamMedium
    label.BackgroundTransparency = 1
    label.Parent = row
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.35, 0, 0.1, 0)
    valueLabel.Text = "1.00x"
    valueLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = row
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.3, 0, 0, 4)
    slider.Position = UDim2.new(0.58, 0, 0.45, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    slider.BorderSizePixel = 0
    slider.Parent = row
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 22, 0, 22)
    minus.Position = UDim2.new(0.02, 0, 0.05, 0)
    minus.Text = "−"
    minus.TextColor3 = Color3.fromRGB(255, 100, 100)
    minus.TextScaled = true
    minus.Font = Enum.Font.GothamBold
    minus.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
    minus.BorderSizePixel = 1
    minus.BorderColor3 = Color3.fromRGB(150, 60, 60)
    minus.Parent = row
    
    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 22, 0, 22)
    plus.Position = UDim2.new(0.92, 0, 0.05, 0)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(100, 255, 100)
    plus.TextScaled = true
    plus.Font = Enum.Font.GothamBold
    plus.BackgroundColor3 = Color3.fromRGB(25, 40, 25)
    plus.BorderSizePixel = 1
    plus.BorderColor3 = Color3.fromRGB(60, 150, 60)
    plus.Parent = row
    
    local currentScale = 1.0
    local mesh = data.part:FindFirstChildOfClass("SpecialMesh")
    
    local function setScale(newScale)
        if not mesh then return end
        currentScale = math.clamp(newScale, 0.1, 5.0)
        local fillSize = (currentScale - 0.1) / 4.9
        fill.Size = UDim2.new(fillSize, 0, 1, 0)
        valueLabel.Text = string.format("%.2fx", currentScale)
        
        local base = baseScales[data.name] or Vector3.new(1, 1, 1)
        mesh.Scale = Vector3.new(base.X * currentScale, base.Y * currentScale, base.Z * currentScale)
    end
    
    minus.MouseButton1Click:Connect(function() setScale(currentScale - 0.1) end)
    plus.MouseButton1Click:Connect(function() setScale(currentScale + 0.1) end)
    
    yPos = yPos + rowHeight + 3
end

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.5, 0, 0, 28)
resetBtn.Position = UDim2.new(0.25, 0, 0, yPos + 5)
resetBtn.Text = "↺ Сброс"
resetBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
resetBtn.TextScaled = true
resetBtn.Font = Enum.Font.GothamBold
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 25)
resetBtn.BorderSizePixel = 1
resetBtn.BorderColor3 = Color3.fromRGB(150, 120, 50)
resetBtn.Parent = mainFrame

resetBtn.MouseButton1Click:Connect(function()
    for _, data in ipairs(partsData) do
        local mesh = data.part:FindFirstChildOfClass("SpecialMesh")
        local base = baseScales[data.name]
        if mesh and base then
            mesh.Scale = base
        end
    end
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "" and child:FindFirstChild("ValueLabel") then
            child.ValueLabel.Text = "1.00x"
            local sliderFill = child:FindFirstChild("Fill")
            if sliderFill then
                sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            end
        end
    end
end)

-- ============================================================
-- GUI НАСТРОЙКИ ФИЗИКИ
-- ============================================================

local physicsGui = Instance.new("ScreenGui")
physicsGui.Name = "PhysicsGUI"
physicsGui.ResetOnSpawn = false
physicsGui.Parent = player:WaitForChild("PlayerGui")
physicsGui.Enabled = false -- Скрыт по умолчанию

local physicsFrame = Instance.new("Frame")
physicsFrame.Size = UDim2.new(0, 280, 0, 340)
physicsFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
physicsFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 30)
physicsFrame.BackgroundTransparency = 0.1
physicsFrame.BorderSizePixel = 1
physicsFrame.BorderColor3 = Color3.fromRGB(80, 200, 200)
physicsFrame.Active = true
physicsFrame.Draggable = true
physicsFrame.Parent = physicsGui

local physicsTitle = Instance.new("TextLabel")
physicsTitle.Size = UDim2.new(1, 0, 0, 30)
physicsTitle.BackgroundColor3 = Color3.fromRGB(30, 60, 70)
physicsTitle.Text = "⚡ НАСТРОЙКИ ФИЗИКИ ⚡"
physicsTitle.TextColor3 = Color3.fromRGB(100, 255, 200)
physicsTitle.TextScaled = true
physicsTitle.Font = Enum.Font.GothamBold
physicsTitle.Parent = physicsFrame

local physicsClose = Instance.new("TextButton")
physicsClose.Size = UDim2.new(0, 25, 0, 25)
physicsClose.Position = UDim2.new(1, -28, 0, 3)
physicsClose.Text = "✕"
physicsClose.TextColor3 = Color3.fromRGB(255, 80, 80)
physicsClose.TextScaled = true
physicsClose.Font = Enum.Font.GothamBold
physicsClose.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
physicsClose.BorderSizePixel = 1
physicsClose.BorderColor3 = Color3.fromRGB(200, 60, 60)
physicsClose.Parent = physicsFrame
physicsClose.MouseButton1Click:Connect(function()
    physicsGui.Enabled = false
end)

-- Кнопка назад
local backBtn = Instance.new("TextButton")
backBtn.Size = UDim2.new(0.2, 0, 0, 25)
backBtn.Position = UDim2.new(0.02, 0, 0, 30)
backBtn.Text = "◄"
backBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
backBtn.TextScaled = true
backBtn.Font = Enum.Font.GothamBold
backBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
backBtn.BorderSizePixel = 1
backBtn.BorderColor3 = Color3.fromRGB(100, 100, 150)
backBtn.Parent = physicsFrame
backBtn.MouseButton1Click:Connect(function()
    physicsGui.Enabled = false
end)

-- Открытие GUI физики
physicsBtn.MouseButton1Click:Connect(function()
    physicsGui.Enabled = true
    physicsGui.Parent = player:WaitForChild("PlayerGui")
end)

local physicsY = 60
local physicsParts = {
    {name = "LeftBoob", label = "Грудь Л", spring = leftSpring},
    {name = "Rightboob", label = "Грудь П", spring = rightSpring},
    {name = "Breast", label = "Центр", spring = breastSpring},
    {name = "LeftAss", label = "Ягодица Л", spring = leftAssSpring},
    {name = "RightAss", label = "Ягодица П", spring = rightAssSpring}
}

-- Сохраняем значения для сброса
local defaultPhysics = {}
for _, data in ipairs(physicsParts) do
    local s = data.spring
    defaultPhysics[data.name] = {
        stiffness = s.Stiffness,
        damping = s.Damping,
        maxForce = s.MaxForce,
        freeLength = s.FreeLength
    }
end

-- Жесткость
local stiffnessRow = Instance.new("Frame")
stiffnessRow.Size = UDim2.new(1, -10, 0, 40)
stiffnessRow.Position = UDim2.new(0, 5, 0, physicsY)
stiffnessRow.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
stiffnessRow.BackgroundTransparency = 0.4
stiffnessRow.BorderSizePixel = 0
stiffnessRow.Parent = physicsFrame

local stiffLabel = Instance.new("TextLabel")
stiffLabel.Size = UDim2.new(0.35, 0, 0, 20)
stiffLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
stiffLabel.Text = "Жесткость"
stiffLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
stiffLabel.TextScaled = true
stiffLabel.Font = Enum.Font.GothamMedium
stiffLabel.BackgroundTransparency = 1
stiffLabel.Parent = stiffnessRow

local stiffValue = Instance.new("TextLabel")
stiffValue.Size = UDim2.new(0.2, 0, 0, 20)
stiffValue.Position = UDim2.new(0.38, 0, 0.1, 0)
stiffValue.Text = "80"
stiffValue.TextColor3 = Color3.fromRGB(100, 255, 255)
stiffValue.TextScaled = true
stiffValue.Font = Enum.Font.GothamBold
stiffValue.BackgroundTransparency = 1
stiffValue.Parent = stiffnessRow

local stiffSlider = Instance.new("Frame")
stiffSlider.Size = UDim2.new(0.35, 0, 0, 4)
stiffSlider.Position = UDim2.new(0.58, 0, 0.45, 0)
stiffSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
stiffSlider.BorderSizePixel = 0
stiffSlider.Parent = stiffnessRow

local stiffFill = Instance.new("Frame")
stiffFill.Size = UDim2.new(0.5, 0, 1, 0)
stiffFill.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
stiffFill.BorderSizePixel = 0
stiffFill.Parent = stiffSlider

local stiffMinus = Instance.new("TextButton")
stiffMinus.Size = UDim2.new(0, 20, 0, 20)
stiffMinus.Position = UDim2.new(0.02, 0, 0.05, 0)
stiffMinus.Text = "−"
stiffMinus.TextColor3 = Color3.fromRGB(255, 100, 100)
stiffMinus.TextScaled = true
stiffMinus.Font = Enum.Font.GothamBold
stiffMinus.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
stiffMinus.BorderSizePixel = 1
stiffMinus.BorderColor3 = Color3.fromRGB(150, 60, 60)
stiffMinus.Parent = stiffnessRow

local stiffPlus = Instance.new("TextButton")
stiffPlus.Size = UDim2.new(0, 20, 0, 20)
stiffPlus.Position = UDim2.new(0.92, 0, 0.05, 0)
stiffPlus.Text = "+"
stiffPlus.TextColor3 = Color3.fromRGB(100, 255, 100)
stiffPlus.TextScaled = true
stiffPlus.Font = Enum.Font.GothamBold
stiffPlus.BackgroundColor3 = Color3.fromRGB(25, 40, 25)
stiffPlus.BorderSizePixel = 1
stiffPlus.BorderColor3 = Color3.fromRGB(60, 150, 60)
stiffPlus.Parent = stiffnessRow

local currentStiff = 80
local function setStiffness(val)
    currentStiff = math.clamp(val, 10, 300)
    stiffFill.Size = UDim2.new((currentStiff - 10) / 290, 0, 1, 0)
    stiffValue.Text = tostring(math.round(currentStiff))
    for _, data in ipairs(physicsParts) do
        data.spring.Stiffness = currentStiff
    end
end

stiffMinus.MouseButton1Click:Connect(function() setStiffness(currentStiff - 5) end)
stiffPlus.MouseButton1Click:Connect(function() setStiffness(currentStiff + 5) end)

-- Демпфирование
physicsY = physicsY + 45
local dampingRow = Instance.new("Frame")
dampingRow.Size = UDim2.new(1, -10, 0, 40)
dampingRow.Position = UDim2.new(0, 5, 0, physicsY)
dampingRow.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
dampingRow.BackgroundTransparency = 0.4
dampingRow.BorderSizePixel = 0
dampingRow.Parent = physicsFrame

local dampLabel = Instance.new("TextLabel")
dampLabel.Size = UDim2.new(0.35, 0, 0, 20)
dampLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
dampLabel.Text = "Демпфирование"
dampLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
dampLabel.TextScaled = true
dampLabel.Font = Enum.Font.GothamMedium
dampLabel.BackgroundTransparency = 1
dampLabel.Parent = dampingRow

local dampValue = Instance.new("TextLabel")
dampValue.Size = UDim2.new(0.2, 0, 0, 20)
dampValue.Position = UDim2.new(0.38, 0, 0.1, 0)
dampValue.Text = "15"
dampValue.TextColor3 = Color3.fromRGB(255, 200, 100)
dampValue.TextScaled = true
dampValue.Font = Enum.Font.GothamBold
dampValue.BackgroundTransparency = 1
dampValue.Parent = dampingRow

local dampSlider = Instance.new("Frame")
dampSlider.Size = UDim2.new(0.35, 0, 0, 4)
dampSlider.Position = UDim2.new(0.58, 0, 0.45, 0)
dampSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
dampSlider.BorderSizePixel = 0
dampSlider.Parent = dampingRow

local dampFill = Instance.new("Frame")
dampFill.Size = UDim2.new(0.5, 0, 1, 0)
dampFill.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
dampFill.BorderSizePixel = 0
dampFill.Parent = dampSlider

local dampMinus = Instance.new("TextButton")
dampMinus.Size = UDim2.new(0, 20, 0, 20)
dampMinus.Position = UDim2.new(0.02, 0, 0.05, 0)
dampMinus.Text = "−"
dampMinus.TextColor3 = Color3.fromRGB(255, 100, 100)
dampMinus.TextScaled = true
dampMinus.Font = Enum.Font.GothamBold
dampMinus.BackgroundColor3 = Color3.fromRGB(40, 25, 25)
dampMinus.BorderSizePixel = 1
dampMinus.BorderColor3 = Color3.fromRGB(150, 60, 60)
dampMinus.Parent = dampingRow

local dampPlus = Instance.new("TextButton")
dampPlus.Size = UDim2.new(0, 20, 0, 20)
dampPlus.Position = UDim2.new(0.92, 0, 0.05, 0)
dampPlus.Text = "+"
dampPlus.TextColor3 = Color3.fromRGB(100, 255, 100)
dampPlus.TextScaled = true
dampPlus.Font = Enum.Font.GothamBold
dampPlus.BackgroundColor3 = Color3.fromRGB(25, 40, 25)
dampPlus.BorderSizePixel = 1
dampPlus.BorderColor3 = Color3.fromRGB(60, 150, 60)
dampPlus.Parent = dampingRow

local currentDamp = 15
local function setDamping(val)
    currentDamp = math.clamp(val, 1, 50)
    dampFill.Size = UDim2.new((currentDamp - 1) / 49, 0, 1, 0)
    dampValue.Text = tostring(math.round(currentDamp))
    for _, data in ipairs(physicsParts) do
        data.spring.Damping = currentDamp
    end
end

dampMinus.MouseButton1Click:Connect(function() setDamping(currentDamp - 1) end)
dampPlus.MouseButton1Click:Connect(function() setDamping(currentDamp + 1) end)

-- Сила
physicsY = physicsY + 45
local forceRow = Instance.new("Frame")
forceRow.Size = UDim2.new(1, -10, 0, 40)
forceRow.Position = UDim2.new(0, 5, 0, physicsY)
forceRow.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
forceRow.BackgroundTransparency = 0.4
forceRow.BorderSizePixel = 0
forceRow.Parent = physicsFrame

local forceLabel = Instance.new("TextLabel")
forceLabel.Size = UDim2.new(0.35, 0, 0, 20)
forceLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
forceLabel.Text = "Макс. сила"
forceLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
forceLabel.TextScaled = true
forceLabel.Fon
