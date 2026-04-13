local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local espEnabled = false

-- 1. GUI Erstellen (Das Menü)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EjectorMenu"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true
mainFrame.Draggable = true -- Du kannst das Menü verschieben
mainFrame.Visible = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "ESP MENU"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
toggleBtn.Text = "ESP: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = mainFrame

-- Kleiner Button zum Minimieren (unten rechts am Bildschirm)
local openCloseBtn = Instance.new("TextButton")
openCloseBtn.Size = UDim2.new(0, 50, 0, 20)
openCloseBtn.Position = UDim2.new(0, 10, 0.9, 0)
openCloseBtn.Text = "Open/Close"
openCloseBtn.Parent = screenGui

openCloseBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- 2. ESP Logik (Highlights & Namen)
local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    local function setup(character)
        -- Highlight (Körper)
        local highlight = character:FindFirstChild("ESPHighlight") or Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.Parent = character
        highlight.FillTransparency = 1
        highlight.OutlineColor = Color3.new(1, 0, 0)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = espEnabled

        -- Name Tag (Über dem Kopf)
        local head = character:WaitForChild("Head", 5)
        if head then
            local billboard = character:FindFirstChild("ESPName") or Instance.new("BillboardGui")
            billboard.Name = "ESPName"
            billboard.Parent = character
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 100, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Enabled = espEnabled

            local nameLabel = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel")
            nameLabel.Parent = billboard
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextScaled = true
        end
    end

    player.CharacterAdded:Connect(setup)
    if player.Character then setup(player.Character) end
end

-- Toggle Funktion
toggleBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        toggleBtn.Text = "ESP: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        toggleBtn.Text = "ESP: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end

    -- Alle Spieler aktualisieren
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            if p.Character:FindFirstChild("ESPHighlight") then
                p.Character.ESPHighlight.Enabled = espEnabled
            end
            if p.Character:FindFirstChild("ESPName") then
                p.Character.ESPName.Enabled = espEnabled
            end
        end
    end
end)

-- Neue Spieler erfassen
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)
