local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local lp = Players.LocalPlayer

-- Variablen für Zustände
local espEnabled = false
local mm2Enabled = false
local targetPlayer = nil

-- 1. GUI Erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EjectorMasterHub"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 380)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "EJECTOR & MM2 HUB"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Parent = mainFrame

-- BUTTONS
local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = mainFrame
    return btn
end

local espBtn = createBtn("ESP: OFF", UDim2.new(0.05, 0, 0.12, 0), Color3.fromRGB(150, 0, 0))
local mm2Btn = createBtn("MM2 Roles: OFF", UDim2.new(0.05, 0, 0.23, 0), Color3.fromRGB(150, 0, 0))

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0.9, 0, 0, 100)
playerList.Position = UDim2.new(0.05, 0, 0.35, 0)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
playerList.Parent = mainFrame
local uiList = Instance.new("UIListLayout")
uiList.Parent = playerList

local flingBtn = createBtn("FLING TARGET", UDim2.new(0.05, 0, 0.65, 0), Color3.fromRGB(60, 60, 60))

-- Open/Close Toggle Button (Immer sichtbar)
local uiToggle = Instance.new("TextButton")
uiToggle.Size = UDim2.new(0, 100, 0, 30)
uiToggle.Position = UDim2.new(0, 10, 0, 10)
uiToggle.Text = "CLOSE MENU"
uiToggle.Parent = screenGui
uiToggle.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    uiToggle.Text = mainFrame.Visible and "CLOSE MENU" or "OPEN MENU"
end)

-- 2. MM2 & ESP LOGIK
local function getMM2Role(player)
    local char = player.Character
    local pack = player.Backpack
    if (char and char:FindFirstChild("Knife")) or (pack and pack:FindFirstChild("Knife")) then
        return "MURDERER", Color3.new(1, 0, 0)
    elseif (char and char:FindFirstChild("Gun")) or (pack and pack:FindFirstChild("Gun")) then
        return "SHERIFF", Color3.new(0, 0, 1)
    end
    return "Innocent", Color3.new(0, 1, 0)
end

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
            -- ESP Highlight
            local highlight = p.Character:FindFirstChild("Highlight")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.FillTransparency = 1
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end

            -- MM2 Roles
            local head = p.Character.Head
            local tag = head:FindFirstChild("RoleTag")
            if mm2Enabled then
                if not tag then
                    tag = Instance.new("BillboardGui", head)
                    tag.Name = "RoleTag"
                    tag.Size = UDim2.new(0, 100, 0, 50)
                    tag.AlwaysOnTop = true
                    tag.StudsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", tag)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.TextStrokeTransparency = 0
                    l.TextScaled = true
                end
                local role, color = getMM2Role(p)
                tag.TextLabel.Text = p.Name .. " [" .. role .. "]"
                tag.TextLabel.TextColor3 = color
                if highlight then highlight.OutlineColor = color end
            elseif tag then
                tag:Destroy()
            end
        end
    end
end)

-- 3. INTERAKTION
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

mm2Btn.MouseButton1Click:Connect(function()
    mm2Enabled = not mm2Enabled
    mm2Btn.Text = mm2Enabled and "MM2 Roles: ON" or "MM2 Roles: OFF"
    mm2Btn.BackgroundColor3 = mm2Enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- Fling Funktion
flingBtn.MouseButton1Click:Connect(function()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        local oldPos = hrp.CFrame
        local bv = Instance.new("BodyAngularVelocity", hrp)
        bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bv.AngularVelocity = Vector3.new(0, 999999, 0)
        
        for i = 1, 30 do
            if targetPlayer.Character then
                hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                hrp.Velocity = Vector3.new(500, 500, 500)
            end
            task.wait()
        end
        bv:Destroy()
        hrp.CFrame = oldPos
    end
end)

-- Player List Update
local function updateList()
    for _, c in pairs(playerList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            local b = Instance.new("TextButton", playerList)
            b.Size = UDim2.new(1, 0, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = (targetPlayer == p) and Color3.new(0, 0.4, 0) or Color3.new(0.2, 0.2, 0.2)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.MouseButton1Click:Connect(function() targetPlayer = p updateList() end)
        end
    end
end
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
