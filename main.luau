-- Script taken from https://robloxscripts.com website --

local Deepsight = {}

Deepsight.Config = {
    Master = {
        Enabled = true,
        SelfMode = false,
        TeamCheck = false,
        ShowTeam = false,
        MaxDistance = 3000,
        RefreshRate = 144,
    },

    LOD = {
        Enabled = true,
        FullFidelityDist = 250,
    },

    VisibilityCheck = {
        Enabled = true,
        CacheInterval = 0.08,
        MaxRaycastDistance = 650,
        VisibleColor = Color3.fromRGB(60, 255, 120),
        OccludedColor = Color3.fromRGB(255, 55, 55),
    },

    TargetHUD = {
        Enabled = false,
        MaxScreenDistance = 350,
        OffsetFromBottom = 135,
        Width = 220,
        Height = 64,
    },

    SpectatorList = {
        Enabled = false,
        OffsetFromRight = 185,
        TopOffset = 40,
        Width = 165,
        DetectAiming = true,
    },

    Keybinds = {
        Enabled = true,
        MasterToggle = Enum.KeyCode.RightShift,
        Unload = Enum.KeyCode.End,
    },

    VelocityRay = {
        Enabled = false,
        LeadTime = 0.65,
        Thickness = 1.2,
        Color = Color3.fromRGB(0, 255, 200),
        MinSpeed = 4,
    },

    Radar = {
        Enabled = false,
        Position = Vector2.new(35, 35),
        Radius = 60,
        Range = 250,
        ClampAtEdge = true,
        BackgroundColor = Color3.fromRGB(15, 15, 20),
        BackgroundTransparency = 0.55,
        BorderColor = Color3.fromRGB(75, 80, 95),
        CrosshairColor = Color3.fromRGB(45, 50, 60),
        CenterDotColor = Color3.fromRGB(255, 255, 255),
        BlipSize = 3,
    },

    SoundVisualizer = {
        Enabled = false,
        Color = Color3.fromRGB(0, 210, 255),
        JumpColor = Color3.fromRGB(255, 130, 40),
        Duration = 0.85,
        MaxRadius = 6.0,
        StepInterval = 0.36,
        MaxConcurrentRings = 16,
    },

    OffscreenArrows = {
        Enabled = false,
        Radius = 0.72,
        Size = 13,
        CustomColor = nil,
    },

    LookVector = {
        Enabled = false,
        Length = 6,
        Thickness = 1.2,
        CustomColor = nil,
    },

    Weapon = {
        Enabled = true,
        Color = Color3.fromRGB(255, 215, 80),
    },

    Boxes = {
        Enabled = true,
        Style = "Corner", -- "Corner" | "2D" | "3D"
        Thickness = 1.5,
        CustomColor = nil,
    },

    Skeleton = {
        Enabled = true,
        Color = Color3.fromRGB(245, 245, 245),
        Thickness = 1.2,
        Transparency = 1,
    },

    Tracers = {
        Enabled = false,
        Mode = "All", -- "All" | "TargetOnly"
        Origin = "Bottom", -- "Bottom" | "Top" | "Center" | "Mouse"
        Thickness = 1,
        CustomColor = nil,
        TargetColor = Color3.fromRGB(255, 60, 60),
    },

    Crosshair = {
        Enabled = false,
        Style = "Cross", -- "Cross" | "T-Shape" | "DotOnly" | "Circle"
        Size = 8,
        Gap = 4,
        Thickness = 1.5,
        Color = Color3.fromRGB(0, 255, 180),
        CenterDot = true,
        DotSize = 2,
        DotColor = Color3.fromRGB(255, 255, 255),
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        OutlineThickness = 1,
        FollowMouse = false,
    },

    FOVCircle = {
        Enabled = false,
        Radius = 350,
        Thickness = 1,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.35,
        Filled = false,
        FollowMouse = true,
        DynamicColor = true,
        LockedColor = Color3.fromRGB(255, 60, 60),
    },

    ItemESP = {
        Enabled = false,
        Containers = { workspace },
        MaxDistance = 500,
        ShowDistance = true,
        ItemColor = Color3.fromRGB(255, 215, 80),
        ProjectileColor = Color3.fromRGB(255, 70, 70),
        Projectiles = { "Rocket", "Grenade", "Bomb", "Missile", "Bullet", "C4" },
        DrawBox = true,
        FontSize = 11,
    },

    Health = {
        Enabled = true,
        Style = "Bar", -- "Bar" | "Text" | "Both"
        Side = "Left", -- "Left" | "Right"
        TextSuffix = " HP",
    },

    Names = {
        Enabled = true,
        UseDisplayName = true,
        ShowDistance = true,
        DistanceUnit = "m", -- "m" | "studs"
        Size = 13,
        Font = 2,
        Outline = true,
    },

    Chams = {
        Enabled = false,
        FillColor = Color3.fromRGB(255, 40, 40),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillTransparency = 0.5,
        OutlineTransparency = 0.1,
        AlwaysOnTop = true,
    },

    Colors = {
        Enemy = Color3.fromRGB(255, 65, 65),
        Ally = Color3.fromRGB(65, 255, 120),
        Rainbow = false,
        RainbowSpeed = 1.0,
    },
}

-- handles
local v2, v3, cf = Vector2.new, Vector3.new, CFrame.new
local rgb, hsv = Color3.fromRGB, Color3.fromHSV
local insert, clear = table.insert, table.clear
local clock = os.clock

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local function draw(kind, props)
    local obj = Drawing.new(kind)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function w2s(worldPos)
    local pos, onScreen = camera:WorldToViewportPoint(worldPos)
    return v2(pos.X, pos.Y), onScreen, pos.Z
end

local Storage = {
    drawings = {},
    highlights = {},
    movement = {},
    visCache = {},
    ringPool = {},
    radar = {},
    targetHud = {},
    threatHud = { entries = {} },
    threatBuffer = {},
    crosshair = {},
    fov = {},
    items = {},
    itemConns = {},
    conns = {},
    rainbow = rgb(255, 255, 255),
    rayParams = RaycastParams.new(),
    rayIgnore = { camera, nil, nil },
}

Storage.rayParams.FilterType = Enum.RaycastFilterType.Exclude
Storage.rayParams.IgnoreWater = true

local function isVisible(char, targetPos, origin, dist, now)
    local cfg = Deepsight.Config.VisibilityCheck
    if not cfg.Enabled or dist > cfg.MaxRaycastDistance then
        return false
    end

    local tracker = Storage.visCache[char]
    if not tracker then
        tracker = { last = 0, hit = false }
        Storage.visCache[char] = tracker
    end

    if (now - tracker.last) < cfg.CacheInterval then
        return tracker.hit
    end
    tracker.last = now

    local ignore = Storage.rayIgnore
    ignore[1] = camera
    local count = 1
    if lp.Character then
        count = count + 1
        ignore[count] = lp.Character
    end
    if char then
        count = count + 1
        ignore[count] = char
    end
    for i = count + 1, #ignore do
        ignore[i] = nil
    end
    Storage.rayParams.FilterDescendantsInstances = ignore

    local res = Workspace:Raycast(origin, targetPos - origin, Storage.rayParams)
    tracker.hit = (res == nil)
    return tracker.hit
end

local function getColor(plr, vis)
    local cfg = Deepsight.Config
    if cfg.Colors.Rainbow then
        return Storage.rainbow
    end

    if plr == lp then
        return cfg.Colors.Ally
    end

    local isTeam = plr.Team ~= nil and lp.Team ~= nil and plr.Team == lp.Team
    if isTeam then
        return cfg.Colors.Ally
    end

    if cfg.VisibilityCheck.Enabled then
        return vis and cfg.VisibilityCheck.VisibleColor or cfg.VisibilityCheck.OccludedColor
    end

    return cfg.Colors.Enemy
end

local function getTracerOrigin(originType, vpX, vpY)
    if originType == "Bottom" then
        return v2(vpX * 0.5, vpY)
    elseif originType == "Top" then
        return v2(vpX * 0.5, 0)
    elseif originType == "Mouse" then
        return UserInputService:GetMouseLocation()
    end
    return v2(vpX * 0.5, vpY * 0.5)
end

