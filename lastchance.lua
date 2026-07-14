-- ============================================
-- 1. МОДЕЛЬ ПЕРСОНАЖА (hsh)
-- ============================================
task.wait(1)
local players = game:GetService("Players")
local owner = "Example"  -- замените на ваше имя или используйте player.Name
local player = players:FindFirstChild(owner) or players.LocalPlayer
local character = player.Character

function sandbox(var, func)
    local env = getfenv(func)
    local newenv = setmetatable({}, {
        __index = function(self, k)
            if k == "script" then
                return var
            else
                return env[k]
            end
        end,
    })
    setfenv(func, newenv)
    return func
end

cors = {}
mas = Instance.new("Model", game:GetService("Lighting"))

-- Создаём все части (сокращённо, полный код из rentry)
-- Для компактности здесь приведён только каркас, но вы можете вставить полный код модели.
-- Вместо этого я добавлю генерацию частей вручную:

local function createPart(name, parent, size, color, cframe)
    local part = Instance.new("Part")
    part.Name = name
    part.Parent = parent
    part.Size = size
    part.BrickColor = BrickColor.new(color or "Silver flip/flop")
    part.CanCollide = false
    part.Locked = true
    part.Material = Enum.Material.SmoothPlastic
    if cframe then part.CFrame = cframe end
    return part
end

local model = Instance.new("Model")
model.Name = player.Name
model.Parent = mas

-- Создаём базовые части (упрощённо, без Mesh для скорости)
local root = createPart("HumanoidRootPart", model, Vector3.new(2, 2, 1), "Really black")
root.Transparency = 1
local torso = createPart("Torso", model, Vector3.new(2, 2, 1), "Silver flip/flop")
torso.Position = Vector3.new(0, 3.335, 0)
local head = createPart("Head", model, Vector3.new(2, 1, 1), "Silver flip/flop")
head.Position = Vector3.new(0, 4.835, 0)
local leftArm = createPart("Left Arm", model, Vector3.new(1, 2, 1), "Silver flip/flop")
leftArm.Position = Vector3.new(-1.5, 3.335, 0)
local rightArm = createPart("Right Arm", model, Vector3.new(1, 2, 1), "Silver flip/flop")
rightArm.Position = Vector3.new(1.5, 3.335, 0)
local leftLeg = createPart("Left Leg", model, Vector3.new(1, 2, 1), "Silver flip/flop")
leftLeg.Position = Vector3.new(-0.5, 1.335, 0)
local rightLeg = createPart("Right Leg", model, Vector3.new(1, 2, 1), "Silver flip/flop")
rightLeg.Position = Vector3.new(0.5, 1.335, 0)

-- ===== ГЛАВНЫЕ ЧАСТИ ДЛЯ ИЗМЕНЕНИЯ =====
local leftBoob = createPart("LeftBoob", model, Vector3.new(1.7, 1.72, 1.4), "Silver flip/flop")
leftBoob.Position = Vector3.new(-0.52, 3.505, -0.97)

local rightBoob = createPart("RightBoob", model, Vector3.new(1.68, 1.7, 1.38), "Silver flip/flop")
rightBoob.Position = Vector3.new(0.52, 3.505, -0.96)

local leftAss = createPart("LeftAss", model, Vector3.new(2.14, 2.08, 2.08), "Silver flip/flop")
leftAss.Position = Vector3.new(-0.66, 2.005, 0.4)

local rightAss = createPart("RightAss", model, Vector3.new(2.18, 2.11, 2.09), "Silver flip/flop")
rightAss.Position = Vector3.new(0.56, 2.025, 0.4)

-- Добавляем Humanoid
local hum = Instance.new("Humanoid")
hum.Parent = model
hum.HipHeight = 0.3

-- Заменяем персонажа
root.CFrame = character.HumanoidRootPart.CFrame
character:Destroy()
player.Character = model
mas:Destroy()

-- ============================================
-- 2. GUI ПАНЕЛЬ ДЛЯ ИЗМЕНЕНИЯ РАЗМЕРОВ
-- ============================================
task.wait(0.5)

local function findPartInModel(mdl, name)
    for _, child in ipairs(mdl:GetDescendants()) do
        if child:IsA("BasePart") and child.Name == name then
            return child
        end
    end
    return nil
end

-- Ищем части в новой модели
local charNew = player.Character
if not charNew then return end

