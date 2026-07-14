-- Ryzen Universal R6 Skinner (Delta Optimized)
task.wait(1)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Функция для изоляции скриптов (песочница)
function sandbox(var, func)
    local env = getfenv(func)
    local newenv = setmetatable({}, {
        __index = function(self, k)
            if k == "script" then
                return var
            else
                return env[k]
            end
        end
    })
    setfenv(func, newenv)
    return func
end

local cors = {} -- таблица для корутин
local mas = Instance.new("Model", game:GetService("Lighting"))

-- Получаем текущего персонажа игрока
local character = player.Character
if not character then
    player.CharacterAdded:Wait()
    character = player.Character
end

-- Создаём новую модель (кастомный персонаж)
local Model0 = Instance.new("Model")
Model0.Name = player.Name
Model0.Parent = mas

-- Создаём Humanoid
local Humanoid1 = Instance.new("Humanoid")
Humanoid1.Parent = Model0
Humanoid1.HipHeight = 0.3
Humanoid1.DisplayName = player.DisplayName

-- Создаём базовые части для R6 (обязательные)
local Part6 = Instance.new("Part") -- HumanoidRootPart
Part6.Name = "HumanoidRootPart"
Part6.Parent = Model0
Part6.Size = Vector3.new(2, 2, 1)
Part6.Transparency = 1
Part6.CanCollide = false
Part6.Locked = true
Part6.Position = Vector3.new(0, 3.335, 0)
Part6.Anchored = false

local Part9 = Instance.new("Part") -- Torso
Part9.Name = "Torso"
Part9.Parent = Model0
Part9.Size = Vector3.new(2, 2, 1)
Part9.BrickColor = BrickColor.new("Silver")
Part9.CanCollide = false
Part9.Locked = true
Part9.Position = Vector3.new(0, 3.335, 0)

local Part20 = Instance.new("Part") -- Head
Part20.Name = "Head"
Part20.Parent = Model0
Part20.Size = Vector3.new(2, 1, 1)
Part20.BrickColor = BrickColor.new("Silver")
Part20.CanCollide = false
Part20.Locked = true
Part20.Position = Vector3.new(0, 4.835, 0)

-- Добавляем лицо
local Decal22 = Instance.new("Decal")
Decal22.Name = "face"
Decal22.Parent = Part20
Decal22.Texture = "rbxasset://textures/face.png"

local Part23 = Instance.new("Part") -- Right Arm
Part23.Name = "Right Arm"
Part23.Parent = Model0
Part23.Size = Vector3.new(1, 2, 1)
Part23.BrickColor = BrickColor.new("Silver")
Part23.CanCollide = false
Part23.Locked = true
Part23.Position = Vector3.new(1.5, 3.335, 0)

local Part28 = Instance.new("Part") -- Left Arm
Part28.Name = "Left Arm"
Part28.Parent = Model0
Part28.Size = Vector3.new(1, 2, 1)
Part28.BrickColor = BrickColor.new("Silver")
Part28.CanCollide = false
Part28.Locked = true
Part28.Position = Vector3.new(-1.5, 3.335, 0)

local Part24 = Instance.new("Part") -- Right Leg
Part24.Name = "Right Leg"
Part24.Parent = Model0
Part24.Size = Vector3.new(1, 2, 1)
Part24.BrickColor = BrickColor.new("Silver")
Part24.CanCollide = false
Part24.Locked = true
Part24.Position = Vector3.new(0.5, 1.335, 0)

local Part26 = Instance.new("Part") -- Left Leg
Part26.Name = "Left Leg"
Part26.Parent = Model0
Part26.Size = Vector3.new(1, 2, 1)
Part26.BrickColor = BrickColor.new("Silver")
Part26.CanCollide = false
Part26.Locked = true
Part26.Position = Vector3.new(-0.5, 1.335, 0)

-- Устанавливаем связи для Humanoid
Humanoid1.Torso = Part9
Humanoid1.LeftLeg = Part26
Humanoid1.RightLeg = Part24
Model0.PrimaryPart = Part6

