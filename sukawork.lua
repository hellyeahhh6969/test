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
    local function createMeshPart(name, parent, cframe, size, meshId, meshScale, color)
        local part = Instance.new("Part")
        part.Name = name
        part.Parent = parent
        part.CFrame = cframe
        part.Size = size
        part.BrickColor = BrickColor.new(color or "Silver flip/flop")
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
    
    -- Добавляем меши к персонажу (НЕ заменяя его)
    local rightBoob = createMeshPart("RightBoob", character, torso.CFrame * CFrame.new(0.444, 0.312, -0.789), Vector3.new(1.344, 1.36, 1.104), "rbxassetid://7135906486", Vector3.new(0.56, 0.568, 0.568))
    local leftBoob = createMeshPart("LeftBoob", character, torso.CFrame * CFrame.new(-0.388, 0.312, -0.797), Vector3.new(1.36, 1.376, 1.12), "rbxassetid://7135906486", Vector3.new(0.568, 0.576, 0.576))
    local rightAss = createMeshPart("RightAss", character, torso.CFrame * CFrame.new(0.5, -0.8, -0.8), Vector3.new(1.2, 0.8, 0.6), "rbxassetid://7135906486", Vector3.new(1, 0.8, 0.8))
    local leftAss = createMeshPart("LeftAss", character, torso.CFrame * CFrame.new(-0.5, -0.8, -0.8), Vector3.new(1.2, 0.8, 0.6), "rbxassetid://7135906486", Vector3.new(1, 0.8, 0.8))
    
    -- Прикрепляем меши к торсу через Weld (чтобы они двигались с персонажем)
    local function weldPart(part, parentPart)
        local weld = Instance.new("Weld")
        weld.Part0 = parentPart
        weld.Part1 = part
        weld.C0 = parentPart.CFrame:Inverse() * part.CFrame
        weld.Parent = part
        return weld
    end
    
    weldPart(rightBoob, torso)
    weldPart(leftBoob, torso)
    weldPart(rightAss, torso)
    weldPart(leftAss, torso)
    
    -- ============================================================
    --   ФИЗИКА ДЛЯ МЕШЕЙ (с привязкой к торсу)
    -- ============================================================
    local physicsParts = {rightBoob, leftBoob, rightAss, leftAss}
    local bvList, bgList, lastPos = {}, {}, {}
    
    for _, part in ipairs(physicsParts) do
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = part
        bvList[part] = bv
        
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(4000, 4000, 4000)
        bg.CFrame = part.CFrame
        bg.Parent = part
        bgList[part] = bg
        
        lastPos[part] = part.Position
    end
    
    local bounceForce = 30
    local dampingForce = 8
    
    -- Физический цикл
    coroutine.wrap(function()
        while character and character.Parent do
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then break end
            local rootPos = rootPart.Position
            
            for _, part in ipairs(physicsParts) do
                if part and part.Parent then
                    local offset = part.Position - rootPos
                    local desiredPos = rootPos + offset
                    local displacement = desiredPos - part.Position
                    local force = displacement * bounceForce
                    local vel = (part.Position - lastPos[part]) / 0.05
                    local damping = -vel * dampingForce
                    local targetVel = (force + damping) / part:GetMass()
                    bvList[part].Velocity = targetVel
                    bgList[part].CFrame = CFrame.lookAt(part.Position, part.Position + Vector3.new(0, 1, 0))
                    lastPos[part] = part.Position
                end
            end
            task.wait(0.05)
        end
    end)()
    
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
    
    local function createSlider(parent, yPos, labelText, varRef, minVal, maxVal, defaultValue)
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
                    varRef = val
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
    
    createSlider(panel1, 25, "Bounce", bounceForce, 10, 100, 30)
    createSlider(panel1, 50, "Damping", dampingForce, 2, 30, 8)
    
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
    
    -- Автоматическое обновление при респавне
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        -- Здесь можно добавить повторное создание мешей для нового персонажа
        -- Но для простоты оставляем только первый запуск
    end)
    
    print("Меши добавлены к персонажу " .. player.Name)
end)
