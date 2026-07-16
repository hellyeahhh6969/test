-- ============================================================
--   СКРИПТ 2: ФИЗИКА И УПРАВЛЕНИЕ РАЗМЕРАМИ (ОБНОВЛЕННЫЙ)
--   С кнопкой сверху для скрытия/показа GUI и перетаскиванием
-- ============================================================

if not _G.selectedGender or not _G.selectedBodyType then
    print("❌ Ошибка! Сначала запустите скрипт выбора пола")
    return
end

local player = _G.player
local character = _G.character

if not player or not character then
    print("❌ Ошибка! Персонаж не найден")
    return
end

print("✅ Загрузка физики для: " .. _G.selectedGender .. " " .. _G.selectedBodyType)

wait(1)

-- ============================================================
--   ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
-- ============================================================
local physicsParts = {}
local meshesAdded = false
local torso = nil
local connections = {}
local boobSize = 0.60
local assSize = 0.50
local clothingRemoved = false
local savedClothing = {}
local guiVisible = true
local dragData = {dragging = false, startPos = nil, startMouse = nil}

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
--   ОПТИМИЗИРОВАННАЯ ФУНКЦИЯ ОБНОВЛЕНИЯ РАЗМЕРОВ
-- ============================================================
local function updateMeshSizes()
    if not meshesAdded then return end
    if not torso or not torso.Parent then return end
    
    local char = torso.Parent
    
    local boobScaleFactor = boobSize / 0.60
    local assScaleFactor = assSize / 0.50
    
    for _, name in ipairs({"RightBoob", "LeftBoob"}) do
        local part = char:FindFirstChild(name)
        if part then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                local newScale = boobSize
                if math.abs(mesh.Scale.X - newScale) > 0.001 then
                    mesh.Scale = Vector3.new(newScale, newScale * 0.97, newScale * 0.97)
                    part.Size = Vector3.new(1.5 * boobScaleFactor, 1.4 * boobScaleFactor, 1.2 * boobScaleFactor)
                end
            end
        end
    end
    
    for _, name in ipairs({"RightAss", "LeftAss"}) do
        local part = char:FindFirstChild(name)
        if part then
            local mesh = part:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                local newScale = assSize
                if math.abs(mesh.Scale.X - newScale) > 0.001 then
                    mesh.Scale = Vector3.new(newScale, newScale * 0.82, newScale * 0.82)
                    part.Size = Vector3.new(1.4 * assScaleFactor, 1.0 * assScaleFactor, 0.8 * assScaleFactor)
                end
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
-- ============================================================
local function addMeshesFemaleR6()
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
    
    local boobPos = Vector3.new(0.55, 0.25, -0.9)
    local assPos = Vector3.new(0.45, -0.7, 0.5)
    
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
    
    local boobBaseSize = Vector3.new(1.5, 1.4, 1.2)
    local boobScaleFactor = boobSize / 0.60
    local boobSizeFinal = boobBaseSize * boobScaleFactor
    local boobMeshScale = Vector3.new(boobSize, boobSize * 0.97, boobSize * 0.97)
    
    local assBaseSize = Vector3.new(1.4, 1.0, 0.8)
    local assScaleFactor = assSize / 0.50
    local assSizeFinal = assBaseSize * assScaleFactor
    local assMeshScale = Vector3.new(assSize, assSize * 0.82, assSize * 0.82)
    
    local rBoob = createPart("RightBoob", char, 
        torso.CFrame * CFrame.new(boobPos.X, boobPos.Y, boobPos.Z) * boobRotation,
        boobSizeFinal,
        "rbxassetid://7135906486",
        boobMeshScale,
        color
    )
    table.insert(physicsParts, rBoob)
    attachWithWeld(rBoob, torso, boobPos, boobRotation)
    
    local lBoob = createPart("LeftBoob", char, 
        torso.CFrame * CFrame.new(-boobPos.X, boobPos.Y, boobPos.Z) * boobRotationLeft,
        boobSizeFinal,
        "rbxassetid://7135906486",
        boobMeshScale,
        color
    )
    table.insert(physicsParts, lBoob)
    attachWithWeld(lBoob, torso, Vector3.new(-boobPos.X, boobPos.Y, boobPos.Z), boobRotationLeft)
    
    local rAss = createPart("RightAss", char, 
        torso.CFrame * CFrame.new(assPos.X, assPos.Y, assPos.Z) * assRotation,
        assSizeFinal,
        "rbxassetid://7135906486",
        assMeshScale,
        color
    )
    table.insert(physicsParts, rAss)
    attachWithWeld(rAss, torso, assPos, assRotation)
    
    local lAss = createPart("LeftAss", char, 
        torso.CFrame * CFrame.new(-assPos.X, assPos.Y, assPos.Z) * assRotationLeft,
        assSizeFinal,
        "rbxassetid://7135906486",
        assMeshScale,
        color
    )
    table.insert(physicsParts, lAss)
    attachWithWeld(lAss, torso, Vector3.new(-assPos.X, assPos.Y, assPos.Z), assRotationLeft)
    
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
--   ФУНКЦИЯ ВОЗВРАТА К ВЫБОРУ ПОЛА
-- ============================================================
local function goBackToGender()
    local curGui = player.PlayerGui:FindFirstChild("PhysicsGUI")
    if curGui then curGui:Destroy() end
    
    local toggleBtn = player.PlayerGui:FindFirstChild("ToggleButton")
    if toggleBtn then toggleBtn:Destroy() end
    
    removeMeshesAndRestore()
    _G.selectedGender = nil
    _G.selectedBodyType = nil
    
    -- Загружаем скрипт 1
    loadstring([[
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        if not player then return end
        
        _G.selectedGender = nil
        _G.selectedBodyType = nil
        _G.player = player
        _G.character = player.Character
        
        if not _G.character then
            _G.character = player.CharacterAdded:Wait()
        end
        
        wait(1)
        
        local function createGenderGUI()
            local oldGui = player.PlayerGui:FindFirstChild("GenderGUI")
            if oldGui then oldGui:Destroy() end
            
            local gui = Instance.new("ScreenGui")
            gui.Parent = player.PlayerGui
            gui.Name = "GenderGUI"
            gui.ResetOnSpawn = false
            
            local frame = Instance.new("Frame")
            frame.Parent = gui
            frame.Size = UDim2.new(0, 300, 0, 170)
            frame.Position = UDim2.new(0.5, -150, 0.5, -85)
            frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
            frame.BackgroundTransparency = 0.05
            frame.BorderSizePixel = 2
            frame.BorderColor3 = Color3.new(0.5, 0.3, 0.7)
            
            local title = Instance.new("TextLabel")
            title.Parent = frame
            title.Size = UDim2.new(1, 0, 0, 40)
            title.Position = UDim2.new(0, 0, 0, 5)
            title.Text = "⚡ ВЫБОР ПЕРСОНАЖА ⚡"
            title.TextColor3 = Color3.new(1, 0.6, 0.8)
            title.BackgroundTransparency = 1
            title.TextSize = 16
            title.Font = Enum.Font.GothamBold
            
            local maleBtn = Instance.new("TextButton")
            maleBtn.Parent = frame
            maleBtn.Size = UDim2.new(0.4, 0, 0, 45)
            maleBtn.Position = UDim2.new(0.05, 0, 0, 55)
            maleBtn.BackgroundColor3 = Color3.new(0.2, 0.3, 0.6)
            maleBtn.BorderSizePixel = 0
            maleBtn.Text = "👨 МУЖСКОЙ"
            maleBtn.TextColor3 = Color3.new(1, 1, 1)
            maleBtn.TextSize = 14
            maleBtn.Font = Enum.Font.GothamBold
            
            local femaleBtn = Instance.new("TextButton")
            femaleBtn.Parent = frame
            femaleBtn.Size = UDim2.new(0.4, 0, 0, 45)
            femaleBtn.Position = UDim2.new(0.55, 0, 0, 55)
            femaleBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.5)
            femaleBtn.BorderSizePixel = 0
            femaleBtn.Text = "👩 ЖЕНСКИЙ"
            femaleBtn.TextColor3 = Color3.new(1, 1, 1)
            femaleBtn.TextSize = 14
            femaleBtn.Font = Enum.Font.GothamBold
            
            local info = Instance.new("TextLabel")
            info.Parent = frame
            info.Size = UDim2.new(1, 0, 0, 20)
            info.Position = UDim2.new(0, 0, 0, 115)
            info.Text = "💡 Выберите пол для продолжения"
            info.TextColor3 = Color3.new(0.6, 0.6, 0.8)
            info.BackgroundTransparency = 1
            info.TextSize = 10
            info.Font = Enum.Font.Gotham
            info.TextXAlignment = Enum.TextXAlignment.Center
            
            local loadingText = Instance.new("TextLabel")
            loadingText.Parent = frame
            loadingText.Size = UDim2.new(1, 0, 0, 20)
            loadingText.Position = UDim2.new(0, 0, 0, 135)
            loadingText.Text = ""
            loadingText.TextColor3 = Color3.new(0.8, 0.8, 0.4)
            loadingText.BackgroundTransparency = 1
            loadingText.TextSize = 11
            loadingText.Font = Enum.Font.Gotham
            loadingText.TextXAlignment = Enum.TextXAlignment.Center
            loadingText.Visible = false
            
            local function loadPhysicsScript()
                maleBtn.Visible = false
                femaleBtn.Visible = false
                info.Text = "⏳ Загрузка..."
                loadingText.Visible = true
                loadingText.Text = "⏳ Пожалуйста, подождите..."
                
                local dots = 0
                local dotTimer = game:GetService("RunService").Heartbeat:Connect(function()
                    dots = (dots + 1) % 4
                    loadingText.Text = "⏳ Пожалуйста, подождите" .. string.rep(".", dots)
                end)
                
                wait(0.8)
                dotTimer:Disconnect()
                
                gui:Destroy()
                _G.selectedGender = "Женский"
                _G.selectedBodyType = "R6"
                
                loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/physics.lua"))()
            end
            
            maleBtn.MouseButton1Click:Connect(function()
                _G.selectedGender = "Мужской"
                info.Text = "👨 Мужской пол выбран"
                wait(0.3)
                gui:Destroy()
                print("👨 Мужской пол активирован")
            end)
            
            femaleBtn.MouseButton1Click:Connect(function()
                _G.selectedGender = "Женский"
                loadPhysicsScript()
            end)
        end
        
        pcall(function()
            createGenderGUI()
        end)
        
        print("👨👩 Выберите пол для продолжения")
    ]])()
    
    print("🔄 Возврат к выбору пола")