-- Создаём Motor6D для соединения частей
local function createMotor(parent, part0, part1, c0, c1, name)
    local motor = Instance.new("Motor6D")
    motor.Name = name or "Motor"
    motor.Parent = parent
    motor.Part0 = part0
    motor.Part1 = part1
    motor.C0 = c0 or CFrame.new()
    motor.C1 = c1 or CFrame.new()
    return motor
end

-- Соединяем корпус с торсом
createMotor(Part6, Part6, Part9, CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, 0, 0), "RootJoint")

-- Соединяем торс с остальными частями
createMotor(Part9, Part9, Part23, CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(-0.5, 0.5, 0), "Right Shoulder")
createMotor(Part9, Part9, Part28, CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(0.5, 0.5, 0), "Left Shoulder")
createMotor(Part9, Part9, Part24, CFrame.new(1, -1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), CFrame.new(0.5, 1, 0), "Right Hip")
createMotor(Part9, Part9, Part26, CFrame.new(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), CFrame.new(-0.5, 1, 0), "Left Hip")
createMotor(Part9, Part9, Part20, CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0), CFrame.new(0, -0.5, 0), "Neck")

-- Копируем позицию оригинального персонажа
local rootPart = character:FindFirstChild("HumanoidRootPart")
if rootPart then
    Part6.CFrame = rootPart.CFrame
end

-- Уничтожаем старого персонажа
character:Destroy()

-- Назначаем нового
player.Character = Model0

-- Загружаем анимации через Animate скрипт (упрощённая версия)
local Script52 = Instance.new("Script")
Script52.Name = "Animate"
Script52.Parent = Model0

table.insert(cors, sandbox(Script52, function()
    local Figure = Model0
    local Humanoid = Figure:WaitForChild("Humanoid")
    local Torso = Figure:WaitForChild("Torso")
    
    local function playAnim(id, speed)
        local anim = Instance.new("Animation")
        anim.AnimationId = id
        local track = Humanoid:LoadAnimation(anim)
        track:Play()
        if speed then track:AdjustSpeed(speed) end
        return track
    end
    
    local currentTrack = nil
    
    Humanoid.Running:Connect(function(speed)
        if currentTrack then currentTrack:Stop() end
        if speed > 0.1 then
            currentTrack = playAnim("http://www.roblox.com/asset/?id=180426354", speed / 14.5)
        else
            currentTrack = playAnim("http://www.roblox.com/asset/?id=180435571")
        end
    end)
    
    Humanoid.Jumping:Connect(function()
        if currentTrack then currentTrack:Stop() end
        currentTrack = playAnim("http://www.roblox.com/asset/?id=125750702")
    end)
end))

-- Загружаем внешность скина
local Script73 = Instance.new("Script")
Script73.Name = "LoadCharacterAppearance"
Script73.Parent = Model0

table.insert(cors, sandbox(Script73, function()
    local Players = game:GetService("Players")
    local plr = nil
    local char = Model0
    
    repeat
        task.wait()
        plr = Players:GetPlayerFromCharacter(char)
    until plr
    
    local hDesc = nil
    for retry = 1, 10 do
        local success, result = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(plr.UserId)
        end)
        if success then
            hDesc = result
            break
        else
            task.wait(retry / 2)
        end
    end
    
    local hum = nil
    repeat
        task.wait()
        hum = char:FindFirstChildOfClass("Humanoid")
    until hum and hum.RootPart
    
    if hDesc then
        pcall(function()
            hum:ApplyDescription(hDesc)
        end)
    end
end))

-- Переносим всё в рабочее пространство
for i, v in pairs(mas:GetChildren()) do
    v.Parent = workspace
    pcall(function() v:MakeJoints() end)
end
mas:Destroy()

-- Запускаем все скрипты
for i, v in pairs(cors) do
    spawn(function()
        pcall(v)
    end)
end

task.wait(0.1)

-- Дополнительный вызов (если требуется в среде Delta)
-- require(15627085040).RAroblox(player.Name)

print("Ryzen: Персонаж успешно заменён на R6 с сохранением скина!")
