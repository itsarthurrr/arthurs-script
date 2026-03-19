-- [[ CONFIG ]]
local webhookURL = "https://discord.com/api/webhooks/1483845385574416468/fNkI9zIiXhX8TKgsNGWIG3kZVOQ-8WadbTJOap4SND6-fk7rTEn0Qp-x4JrkPh-HLtiD"

-- [[ SERVICES ]]
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- States
local flying, noclip, xrayEnabled, aimbotEnabled, hitboxEnabled = false, false, false, false, false
local wallHopEnabled, infJumpEnabled, fakeLagEnabled = false, false, false
local isFlinging = false
local walkSpeedValue, glitchSpeedValue, jumpPowerValue = 16, 50, 50

-- [[ UI SETUP ]]
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 0)
main.Position = UDim2.new(0.05, 0, 0.02, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true; main.Draggable = true
main.AutomaticSize = Enum.AutomaticSize.Y
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 45); header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -40, 1, 0); title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "ARTHUR'S INTERNAL"; title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextXAlignment = "Left"

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, 0, 0, 0); container.Position = UDim2.new(0, 0, 0, 50); container.BackgroundTransparency = 1
container.AutomaticSize = Enum.AutomaticSize.Y

local padding = Instance.new("UIPadding", container)
padding.PaddingLeft = UDim.new(0, 12); padding.PaddingRight = UDim.new(0, 12); padding.PaddingBottom = UDim.new(0, 12)

local layout = Instance.new("UIListLayout", container)
layout.HorizontalAlignment = "Center"; layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder

local toggles = {}

-- [[ GENERATORS ]]
local function createToggle(name, varName, order, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); btn.LayoutOrder = order
    btn.Text = "  " .. name; btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamMedium; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local ind = Instance.new("Frame", btn); ind.Size = UDim2.new(0, 18, 0, 8); ind.Position = UDim2.new(1, -28, 0.5, -4); ind.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
    local function toggle()
        _G[varName.."_State"] = not _G[varName.."_State"]
        callback(_G[varName.."_State"])
        ind.BackgroundColor3 = _G[varName.."_State"] and Color3.new(1, 1, 1) or Color3.fromRGB(45, 45, 45)
    end
    btn.MouseButton1Click:Connect(toggle); toggles[varName] = toggle
end

local function createSlider(name, min, max, default, order, callback)
    local sFrame = Instance.new("Frame", container)
    sFrame.Size = UDim2.new(1, 0, 0, 48); sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22); sFrame.LayoutOrder = order
    Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 8)
    local sLabel = Instance.new("TextLabel", sFrame); sLabel.Size = UDim2.new(1, 0, 0, 20); sLabel.Text = name..": "..default; sLabel.TextColor3 = Color3.new(1,1,1); sLabel.BackgroundTransparency = 1; sLabel.Font = Enum.Font.GothamMedium; sLabel.TextSize = 10
    local sBar = Instance.new("Frame", sFrame); sBar.Size = UDim2.new(0.8, 0, 0, 3); sBar.Position = UDim2.new(0.1, 0, 0.7, 0); sBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", sBar)
    local sDot = Instance.new("TextButton", sBar); sDot.Size = UDim2.new(0, 10, 0, 10); sDot.Position = UDim2.new((default-min)/(max-min), -5, 0.5, -5); sDot.BackgroundColor3 = Color3.new(1,1,1); sDot.Text = ""; Instance.new("UICorner", sDot).CornerRadius = UDim.new(1, 0)
    local dragging = false
    sDot.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local p = math.clamp((UIS:GetMouseLocation().X - sBar.AbsolutePosition.X) / sBar.AbsoluteSize.X, 0, 1)
            sDot.Position = UDim2.new(p, -5, 0.5, -5); local val = math.floor(min + (p * (max - min))); sLabel.Text = name..": "..val; callback(val)
        end
    end)
end

-- 1. TOGGLES
createToggle("Fly (F)", "Fly", 1, function(s) flying = s end)
createToggle("Noclip (N)", "Noclip", 2, function(s) noclip = s end)
createToggle("Infinite Jump (U)", "IJump", 3, function(s) infJumpEnabled = s end)
createToggle("Aimlock (Z)", "Aim", 4, function(s) aimbotEnabled = s end)
createToggle("Hitbox (H)", "Hit", 5, function(s) hitboxEnabled = s end)
createToggle("X-Ray (X)", "Xray", 6, function(s) xrayEnabled = s; for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v:IsDescendantOf(player.Character) then v.LocalTransparencyModifier = s and 0.5 or 0 end end end)
createToggle("Fake Lag (L)", "FLag", 7, function(s) fakeLagEnabled = s end)
createToggle("Wall Hop (J)", "WHop", 8, function(s) wallHopEnabled = s end)

-- 2. REGLAGE
createSlider("Walkspeed", 16, 250, 16, 50, function(v) walkSpeedValue = v end)
createSlider("Speed Glitch", 16, 300, 50, 51, function(v) glitchSpeedValue = v end)
createSlider("Jump Power", 50, 400, 50, 52, function(v) jumpPowerValue = v end)

