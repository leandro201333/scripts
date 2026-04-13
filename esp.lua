local Players = game:GetService("Players")

local function addHighlightToCharacter(character)
    -- Sicherstellen, dass wir nicht uns selbst markieren (optional)
    if character == Players.LocalPlayer.Character then return end

    if not character:FindFirstChildOfClass("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        
        -- Einstellungen
        highlight.FillTransparency = 1 -- Inneres unsichtbar
        highlight.OutlineColor = Color3.new(1, 0, 0) -- Rot
        highlight.OutlineTransparency = 0 -- Sichtbar
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Sieht man durch Wände!
    end
end

-- 1. Bestehende Spieler sofort markieren
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        addHighlightToCharacter(player.Character)
    end
    -- Falls der Charakter neu spawnt
    player.CharacterAdded:Connect(addHighlightToCharacter)
end

-- 2. Neue Spieler markieren, die später beitreten
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(addHighlightToCharacter)
end)
