--[[ 
   WARNUNG: Dieses Skript wurde nicht von ScriptBlox überprüft. Verwendung auf eigene Gefahr! 
   Skript erstellt von TucoT9 
]]

-- Setze Hitbox-Größe, Transparenz-Level und Benachrichtigungsstatus
local size = Vector3.new(10, 10, 10)
local trans = 1
local notifications = false
 
-- Speichere die Startzeit, zu der der Code ausgeführt wird
local start = os.clock()

-- Sende eine Benachrichtigung, dass das Skript geladen wird
game.StarterGui:SetCore("SendNotification", {
   Title = "TucoT9",
   Text = "Skript wird geladen...",
   Icon = "",
   Duration = 5
})

-- Laden der ESP-Einheit
local esp = loadstring(game:HttpGet("https://raw.githubusercontent.com/andrewc0de/Roblox/main/Dependencies/ESP.lua"))()
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
   Color = Color3.fromRGB(255, 0, 4),

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
   Text = string.format("Skript geladen in %.2f Sekunden (%s Laden)", time, rating),
   Icon = "",
   Duration = 5
})