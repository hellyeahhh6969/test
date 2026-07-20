-- script.lua для ForceHack (Delta) — Веточное меню с Main, Survivor и ESP
-- Активация: F7 для открытия/закрытия + кнопка сворачивания на экране

local player = engine.get_local_player()

-- ===== СОСТОЯНИЯ =====
local guiOpen = false
local guiMinimized = false
local currentTab = "main"
local infiniteStaminaEnabled = false
local backstabEnabled = false
local isBackstabRunning = false
local targetTime = 1.5

-- ===== КНОПКА СВОРАЧИВАНИЯ =====
local minimizeButton = {
    x = 10,
    y = 10,
    w = 36,
    h = 36,
    visible = true
}

-- ===== MAIN МОДУЛИ =====
local aspect4x3 = false
local fpsBoost = false
local greySky = false

-- ===== ESP СОСТОЯНИЯ =====
local esp = {
    killer = false,
    minions = false,
    survivor = false,
    items = false,
    generators = false,
    veronica = false,
    traps = false
}

-- ===== МОБИЛЬНАЯ КНОПКА =====
local mobileButton = {
    x = 0, y = 0, w = 80, h = 80,
    dragging = false,
    dragOffsetX = 0, dragOffsetY = 0,
    visible = false,
    radius = 40
}

function initMobileButton()
    local screenW, screenH = engine.get_screen_size()
    mobileButton.x = screenW - 100
    mobileButton.y = screenH - 120
end

function isOnMobileButton(x, y)
    if not mobileButton.visible then return false end
    local cx = mobileButton.x + mobileButton.w / 2
    local cy = mobileButton.y + mobileButton.h / 2
    local dx = x - cx
    local dy = y - cy
    return (dx * dx + dy * dy) <= (mobileButton.radius * mobileButton.radius)
end

function drawMobileButton()
    if not mobileButton.visible then return end
    local cx = mobileButton.x + mobileButton.w / 2
    local cy = mobileButton.y + mobileButton.h / 2
    
    engine.draw_circle(cx + 3, cy + 3, mobileButton.radius, {0, 0, 0, 150})
    local color = backstabEnabled and {0, 200, 255, 220} or {100, 100, 100, 200}
    engine.draw_circle(cx, cy, mobileButton.radius, color)
    engine.draw_circle_outline(cx, cy, mobileButton.radius, {255, 255, 255, 180}, 2)
    engine.draw_text(cx - 12, cy - 8, "🔪", {255, 255, 255, 255}, 28)
    
    if backstabEnabled then
        engine.draw_text(cx - 20, cy + mobileButton.radius + 5, "BACKSTAB", {0, 255, 255, 200}, 12)
    else
        engine.draw_text(cx - 25, cy + mobileButton.radius + 5, "OFF", {255, 100, 100, 200}, 12)
    end
end

-- ===== КНОПКА СВОРАЧИВАНИЯ =====
function drawMinimizeButton()
    if not minimizeButton.visible then return end
    
    local x = minimizeButton.x
    local y = minimizeButton.y
    local w = minimizeButton.w
    local h = minimizeButton.h
    
    -- Фон
    local color = guiMinimized and {0, 200, 80, 220} or {60, 60, 80, 220}
    engine.draw_rect(x, y, w, h, color)
    engine.draw_rect_outline(x, y, w, h, {255, 255, 255, 120}, 1)
    
    -- Иконка
    if guiMinimized then
        -- Развернуть (квадрат с плюсом или стрелка вверх)
        engine.draw_rect(x + 8, y + 14, 20, 4, {255, 255, 255, 255})
        engine.draw_rect(x + 18, y + 4, 4, 20, {255, 255, 255, 255})
    else
        -- Свернуть (стрелка вниз или минус)
        engine.draw_rect(x + 8, y + 16, 20, 4, {255, 255, 255, 255})
    end
    
    -- Подпись
    engine.draw_text(x + 2, y + h + 4, "MENU", {200, 200, 200, 150}, 8)
end

function isOnMinimizeButton(x, y)
    if not minimizeButton.visible then return false end
    return x >= minimizeButton.x and x <= minimizeButton.x + minimizeButton.w and
           y >= minimizeButton.y and y <= minimizeButton.y + minimizeButton.h
end

