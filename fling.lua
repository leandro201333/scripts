local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

local espEnabled = false
local targetPlayer = nil

-- 1. GUI Erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EjectorHub"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "PREMIUM EJECTOR HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Parent = mainFrame

-- ESP Button
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.9, 0, 0, 35)
espBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
espBtn.Text = "Toggle ESP: OFF"
espBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
espBtn.Parent = mainFrame

-- Spieler Auswahl (Scrolling Frame)
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0, 100)
playerList.Position = UDim2.new(0.05, 0, 0.35, 0)
playerList.CanvasSize = UDim2.new(0, 0, 5, 0)
playerList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
playerList.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = playerList

-- Fling Button
local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.9, 0, 0, 40)
flingBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
flingBtn.Text = "FLING TARGET"
flingBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
flingBtn.Parent = mainFrame

-- Open/Close Button
local toggleGuiBtn = Instance.new("TextButton")
toggleGuiBtn.Size = UDim2.new(0, 80, 0, 30)
toggleGuiBtn.Position = UDim2.new(0, 10, 0.85, 0)
toggleGuiBtn.Text = "Menu UI"
toggleGuiBtn.Parent = screenGui
toggleGuiBtn.MouseButton1Click:Connect(function() mainFrame.Visible = not mainFrame.Visible end)

-- 2. Spieler-Liste aktualisieren
local function updatePlayerList()
    for _, child in pairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 25)
            pBtn.Text = p.Name
            pBtn.BackgroundColor3 = (targetPlayer == p) and Color3.new(0,0.5,0) or Color3.new(0.2,0.2,0.2)
            pBtn.TextColor3 = Color3.new(1,1,1)
            pBtn.Parent = playerList
            pBtn.MouseButton1Click:Connect(function()
                targetPlayer = p
                updatePlayerList()
            end)
        end
    end
end
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

-- 3. Fling Logik (Der "Ejector")
local function fling(target)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetChar = target.Character
    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")

    if hrp and targetHrp then
        local oldPos = hrp.CFrame
        local flingActive = true
        
        -- Power up
        local bv = Instance.new("BodyAngularVelocity")
        bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bv.AngularVelocity = Vector3.new(0, 99999, 0)
        bv.Parent = hrp
        
        -- Zum Ziel teleportieren und flingen
        task.spawn(function()
            for i = 1, 50 do -- Dauer des Flings
                if not targetHrp or not targetHrp.Parent then break end
                hrp.CFrame = targetHrp.CFrame * CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                hrp.Velocity = Vector3.new(999, 999, 999)
                task.wait()
            end
            bv:Destroy()
            hrp.CFrame = oldPos
            hrp.Velocity = Vector3.new(0,0,0)
        end)
    end
end

flingBtn.MouseButton1Click:Connect(function()
    if targetPlayer then
        fling(targetPlayer)
    else
        flingBtn.Text = "SELECT PLAYER FIRST!"
        task.wait(1)
        flingBtn.Text = "FLING TARGET"
    end
end)

-- (ESP Logik wie zuvor einfügen oder hier gekürzt...)
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "Toggle ESP: ON" or "Toggle ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0,150,0) or Color3.fromRGB(150,0,0)
    -- Hier kommen die Highlight-Funktionen rein (siehe vorheriger Post)
end)
