-- Автоматический запуск
spawn(function()
    task.wait(1) -- Ждем загрузки персонажа
    
    local players = game:GetService("Players")
    local owner = "xrutru"
    local player = players:FindFirstChild(owner)
    if not player then return end
    
    local character = player.Character
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
    end
    
    -- Ждем пока персонаж полностью загрузится
    task.wait(0.5)
    
    -- Функция создания части с мешем
    local function createMeshPart(name, parent, cframe, size, meshId, meshScale, torsoColor)
        local part = Instance.new("Part")
        part.Name = name
        part.Parent = parent
        part.CFrame = cframe
        part.Size = size
        part.BrickColor = torsoColor or BrickColor.new("Medium stone grey")
        part.CanCollide = false
        part.Locked = false
        part.Material = Enum.Material.SmoothPlastic
        part.Anchored = false
        
        if meshId then
            local mesh = Instance.new("SpecialMesh")
            mesh.Parent = part
            mesh.MeshId = meshId
            mesh.Scale = meshScale or Vector3.new(1, 1, 1)
            mesh.MeshType = Enum.MeshType.FileMesh
        end
        return part
    end
    
    -- Находим торс персонажа
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not torso then 
        warn("Torso not found!")
        return 
    end
    
    local torsoColor = torso.BrickColor
    
    -- Параметры позиционирования
    local boobOffset = Vector3.new(0.4, 0.3, -0.8)  -- спереди
    local assOffset = Vector3.new(0.4, -0.6, 0.6)   -- сзади и ниже
    
    -- Создаем части
    local rightBoob = createMeshPart("RightBoob", character, 
        torso.CFrame * CFrame.new(boobOffset.X, boobOffset.Y, boobOffset.Z), 
        Vector3.new(1.344, 1.36, 1.104), "rbxassetid://7135906486", 
        Vector3.new(0.56, 0.568, 0.568), torsoColor)
    
    local leftBoob = createMeshPart("LeftBoob", character, 
        torso.CFrame * CFrame.new(-boobOffset.X, boobOffset.Y, boobOffset.Z), 
        Vector3.new(1.36, 1.376, 1.12), "rbxassetid://7135906486", 
        Vector3.new(0.568, 0.576, 0.576), torsoColor)
    
    local rightAss = createMeshPart("RightAss", character, 
        torso.CFrame * CFrame.new(assOffset.X, assOffset.Y, assOffset.Z), 
        Vector3.new(1.2, 0.8, 0.6), "rbxassetid://7135906486", 
        Vector3.new(1, 0.8, 0.8), torsoColor)
    
    local leftAss = createMeshPart("LeftAss", character, 
        torso.CFrame * CFrame.new(-assOffset.X, assOffset.Y, assOffset.Z), 
        Vector3.new(1.2, 0.8, 0.6), "rbxassetid://7135906486", 
        Vector3.new(1, 0.8, 0.8), torsoColor)
    
    -- Функция привязки через SpringConstraint
    local function attachWithSpring(part, torso, isAss)
        local offset = torso.CFrame:Inverse() * part.CFrame.Position
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
        spring.Stiffness = isAss and 80 or 50
        spring.Damping = isAss and 15 or 10
        spring.MaxForce = 2000
        spring.LimitsEnabled = true
        spring.MinLength = 0.2
        spring.MaxLength = isAss and 1.2 or 1.5
        
        local hinge = Instance.new("HingeConstraint")
        hinge.Parent = part
        hinge.Attachment0 = att0
        hinge.Attachment1 = att1
        hinge.LimitsEnabled = true
        hinge.MinAngle = -40
        hinge.MaxAngle = 40
        hinge.Axis = Vector3.new(0, 1, 0)
        
        return spring
    end
    
    -- Привязываем части
    attachWithSpring(rightBoob, torso, false)
    attachWithSpring(leftBoob, torso, false)
    attachWithSpring(rightAss, torso, true)
    attachWithSpring(leftAss, torso, true)
    
    -- Следим за изменением цвета торса
    torso:GetPropertyChangedSignal("BrickColor"):Connect(function()
        local newColor = torso.BrickColor
        local parts = {"RightBoob", "LeftBoob", "RightAss", "LeftAss"}
        for _, name in ipairs(parts) do
            local part = character:FindFirstChild(name)
            if part then
                part.BrickColor = newColor
            end
        end
    end)
    
    -- ============================================================
    --   GUI УПРАВЛЕНИЯ
    -- ============================================================
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.Name = "PhysicsGUI"
    
    -- Панель 1: Физика
    local panel1 = Instance.new("Frame")
    panel1.Parent = gui
    panel1.Size = UDim2.new(0, 180, 0, 80)
    panel1.Position = UDim2.new(0, 10, 0, 10)
    panel1.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    panel1.BackgroundTransparency = 0.3
    panel1.BorderSizePixel = 0
    
    local function createSlider(parent, yPos, labelText, minVal, maxVal, defaultValue, callback)
        local frame = Instance.new("Frame")
        frame.Parent = parent
        frame.Size = UDim2.new(1, -20, 0, 20)
        frame.Position = UDim2.new(0, 10, 0, yPos)
        frame.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
        
        local label = Instance.new("TextLabel")
        label.Parent = frame
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Text = labelText .. ": " .. tostring(defaultValue)
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.TextSize = 11
        
        local bar = Instance.new("Frame")
        bar.Parent = frame
        bar.Size = UDim2.new((defaultValue - minVal) / (maxVal - minVal), 0, 1, 0)
        bar.Position = UDim2.new(0.5, 0, 0, 0)
        bar.BackgroundColor3 = Color3.new(0, 0.8, 0.5)
        bar.BorderSizePixel = 0
        
        local button = Instance.new("TextButton")
        button.Parent = frame
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Text = ""
        button.BackgroundTransparency = 1
        
        button.MouseButton1Down:Connect(function()
            local startX = button.AbsolutePosition.X
            local endX = startX + button.AbsoluteSize.X
            local dragConn, upConn
            dragConn = game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((input.Position.X - startX) / (endX - startX), 0, 1)
                    bar.Size = UDim2.new(percent, 0, 1, 0)
                    local val = minVal + percent * (maxVal - minVal)
                    label.Text = labelText .. ": " .. math.floor(val)
                    if callback then callback(val) end
                end
            end)
            upConn = game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragConn:Disconnect()
                    upConn:Disconnect()
                end
            end)
        end)
    end
    
    -- Слайдеры управления физикой
    local bounceForce = 30
    local dampingForce = 8
    
    createSlider(panel1, 25, "Bounce", 10, 100, 30, function(val)
        bounceForce = val
    end)
    createSlider(panel1, 50, "Damping", 2, 30, 8, function(val)
        dampingForce = val
    end)
    
    -- Панель 2: Размеры мешей
    local panel2 = Instance.new("Frame")
    panel2.Parent = gui
    panel2.Size = UDim2.new(0, 200, 0, 180)
    panel2.Position = UDim2.new(0, 10, 0, 100)
    panel2.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    panel2.BackgroundTransparency = 0.3
    panel2.BorderSizePixel = 0
    
    local yOff = 25
    local partsList = {"RightBoob", "LeftBoob", "RightAss", "LeftAss"}
    
    for _, pName in ipairs(partsList) do
        local label = Instance.new("TextLabel")
        label.Parent = panel2
        label.Size = UDim2.new(1, 0, 0, 16)
        label.Position = UDim2.new(0, 0, 0, yOff)
        label.Text = pName
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.TextSize = 11
        yOff = yOff + 16
        
        local part = character:FindFirstChild(pName)
        local mesh = part and part:FindFirstChildOfClass("SpecialMesh")
        
        if part and mesh then
            local frame = Instance.new("Frame")
            frame.Parent = panel2
            frame.Size = UDim2.new(1, -20, 0, 16)
            frame.Position = UDim2.new(0, 10, 0, yOff)
            frame.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
            
            local label2 = Instance.new("TextLabel")
            label2.Parent = frame
            label2.Size = UDim2.new(0.3, 0, 1, 0)
            label2.Text = "Scale"
            label2.TextColor3 = Color3.new(1, 1, 1)
            label2.BackgroundTransparency = 1
            label2.TextSize = 10
            
            local bar = Instance.new("Frame")
            bar.Parent = frame
            bar.Size = UDim2.new(0.5, 0, 1, 0)
            bar.Position = UDim2.new(0.3, 0, 0, 0)
            bar.BackgroundColor3 = Color3.new(0.3, 0.6, 1)
            bar.BorderSizePixel = 0
            
            local button = Instance.new("TextButton")
            button.Parent = frame
            button.Size = UDim2.new(1, 0, 1, 0)
            button.Text = ""
            button.BackgroundTransparency = 1
            
            local currentScale = mesh.Scale.X
            bar.Size = UDim2.new(0.3 + (currentScale / 3) * 0.7, 0, 1, 0)
            
            button.MouseButton1Down:Connect(function()
                local startX = button.AbsolutePosition.X
                local endX = startX + button.AbsoluteSize.X
                local dragConn, upConn
                dragConn = game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = math.clamp((input.Position.X - startX) / (endX - startX), 0, 1)
                        bar.Size = UDim2.new(0.3 + percent * 0.7, 0, 1, 0)
                        local newScale = 0.4 + percent * 2.6
                        mesh.Scale = Vector3.new(newScale, newScale, newScale)
                        part.Size = Vector3.new(newScale * 1.2, newScale * 1.2, newScale * 1.2)
                    end
                end)
                upConn = game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragConn:Disconnect()
                        upConn:Disconnect()
                    end
                end)
            end)
            yOff = yOff + 20
        end
    end
    
    -- Обновление при респавне
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        -- Можно добавить повторное создание мешей
    end)
    
    print("Меши добавлены к персонажу " .. player.Name)
end)