local function initRings()
    local cfg = Deepsight.Config.SoundVisualizer
    for _ = 1, cfg.MaxConcurrentRings do
        insert(Storage.ringPool, {
            circle = draw("Circle", {
                Visible = false,
                Color = cfg.Color,
                Radius = 1,
                Filled = false,
                Thickness = 1.2,
                Transparency = 1,
            }),
            active = false,
            spawnTime = 0,
            maxRadius = cfg.MaxRadius,
            duration = cfg.Duration,
            pos = v3(),
            color = cfg.Color,
        })
    end
end

local function spawnRing(origin, color, maxRadius, duration, char)
    local now = clock()
    local spawnPos = origin
    if char then
        Storage.rayIgnore[1] = camera
        local count = 1
        if lp.Character then
            count = count + 1
            Storage.rayIgnore[count] = lp.Character
        end
        count = count + 1
        Storage.rayIgnore[count] = char
        for i = count + 1, #Storage.rayIgnore do
            Storage.rayIgnore[i] = nil
        end
        Storage.rayParams.FilterDescendantsInstances = Storage.rayIgnore

        local floorHit = Workspace:Raycast(origin + v3(0, 1, 0), v3(0, -5, 0), Storage.rayParams)
        if floorHit then
            spawnPos = floorHit.Position + v3(0, 0.05, 0)
        end
    end

    for _, ring in ipairs(Storage.ringPool) do
        if not ring.active then
            ring.active = true
            ring.spawnTime = now
            ring.pos = spawnPos
            ring.color = color or Deepsight.Config.SoundVisualizer.Color
            ring.maxRadius = maxRadius or Deepsight.Config.SoundVisualizer.MaxRadius
            ring.duration = duration or Deepsight.Config.SoundVisualizer.Duration
            return
        end
    end
end

local function updateRings(now)
    local cfg = Deepsight.Config.SoundVisualizer
    if not cfg.Enabled then
        for _, ring in ipairs(Storage.ringPool) do
            if ring.active then
                ring.active = false
                ring.circle.Visible = false
            end
        end
        return
    end

    for _, ring in ipairs(Storage.ringPool) do
        if ring.active then
            local age = now - ring.spawnTime
            if age >= ring.duration then
                ring.active = false
                ring.circle.Visible = false
            else
                local prog = age / ring.duration
                local currentRadius = ring.maxRadius * (prog ^ 0.5)
                local centerScr, centerOn, centerZ = w2s(ring.pos)

                if centerOn and centerZ > 0 then
                    local edgeScr = w2s(ring.pos + v3(currentRadius, 0, 0))
                    ring.circle.Position = centerScr
                    ring.circle.Radius = (edgeScr - centerScr).Magnitude
                    ring.circle.Color = ring.color
                    ring.circle.Transparency = 1 - prog
                    ring.circle.Visible = true
                else
                    ring.circle.Visible = false
                end
            end
        end
    end
end

local function initRadar()
    local cfg = Deepsight.Config.Radar
    Storage.radar = {
        bg = draw("Circle", {
            Position = cfg.Position,
            Radius = cfg.Radius,
            Filled = true,
            Color = cfg.BackgroundColor,
            Transparency = cfg.BackgroundTransparency,
            Visible = false,
        }),
        border = draw("Circle", {
            Position = cfg.Position,
            Radius = cfg.Radius,
            Filled = false,
            Color = cfg.BorderColor,
            Thickness = 1.5,
            Visible = false,
        }),
        crossH = draw("Line", {
            Color = cfg.CrosshairColor,
            Thickness = 1,
            Transparency = 0.7,
            Visible = false,
        }),
        crossV = draw("Line", {
            Color = cfg.CrosshairColor,
            Thickness = 1,
            Transparency = 0.7,
            Visible = false,
        }),
        centerDot = draw("Circle", {
            Position = cfg.Position,
            Radius = 2.5,
            Filled = true,
            Color = cfg.CenterDotColor,
            Visible = false,
        }),
    }
end

local function updateRadar(cfg, center)
    local hud = Storage.radar
    if not hud.bg then
        return
    end

    if not cfg.Master.Enabled or not cfg.Radar.Enabled then
        hud.bg.Visible = false
        hud.border.Visible = false
        hud.crossH.Visible = false
        hud.crossV.Visible = false
        hud.centerDot.Visible = false
        return
    end

    local r = cfg.Radar.Radius

    hud.bg.Position = center
    hud.bg.Radius = r
    hud.bg.Color = cfg.Radar.BackgroundColor
    hud.bg.Transparency = cfg.Radar.BackgroundTransparency
    hud.bg.Visible = true

    hud.border.Position = center
    hud.border.Radius = r
    hud.border.Color = cfg.Radar.BorderColor
    hud.border.Visible = true

    hud.crossH.From = center - v2(r, 0)
    hud.crossH.To = center + v2(r, 0)
    hud.crossH.Color = cfg.Radar.CrosshairColor
    hud.crossH.Visible = true

    hud.crossV.From = center - v2(0, r)
    hud.crossV.To = center + v2(0, r)
    hud.crossV.Color = cfg.Radar.CrosshairColor
    hud.crossV.Visible = true

    hud.centerDot.Position = center
    hud.centerDot.Color = cfg.Radar.CenterDotColor
    hud.centerDot.Visible = true
end

local function initTargetHud()
    Storage.targetHud = {
        bg = draw("Square", {
            Filled = true,
            Color = rgb(15, 16, 22),
            Transparency = 0.75,
            Visible = false,
        }),
        border = draw("Square", {
            Filled = false,
            Color = rgb(60, 65, 80),
            Thickness = 1,
            Visible = false,
        }),
        name = draw("Text", {
            Size = 13,
            Font = 2,
            Outline = true,
            Center = false,
            Color = rgb(255, 255, 255),
            Visible = false,
        }),
        hpOutline = draw("Square", {
            Filled = true,
            Color = rgb(0, 0, 0),
            Transparency = 0.7,
            Visible = false,
        }),
        hpFill = draw("Square", {
            Filled = true,
            Color = rgb(50, 255, 100),
            Transparency = 1,
            Visible = false,
        }),
        hpText = draw("Text", {
            Size = 11,
            Font = 2,
            Outline = true,
            Center = true,
            Color = rgb(255, 255, 255),
            Visible = false,
        }),
        details = draw("Text", {
            Size = 11,
            Font = 2,
            Outline = true,
            Center = false,
            Color = rgb(200, 210, 225),
            Visible = false,
        }),
        cachedTarget = nil,
        cachedHp = -1,
        cachedMaxHp = -1,
        cachedDist = -1,
        cachedSpeed = -1,
        cachedGun = nil,
    }
end

