local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local EffectFolder = Instance.new("Folder")
EffectFolder.Name = "UniversalStarsEffect"
EffectFolder.Parent = workspace.CurrentCamera

local CONFIG = {
    STARS_PER_PLAYER = 6,
    MIN_RADIUS = 3.0,
    MAX_RADIUS = 6.5,
    MIN_HEIGHT = -1.5,
    MAX_HEIGHT = 3.5,
    MIN_SPEED = 1.0,
    MAX_SPEED = 2.5,
    MIN_LIFETIME = 3.0,
    MAX_LIFETIME = 6.0,
    BASE_STAR_SIZE = 1.2,
}

local STAR_TEXTURE = "rbxassetid://7743868000"

local activeEffects = {}

local function generateStarData()
    return {
        angle = math.random() * math.pi * 2,
        speed = (math.random() > 0.5 and 1 or -1) * (math.random(CONFIG.MIN_SPEED * 10, CONFIG.MAX_SPEED * 10) / 10),
        radius = math.random(CONFIG.MIN_RADIUS * 10, CONFIG.MAX_RADIUS * 10) / 10,
        height = math.random(CONFIG.MIN_HEIGHT * 10, CONFIG.MAX_HEIGHT * 10) / 10,
        lifetime = math.random(CONFIG.MIN_LIFETIME * 10, CONFIG.MAX_LIFETIME * 10) / 10,
        age = 0,
        pulseSpeed = math.random(3, 7),
        rotSpeed = math.random(30, 90) * (math.random() > 0.5 and 1 or -1),
        bobSpeed = math.random(15, 35) / 10,
    }
end

local function createStarInstance()
    local part = Instance.new("Part")
    part.Name = "GlowStar"
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Parent = EffectFolder

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 255, 255)
    light.Range = 4
    light.Brightness = 1.5
    light.Parent = part

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(CONFIG.BASE_STAR_SIZE, 0, CONFIG.BASE_STAR_SIZE, 0)
    billboard.AlwaysOnTop = false
    billboard.LightInfluence = 0
    billboard.Parent = part

    local image = Instance.new("ImageLabel")
    image.BackgroundTransparency = 1
    image.Image = STAR_TEXTURE
    image.ImageColor3 = Color3.fromRGB(255, 255, 255)
    image.Size = UDim2.new(1, 0, 1, 0)
    image.Parent = billboard

    return {
        Part = part,
        Light = light,
        Billboard = billboard,
        Image = image,
        Data = generateStarData()
    }
end

local function attachEffect(character)
    if not character then return end
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    if activeEffects[character] then
        for _, starObj in ipairs(activeEffects[character].stars) do
            if starObj.Part then starObj.Part:Destroy() end
        end
    end

    local stars = {}
    for i = 1, CONFIG.STARS_PER_PLAYER do
        table.insert(stars, createStarInstance())
    end

    activeEffects[character] = {
        root = root,
        stars = stars
    }
end

local function removeEffect(character)
    if activeEffects[character] then
        for _, starObj in ipairs(activeEffects[character].stars) do
            if starObj.Part then
                starObj.Part:Destroy()
            end
        end
        activeEffects[character] = nil
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        attachEffect(char)
    end)

    player.CharacterRemoving:Connect(function(char)
        removeEffect(char)
    end)

    if player.Character then
        attachEffect(player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

Players.PlayerRemoving:Connect(function(player)
    if player.Character then
        removeEffect(player.Character)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    for character, data in pairs(activeEffects) do
        local root = data.root
        if not root or not root.Parent then
            removeEffect(character)
            continue
        end

        local rootPos = root.Position

        for _, starObj in ipairs(data.stars) do
            local sData = starObj.Data
            sData.age = sData.age + dt

            if sData.age >= sData.lifetime then
                starObj.Data = generateStarData()
                sData = starObj.Data
            end

            sData.angle = sData.angle + (sData.speed * dt)

            local fadeDuration = 0.5
            local alpha = 1
            if sData.age < fadeDuration then
                alpha = sData.age / fadeDuration
            elseif sData.age > (sData.lifetime - fadeDuration) then
                alpha = (sData.lifetime - sData.age) / fadeDuration
            end
            alpha = math.clamp(alpha, 0, 1)

            local pulse = (math.sin(sData.age * sData.pulseSpeed) + 1) * 0.5
            local currentScale = (0.7 + pulse * 0.6) * alpha
            local currentTransparency = 1 - (alpha * (0.8 + pulse * 0.2))

            local bobbing = math.sin(sData.age * sData.bobSpeed) * 0.4
            local currentHeight = sData.height + bobbing

            local x = math.cos(sData.angle) * sData.radius
            local z = math.sin(sData.angle) * sData.radius
            local finalPos = rootPos + Vector3.new(x, currentHeight, z)

            starObj.Part.Position = finalPos
            starObj.Image.ImageTransparency = currentTransparency
            starObj.Image.Rotation = starObj.Image.Rotation + (sData.rotSpeed * dt)
            starObj.Billboard.Size = UDim2.new(
                CONFIG.BASE_STAR_SIZE * currentScale, 0, 
                CONFIG.BASE_STAR_SIZE * currentScale, 0
            )
            starObj.Light.Brightness = alpha * (1.2 + pulse * 1.5)
        end
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Бурмалда",
        Text = "Много бурмалды",
        Duration = 4
    })
end)