end

-- ============================================================
--   ФУНКЦИЯ СОЗДАНИЯ КНОПКИ-ПЕРЕКЛЮЧАТЕЛЯ
-- ============================================================
local function createToggleButton()
    local btnGui = Instance.new("ScreenGui")
    btnGui.Parent = player.PlayerGui
    btnGui.Name = "ToggleButton"
    btnGui.ResetOnSpawn = false
    btnGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local button = Instance.new("TextButton")
    button.Parent = btnGui
    button.Size = UDim2.new(0, 40, 0, 40)
    button.Position = UDim2.new(0.5, -20, 0, 10) -- Сверху по центру
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.new(0.5, 0.3, 0.7)
    button.Text = "⚡"
    button.TextColor3 = Color3.new(1, 0.6, 0.8)
    button.TextSize = 20
    button.Font = Enum.Font.GothamBold
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Name = "ToggleButton"
    
    -- Тень для кнопки
    local shadow = Instance.new("Frame")
    shadow.Parent = button
    shadow.Size = UDim2.new(1, 2, 1, 2)
    shadow.Position = UDim2.new(0, -1, 0, -1)
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.3
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    
    -- Индикатор состояния
    local indicator = Instance.new("Frame")
    indicator.Parent = button
    indicator.Size = UDim2.new(0, 8, 0, 8)
    indicator.Position = UDim2.new(0.7, 0, 0.7, 0)
    indicator.BackgroundColor3 = Color3.new(0, 1, 0)
    indicator.BorderSizePixel = 0
    indicator.Name = "Indicator"
    
    -- ============================================================
    --   ЛОГИКА ПЕРЕТАСКИВАНИЯ
    -- ============================================================
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local userInput = game:GetService("UserInputService")
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
