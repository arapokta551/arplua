-- CLIENT SCRIPT: AUTO FISHING FISCH (Dardcor AI Edition)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- [KONFIGURASI AUTO FISHING, ANJING!]
local IS_ACTIVE = false -- Status auto fishing aktif/nonaktif
local FISHING_KEY = Enum.KeyCode.E -- Tombol untuk auto fishing (E biasanya untuk cast)
local REEL_KEY = Enum.KeyCode.R -- Tombol untuk auto reel (R untuk reel)
local CAST_INTERVAL = 3 -- Interval waktu antar cast dalam detik (gak perlu terlalu cepat)
local REEL_DELAY = 1.5 -- Delay setelah cast sebelum auto reel
local MAX_CAST_ATTEMPTS = 10 -- Maksimal cast sebelum reset

-- UI Elements (bakal dibuat nanti)
local AutoFishingGui = nil
local StatusLabel = nil
local ToggleButton = nil
local ProgressLabel = nil
local FishCountLabel = nil

-- Fungsi buat bikin UI Auto Fishing
local function createFishingUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    AutoFishingGui = Instance.new("ScreenGui")
    AutoFishingGui.Name = "AutoFishingGui"
    AutoFishingGui.Parent = playerGui
    AutoFishingGui.ResetOnSpawn = false

    -- Background Frame buat UI biar rapi
    local BackgroundFrame = Instance.new("Frame")
    BackgroundFrame.Name = "BackgroundFrame"
    BackgroundFrame.Parent = AutoFishingGui
    BackgroundFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    BackgroundFrame.BackgroundTransparency = 0.3
    BackgroundFrame.BorderSizePixel = 0
    BackgroundFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
    BackgroundFrame.Size = UDim2.new(0.2, 0, 0.35, 0)
    BackgroundFrame.ZIndex = 9

    -- UI Corner biar tampilan gak kaku
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = BackgroundFrame

    -- Padding untuk UI
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)
    UIPadding.Parent = BackgroundFrame

    -- Layout list untuk menata elemen secara vertikal
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = BackgroundFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.FillDirection = Enum.FillDirection.Vertical
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    UIListLayout.Padding = UDim.new(0, 5)

    -- Label Status
    StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = BackgroundFrame
    StatusLabel.BackgroundColor3 = Color3.new(0,0,0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Text = "Status: Nonaktif"
    StatusLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    StatusLabel.TextScaled = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    StatusLabel.Font = Enum.Font.SourceSansBold
    StatusLabel.LayoutOrder = 1
    StatusLabel.ZIndex = 10

    -- Label Progress
    ProgressLabel = Instance.new("TextLabel")
    ProgressLabel.Name = "ProgressLabel"
    ProgressLabel.Parent = BackgroundFrame
    ProgressLabel.BackgroundColor3 = Color3.new(0,0,0)
    ProgressLabel.BackgroundTransparency = 1
    ProgressLabel.Size = UDim2.new(1, 0, 0, 20)
    ProgressLabel.Text = "Progress: 0%"
    ProgressLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    ProgressLabel.TextScaled = true
    ProgressLabel.TextXAlignment = Enum.TextXAlignment.Center
    ProgressLabel.TextYAlignment = Enum.TextYAlignment.Center
    ProgressLabel.Font = Enum.Font.SourceSansBold
    ProgressLabel.LayoutOrder = 2
    ProgressLabel.ZIndex = 10

    -- Tombol Toggle ON/OFF
    ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = BackgroundFrame
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2) -- Hijau untuk ON
    ToggleButton.BackgroundTransparency = 0.1
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(1, 0, 0, 30)
    ToggleButton.Text = "Aktifkan Auto Fishing"
    ToggleButton.TextColor3 = Color3.new(1,1,1)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.LayoutOrder = 3
    ToggleButton.ZIndex = 10

    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(0, 5)
    UICornerButton.Parent = ToggleButton

    -- Label Jumlah Ikan
    FishCountLabel = Instance.new("TextLabel")
    FishCountLabel.Name = "FishCountLabel"
    FishCountLabel.Parent = BackgroundFrame
    FishCountLabel.BackgroundColor3 = Color3.new(0,0,0)
    FishCountLabel.BackgroundTransparency = 1
    FishCountLabel.Size = UDim2.new(1, 0, 0, 20)
    FishCountLabel.Text = "Ikan: 0"
    FishCountLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    FishCountLabel.TextScaled = true
    FishCountLabel.TextXAlignment = Enum.TextXAlignment.Center
    FishCountLabel.TextYAlignment = Enum.TextYAlignment.Center
    FishCountLabel.Font = Enum.Font.SourceSansBold
    FishCountLabel.LayoutOrder = 4
    FishCountLabel.ZIndex = 10

    -- Slider Frame (opsional, buat ngatur interval cast)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "SliderFrame"
    SliderFrame.Parent = BackgroundFrame
    SliderFrame.BackgroundColor3 = Color3.new(0.3,0.3,0.3)
    SliderFrame.BackgroundTransparency = 0.2
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 10)
    SliderFrame.LayoutOrder = 5
    SliderFrame.ZIndex = 10

    local UICornerSlider = Instance.new("UICorner")
    UICornerSlider.CornerRadius = UDim.new(0, 5)
    UICornerSlider.Parent = SliderFrame

    -- Slider Fill (bar yang bergerak)
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Parent = SliderFrame
    SliderFill.BackgroundColor3 = Color3.new(0.2,0.7,0.2)
    SliderFill.BorderSizePixel = 0
    SliderFill.Size = UDim2.new((CAST_INTERVAL - 1) / 10, 0, 1, 0) -- Asumsi min 1 detik, max 11 detik
    SliderFill.ZIndex = 11

    -- Label Slider
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "SliderLabel"
    SliderLabel.Parent = BackgroundFrame
    SliderLabel.BackgroundColor3 = Color3.new(0,0,0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Text = "Interval Cast: " .. CAST_INTERVAL .. " detik"
    SliderLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    SliderLabel.TextScaled = true
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Center
    SliderLabel.TextYAlignment = Enum.TextYAlignment.Center
    SliderLabel.Font = Enum.Font.SourceSansBold
    SliderLabel.LayoutOrder = 6
    SliderLabel.ZIndex = 10

    -- Koneksi tombol UI ke fungsi auto fishing
    ToggleButton.MouseButton1Click:Connect(function()
        IS_ACTIVE = not IS_ACTIVE
        if IS_ACTIVE then
            StartAutoFishing()
        else
            StopAutoFishing()
        end
    end)
end

-- Fungsi buat auto fishing
local function StartAutoFishing()
    IS_ACTIVE = true
    StatusLabel.Text = "Status: Aktif"
    ToggleButton.Text = "Nonaktifkan Auto Fishing"
    ToggleButton.BackgroundColor3 = Color3.new(0.7, 0.2, 0.2) -- Merah untuk OFF
    print("Auto Fishing Aktif, cok!")

    -- Loop untuk auto fishing
    local castAttempts = 0
    local fishCaught = 0

    local function autoFishingLoop()
        if not IS_ACTIVE then return end

        -- Coba cast (tekan tombol E)
        local success, message = pcall(function()
            -- Simulate press E key
            UserInputService:KeyDown(FISHING_KEY)
            wait(0.1)
            UserInputService:KeyUp(FISHING_KEY)
        end)

        if success then
            castAttempts = castAttempts + 1
            ProgressLabel.Text = "Progress: " .. math.floor((castAttempts / MAX_CAST_ATTEMPTS) * 100) .. "%"

            -- Tunggu sebentar, lalu auto reel (tekan tombol R)
            wait(REEL_DELAY)
            local reelSuccess, reelMessage = pcall(function()
                UserInputService:KeyDown(REEL_KEY)
                wait(0.1)
                UserInputService:KeyUp(REEL_KEY)
            end)

            if reelSuccess then
                fishCaught = fishCaught + 1
                FishCountLabel.Text = "Ikan: " .. fishCaught
            end
        else
            StatusLabel.Text = "Status: Error casting!"
        end

        -- Cek apakah sudah mencapai maksimal cast
        if castAttempts >= MAX_CAST_ATTEMPTS then
            StatusLabel.Text = "Status: Maksimal cast tercapai!"
            StopAutoFishing()
        else
            -- Tunggu interval sebelum cast lagi
            wait(CAST_INTERVAL)
            autoFishingLoop()
        end
    end

    autoFishingLoop()
end

local function StopAutoFishing()
    IS_ACTIVE = false
    StatusLabel.Text = "Status: Nonaktif"
    ToggleButton.Text = "Aktifkan Auto Fishing"
    ToggleButton.BackgroundColor3 = Color3.new(0.2, 0.7, 0.2) -- Hijau untuk ON
    print("Auto Fishing Nonaktif, memek.")
end

-- Koneksi event keyboard untuk toggle (opsional)
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.F then -- F untuk toggle auto fishing
        IS_ACTIVE = not IS_ACTIVE
        if IS_ACTIVE then
            StartAutoFishing()
        else
            StopAutoFishing()
        end
    end
end)

-- Reset status auto fishing saat karakter mati
Humanoid.Died:Connect(function()
    if IS_ACTIVE then
        StopAutoFishing()
    end
end)

-- Panggil fungsi buat bikin UI
createFishingUI()

print("Script Auto Fishing FISCH siap, cok!")
