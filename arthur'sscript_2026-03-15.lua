-- Settings
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying, noclip, aimbotEnabled, xrayEnabled, hitboxEnabled, pshadeEnabled, wallHopEnabled, infJumpEnabled, wallGlideEnabled, fakeLagEnabled, lagSwitchEnabled = false, false, false, false, false, false, false, false, false, false, false
local flySpeed = 80
local walkSpeedValue = 16
local jumpPowerValue = 50
local hitboxSize = 20 

-- UI Setup
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 600)
main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- Header
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "Arthur's scripts"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Stäng
local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeBtn)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() script.Disabled = true end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, 0, 1, -160)
scroll.Position = UDim2.new(0, 0, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 850)
scroll.ScrollBarThickness = 4
Instance.new("UIListLayout", scroll).HorizontalAlignment = "Center"

-- SLIDER FUNKTION
local function createSlider(name, min, max, default, pos)
    local frame = Instance.new("Frame", main)
    frame.Size = UDim2.new(0.9, 0, 0, 45)
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham; label.TextSize = 11

    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(0.8, 0, 0, 4)
    bar.Position = UDim2.new(0.1, 0, 0.7, 0)
    bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

    local dot = Instance.new("TextButton", bar)
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7)
    dot.BackgroundColor3 = Color3.new(0, 1, 0)
    dot.Text = ""
    Instance.new("UICorner", dot)

    local val = default
    local dragging = false
    dot.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UIS:GetMouseLocation().X
            local percent = math.clamp((mousePos - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            dot.Position = UDim2.new(percent, -7, 0.5, -7)
            val = math.floor(min + (percent * (max - min)))
            label.Text = name .. ": " .. val
        end
    end)
    return function() return val end
end

local getJumpPower = createSlider("Jump Power", 50, 250, 50, UDim2.new(0.05, 0, 1, -105))
local getWalkSpeed = createSlider("Walk Speed", 16, 200, 16, UDim2.new(0.05, 0, 1, -55))

-- UI TOGGLES
local function updateVisuals()
    if not sg.Parent then return end
    _G.fInd.BackgroundColor3 = flying and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.nInd.BackgroundColor3 = noclip and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.xInd.BackgroundColor3 = xrayEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.aInd.BackgroundColor3 = aimbotEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.hInd.BackgroundColor3 = hitboxEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.wInd.BackgroundColor3 = wallHopEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.iInd.BackgroundColor3 = infJumpEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.gInd.BackgroundColor3 = wallGlideEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.lInd.BackgroundColor3 = fakeLagEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
    _G.lsInd.BackgroundColor3 = lagSwitchEnabled and Color3.new(0,1,0) or Color3.new(1,0,0)
end

local function createToggle(name, key, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. " [" .. key .. "]"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham; btn.TextSize = 13
    Instance.new("UICorner", btn)
    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0, 4, 1, 0)
    ind.BackgroundColor3 = Color3.new(1, 0, 0)
    btn.MouseButton1Click:Connect(callback)
    return btn, ind
end

-- Toggles
local function toggleFly() flying = not flying updateVisuals() end
local function toggleNoclip() noclip = not noclip updateVisuals() end
local function toggleXray() xrayEnabled = not xrayEnabled updateVisuals() end
local function toggleAimlock() aimbotEnabled = not aimbotEnabled updateVisuals() end
local function toggleHitbox() hitboxEnabled = not hitboxEnabled updateVisuals() end
local function toggleWallHop() wallHopEnabled = not wallHopEnabled updateVisuals() end
local function toggleInfJump() infJumpEnabled = not infJumpEnabled updateVisuals() end
local function toggleWallGlide() wallGlideEnabled = not wallGlideEnabled updateVisuals() end
local function toggleFakeLag() fakeLagEnabled = not fakeLagEnabled updateVisuals() end
local function toggleLagSwitch() 
    lagSwitchEnabled = not lagSwitchEnabled 
    -- Fryser nätverket (om executor stöder det) eller sänker FPS till minimum för att stoppa paket
    if settings():GetService("NetworkSettings") then
        settings():GetService("NetworkSettings").IncomingReplicationLag = lagSwitchEnabled and 1000 or 0
    end
    updateVisuals() 
end
local function runSpeedGl() loadstring(game:HttpGet("https://raw.githubusercontent.com/zbrau/script/refs/heads/main/e6"))() end

local fBtn, fInd = createToggle("Fly", "F", toggleFly)
local nBtn, nInd = createToggle("Noclip", "N", toggleNoclip)
local xBtn, xInd = createToggle("X-Ray", "X", toggleXray)
local aBtn, aInd = createToggle("Hard Aimlock", "Z", toggleAimlock)
local hBtn, hInd = createToggle("Ghost Hitbox", "H", toggleHitbox)
local wBtn, wInd = createToggle("Wall Hop", "J", toggleWallHop)
local iBtn, iInd = createToggle("Infinite Jump", "U", toggleInfJump)
local gBtn, gInd = createToggle("Wall Glide", "G", toggleWallGlide)
local lBtn, lInd = createToggle("Fake Lag", "L", toggleFakeLag)
local lsBtn, lsInd = createToggle("Lag Switch", "B", toggleLagSwitch)
local eBtn, eInd = createToggle("speed gl", "K", runSpeedGl)

_G.fInd, _G.nInd, _G.xInd, _G.aInd, _G.hInd, _G.wInd, _G.iInd, _G.gInd, _G.lInd, _G.lsInd = fInd, nInd, xInd, aInd, hInd, wInd, iInd, gInd, lInd, lsInd

-- INPUTS
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not sg.Parent then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly()
    elseif input.KeyCode == Enum.KeyCode.N then toggleNoclip()
    elseif input.KeyCode == Enum.KeyCode.X then toggleXray()
    elseif input.KeyCode == Enum.KeyCode.Z then toggleAimlock()
    elseif input.KeyCode == Enum.KeyCode.H then toggleHitbox()
    elseif input.KeyCode == Enum.KeyCode.J then toggleWallHop()
    elseif input.KeyCode == Enum.KeyCode.U then toggleInfJump()
    elseif input.KeyCode == Enum.KeyCode.G then toggleWallGlide()
    elseif input.KeyCode == Enum.KeyCode.L then toggleFakeLag()
    elseif input.KeyCode == Enum.KeyCode.B then toggleLagSwitch()
    elseif input.KeyCode == Enum.KeyCode.K then runSpeedGl()
    elseif input.KeyCode == Enum.KeyCode.Space then
        if infJumpEnabled and player.Character then 
            local h = player.Character:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- FAKE LAG LOGIC
task.spawn(function()
    while true do
        task.wait()
        if fakeLagEnabled and sg.Parent then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = true
                task.wait(0.12)
                root.Anchored = false
                task.wait(0.05)
            end
        end
    end
end)

-- PHYSICS LOOP
RunService.Stepped:Connect(function()
    if not sg.Parent or not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    hum.JumpPower = getJumpPower()
    hum.WalkSpeed = getWalkSpeed()
    hum.UseJumpPower = true

    if (wallHopEnabled or wallGlideEnabled) then
        local ray = Ray.new(root.Position, root.CFrame.LookVector * 2.6)
        local part = workspace:FindPartOnRay(ray, char)
        if part and part.CanCollide then
            if wallHopEnabled and UIS:IsKeyDown(Enum.KeyCode.Space) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.Velocity = Vector3.new(root.Velocity.X, getJumpPower(), root.Velocity.Z)
            end
            if wallGlideEnabled then
                root.Velocity = Vector3.new(root.Velocity.X, 2, root.Velocity.Z)
                hum:ChangeState(Enum.HumanoidStateType.Climbing)
            end
        end
    end

    if noclip then
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end

    if flying then
        local bv = root:FindFirstChild("XenoFly") or Instance.new("BodyVelocity", root)
        bv.Name = "XenoFly"; bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        local direction = Vector3.new(0,0,0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0,1,0) end
        bv.Velocity = direction * flySpeed; hum.PlatformStand = true
    else
        if root:FindFirstChild("XenoFly") then root.XenoFly:Destroy() hum.PlatformStand = false end
    end
end)

-- RENDER LOOP
RunService.RenderStepped:Connect(function()
    if not sg.Parent then return end
    if hitboxEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                v.Character.HumanoidRootPart.Transparency = 0.7; v.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= player and v.Character then
            local hl = v.Character:FindFirstChild("XenoHighlight")
            if xrayEnabled then
                if not hl then hl = Instance.new("Highlight", v.Character) hl.Name = "XenoHighlight" end
                local isM = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
                local isS = v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun")
                hl.FillColor = isM and Color3.new(1,0,0) or isS and Color3.new(0,0,1) or Color3.new(0,1,0)
            elseif hl then hl:Destroy() end
        end
    end
    if aimbotEnabled then
        local t, dist = nil, math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                local d = (v.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then t = v.Character.HumanoidRootPart; dist = d end
            end
        end
        if t then camera.CFrame = CFrame.new(camera.CFrame.Position, t.Position) end
    end
end)