local function updateTargetHud(cfg, target, char, camPos)
    local hud = Storage.targetHud
    if not hud.bg then
        return
    end

    if not cfg.Master.Enabled or not cfg.TargetHUD.Enabled or not target or not char then
        hud.bg.Visible = false
        hud.border.Visible = false
        hud.name.Visible = false
        hud.hpOutline.Visible = false
        hud.hpFill.Visible = false
        hud.hpText.Visible = false
        hud.details.Visible = false
        hud.cachedTarget = nil
        return
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then
        hud.bg.Visible = false
        hud.border.Visible = false
        hud.name.Visible = false
        hud.hpOutline.Visible = false
        hud.hpFill.Visible = false
        hud.hpText.Visible = false
        hud.details.Visible = false
        hud.cachedTarget = nil
        return
    end

    local vp = camera.ViewportSize
    local cardW = cfg.TargetHUD.Width
    local cardH = cfg.TargetHUD.Height
    local pos = v2((vp.X * 0.5) - (cardW * 0.5), vp.Y - cfg.TargetHUD.OffsetFromBottom)

    hud.bg.Position = pos
    hud.bg.Size = v2(cardW, cardH)
    hud.bg.Visible = true

    hud.border.Position = pos
    hud.border.Size = v2(cardW, cardH)
    hud.border.Visible = true

    if hud.cachedTarget ~= target then
        hud.cachedTarget = target
        hud.name.Text = string.format("%s (@%s)", target.DisplayName, target.Name)
    end
    hud.name.Position = pos + v2(10, 8)
    hud.name.Visible = true

    local hp = math.clamp(hum.Health, 0, hum.MaxHealth)
    local pct = hum.MaxHealth > 0 and (hp / hum.MaxHealth) or 0
    local barW = cardW - 20
    local barH = 12
    local barPos = pos + v2(10, 27)

    hud.hpOutline.Position = barPos - v2(1, 1)
    hud.hpOutline.Size = v2(barW + 2, barH + 2)
    hud.hpOutline.Visible = true

    local r = pct < 0.5 and 255 or math.floor(255 * (1 - pct) * 2)
    local g = pct >= 0.5 and 255 or math.floor(255 * pct * 2)
    hud.hpFill.Position = barPos
    hud.hpFill.Size = v2(math.floor(barW * pct), barH)
    hud.hpFill.Color = rgb(r, g, 25)
    hud.hpFill.Visible = true

    local intHp = math.floor(hp)
    local intMaxHp = math.floor(hum.MaxHealth)
    if hud.cachedHp ~= intHp or hud.cachedMaxHp ~= intMaxHp then
        hud.cachedHp = intHp
        hud.cachedMaxHp = intMaxHp
        hud.hpText.Text = string.format("%d / %d HP [%d%%]", intHp, intMaxHp, math.floor(pct * 100))
    end
    hud.hpText.Position = barPos + v2(barW * 0.5, 0)
    hud.hpText.Visible = true

    local tool = char:FindFirstChildOfClass("Tool")
    local gun = tool and tool.Name or "None"
    local myChar = lp.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local refPos = myHrp and myHrp.Position or camPos
    local dist = math.floor((hrp.Position - refPos).Magnitude * 0.28)
    local speed = math.floor(v3(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude)

    if hud.cachedGun ~= gun or hud.cachedDist ~= dist or hud.cachedSpeed ~= speed then
        hud.cachedGun = gun
        hud.cachedDist = dist
        hud.cachedSpeed = speed
        hud.details.Text = string.format("Gun: %s  |  Dist: %dm  |  Speed: %d s/s", gun, dist, speed)
    end
    hud.details.Position = pos + v2(10, 46)
    hud.details.Visible = true
end

local function initThreatHud()
    local hud = {
        bg = draw("Square", {
            Filled = true,
            Color = rgb(15, 16, 22),
            Transparency = 0.75,
            Visible = false,
        }),
        border = draw("Square", {
            Filled = false,
            Color = rgb(60, 65, 80),
            Thickness = 1,
            Visible = false,
        }),
        title = draw("Text", {
            Size = 12,
            Font = 2,
            Outline = true,
            Center = false,
            Color = rgb(255, 255, 255),
            Visible = false,
        }),
        entries = {},
    }
    for _ = 1, 6 do
        insert(hud.entries, draw("Text", {
            Size = 11,
            Font = 2,
            Outline = true,
            Center = false,
            Visible = false,
        }))
    end
    Storage.threatHud = hud
end

local function updateThreatHud(cfg, threats)
    local hud = Storage.threatHud
    if not hud.bg then
        return
    end

    if not cfg.Master.Enabled or not cfg.SpectatorList.Enabled or #threats == 0 then
        hud.bg.Visible = false
        hud.border.Visible = false
        hud.title.Visible = false
        for _, entry in ipairs(hud.entries) do
            entry.Visible = false
        end
        return
    end

    local vp = camera.ViewportSize
    local width = cfg.SpectatorList.Width
    local height = 24 + (#threats * 16)
    local pos = v2(vp.X - cfg.SpectatorList.OffsetFromRight, cfg.SpectatorList.TopOffset)

    hud.bg.Position = pos
    hud.bg.Size = v2(width, height)
    hud.bg.Visible = true

    hud.border.Position = pos
    hud.border.Size = v2(width, height)
    hud.border.Visible = true

    hud.title.Text = string.format("THREATS (%d)", #threats)
    hud.title.Position = pos + v2(8, 6)
    hud.title.Visible = true

    for i = 1, 6 do
        local line = hud.entries[i]
        local t = threats[i]
        if t then
            line.Text = string.format("%s %s", t.name, t.status)
            line.Position = pos + v2(8, 22 + ((i - 1) * 15))
            line.Color = t.color
            line.Visible = true
        else
            line.Visible = false
        end
    end
end

local function initCrosshair()
    Storage.crosshair = {
        top = draw("Line", { Visible = false }),
        bottom = draw("Line", { Visible = false }),
        left = draw("Line", { Visible = false }),
        right = draw("Line", { Visible = false }),
        topOut = draw("Line", { Visible = false }),
        bottomOut = draw("Line", { Visible = false }),
        leftOut = draw("Line", { Visible = false }),
        rightOut = draw("Line", { Visible = false }),
        dot = draw("Circle", { Visible = false }),
        dotOut = draw("Circle", { Visible = false }),
        circle = draw("Circle", { Visible = false }),
        circleOut = draw("Circle", { Visible = false }),
    }
    Storage.fov = {
        circle = draw("Circle", { Visible = false }),
    }
end

local function updateCrosshair(cfg, hasTarget)
    local ch = Storage.crosshair
    local fov = Storage.fov
    local crossCfg = cfg.Crosshair
    local fovCfg = cfg.FOVCircle

    local vp = camera.ViewportSize
    local center = crossCfg.FollowMouse and UserInputService:GetMouseLocation() or v2(vp.X * 0.5, vp.Y * 0.5)

    if not cfg.Master.Enabled or not crossCfg.Enabled then
        ch.top.Visible = false; ch.bottom.Visible = false; ch.left.Visible = false; ch.right.Visible = false
        ch.topOut.Visible = false; ch.bottomOut.Visible = false; ch.leftOut.Visible = false; ch.rightOut.Visible = false
        ch.dot.Visible = false; ch.dotOut.Visible = false
        ch.circle.Visible = false; ch.circleOut.Visible = false
    else
        local s = crossCfg.Size
        local g = crossCfg.Gap
        local t = crossCfg.Thickness
        local clr = crossCfg.Color
        local outClr = crossCfg.OutlineColor
        local outThick = t + (crossCfg.OutlineThickness * 2)

        local style = crossCfg.Style
        if style == "Cross" or style == "T-Shape" then
            ch.circle.Visible = false
            ch.circleOut.Visible = false

            local function drawBar(line, outline, from, to)
                if crossCfg.Outline then
                    outline.From = from
                    outline.To = to
                    outline.Color = outClr
                    outline.Thickness = outThick
                    outline.Visible = true
                else
                    outline.Visible = false
                end
                line.From = from
                line.To = to
                line.Color = clr
                line.Thickness = t
                line.Visible = true
            end

            if style == "Cross" then
                drawBar(ch.top, ch.topOut, center - v2(0, g + s), center - v2(0, g))
            else
                ch.top.Visible = false
                ch.topOut.Visible = false
            end
            drawBar(ch.bottom, ch.bottomOut, center + v2(0, g), center + v2(0, g + s))
            drawBar(ch.left, ch.leftOut, center - v2(g + s, 0), center - v2(g, 0))
            drawBar(ch.right, ch.rightOut, center + v2(g, 0), center + v2(g + s, 0))
        elseif style == "Circle" then
            ch.top.Visible = false; ch.bottom.Visible = false; ch.left.Visible = false; ch.right.Visible = false
            ch.topOut.Visible = false; ch.bottomOut.Visible = false; ch.leftOut.Visible = false; ch.rightOut.Visible = false

            if crossCfg.Outline then
                ch.circleOut.Position = center
                ch.circleOut.Radius = s
                ch.circleOut.Thickness = outThick
                ch.circleOut.Color = outClr
                ch.circleOut.Filled = false
                ch.circleOut.Visible = true
            else
                ch.circleOut.Visible = false
            end
            ch.circle.Position = center
            ch.circle.Radius = s
            ch.circle.Thickness = t
            ch.circle.Color = clr
            ch.circle.Filled = false
            ch.circle.Visible = true
        else
            ch.top.Visible = false; ch.bottom.Visible = false; ch.left.Visible = false; ch.right.Visible = false
            ch.topOut.Visible = false; ch.bottomOut.Visible = false; ch.leftOut.Visible = false; ch.rightOut.Visible = false
            ch.circle.Visible = false; ch.circleOut.Visible = false
        end

        if crossCfg.CenterDot then
            if crossCfg.Outline then
                ch.dotOut.Position = center
                ch.dotOut.Radius = crossCfg.DotSize + crossCfg.OutlineThickness
                ch.dotOut.Color = outClr
                ch.dotOut.Filled = true
                ch.dotOut.Visible = true
            else
                ch.dotOut.Visible = false
            end
            ch.dot.Position = center
            ch.dot.Radius = crossCfg.DotSize
            ch.dot.Color = crossCfg.DotColor
            ch.dot.Filled = true
            ch.dot.Visible = true
        else
            ch.dot.Visible = false
            ch.dotOut.Visible = false
        end
    end

    if not cfg.Master.Enabled or not fovCfg.Enabled then
        fov.circle.Visible = false
    else
        local fovCenter = fovCfg.FollowMouse and UserInputService:GetMouseLocation() or v2(vp.X * 0.5, vp.Y * 0.5)
        local fovClr = (fovCfg.DynamicColor and hasTarget) and fovCfg.LockedColor or fovCfg.Color
        fov.circle.Position = fovCenter
        fov.circle.Radius = fovCfg.Radius
        fov.circle.Color = fovClr
        fov.circle.Thickness = fovCfg.Thickness
        fov.circle.Transparency = fovCfg.Transparency
        fov.circle.Filled = fovCfg.Filled
        fov.circle.Visible = true
    end
end

local function isProjectile(item, list)
    local name = item.Name:lower()
    for _, str in ipairs(list) do
        if name:find(str:lower()) then
            return true
        end
    end
    return false
end

local function getItemRoot(item)
    if item:IsA("Tool") then
        return item:FindFirstChild("Handle") or item:FindFirstChildOfClass("BasePart")
    elseif item:IsA("BasePart") then
        return item
    elseif item:IsA("Model") then
        return item.PrimaryPart or item:FindFirstChildOfClass("BasePart")
    end
    return nil
end

local function trackItem(item)
    if Storage.items[item] then
        return
    end
    local cfg = Deepsight.Config.ItemESP
    local part = getItemRoot(item)
    if not part then
        return
    end

    local isProj = isProjectile(item, cfg.Projectiles)
    if not (item:IsA("Tool") or isProj) then
        return
    end

    local d = {
        isProj = isProj,
        part = part,
        name = draw("Text", {
            Text = isProj and string.format("[!] %s", item.Name) or item.Name,
            Size = cfg.FontSize,
            Font = 2,
            Outline = true,
            Center = true,
            Visible = false,
        }),
        dist = draw("Text", {
            Size = cfg.FontSize - 2,
            Font = 2,
            Outline = true,
            Center = true,
            Color = rgb(220, 220, 220),
            Visible = false,
        }),
        box = draw("Square", {
            Color = isProj and cfg.ProjectileColor or cfg.ItemColor,
            Filled = false,
            Thickness = 1,
            Transparency = 1,
            Visible = false,
        }),
        cachedDist = -1,
        conns = {},
    }

    insert(d.conns, item.AncestryChanged:Connect(function(_, parent)
        if not parent then
            Deepsight.UntrackItem(item)
        end
    end))
    insert(d.conns, item.Destroying:Connect(function()
        Deepsight.UntrackItem(item)
    end))

    Storage.items[item] = d
end

function Deepsight.UntrackItem(item)
    local d = Storage.items[item]
    if d then
        for _, c in ipairs(d.conns) do
            if c and c.Connected then
                c:Disconnect()
            end
        end
        d.name:Remove()
        d.dist:Remove()
        d.box:Remove()
        Storage.items[item] = nil
    end
end

local function initItemEsp()
    local cfg = Deepsight.Config.ItemESP
    for _, container in ipairs(cfg.Containers) do
        if container and typeof(container) == "Instance" then
            for _, child in ipairs(container:GetChildren()) do
                trackItem(child)
            end
            insert(Storage.itemConns, container.ChildAdded:Connect(trackItem))
            insert(Storage.itemConns, container.ChildRemoved:Connect(Deepsight.UntrackItem))
        end
    end
end

local function updateItemEsp(cfg, camPos)
    local itemCfg = cfg.ItemESP
    if not cfg.Master.Enabled or not itemCfg.Enabled then
        for _, d in pairs(Storage.items) do
            d.name.Visible = false
            d.dist.Visible = false
            d.box.Visible = false
        end
        return
    end

    local maxDist = itemCfg.MaxDistance
    local showDist = itemCfg.ShowDistance

    for item, d in pairs(Storage.items) do
        local part = d.part
        if not part or not part.Parent then
            Deepsight.UntrackItem(item)
        else
            local pos = part.Position
            local dist = (pos - camPos).Magnitude
            if dist > maxDist then
                d.name.Visible = false
                d.dist.Visible = false
                d.box.Visible = false
            else
                local scr, onScreen, z = w2s(pos)
                if onScreen and z > 0 then
                    local clr = d.isProj and itemCfg.ProjectileColor or itemCfg.ItemColor
                    d.name.Position = scr - v2(0, 16)
                    d.name.Color = clr
                    d.name.Visible = true

                    if showDist then
                        local distM = math.floor(dist * 0.28)
                        if d.cachedDist ~= distM then
                            d.cachedDist = distM
                            d.dist.Text = string.format("[%dm]", distM)
                        end
                        d.dist.Position = scr + v2(0, 4)
                        d.dist.Visible = true
                    else
                        d.dist.Visible = false
                    end

                    if itemCfg.DrawBox then
                        local size = math.clamp(math.floor(250 / math.max(dist, 1)), 8, 24)
                        d.box.Position = scr - v2(size * 0.5, size * 0.5)
                        d.box.Size = v2(size, size)
                        d.box.Color = clr
                        d.box.Visible = true
                    else
                        d.box.Visible = false
                    end
                else
                    d.name.Visible = false
                    d.dist.Visible = false
                    d.box.Visible = false
                end
            end
        end
    end
end

local function cacheR15(d, char)
    if d.rigCached then
        return
    end
    if not d.rigAtts then
        d.rigAtts = {}
    end

    local names = {
        "NeckRigAttachment", "WaistRigAttachment",
        "LeftShoulderRigAttachment", "LeftElbowRigAttachment",
        "RightShoulderRigAttachment", "RightElbowRigAttachment",
        "LeftHipRigAttachment", "LeftKneeRigAttachment",
        "RightHipRigAttachment", "RightKneeRigAttachment"
    }
    local count = 0
    for _, name in ipairs(names) do
        local att = d.rigAtts[name]
        if not att or not att.Parent then
            att = char:FindFirstChild(name, true)
            if att and att:IsA("Attachment") then
                d.rigAtts[name] = att
            end
        end
        if d.rigAtts[name] then
            count = count + 1
        end
    end

    if count >= #names then
        d.rigCached = true
    end
end

local function cacheR6(d, torso)
    if d.motorsCached then
        return
    end

    local neck = torso:FindFirstChild("Neck")
    local ls = torso:FindFirstChild("Left Shoulder")
    local rs = torso:FindFirstChild("Right Shoulder")
    local lh = torso:FindFirstChild("Left Hip")
    local rh = torso:FindFirstChild("Right Hip")

    if neck and ls and rs and lh and rh then
        d.motorsCached = true
    end

    d.motors = {
        neck = neck,
        ls = ls,
        rs = rs,
        lh = lh,
        rh = rh,
    }
end

local function getMotorPos(motor)
    if motor and motor:IsA("Motor6D") and motor.Part0 then
        return motor.Part0.CFrame:PointToWorldSpace(motor.C0.Position)
    end
    return nil
end

local function getJoints(d, char, rigType)
    local joints = {}

    if rigType == Enum.HumanoidRigType.R15 then
        local head = char:FindFirstChild("Head")
        local uTorso = char:FindFirstChild("UpperTorso")
        local lTorso = char:FindFirstChild("LowerTorso")
        local lArm = char:FindFirstChild("LeftUpperArm")
        local lElb = char:FindFirstChild("LeftLowerArm")
        local rArm = char:FindFirstChild("RightUpperArm")
        local rElb = char:FindFirstChild("RightLowerArm")
        local lHip = char:FindFirstChild("LeftUpperLeg")
        local lKne = char:FindFirstChild("LeftLowerLeg")
        local rHip = char:FindFirstChild("RightUpperLeg")
        local rKne = char:FindFirstChild("RightLowerLeg")

        if not (head and uTorso and lTorso) then
            return nil
        end

        cacheR15(d, char)
        local atts = d.rigAtts

        joints.head = head.Position
        joints.neck = (atts.NeckRigAttachment and atts.NeckRigAttachment.WorldPosition) or (uTorso.CFrame * cf(0, uTorso.Size.Y * 0.5, 0)).Position
        joints.spine = (atts.WaistRigAttachment and atts.WaistRigAttachment.WorldPosition) or lTorso.Position
        joints.lShoulder = (atts.LeftShoulderRigAttachment and atts.LeftShoulderRigAttachment.WorldPosition) or (lArm and lArm.Position)
        joints.lElbow = (atts.LeftElbowRigAttachment and atts.LeftElbowRigAttachment.WorldPosition) or (lElb and lElb.Position)
        joints.rShoulder = (atts.RightShoulderRigAttachment and atts.RightShoulderRigAttachment.WorldPosition) or (rArm and rArm.Position)
        joints.rElbow = (atts.RightElbowRigAttachment and atts.RightElbowRigAttachment.WorldPosition) or (rElb and rElb.Position)
        joints.lHip = (atts.LeftHipRigAttachment and atts.LeftHipRigAttachment.WorldPosition) or (lHip and lHip.Position)
        joints.lKnee = (atts.LeftKneeRigAttachment and atts.LeftKneeRigAttachment.WorldPosition) or (lKne and lKne.Position)
        joints.rHip = (atts.RightHipRigAttachment and atts.RightHipRigAttachment.WorldPosition) or (rHip and rHip.Position)
        joints.rKnee = (atts.RightKneeRigAttachment and atts.RightKneeRigAttachment.WorldPosition) or (rKne and rKne.Position)
    else
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso")
        local lArm = char:FindFirstChild("Left Arm")
        local rArm = char:FindFirstChild("Right Arm")
        local lLeg = char:FindFirstChild("Left Leg")
        local rLeg = char:FindFirstChild("Right Leg")

        if not (head and torso) then
            return nil
        end

        cacheR6(d, torso)
        local m = d.motors

        joints.head = head.Position
        joints.neck = getMotorPos(m.neck) or (torso.CFrame * cf(0, 1, 0)).Position
        joints.spine = (torso.CFrame * cf(0, -1, 0)).Position
        joints.lShoulder = getMotorPos(m.ls) or (torso.CFrame * cf(-1.5, 0.5, 0)).Position
        joints.lElbow = lArm and (lArm.CFrame * cf(0, -1, 0)).Position
        joints.rShoulder = getMotorPos(m.rs) or (torso.CFrame * cf(1.5, 0.5, 0)).Position
        joints.rElbow = rArm and (rArm.CFrame * cf(0, -1, 0)).Position
        joints.lHip = getMotorPos(m.lh) or (torso.CFrame * cf(-0.5, -1, 0)).Position
        joints.lKnee = lLeg and (lLeg.CFrame * cf(0, -1, 0)).Position
        joints.rHip = getMotorPos(m.rh) or (torso.CFrame * cf(0.5, -1, 0)).Position
        joints.rKnee = rLeg and (rLeg.CFrame * cf(0, -1, 0)).Position
    end

    return joints
end

local function drawBone(line, posA, posB, color, thick, trans)
    if not posA or not posB then
        line.Visible = false
        return
    end

    local scrA, onA, zA = w2s(posA)
    local scrB, onB, zB = w2s(posB)

    if (not onA and not onB) or zA <= 0 or zB <= 0 then
        line.Visible = false
        return
    end

    line.From = scrA
    line.To = scrB
    line.Color = color
    line.Thickness = thick
    line.Transparency = trans
    line.Visible = true
end

local function renderArrow(tri, targetPos, color, cfg, vpCenter, vpRadius)
    local rel = camera.CFrame:PointToObjectSpace(targetPos)
    local angle = math.atan2(-rel.Y, rel.X)
    local dir = v2(math.cos(angle), math.sin(angle))

    local size = cfg.OffscreenArrows.Size
    local tip = vpCenter + (dir * vpRadius)
    local perp = v2(-dir.Y, dir.X)
    local base = tip - (dir * size)

    tri.PointA = tip
    tri.PointB = base + (perp * (size * 0.55))
    tri.PointC = base - (perp * (size * 0.55))
    tri.Color = color
    tri.Visible = true
end

local function createPlayerDrawings(plr)
    if (plr == lp and not Deepsight.Config.Master.SelfMode) or Storage.drawings[plr] then
        return
    end

    local cfg = Deepsight.Config
    local d = {
        hidden = false,
        boxCorners = {},
        box2d = {},
        box3d = {},
        hpOutline = draw("Square", { Filled = true, Color = rgb(0, 0, 0), Transparency = 0.7, Visible = false }),
        hpFill = draw("Square", { Filled = true, Color = rgb(0, 255, 0), Transparency = 1, Visible = false }),
        hpText = draw("Text", { Size = 12, Font = 2, Outline = true, Center = true, Visible = false }),
        name = draw("Text", { Size = cfg.Names.Size, Font = cfg.Names.Font, Outline = cfg.Names.Outline, Center = true, Visible = false }),
        dist = draw("Text", { Size = cfg.Names.Size - 2, Font = cfg.Names.Font, Outline = cfg.Names.Outline, Center = true, Visible = false }),
        weapon = draw("Text", { Size = cfg.Names.Size - 2, Font = cfg.Names.Font, Outline = cfg.Names.Outline, Center = true, Visible = false }),
        tracer = draw("Line", { Thickness = cfg.Tracers.Thickness, Visible = false }),
        lookRay = draw("Line", { Color = rgb(255, 255, 255), Thickness = cfg.LookVector.Thickness, Transparency = 1, Visible = false }),
        velRay = draw("Line", { Color = cfg.VelocityRay.Color, Thickness = cfg.VelocityRay.Thickness, Transparency = 1, Visible = false }),
        arrow = draw("Triangle", { Filled = true, Transparency = 0.9, Visible = false }),
        blip = draw("Circle", { Color = rgb(255, 60, 60), Radius = cfg.Radar.BlipSize, Filled = true, Visible = false }),
        skeleton = {},
        cachedDist = -1,
        cachedTool = nil,
        cachedHp = -1,
        rigCached = false,
        rigAtts = nil,
        motorsCached = false,
        motors = nil,
        lastChar = nil,
    }

    for _ = 1, 8 do
        insert(d.boxCorners, draw("Line", { Thickness = cfg.Boxes.Thickness, Visible = false }))
    end
    for _ = 1, 4 do
        insert(d.box2d, draw("Line", { Thickness = cfg.Boxes.Thickness, Visible = false }))
    end
    for _ = 1, 12 do
        insert(d.box3d, draw("Line", { Thickness = cfg.Boxes.Thickness, Visible = false }))
    end

    local boneKeys = {
        "headNeck", "spine", "lShoulder", "lArm", "rShoulder",
        "rArm", "pelvisLeft", "lLeg", "pelvisRight", "rLeg"
    }
    for _, key in ipairs(boneKeys) do
        d.skeleton[key] = draw("Line", {
            Color = cfg.Skeleton.Color,
            Thickness = cfg.Skeleton.Thickness,
            Transparency = cfg.Skeleton.Transparency,
            Visible = false,
        })
    end

    Storage.drawings[plr] = d
    Storage.movement[plr] = {
        lastStep = 0,
        grounded = true,
        lastPos = v3(),
    }

    local hl = Instance.new("Highlight")
    hl.Enabled = false
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Storage.highlights[plr] = hl
end

local function hidePlayer(d)
    if d.hidden then
        return
    end
    d.hidden = true

    for _, l in ipairs(d.boxCorners) do l.Visible = false end
    for _, l in ipairs(d.box2d) do l.Visible = false end
    for _, l in ipairs(d.box3d) do l.Visible = false end
    d.hpOutline.Visible = false
    d.hpFill.Visible = false
    d.hpText.Visible = false
    d.name.Visible = false
    d.dist.Visible = false
    d.weapon.Visible = false
    d.tracer.Visible = false
    d.lookRay.Visible = false
    d.velRay.Visible = false
    d.blip.Visible = false
    d.arrow.Visible = false

    for _, l in pairs(d.skeleton) do
        l.Visible = false
    end
end

local function removePlayer(plr)
    local d = Storage.drawings[plr]
    if d then
        for _, l in ipairs(d.boxCorners) do l:Remove() end
        for _, l in ipairs(d.box2d) do l:Remove() end
        for _, l in ipairs(d.box3d) do l:Remove() end
        d.hpOutline:Remove()
        d.hpFill:Remove()
        d.hpText:Remove()
        d.name:Remove()
        d.dist:Remove()
        d.weapon:Remove()
        d.tracer:Remove()
        d.lookRay:Remove()
        d.velRay:Remove()
        d.blip:Remove()
        d.arrow:Remove()
        for _, l in pairs(d.skeleton) do l:Remove() end
        Storage.drawings[plr] = nil
        Storage.movement[plr] = nil
    end

    local hl = Storage.highlights[plr]
    if hl then
        hl:Destroy()
        Storage.highlights[plr] = nil
    end
    if d and d.lastChar and Storage.visCache[d.lastChar] then
        Storage.visCache[d.lastChar] = nil
    end
end

local function render2DBox(lines, x, y, w, h, color, thick)
    lines[1].From = v2(x, y); lines[1].To = v2(x + w, y)
    lines[2].From = v2(x + w, y); lines[2].To = v2(x + w, y + h)
    lines[3].From = v2(x + w, y + h); lines[3].To = v2(x, y + h)
    lines[4].From = v2(x, y + h); lines[4].To = v2(x, y)

    for i = 1, 4 do
        lines[i].Color = color
        lines[i].Thickness = thick
        lines[i].Visible = true
    end
end

local function updatePlayer(plr, cfg, now, camCF, camPos, vpX, vpY, vpCenter, vpRadius, myRoot, radarCenter, radarScale, radarRadiusSq)
    local d = Storage.drawings[plr]
    if not d then
        return
    end

    local char = plr.Character
    if not char then
        hidePlayer(d)
        if Storage.highlights[plr] then
            Storage.highlights[plr].Enabled = false
        end
        return
    end

    if d.lastChar ~= char then
        if d.lastChar and Storage.visCache[d.lastChar] then
            Storage.visCache[d.lastChar] = nil
        end
        d.lastChar = char
        d.rigCached = false
        d.motorsCached = false
        d.rigAtts = nil
        d.motors = nil
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        hidePlayer(d)
        if Storage.highlights[plr] then
            Storage.highlights[plr].Enabled = false
        end
        return
    end

    local rootPos = hrp.Position
    local refPos = myRoot and myRoot.Position or camPos
    local dist = (rootPos - refPos).Magnitude
    if cfg.Master.MaxDistance > 0 and dist > cfg.Master.MaxDistance then
        hidePlayer(d)
        if Storage.highlights[plr] then
            Storage.highlights[plr].Enabled = false
        end
        return
    end

    local isSelf = (plr == lp)
    local isTeam = not isSelf and plr.Team ~= nil and lp.Team ~= nil and plr.Team == lp.Team
    if cfg.Master.TeamCheck and isTeam then
        hidePlayer(d)
        if Storage.highlights[plr] then
            Storage.highlights[plr].Enabled = false
        end
        return
    end

    local fullFidelity = not cfg.LOD.Enabled or (dist <= cfg.LOD.FullFidelityDist)

    -- sounds & footstep ripples
    if cfg.SoundVisualizer.Enabled and fullFidelity then
        local tracker = Storage.movement[plr]
        if tracker then
            local humState = hum:GetState()
            local runSnd = hrp:FindFirstChild("Running")
            local jumpSnd = hrp:FindFirstChild("Jumping")
            local landSnd = hrp:FindFirstChild("Landing")

            local isGrounded = (hum.FloorMaterial ~= Enum.Material.Air)
            local isMoving = (hum.MoveDirection.Magnitude > 0.1)

            local isJump = (humState == Enum.HumanoidStateType.Jumping) or (jumpSnd and jumpSnd.IsPlaying)
            local isLand = (humState == Enum.HumanoidStateType.Landed) or (landSnd and landSnd.IsPlaying)
            local isRun = (humState == Enum.HumanoidStateType.Running and isMoving) or (runSnd and runSnd.IsPlaying)

            local footPos = rootPos - v3(0, 2.5, 0)
            if isLand and not tracker.grounded then
                spawnRing(footPos, cfg.SoundVisualizer.JumpColor, cfg.SoundVisualizer.MaxRadius * 1.3, cfg.SoundVisualizer.Duration * 1.1, char)
            elseif isJump and tracker.grounded then
                spawnRing(footPos, cfg.SoundVisualizer.JumpColor, cfg.SoundVisualizer.MaxRadius * 1.2, cfg.SoundVisualizer.Duration, char)
            elseif isGrounded and isRun and (now - tracker.lastStep >= cfg.SoundVisualizer.StepInterval) then
                tracker.lastStep = now
                spawnRing(footPos, cfg.SoundVisualizer.Color, cfg.SoundVisualizer.MaxRadius, cfg.SoundVisualizer.Duration, char)
            end

            tracker.grounded = isGrounded
        end
    end

    local head = char:FindFirstChild("Head")
    local headPos = head and head.Position or rootPos
    local vis = isVisible(char, headPos, camPos, dist, now)
    local baseColor = getColor(plr, vis)

    -- radar blip
    if cfg.Radar.Enabled and not isSelf then
        local rel = camCF:PointToObjectSpace(rootPos)
        local blipX = rel.X * radarScale
        local blipY = rel.Z * radarScale
        local distSq = (blipX * blipX) + (blipY * blipY)

        if distSq <= radarRadiusSq then
            d.blip.Position = radarCenter + v2(blipX, blipY)
            d.blip.Color = baseColor
            d.blip.Visible = true
        elseif cfg.Radar.ClampAtEdge then
            local blipDist = math.sqrt(distSq)
            local clamped = v2(blipX / blipDist, blipY / blipDist) * (cfg.Radar.Radius - cfg.Radar.BlipSize)
            d.blip.Position = radarCenter + clamped
            d.blip.Color = baseColor
            d.blip.Visible = true
        else
            d.blip.Visible = false
        end
    else
        d.blip.Visible = false
    end

    local rootScr, onScreen, rootZ = w2s(rootPos)

    if not onScreen or rootZ <= 0 then
        hidePlayer(d)
        if Storage.highlights[plr] then
            Storage.highlights[plr].Enabled = false
        end

        if cfg.OffscreenArrows.Enabled and not isSelf then
            local arrowClr = cfg.OffscreenArrows.CustomColor or baseColor
            renderArrow(d.arrow, rootPos, arrowClr, cfg, vpCenter, vpRadius)
        end
        return
    else
        d.arrow.Visible = false
        d.hidden = false
    end

    local top, topOn = camera:WorldToViewportPoint(headPos + v3(0, 0.5, 0))
    local btm = camera:WorldToViewportPoint(rootPos - v3(0, 3, 0))

    local boxH = math.abs(top.Y - btm.Y)
    local boxW = boxH * 0.65
    local boxX = top.X - (boxW * 0.5)
    local boxY = math.min(top.Y, btm.Y)

    local boxClr = cfg.Boxes.CustomColor or baseColor
    local tracerClr = cfg.Tracers.CustomColor or baseColor

    -- boxes
    if cfg.Boxes.Enabled then
        if cfg.Boxes.Style == "Corner" then
            for _, l in ipairs(d.box2d) do l.Visible = false end
            for _, l in ipairs(d.box3d) do l.Visible = false end

            local cl = math.clamp(boxW * 0.25, 4, 18)
            local x1, y1 = boxX, boxY
            local x2, y2 = x1 + boxW, y1 + boxH
            local lines = d.boxCorners

            lines[1].From = v2(x1, y1); lines[1].To = v2(x1 + cl, y1)
            lines[2].From = v2(x1, y1); lines[2].To = v2(x1, y1 + cl)
            lines[3].From = v2(x2, y1); lines[3].To = v2(x2 - cl, y1)
            lines[4].From = v2(x2, y1); lines[4].To = v2(x2, y1 + cl)
            lines[5].From = v2(x1, y2); lines[5].To = v2(x1 + cl, y2)
            lines[6].From = v2(x1, y2); lines[6].To = v2(x1, y2 - cl)
            lines[7].From = v2(x2, y2); lines[7].To = v2(x2 - cl, y2)
            lines[8].From = v2(x2, y2); lines[8].To = v2(x2, y2 - cl)

            for i = 1, 8 do
                lines[i].Color = boxClr
                lines[i].Visible = true
            end
        elseif cfg.Boxes.Style == "2D" then
            for _, l in ipairs(d.boxCorners) do l.Visible = false end
            for _, l in ipairs(d.box3d) do l.Visible = false end
            render2DBox(d.box2d, boxX, boxY, boxW, boxH, boxClr, cfg.Boxes.Thickness)
        elseif cfg.Boxes.Style == "3D" then
            for _, l in ipairs(d.boxCorners) do l.Visible = false end

            local rootCF = hrp.CFrame
            local corners = {
                v3(-1.7, 2.5, -1.2), v3(1.7, 2.5, -1.2),
                v3(1.7, -3, -1.2),   v3(-1.7, -3, -1.2),
                v3(-1.7, 2.5, 1.2),  v3(1.7, 2.5, 1.2),
                v3(1.7, -3, 1.2),    v3(-1.7, -3, 1.2),
            }

            local scrCorners = {}
            local allValid = true
            for i = 1, 8 do
                local sPos, _, sZ = w2s((rootCF * cf(corners[i])).Position)
                if sZ <= 0 then
                    allValid = false
                    break
                end
                scrCorners[i] = sPos
            end

            if allValid then
                for _, l in ipairs(d.box2d) do l.Visible = false end
                local lines = d.box3d
                local function connect(idx, a, b)
                    lines[idx].From = scrCorners[a]
                    lines[idx].To = scrCorners[b]
                    lines[idx].Color = boxClr
                    lines[idx].Visible = true
                end
                connect(1, 1, 2); connect(2, 2, 3); connect(3, 3, 4); connect(4, 4, 1)
                connect(5, 5, 6); connect(6, 6, 7); connect(7, 7, 8); connect(8, 8, 5)
                connect(9, 1, 5); connect(10, 2, 6); connect(11, 3, 7); connect(12, 4, 8)
            else
                for _, l in ipairs(d.box3d) do l.Visible = false end
                render2DBox(d.box2d, boxX, boxY, boxW, boxH, boxClr, cfg.Boxes.Thickness)
            end
        end
    else
        for _, l in ipairs(d.boxCorners) do l.Visible = false end
        for _, l in ipairs(d.box2d) do l.Visible = false end
        for _, l in ipairs(d.box3d) do l.Visible = false end
    end

    -- velocity ray
    if cfg.VelocityRay.Enabled and fullFidelity then
        local vel = hrp.AssemblyLinearVelocity
        if vel.Magnitude >= cfg.VelocityRay.MinSpeed then
            local endPos = rootPos + (vel * cfg.VelocityRay.LeadTime)
            local scrA, onA, zA = w2s(rootPos)
            local scrB, onB, zB = w2s(endPos)

            if (onA or onB) and zA > 0 and zB > 0 then
                d.velRay.From = scrA
                d.velRay.To = scrB
                d.velRay.Visible = true
            else
                d.velRay.Visible = false
            end
        else
            d.velRay.Visible = false
        end
    else
        d.velRay.Visible = false
    end

    -- look ray
    if cfg.LookVector.Enabled and head and fullFidelity then
        local startWorld = head.Position
        local endWorld = startWorld + (head.CFrame.LookVector * cfg.LookVector.Length)
        local scrA, onA, zA = w2s(startWorld)
        local scrB, onB, zB = w2s(endWorld)

        if (onA or onB) and zA > 0 and zB > 0 then
            d.lookRay.From = scrA
            d.lookRay.To = scrB
            d.lookRay.Color = cfg.LookVector.CustomColor or baseColor
            d.lookRay.Visible = true
        else
            d.lookRay.Visible = false
        end
    else
        d.lookRay.Visible = false
    end

    -- tracers
    if cfg.Tracers.Enabled and not isSelf then
        local activeColor = (cfg.Tracers.Mode == "TargetOnly") and (cfg.Tracers.TargetColor or baseColor) or tracerClr
        d.tracer.From = getTracerOrigin(cfg.Tracers.Origin, vpX, vpY)
        d.tracer.To = v2(rootScr.X, boxY + boxH)
        d.tracer.Color = activeColor
        d.tracer.Visible = true
    else
        d.tracer.Visible = false
    end

    -- health bar
    if cfg.Health.Enabled then
        local hp = math.clamp(hum.Health, 0, hum.MaxHealth)
        local pct = hum.MaxHealth > 0 and (hp / hum.MaxHealth) or 0
        local barW = 3
        local barH = boxH
        local barX = (cfg.Health.Side == "Left") and (boxX - barW - 4) or (boxX + boxW + 4)
        local barY = boxY

        d.hpOutline.Position = v2(barX - 1, barY - 1)
        d.hpOutline.Size = v2(barW + 2, barH + 2)
        d.hpOutline.Visible = (cfg.Health.Style == "Bar" or cfg.Health.Style == "Both")

        local r = pct < 0.5 and 255 or math.floor(255 * (1 - pct) * 2)
        local g = pct >= 0.5 and 255 or math.floor(255 * pct * 2)
        local fillClr = rgb(r, g, 20)

        local fillH = math.floor(barH * pct)
        d.hpFill.Position = v2(barX, barY + (barH - fillH))
        d.hpFill.Size = v2(barW, fillH)
        d.hpFill.Color = fillClr
        d.hpFill.Visible = (cfg.Health.Style == "Bar" or cfg.Health.Style == "Both")

        if cfg.Health.Style == "Text" or cfg.Health.Style == "Both" then
            local intHp = math.floor(hp)
            if d.cachedHp ~= intHp then
                d.cachedHp = intHp
                d.hpText.Text = string.format("%d%s", intHp, cfg.Health.TextSuffix)
            end
            d.hpText.Position = v2(barX + (cfg.Health.Side == "Left" and -20 or 12), barY + (barH - fillH) - 6)
            d.hpText.Color = fillClr
            d.hpText.Visible = true
        else
            d.hpText.Visible = false
        end
    else
        d.hpOutline.Visible = false
        d.hpFill.Visible = false
        d.hpText.Visible = false
    end

    local currentY = boxY + boxH + 3

    -- name & dist
    if cfg.Names.Enabled then
        d.name.Text = cfg.Names.UseDisplayName and plr.DisplayName or plr.Name
        d.name.Position = v2(boxX + (boxW * 0.5), boxY - 16)
        d.name.Color = baseColor
        d.name.Visible = true

        if cfg.Names.ShowDistance then
            local distVal = cfg.Names.DistanceUnit == "m" and math.floor(dist * 0.28) or math.floor(dist)
            if d.cachedDist ~= distVal then
                d.cachedDist = distVal
                d.dist.Text = string.format("[%d %s]", distVal, cfg.Names.DistanceUnit)
            end
            d.dist.Position = v2(boxX + (boxW * 0.5), currentY)
            d.dist.Visible = true
            currentY = currentY + 13
        else
            d.dist.Visible = false
        end
    else
        d.name.Visible = false
        d.dist.Visible = false
    end

    -- weapon
    if cfg.Weapon.Enabled then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local toolName = tool.Name
            if d.cachedTool ~= toolName then
                d.cachedTool = toolName
                d.weapon.Text = string.format("[%s]", toolName)
            end
            d.weapon.Position = v2(boxX + (boxW * 0.5), currentY)
            d.weapon.Color = cfg.Weapon.Color
            d.weapon.Visible = true
        else
            d.weapon.Visible = false
            d.cachedTool = nil
        end
    else
        d.weapon.Visible = false
    end

    -- skeleton
    if cfg.Skeleton.Enabled and fullFidelity then
        local joints = getJoints(d, char, hum.RigType)
        if joints then
            local sClr = cfg.Skeleton.Color
            local sThick = cfg.Skeleton.Thickness
            local sTrans = cfg.Skeleton.Transparency
            local sk = d.skeleton

            drawBone(sk.headNeck, joints.head, joints.neck, sClr, sThick, sTrans)
            drawBone(sk.spine, joints.neck, joints.spine, sClr, sThick, sTrans)
            drawBone(sk.lShoulder, joints.neck, joints.lShoulder, sClr, sThick, sTrans)
            drawBone(sk.lArm, joints.lShoulder, joints.lElbow, sClr, sThick, sTrans)
            drawBone(sk.rShoulder, joints.neck, joints.rShoulder, sClr, sThick, sTrans)
            drawBone(sk.rArm, joints.rShoulder, joints.rElbow, sClr, sThick, sTrans)
            drawBone(sk.pelvisLeft, joints.spine, joints.lHip, sClr, sThick, sTrans)
            drawBone(sk.lLeg, joints.lHip, joints.lKnee, sClr, sThick, sTrans)
            drawBone(sk.pelvisRight, joints.spine, joints.rHip, sClr, sThick, sTrans)
            drawBone(sk.rLeg, joints.rHip, joints.rKnee, sClr, sThick, sTrans)
        else
            for _, l in pairs(d.skeleton) do l.Visible = false end
        end
    else
        for _, l in pairs(d.skeleton) do l.Visible = false end
    end

    -- chams
    local hl = Storage.highlights[plr]
    if hl then
        if cfg.Chams.Enabled then
            if hl.Parent ~= char then
                hl.Parent = char
            end
            hl.FillColor = cfg.Chams.FillColor
            hl.OutlineColor = cfg.Chams.OutlineColor
            hl.FillTransparency = cfg.Chams.FillTransparency
            hl.OutlineTransparency = cfg.Chams.OutlineTransparency
            hl.DepthMode = cfg.Chams.AlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            hl.Enabled = true
        else
            hl.Enabled = false
        end
    end
end

function Deepsight:Init()
    self:Unload()

    initRings()
    initRadar()
    initTargetHud()
    initThreatHud()
    initCrosshair()
    initItemEsp()

    local inputConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe or UserInputService:GetFocusedTextBox() then
            return
        end
        local cfg = Deepsight.Config
        if not cfg.Keybinds.Enabled then
            return
        end

        if input.KeyCode == cfg.Keybinds.MasterToggle then
            cfg.Master.Enabled = not cfg.Master.Enabled
        elseif input.KeyCode == cfg.Keybinds.Unload then
            Deepsight:Unload()
        end
    end)
    insert(Storage.conns, inputConn)

    insert(Storage.conns, Players.PlayerAdded:Connect(createPlayerDrawings))
    insert(Storage.conns, Players.PlayerRemoving:Connect(removePlayer))

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp or Deepsight.Config.Master.SelfMode then
            createPlayerDrawings(p)
        end
    end

    local lastUpdate = 0
    local renderConn = RunService.RenderStepped:Connect(function()
        local cfg = Deepsight.Config
        local now = clock()

        local interval = 1 / math.clamp(cfg.Master.RefreshRate, 1, 240)
        if now - lastUpdate < interval then
            return
        end
        lastUpdate = now

        if cfg.Colors.Rainbow then
            Storage.rainbow = hsv((now * cfg.Colors.RainbowSpeed) % 1, 0.8, 1)
        end

        local camCF = camera.CFrame
        local camPos = camCF.Position

        if not cfg.Master.Enabled then
            for _, d in pairs(Storage.drawings) do
                hidePlayer(d)
            end
            for _, hl in pairs(Storage.highlights) do
                hl.Enabled = false
            end
            updateTargetHud(cfg, nil, nil, camPos)
            updateCrosshair(cfg, false)
            updateItemEsp(cfg, camPos)
            return
        end

        local radarCenter = cfg.Radar.Position + v2(cfg.Radar.Radius, cfg.Radar.Radius)
        local radarScale = cfg.Radar.Radius / cfg.Radar.Range
        local radarRadiusSq = cfg.Radar.Radius * cfg.Radar.Radius

        updateRings(now)
        updateRadar(cfg, radarCenter)
        updateItemEsp(cfg, camPos)

        local vp = camera.ViewportSize
        local vpX, vpY = vp.X, vp.Y
        local vpCenter = v2(vpX * 0.5, vpY * 0.5)
        local vpRadius = math.min(vpCenter.X, vpCenter.Y) * math.clamp(cfg.OffscreenArrows.Radius, 0.3, 0.95)

        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local threats = Storage.threatBuffer
        clear(threats)
        local closestPlr = nil
        local closestChar = nil
        local closestDist = cfg.TargetHUD.MaxScreenDistance
        local mousePos = UserInputService:GetMouseLocation()

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp or cfg.Master.SelfMode then
                if not Storage.drawings[p] then
                    createPlayerDrawings(p)
                end
                updatePlayer(p, cfg, now, camCF, camPos, vpX, vpY, vpCenter, vpRadius, myRoot, radarCenter, radarScale, radarRadiusSq)

                if p ~= lp then
                    local char = p.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local isTeam = p.Team ~= nil and lp.Team ~= nil and p.Team == lp.Team
                        if not (cfg.Master.TeamCheck and isTeam) then
                            local scr, onScreen, z = w2s(hrp.Position)
                            if onScreen and z > 0 then
                                local screenDist = (scr - mousePos).Magnitude
                                if screenDist < closestDist then
                                    closestDist = screenDist
                                    closestPlr = p
                                    closestChar = char
                                end
                            end

                            if myRoot and cfg.SpectatorList.Enabled and cfg.SpectatorList.DetectAiming then
                                local head = char:FindFirstChild("Head")
                                local tool = char:FindFirstChildOfClass("Tool")
                                if head and tool then
                                    local toMe = (myRoot.Position - head.Position).Unit
                                    if head.CFrame.LookVector:Dot(toMe) > 0.95 then
                                        insert(threats, { name = p.DisplayName, status = "[AIMING AT YOU]", color = rgb(255, 75, 75) })
                                    end
                                end
                            end
                        end
                    end
                end
            elseif Storage.drawings[p] then
                hidePlayer(Storage.drawings[p])
            end
        end

        updateThreatHud(cfg, threats)

        if cfg.Tracers.Enabled and cfg.Tracers.Mode == "TargetOnly" then
            for p, d in pairs(Storage.drawings) do
                if p ~= closestPlr then
                    d.tracer.Visible = false
                end
            end
        end

        updateCrosshair(cfg, closestPlr ~= nil)
        updateTargetHud(cfg, closestPlr, closestChar, camPos)
    end)
    insert(Storage.conns, renderConn)
end

function Deepsight:Unload()
    for _, c in ipairs(Storage.conns) do
        if c and c.Connected then c:Disconnect() end
    end
    clear(Storage.conns)

    for _, c in ipairs(Storage.itemConns) do
        if c and c.Connected then c:Disconnect() end
    end
    clear(Storage.itemConns)

    for _, d in pairs(Storage.items) do
        d.name:Remove()
        d.dist:Remove()
        d.box:Remove()
    end
    clear(Storage.items)

    for _, obj in pairs(Storage.crosshair) do
        if obj and obj.Remove then obj:Remove() end
    end
    clear(Storage.crosshair)

    if Storage.fov.circle then
        Storage.fov.circle:Remove()
    end
    clear(Storage.fov)

    for _, ring in ipairs(Storage.ringPool) do
        if ring.circle then ring.circle:Remove() end
    end
    clear(Storage.ringPool)

    for _, obj in pairs(Storage.radar) do
        if obj and obj.Remove then obj:Remove() end
    end
    clear(Storage.radar)

    for _, obj in pairs(Storage.targetHud) do
        if obj and obj.Remove then obj:Remove() end
    end
    clear(Storage.targetHud)

    if Storage.threatHud.bg then
        Storage.threatHud.bg:Remove()
        Storage.threatHud.border:Remove()
        Storage.threatHud.title:Remove()
        for _, entry in ipairs(Storage.threatHud.entries) do
            entry:Remove()
        end
    end
    clear(Storage.threatHud)

    for p, _ in pairs(Storage.drawings) do
        removePlayer(p)
    end
    clear(Storage.drawings)
    clear(Storage.highlights)
    clear(Storage.movement)
    clear(Storage.visCache)
    clear(Storage.threatBuffer)
end

Deepsight:Init()

return Deepsight
