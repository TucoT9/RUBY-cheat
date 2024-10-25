--[[ 
   WARNUNG: Dieses Skript wurde nicht von ScriptBlox überprüft. Verwendung auf eigene Gefahr! 
   Skript erstellt von TucoT9 
]]

-- Variablen für den Godmode und den Status
local godModeEnabled = false

-- Funktion zum Senden von Benachrichtigungen
local function sendNotification(title, text)
    game.StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Icon = "",
        Duration = 5
    })
end

-- Funktion, um Godmode zu aktivieren oder zu deaktivieren
local function toggleGodMode()
    godModeEnabled = not godModeEnabled

    if godModeEnabled then
        -- Setze den Godmode-Status (z.B. Unverwundbarkeit aktivieren)
        local player = game.Players.LocalPlayer
        player.Character.Humanoid.Health = math.huge -- Unverwundbar machen
        sendNotification("Godmode", "Godmode ist jetzt aktiv.")
    else
        -- Setze den Godmode-Status (z.B. Unverwundbarkeit deaktivieren)
        local player = game.Players.LocalPlayer
        player.Character.Humanoid.Health = 100 -- Zurücksetzen der Gesundheit
        sendNotification("Godmode", "Godmode ist jetzt deaktiviert.")
    end
end

-- Ereignis zum Überwachen von Tasteneingaben
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.P then
        toggleGodMode()
    end
end)

-- Sende eine Benachrichtigung, dass das Skript geladen wurde
sendNotification("TucoT9", "Das Skript wurde geladen. Drücke 'P' für Godmode.")