-- ===== ВЕТКИ МЕНЮ =====
function drawTabs(panelX, panelY, panelW)
    local tabs = {
        {id = "main", icon = "🏠", label = "Main", x = 10},
        {id = "survivor", icon = "🛡️", label = "Survivor", x = 90},
        {id = "esp", icon = "👁️", label = "ESP", x = 175}
    }
    
    local tabW = 65
    local tabH = 35
    local yOff = 10
    
    for _, tab in ipairs(tabs) do
        local color = currentTab == tab.id and {0, 200, 255, 220} or {60, 60, 70, 200}
        engine.draw_rect(panelX + tab.x, panelY + yOff, tabW, tabH, color)
        engine.draw_rect_outline(panelX + tab.x, panelY + yOff, tabW, tabH, {255, 255, 255, 100}, 1)
        engine.draw_text(panelX + tab.x + 20, panelY + yOff + 5, tab.icon, {255, 255, 255, 255}, 16)
        engine.draw_text(panelX + tab.x + 10, panelY + yOff + 24, tab.label, {200, 200, 200, 200}, 9)
    end
    
    return tabs[#tabs].x + tabW, tabH, yOff
end

-- ===== ПОЛЗУНОК =====
function drawToggle(contentX, contentY, width, height, state, label, yOff)
    local x = contentX
    local y = contentY + yOff
    local w = width
    local h = height
    local toggleW = 50
    local toggleH = 24
    local toggleX = x + w - toggleW - 10
    local toggleY = y + (h - toggleH) / 2
    
    local bgColor = state and {0, 200, 80, 200} or {60, 60, 70, 200}
    engine.draw_rect(x, y, w, h, bgColor)
    engine.draw_rect_outline(x, y, w, h, {255, 255, 255, 80}, 1)
    
    local textColor = state and {0, 255, 100, 255} or {200, 200, 200, 200}
    engine.draw_text(x + 10, y + (h - 14) / 2, label, textColor, 12)
    engine.draw_text(x + w - 70, y + (h - 14) / 2, state and "ON" or "OFF", state and {0, 255, 100, 255} or {200, 80, 80, 255}, 11)
    
    local sliderColor = state and {0, 200, 80, 220} or {150, 150, 150, 200}
    engine.draw_rect(toggleX, toggleY, toggleW, toggleH, {40, 40, 50, 200})
    engine.draw_rect_outline(toggleX, toggleY, toggleW, toggleH, {255, 255, 255, 60}, 1)
    
    local knobX = state and (toggleX + toggleW - 20) or toggleX
    engine.draw_circle(knobX + 10, toggleY + toggleH / 2, 9, sliderColor)
    engine.draw_circle_outline(knobX + 10, toggleY + toggleH / 2, 9, {255, 255, 255, 150}, 1)
    
    return toggleX, toggleY, toggleW, toggleH
end

-- ===== MAIN ФУНКЦИИ =====
function applyAspect4x3()
    if aspect4x3 then
        engine.set_aspect_ratio(4/3)
        engine.execute_cmd("screensize 4:3")
        print("[Ryzen] 4:3 режим включен")
    else
        engine.set_aspect_ratio(16/9)
        engine.execute_cmd("screensize default")
        print("[Ryzen] 4:3 режим выключен")
    end
end

function applyFPSBoost()
    if fpsBoost then
        engine.set_float("graphics.texture_quality", 0.1)
        engine.set_float("graphics.shadow_quality", 0.0)
        engine.set_float("graphics.particle_quality", 0.0)
        engine.set_float("graphics.post_processing", 0.0)
        engine.set_float("fog.enabled", 0.0)
        engine.set_float("fog.density", 0.0)
        engine.set_float("graphics.brightness", 1.5)
        engine.set_float("graphics.gamma", 1.3)
        engine.set_float("graphics.view_distance", 0.5)
        print("[Ryzen] FPS Boost включен")
    else
        engine.set_float("graphics.texture_quality", 1.0)
        engine.set_float("graphics.shadow_quality", 1.0)
        engine.set_float("graphics.particle_quality", 1.0)
        engine.set_float("graphics.post_processing", 1.0)
        engine.set_float("fog.enabled", 1.0)
        engine.set_float("fog.density", 1.0)
        engine.set_float("graphics.brightness", 1.0)
        engine.set_float("graphics.gamma", 1.0)
        engine.set_float("graphics.view_distance", 1.0)
        print("[Ryzen] FPS Boost выключен")
    end
end

function applyGreySky()
    if greySky then
        engine.set_color("sky", {180, 180, 180, 255})
        engine.set_float("sky.brightness", 0.7)
        print("[Ryzen] Серое небо включено")
    else
        engine.set_color("sky", {135, 206, 235, 255})
        engine.set_float("sky.brightness", 1.0)
        print("[Ryzen] Серое небо выключено")
    end
end

-- ===== ESP ОТРИСОВКА =====
function drawESP()
    local players = engine.get_players()
    local objects = engine.get_objects()
    
    for _, p in ipairs(players) do
        if p:is_alive() then
            local pos = p:get_pos()
            local screenPos = engine.world_to_screen(pos)
            if screenPos then
                local name = p:get_name() or "Unknown"
                local isKiller = p:is_killer()
                local isSurvivor = p:is_survivor()
                local isMinion = p:is_minion()
                
                if esp.killer and isKiller then
                    engine.draw_rect_outline(screenPos.x - 20, screenPos.y - 40, 40, 60, {255, 0, 0, 255}, 2)
                    engine.draw_text(screenPos.x - 30, screenPos.y - 55, name, {255, 0, 0, 255}, 12)
                end
                
                if esp.survivor and isSurvivor then
                    engine.draw_rect_outline(screenPos.x - 20, screenPos.y - 40, 40, 60, {0, 255, 0, 255}, 2)
                    engine.draw_text(screenPos.x - 30, screenPos.y - 55, name, {0, 255, 0, 255}, 12)
                end
                
                if esp.minions and isMinion then
                    engine.draw_rect_outline(screenPos.x - 15, screenPos.y - 30, 30, 50, {139, 0, 0, 255}, 2)
                    engine.draw_text(screenPos.x - 20, screenPos.y - 45, name, {139, 0, 0, 255}, 10)
                end
            end
        end
    end
    
    if esp.items then
        for _, obj in ipairs(objects) do
            if obj:is_item() then
                local pos = obj:get_pos()
                local screenPos = engine.world_to_screen(pos)
                if screenPos then
                    local name = obj:get_name() or "Item"
                    if name:find("MedKit") or name:find("RobloxCola") then
                        engine.draw_rect_outline(screenPos.x - 12, screenPos.y - 12, 24, 24, {0, 100, 255, 255}, 2)
                        engine.draw_text(screenPos.x - 30, screenPos.y - 25, name, {0, 100, 255, 255}, 10)
                    end
                end
            end
        end
    end
    
    if esp.generators then
        for _, obj in ipairs(objects) do
            if obj:is_generator() then
                local pos = obj:get_pos()
                local screenPos = engine.world_to_screen(pos)
                if screenPos then
                    local progress = obj:get_progress() or 0
                    local isFake = obj:is_fake()
                    local isComplete = obj:is_complete()
                    
                    local color
                    local label
                    if isComplete then
                        color = {255, 200, 0, 255}
                        label = "✅ COMPLETE"
                    elseif isFake then
                        color = {255, 165, 0, 255}
                        label = "🎭 FAKE"
                    else
                        color = {255, 200, 0, 255}
                        label = "⚙️ " .. math.floor(progress * 100) .. "%"
                    end
                    
                    engine.draw_rect_outline(screenPos.x - 20, screenPos.y - 20, 40, 40, color, 2)
                    engine.draw_text(screenPos.x - 35, screenPos.y - 35, label, color, 10)
                    engine.draw_text(screenPos.x - 20, screenPos.y + 25, "Generator", color, 9)
                end
            end
        end
    end
    
    if esp.veronica then
        for _, obj in ipairs(objects) do
            if obj:is_veronica_graffiti() then
                local pos = obj:get_pos()
                local screenPos = engine.world_to_screen(pos)
                if screenPos then
                    engine.draw_rect_outline(screenPos.x - 15, screenPos.y - 15, 30, 30, {255, 20, 147, 255}, 2)
                    engine.draw_text(screenPos.x - 25, screenPos.y - 30, "Veronica 🎨", {255, 20, 147, 255}, 10)
                end
            end
        end
    end
    
    if esp.traps then
        for _, obj in ipairs(objects) do
            if obj:is_trap() then
                local pos = obj:get_pos()
                local screenPos = engine.world_to_screen(pos)
                if screenPos then
                    local trapType = obj:get_trap_type() or "Trap"
                    engine.draw_rect_outline(screenPos.x - 18, screenPos.y - 18, 36, 36, {255, 0, 0, 255}, 2)
                    engine.draw_text(screenPos.x - 30, screenPos.y - 32, trapType .. " ⚠️", {255, 0, 0, 255}, 10)
                end
            end
        end
    end
end

-- ===== ОСНОВНАЯ ПАНЕЛЬ =====
function drawGUI()
    if not guiOpen then return end
    
    if guiMinimized then
        -- Свернутое состояние — показываем только кнопку разворачивания
        drawMinimizeButton()
        return
    end
    
    local screenW, screenH = engine.get_screen_size()
    local panelX = screenW / 2 - 200
    local panelY = screenH / 2 - 180
    local panelW = 400
    local panelH = 420
    
    engine.draw_rect(panelX, panelY, panelW, panelH, {16, 18, 28, 240})
    engine.draw_rect_outline(panelX, panelY, panelW, panelH, {0, 180, 255, 200}, 2)
    
    -- Кнопка сворачивания в углу панели
    local minX = panelX + panelW - 45
    local minY = panelY + 5
    local minW = 35
    local minH = 30
    engine.draw_rect(minX, minY, minW, minH, {60, 60, 80, 200})
    engine.draw_rect_outline(minX, minY, minW, minH, {255, 255, 255, 100}, 1)
    engine.draw_text(minX + 10, minY + 6, "−", {255, 255, 255, 255}, 18)
    minimizeButton.x = minX
    minimizeButton.y = minY
    minimizeButton.w = minW
    minimizeButton.h = minH
    
    engine.draw_text(panelX + 12, panelY + 8, "RYZEN PANEL", {0, 200, 255, 255}, 20)
    engine.draw_text(panelX + panelW - 100, panelY + 10, "[F7]", {100, 100, 120, 150}, 13)
    
    local tabEndX, tabH, tabY = drawTabs(panelX, panelY, panelW)
    local contentY = panelY + tabY + tabH + 15
    local contentX = panelX + 15
    local contentW = panelW - 30
    
    engine.draw_rect(panelX + 10, contentY - 5, panelW - 20, 1, {100, 100, 140, 100})
    
    local spacing = 40
    local btnH = 32
    
    -- MAIN
    if currentTab == "main" then
        local yOff = 30
        engine.draw_text(contentX, contentY + yOff - 20, "⚙️ Main Functions", {200, 200, 255, 220}, 15)
        
        drawToggle(contentX, contentY, contentW, btnH, infiniteStaminaEnabled, "⚡ Infinite Stamina", yOff)
        yOff = yOff + spacing
        drawToggle(contentX, contentY, contentW, btnH, aspect4x3, "📐 4:3 Aspect Ratio", yOff)
        yOff = yOff + spacing
        drawToggle(contentX, contentY, contentW, btnH, fpsBoost, "🚀 FPS Boost", yOff)
        yOff = yOff + spacing
        drawToggle(contentX, contentY, contentW, btnH, greySky, "🌥️ Grey Sky", yOff)
    end
    
    -- SURVIVOR
    if currentTab == "survivor" then
        local yOff = 30
        engine.draw_text(contentX, contentY + yOff - 20, "🛡️ Survivor Modules", {200, 200, 255, 220}, 15)
        
        drawToggle(contentX, contentY, contentW, btnH, backstabEnabled, "🔪 Backstab", yOff)
        yOff = yOff + spacing
        drawToggle(contentX, contentY, contentW, btnH, mobileButton.visible, "📱 Mobile Button", yOff)
        yOff = yOff + spacing
        
        local exColor = backstabEnabled and {40, 40, 180, 220} or {80, 80, 80, 150}
        engine.draw_rect(contentX, contentY + yOff, contentW, btnH, exColor)
        engine.draw_rect_outline(contentX, contentY + yOff, contentW, btnH, {255, 255, 255, 100}, 1)
        engine.draw_text(contentX + 80, contentY + yOff + 8, "▶ EXECUTE BACKSTAB", backstabEnabled and {255, 255, 255, 255} or {150, 150, 150, 150}, 13)
    end
    
    -- ESP
    if currentTab == "esp" then
        local yOff = 30
        engine.draw_text(contentX, contentY + yOff - 20, "👁️ ESP Modules", {200, 200, 255, 220}, 15)
        
        local espList = {
            {key = "killer", label = "🔴 ESP Killer"},
            {key = "minions", label = "🟤 ESP Minions"},
            {key = "survivor", label = "🟢 ESP Survivor"},
            {key = "items", label = "🔵 ESP Items"},
            {key = "generators", label = "🟡 ESP Generators"},
            {key = "veronica", label = "🩷 ESP Veronica's Graffiti"},
            {key = "traps", label = "🔴 ESP Traps"}
        }
        
        for _, item in ipairs(espList) do
            drawToggle(contentX, contentY, contentW, 28, esp[item.key], item.label, yOff)
            yOff = yOff + 32
        end
    end
    
    engine.draw_text(panelX + 10, panelY + panelH - 20, "Click on slider to toggle | F6 - Quick BS", {120, 120, 150, 150}, 11)
end

-- ===== ПРОВЕРКА КЛИКА ПО ПОЛЗУНКУ =====
function isOnToggle(x, y, toggleX, toggleY, toggleW, toggleH)
    return x >= toggleX and x <= toggleX + toggleW and y >= toggleY and y <= toggleY + toggleH
end

-- ===== ОБРАБОТЧИК КЛИКОВ =====
function handleGUIClick(x, y)
    -- Сначала проверяем кнопку сворачивания
    if isOnMinimizeButton(x, y) then
        if guiOpen then
            guiMinimized = not guiMinimized
            print("[Ryzen] Меню " .. (guiMinimized and "свернуто" or "развернуто"))
        end
        return true
    end
    
    if not guiOpen or guiMinimized then return false end
    
    local screenW, screenH = engine.get_screen_size()
    local panelX = screenW / 2 - 200
    local panelY = screenH / 2 - 180
    local panelW = 400
    local panelH = 420
    
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        return false
    end
    
    -- Вкладки
    local tabs = {
        {id = "main", x = 10},
        {id = "survivor", x = 90},
        {id = "esp", x = 175}
    }
    local tabW, tabH, tabY = 65, 35, 10
    
    for _, tab in ipairs(tabs) do
        if x > panelX + tab.x and x < panelX + tab.x + tabW and y > panelY + tabY and y < panelY + tabY + tabH then
            currentTab = tab.id
            return true
        end
    end
    
    local contentY = panelY + tabY + tabH + 15
    local contentX = panelX + 15
    local contentW = panelW - 30
    local spacing = 40
    local btnH = 32
    local toggleW = 50
    local toggleH = 24
    
    if currentTab == "main" then
        local yOff = 30
        
        local tx = contentX + contentW - toggleW - 10
        local ty = contentY + yOff + (btnH - toggleH) / 2
        if isOnToggle(x, y, tx, ty, toggleW, toggleH) then
            infiniteStaminaEnabled = not infiniteStaminaEnabled
            if infiniteStaminaEnabled then enableInfiniteStamina() else disableInfiniteStamina() end
            print("[Ryzen] Stamina: " .. (infiniteStaminaEnabled and "ON" or "OFF"))
            return true
        end
        yOff = yOff + spacing
        
        tx = contentX + contentW - toggleW - 10
        ty = contentY + yOff + (btnH - toggleH) / 2
        if isOnToggle(x, y, tx, ty, toggleW, toggleH) then
            aspect4x3 = not aspect4x3
            applyAspect4x3()
            return true
        end
        yOff = yOff + spacing
        
        tx = contentX + contentW - toggleW - 10
        ty = contentY + yOff + (btnH - toggleH) / 2
        if isOnToggle(x, y, tx, ty, toggleW, toggleH) then
            fpsBoost = not fpsBoost
            applyFPSBoost()
            return true
        end
        yOff = yOff + spacing
        
        tx = contentX + contentW - toggleW - 10
        ty = contentY + yOff + (btnH - toggleH) / 2
        if isOnToggle(x, y, tx, ty, toggleW, toggleH) then
            greySky = not greySky
            applyGreySky()
            return true
        end
    end
    
    if currentTab == "survivor" then
        local yOff = 30
        
        local tx = contentX + contentW - toggleW - 10
        local ty = contentY + yOff + (btnH - toggleH) / 2
        if isOnToggle(x, y, tx, ty, toggleW, toggleH) then
            backstabEnabled = not backstabEnabled
            print("[Ryzen] Backstab: " .. (backstabEnabled and "ON" or "OFF"))
            return true
        end
        yOff = yOff + spacing
        
        tx = contentX + contentW - toggleW - 10
        ty = contentY + yOff + (btnH - toggleH) / 2
        if isOnToggle(x, y, tx, ty, toggleW, toggleH) then
            mobileButton.visible = not mobileButton.visible
            if mobileButton.visible then initMobileButton() end
            print("[Ryzen] Mobile: " .. (mobileButton.visible and "ON" or "OFF"))
            return true
        end
        yOff = yOff + spacing
        
        
