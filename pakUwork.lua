-- Автоматический запуск
spawn(function()
    task.wait(1)
    
    local players = game:GetService("Players")
    local owner = "xrutru"
    local player = players:FindFirstChild(owner)
    if not player then return end
    
    local character = player.Character
    if not character then
        player.CharacterAdded:Wait()
        character = player.Character
    end
    
    task.wait(0.5)
    
    local physicsParts = {}
    local boobScale = 0.6
    local assScale = 1.1
    local meshesAdded = false
    
    -- ============================================================
    --   ФУНКЦИЯ РАСЧЕТА ПОЗИЦИИ
    -- ============================================================
    local function calculatePosition(baseOffset, currentScale, type)
        local sizeFactor = math.clamp((currentScale - 0.4) / 2.6, 0, 1)
        
        if type == "boob" then
            return Vector3.new(
                baseOffset.X + (sizeFactor * 0.2),
                baseOffset.Y - (sizeFactor * 0.4),
                baseOffset.Z - (sizeFactor * 0.15)
            )
        elseif type == "ass" then
            return Vector3.new(
                baseOffset.X + (sizeFactor * 0.15),
                baseOffset.Y - (sizeFactor * 0.25),
                baseOffset.Z + (sizeFactor * 0.2)
            )
        end
        return baseOffset
    end
    
    -- ============================================================
    --   ФУНКЦИЯ СОЗДАНИЯ МЕША (СКРЫТОГО ДЛЯ ДРУГИХ)
    -- ============================================================
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
        part.Transparency = 0
        part.LocalTransparencyModifier = 0
        
        -- LocalScript для скрытия от других игроков
        local visibilityScript = Instance.new("LocalScript")
        visibilityScript.Parent = part
        visibilityScript.Name = "VisibilityController"
        visibilityScript.Source = [[
            local part = script.Parent
            local player = game:GetService("Players").LocalPlayer
            local owner = "xrutru"
            
            if player.Name ~= owner then
                part.Transparency = 1
                part.LocalTransparencyModifier = 1
                part.CanCollide = false
                for _, child in ipairs(part:GetChildren()) do
                    if child:IsA("Constraint") or child:IsA("Attachment") then
                        child:Destroy()
                    end
                end
            end
        ]]
        
        if meshId then
            local mesh = Instance.new("SpecialMesh")
            mesh.Parent = part
            mesh.MeshId = meshId
            mesh.Scale = meshScale or Vector3.new(1, 1, 1)
            mesh.MeshType = Enum.MeshType.FileMesh
        end
        return part
    end
    
    -- ============================================================
    --   ПРИКРЕПЛЕНИЕ (ГРУДЬ)
    -- ============================================================
    local function attachTopOnlyBoob(part, torso)
        local topOffset = Vector3.new(0, part.Size.Y/2 - 0.1, 0)
        local worldTopPos = part.CFrame * CFrame.new(topOffset)
        local localTopPos = torso.CFrame:Inverse() * worldTopPos.Position
        
        local att0 = Instance.new("Attachment")
        att0.Parent = torso
        att0.Position = localTopPos
        
        local att1 = Instance.new("Attachment")
        att1.Parent = part
        att1.Position = topOffset
        
        local spring = Instance.new("SpringConstraint")
        spring.Parent = part
        spring.Attachment0 = att0
        spring.Attachment1 = att1
        spring.Stiffness = 30
        spring.Damping = 10
        spring.MaxForce = 1500
        spring.LimitsEnabled = true
        spring.MinLength = 0.05
        spring.MaxLength = 1.8
        
        local hinge = Instance.new("HingeConstraint")
        hinge.Parent = part
        hinge.Attachment0 = att0
        hinge.Attachment1 = att1
        hinge.LimitsEnabled = true
        hinge.MinAngle = -35
        hinge.MaxAngle = 35
        hinge.Axis = Vector3.new(1, 0, 0)
        
        local hinge2 = Instance.new("HingeConstraint")
        hinge2.Parent = part
        hinge2.Attachment0 = att0
        hinge2.Attachment1 = att1
        hinge2.LimitsEnabled = true
        hinge2.MinAngle = -15
        hinge2.MaxAngle = 15
        hinge2.Axis = Vector3.new(0, 0, 1)
        
        return spring
    end
    
    -- ============================================================
    --   ПРИКРЕПЛЕНИЕ (ЯГОДИЦЫ)
    -- ============================================================
    local function attachTopOnlyAss(part, torso)
        local topOffset = Vector3.new(0, part.Size.Y/2 - 0.05, 0)
        local worldTopPos = part.CFrame * CFrame.new(topOffset)
        local localTopPos = torso.CFrame:Inverse() * worldTopPos.Position
        
        local att0 = Instance.new("Attachment")
        att0.Parent = torso
        att0.Position = localTopPos
        
        local att1 = Instance.new("Attachment")
        att1.Parent = part
        att1.Position = topOffset
        
        local spring = Instance.new("SpringConstraint")
        spring.Parent = part
        spring.Attachment0 = att0
        spring.Attachment1 = att1
        spring.Stiffness = 55
        spring.Damping = 16
        spring.MaxForce = 2500
        spring.LimitsEnabled = true
        spring.MinLength = 0.05
        spring.MaxLength = 1.2
        
        local hinge = Instance.new("HingeConstraint")
        hinge.Parent = part
        hinge.Attachment0 = att0
        hinge.Attachment1 = att1
        hinge.LimitsEnabled = true
        hinge.MinAngle = -35
        hinge.MaxAngle = 35
        hinge.Axis = Vector3.new(1, 0, 0)
        
        local hinge2 = Instance.new("HingeConstraint")
        hinge2.Parent = part
        hinge2.Attachment0 = att0
        hinge2.Attachment1 = att1
        hinge2.LimitsEnabled = true
        hinge2.MinAngle = -25
        hinge2.MaxAngle = 25
        hinge2.Axis = Vector3.new(0, 0, 1)
        
        local spring2 = Instance.new("SpringConstraint")
        spring2.Parent = part
        spring2.Attachment0 = att0
        spring2.Attachment1 = att1
        spring2.Stiffness = 35
        spring2.Damping = 12
        spring2.MaxForce = 1500
        spring2.LimitsEnabled = true
        spring2.MinLength = 0.1
        spring2.MaxLength = 1.0
        
        return spring
    end
    
    -- ============================================================
    --   ФУНКЦИЯ СОЗДАНИЯ ВСЕХ МЕШЕЙ
    -- ============================================================
    local function createAllMeshes(char)
        -- Очищаем старые меши
        for _, part in ipairs(physicsParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        physicsParts = {}
        
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not torso then 
            warn("Torso not found!")
            return false
        end
        
        local torsoColor = torso.BrickColor
        
        local boobBaseOffset = Vector3.new(0.55, 0.25, -0.9)
        local assBaseOffset = Vector3.new(0.45, -0.7, 0.5)
        
        local boobPos = calculatePosition(boobBaseOffset, boobScale, "boob")
        local assPos = calculatePosition(assBaseOffset, assScale, "ass")
        
        -- ГРУДЬ ПРАВАЯ
        local rightBoob = createMeshPart("RightBoob", char, 
            torso.CFrame * CFrame.new(boobPos.X, boobPos.Y, boobPos.Z), 
            Vector3.new(1.5 * (boobScale/0.6), 1.4 * (boobScale/0.6), 1.2 * (boobScale/0.6)), 
            "rbxassetid://7135906486", 
            Vector3.new(boobScale, boobScale * 0.97, boobScale * 0.97), torsoColor)
        table.insert(physicsParts, rightBoob)
        
        -- ГРУДЬ ЛЕВАЯ
        local leftBoob = createMeshPart("LeftBoob", char, 
            torso.CFrame * CFrame.new(-boobPos.X, boobPos.Y, boobPos.Z), 
            Vector3.new(1.5 * (boobScale/0.6), 1.4 * (boobScale/0.6), 1.2 * (boobScale/0.6)), 
            "rbxassetid://7135906486", 
            Vector3.new(boobScale, boobScale * 0.97, boobScale * 0.97), torsoColor)
        table.insert(physicsParts, leftBoob)
        
        -- ЯГОДИЦА ПРАВАЯ
        local rightAss = createMeshPart("RightAss", char, 
            torso.CFrame * CFrame.new(assPos.X, assPos.Y, assPos.Z), 
            Vector3.new(1.4 * (assScale/1.1), 1.0 * (assScale/1.1), 0.8 * (assScale/1.1)), 
            "rbxassetid://7135906486", 
            Vector3.new(assScale, assScale * 0.82, assScale * 0.82), torsoColor)
        table.insert(physicsParts, rightAss)
        
        -- ЯГОДИЦА ЛЕВАЯ
        local leftAss = createMeshPart("LeftAss", char, 
            torso.CFrame * CFrame.new(-assPos.X, assPos.Y, assPos.Z), 
            Vector3.new(1.4 * (assScale/1.1), 1.0 * (assScale/1.1), 0.8 * (assScale/1.1)), 
            "rbxassetid://7135906486", 
            Vector3.new(assScale, assScale * 0.82, assScale * 0.82), torsoColor)
        table.insert(physicsParts, leftAss)
        
        -- ПРИКРЕПЛЕНИЕ
        attachTopOnlyBoob(rightBoob, torso)
        attachTopOnlyBoob(leftBoob, torso)
        attachTopOnlyAss(rightAss, torso)
        attachTopOnlyAss(leftAss, torso)
        
        -- ОБНОВЛЕНИЕ ЦВЕТА
        torso:GetPropertyChangedSignal("BrickColor"):Connect(function()
            local newColor = torso.BrickColor
            for _, part in ipairs(physicsParts) do
                if part and part.Parent then
                    part.BrickColor = newColor
                end
            end
        end)
        
        meshesAdded = true
        return true
    end
    
    -- ============================================================
    --   ФУНКЦИЯ УДАЛЕНИЯ МЕШЕЙ
    -- ============================================================
    local function removeAllMeshes()
        for _, part in ipairs(physicsParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        physicsParts = {}
        meshesAdded = false
        print("🗑️ Меши удалены")
    end
    
    -- ============================================================
    --   СОЗДАНИЕ GUI С КНОПКОЙ
    -- ============================================================
    local function createGUI(ply)
        local gui = Instance.new("ScreenGui")
        gui.Parent = ply:WaitForChild("PlayerGui")
        gui.Name = "PhysicsGUI"
        gui.ResetOnSpawn = false
        
        -- ГЛАВНАЯ ПАНЕЛЬ
        local mainPanel = Instance.new("Frame")
        mainPanel.Parent = gui
        mainPanel.Size = UDim2.new(0, 280, 0, 230)
        mainPanel.Position = UDim2.new(0, 10, 0, 10)
        mainPanel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
        mainPanel.BackgroundTransparency = 0.15
        mainPanel.BorderSizePixel = 1
        mainPanel.BorderColor3 = Color3.new(0.3, 0.3, 0.5)
        
        -- ЗАГОЛОВОК
        local title = Instance.new("TextLabel")
        title.Parent = mainPanel
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.Text = "⚡ PHYSICS CONTROLS ⚡"
        title.TextColor3 = Color3.new(1, 0.6, 0.8)
        title.BackgroundTransparency = 1
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        
        -- РАЗДЕЛИТЕЛЬ
        local divider = Instance.new("Frame")
        divider.Parent = mainPanel
        divider.Size = UDim2.new(0.9, 0, 0, 1)
        divider.Position = UDim2.new(0.05, 0, 0, 30)
        divider.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
        divider.BorderSizePixel = 0
        
        -- ============================================================
        --   КНОПКА ДОБАВЛЕНИЯ МЕШЕЙ
        -- ============================================================
        local addButton = Instance.new("TextButton")
        addButton.Parent = mainPanel
        addButton.Size = UDim2.new(0.8, 0, 0, 30)
        addButton.Position = UDim2.new(0.1, 0, 0, 35)
        addButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
        addButton.BorderSizePixel = 0
        addButton.Text = "➕ ДОБАВИТЬ МЕШИ"
        addButton.TextColor3 = Color3.new(1, 1, 1)
        addButton.TextSize = 13
        addButton.Font = Enum.Font.GothamBold
        
        -- Кнопка удаления мешей
        local removeButton = Instance.new("TextButton")
        removeButton.Parent = mainPanel
        removeButton.Size = UDim2.new(0.8, 0, 0, 30)
        removeButton.Position = UDim2.new(0.1, 0, 0, 70)
        removeButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
        removeButton.BorderSizePixel = 0
        removeButton.Text = "🗑️ УДАЛИТЬ МЕШИ"
        removeButton.TextColor3 = Color3.new(1, 1, 1)
        removeButton.TextSize = 13
        removeButton.Font = Enum.Font.GothamBold
        
        -- СТАТУС
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Parent = mainPanel
        statusLabel.Size = UDim2.new(1, 0, 0, 20)
        statusLabel.Position = UDim2.new(0, 0, 0, 105)
        statusLabel.Text = "📌 Статус: Меши не добавлены"
        statusLabel.TextColor3 = Color3.new(1, 0.6, 0.4)
        statusLabel.BackgroundTransparency = 1
        statusLabel.TextSize = 11
        statusLabel.Font = Enum.Font.GothamMedium
        statusLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        -- ============================================================
        --   ВИЗУАЛЬНЫЙ СЛАЙДЕР (ГРУДЬ)
        -- ============================================================
        local function createVisualSlider(parent, yPos, labelText, icon, color, minVal, maxVal, defaultValue, callback)
            local frame = Instance.new("Frame")
            frame.Parent = parent
            frame.Size = UDim2.new(1, -20, 0, 45)
            frame.Position = UDim2.new(0, 10, 0, yPos)
            frame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
            frame.BorderSizePixel = 0
            
            local label = Instance.new("TextLabel")
            label.Parent = frame
            label.Size = UDim2.new(1, 0, 0, 16)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.Text = icon .. " " .. labelText
            label.TextColor3 = color
            label.BackgroundTransparency = 1
            label.TextSize = 11
            label.Font = Enum.Font.GothamMedium
            label.TextXAlignment = Enum.TextXAlignment.Left
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Parent = frame
            valueLabel.Size = UDim2.new(0.4, 0, 0, 16)
            valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
            valueLabel.Text = string.format("%.2f", defaultValue)
            valueLabel.TextColor3 = Color3.new(1, 1, 1)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextSize = 11
            valueLabel.Font = Enum.Font.GothamMedium
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local barBg = Instance.new("Frame")
            barBg.Parent = frame
            barBg.Size = UDim2.new(1, 0, 0, 5)
            barBg.Position = UDim2.new(0, 0, 0, 20)
            barBg.BackgroundColor3 = Color3.new(0.25, 0.25, 0.3)
            barBg.BorderSizePixel = 0
            
            local barFill = Instance.new("Frame")
            barFill.Parent = barBg
            barFill.Size = UDim2.new((defaultValue - minVal) / (maxVal - minVal), 0, 1, 0)
            barFill.BackgroundColor3 = color
            barFill.BorderSizePixel = 0
            
            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Parent = barBg
            sliderBtn.Size = UDim2.new(0, 12, 0, 12)
            sliderBtn.Position = UDim2.new(barFill.Size.X.Scale - 0.025, 0, -3.5, 0)
            sliderBtn.BackgroundColor3 = color
            sliderBtn.BorderSizePixel = 0
            sliderBtn.Text = ""
            sliderBtn.AutoButtonColor = false
            
            local dragging = false
            sliderBtn.MouseButton1Down:Connect(function()
                dragging = true
                local startX = barBg.AbsolutePosition.X
                local endX = startX + barBg.AbsoluteSize.X
                
                local dragConn = game:GetService("UserInputService").InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                        local percent = math.clamp((input.Position.X - startX) / (endX - startX), 0, 1)
                        barFill.Size = UDim2.new(percent, 0, 1, 0)
                        sliderBtn.Position = UDim2.new(percent - 0.025, 0, -3.5, 0)
                        local val = minVal + percent * (maxVal - minVal)
                        valueLabel.Text = string.format("%.2f", val)
                        callback(val)
                    end
                end)
                
                local upConn = game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        dragConn:Disconnect()
                        upConn:Disconnect()
                    end
                end)
            end)
            
            return frame
        end
        
        -- Слайдер для груди
        createVisualSlider(mainPanel, 130, "Boob Size", "💗", Color3.new(1, 0.3, 0.5), 0.3, 1.5, boobScale, function(val)
            boobScale = val
            if not meshesAdded then return end
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if torso then
                local boobBaseOffset = Vector3.new(0.55, 0.25, -0.9)
                local newPos = calculatePosition(boobBaseOffset, val, "boob")
                
                for _, name in ipairs({"RightBoob", "LeftBoob"}) do
                    local part = character:FindFirstChild(name)
                    if part then
                        part.CFrame = torso.CFrame * CFrame.new(
                            (name == "RightBoob" and newPos.X or -newPos.X),
                            newPos.Y,
                            newPos.Z
                        )
                        local scaleFactor = val / 0.6
                        part.Size = Vector3.new(1.5 * scaleFactor, 1.4 * scaleFactor, 1.2 * scaleFactor)
                        local mesh = part:FindFirstChildOfClass("SpecialMesh")
                        if mesh then
                            mesh.Scale = Vector3.new(val, val * 0.97, val * 0.97)
                        end
                    end
                end
            end
        end)
        
        -- Слайдер для ягодиц
        createVisualSlider(mainPanel, 180, "Ass Size", "🍑", Color3.new(0.3, 0.5, 1), 0.4, 2.0, assScale, function(val)
            assScale = val
            if not meshesAdded then return end
            local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
            if torso then
                local assBaseOffset = Vector3.new(0.45, -0.7, 0.5)
                local newPos = calculatePosition(assBaseOffset, val, "ass")
                
                for _, name in ipairs({"RightAss", "LeftAss"}) do
                    local part = character:FindFirstChild(name)
                    if part then
                        part.CFrame = torso.CFrame * CFrame.new(
                            (name 