-- 3. FLING KOLUMN
local flingBox = Instance.new("Frame", container)
flingBox.Size = UDim2.new(1, 0, 0, 110); flingBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22); flingBox.LayoutOrder = 60
Instance.new("UICorner", flingBox).CornerRadius = UDim.new(0, 10)
local fInput = Instance.new("TextBox", flingBox); fInput.Size = UDim2.new(0.9, 0, 0, 24); fInput.Position = UDim2.new(0.05, 0, 0.1, 0); fInput.PlaceholderText = "Target Username..."; fInput.BackgroundColor3 = Color3.fromRGB(10, 10, 10); fInput.TextColor3 = Color3.new(1,1,1); fInput.Font = Enum.Font.Gotham; fInput.TextSize = 10; Instance.new("UICorner", fInput)
local fStart = Instance.new("TextButton", flingBox); fStart.Size = UDim2.new(0.42, 0, 0, 28); fStart.Position = UDim2.new(0.05, 0, 0.38, 0); fStart.Text = "FLING"; fStart.BackgroundColor3 = Color3.new(1,1,1); fStart.TextColor3 = Color3.new(0,0,0); fStart.Font = Enum.Font.GothamBold; fStart.TextSize = 10; Instance.new("UICorner", fStart)
local fStop = Instance.new("TextButton", flingBox); fStop.Size = UDim2.new(0.42, 0, 0, 28); fStop.Position = UDim2.new(0.53, 0, 0.38, 0); fStop.Text = "STOP"; fStop.BackgroundColor3 = Color3.fromRGB(40,40,40); fStop.TextColor3 = Color3.new(1,1,1); fStop.Font = Enum.Font.GothamBold; fStop.TextSize = 10; Instance.new("UICorner", fStop)
local fKill = Instance.new("TextButton", flingBox); fKill.Size = UDim2.new(0.9, 0, 0, 28); fKill.Position = UDim2.new(0.05, 0, 0.68, 0); fKill.Text = "KILL TARGET"; fKill.BackgroundColor3 = Color3.new(1,1,1); fKill.TextColor3 = Color3.new(0,0,0); fKill.Font = Enum.Font.GothamBold; fKill.TextSize = 10; Instance.new("UICorner", fKill)

-- 4. KILL ALL KNAPP
local killAll = Instance.new("TextButton", container)
killAll.Size = UDim2.new(1, 0, 0, 45); killAll.BackgroundColor3 = Color3.new(1,1,1); killAll.TextColor3 = Color3.new(0,0,0)
killAll.Text = "KILL ALL"; killAll.Font = Enum.Font.GothamBold; killAll.TextSize = 16; killAll.LayoutOrder = 70
Instance.new("UICorner", killAll).CornerRadius = UDim.new(0, 8)

-- [[ FUNCTIONS ]]
fKill.MouseButton1Click:Connect(function()
    local tName = fInput.Text:lower()
    for _, v in pairs(game.Players:GetPlayers()) do if v.Name:lower():find(tName) and v.Character and v.Character:FindFirstChild("Humanoid") then v.Character.Humanoid.Health = 0 end end
end)

killAll.MouseButton1Click:Connect(function()
    for _, v in pairs(game.Players:GetPlayers()) do if v ~= player and v.Character and v.Character:FindFirstChild("Humanoid") then v.Character.Humanoid.Health = 0 end end
end)

fStart.MouseButton1Click:Connect(function()
    isFlinging = true
    local target = nil
    for _, v in pairs(game.Players:GetPlayers()) do if v.Name:lower():find(fInput.Text:lower()) then target = v break end end
    if target and target.Character and player.Character then
        local root = player.Character.HumanoidRootPart
        local bV = Instance.new("BodyAngularVelocity", root); bV.AngularVelocity = Vector3.new(0, 999999, 0); bV.MaxTorque = Vector3.new(0, math.huge, 0)
        task.spawn(function()
            while isFlinging and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do root.CFrame = target.Character.HumanoidRootPart.CFrame; RunService.Heartbeat:Wait() end
            bV:Destroy()
        end)
    end
end)
fStop.MouseButton1Click:Connect(function() isFlinging = false end)

-- [[ SHORTCUTS & LOGIC ]]
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local binds = {F="Fly", N="Noclip", U="IJump", Z="Aim", H="Hit", X="Xray", L="FLag", J="WHop"}
    local key = input.KeyCode.Name
    if binds[key] and toggles[binds[key]] then toggles[binds[key]]() end
end)

UIS.JumpRequest:Connect(function() 
    if infJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then 
        player.Character.Humanoid:ChangeState("Jumping") 
    end 
end)

RunService.Stepped:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return end
    local hum, root = player.Character.Humanoid, player.Character.HumanoidRootPart
    
    -- Wall Hop Logic
    if wallHopEnabled then
        local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
        local part = workspace:FindPartOnRay(ray, player.Character)
        if part then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end

    local isMoving = hum.MoveDirection.Magnitude > 0.1
    local isAirborne = hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall
    hum.WalkSpeed = (isMoving and isAirborne) and glitchSpeedValue or walkSpeedValue
    hum.JumpPower = jumpPowerValue; hum.UseJumpPower = true

    if flying then
        local bv = root:FindFirstChild("XVel") or Instance.new("BodyVelocity", root); bv.Name = "XVel"; bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        local bg = root:FindFirstChild("XGy") or Instance.new("BodyGyro", root); bg.Name = "XGy"; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = camera.CFrame
        local dir = Vector3.new()
        if UIS:IsKeyDown("W") then dir = dir + camera.CFrame.LookVector end
        if UIS:IsKeyDown("S") then dir = dir - camera.CFrame.LookVector end
        if UIS:IsKeyDown("D") then dir = dir + camera.CFrame.RightVector end
        if UIS:IsKeyDown("A") then dir = dir - camera.CFrame.RightVector end
        bv.Velocity = dir * 100; hum.PlatformStand = true
    else
        if root:FindFirstChild("XVel") then root.XVel:Destroy() end
        if root:FindFirstChild("XGy") then root.XGy:Destroy() end
        hum.PlatformStand = false
    end

    if noclip then for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if fakeLagEnabled then root.Anchored = true; task.wait(0.01); root.Anchored = false end
end)

RunService.RenderStepped:Connect(function()
    if hitboxEnabled then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(20, 20, 20); v.Character.HumanoidRootPart.Transparency = 0.7
            end
        end
    end
end)