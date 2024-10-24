--[[ 
    Erstellt von TucoT9
    Hinweis: Verwenden auf eigene Gefahr!
]] 

-- ESP Einstellungen
local ESP = {
    Enabled = false,
    BoxSettings = {
        Enabled = true,
        Size = Vector3.new(4, 6, 0),
        Shift = CFrame.new(0, -1.5, 0),
        Color = Color3.fromRGB(255, 0, 255),  -- Leuchtendes Magenta
        Thickness = 2,
    },
    NameSettings = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255), -- Weiß
        Size = 19,
    },
    DistanceSettings = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255), -- Weiß
        Size = 19,
    },
    TeamSettings = {
        Enabled = true,
        UseTeamColor = true,
    },
    TracerSettings = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0), -- Rot
        Thickness = 2,
    },
    Objects = {},
}

-- Deklarationen
local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer

-- Funktionen
local function Draw(obj, props)
    local new = Drawing.new(obj)
    for i, v in pairs(props) do
        new[i] = v
    end
    return new
end

function ESP:GetTeam(player)
    return player and player.Team
end

function ESP:IsTeamMate(player)
    return self:GetTeam(player) == self:GetTeam(plr)
end

function ESP:GetColor(player)
    if self.TeamSettings.UseTeamColor and player.Team then
        return player.Team.TeamColor.Color
    end
    return self.BoxSettings.Color
end

function ESP:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for _, box in pairs(self.Objects) do
            box:Remove()
        end
    end
end

function ESP:AddObject(obj)
    if not obj:IsA("Model") or not obj:FindFirstChild("Humanoid") then return end

    local box = {
        Object = obj,
        Components = {},
        Name = obj.Name,
        Color = self:GetColor(plrs:GetPlayerFromCharacter(obj)),
    }

    -- Box erstellen
    box.Components.Quad = Draw("Quad", {
        Thickness = self.BoxSettings.Thickness,
        Color = box.Color,
        Transparency = 1,
        Visible = self.Enabled and self.BoxSettings.Enabled,
    })

    -- Name erstellen
    box.Components.Name = Draw("Text", {
        Text = box.Name,
        Color = self.NameSettings.Color,
        Center = true,
        Outline = true,
        Size = self.NameSettings.Size,
        Visible = self.Enabled and self.NameSettings.Enabled,
    })

    -- Distanz erstellen
    box.Components.Distance = Draw("Text", {
        Color = self.DistanceSettings.Color,
        Center = true,
        Outline = true,
        Size = self.DistanceSettings.Size,
        Visible = self.Enabled and self.DistanceSettings.Enabled,
    })

    self.Objects[obj] = box

    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            box:Remove()
        end
    end)
end

function ESP:Update()
    if not self.Enabled then return end

    for _, box in pairs(self.Objects) do
        local cf = box.Object.PrimaryPart.CFrame
        local size = self.BoxSettings.Size
        local locs = {
            TopLeft = cf * self.BoxSettings.Shift * CFrame.new(size.X/2, size.Y/2, 0),
            TopRight = cf * self.BoxSettings.Shift * CFrame.new(-size.X/2, size.Y/2, 0),
            BottomLeft = cf * self.BoxSettings.Shift * CFrame.new(size.X/2, -size.Y/2, 0),
            BottomRight = cf * self.BoxSettings.Shift * CFrame.new(-size.X/2, -size.Y/2, 0),
            TagPos = cf * self.BoxSettings.Shift * CFrame.new(0, size.Y/2, 0),
        }

        -- Update Box
        local TL, Vis1 = cam:WorldToViewportPoint(locs.TopLeft.Position)
        local TR, Vis2 = cam:WorldToViewportPoint(locs.TopRight.Position)
        local BL, Vis3 = cam:WorldToViewportPoint(locs.BottomLeft.Position)
        local BR, Vis4 = cam:WorldToViewportPoint(locs.BottomRight.Position)

        box.Components.Quad.Visible = Vis1 or Vis2 or Vis3 or Vis4
        if box.Components.Quad.Visible then
            box.Components.Quad.PointA = Vector2.new(TR.X, TR.Y)
            box.Components.Quad.PointB = Vector2.new(TL.X, TL.Y)
            box.Components.Quad.PointC = Vector2.new(BL.X, BL.Y)
            box.Components.Quad.PointD = Vector2.new(BR.X, BR.Y)
            box.Components.Quad.Color = box.Color
        end

        -- Update Name
        local TagPos, Vis5 = cam:WorldToViewportPoint(locs.TagPos.Position)
        box.Components.Name.Visible = Vis5
        if Vis5 then
            box.Components.Name.Position = Vector2.new(TagPos.X, TagPos.Y)
            box.Components.Name.Text = box.Name
        end

        -- Update Distance
        box.Components.Distance.Visible = Vis5
        if Vis5 then
            box.Components.Distance.Position = Vector2.new(TagPos.X, TagPos.Y + 14)
            box.Components.Distance.Text = math.floor((cam.CFrame.Position - cf.Position).magnitude) .. "m entfernt"
        end
    end
end

-- Render-Stepped Verbindung
game:GetService("RunService").RenderStepped:Connect(function()
    ESP:Update()
end)

return ESP

