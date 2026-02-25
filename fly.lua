-- GABUNGAN SCRIPT FLY + UI

-- [SERVER BAGIAN] (Opsional, kalo mau ada status game)
-- ... (kalo ada)

-- [CLIENT BAGIAN - FLY FUNCTION]
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local IsFlying = false
local FlySpeed = 15
local FlyForce = 500
local OriginalGravity = workspace.Gravity
local FlyBodyVelocity = nil

-- [CLIENT BAGIAN - FLY FUNCTION] (lanjutan)
-- ... (fungsi StartFlying, StopFlying, dll)

-- [CLIENT BAGIAN - UI HANDLER]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateGameStatusEvent = Instance.new("RemoteEvent")
UpdateGameStatusEvent.Name = "UpdateGameStatus"
UpdateGameStatusEvent.Parent = ReplicatedStorage

-- [SETUP UI - TARUH DI fly.lua JUGA]
local function createFlyUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local FlyGui = Instance.new("ScreenGui")
    FlyGui.Name = "FlyGui"
    FlyGui.Parent = PlayerGui
    FlyGui.ResetOnSpawn = false

    -- Label Status
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = FlyGui
    StatusLabel.BackgroundColor3 = Color3.new(0,0,0)
    StatusLabel.BackgroundTransparency = 0.5
    StatusLabel.BorderSizePixel = 0
    StatusLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
    StatusLabel.Size = UDim2.new(0.8, 0, 0.05, 0)
    StatusLabel.Text = "Script Fly Ready"
    StatusLabel.TextColor3 = Color3.new(1,1,1)
    StatusLabel.TextScaled = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    StatusLabel.ZIndex = 10

    -- Label Aktif/Nonaktif
    local FlyStatusLabel = Instance.new("TextLabel")
    FlyStatusLabel.Name = "FlyStatusLabel"
    FlyStatusLabel.Parent = FlyGui
    FlyStatusLabel.BackgroundColor3 = Color3.new(0,0,0)
    FlyStatusLabel.BackgroundTransparency = 0.5
    FlyStatusLabel.BorderSizePixel = 0
    FlyStatusLabel.Position = UDim2.new(0.5, 0, 0.15, 0)
    FlyStatusLabel.Size = UDim2.new(0.8, 0, 0.05, 0)
    FlyStatusLabel.Text = "Status: Nonaktif"
    FlyStatusLabel.TextColor3 = Color3.new(1,1,1)
    FlyStatusLabel.TextScaled = true
    FlyStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    FlyStatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    FlyStatusLabel.ZIndex = 10

    -- Label Speed
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Name = "SpeedLabel"
    SpeedLabel.Parent = FlyGui
    SpeedLabel.BackgroundColor3 = Color3.new(0,0,0)
    SpeedLabel.BackgroundTransparency = 0.5
    SpeedLabel.BorderSizePixel = 0
    SpeedLabel.Position = UDim2.new(0.5, 0, 0.2, 0)
    SpeedLabel.Size = UDim2.new(0.8, 0, 0.05, 0)
    SpeedLabel.Text = "Speed: " .. FlySpeed
    SpeedLabel.TextColor3 = Color3.new(1,1,1)
    SpeedLabel.TextScaled = true
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedLabel.TextYAlignment = Enum.TextYAlignment.Center
    SpeedLabel.ZIndex = 10

    -- Tombol Aktif/Nonaktif
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = FlyGui
    ToggleButton.BackgroundColor3 = Color3.new(0,1,0)
    ToggleButton.BackgroundTransparency = 0.3
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0.5, 0, 0.9, 0)
    ToggleButton.Size = UDim2.new(0.2, 0, 0.05, 0)
    ToggleButton.Text = "Aktifkan (Q)"
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.TextScaled = true
    ToggleButton.ZIndex = 10
    ToggleButton.MouseButton1Click:Connect(function()
        if not IsFlying then
            StartFlying()
            ToggleButton.Text = "Nonaktifkan (E)"
            ToggleButton.BackgroundColor3 = Color3.new(1,0,0)
            FlyStatusLabel.Text = "Status: Aktif"
        else
            StopFlying()
            ToggleButton.Text = "Aktifkan (Q)"
            ToggleButton.BackgroundColor3 = Color3.new(0,1,0)
            FlyStatusLabel.Text = "Status: Nonaktif"
        end
    end)

    -- Slider Speed (opsional, buat ngatur kecepatan)
    local SpeedSlider = Instance.new("Frame")
    SpeedSlider.Name = "SpeedSlider"
    SpeedSlider.Parent = FlyGui
    SpeedSlider.BackgroundColor3 = Color3.new(0.5,0.5,0.5)
    SpeedSlider.BackgroundTransparency = 0.3
    SpeedSlider.BorderSizePixel = 0
    SpeedSlider.Position = UDim2.new(0.5, 0, 0.7, 0)
    SpeedSlider.Size = UDim2.new(0.6, 0, 0.02, 0)
    SpeedSlider.ZIndex = 10

    local SpeedSliderFill = Instance.new("Frame")
    SpeedSliderFill.Name = "SpeedSliderFill"
    SpeedSliderFill.Parent = SpeedSlider
    SpeedSliderFill.BackgroundColor3 = Color3.new(0,1,0)
    SpeedSliderFill.BorderSizePixel = 0
    SpeedSliderFill.Size = UDim2.new(FlySpeed/30, 0, 1, 0) -- Asumsi max speed 30
    SpeedSliderFill.ZIndex = 11

    -- Label Speed Slider
    local SpeedSliderLabel = Instance.new("TextLabel")
    SpeedSliderLabel.Name = "SpeedSliderLabel"
    SpeedSliderLabel.Parent = FlyGui
    SpeedSliderLabel.BackgroundColor3 = Color3.new(0,0,0)
    SpeedSliderLabel.BackgroundTransparency = 0.5
    SpeedSliderLabel.BorderSizePixel = 0
    SpeedSliderLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
    SpeedSliderLabel.Size = UDim2.new(0.8, 0, 0.05, 0)
    SpeedSliderLabel.Text = "Kecepatan Terbang: " .. FlySpeed
    SpeedSliderLabel.TextColor3 = Color3.new(1,1,1)
    SpeedSliderLabel.TextScaled = true
    SpeedSliderLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedSliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    SpeedSliderLabel.ZIndex = 10

    return FlyGui, StatusLabel, FlyStatusLabel, SpeedLabel, ToggleButton, SpeedSlider, SpeedSliderFill, SpeedSliderLabel
end

-- Panggil fungsi buat bikin UI
local FlyGui, StatusLabel, FlyStatusLabel, SpeedLabel, ToggleButton, SpeedSlider, SpeedSliderFill, SpeedSliderLabel = createFlyUI()

-- Update UI kalo status terbang berubah
Humanoid.Died:Connect(function()
    if IsFlying then
        StopFlying()
        if ToggleButton then
            ToggleButton.Text = "Aktifkan (Q)"
            ToggleButton.BackgroundColor3 = Color3.new(0,1,0)
            FlyStatusLabel.Text = "Status: Nonaktif"
        end
    end
end)

print("Script Fly dengan UI siap, cok!")
