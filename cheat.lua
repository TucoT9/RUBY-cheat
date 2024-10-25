--[[ 
   WARNUNG: Dieses Skript wurde nicht von ScriptBlox überprüft. Verwendung auf eigene Gefahr! 
   Skript erstellt von TucoT9 
]]

-- Setze Hitbox-Größe, Transparenz-Level und Benachrichtigungsstatus
local size = Vector3.new(25, 25, 25)
local trans = 1
local notifications = false

-- Speichere die Startzeit, zu der der Code ausgeführt wird
local start = os.clock()

-- Sende eine Benachrichtigung, dass das Skript geladen wird
game.StarterGui:SetCore("SendNotification", {
   Title = "TucoT9",
   Text = "Der Cheat ist am injecten...",
   Icon = "",
   Duration = 5
})

-- Laden der ESP-Einheit
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/TucoT9/RUBY-cheat/main/esp.lua"))()
esp:Toggle(true)

-- Konfiguration der ESP-Einstellungen
esp.Boxes = true
esp.Names = false
esp.Tracers = false
esp.Players = false

-- Füge einen Objekt-Listener zum Workspace hinzu, um feindliche Modelle zu erkennen
esp:AddObjectListener(workspace, {
   Name = "soldier_model",
   Type = "Model",
   Color = Color3.fromRGB(255, 0, 0),  -- Leuchtend Rot

   -- Bestimme das primäre Teil des Modells als den HumanoidRootPart
   PrimaryPart = function(obj)
       local root
       repeat
           root = obj:FindFirstChild("HumanoidRootPart")
           task.wait()
       until root
       return root
   end,

   -- Verwende eine Validierungsfunktion, um sicherzustellen, dass Modelle nicht das Kind "friendly_marker" enthalten
   Validator = function(obj)
       task.wait(1)
       if obj:FindFirstChild("friendly_marker") then
           return false
       end
       return true
   end,

   -- Setze einen benutzerdefinierten Namen für die feindlichen Modelle
   CustomName = "?",
   -- Aktiviere die ESP für feindliche Modelle
   IsEnabled = "enemy"
})

-- Aktiviere die ESP für feindliche Modelle
esp.enemy = true

-- Warte, bis das Spiel vollständig geladen ist, bevor Hitboxen angewendet werden
task.wait(1)

-- Wende Hitboxen auf alle vorhandenen feindlichen Modelle im Workspace an
for _, v in pairs(workspace:GetDescendants()) do
   if v.Name == "soldier_model" and v:IsA("Model") and not v:FindFirstChild("friendly_marker") then
       local pos = v:FindFirstChild("HumanoidRootPart").Position
       for _, bp in pairs(workspace:GetChildren()) do
           if bp:IsA("BasePart") then
               local distance = (bp.Position - pos).Magnitude
               if distance <= 5 then
                   bp.Transparency = trans
                   bp.Size = size
               end
           end
       end
   end
end

-- Funktion, um zu behandeln, wenn ein neuer Nachkomme zum Workspace hinzugefügt wird
local function handleDescendantAdded(descendant)
   task.wait(1)

   -- Wenn der neue Nachkomme ein feindliches Modell ist und Benachrichtigungen aktiviert sind, sende eine Benachrichtigung
   if descendant.Name == "soldier_model" and descendant:IsA("Model") and not descendant:FindFirstChild("friendly_marker") then
       if notifications then
           game.StarterGui:SetCore("SendNotification", {
               Title = "Skript",
               Text = "[Warnung] Neuer Feind gespawnt! Hitboxen angewendet.",
               Icon = "",
               Duration = 3
           })
       end

       -- Wende Hitboxen auf das neue feindliche Modell an
       local pos = descendant:FindFirstChild("HumanoidRootPart").Position
       for _, bp in pairs(workspace:GetChildren()) do
           if bp:IsA("BasePart") then
               local distance = (bp.Position - pos).Magnitude
               if distance <= 5 then
                   bp.Transparency = trans
                   bp.Size = size
               end
           end
       end
   end
end

-- Verbinde die Funktion handleDescendantAdded mit dem Ereignis DescendantAdded des Workspace
task.spawn(function()
   game.Workspace.DescendantAdded:Connect(handleDescendantAdded)
end)

-- Godmode-Funktionalität
local godModeEnabled = false

local function toggleGodMode()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        game.Players.LocalPlayer.Character.Humanoid.MaxHealth = math.huge
        game.Players.LocalPlayer.Character.Humanoid.Health = math.huge
        game.StarterGui:SetCore("SendNotification", {
            Title = "Godmode",
            Text = "Godmode aktiviert!",
            Icon = "",
            Duration = 5
        })
    else
        game.Players.LocalPlayer.Character.Humanoid.MaxHealth = 100
        game.Players.LocalPlayer.Character.Humanoid.Health = 100
        game.StarterGui:SetCore("SendNotification", {
            Title = "Godmode",
            Text = "Godmode deaktiviert!",
            Icon = "",
            Duration = 5
        })
    end
end

-- Tasteneingabe für Godmode
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        toggleGodMode()
    end
end)

-- FPS-Anzeige erstellen
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(0, 100, 0, 50)
fpsLabel.Position = UDim2.new(0.8, 0, 0, 0)  -- Position oben rechts
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextScaled = true
fpsLabel.Text = "FPS: 0"
fpsLabel.Parent = game.CoreGui
fpsLabel.BackgroundTransparency = 0.5  -- Leicht transparent

-- Funktion zur Aktualisierung der FPS-Anzeige
local lastTick = tick()
local frameCount = 0
local updateInterval = 1  -- Interval für die FPS-Aktualisierung in Sekunden

-- Starte die FPS-Anzeige
task.spawn(function()
    while true do
        frameCount = frameCount + 1
        wait(0.03)  -- Grob 30 FPS
        if tick() - lastTick >= updateInterval then
            local fps = frameCount / (tick() - lastTick)
            fpsLabel.Text = string.format("FPS: %.2f", fps)
            frameCount = 0
            lastTick = tick()
        end
    end
end)

-- Speichere die Endzeit, zu der der Code ausgeführt wird
local finish = os.clock()

-- Berechne, wie lange der Code benötigt hat, und bestimme eine Bewertung für die Ladegeschwindigkeit
local time = finish - start
local rating
if time < 3 then
    rating = "schnell"
elseif time < 5 then
    rating = "akzeptabel"
else
    rating = "langsam"
end

-- Sende eine Benachrichtigung, wie lange das Skript zum Laden benötigt hat und dessen Bewertung
game.StarterGui:SetCore("SendNotification", {
    Title = "TucoT9",
    Text = string.format("Cheat wurde in %.2f Sekunden (%s injected)", time, rating),
    Icon = "",
    Duration = 5
})
