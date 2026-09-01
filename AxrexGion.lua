local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxrexGion"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(0, 220, 0, 40)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.AnchorPoint = Vector2.new(0, 0)
Frame.Parent = ScreenGui
Frame.ClipsDescendants = true
Frame.AutoLocalize = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local TextLabel = Instance.new("TextLabel")
TextLabel.BackgroundTransparency = 1
TextLabel.Size = UDim2.new(1, -20, 1, 0)
TextLabel.Position = UDim2.new(0, 10, 0, 0)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextSize = 18
TextLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
TextLabel.TextStrokeTransparency = 0.65
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.TextYAlignment = Enum.TextYAlignment.Center
TextLabel.Parent = Frame

local lastTime = tick()
local frameCount = 0
local fps = 0

RunService.Heartbeat:Connect(function(deltaTime)
    frameCount = frameCount + 1
    if tick() - lastTime >= 1 then
        fps = frameCount
        frameCount = 0
        lastTime = tick()
        TextLabel.Text = string.format("AxrexGion | %d FPS | v1", fps)
    end
end)

for _, light in ipairs(workspace:GetDescendants()) do
    if light:IsA("Light") then
        light.Enabled = false
    end
end

setfflag("TaskSchedulerTargetFps", "100000")

for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    elseif obj:IsA("ParticleEmitter") then
        obj:Destroy()
    elseif obj:IsA("Trail") then
        obj:Destroy()
    elseif obj:IsA("Smoke") or obj:IsA("Fire") then
        obj:Destroy()
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        obj.Material = Enum.Material.Plastic
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        obj.Shadows = false
    end
end

print("Finished FPS Boost. Credit to RainbowTickleBlaster")