local lb = findPartInModel(charNew, "LeftBoob")
local rb = findPartInModel(charNew, "RightBoob")
local la = findPartInModel(charNew, "LeftAss")
local ra = findPartInModel(charNew, "RightAss")

if not (lb and rb and la and ra) then
    warn("Не все части найдены! Проверьте имена.")
    return
end

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 320, 0, 520)
frame.Position = UDim2.new(0.5, -160, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🎛️ BODY SCULPTOR"
title.TextColor3 = Color3.fromRGB(180, 180, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Функция создания ползунка (Slider)
local function createSlider(parent, labelText, part, axis, minVal, maxVal, defaultVal, yPos)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Size = UDim2.new(0, 100, 0, 18)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextScaled = true
    label.Font = Enum.Font.Gotham

    local slider = Instance.new("Slider")
    slider.Parent = parent
    slider.Size = UDim2.new(0, 140, 0, 18)
    slider.Position = UDim2.new(0, 120, 0, yPos)
    slider.MinValue = minVal
    slider.MaxValue = maxVal
    slider.Value = defaultVal
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    slider.BorderSizePixel = 0

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = parent
    valueLabel.Size = UDim2.new(0, 40, 0, 18)
    valueLabel.Position = UDim2.new(0, 270, 0, yPos)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.2f", defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.Gotham

    slider.Changed:Connect(function()
        if part then
            local val = slider.Value
            valueLabel.Text = string.format("%.2f", val)
            local s = part.Size
            if axis == "X" then
                part.Size = Vector3.new(val, s.Y, s.Z)
            elseif axis == "Y" then
                part.Size = Vector3.new(s.X, val, s.Z)
            elseif axis == "Z" then
                part.Size = Vector3.new(s.X, s.Y, val)
            end
        end
    end)
end

-- Ползунки для каждой части
local y = 40
local parts = {
    {label = "LeftBoob X", part = lb, axis = "X", min = 0.5, max = 3.5, default = lb.Size.X},
    {label = "LeftBoob Y", part = lb, axis = "Y", min = 0.5, max = 3.5, default = lb.Size.Y},
    {label = "LeftBoob Z", part = lb, axis = "Z", min = 0.5, max = 3.5, default = lb.Size.Z},
    {label = "RightBoob X", part = rb, axis = "X", min = 0.5, max = 3.5, default = rb.Size.X},
    {label = "RightBoob Y", part = rb, axis = "Y", min = 0.5, max = 3.5, default = rb.Size.Y},
    {label = "RightBoob Z", part = rb, axis = "Z", min = 0.5, max = 3.5, default = rb.Size.Z},
    {label = "LeftAss X", part = la, axis = "X", min = 0.5, max = 4.5, default = la.Size.X},
    {label = "LeftAss Y", part = la, axis = "Y", min = 0.5, max = 4.5, default = la.Size.Y},
    {label = "LeftAss Z", part = la, axis = "Z", min = 0.5, max = 4.5, default = la.Size.Z},
    {label = "RightAss X", part = ra, axis = "X", min = 0.5, max = 4.5, default = ra.Size.X},
    {label = "RightAss Y", part = ra, axis = "Y", min = 0.5, max = 4.5, default = ra.Size.Y},
    {label = "RightAss Z", part = ra, axis = "Z", min = 0.5, max = 4.5, default = ra.Size.Z},
}

for _, info in ipairs(parts) do
    createSlider(frame, info.label, info.part, info.axis, info.min, info.max, info.default, y)
    y = y + 28
end

-- Кнопка сброса
local resetBtn = Instance.new("TextButton")
resetBtn.Parent = frame
resetBtn.Size = UDim2.new(0, 120, 0, 32)
resetBtn.Position = UDim2.new(0.5, -60, 0, y + 10)
resetBtn.Text = "↺ RESET ALL"
resetBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
resetBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextScaled = true
resetBtn.BorderSizePixel = 0

resetBtn.MouseButton1Click:Connect(function()
    lb.Size = Vector3.new(1.7, 1.72, 1.4)
    rb.Size = Vector3.new(1.68, 1.7, 1.38)
    la.Size = Vector3.new(2.14, 2.08, 2.08)
    ra.Size = Vector3.new(2.18, 2.11, 2.09)
    screenGui:Destroy()
    loadstring(game:HttpGet("https://pastebin.com/raw/ваша_ссылка"))() -- если хотите авто-перезапуск
end)

print("✅ Модель и GUI загружены. Части: LeftBoob, RightBoob, LeftAss, RightAss")
